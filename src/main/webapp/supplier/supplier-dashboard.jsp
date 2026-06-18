<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.nexusshope.model.User currentUser = (com.nexusshope.model.User) session.getAttribute("user");
    if (currentUser == null || !"supplier".equals(currentUser.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    java.util.List<com.nexusshope.model.Product> allProducts =
            (java.util.List<com.nexusshope.model.Product>) request.getAttribute("allProducts");
    java.util.List<com.nexusshope.model.Product> lowStockProducts =
            (java.util.List<com.nexusshope.model.Product>) request.getAttribute("lowStockProducts");
    java.util.List<com.nexusshope.model.Product> outOfStockProducts =
            (java.util.List<com.nexusshope.model.Product>) request.getAttribute("outOfStockProducts");
    String message = (String) session.getAttribute("message");
    String error = (String) request.getAttribute("error");

    if (message != null) session.removeAttribute("message");
    if (allProducts == null) allProducts = java.util.Collections.emptyList();
    if (lowStockProducts == null) lowStockProducts = java.util.Collections.emptyList();
    if (outOfStockProducts == null) outOfStockProducts = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplier Dashboard - NexusShop</title>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <!-- CSS -->
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/supplier-dashboard.css">
    <style>
        .stock-badge.out-of-stock { background: #ffebee; color: #c62828; }
        .stock-badge.low-stock { background: #fff3e0; color: #f57c00; }
        .stock-badge.in-stock { background: #e8f5e8; color: #2e7d32; }
        .status-badge.pending { background: #fff3e0; color: #f57c00; }
        .status-badge.approved { background: #e8f5e8; color: #2e7d32; }
        .status-badge.rejected { background: #ffebee; color: #c62828; }
        .status-badge.held { background: #f3e5f5; color: #7b1fa2; }
        .category-tag { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 0.85em; font-weight: 500; background: #f1f3f5; }
        .product-image-small img { width: 40px; height: 40px; object-fit: cover; border-radius: 4px; }
        .no-image { width: 40px; height: 40px; background: #f1f3f5; display: flex; align-items: center; justify-content: center; border-radius: 4px; }
        .stock-input-small { width: 60px; padding: 4px 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 0.9em; }
        .notification { padding: 12px; margin-bottom: 20px; border-radius: 6px; display: flex; align-items: center; gap: 10px; }
        .notification.success { background: #e8f5e8; color: #2e7d32; }
        .notification.error { background: #ffebee; color: #c62828; }
    </style>
</head>
<body>
<!-- Floating Background Elements -->
<div class="floating-bg">
    <div class="floating-circle circle-1"></div>
    <div class="floating-circle circle-2"></div>
    <div class="floating-circle circle-3"></div>
    <div class="floating-circle circle-4"></div>
</div>

<!-- Header Section -->
<header class="header">
    <div class="header-container">
        <!-- Logo -->
        <div class="logo">
            <a href="../index.jsp">
                <span class="logo-icon"><i class="fas fa-atom"></i></span>
                <span class="logo-text">NexusShop</span>
            </a>
        </div>

        <!-- Navigation -->
        <nav class="main-nav">
            <ul class="nav-list">
                <li class="nav-item"><a href="../index.jsp" class="nav-link">Home</a></li>
                <li class="nav-item"><a href="products" class="nav-link">Shop</a></li>
                <li class="nav-item"><a href="" class="nav-link active">Supplier Dashboard</a></li>
            </ul>
        </nav>

        <!-- User Actions -->
        <div class="user-actions">
            <span class="action-text">Welcome, <%= currentUser.getFullName() %></span>
            <a href="logout" class="action-link" onclick="return confirm('Are you sure you want to logout?')">
                <i class="fas fa-sign-out-alt"></i>
                <span class="action-text">Logout</span>
            </a>
        </div>

        <!-- Mobile Menu Button -->
        <div class="mobile-menu-btn">
            <i class="fas fa-bars"></i>
        </div>
    </div>
</header>

<!-- Supplier Dashboard Content -->
<div class="supplier-dashboard">
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <div class="header-content">
                <h1 class="section-title">
                    <i class="fas fa-warehouse"></i> Supplier Dashboard
                </h1>
                <p class="section-subtitle">Manage inventory and product stock levels</p>
            </div>
            <div class="header-actions">
                <button id="refreshDashboard" class="btn btn-secondary btn-refresh">
                    <i class="fas fa-sync-alt"></i> Refresh
                </button>
            </div>
        </div>

        <!-- Notifications -->
        <% if (message != null) { %>
        <div class="notification success">
            <i class="fas fa-check-circle"></i>
            <span><%= message %></span>
        </div>
        <% } %>
        <% if (error != null) { %>
        <div class="notification error">
            <i class="fas fa-exclamation-circle"></i>
            <span><%= error %></span>
        </div>
        <% } %>

        <!-- Summary Cards -->
        <div class="summary-grid">
            <div class="summary-card total">
                <div class="summary-icon">
                    <i class="fas fa-boxes"></i>
                </div>
                <div class="summary-content">
                    <h3>Total Products</h3>
                    <div class="summary-value"><%= allProducts.size() %></div>
                    <div class="summary-trend">
                        <i class="fas fa-chart-line"></i>
                        <span>All your products</span>
                    </div>
                </div>
            </div>

            <div class="summary-card low-stock">
                <div class="summary-icon">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <div class="summary-content">
                    <h3>Low Stock (≤10)</h3>
                    <div class="summary-value"><%= lowStockProducts.size() %></div>
                    <div class="summary-trend warning">
                        <i class="fas fa-arrow-down"></i>
                        <span>Need restocking</span>
                    </div>
                </div>
            </div>

            <div class="summary-card out-of-stock">
                <div class="summary-icon">
                    <i class="fas fa-times-circle"></i>
                </div>
                <div class="summary-content">
                    <h3>Out of Stock</h3>
                    <div class="summary-value"><%= outOfStockProducts.size() %></div>
                    <div class="summary-trend danger">
                        <i class="fas fa-times"></i>
                        <span>Urgent attention</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Dashboard Actions -->
        <div class="dashboard-actions">
            <a href="add-product.jsp" class="btn btn-primary btn-submit-product">
                <i class="fas fa-plus"></i> Submit New Product
            </a>
            <a href="supplier/products" class="btn btn-secondary">
                <i class="fas fa-cube"></i> View My Products
            </a>
            <div class="action-group">
                <button class="btn btn-outline" id="exportData">
                    <i class="fas fa-download"></i> Export
                </button>
            </div>
        </div>

        <!-- Main Content Tabs -->
        <div class="content-tabs">
            <div class="tab-nav">
                <button class="tab-btn active" data-tab="all-products">All Products</button>
                <button class="tab-btn" data-tab="low-stock">Low Stock</button>
                <button class="tab-btn" data-tab="out-of-stock">Out of Stock</button>
            </div>

            <!-- Search and View Controls -->
            <div class="table-controls">
                <div class="search-container">
                    <input type="text" id="productSearch" placeholder="Search products by name or SKU..." class="search-input">
                    <i class="fas fa-search search-icon"></i>
                </div>
            </div>

            <!-- Tab Contents -->
            <div class="tab-content active" id="all-products">
                <!-- Table View -->
                <div class="table-view active">
                    <div class="table-container">
                        <table class="admin-table">
                            <thead>
                            <tr>
                                <th>Product</th>
                                <th>SKU</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% for (com.nexusshope.model.Product product : allProducts) { %>
                            <tr class="product-row">
                                <td>
                                    <div class="product-info">
                                        <div class="product-image-small">
                                            <% if (product.getPrimaryImage() != null && !product.getPrimaryImage().isEmpty()) { %>
                                            <img src="<%= product.getPrimaryImage() %>" alt="<%= product.getName() %>">
                                            <% } else { %>
                                            <div class="no-image">
                                                <i class="fas fa-image"></i>
                                            </div>
                                            <% } %>
                                        </div>
                                        <div class="product-details">
                                            <div class="product-name"><%= product.getName() %></div>
                                        </div>
                                    </div>
                                </td>
                                <td class="product-sku"><%= product.getSku() %></td>
                                <td>
                                    <span class="category-tag"><%= product.getCategory() %></span>
                                </td>
                                <td>$<%= String.format("%.2f", product.getPrice()) %></td>
                                <td>
                                    <% if (product.getStock() == 0) { %>
                                    <span class="stock-badge out-of-stock">Out of Stock</span>
                                    <% } else if (product.getStock() <= 10) { %>
                                    <span class="stock-badge low-stock"><%= product.getStock() %> left</span>
                                    <% } else { %>
                                    <span class="stock-badge in-stock"><%= product.getStock() %></span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="status-badge <%= product.getStatus().toLowerCase() %>"><%= product.getStatus() %></span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="supplier/products?action=edit&productID=<%= product.getProductID() %>" class="btn btn-sm btn-info">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <% if ("approved".equals(product.getStatus())) { %>
                                        <form class="stock-update-form" action="" method="post" style="display:inline;">
                                            <input type="hidden" name="productId" value="<%= product.getProductID() %>">
                                            <input type="number" name="stock" value="<%= product.getStock() %>" min="0" class="stock-input-small">
                                            <button type="submit" class="btn btn-sm btn-success">
                                                <i class="fas fa-sync"></i>
                                            </button>
                                        </form>
                                        <% } else { %>
                                        <button class="btn btn-sm btn-warning" disabled>
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Low Stock Tab -->
            <div class="tab-content" id="low-stock">
                <div class="alert-products">
                    <% if (!lowStockProducts.isEmpty()) { %>
                    <% for (com.nexusshope.model.Product product : lowStockProducts) { %>
                    <div class="alert-product-card">
                        <div class="alert-product-info">
                            <div class="product-image-small">
                                <% if (product.getPrimaryImage() != null && !product.getPrimaryImage().isEmpty()) { %>
                                <img src="<%= product.getPrimaryImage() %>" alt="<%= product.getName() %>">
                                <% } else { %>
                                <div class="no-image">
                                    <i class="fas fa-image"></i>
                                </div>
                                <% } %>
                            </div>
                            <div class="product-details">
                                <div class="product-name"><%= product.getName() %></div>
                                <div class="product-sku">SKU: <%= product.getSku() %></div>
                                <div class="stock-warning">
                                    <span class="warning-text">Only <%= product.getStock() %> units left!</span>
                                </div>
                            </div>
                        </div>
                        <div class="alert-product-actions">
                            <form class="stock-update-form" action="" method="post" style="display:inline;">
                                <input type="hidden" name="productId" value="<%= product.getProductID() %>">
                                <div class="stock-update-controls">
                                    <input type="number" name="stock" value="<%= product.getStock() %>" min="0" class="stock-input-small">
                                    <button type="submit" class="btn btn-sm btn-success">
                                        <i class="fas fa-sync"></i> Update
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <% } %>
                    <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-check-circle"></i>
                        <h3>No Low Stock Products</h3>
                        <p>All your products have sufficient stock levels.</p>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Out of Stock Tab -->
            <div class="tab-content" id="out-of-stock">
                <div class="alert-products">
                    <% if (!outOfStockProducts.isEmpty()) { %>
                    <% for (com.nexusshope.model.Product product : outOfStockProducts) { %>
                    <div class="alert-product-card">
                        <div class="alert-product-info">
                            <div class="product-image-small">
                                <% if (product.getPrimaryImage() != null && !product.getPrimaryImage().isEmpty()) { %>
                                <img src="<%= product.getPrimaryImage() %>" alt="<%= product.getName() %>">
                                <% } else { %>
                                <div class="no-image">
                                    <i class="fas fa-image"></i>
                                </div>
                                <% } %>
                            </div>
                            <div class="product-details">
                                <div class="product-name"><%= product.getName() %></div>
                                <div class="product-sku">SKU: <%= product.getSku() %></div>
                                <div class="stock-warning">
                                    <span class="warning-text">Out of Stock!</span>
                                </div>
                            </div>
                        </div>
                        <div class="alert-product-actions">
                            <form class="stock-update-form" action="" method="post" style="display:inline;">
                                <input type="hidden" name="productId" value="<%= product.getProductID() %>">
                                <div class="stock-update-controls">
                                    <input type="number" name="stock" value="0" min="0" class="stock-input-small">
                                    <button type="submit" class="btn btn-sm btn-success">
                                        <i class="fas fa-sync"></i> Restock
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <% } %>
                    <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-check-circle"></i>
                        <h3>No Out of Stock Products</h3>
                        <p>All your products are in stock.</p>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Footer Section -->
<footer class="site-footer">
    <div class="footer-container">
        <div class="footer-grid">
            <div class="footer-col">
                <div class="logo">
                    <a href="../index.jsp">
                        <span class="logo-icon"><i class="fas fa-atom"></i></span>
                        <span class="logo-text">NexusShop</span>
                    </a>
                </div>
                <p class="footer-about">Your premier destination for cutting-edge technology and electronics.</p>
                <div class="social-links">
                    <a href="#"><i class="fab fa-facebook-f"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                    <a href="#"><i class="fab fa-instagram"></i></a>
                    <a href="#"><i class="fab fa-youtube"></i></a>
                </div>
            </div>

            <div class="footer-col">
                <h3>Shop</h3>
                <ul>
                    <li><a href="products">All Products</a></li>
                    <li><a href="products?filter=new">New Arrivals</a></li>
                    <li><a href="products?filter=featured">Featured</a></li>
                    <li><a href="products?filter=deals">Deals</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Help</h3>
                <ul>
                    <li><a href="contact">Contact Us</a></li>
                    <li><a href="faq">FAQs</a></li>
                    <li><a href="shipping.jsp">Shipping</a></li>
                    <li><a href="returns.jsp">Returns</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Company</h3>
                <ul>
                    <li><a href="about.jsp">About Us</a></li>
                    <li><a href="careers.jsp">Careers</a></li>
                    <li><a href="privacy.jsp">Privacy Policy</a></li>
                    <li><a href="terms.jsp">Terms of Service</a></li>
                </ul>
            </div>
        </div>

        <div class="footer-bottom">
            <p>&copy; 2025 NexusShop. All rights reserved.</p>
            <div class="payment-methods">
                <i class="fab fa-cc-visa"></i>
                <i class="fab fa-cc-mastercard"></i>
                <i class="fab fa-cc-paypal"></i>
                <i class="fab fa-cc-apple-pay"></i>
            </div>
        </div>
    </div>
</footer>

<script src="../js/main.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Tab functionality
        const tabBtns = document.querySelectorAll('.tab-btn');
        const tabContents = document.querySelectorAll('.tab-content');

        tabBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const tabId = this.dataset.tab;

                // Remove active class from all tabs and contents
                tabBtns.forEach(b => b.classList.remove('active'));
                tabContents.forEach(c => c.classList.remove('active'));

                // Add active class to current tab and content
                this.classList.add('active');
                document.getElementById(tabId).classList.add('active');
            });
        });

        // Search functionality
        const searchInput = document.getElementById('productSearch');
        const productRows = document.querySelectorAll('.product-row');

        searchInput.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();

            productRows.forEach(row => {
                const productName = row.querySelector('.product-name').textContent.toLowerCase();
                const productSku = row.querySelector('.product-sku').textContent.toLowerCase();

                if (productName.includes(searchTerm) || productSku.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });

        // Refresh button
        const refreshBtn = document.getElementById('refreshDashboard');
        refreshBtn.addEventListener('click', function() {
            this.classList.add('refreshing');
            this.innerHTML = '<i class="fas fa-spinner"></i> Refreshing...';

            setTimeout(() => {
                location.reload();
            }, 1000);
        });
    });
</script>
</body>
</html>
