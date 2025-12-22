# E-Commerce Microservices - Complete Technical Documentation

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [System Architecture](#system-architecture)
3. [Technology Stack](#technology-stack)
4. [Component Details](#component-details)
5. [API Documentation](#api-documentation)
6. [Data Flow](#data-flow)
7. [Deployment Architecture](#deployment-architecture)
8. [Configuration Details](#configuration-details)
9. [Database Schema](#database-schema)
10. [Network Architecture](#network-architecture)
11. [CI/CD Pipeline](#cicd-pipeline)
12. [Security Considerations](#security-considerations)
13. [Monitoring & Logging](#monitoring--logging)
14. [Scaling & Performance](#scaling--performance)
15. [Troubleshooting Guide](#troubleshooting-guide)

---

## Executive Summary

### Project Overview
This is a **containerized microservices e-commerce platform** built with modern cloud-native technologies. The system consists of four independent microservices (Catalog, Cart, Order, Payment), a React-based dashboard, and supporting infrastructure (Kafka, Zookeeper) for event-driven communication.

### Key Features
- **Microservices Architecture**: Fully isolated services with independent databases
- **Kubernetes Orchestration**: Deployed on KinD (Kubernetes in Docker) for local development
- **Event-Driven Communication**: Kafka integration for order events
- **GitOps Deployment**: ArgoCD configuration for automated deployments
- **CI/CD Automation**: GitHub Actions pipeline for automated builds and deployments
- **Real-time Dashboard**: React-based UI with auto-refresh capabilities

### System Capabilities
- Product catalog management (CRUD operations)
- Shopping cart management (add/remove items, quantity updates)
- Order creation and tracking
- Payment processing simulation
- Real-time order status monitoring
- Complete e-commerce workflow from browsing to payment

---

## System Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         React Dashboard (Port 3000)                       │  │
│  │  - Dashboard Tab (Statistics & Recent Orders)           │  │
│  │  - Products Tab (Browse & Create Products)                │  │
│  │  - Cart Tab (Manage Cart & Checkout)                      │  │
│  │  - Orders Tab (View Orders & Process Payments)           │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/REST API
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY LAYER                          │
│  (Port-forwarding provides access to services)                 │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Catalog    │    │     Cart     │    │   Payment    │
│   Service    │    │   Service    │    │   Service    │
│   Port 8001  │    │   Port 8002  │    │   Port 8004  │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                    │                    │
       │                    │                    │
       └────────────────────┼────────────────────┘
                            │
                            ▼
                   ┌──────────────┐
                   │    Order     │
                   │   Service    │
                   │   Port 8003  │
                   └──────┬───────┘
                          │
                          │ Kafka Events
                          ▼
                   ┌──────────────┐
                   │    Kafka     │
                   │   Port 9092  │
                   └──────────────┘
```

### Service Communication Flow

```
User Action Flow:
1. Browse Products → Catalog Service (GET /products)
2. Add to Cart → Cart Service (POST /cart/{user_id}/items)
   └─> Cart Service calls Catalog Service to validate product
3. Create Order → Order Service (POST /orders)
   └─> Order Service calls Cart Service to get cart items
   └─> Order Service clears cart via Cart Service
   └─> Order Service publishes event to Kafka
4. Process Payment → Order Service (POST /orders/{id}/payment)
   └─> Order Service calls Payment Service
   └─> Order Service updates order status
   └─> Order Service publishes payment event to Kafka
```

### Data Storage Architecture

```
Each Service Has Independent Database:
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Catalog    │    │     Cart     │    │    Order     │    │   Payment    │
│   Service    │    │   Service    │    │   Service    │    │   Service    │
│              │    │              │    │              │    │              │
│ catalog.db   │    │  cart.db     │    │  order.db    │    │ payment.db   │
│ (SQLite)     │    │  (SQLite)    │    │  (SQLite)    │    │  (SQLite)    │
│              │    │              │    │              │    │              │
│ Products     │    │ Cart Items   │    │ Orders       │    │ Payments     │
│ Table        │    │ Table        │    │ Table        │    │ Table        │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
```

---

## Technology Stack

### Backend Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **API Framework** | FastAPI | 0.104.1 | RESTful API development |
| **Language** | Python | 3.11 | Backend programming language |
| **Database** | SQLite | 3.x | Lightweight embedded database |
| **HTTP Client** | httpx | 0.25.2 | Async HTTP requests between services |
| **Message Queue** | Kafka | 7.5.0 | Event-driven communication |
| **Kafka Coordinator** | Zookeeper | 7.5.0 | Kafka cluster coordination |
| **Data Validation** | Pydantic | 2.5.0 | Request/response validation |

### Frontend Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Framework** | React | 18.2.0 | UI framework |
| **HTTP Client** | Axios | 1.6.2 | API communication |
| **Build Tool** | react-scripts | 5.0.1 | React build and development |
| **Web Server** | Nginx | Alpine | Production web server |

### Infrastructure Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Containerization** | Docker | Latest | Container runtime |
| **Orchestration** | Kubernetes | 1.28.0 | Container orchestration |
| **Local K8s** | KinD | Latest | Local Kubernetes cluster |
| **GitOps** | ArgoCD | Latest | Automated deployment |
| **CI/CD** | GitHub Actions | Latest | Automated builds |
| **Container Registry** | Docker Hub | - | Image storage |

---

## Component Details

### 1. Catalog Service

**Purpose**: Manages product catalog with CRUD operations

**Technology**: FastAPI (Python 3.11)

**Port**: 8001

**Database**: SQLite (`catalog.db`)

**Key Features**:
- Product CRUD operations
- Product search and filtering
- Stock management
- Category organization
- Sample data initialization

**File Structure**:
```
services/catalog/
├── main.py              # FastAPI application
├── requirements.txt     # Python dependencies
└── Dockerfile          # Container definition
```

**Dependencies**:
- `fastapi==0.104.1` - Web framework
- `uvicorn[standard]==0.24.0` - ASGI server
- `pydantic==2.5.0` - Data validation

**Database Schema**:
```sql
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    category TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Initialization**:
- Creates database table on startup
- Seeds 4 sample products if database is empty:
  - Laptop ($999.99, Electronics)
  - Mouse ($29.99, Electronics)
  - Keyboard ($79.99, Electronics)
  - Monitor ($399.99, Electronics)

---

### 2. Cart Service

**Purpose**: Manages user shopping carts

**Technology**: FastAPI (Python 3.11)

**Port**: 8002

**Database**: SQLite (`cart.db`)

**Dependencies**: Catalog Service (for product validation)

**Key Features**:
- Add items to cart
- Remove items from cart
- Update item quantities
- Get cart with product details
- Clear entire cart
- Stock validation

**File Structure**:
```
services/cart/
├── main.py              # FastAPI application
├── requirements.txt     # Python dependencies
└── Dockerfile          # Container definition
```

**Dependencies**:
- `fastapi==0.104.1`
- `uvicorn[standard]==0.24.0`
- `pydantic==2.5.0`
- `httpx==0.25.2` - For calling Catalog Service

**Database Schema**:
```sql
CREATE TABLE cart_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
)
```

**Service Communication**:
- Calls Catalog Service to validate products exist
- Calls Catalog Service to check stock availability
- Calls Catalog Service to get product details (name, price)

**Environment Variables**:
- `CATALOG_SERVICE_URL`: http://catalog-service:8001 (K8s) or http://catalog:8001 (Docker Compose)

---

### 3. Order Service

**Purpose**: Handles order creation, tracking, and payment processing

**Technology**: FastAPI (Python 3.11)

**Port**: 8003

**Database**: SQLite (`order.db`)

**Dependencies**: Cart Service, Payment Service, Kafka

**Key Features**:
- Create orders from cart
- Order status tracking (pending → confirmed → paid → processing → shipped → delivered)
- Payment processing integration
- Order history retrieval
- Kafka event publishing
- Automatic cart clearing after order creation

**File Structure**:
```
services/order/
├── main.py              # FastAPI application
├── requirements.txt     # Python dependencies
└── Dockerfile          # Container definition
```

**Dependencies**:
- `fastapi==0.104.1`
- `uvicorn[standard]==0.24.0`
- `pydantic==2.5.0`
- `httpx==0.25.2` - For calling Cart and Payment services
- `kafka-python==2.0.2` - For Kafka event publishing

**Database Schema**:
```sql
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    total_amount REAL NOT NULL,
    items TEXT NOT NULL,  -- JSON string
    payment_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Order Status Flow**:
```
pending → confirmed → paid → processing → shipped → delivered
   │                                    │
   └──────────→ cancelled ──────────────┘
```

**Kafka Events Published**:
- `order_created` - When order is created
- `order_status_updated` - When order status changes
- `order_paid` - When payment is processed

**Service Communication**:
- GET cart from Cart Service
- DELETE cart after order creation
- POST payment to Payment Service
- Publish events to Kafka (non-blocking, errors are logged but don't fail)

**Environment Variables**:
- `CART_SERVICE_URL`: http://cart-service:8002
- `PAYMENT_SERVICE_URL`: http://payment-service:8004
- `KAFKA_BOOTSTRAP_SERVERS`: kafka:9092

---

### 4. Payment Service

**Purpose**: Simulates payment processing

**Technology**: FastAPI (Python 3.11)

**Port**: 8004

**Database**: SQLite (`payment.db`)

**Key Features**:
- Payment creation
- Payment status tracking
- Payment lookup by order ID
- Simulated payment processing (90% success rate)

**File Structure**:
```
services/payment/
├── main.py              # FastAPI application
├── requirements.txt     # Python dependencies
└── Dockerfile          # Container definition
```

**Dependencies**:
- `fastapi==0.104.1`
- `uvicorn[standard]==0.24.0`
- `pydantic==2.5.0`

**Database Schema**:
```sql
CREATE TABLE payments (
    id TEXT PRIMARY KEY,  -- UUID string
    order_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Payment Status**:
- `pending` - Payment initiated
- `success` - Payment approved (90% chance)
- `failed` - Payment rejected (10% chance)

**Payment ID Format**: UUID v4 (e.g., `550e8400-e29b-41d4-a716-446655440000`)

---

### 5. Dashboard (Frontend)

**Purpose**: React-based web interface for e-commerce operations

**Technology**: React 18, Nginx

**Port**: 3000 (via port-forwarding) or 30000 (NodePort)

**Key Features**:
- Real-time order monitoring (auto-refresh every 5 seconds)
- Product browsing and creation
- Shopping cart management
- Order creation and payment processing
- Responsive design (mobile and desktop)

**File Structure**:
```
dashboard/
├── public/
│   └── index.html          # HTML template
├── src/
│   ├── App.js              # Main React component
│   ├── App.css             # Component styles
│   ├── index.js            # React entry point
│   └── index.css           # Global styles
├── package.json            # Node.js dependencies
├── Dockerfile              # Multi-stage build (Node + Nginx)
└── nginx.conf              # Nginx configuration
```

**Dependencies**:
- `react`: ^18.2.0
- `react-dom`: ^18.2.0
- `react-scripts`: 5.0.1
- `axios`: ^1.6.2

**Build Process**:
1. **Build Stage**: Node.js builds React app (`npm run build`)
2. **Production Stage**: Nginx serves static files from `/usr/share/nginx/html`

**Environment Variables** (set at build time):
- `REACT_APP_API_URL`: http://localhost:8003 (default)
- `REACT_APP_CATALOG_URL`: http://localhost:8001
- `REACT_APP_CART_URL`: http://localhost:8002
- `REACT_APP_ORDER_URL`: http://localhost:8003
- `REACT_APP_PAYMENT_URL`: http://localhost:8004

**User Persistence**:
- User ID stored in `localStorage`
- Auto-generated if not present: `user{random_number}`

**API Integration**:
- All API calls use Axios
- Error handling with user-friendly messages
- Loading states during API calls

---

### 6. Kafka & Zookeeper

**Purpose**: Event-driven communication for order events

**Technology**: Confluent Platform

**Kafka Port**: 9092

**Zookeeper Port**: 2181

**Configuration**:
- **Broker ID**: 1
- **Replication Factor**: 1 (single broker setup)
- **Topic**: `order-events`
- **Advertised Listeners**: PLAINTEXT://kafka:9092

**Events Published**:
```json
{
  "event_type": "order_created" | "order_status_updated" | "order_paid",
  "timestamp": "2025-12-22T05:30:00.000Z",
  "data": {
    "order_id": 1,
    "user_id": "user123",
    "total_amount": 199.98,
    "status": "pending" | "paid" | ...
  }
}
```

**Zookeeper Configuration**:
- Client Port: 2181
- Tick Time: 2000ms
- Used for Kafka cluster coordination

---

## API Documentation

### Catalog Service API

**Base URL**: `http://localhost:8001`

#### GET /health
**Description**: Health check endpoint

**Response**:
```json
{
  "status": "healthy",
  "service": "catalog"
}
```

#### GET /products
**Description**: Get all products

**Query Parameters**:
- `skip` (int, optional): Number of products to skip (default: 0)
- `limit` (int, optional): Maximum number of products (default: 100)

**Response**:
```json
[
  {
    "id": 1,
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 999.99,
    "stock": 10,
    "category": "Electronics",
    "created_at": "2025-12-22T05:00:00"
  }
]
```

#### GET /products/{product_id}
**Description**: Get a specific product

**Path Parameters**:
- `product_id` (int): Product ID

**Response**: Product object (same as above)

**Error**: 404 if product not found

#### POST /products
**Description**: Create a new product

**Request Body**:
```json
{
  "name": "New Product",
  "description": "Product description",
  "price": 99.99,
  "stock": 50,
  "category": "Electronics"
}
```

**Response**: Created product object

#### PUT /products/{product_id}
**Description**: Update a product

**Path Parameters**:
- `product_id` (int): Product ID

**Request Body** (all fields optional):
```json
{
  "name": "Updated Name",
  "price": 89.99,
  "stock": 40
}
```

**Response**: Updated product object

#### DELETE /products/{product_id}
**Description**: Delete a product

**Path Parameters**:
- `product_id` (int): Product ID

**Response**:
```json
{
  "message": "Product deleted successfully"
}
```

---

### Cart Service API

**Base URL**: `http://localhost:8002`

#### GET /health
**Description**: Health check endpoint

**Response**:
```json
{
  "status": "healthy",
  "service": "cart"
}
```

#### GET /cart/{user_id}
**Description**: Get user's cart

**Path Parameters**:
- `user_id` (string): User identifier

**Response**:
```json
{
  "user_id": "user123",
  "items": [
    {
      "id": 1,
      "user_id": "user123",
      "product_id": 1,
      "quantity": 2,
      "product_name": "Laptop",
      "product_price": 999.99,
      "created_at": "2025-12-22T05:00:00"
    }
  ],
  "total": 1999.98
}
```

#### POST /cart/{user_id}/items
**Description**: Add item to cart

**Path Parameters**:
- `user_id` (string): User identifier

**Request Body**:
```json
{
  "product_id": 1,
  "quantity": 2
}
```

**Response**: Cart item object

**Errors**:
- 404: Product not found
- 400: Insufficient stock

#### PUT /cart/{user_id}/items/{product_id}
**Description**: Update item quantity

**Path Parameters**:
- `user_id` (string): User identifier
- `product_id` (int): Product ID

**Query Parameters**:
- `quantity` (int): New quantity

**Response**:
```json
{
  "message": "Item quantity updated"
}
```

#### DELETE /cart/{user_id}/items/{product_id}
**Description**: Remove item from cart

**Path Parameters**:
- `user_id` (string): User identifier
- `product_id` (int): Product ID

**Response**:
```json
{
  "message": "Item removed from cart"
}
```

#### DELETE /cart/{user_id}
**Description**: Clear entire cart

**Path Parameters**:
- `user_id` (string): User identifier

**Response**:
```json
{
  "message": "Cart cleared"
}
```

---

### Order Service API

**Base URL**: `http://localhost:8003`

#### GET /health
**Description**: Health check endpoint

**Response**:
```json
{
  "status": "healthy",
  "service": "order"
}
```

#### POST /orders
**Description**: Create a new order from user's cart

**Request Body**:
```json
{
  "user_id": "user123"
}
```

**Response**:
```json
{
  "id": 1,
  "user_id": "user123",
  "status": "pending",
  "total_amount": 1999.98,
  "items": [
    {
      "product_id": 1,
      "product_name": "Laptop",
      "quantity": 2,
      "price": 999.99
    }
  ],
  "payment_id": null,
  "created_at": "2025-12-22T05:00:00",
  "updated_at": "2025-12-22T05:00:00"
}
```

**Errors**:
- 404: Cart not found
- 400: Cart is empty

**Side Effects**:
- Clears user's cart
- Publishes `order_created` event to Kafka

#### GET /orders
**Description**: Get all orders

**Query Parameters**:
- `skip` (int, optional): Number of orders to skip (default: 0)
- `limit` (int, optional): Maximum number of orders (default: 100)

**Response**: Array of order objects

#### GET /orders/{order_id}
**Description**: Get a specific order

**Path Parameters**:
- `order_id` (int): Order ID

**Response**: Order object

**Error**: 404 if order not found

#### GET /orders/user/{user_id}
**Description**: Get all orders for a user

**Path Parameters**:
- `user_id` (string): User identifier

**Response**: Array of order objects (sorted by created_at DESC)

#### PUT /orders/{order_id}/status
**Description**: Update order status

**Path Parameters**:
- `order_id` (int): Order ID

**Request Body**:
```json
{
  "status": "confirmed" | "paid" | "processing" | "shipped" | "delivered" | "cancelled"
}
```

**Response**: Updated order object

**Side Effects**: Publishes `order_status_updated` event to Kafka

#### POST /orders/{order_id}/payment
**Description**: Process payment for an order

**Path Parameters**:
- `order_id` (int): Order ID

**Response**: Updated order object (status changed to "paid")

**Errors**:
- 400: Order is not in pending status
- 400: Payment failed

**Side Effects**:
- Calls Payment Service
- Updates order with payment_id
- Changes status to "paid"
- Publishes `order_paid` event to Kafka

---

### Payment Service API

**Base URL**: `http://localhost:8004`

#### GET /health
**Description**: Health check endpoint

**Response**:
```json
{
  "status": "healthy",
  "service": "payment"
}
```

#### POST /payments
**Description**: Create a payment

**Request Body**:
```json
{
  "order_id": 1,
  "amount": 1999.98
}
```

**Response**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "order_id": 1,
  "amount": 1999.98,
  "status": "success",
  "created_at": "2025-12-22T05:00:00"
}
```

**Payment Logic**:
- Generates UUID v4 payment ID
- 90% success rate (random)
- 10% failure rate (random)

#### GET /payments/{payment_id}
**Description**: Get payment by ID

**Path Parameters**:
- `payment_id` (string): Payment UUID

**Response**: Payment object

**Error**: 404 if payment not found

#### GET /payments/order/{order_id}
**Description**: Get payment by order ID

**Path Parameters**:
- `order_id` (int): Order ID

**Response**: Payment object (most recent)

**Error**: 404 if payment not found

---

## Data Flow

### Complete E-Commerce Flow

```
1. USER BROWSES PRODUCTS
   User → Dashboard → Catalog Service (GET /products)
   Response: List of products displayed

2. USER ADDS TO CART
   User → Dashboard → Cart Service (POST /cart/{user_id}/items)
   Cart Service → Catalog Service (GET /products/{id}) [validates product]
   Cart Service → Catalog Service [checks stock]
   Response: Item added to cart

3. USER CHECKS OUT
   User → Dashboard → Order Service (POST /orders)
   Order Service → Cart Service (GET /cart/{user_id}) [gets cart]
   Order Service → Cart Service (DELETE /cart/{user_id}) [clears cart]
   Order Service → Kafka [publishes order_created event]
   Response: Order created

4. USER PROCESSES PAYMENT
   User → Dashboard → Order Service (POST /orders/{id}/payment)
   Order Service → Payment Service (POST /payments)
   Payment Service → [generates payment, 90% success]
   Order Service → [updates order with payment_id, status="paid"]
   Order Service → Kafka [publishes order_paid event]
   Response: Payment processed, order status updated

5. DASHBOARD AUTO-REFRESHES
   Dashboard → Order Service (GET /orders) [every 5 seconds]
   Response: Updated order list displayed
```

### Service Dependencies

```
Catalog Service
  └─> No dependencies (standalone)

Cart Service
  └─> Depends on: Catalog Service
      - Validates products exist
      - Checks stock availability
      - Gets product details

Payment Service
  └─> No dependencies (standalone)

Order Service
  └─> Depends on: Cart Service, Payment Service, Kafka
      - Gets cart items
      - Clears cart
      - Processes payments
      - Publishes events

Dashboard
  └─> Depends on: All services
      - Catalog Service (products)
      - Cart Service (cart management)
      - Order Service (orders)
      - Payment Service (via Order Service)
```

---

## Deployment Architecture

### Kubernetes Deployment

**Namespace**: `ecommerce`

**Deployment Strategy**: Rolling updates with 2 replicas per service

**Service Types**:
- **ClusterIP**: Catalog, Cart, Order, Payment (internal only)
- **NodePort**: Dashboard (port 30000)

**Resource Limits**:
- **Memory**: 128Mi request, 256Mi limit per pod
- **CPU**: 100m request, 200m limit per pod

**Health Checks**:
- **Liveness Probe**: HTTP GET /health (10s initial delay, 10s period)
- **Readiness Probe**: HTTP GET /health (5s initial delay, 5s period)

**Volume Mounts**:
- **EmptyDir**: Persistent storage for SQLite databases
- **Mount Path**: `/data`

**Environment Variables**:
```yaml
Catalog Service:
  - DB_PATH: /data/catalog.db

Cart Service:
  - DB_PATH: /data/cart.db
  - CATALOG_SERVICE_URL: http://catalog-service:8001

Order Service:
  - DB_PATH: /data/order.db
  - CART_SERVICE_URL: http://cart-service:8002
  - PAYMENT_SERVICE_URL: http://payment-service:8004
  - KAFKA_BOOTSTRAP_SERVERS: kafka:9092

Payment Service:
  - DB_PATH: /data/payment.db

Dashboard:
  - REACT_APP_CATALOG_URL: http://catalog-service:8001
  - REACT_APP_CART_URL: http://cart-service:8002
  - REACT_APP_ORDER_URL: http://order-service:8003
  - REACT_APP_PAYMENT_URL: http://payment-service:8004
```

### Docker Compose Deployment

**Network**: `ecommerce-network` (bridge driver)

**Volumes**: Named volumes for data persistence
- `catalog-data`
- `cart-data`
- `order-data`
- `payment-data`

**Service Dependencies**:
- Zookeeper → Kafka
- Catalog → Cart
- Cart, Payment, Kafka → Order
- Order → Dashboard

**Port Mappings**:
- Catalog: 8001:8001
- Cart: 8002:8002
- Order: 8003:8003
- Payment: 8004:8004
- Dashboard: 3000:80
- Kafka: 9092:9092

---

## Configuration Details

### Docker Configuration

#### Service Dockerfiles
All services follow the same pattern:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
EXPOSE <port>
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "<port>"]
```

#### Dashboard Dockerfile (Multi-stage)
```dockerfile
# Build stage
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Kubernetes Configuration

#### Namespace
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
```

#### Deployment Example (Catalog Service)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog-service
  namespace: ecommerce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: catalog-service
  template:
    metadata:
      labels:
        app: catalog-service
    spec:
      containers:
      - name: catalog-service
        image: catalog-service:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8001
        env:
        - name: DB_PATH
          value: "/data/catalog.db"
        volumeMounts:
        - name: data
          mountPath: /data
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8001
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8001
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: data
        emptyDir: {}
```

#### Service Example
```yaml
apiVersion: v1
kind: Service
metadata:
  name: catalog-service
  namespace: ecommerce
spec:
  type: ClusterIP
  ports:
  - port: 8001
    targetPort: 8001
    protocol: TCP
  selector:
    app: catalog-service
```

### Kafka Configuration

**Environment Variables**:
```yaml
KAFKA_BROKER_ID: "1"
KAFKA_ZOOKEEPER_CONNECT: "zookeeper:2181"
KAFKA_LISTENERS: "PLAINTEXT://0.0.0.0:9092"
KAFKA_ADVERTISED_LISTENERS: "PLAINTEXT://kafka:9092"
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: "1"
KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: "1"
KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: "1"
KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
```

---

## Database Schema

### Catalog Service Database

**File**: `catalog.db`

**Table**: `products`
```sql
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    category TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Indexes**: Primary key on `id`

**Sample Data**:
- 4 products seeded on first startup
- Categories: Electronics

---

### Cart Service Database

**File**: `cart.db`

**Table**: `cart_items`
```sql
CREATE TABLE cart_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
)
```

**Constraints**: Unique constraint on `(user_id, product_id)` prevents duplicate items

---

### Order Service Database

**File**: `order.db`

**Table**: `orders`
```sql
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    total_amount REAL NOT NULL,
    items TEXT NOT NULL,  -- JSON array string
    payment_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Status Values**:
- `pending`
- `confirmed`
- `paid`
- `processing`
- `shipped`
- `delivered`
- `cancelled`

**Items Format** (JSON string):
```json
[
  {
    "product_id": 1,
    "product_name": "Laptop",
    "quantity": 2,
    "price": 999.99
  }
]
```

---

### Payment Service Database

**File**: `payment.db`

**Table**: `payments`
```sql
CREATE TABLE payments (
    id TEXT PRIMARY KEY,  -- UUID v4
    order_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**Status Values**:
- `pending`
- `success` (90% probability)
- `failed` (10% probability)

---

## Network Architecture

### Service Discovery

**Kubernetes**: Uses DNS-based service discovery
- Service name resolves to ClusterIP
- Example: `catalog-service.ecommerce.svc.cluster.local` → `10.96.82.112`

**Docker Compose**: Uses service names as hostnames
- Example: `catalog` → resolves to service IP

### Port Allocation

| Service | Container Port | Host Port (Docker) | NodePort (K8s) | Access Method |
|---------|---------------|-------------------|----------------|---------------|
| Catalog | 8001 | 8001 | - | Port-forward |
| Cart | 8002 | 8002 | - | Port-forward |
| Order | 8003 | 8003 | - | Port-forward |
| Payment | 8004 | 8004 | - | Port-forward |
| Dashboard | 80 | 3000 | 30000 | Port-forward or NodePort |
| Kafka | 9092 | 9092 | - | Internal only |
| Zookeeper | 2181 | - | - | Internal only |

### Network Policies

**Current**: No network policies (all services can communicate)

**Recommended for Production**:
- Restrict Cart Service to only Catalog Service
- Restrict Order Service to Cart, Payment, and Kafka
- Restrict Dashboard to all services

---

## CI/CD Pipeline

### GitHub Actions Workflow

**File**: `.github/workflows/ci-cd.yml`

**Triggers**:
- Push to `main` or `master` branch
- Pull requests to `main` or `master`

**Jobs**:

#### 1. build-and-test
**Runs on**: `ubuntu-latest`

**Steps**:
1. Checkout code
2. Set up Python 3.11
3. Install dependencies
4. Run tests (placeholder)
5. Set up Docker Buildx
6. Login to Docker Hub (if push event)
7. Build and push Catalog Service
8. Build and push Cart Service
9. Build and push Order Service
10. Build and push Payment Service
11. Build and push Dashboard

**Image Tags**:
- `latest` - Always updated
- `{commit-sha}` - Specific commit tag

**Example**: `seif1000iq/catalog-service:230cd47`

#### 2. deploy (Optional)
**Runs on**: `ubuntu-latest`

**Condition**: Only runs if `KUBECONFIG` secret exists

**Steps**:
1. Checkout code
2. Set up kubectl
3. Configure kubectl from secret
4. Update Kubernetes manifests with new image tags
5. Deploy to Kubernetes
6. Wait for deployments to be available

**Deployment Strategy**:
- Updates image tags in deployment YAMLs
- Uses `kubectl apply` for rolling updates
- Waits for all pods to be ready

### Docker Hub Configuration

**Registry**: `docker.io`

**Username**: `seif1000iq`

**Repositories**:
- `seif1000iq/catalog-service`
- `seif1000iq/cart-service`
- `seif1000iq/order-service`
- `seif1000iq/payment-service`
- `seif1000iq/dashboard`

**Required Secrets**:
- `DOCKER_USERNAME`: Docker Hub username
- `DOCKER_PASSWORD`: Docker Hub password or access token

---

## Security Considerations

### Current Security Posture

**Strengths**:
- Services isolated in containers
- Independent databases per service
- Health check endpoints for monitoring
- Environment variable configuration

**Areas for Improvement**:

1. **Authentication & Authorization**
   - Currently: No authentication
   - Recommended: JWT tokens, OAuth2, or API keys

2. **Data Encryption**
   - Currently: SQLite databases not encrypted
   - Recommended: Encrypt sensitive data at rest

3. **Network Security**
   - Currently: All services can communicate
   - Recommended: Network policies, service mesh (Istio)

4. **Secrets Management**
   - Currently: Environment variables
   - Recommended: Kubernetes Secrets, Vault

5. **HTTPS/TLS**
   - Currently: HTTP only
   - Recommended: TLS certificates, HTTPS endpoints

6. **Input Validation**
   - Currently: Pydantic validation
   - Recommended: Additional sanitization, rate limiting

### Security Best Practices Applied

- ✅ SQL injection prevention (parameterized queries)
- ✅ CORS configuration (dashboard)
- ✅ Container resource limits
- ✅ Health checks for availability
- ✅ Non-root user in containers (where applicable)

---

## Monitoring & Logging

### Current Monitoring

**Health Endpoints**: All services expose `/health`
- Returns: `{"status": "healthy", "service": "<service-name>"}`
- Used by: Kubernetes liveness and readiness probes

**Logging**:
- **Format**: Standard output (stdout)
- **Level**: INFO (FastAPI default)
- **Access**: `kubectl logs <pod-name> -n ecommerce`

### Recommended Monitoring Stack

**Metrics**:
- Prometheus for metrics collection
- Grafana for visualization
- Custom metrics: Request count, latency, error rate

**Logging**:
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Centralized log aggregation
- Log retention policies

**Tracing**:
- Jaeger or Zipkin for distributed tracing
- Track requests across services

**Alerting**:
- AlertManager for Prometheus alerts
- Notifications for service failures

---

## Scaling & Performance

### Current Scaling Configuration

**Replicas**: 2 per microservice (except Dashboard: 1)

**Resource Limits**:
- Memory: 256Mi per pod
- CPU: 200m per pod

### Horizontal Scaling

**Scaling Commands**:
```bash
# Scale catalog service to 5 replicas
kubectl scale deployment catalog-service -n ecommerce --replicas=5

# Auto-scaling (requires metrics server)
kubectl autoscale deployment catalog-service -n ecommerce --min=2 --max=10 --cpu-percent=80
```

### Performance Optimization

**Database**:
- Current: SQLite (single-file database)
- Production: PostgreSQL or MySQL with connection pooling
- Caching: Redis for frequently accessed data

**API Performance**:
- Current: Synchronous HTTP calls
- Optimization: Async/await patterns (already implemented)
- Caching: Response caching for product catalog

**Load Balancing**:
- Kubernetes Service provides load balancing
- Round-robin distribution across replicas

---

## Troubleshooting Guide

### Common Issues

#### 1. Services Not Starting

**Symptoms**: Pods in `CrashLoopBackOff` or `Error` state

**Diagnosis**:
```bash
kubectl get pods -n ecommerce
kubectl describe pod <pod-name> -n ecommerce
kubectl logs <pod-name> -n ecommerce
```

**Solutions**:
- Check resource limits (may need more memory/CPU)
- Verify environment variables are correct
- Check database file permissions
- Review application logs for errors

#### 2. Services Can't Communicate

**Symptoms**: 500 errors, connection refused

**Diagnosis**:
```bash
# Check service endpoints
kubectl get endpoints -n ecommerce

# Test service connectivity
kubectl exec -it <pod-name> -n ecommerce -- curl http://catalog-service:8001/health
```

**Solutions**:
- Verify service names match (case-sensitive)
- Check network policies
- Verify DNS resolution
- Check service selectors match pod labels

#### 3. Port-Forwarding Not Working

**Symptoms**: Can't access services from browser

**Diagnosis**:
```bash
# Check if port-forward is running
Get-Process | Where-Object {$_.ProcessName -like '*kubectl*'}

# Check if ports are in use
netstat -ano | findstr :8001
```

**Solutions**:
- Restart port-forwarding: `.\cloud\scripts\port-forward-all.ps1`
- Check for port conflicts
- Verify pods are running

#### 4. Kafka Not Starting

**Symptoms**: Kafka pod in `CrashLoopBackOff`

**Diagnosis**:
```bash
kubectl logs kafka-<pod-id> -n ecommerce
kubectl describe pod kafka-<pod-id> -n ecommerce
```

**Solutions**:
- Verify Zookeeper is running first
- Check Kafka environment variables
- Increase memory limits if needed
- Review Kafka logs for specific errors

#### 5. Database Issues

**Symptoms**: Data not persisting, database errors

**Diagnosis**:
```bash
# Check volume mounts
kubectl describe pod <pod-name> -n ecommerce | grep -A 5 "Mounts"

# Check database file
kubectl exec -it <pod-name> -n ecommerce -- ls -la /data
```

**Solutions**:
- Use PersistentVolumes instead of EmptyDir
- Check file permissions
- Verify volume mounts are correct

### Diagnostic Commands

```bash
# Check all pods
kubectl get pods -n ecommerce

# Check all services
kubectl get services -n ecommerce

# Check deployments
kubectl get deployments -n ecommerce

# View pod logs
kubectl logs -f deployment/catalog-service -n ecommerce

# Describe resource
kubectl describe deployment catalog-service -n ecommerce

# Check events
kubectl get events -n ecommerce --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n ecommerce
```

---

## Project Structure

```
ecommerce-microservices/
├── cloud/
│   ├── .github/
│   │   └── workflows/
│   │       └── ci-cd.yml          # CI/CD pipeline
│   ├── argocd/
│   │   └── applications/
│   │       ├── ecommerce-app.yaml # ArgoCD app config
│   │       └── kafka-app.yaml     # Kafka app config
│   ├── dashboard/
│   │   ├── public/
│   │   │   └── index.html         # HTML template
│   │   ├── src/
│   │   │   ├── App.js             # Main React component
│   │   │   ├── App.css            # Component styles
│   │   │   ├── index.js           # React entry point
│   │   │   └── index.css          # Global styles
│   │   ├── Dockerfile             # Multi-stage build
│   │   ├── nginx.conf             # Nginx configuration
│   │   └── package.json           # Node.js dependencies
│   ├── k8s/
│   │   ├── namespace.yaml         # Kubernetes namespace
│   │   ├── catalog/
│   │   │   ├── deployment.yaml    # Catalog deployment
│   │   │   └── service.yaml       # Catalog service
│   │   ├── cart/
│   │   │   ├── deployment.yaml    # Cart deployment
│   │   │   └── service.yaml       # Cart service
│   │   ├── order/
│   │   │   ├── deployment.yaml    # Order deployment
│   │   │   └── service.yaml       # Order service
│   │   ├── payment/
│   │   │   ├── deployment.yaml    # Payment deployment
│   │   │   └── service.yaml       # Payment service
│   │   └── dashboard/
│   │       ├── deployment.yaml    # Dashboard deployment
│   │       └── service.yaml       # Dashboard service
│   ├── kafka/
│   │   └── kafka-deployment.yaml  # Kafka & Zookeeper
│   ├── scripts/
│   │   ├── setup-kind.ps1         # KinD cluster setup (Windows)
│   │   ├── setup-kind.sh          # KinD cluster setup (Linux/macOS)
│   │   ├── build-and-load-images.ps1 # Build & load images
│   │   ├── deploy-all.ps1         # Deploy all services
│   │   ├── port-forward-all.ps1   # Port-forward all services
│   │   ├── check-services.ps1     # Check service status
│   │   └── ... (many more utility scripts)
│   ├── services/
│   │   ├── catalog/
│   │   │   ├── main.py            # FastAPI application
│   │   │   ├── requirements.txt   # Python dependencies
│   │   │   └── Dockerfile         # Container definition
│   │   ├── cart/
│   │   │   ├── main.py
│   │   │   ├── requirements.txt
│   │   │   └── Dockerfile
│   │   ├── order/
│   │   │   ├── main.py
│   │   │   ├── requirements.txt
│   │   │   └── Dockerfile
│   │   └── payment/
│   │       ├── main.py
│   │       ├── requirements.txt
│   │       └── Dockerfile
│   ├── docker-compose.yml         # Docker Compose configuration
│   ├── Makefile                   # Make commands
│   ├── README.md                  # Main documentation
│   ├── TECHNICAL_DOCUMENTATION.md # This file
│   └── ... (other documentation files)
└── .github/
    └── workflows/
        └── ci-cd.yml              # CI/CD workflow (root level)
```

---

## Quick Reference

### Service URLs (After Port-Forwarding)

- **Dashboard**: http://localhost:3000
- **Catalog API**: http://localhost:8001
- **Cart API**: http://localhost:8002
- **Order API**: http://localhost:8003
- **Payment API**: http://localhost:8004

### API Documentation URLs

- **Catalog Swagger**: http://localhost:8001/docs
- **Cart Swagger**: http://localhost:8002/docs
- **Order Swagger**: http://localhost:8003/docs
- **Payment Swagger**: http://localhost:8004/docs

### Common Commands

```bash
# Kubernetes
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
kubectl logs -f deployment/catalog-service -n ecommerce
kubectl describe pod <pod-name> -n ecommerce

# Docker Compose
docker-compose up -d
docker-compose ps
docker-compose logs -f catalog
docker-compose down

# Port-Forwarding
kubectl port-forward svc/catalog-service -n ecommerce 8001:8001
kubectl port-forward svc/dashboard -n ecommerce 3000:80

# Scripts (from root directory)
.\cloud\scripts\check-services.ps1
.\cloud\scripts\port-forward-all.ps1
.\cloud\scripts\deploy-all.ps1
```

---

## Conclusion

This e-commerce microservices platform demonstrates modern cloud-native architecture principles:

- **Microservices**: Independent, scalable services
- **Containerization**: Docker for consistent deployments
- **Orchestration**: Kubernetes for automated management
- **CI/CD**: Automated build and deployment pipeline
- **Event-Driven**: Kafka for asynchronous communication
- **GitOps**: ArgoCD for declarative deployments

The system is production-ready for development and can be extended with additional features like authentication, monitoring, and cloud deployment.

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Author**: E-Commerce Microservices Team

