import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8003';
const CATALOG_URL = process.env.REACT_APP_CATALOG_URL || 'http://localhost:8001';
const CART_URL = process.env.REACT_APP_CART_URL || 'http://localhost:8002';
const ORDER_URL = process.env.REACT_APP_ORDER_URL || 'http://localhost:8003';
const PAYMENT_URL = process.env.REACT_APP_PAYMENT_URL || 'http://localhost:8004';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [products, setProducts] = useState([]);
  const [cart, setCart] = useState(null);
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [userId] = useState(() => localStorage.getItem('userId') || `user${Math.floor(Math.random() * 10000)}`);
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [newProduct, setNewProduct] = useState({ name: '', description: '', price: '', stock: '', category: '' });

  useEffect(() => {
    localStorage.setItem('userId', userId);
    fetchData();
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, [userId]);

  const fetchData = async () => {
    try {
      await Promise.all([
        fetchProducts(),
        fetchCart(),
        fetchOrders()
      ]);
      setLoading(false);
      setError(null);
    } catch (err) {
      setError('Failed to connect to services. Make sure port-forwarding is active.');
      setLoading(false);
    }
  };

  const fetchProducts = async () => {
    try {
      const response = await axios.get(`${CATALOG_URL}/products`);
      setProducts(response.data);
    } catch (err) {
      console.error('Failed to fetch products:', err);
    }
  };

  const fetchCart = async () => {
    try {
      const response = await axios.get(`${CART_URL}/cart/${userId}`);
      setCart(response.data);
    } catch (err) {
      console.error('Failed to fetch cart:', err);
    }
  };

  const fetchOrders = async () => {
    try {
      const response = await axios.get(`${ORDER_URL}/orders`);
      setOrders(response.data);
    } catch (err) {
      console.error('Failed to fetch orders:', err);
    }
  };

  const addToCart = async (productId, quantity = 1) => {
    try {
      await axios.post(`${CART_URL}/cart/${userId}/items`, {
        product_id: productId,
        quantity: quantity
      });
      fetchCart();
      alert('Item added to cart!');
    } catch (err) {
      alert('Failed to add item to cart: ' + (err.response?.data?.detail || err.message));
    }
  };

  const removeFromCart = async (productId) => {
    try {
      await axios.delete(`${CART_URL}/cart/${userId}/items/${productId}`);
      fetchCart();
    } catch (err) {
      alert('Failed to remove item from cart');
    }
  };

  const updateCartQuantity = async (productId, quantity) => {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    try {
      await axios.put(`${CART_URL}/cart/${userId}/items/${productId}`, null, {
        params: { quantity }
      });
      fetchCart();
    } catch (err) {
      alert('Failed to update cart');
    }
  };

  const createOrder = async () => {
    if (!cart || !cart.items || cart.items.length === 0) {
      alert('Cart is empty!');
      return;
    }
    try {
      const response = await axios.post(`${ORDER_URL}/orders`, {
        user_id: userId
      });
      fetchOrders();
      fetchCart();
      alert(`Order created! Order ID: ${response.data.id}`);
    } catch (err) {
      alert('Failed to create order: ' + (err.response?.data?.detail || err.message));
    }
  };

  const processPayment = async (orderId) => {
    try {
      await axios.post(`${ORDER_URL}/orders/${orderId}/payment`);
      fetchOrders();
      alert('Payment processed!');
    } catch (err) {
      alert('Failed to process payment: ' + (err.response?.data?.detail || err.message));
    }
  };

  const createProduct = async (e) => {
    e.preventDefault();
    try {
      await axios.post(`${CATALOG_URL}/products`, {
        name: newProduct.name,
        description: newProduct.description,
        price: parseFloat(newProduct.price),
        stock: parseInt(newProduct.stock),
        category: newProduct.category
      });
      setNewProduct({ name: '', description: '', price: '', stock: '', category: '' });
      fetchProducts();
      alert('Product created!');
    } catch (err) {
      alert('Failed to create product: ' + (err.response?.data?.detail || err.message));
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      pending: '#f59e0b',
      confirmed: '#3b82f6',
      paid: '#10b981',
      processing: '#8b5cf6',
      shipped: '#6366f1',
      delivered: '#059669',
      cancelled: '#ef4444'
    };
    return colors[status] || '#6b7280';
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(amount);
  };

  if (loading) {
    return (
      <div className="app">
        <div className="loading-screen">
          <div className="loading-spinner"></div>
          <p>Loading e-commerce dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="app">
      <header className="app-header">
        <div className="header-content">
          <h1>🛒 E-Commerce Dashboard</h1>
          <div className="user-info">
            <span>User: {userId}</span>
          </div>
        </div>
      </header>

      <nav className="app-nav">
        <button 
          className={activeTab === 'dashboard' ? 'active' : ''} 
          onClick={() => setActiveTab('dashboard')}
        >
          📊 Dashboard
        </button>
        <button 
          className={activeTab === 'products' ? 'active' : ''} 
          onClick={() => setActiveTab('products')}
        >
          📦 Products
        </button>
        <button 
          className={activeTab === 'cart' ? 'active' : ''} 
          onClick={() => setActiveTab('cart')}
        >
          🛒 Cart {cart && cart.items && cart.items.length > 0 && `(${cart.items.length})`}
        </button>
        <button 
          className={activeTab === 'orders' ? 'active' : ''} 
          onClick={() => setActiveTab('orders')}
        >
          📋 Orders
        </button>
      </nav>

      {error && (
        <div className="error-banner">
          {error}
          <br />
          <small>Make sure to run: kubectl port-forward svc/catalog-service -n ecommerce 8001:8001 (and similar for other services)</small>
        </div>
      )}

      <main className="app-main">
        {activeTab === 'dashboard' && (
          <div className="dashboard-tab">
            <div className="stats-grid">
              <div className="stat-card">
                <div className="stat-icon">📦</div>
                <div className="stat-value">{products.length}</div>
                <div className="stat-label">Products</div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">🛒</div>
                <div className="stat-value">{cart?.items?.length || 0}</div>
                <div className="stat-label">Cart Items</div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">📋</div>
                <div className="stat-value">{orders.length}</div>
                <div className="stat-label">Total Orders</div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">💰</div>
                <div className="stat-value">
                  {formatCurrency(orders.reduce((sum, o) => sum + o.total_amount, 0))}
                </div>
                <div className="stat-label">Total Revenue</div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">✅</div>
                <div className="stat-value">
                  {orders.filter(o => o.status === 'delivered').length}
                </div>
                <div className="stat-label">Delivered</div>
              </div>
              <div className="stat-card">
                <div className="stat-icon">⏳</div>
                <div className="stat-value">
                  {orders.filter(o => ['pending', 'confirmed', 'paid', 'processing', 'shipped'].includes(o.status)).length}
                </div>
                <div className="stat-label">In Progress</div>
              </div>
            </div>

            <div className="dashboard-section">
              <h2>Recent Orders</h2>
              {orders.length === 0 ? (
                <div className="empty-state">
                  <p>No orders yet. Create an order from the Cart tab!</p>
                </div>
              ) : (
                <div className="orders-list">
                  {orders.slice(0, 5).map(order => (
                    <div key={order.id} className="order-card-mini" onClick={() => {
                      setSelectedOrder(order);
                      setActiveTab('orders');
                    }}>
                      <div className="order-mini-header">
                        <span className="order-id">Order #{order.id}</span>
                        <span 
                          className="status-badge-mini"
                          style={{ backgroundColor: getStatusColor(order.status) }}
                        >
                          {order.status}
                        </span>
                      </div>
                      <div className="order-mini-body">
                        <span>{formatCurrency(order.total_amount)}</span>
                        <span>{new Date(order.created_at).toLocaleDateString()}</span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'products' && (
          <div className="products-tab">
            <div className="section-header">
              <h2>Products Catalog</h2>
              <button className="btn-primary" onClick={() => document.getElementById('new-product-form').scrollIntoView()}>
                + Add Product
              </button>
            </div>

            <div className="products-grid">
              {products.map(product => (
                <div key={product.id} className="product-card">
                  <div className="product-header">
                    <h3>{product.name}</h3>
                    <span className="product-price">{formatCurrency(product.price)}</span>
                  </div>
                  <p className="product-description">{product.description || 'No description'}</p>
                  <div className="product-meta">
                    <span className="product-category">{product.category || 'Uncategorized'}</span>
                    <span className="product-stock">Stock: {product.stock}</span>
                  </div>
                  <button 
                    className="btn-add-cart"
                    onClick={() => addToCart(product.id, 1)}
                    disabled={product.stock === 0}
                  >
                    {product.stock > 0 ? 'Add to Cart' : 'Out of Stock'}
                  </button>
                </div>
              ))}
            </div>

            <div id="new-product-form" className="new-product-form">
              <h3>Create New Product</h3>
              <form onSubmit={createProduct}>
                <div className="form-row">
                  <input
                    type="text"
                    placeholder="Product Name"
                    value={newProduct.name}
                    onChange={(e) => setNewProduct({...newProduct, name: e.target.value})}
                    required
                  />
                  <input
                    type="text"
                    placeholder="Category"
                    value={newProduct.category}
                    onChange={(e) => setNewProduct({...newProduct, category: e.target.value})}
                  />
                </div>
                <textarea
                  placeholder="Description"
                  value={newProduct.description}
                  onChange={(e) => setNewProduct({...newProduct, description: e.target.value})}
                />
                <div className="form-row">
                  <input
                    type="number"
                    step="0.01"
                    placeholder="Price"
                    value={newProduct.price}
                    onChange={(e) => setNewProduct({...newProduct, price: e.target.value})}
                    required
                  />
                  <input
                    type="number"
                    placeholder="Stock"
                    value={newProduct.stock}
                    onChange={(e) => setNewProduct({...newProduct, stock: e.target.value})}
                    required
                  />
                </div>
                <button type="submit" className="btn-primary">Create Product</button>
              </form>
            </div>
          </div>
        )}

        {activeTab === 'cart' && (
          <div className="cart-tab">
            <div className="section-header">
              <h2>Shopping Cart</h2>
              {cart && cart.items && cart.items.length > 0 && (
                <button className="btn-primary" onClick={createOrder}>
                  Checkout & Create Order
                </button>
              )}
            </div>

            {!cart || !cart.items || cart.items.length === 0 ? (
              <div className="empty-state">
                <p>Your cart is empty. Add some products from the Products tab!</p>
              </div>
            ) : (
              <>
                <div className="cart-items">
                  {cart.items.map(item => (
                    <div key={item.id} className="cart-item">
                      <div className="cart-item-info">
                        <h4>{item.product_name || `Product ${item.product_id}`}</h4>
                        <p>{formatCurrency(item.product_price || 0)} each</p>
                      </div>
                      <div className="cart-item-controls">
                        <button 
                          className="btn-quantity"
                          onClick={() => updateCartQuantity(item.product_id, item.quantity - 1)}
                        >
                          -
                        </button>
                        <span className="quantity">{item.quantity}</span>
                        <button 
                          className="btn-quantity"
                          onClick={() => updateCartQuantity(item.product_id, item.quantity + 1)}
                        >
                          +
                        </button>
                        <button 
                          className="btn-remove"
                          onClick={() => removeFromCart(item.product_id)}
                        >
                          Remove
                        </button>
                      </div>
                      <div className="cart-item-total">
                        {formatCurrency((item.product_price || 0) * item.quantity)}
                      </div>
                    </div>
                  ))}
                </div>
                <div className="cart-summary">
                  <div className="cart-total">
                    <span>Total:</span>
                    <span className="total-amount">{formatCurrency(cart.total || 0)}</span>
                  </div>
                </div>
              </>
            )}
          </div>
        )}

        {activeTab === 'orders' && (
          <div className="orders-tab">
            <h2>Orders</h2>
            {orders.length === 0 ? (
              <div className="empty-state">
                <p>No orders yet. Add items to cart and create an order!</p>
              </div>
            ) : (
              <div className="orders-list-full">
                {orders.map(order => (
                  <div 
                    key={order.id} 
                    className={`order-card ${selectedOrder?.id === order.id ? 'selected' : ''}`}
                    onClick={() => setSelectedOrder(order)}
                  >
                    <div className="order-header">
                      <div className="order-id">Order #{order.id}</div>
                      <div 
                        className="status-badge"
                        style={{ backgroundColor: getStatusColor(order.status) }}
                      >
                        {order.status.toUpperCase()}
                      </div>
                    </div>
                    <div className="order-body">
                      <div className="order-info-row">
                        <span>User:</span>
                        <span>{order.user_id}</span>
                      </div>
                      <div className="order-info-row">
                        <span>Total:</span>
                        <span className="amount">{formatCurrency(order.total_amount)}</span>
                      </div>
                      <div className="order-info-row">
                        <span>Items:</span>
                        <span>{order.items.length}</span>
                      </div>
                      <div className="order-info-row">
                        <span>Created:</span>
                        <span>{new Date(order.created_at).toLocaleString()}</span>
                      </div>
                      {order.status === 'pending' && (
                        <button 
                          className="btn-payment"
                          onClick={(e) => {
                            e.stopPropagation();
                            processPayment(order.id);
                          }}
                        >
                          Process Payment
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}

            {selectedOrder && (
              <div className="modal-overlay" onClick={() => setSelectedOrder(null)}>
                <div className="modal" onClick={(e) => e.stopPropagation()}>
                  <div className="modal-header">
                    <h2>Order #{selectedOrder.id} Details</h2>
                    <button className="close-btn" onClick={() => setSelectedOrder(null)}>×</button>
                  </div>
                  <div className="modal-body">
                    <div className="detail-section">
                      <h3>Order Information</h3>
                      <div className="detail-grid">
                        <div className="detail-item">
                          <span className="detail-label">Status:</span>
                          <span className="detail-value status" style={{ color: getStatusColor(selectedOrder.status) }}>
                            {selectedOrder.status.toUpperCase()}
                          </span>
                        </div>
                        <div className="detail-item">
                          <span className="detail-label">User ID:</span>
                          <span className="detail-value">{selectedOrder.user_id}</span>
                        </div>
                        <div className="detail-item">
                          <span className="detail-label">Total Amount:</span>
                          <span className="detail-value amount">{formatCurrency(selectedOrder.total_amount)}</span>
                        </div>
                        <div className="detail-item">
                          <span className="detail-label">Payment ID:</span>
                          <span className="detail-value">{selectedOrder.payment_id || 'N/A'}</span>
                        </div>
                        <div className="detail-item">
                          <span className="detail-label">Created:</span>
                          <span className="detail-value">{new Date(selectedOrder.created_at).toLocaleString()}</span>
                        </div>
                        <div className="detail-item">
                          <span className="detail-label">Updated:</span>
                          <span className="detail-value">{new Date(selectedOrder.updated_at).toLocaleString()}</span>
                        </div>
                      </div>
                    </div>
                    <div className="detail-section">
                      <h3>Order Items</h3>
                      <table className="items-table">
                        <thead>
                          <tr>
                            <th>Product</th>
                            <th>Quantity</th>
                            <th>Price</th>
                            <th>Subtotal</th>
                          </tr>
                        </thead>
                        <tbody>
                          {selectedOrder.items.map((item, index) => (
                            <tr key={index}>
                              <td>{item.product_name}</td>
                              <td>{item.quantity}</td>
                              <td>{formatCurrency(item.price)}</td>
                              <td>{formatCurrency(item.price * item.quantity)}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
