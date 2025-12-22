from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import sqlite3
import os
from datetime import datetime

app = FastAPI(title="Catalog Service", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database setup
DB_PATH = os.getenv("DB_PATH", "catalog.db")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            price REAL NOT NULL,
            stock INTEGER NOT NULL DEFAULT 0,
            category TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

# Initialize database on startup
@app.on_event("startup")
def startup():
    init_db()
    # Add sample products
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM products")
    if cursor.fetchone()[0] == 0:
        sample_products = [
            ("Laptop", "High-performance laptop", 999.99, 10, "Electronics"),
            ("Mouse", "Wireless mouse", 29.99, 50, "Electronics"),
            ("Keyboard", "Mechanical keyboard", 79.99, 30, "Electronics"),
            ("Monitor", "27-inch 4K monitor", 399.99, 15, "Electronics"),
        ]
        cursor.executemany(
            "INSERT INTO products (name, description, price, stock, category) VALUES (?, ?, ?, ?, ?)",
            sample_products
        )
        conn.commit()
    conn.close()

# Models
class ProductCreate(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    stock: int = 0
    category: Optional[str] = None

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    stock: Optional[int] = None
    category: Optional[str] = None

class Product(BaseModel):
    id: int
    name: str
    description: Optional[str]
    price: float
    stock: int
    category: Optional[str]
    created_at: str

    class Config:
        from_attributes = True

# Routes
@app.get("/health")
def health():
    return {"status": "healthy", "service": "catalog"}

@app.get("/products", response_model=List[Product])
def get_products(skip: int = 0, limit: int = 100):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM products LIMIT ? OFFSET ?", (limit, skip))
    products = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return products

@app.get("/products/{product_id}", response_model=Product)
def get_product(product_id: int):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM products WHERE id = ?", (product_id,))
    product = cursor.fetchone()
    conn.close()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return dict(product)

@app.post("/products", response_model=Product)
def create_product(product: ProductCreate):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO products (name, description, price, stock, category) VALUES (?, ?, ?, ?, ?)",
        (product.name, product.description, product.price, product.stock, product.category)
    )
    product_id = cursor.lastrowid
    conn.commit()
    conn.close()
    
    return get_product(product_id)

@app.put("/products/{product_id}", response_model=Product)
def update_product(product_id: int, product: ProductUpdate):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Build update query dynamically
    updates = []
    values = []
    if product.name is not None:
        updates.append("name = ?")
        values.append(product.name)
    if product.description is not None:
        updates.append("description = ?")
        values.append(product.description)
    if product.price is not None:
        updates.append("price = ?")
        values.append(product.price)
    if product.stock is not None:
        updates.append("stock = ?")
        values.append(product.stock)
    if product.category is not None:
        updates.append("category = ?")
        values.append(product.category)
    
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    values.append(product_id)
    cursor.execute(f"UPDATE products SET {', '.join(updates)} WHERE id = ?", values)
    conn.commit()
    conn.close()
    
    return get_product(product_id)

@app.delete("/products/{product_id}")
def delete_product(product_id: int):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM products WHERE id = ?", (product_id,))
    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="Product not found")
    conn.commit()
    conn.close()
    return {"message": "Product deleted successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)

