<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.nexusshope.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
  // Get products from request attribute
  List<Product> products = (List<Product>) request.getAttribute("products");
  String error = (String) request.getAttribute("error");
  String searchQuery = (String) request.getAttribute("searchQuery");
  String selectedCategory = (String) request.getAttribute("selectedCategory");
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Shop - NexusShop</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/products.css">
  <style>
    .glass-effect {
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .product-card {
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255, 255, 255, 0.2);
      border-radius: 15px;
      overflow: hidden;
      transition: all 0.3s ease;
    }

    .product-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    }

    .error-message {
      background: rgba(231, 76, 60, 0.2);
      border: 1px solid rgba(231, 76, 60, 0.5);
      color: white;
      padding: 15px;
      border-radius: 8px;
      margin-bottom: 20px;
      text-align: center;
    }

    .no-products {
      text-align: center;
      padding: 60px 20px;
      color: white;
    }

    .no-products-icon {
      font-size: 4rem;
      margin-bottom: 20px;
      opacity: 0.7;
    }

    .product-image {
      position: relative;
      width: 100%;
      height: 200px;
      overflow: hidden;
      background: linear-gradient(45deg, #f8f9fa, #e9ecef);
    }

    .product-image img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform 0.3s ease;
    }

    .product-card:hover .product-image img {
      transform: scale(1.05);
    }

    .image-placeholder {
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(45deg, #667eea, #764ba2);
      color: white;
      font-size: 3rem;
    }

    .product-actions {
      position: absolute;
      top: 10px;
      right: 10px;
      display: flex;
      flex-direction: column;
      gap: 5px;
      opacity: 0;
      transition: opacity 0.3s ease;
    }

    .product-card:hover .product-actions {
      opacity: 1;
    }

    .action-btn {
      width: 35px;
      height: 35px;
      border: none;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.9);
      color: #333;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.3s ease;
      backdrop-filter: blur(10px);
    }

    .action-btn:hover {
      background: white;
      transform: scale(1.1);
    }

    .wishlist-btn:hover {
      color: #e74c3c;
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

<!-- Updated Header -->
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
        <li class="nav-item"><a href="${pageContext.request.contextPath}/products" class="nav-link active">Shop</a></li>
        <li class="nav-item"><a href="about.jsp" class="nav-link">About</a></li>
      </ul>
    </nav>

    <div class="user-actions">
      <c:choose>
        <c:when test="${not empty sessionScope.user}">
          <div class="action-item">
            <span class="action-text">Welcome, ${sessionScope.user.fullName}</span>
          </div>
          <div class="action-item">
            <a href="${pageContext.request.contextPath}/user" class="action-link">
              <i class="fas fa-user"></i>
              <span class="action-text">Account</span>
            </a>
          </div>
          <div class="action-item">
            <a href="${pageContext.request.contextPath}/logout" class="action-link">
              <i class="fas fa-sign-out-alt"></i>
              <span class="action-text">Logout</span>
            </a>
          </div>
        </c:when>
        <c:otherwise>
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
        </c:otherwise>
      </c:choose>


      <div class="action-item">
        <a href="${pageContext.request.contextPath}/cart/view" class="action-link">
          <i class="fas fa-shopping-cart"></i>
          <span class="action-text">Cart</span>
          <c:if test="${not empty sessionScope.cart and not empty sessionScope.cart.totalItems}">
            <span class="cart-count">${sessionScope.cart.totalItems}</span>
          </c:if>
        </a>
      </div>
    </div>

    <div class="mobile-menu-btn">
      <i class="fas fa-bars"></i>
    </div>
  </div>
</header>

<main class="products-page">
  <div class="container">
    <div class="page-header">
      <h1 class="page-title">Discover Amazing Products</h1>
      <p class="page-subtitle">Find the perfect tech products for your needs</p>
    </div>

    <%-- Error Message --%>
    <% if (error != null) { %>
    <div class="error-message glass-effect">
      <i class="fas fa-exclamation-triangle"></i> <%= error %>
    </div>
    <% } %>

    <!-- Modern Filter Section -->
    <div class="filter-section glass-effect">
      <form id="filter-form" action="${pageContext.request.contextPath}/products" method="get" class="filter-grid">
        <div class="filter-group">
          <label for="search" class="filter-label">
            <i class="fas fa-search"></i> Search
          </label>
          <input type="text" id="search" name="search" value="<%= searchQuery != null ? searchQuery : "" %>"
                 placeholder="What are you looking for?" class="filter-input">
        </div>

        <div class="filter-group">
          <label for="category" class="filter-label">
            <i class="fas fa-tags"></i> Category
          </label>
          <select id="category" name="category" class="filter-select">
            <option value="">All Categories</option>
            <option value="Electronics" <%= "Electronics".equals(selectedCategory) ? "selected" : "" %>>Electronics</option>
            <option value="Clothing" <%= "Clothing".equals(selectedCategory) ? "selected" : "" %>>Clothing</option>
            <option value="Books" <%= "Books".equals(selectedCategory) ? "selected" : "" %>>Books</option>
            <option value="Home" <%= "Home".equals(selectedCategory) ? "selected" : "" %>>Home</option>
            <option value="Sports" <%= "Sports".equals(selectedCategory) ? "selected" : "" %>>Sports</option>
            <option value="Beauty" <%= "Beauty".equals(selectedCategory) ? "selected" : "" %>>Beauty</option>
          </select>
        </div>

        <div class="filter-group">
          <label class="filter-label">
            <i class="fas fa-dollar-sign"></i> Price Range
          </label>
          <div class="price-range-group">
            <div class="price-inputs">
              <input type="number" id="price_min" name="price_min" value="${param.price_min}"
                     placeholder="Min" min="0" step="0.01" class="price-input">
              <span class="price-separator">to</span>
              <input type="number" id="price_max" name="price_max" value="${param.price_max}"
                     placeholder="Max" min="0" step="0.01" class="price-input">
            </div>
          </div>
        </div>

        <div class="filter-actions">
          <button type="submit" class="filter-btn primary">
            <i class="fas fa-filter"></i> Apply Filters
          </button>
          <a href="${pageContext.request.contextPath}/products" class="filter-btn secondary">
            <i class="fas fa-times"></i> Clear All
          </a>
        </div>
      </form>
    </div>

    <!-- Results Header -->
    <div class="results-header">
      <div class="results-count">
        <span class="count"><%= products != null ? products.size() : 0 %></span> products found
      </div>
      <div class="sort-options">
        <span>Sort by:</span>
        <select class="sort-select" onchange="sortProducts(this.value)">
          <option value="featured" ${param.sort == 'featured' ? 'selected' : ''}>Featured</option>
          <option value="price_asc" ${param.sort == 'price_asc' ? 'selected' : ''}>Price: Low to High</option>
          <option value="price_desc" ${param.sort == 'price_desc' ? 'selected' : ''}>Price: High to Low</option>
          <option value="rating" ${param.sort == 'rating' ? 'selected' : ''}>Highest Rated</option>
          <option value="newest" ${param.sort == 'newest' ? 'selected' : ''}>Newest First</option>
        </select>
      </div>
    </div>

    <!-- Products Grid -->
    <div class="products-grid" id="productsGrid">
      <% if (products != null && !products.isEmpty()) { %>
      <% for (Product product : products) { %>
      <div class="product-card" onclick="window.location.href='${pageContext.request.contextPath}/product-detail?id=<%= product.getProductID() %>'"
           data-price="<%= product.getPrice() %>" data-rating="<%= product.getRating() %>">

        <div class="product-badge">
          <% if (product.getPrice() < 100) { %>
          <span class="badge discount">Hot Deal</span>
          <% } %>
          <% if (product.getStock() > 0 && product.getStock() <= 10) { %>
          <span class="badge low-stock">Low Stock</span>
          <% } %>
          <% if (product.getCreatedDate() != null &&
                  System.currentTimeMillis() - product.getCreatedDate().getTime() < 7 * 24 * 60 * 60 * 1000) { %>
          <span class="badge new">New</span>
          <% } %>
        </div>

        <!-- Replace the entire product-image div with this: -->
        <div class="product-image">
          <%
            // Get the product image map
            Map<String, String> productImageMap = (Map<String, String>) request.getAttribute("productImageMap");
            String productId = product.getProductID();
            String imageUrl = productImageMap != null ? productImageMap.get(productId) : null;

            if (imageUrl != null && !imageUrl.trim().isEmpty()) {
          %>
          <img src="${pageContext.request.contextPath}<%= imageUrl %>"
               alt="<%= product.getName() %>"
               onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
          <div class="image-placeholder" style="display: none;">
            <i class="fas fa-box"></i>
          </div>
          <% } else { %>
          <div class="image-placeholder">
            <i class="fas fa-box"></i>
          </div>
          <% } %>

          <div class="product-actions">
            <button class="action-btn wishlist-btn" onclick="addToWishlist('<%= product.getProductID() %>'); event.stopPropagation();"
                    title="Add to Wishlist">
              <i class="far fa-heart"></i>
            </button>
          </div>
        </div>

        <div class="product-content">
          <h3 class="product-title">
            <a href="${pageContext.request.contextPath}/product-detail?id=<%= product.getProductID() %>"
               class="product-link" onclick="event.stopPropagation();">
              <%= product.getName() %>
            </a>
          </h3>
          <div class="product-category"><%= product.getCategory() %></div>

          <div class="product-rating">
            <% for (int i = 1; i <= 5; i++) { %>
            <% if (i <= (int)product.getRating()) { %>
            <i class="fas fa-star"></i>
            <% } else { %>
            <i class="far fa-star"></i>
            <% } %>
            <% } %>
            <span class="rating-text">(<%= String.format("%.1f", product.getRating()) %>)</span>
          </div>

          <div class="product-price">
            <span class="current-price">$<%= String.format("%.2f", product.getPrice()) %></span>
            <% if (product.getPrice() > 200) { %>
            <span class="original-price">$<%= String.format("%.2f", product.getPrice() + 50) %></span>
            <% } %>
          </div>

          <div class="product-stock">
            <% if (product.getStock() > 10) { %>
            <span class="stock in-stock"><i class="fas fa-check"></i> In Stock</span>
            <% } else if (product.getStock() > 0) { %>
            <span class="stock low-stock"><i class="fas fa-exclamation-triangle"></i> Only <%= product.getStock() %> left</span>
            <% } else { %>
            <span class="stock out-of-stock"><i class="fas fa-times"></i> Out of Stock</span>
            <% } %>
          </div>

          <div class="product-actions-main">
            <button class="btn add-to-cart-btn" onclick="addToCart('<%= product.getProductID() %>'); event.stopPropagation();"
                    <%= product.getStock() == 0 ? "disabled" : "" %>>
              <i class="fas fa-shopping-cart"></i>
              Add to Cart
            </button>

            <button class="btn buy-now-btn" onclick="buyNow('<%= product.getProductID() %>'); event.stopPropagation();"
                    <%= product.getStock() == 0 ? "disabled" : "" %>>
              <i class="fas fa-bolt"></i>
              Buy Now
            </button>
          </div>
        </div>
      </div>
      <% } %>
      <% } else { %>
      <div class="no-products glass-effect">
        <div class="no-products-icon">
          <i class="fas fa-search"></i>
        </div>
        <h3>No products found</h3>
        <p>
          <% if (searchQuery != null) { %>
          No products found for '<%= searchQuery %>'
          <% } else if (selectedCategory != null) { %>
          No products found in category '<%= selectedCategory %>'
          <% } else { %>
          No products available at the moment
          <% } %>
        </p>
        <a href="${pageContext.request.contextPath}/products" class="btn primary">Browse All Products</a>
      </div>
      <% } %>
    </div>
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
        <button type="submit" class="cta-button primary">
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

<!-- JavaScript -->
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
  // Product interaction functions
  function addToCart(productId) {
    fetch('${pageContext.request.contextPath}/cart/add', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'productId=' + productId + '&quantity=1'
    })
            .then(response => response.json())
            .then(data => {
              if (data.success) {
                // Update cart count
                const cartCount = document.querySelector('.cart-count');
                if (cartCount) {
                  cartCount.textContent = data.totalItems;
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

  function buyNow(productId) {
    addToCart(productId);
    setTimeout(() => {
      window.location.href = '${pageContext.request.contextPath}/cart/view';
    }, 1000);
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
                // Update heart icon
                const heartIcon = event.target.closest('.wishlist-btn').querySelector('i');
                heartIcon.className = 'fas fa-heart';
                event.target.closest('.wishlist-btn').style.pointerEvents = 'none';
              } else {
                showNotification('Error adding to wishlist', 'error');
              }
            })
            .catch(error => {
              console.error('Error:', error);
              showNotification('Error adding to wishlist', 'error');
            });
  }

  function sortProducts(sortType) {
    const url = new URL(window.location.href);
    url.searchParams.set('sort', sortType);
    window.location.href = url.toString();
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

  // Initialize product grid animations
  document.addEventListener('DOMContentLoaded', function() {
    const productCards = document.querySelectorAll('.product-card');
    productCards.forEach((card, index) => {
      card.style.animationDelay = (index * 0.1) + 's';
    });
  });
</script>
</body>
</html>