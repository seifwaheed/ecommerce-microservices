from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import sqlite3
import os
import httpx

app = FastAPI(title="Cart Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
DB_PATH = os.getenv("DB_PATH", "cart.db")
CATALOG_SERVICE_URL = os.getenv("CATALOG_SERVICE_URL", "http://catalog-service:8001")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS cart_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(user_id, product_id)
        )
    """)
    conn.commit()
    conn.close()

@app.on_event("startup")
def startup():
    init_db()

# Models
class CartItemCreate(BaseModel):
    product_id: int
    quantity: int = 1

class CartItem(BaseModel):
    id: int
    user_id: str
    product_id: int
    quantity: int
    product_name: Optional[str] = None
    product_price: Optional[float] = None
    created_at: str

    class Config:
        from_attributes = True

class CartResponse(BaseModel):
    user_id: str
    items: List[CartItem]
    total: float

# Helper function to get product info
async def get_product_info(product_id: int):
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{CATALOG_SERVICE_URL}/products/{product_id}")
            if response.status_code == 200:
                return response.json()
    except Exception as e:
        print(f"Error fetching product: {e}")
    return None

# Routes
@app.get("/health")
def health():
    return {"status": "healthy", "service": "cart"}

@app.get("/cart/{user_id}", response_model=CartResponse)
async def get_cart(user_id: str):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM cart_items WHERE user_id = ?", (user_id,))
    rows = cursor.fetchall()
    conn.close()
    
    items = []
    total = 0.0
    
    for row in rows:
        product_info = await get_product_info(row["product_id"])
        item = dict(row)
        if product_info:
            item["product_name"] = product_info.get("name")
            item["product_price"] = product_info.get("price")
            total += product_info.get("price", 0) * row["quantity"]
        items.append(CartItem(**item))
    
    return CartResponse(user_id=user_id, items=items, total=total)

@app.post("/cart/{user_id}/items", response_model=CartItem)
async def add_item(user_id: str, item: CartItemCreate):
    # Verify product exists
    product_info = await get_product_info(item.product_id)
    if not product_info:
        raise HTTPException(status_code=404, detail="Product not found")
    
    # Check stock
    if product_info.get("stock", 0) < item.quantity:
        raise HTTPException(status_code=400, detail="Insufficient stock")
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Check if item already exists
    cursor.execute(
        "SELECT id, quantity FROM cart_items WHERE user_id = ? AND product_id = ?",
        (user_id, item.product_id)
    )
    existing = cursor.fetchone()
    
    if existing:
        # Update quantity
        new_quantity = existing[1] + item.quantity
        cursor.execute(
            "UPDATE cart_items SET quantity = ? WHERE id = ?",
            (new_quantity, existing[0])
        )
        item_id = existing[0]
    else:
        # Insert new item
        cursor.execute(
            "INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?)",
            (user_id, item.product_id, item.quantity)
        )
        item_id = cursor.lastrowid
    
    conn.commit()
    conn.close()
    
    # Return cart item with product info
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM cart_items WHERE id = ?", (item_id,))
    row = dict(cursor.fetchone())
    conn.close()
    
    row["product_name"] = product_info.get("name")
    row["product_price"] = product_info.get("price")
    
    return CartItem(**row)

@app.delete("/cart/{user_id}/items/{product_id}")
def remove_item(user_id: str, product_id: int):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        "DELETE FROM cart_items WHERE user_id = ? AND product_id = ?",
        (user_id, product_id)
    )
    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="Item not found in cart")
    conn.commit()
    conn.close()
    return {"message": "Item removed from cart"}

@app.put("/cart/{user_id}/items/{product_id}")
async def update_item_quantity(user_id: str, product_id: int, quantity: int):
    if quantity <= 0:
        raise HTTPException(status_code=400, detail="Quantity must be positive")
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE cart_items SET quantity = ? WHERE user_id = ? AND product_id = ?",
        (quantity, user_id, product_id)
    )
    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="Item not found in cart")
    conn.commit()
    conn.close()
    return {"message": "Item quantity updated"}

@app.delete("/cart/{user_id}")
def clear_cart(user_id: str):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM cart_items WHERE user_id = ?", (user_id,))
    conn.commit()
    conn.close()
    return {"message": "Cart cleared"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)

