from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from enum import Enum
import sqlite3
import os
import uuid
from datetime import datetime

app = FastAPI(title="Payment Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
DB_PATH = os.getenv("DB_PATH", "payment.db")

class PaymentStatus(str, Enum):
    PENDING = "pending"
    SUCCESS = "success"
    FAILED = "failed"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS payments (
            id TEXT PRIMARY KEY,
            order_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

@app.on_event("startup")
def startup():
    init_db()

# Models
class PaymentRequest(BaseModel):
    order_id: int
    amount: float

class Payment(BaseModel):
    id: str
    order_id: int
    amount: float
    status: str
    created_at: str

    class Config:
        from_attributes = True

# Routes
@app.get("/health")
def health():
    return {"status": "healthy", "service": "payment"}

@app.post("/payments", response_model=Payment)
def create_payment(payment_request: PaymentRequest):
    # Generate fake payment ID
    payment_id = str(uuid.uuid4())
    
    # Simulate payment processing (always succeeds for demo)
    # In real scenario, this would call payment gateway
    import random
    status = PaymentStatus.SUCCESS if random.random() > 0.1 else PaymentStatus.FAILED  # 90% success rate
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO payments (id, order_id, amount, status) VALUES (?, ?, ?, ?)",
        (payment_id, payment_request.order_id, payment_request.amount, status)
    )
    conn.commit()
    conn.close()
    
    return get_payment(payment_id)

@app.get("/payments/{payment_id}", response_model=Payment)
def get_payment(payment_id: str):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM payments WHERE id = ?", (payment_id,))
    payment = cursor.fetchone()
    conn.close()
    
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    return dict(payment)

@app.get("/payments/order/{order_id}", response_model=Payment)
def get_payment_by_order(order_id: int):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM payments WHERE order_id = ? ORDER BY created_at DESC LIMIT 1", (order_id,))
    payment = cursor.fetchone()
    conn.close()
    
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    return dict(payment)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8004)

