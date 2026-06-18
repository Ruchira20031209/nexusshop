<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.nexusshope.model.Product" %>
<%@ page import="com.nexusshope.model.ProductImage" %>
<%@ page import="com.nexusshope.model.ProductSpecification" %>
<%@ page import="com.nexusshope.model.FAQ" %>
<%@ page import="com.nexusshope.service.FAQService" %>
<%@ page import="java.util.List" %>
<%
    // Get product and related data from request attributes
    Product product = (Product) request.getAttribute("product");
    List<ProductImage> productImages = (List<ProductImage>) request.getAttribute("productImages");
    List<ProductSpecification> productSpecs = (List<ProductSpecification>) request.getAttribute("productSpecs");
    String error = (String) request.getAttribute("error");

    // Get primary image
    String primaryImageUrl = "${pageContext.request.contextPath}/images/default-product.jpg";
    if (productImages != null && !productImages.isEmpty()) {
        for (ProductImage image : productImages) {
            if (image.isPrimary()) {
                primaryImageUrl = image.getImageUrl();
                break;
            }
        }
        // If no primary image found, use the first one
        if (primaryImageUrl.equals("${pageContext.request.contextPath}/images/default-product.jpg")) {
            primaryImageUrl = productImages.get(0).getImageUrl();
        }
    }

    // Ensure image URL has context path
    if (!primaryImageUrl.startsWith("http") && !primaryImageUrl.startsWith("/")) {
        primaryImageUrl = "/" + primaryImageUrl;
    }
    if (!primaryImageUrl.startsWith("http")) {
        primaryImageUrl = request.getContextPath() + primaryImageUrl;
    }

    // Get product-specific FAQs
    FAQService faqService = new FAQService();
    List<FAQ> productFAQs = new java.util.ArrayList<>();
    if (product != null) {
        try {
            productFAQs = faqService.getFAQsByProductType(product.getName());
            if (productFAQs.isEmpty()) {
                productFAQs = faqService.getFAQsByProductCategory(product.getCategory());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    com.nexusshope.model.User currentUser = (com.nexusshope.model.User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product != null ? product.getName() : "Product" %> - NexusShop</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product_detail.css">
    <style>
        .glass-effect {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .product-detail-container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .product-detail-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
        }
        .product-gallery {
            position: relative;
        }
        .main-image {
            position: relative;
            width: 100%;
            height: 400px;
            overflow: hidden;
            border-radius: 10px;
            background: #f8f9fa;
        }
        .main-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .image-thumbnails {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            flex-wrap: wrap;
        }
        .thumbnail {
            width: 60px;
            height: 60px;
            border: 2px solid transparent;
            border-radius: 5px;
            cursor: pointer;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .thumbnail.active {
            border-color: #6c5ce7;
        }
        .thumbnail:hover {
            border-color: #6c5ce7;
            transform: scale(1.05);
        }
        .thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .thumbnail-placeholder {
            width: 100%;
            height: 100%;
            background: #e9ecef;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #6c757d;
        }
        .product-badge {
            position: absolute;
            top: 15px;
            left: 15px;
            padding: 8px 15px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9em;
            z-index: 10;
        }
        .product-badge.discount { background: #fff3e0; color: #f57c00; }
        .product-badge.low-stock { background: #ffebee; color: #c62828; }
        .product-badge.new { background: #e3f2fd; color: #1976d2; }
        .product-info {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        .product-title {
            font-size: 2em;
            margin: 0;
            color: #333;
        }
        .product-meta {
            display: flex;
            gap: 20px;
            color: #666;
            font-size: 0.9em;
        }
        .stars {
            color: #ffc107;
        }
        .rating-text {
            color: #666;
            font-size: 0.9em;
            margin-left: 10px;
        }
        .price {
            display: flex;
            align-items: center;
            gap: 15px;
            margin: 15px 0;
        }
        .current-price {
            font-size: 2.5em;
            font-weight: 700;
            color: #333;
        }
        .original-price {
            text-decoration: line-through;
            color: #999;
            font-size: 1.2em;
        }
        .tax-info {
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
        }
        .stock {
            padding: 8px 15px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9em;
        }
        .stock.in-stock { background: #e8f5e8; color: #2e7d32; }
        .stock.low-stock { background: #fff3e0; color: #f57c00; }
        .stock.out-of-stock { background: #ffebee; color: #c62828; }
        .quantity-controls {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .quantity-btn {
            width: 40px;
            height: 40px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }
        .quantity-btn:disabled {
            background: #f5f5f5;
            cursor: not-allowed;
        }
        .quantity-btn:hover:not(:disabled) {
            background: #f8f9fa;
            transform: scale(1.1);
        }
        .quantity-input {
            width: 60px;
            height: 40px;
            text-align: center;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-weight: 600;
        }
        .action-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }
        .btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }
        .btn.add-to-cart-btn {
            background: #6c5ce7;
            color: white;
            flex: 1;
        }
        .btn.add-to-cart-btn:hover:not(:disabled) {
            background: #5b4bc4;
            transform: translateY(-2px);
        }
        .btn.buy-now-btn {
            background: #e74c3c;
            color: white;
            flex: 1;
        }
        .btn.buy-now-btn:hover:not(:disabled) {
            background: #c0392b;
            transform: translateY(-2px);
        }
        .btn.wishlist-btn {
            background: #f39c12;
            color: white;
            flex: 0 0 auto;
        }
        .btn.wishlist-btn:hover {
            background: #e67e22;
            transform: translateY(-2px);
        }
        .feature-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 0;
            color: #666;
        }
        .tabs-header {
            display: flex;
            border-bottom: 2px solid #eee;
        }
        .tab-link {
            padding: 15px 25px;
            border: none;
            background: none;
            cursor: pointer;
            font-weight: 600;
            color: #666;
            border-bottom: 2px solid transparent;
            transition: all 0.3s ease;
        }
        .tab-link.active {
            color: #6c5ce7;
            border-bottom: 2px solid #6c5ce7;
        }
        .tab-link:hover {
            color: #6c5ce7;
        }
        .tab-panel {
            display: none;
            padding: 25px 0;
        }
        .tab-panel.active {
            display: block;
        }
        .specs-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }
        .spec-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }
        .spec-label {
            font-weight: 600;
            color: #333;
        }
        .spec-value {
            color: #666;
        }
        .reviews-summary {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 25px;
        }
        .overall-rating {
            text-align: center;
        }
        .rating-score {
            font-size: 2.5em;
            font-weight: 700;
            color: #6c5ce7;
        }
        .rating-count {
            color: #666;
            font-size: 0.9em;
        }
        .review-item {
            border-bottom: 1px solid #eee;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        .reviewer {
            font-weight: 600;
            color: #333;
        }
        .review-title {
            font-weight: 600;
            margin: 10px 0;
        }
        .review-content {
            color: #666;
            margin-bottom: 10px;
        }
        .review-date {
            color: #999;
            font-size: 0.9em;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
        }
        .empty-icon {
            font-size: 4em;
            color: #ccc;
            margin-bottom: 20px;
        }
        .breadcrumb {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
            color: #666;
            font-size: 0.9em;
        }
        .breadcrumb a {
            color: #6c5ce7;
            text-decoration: none;
        }
        .breadcrumb i {
            font-size: 0.6em;
        }
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 6px;
            color: white;
            font-weight: 600;
            z-index: 1000;
            animation: slideIn 0.3s, fadeOut 0.5s 2.5s;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .notification.success { background: #2e7d32; }
        .notification.error { background: #c62828; }
        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        @keyframes fadeOut {
            from { opacity: 1; }
            to { opacity: 0; }
        }
        .faq-section {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            margin-top: 30px;
        }
        .faq-section h3 {
            margin-top: 0;
            color: #333;
            border-bottom: 2px solid #f0f0f0;
            padding-bottom: 15px;
        }
        .faq-item {
            border-bottom: 1px solid #eee;
            padding: 15px 0;
        }
        .faq-question {
            font-weight: 600;
            color: #333;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: color 0.3s ease;
        }
        .faq-question:hover {
            color: #6c5ce7;
        }
        .faq-answer {
            margin-top: 10px;
            color: #666;
            display: none;
            line-height: 1.6;
        }
        .related-products {
            margin-top: 50px;
        }
        .section-title {
            font-size: 1.8em;
            margin-bottom: 20px;
            color: #333;
        }
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }
        .product-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transition: transform 0.3s ease;
        }
        .product-card:hover {
            transform: translateY(-5px);
        }
        .placeholder-image {
            width: 100%;
            height: 150px;
            background: #f0f0f0;
            border-radius: 5px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #999;
        }
        .action-form {
            margin: 0;
            flex: 1;
        }

        /* Debug styles - remove after testing */
        .debug-info {
            background: #f8f9fa;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
            border-left: 4px solid #6c5ce7;
            font-size: 0.9em;
        }
        .debug-info h4 {
            margin-top: 0;
            color: #6c5ce7;
        }
    </style>
</head>
<body>
<div class="floating-bg">
    <div class="floating-circle circle-1"></div>
    <div class="floating-circle circle-2"></div>
    <div class="floating-circle circle-3"></div>
    <div class="floating-circle circle-4"></div>
</div>

<!-- Header -->
<header class="header">
    <div class="header-container">
        <div class="logo">
            <a href="index.jsp">
                <span class="logo-icon"><i class="fas fa-atom"></i></span>
                <span class="logo-text">NexusShop</span>
            </a>
        </div>

        <div class="search-bar">
            <form class="search-form" action="${pageContext.request.contextPath}/products" method="get">
                <input type="text" name="search" placeholder="Search for products..." class="search-input" value="${param.search}">
                <button type="submit" class="search-button">
                    <i class="fas fa-search"></i>
                </button>
            </form>
        </div>

        <nav class="main-nav">
            <ul class="nav-list">
                <li class="nav-item"><a href="index.jsp" class="nav-link">Home</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/products" class="nav-link">Shop</a></li>
                <li class="nav-item"><a href="about.jsp" class="nav-link">About</a></li>
            </ul>
        </nav>

        <div class="user-actions">
            <%
                if (currentUser != null) {
            %>
            <div class="action-item">
                <span class="action-text">Welcome, <%= currentUser.getFullName() %></span>
            </div>
            <div class="action-item">
                <a href="${pageContext.request.contextPath}/user" class="action-link">
                    <i class="fas fa-user"></i>
                    <span class="action-text">Account</span>
                </a>
            </div>
            <div class="action-item">
                <a href="${pageContext.request.contextPath}/logout" class="action-link" onclick="return confirm('Are you sure you want to logout?')">
                    <i class="fas fa-sign-out-alt"></i>
                    <span class="action-text">Logout</span>
                </a>
            </div>
            <%
            } else {
            %>
            <div class="action-item">
                <a href="${pageContext.request.contextPath}/login.jsp" class="action-link">
                    <i class="far fa-user"></i>
                    <span class="action-text">Login</span>
                </a>
            </div>
            <div class="action-item">
                <a href="${pageContext.request.contextPath}/register.jsp" class="action-link">
                    <i class="fas fa-user-plus"></i>
                    <span class="action-text">Register</span>
                </a>
            </div>
            <%
                }
            %>

            <div class="action-item">
                <a href="wishlist.jsp" class="action-link">
                    <i class="far fa-heart"></i>
                    <span class="action-text">Wishlist</span>
                </a>
            </div>

            <div class="action-item">
                <a href="${pageContext.request.contextPath}/cart/view" class="action-link">
                    <i class="fas fa-shopping-cart"></i>
                    <span class="action-text">Cart</span>
                    <%
                        Integer cartCount = (Integer) session.getAttribute("cartCount");
                        if (cartCount != null && cartCount > 0) {
                    %>
                    <span class="cart-count"><%= cartCount %></span>
                    <%
                        }
                    %>
                </a>
            </div>
        </div>

        <div class="mobile-menu-btn">
            <i class="fas fa-bars"></i>
        </div>
    </div>
</header>

<!-- Main Content -->
<main class="product-detail-page">
    <div class="container">
        <% if (error != null) { %>
        <div class="empty-state glass-effect">
            <div class="empty-icon">
                <i class="fas fa-exclamation-circle"></i>
            </div>
            <h2>Error Loading Product</h2>
            <p><%= error %></p>
            <a href="${pageContext.request.contextPath}/products" class="btn add-to-cart-btn">
                <i class="fas fa-arrow-left"></i> Back to Shop
            </a>
        </div>
        <% } else if (product == null) { %>
        <div class="empty-state glass-effect">
            <div class="empty-icon">
                <i class="fas fa-exclamation-circle"></i>
            </div>
            <h2>Product Not Found</h2>
            <p>Sorry, the product you're looking for doesn't exist or has been removed.</p>
            <a href="${pageContext.request.contextPath}/products" class="btn add-to-cart-btn">
                <i class="fas fa-arrow-left"></i> Back to Shop
            </a>
        </div>
        <% } else { %>



        <div class="product-detail-container">
            <!-- Breadcrumb -->
            <div class="breadcrumb">
                <a href="index.jsp">Home</a>
                <i class="fas fa-chevron-right"></i>
                <a href="${pageContext.request.contextPath}/products">Shop</a>
                <i class="fas fa-chevron-right"></i>
                <a href="${pageContext.request.contextPath}/products?category=<%= product.getCategory() %>"><%= product.getCategory() %></a>
                <i class="fas fa-chevron-right"></i>
                <span><%= product.getName() %></span>
            </div>

            <div class="product-detail-content glass-effect">
                <div class="product-gallery">
                    <div class="main-image">
                        <img src="<%= primaryImageUrl %>"
                             alt="<%= product.getName() %>"
                             id="main-product-image"
                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/default-product.jpg';">

                        <% if (product.getPrice() < 100) { %>
                        <span class="product-badge discount">Hot Deal</span>
                        <% } %>
                        <% if (product.getStock() > 0 && product.getStock() <= 10) { %>
                        <span class="product-badge low-stock">Low Stock</span>
                        <% } %>
                        <% if (product.getCreatedDate() != null &&
                                System.currentTimeMillis() - product.getCreatedDate().getTime() < 7 * 24 * 60 * 60 * 1000) { %>
                        <span class="product-badge new">New</span>
                        <% } %>
                    </div>

                    <!-- Image Thumbnails -->
                    <% if (productImages != null && productImages.size() > 1) { %>
                    <div class="image-thumbnails">
                        <% for (ProductImage image : productImages) {
                            String thumbUrl = image.getImageUrl();
                            if (!thumbUrl.startsWith("http") && !thumbUrl.startsWith("/")) {
                                thumbUrl = "/" + thumbUrl;
                            }
                            if (!thumbUrl.startsWith("http")) {
                                thumbUrl = request.getContextPath() + thumbUrl;
                            }
                            boolean isActive = thumbUrl.equals(primaryImageUrl);
                        %>
                        <div class="thumbnail <%= isActive ? "active" : "" %>"
                             onclick="changeMainImage('<%= thumbUrl %>', this)"
                             data-image-url="<%= thumbUrl %>">
                            <img src="<%= thumbUrl %>"
                                 alt="Thumbnail"
                                 onerror="handleImageError(this)">
                        </div>
                    <% } %>
                </div>
                <% } %>
            </div>

            <div class="product-info">
                <div class="product-header">
                    <h1 class="product-title"><%= product.getName() %></h1>
                    <div class="product-meta">
                        <span class="sku">SKU: <%= product.getSku() %></span>
                        <span class="category">Category: <%= product.getCategory() %></span>
                    </div>
                </div>

                <div class="product-rating">
                    <div class="stars">
                        <% for (int i = 1; i <= 5; i++) { %>
                        <% if (i <= (int)product.getRating()) { %>
                        <i class="fas fa-star"></i>
                        <% } else { %>
                        <i class="far fa-star"></i>
                        <% } %>
                        <% } %>
                    </div>
                    <span class="rating-text"><%= String.format("%.1f", product.getRating()) %>/5 (Based on 42 reviews)</span>
                </div>

                <div class="product-price-section">
                    <div class="price">
                        <span class="current-price">$<%= String.format("%.2f", product.getPrice()) %></span>
                        <% if (product.getPrice() > 200) { %>
                        <span class="original-price">$<%= String.format("%.2f", product.getPrice() + 50) %></span>
                        <% } %>
                    </div>
                    <div class="tax-info">Tax included. Shipping calculated at checkout.</div>
                </div>

                <div class="product-stock-info">
                    <% if (product.getStock() > 10) { %>
                    <span class="stock in-stock"><i class="fas fa-check-circle"></i> In Stock (<%= product.getStock() %> available)</span>
                    <% } else if (product.getStock() > 0) { %>
                    <span class="stock low-stock"><i class="fas fa-exclamation-triangle"></i> Only <%= product.getStock() %> left in stock</span>
                    <% } else { %>
                    <span class="stock out-of-stock"><i class="fas fa-times-circle"></i> Out of Stock</span>
                    <% } %>
                </div>

                <div class="product-description">
                    <p><%= product.getDescription() != null ? product.getDescription() : "No description available." %></p>
                </div>



                    <div class="action-buttons">
                        <form action="${pageContext.request.contextPath}/cart/add" method="post" class="action-form" id="add-to-cart-form">
                            <input type="hidden" name="productId" value="<%= product.getProductID() %>">
                            <input type="hidden" id="form-quantity" name="quantity" value="1">
                            <button type="submit" class="btn add-to-cart-btn" <%= product.getStock() == 0 ? "disabled" : "" %>>
                                <i class="fas fa-shopping-cart"></i> Add to Cart
                            </button>
                        </form>
                        <form action="${pageContext.request.contextPath}/cart/buy-now" method="post" class="action-form" id="buy-now-form">
                            <input type="hidden" name="productId" value="<%= product.getProductID() %>">
                            <input type="hidden" name="quantity" value="1" id="buy-now-quantity">
                            <button type="submit" class="btn buy-now-btn" <%= product.getStock() == 0 ? "disabled" : "" %>>
                                <i class="fas fa-bolt"></i> Buy Now
                            </button>
                        </form>
                        <button class="btn wishlist-btn" onclick="addToWishlist('<%= product.getProductID() %>')">
                            <i class="far fa-heart"></i> Add to Wishlist
                        </button>
                    </div>
                </div>

                <div class="product-features">
                    <div class="feature-item">
                        <i class="fas fa-shipping-fast"></i>
                        <span>Free shipping on orders over $100</span>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-undo"></i>
                        <span>30-day return policy</span>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-shield-alt"></i>
                        <span>2-year warranty included</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Product Tabs -->
        <div class="product-tabs glass-effect">
            <div class="tabs-header">
                <button class="tab-link active" data-tab="description">Description</button>
                <button class="tab-link" data-tab="specifications">Specifications</button>
                <button class="tab-link" data-tab="reviews">Reviews (42)</button>
            </div>

            <div class="tabs-content">
                <div id="description" class="tab-panel active">
                    <h3>Product Description</h3>
                    <p><%= product.getDescription() != null ? product.getDescription() : "No detailed description available." %></p>
                    <p>Experience the ultimate in performance and design with our premium <%= product.getName() %>. Crafted with attention to detail and built to last, this product combines cutting-edge technology with user-friendly features.</p>
                    <ul>
                        <li>High-quality materials and construction</li>
                        <li>Advanced features for enhanced usability</li>
                        <li>Energy-efficient operation</li>
                        <li>Compatible with most standard systems</li>
                    </ul>
                </div>

                <div id="specifications" class="tab-panel">
                    <h3>Technical Specifications</h3>
                    <div class="specs-grid">
                        <div class="spec-item">
                            <span class="spec-label">Model</span>
                            <span class="spec-value"><%= product.getSku() %></span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Category</span>
                            <span class="spec-value"><%= product.getCategory() %></span>
                        </div>
                        <% if (productSpecs != null && !productSpecs.isEmpty()) { %>
                        <% for (ProductSpecification spec : productSpecs) { %>
                        <div class="spec-item">
                            <span class="spec-label"><%= spec.getSpecKey() %></span>
                            <span class="spec-value"><%= spec.getSpecValue() %></span>
                        </div>
                        <% } %>
                        <% } else { %>
                        <!-- Default specs if none available -->
                        <div class="spec-item">
                            <span class="spec-label">Weight</span>
                            <span class="spec-value">1.2 kg</span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Dimensions</span>
                            <span class="spec-value">15 x 10 x 5 cm</span>
                        </div>
                        <div class="spec-item">
                            <span class="spec-label">Warranty</span>
                            <span class="spec-value">24 months</span>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div id="reviews" class="tab-panel">
                    <h3>Customer Reviews</h3>
                    <div class="reviews-summary">
                        <div class="overall-rating">
                            <div class="rating-score"><%= String.format("%.1f", product.getRating()) %></div>
                            <div class="stars">
                                <% for (int i = 1; i <= 5; i++) { %>
                                <% if (i <= (int)product.getRating()) { %>
                                <i class="fas fa-star"></i>
                                <% } else { %>
                                <i class="far fa-star"></i>
                                <% } %>
                                <% } %>
                            </div>
                            <div class="rating-count">Based on 42 reviews</div>
                        </div>
                    </div>
                    <div class="review-item">
                        <div class="review-header">
                            <div class="reviewer">John D.</div>
                            <div class="review-rating">
                                <i class="fas fa-star"></i>
                                <i class="fas fa-star"></i>
                                <i class="fas fa-star"></i>
                                <i class="fas fa-star"></i>
                                <i class="fas fa-star"></i>
                            </div>
                        </div>
                        <div class="review-title">Excellent product!</div>
                        <div class="review-content">This product exceeded my expectations. The quality is outstanding and it works perfectly.</div>
                        <div class="review-date">Posted on March 15, 2025</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Product-Specific FAQs -->
        <% if (!productFAQs.isEmpty()) { %>
        <div class="faq-section">
            <h3>Frequently Asked Questions</h3>
            <% for (FAQ faq : productFAQs) { %>
            <div class="faq-item">
                <div class="faq-question" onclick="toggleFAQ(this)">
                    <span><%= faq.getQuestion() %></span>
                    <i class="fas fa-chevron-down"></i>
                </div>
                <div class="faq-answer">
                    <p><%= faq.getAnswer() %></p>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>

        <!-- Related Products -->
        <div class="related-products">
            <h2 class="section-title">You Might Also Like</h2>
            <div class="products-grid">
                <!-- This would be populated with related products from the backend -->
                <div class="product-card placeholder">
                    <div class="product-image">
                        <div class="placeholder-image">
                            <i class="fas fa-image"></i>
                        </div>
                    </div>
                    <div class="product-content">
                        <h3 class="product-title">Related Product 1</h3>
                        <div class="product-price">$299.99</div>
                    </div>
                </div>
                <div class="product-card placeholder">
                    <div class="product-image">
                        <div class="placeholder-image">
                            <i class="fas fa-image"></i>
                        </div>
                    </div>
                    <div class="product-content">
                        <h3 class="product-title">Related Product 2</h3>
                        <div class="product-price">$199.99</div>
                    </div>
                </div>
                <div class="product-card placeholder">
                    <div class="product-image">
                        <div class="placeholder-image">
                            <i class="fas fa-image"></i>
                        </div>
                    </div>
                    <div class="product-content">
                        <h3 class="product-title">Related Product 3</h3>
                        <div class="product-price">$399.99</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <% } %>
    </div>
</main>

<!-- Newsletter Section -->
<section class="newsletter">
    <div class="container">
        <div class="newsletter-content">
            <h2>Stay Updated with Latest Tech</h2>
            <p>Subscribe to get exclusive deals and product updates</p>
            <form class="newsletter-form">
                <input type="email" placeholder="Enter your email" required>
                <button type="submit" class="btn add-to-cart-btn">
                    <i class="fas fa-paper-plane"></i> Subscribe
                </button>
            </form>
        </div>
    </div>
</section>

<!-- Footer -->
<footer class="site-footer">
    <div class="footer-container">
        <div class="footer-grid">
            <div class="footer-col">
                <div class="logo">
                    <a href="index.jsp">
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
                    <li><a href="${pageContext.request.contextPath}/products">All Products</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?category=Electronics">Electronics</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?category=Clothing">Clothing</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?category=Books">Books</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Help</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/contact">Contact Us</a></li>
                    <li><a href="faq.jsp">FAQs</a></li>
                    <li><a href="shipping.jsp">Shipping</a></li>
                    <li><a href="returns.jsp">Returns</a></li>
                    <li><a href="order-tracking.jsp">Track Order</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Company</h3>
                <ul>
                    <li><a href="about.jsp">About Us</a></li>
                    <li><a href="careers.jsp">Careers</a></li>
                    <li><a href="privacy.jsp">Privacy Policy</a></li>
                    <li><a href="terms.jsp">Terms of Service</a></li>
                    <li><a href="blog.jsp">Blog</a></li>
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

<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
    // Product interaction functions
    function addToCart(productId) {
        const quantity = document.getElementById('quantity').value;

        fetch('${pageContext.request.contextPath}/cart/add', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'productId=' + productId + '&quantity=' + quantity
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update cart count
                    const cartCount = document.querySelector('.cart-count');
                    if (cartCount) {
                        cartCount.textContent = data.totalItems || 0;
                        cartCount.classList.add('pulse');
                        setTimeout(() => cartCount.classList.remove('pulse'), 500);
                    }
                    showNotification('Product added to cart!', 'success');
                } else {
                    showNotification('Error adding product to cart', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showNotification('Error adding product to cart', 'error');
            });
    }

    function changeMainImage(imageUrl, element) {
        // Update main image
        document.getElementById('main-product-image').src = imageUrl;

        // Update active thumbnail
        document.querySelectorAll('.thumbnail').forEach(thumb => {
            thumb.classList.remove('active');
        });
        element.classList.add('active');
    }

    function addToWishlist(productId) {
        fetch('${pageContext.request.contextPath}/wishlist/add', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'productId=' + productId
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showNotification('Added to wishlist!', 'success');
                    document.querySelector('.wishlist-btn i').className = 'fas fa-heart';
                    document.querySelector('.wishlist-btn').innerHTML = '<i class="fas fa-heart"></i> In Wishlist';
                    document.querySelector('.wishlist-btn').onclick = null;
                    document.querySelector('.wishlist-btn').style.background = '#e74c3c';
                    document.querySelector('.wishlist-btn').style.cursor = 'default';
                    document.querySelector('.wishlist-btn').style.transform = 'none';
                    document.querySelector('.wishlist-btn').style.pointerEvents = 'none';
                } else {
                    showNotification('Error adding to wishlist', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showNotification('Error adding to wishlist', 'error');
            });
    }

    function increaseQuantity() {
        const quantityInput = document.getElementById('quantity');
        const max = parseInt(quantityInput.getAttribute('max'));
        let currentValue = parseInt(quantityInput.value);

        if (currentValue < max) {
            quantityInput.value = currentValue + 1;
            updateQuantities();
        }
    }

    function decreaseQuantity() {
        const quantityInput = document.getElementById('quantity');
        let currentValue = parseInt(quantityInput.value);

        if (currentValue > 1) {
            quantityInput.value = currentValue - 1;
            updateQuantities();
        }
    }

    function updateQuantities() {
        const quantity = document.getElementById('quantity').value;
        document.getElementById('form-quantity').value = quantity;
        document.getElementById('buy-now-quantity').value = quantity;
    }

    function showNotification(message, type) {
        const notification = document.createElement('div');
        notification.className = 'notification ' + type;

        let iconClass = 'fas fa-info';
        if (type === 'success') iconClass = 'fas fa-check';
        else if (type === 'error') iconClass = 'fas fa-exclamation-triangle';

        notification.innerHTML = `
            <i class="${iconClass}"></i>
            <span>${message}</span>
        `;

        document.body.appendChild(notification);

        setTimeout(() => {
            notification.remove();
        }, 3000);
    }

    function toggleFAQ(element) {
        const answer = element.nextElementSibling;
        const icon = element.querySelector('i');

        if (answer.style.display === 'block') {
            answer.style.display = 'none';
            icon.className = 'fas fa-chevron-down';
        } else {
            answer.style.display = 'block';
            icon.className = 'fas fa-chevron-up';
        }
    }

    // Tab functionality
    document.addEventListener('DOMContentLoaded', function() {
        const tabLinks = document.querySelectorAll('.tab-link');
        const tabPanels = document.querySelectorAll('.tab-panel');

        tabLinks.forEach(link => {
            link.addEventListener('click', function() {
                const tabId = this.getAttribute('data-tab');

                // Remove active class from all tabs and panels
                tabLinks.forEach(tab => tab.classList.remove('active'));
                tabPanels.forEach(panel => panel.classList.remove('active'));

                // Add active class to current tab and panel
                this.classList.add('active');
                document.getElementById(tabId).classList.add('active');
            });
        });

        // Initialize quantities
        updateQuantities();

        // Update quantities when input changes
        const quantityInput = document.getElementById('quantity');
        if (quantityInput) {
            quantityInput.addEventListener('change', updateQuantities);
        }

        // Mobile menu functionality
        const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
        const mainNav = document.querySelector('.main-nav');
        if (mobileMenuBtn && mainNav) {
            mobileMenuBtn.addEventListener('click', () => {
                mainNav.classList.toggle('active');
                mobileMenuBtn.querySelector('i').classList.toggle('fa-bars');
                mobileMenuBtn.querySelector('i').classList.toggle('fa-times');
            });
        }

        // Handle form submissions
        const addToCartForm = document.getElementById('add-to-cart-form');
        if (addToCartForm) {
            addToCartForm.addEventListener('submit', function(e) {
                e.preventDefault();
                const productId = this.querySelector('input[name="productId"]').value;
                addToCart(productId);
            });
        }

        // Prevent form submission for disabled buttons
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                const submitBtn = this.querySelector('button[type="submit"]');
                if (submitBtn && submitBtn.disabled) {
                    e.preventDefault();
                    showNotification('This product is currently out of stock', 'error');
                }
            });
        });
    });
</script>
</body>
</html>