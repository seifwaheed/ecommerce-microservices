from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from enum import Enum
import sqlite3
import os
import httpx
import json
from datetime import datetime

app = FastAPI(title="Order Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
DB_PATH = os.getenv("DB_PATH", "order.db")
CART_SERVICE_URL = os.getenv("CART_SERVICE_URL", "http://cart-service:8002")
PAYMENT_SERVICE_URL = os.getenv("PAYMENT_SERVICE_URL", "http://payment-service:8004")
KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")

class OrderStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    PAID = "paid"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            total_amount REAL NOT NULL,
            items TEXT NOT NULL,
            payment_id TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

@app.on_event("startup")
def startup():
    init_db()

# Models
class OrderItem(BaseModel):
    product_id: int
    product_name: str
    quantity: int
    price: float

class OrderCreate(BaseModel):
    user_id: str

class Order(BaseModel):
    id: int
    user_id: str
    status: str
    total_amount: float
    items: List[OrderItem]
    payment_id: Optional[str]
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True

# Helper function to publish to Kafka
async def publish_order_event(event_type: str, order_data: dict):
    try:
        from kafka import KafkaProducer
        producer = KafkaProducer(
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
        )
        event = {
            "event_type": event_type,
            "timestamp": datetime.utcnow().isoformat(),
            "data": order_data
        }
        producer.send("order-events", value=event)
        producer.flush()
    except Exception as e:
        print(f"Kafka publish error (non-critical): {e}")

# Routes
@app.get("/health")
def health():
    return {"status": "healthy", "service": "order"}

@app.post("/orders", response_model=Order)
async def create_order(order_data: OrderCreate):
    # Get cart items
    async with httpx.AsyncClient() as client:
        cart_response = await client.get(f"{CART_SERVICE_URL}/cart/{order_data.user_id}")
        if cart_response.status_code != 200:
            raise HTTPException(status_code=404, detail="Cart not found")
        
        cart = cart_response.json()
        if not cart.get("items"):
            raise HTTPException(status_code=400, detail="Cart is empty")
    
    # Create order
    items = []
    for item in cart["items"]:
        items.append({
            "product_id": item["product_id"],
            "product_name": item.get("product_name", "Unknown"),
            "quantity": item["quantity"],
            "price": item.get("product_price", 0)
        })
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO orders (user_id, status, total_amount, items) VALUES (?, ?, ?, ?)",
        (order_data.user_id, OrderStatus.PENDING.value, cart["total"], json.dumps(items))
    )
    order_id = cursor.lastrowid
    conn.commit()
    conn.close()
    
    # Clear cart
    async with httpx.AsyncClient() as client:
        await client.delete(f"{CART_SERVICE_URL}/cart/{order_data.user_id}")
    
    # Get created order
    order = await get_order(order_id)
    
    # Publish order created event
    await publish_order_event("order_created", {
        "order_id": order_id,
        "user_id": order_data.user_id,
        "total_amount": cart["total"]
    })
    
    return order

@app.get("/orders/{order_id}", response_model=Order)
async def get_order(order_id: int):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM orders WHERE id = ?", (order_id,))
    row = cursor.fetchone()
    conn.close()
    
    if not row:
        raise HTTPException(status_code=404, detail="Order not found")
    
    order_dict = dict(row)
    order_dict["items"] = json.loads(order_dict["items"])
    return Order(**order_dict)

@app.get("/orders/user/{user_id}", response_model=List[Order])
async def get_user_orders(user_id: str):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC", (user_id,))
    rows = cursor.fetchall()
    conn.close()
    
    orders = []
    for row in rows:
        order_dict = dict(row)
        order_dict["items"] = json.loads(order_dict["items"])
        orders.append(Order(**order_dict))
    
    return orders

@app.put("/orders/{order_id}/status")
async def update_order_status(order_id: int, status: OrderStatus):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        (status.value, order_id)
    )
    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="Order not found")
    conn.commit()
    conn.close()
    
    order = await get_order(order_id)
    
    # Publish status update event
    await publish_order_event("order_status_updated", {
        "order_id": order_id,
        "status": status.value
    })
    
    return order

@app.post("/orders/{order_id}/payment")
async def process_payment(order_id: int):
    order = await get_order(order_id)
    
    if order.status != OrderStatus.PENDING.value:
        raise HTTPException(status_code=400, detail="Order is not in pending status")
    
    # Call payment service
    async with httpx.AsyncClient() as client:
        payment_response = await client.post(
            f"{PAYMENT_SERVICE_URL}/payments",
            json={"order_id": order_id, "amount": order.total_amount}
        )
        if payment_response.status_code != 200:
            raise HTTPException(status_code=400, detail="Payment failed")
        
        payment_data = payment_response.json()
    
    # Update order with payment ID and status
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE orders SET payment_id = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        (payment_data.get("payment_id"), OrderStatus.PAID.value, order_id)
    )
    conn.commit()
    conn.close()
    
    updated_order = await get_order(order_id)
    
    # Publish payment event
    await publish_order_event("order_paid", {
        "order_id": order_id,
        "payment_id": payment_data.get("payment_id")
    })
    
    return updated_order

@app.get("/orders", response_model=List[Order])
async def get_all_orders(skip: int = 0, limit: int = 100):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM orders ORDER BY created_at DESC LIMIT ? OFFSET ?", (limit, skip))
    rows = cursor.fetchall()
    conn.close()
    
    orders = []
    for row in rows:
        order_dict = dict(row)
        order_dict["items"] = json.loads(order_dict["items"])
        orders.append(Order(**order_dict))
    
    return orders

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8003)

