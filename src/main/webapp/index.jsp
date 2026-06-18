<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>NexusShop - Modern Tech Store</title>
  <!-- Font Awesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
  <!-- CSS -->
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/animations.css">
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
      <a href="index.jsp">
        <span class="logo-icon"><i class="fas fa-atom"></i></span>
        <span class="logo-text">NexusShop</span>
      </a>
    </div>
    <!-- Search Bar -->
    <div class="search-bar">
      <form class="search-form">
        <input type="text" placeholder="Search for products..." class="search-input">
        <button type="submit" class="search-button">
          <i class="fas fa-search"></i>
        </button>
      </form>
    </div>
    <!-- Navigation -->
    <nav class="main-nav">
      <ul class="nav-list">
        <li class="nav-item"><a href="index.jsp" class="nav-link">Home</a></li>
        <li class="nav-item"><a href="products" class="nav-link">Shop</a></li>
        <li class="nav-item"><a href="products/?filter=deals" class="nav-link">Deals</a></li>
        <li class="nav-item"><a href="products/?filter=new" class="nav-link">New Arrivals</a></li>
        <li class="nav-item"><a href="about.jsp" class="nav-link">About</a></li>
      </ul>
    </nav>
    <!-- User Actions -->
    <div class="user-actions">
      <%
        // Check if user is logged in
        com.nexusshope.model.User currentUser = (com.nexusshope.model.User) session.getAttribute("user");
        if (currentUser != null) {
          // User is logged in → show "My Account"
      %>
      <div class="action-item">
        <a href="myaccount" class="action-link">
          <i class="far fa-user"></i>
          <span class="action-text">Hi, <%= currentUser.getFullName().split(" ")[0] %></span>
        </a>
      </div>
      <div class="action-item">
        <a href="logout" class="action-link" onclick="return confirmLogout(event);">
          <i class="fas fa-sign-out-alt"></i>
          <span class="action-text">Logout</span>
        </a>
      </div>
      <%
      } else {
        // Not logged in → show Login & Register
      %>
      <div class="action-item">
        <a href="login.jsp" class="action-link">
          <i class="far fa-user"></i>
          <span class="action-text">LogIn</span>
        </a>
      </div>
      <div class="action-item">
        <a href="register.jsp" class="action-link">
          <i class="fas fa-user-plus"></i>
          <span class="action-text">Register</span>
        </a>
      </div>
      <%
        }
      %>
      <div class="action-item">
        <a href="cart/view" class="action-link">
          <i class="fas fa-shopping-cart"></i>
          <span class="action-text">Cart</span>
          <span class="cart-count">0</span>
        </a>
      </div>
    </div>
    <!-- Mobile Menu Button -->
    <div class="mobile-menu-btn">
      <i class="fas fa-bars"></i>
    </div>
  </div>
</header>
<!-- Hero Section -->
<section class="hero">
  <div class="hero-container">
    <!-- Hero Content -->
    <div class="hero-content">
      <h1 class="hero-title">Summer <span>Tech</span> Sale Is Live!</h1>
      <p class="hero-subtitle">Up to 70% off on premium gadgets and electronics. Limited time offer.</p>
      <div class="hero-cta">
        <a href="products/?filter=deals" class="cta-button primary">Shop Now</a>
        <a href="#trending" class="cta-button secondary">Explore Deals</a>
      </div>
      <div class="hero-stats">
        <div class="stat-item">
          <span class="stat-number">10K+</span>
          <span class="stat-text">Products</span>
        </div>
        <div class="stat-item">
          <span class="stat-number">2M+</span>
          <span class="stat-text">Customers</span>
        </div>
        <div class="stat-item">
          <span class="stat-number">24/7</span>
          <span class="stat-text">Support</span>
        </div>
      </div>
    </div>
    <!-- Hero Image Carousel -->
    <div class="hero-carousel">
      <div class="carousel-track">
        <!-- Slide 1 -->
        <div class="carousel-slide active" data-price-old="299.99" data-price-new="199.99">
          <div class="image-container">
            <img src="images/hero-product1.png" alt="MacBook Pro" class="main-image">
          </div>
        </div>
        <!-- Slide 2 -->
        <div class="carousel-slide" data-price-old="399.99" data-price-new="249.99">
          <div class="image-container">
            <img src="images/hero-product2.png" alt="Smartphone" class="main-image">
          </div>
        </div>
        <!-- Slide 3 -->
        <div class="carousel-slide" data-price-old="199.99" data-price-new="129.99">
          <div class="image-container">
            <img src="images/hero-product3.png" alt="Headphones" class="main-image">
          </div>
        </div>
      </div>
      <!-- Carousel Controls -->
      <div class="carousel-controls">
        <button class="control-prev"><i class="fas fa-chevron-left"></i></button>
        <div class="carousel-dots"></div>
        <button class="control-next"><i class="fas fa-chevron-right"></i></button>
      </div>

      <!-- Price Tag -->
      <div class="price-tag">
        <span class="old-price">$299.99</span>
        <span class="new-price">$199.99</span>
      </div>
    </div>
  </div>
</section>

<!-- Shop by Category Section -->
<section class="categories">
  <div class="container">
    <h2 class="section-title">Browse Categories</h2>

    <div class="categories-grid">
      <!-- Category 1 -->
      <a href="products/?category=laptops" class="category-card">
        <div class="category-icon">
          <i class="fas fa-laptop"></i>
        </div>
        <h3 class="category-title">Laptops</h3>
      </a>

      <!-- Category 2 -->
      <a href="products/?category=phones" class="category-card">
        <div class="category-icon">
          <i class="fas fa-mobile-alt"></i>
        </div>
        <h3 class="category-title">Phones</h3>
      </a>

      <!-- Category 3 -->
      <a href="products/?category=audio" class="category-card">
        <div class="category-icon">
          <i class="fas fa-headphones"></i>
        </div>
        <h3 class="category-title">Audio</h3>
      </a>

      <!-- Category 4 -->
      <a href="products/?category=gaming" class="category-card">
        <div class="category-icon">
          <i class="fas fa-gamepad"></i>
        </div>
        <h3 class="category-title">Gaming</h3>
      </a>

      <!-- Category 5 -->
      <a href="products/?category=tablets" class="category-card">
        <div class="category-icon">
          <i class="fas fa-tablet-alt"></i>
        </div>
        <h3 class="category-title">Tablets</h3>
      </a>

      <!-- Category 6 -->
      <a href="products/?category=tvs" class="category-card">
        <div class="category-icon">
          <i class="fas fa-tv"></i>
        </div>
        <h3 class="category-title">TVs</h3>
      </a>
    </div>
  </div>
</section>

<!-- Special Offers Section -->
<section class="special-offers">
  <div class="container">
    <div class="offers-slider">
      <!-- Slide 1 -->
      <div class="offer-slide active">
        <div class="offer-content">
          <div class="offer-text">
            <span class="offer-discount">50% OFF Apple Products</span>
            <p class="offer-description">Limited time offer on all MacBooks, iPads and accessories.</p>
            <a href="products/?brand=apple" class="offer-button">Shop Now</a>
          </div>
          <div class="offer-image">
            <img src="images/offers2.png" alt="Apple Products">
          </div>
        </div>
      </div>

      <!-- Slide 2 -->
      <div class="offer-slide">
        <div class="offer-content">
          <div class="offer-text">
            <span class="offer-discount">Free Shipping Worldwide</span>
            <p class="offer-description">No minimum purchase required. Limited time offer.</p>
            <a href="products/" class="offer-button">Shop Now</a>
          </div>
          <div class="offer-image">
            <img src="images/offers1.png" alt="Shipping Offer">
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Trending Items Section -->
<section class="trending-items" id="trending">
  <div class="container">
    <h2 class="section-title">Trending Now</h2>
    <p class="section-subtitle">Discover this week's most popular tech products</p>

    <div class="trending-container">
      <div class="trending-carousel">
        <!-- Products will be loaded via JavaScript -->
      </div>
    </div>
  </div>
</section>

<!-- Banner Section -->
<section class="banner">
  <div class="container">
    <div class="banner-content">
      <h2>Premium Tech Support</h2>
      <p>Get expert help with all your tech purchases. Our support team is available 24/7.</p>
      <a href="support/" class="cta-button">Learn More</a>
    </div>
  </div>
</section>

<!-- Featured Products Section -->
<section class="featured-products">
  <div class="container">
    <div class="section-header">
      <h2 class="section-title">Featured Products</h2>
      <div class="view-toggle">
        <button class="view-btn active" data-view="grid"><i class="fas fa-th-large"></i></button>
        <button class="view-btn" data-view="list"><i class="fas fa-list"></i></button>
      </div>
    </div>

    <div class="products-container grid-view" id="productsContainer">
      <!-- Products will be loaded via JavaScript -->
    </div>

    <div class="load-more-container">
      <button class="load-more-btn" id="loadMoreBtn">Load More</button>
      <button class="show-all-btn" id="showAllBtn">Show All (125)</button>
      <button class="show-less-btn" id="showLessBtn" style="display:none;">Show Less</button>
    </div>
  </div>
</section>

<!-- Newsletter Section -->
<section class="newsletter">
  <div class="container">
    <div class="newsletter-content">
      <h2>Stay Updated</h2>
      <p>Subscribe to our newsletter for exclusive deals and tech news</p>
      <form class="newsletter-form">
        <input type="email" placeholder="Your email address" required>
        <button type="submit">Subscribe</button>
      </form>
    </div>
  </div>
</section>

<!-- Footer Section -->
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
          <li><a href="products">All Products</a></li>
          <li><a href="products/?filter=new">New Arrivals</a></li>
          <li><a href="products/?filter=featured">Featured</a></li>
          <li><a href="products/?filter=deals">Deals</a></li>
          <li><a href="products/?filter=bestsellers">Best Sellers</a></li>
        </ul>
      </div>

      <div class="footer-col">
        <h3>Help</h3>
        <ul>
          <li><a href="contact.jsp">Contact Us</a></li>
          <li><a href="faq">FAQs</a></li>
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
          <li><a href="blog/">Blog</a></li>
        </ul>
      </div>
    </div>

    <div class="footer-bottom">
      <p>&copy; 2023 NexusShop. All rights reserved.</p>
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
<script src="js/main.js"></script>
<script src="js/carousel.js"></script>
<script src="js/products.js"></script>
<script>
  function confirmLogout(event) {
    if (!confirm("Are you sure you want to logout?")) {
      event.preventDefault();
      return false;
    }
    return true;
  }
</script>
</body>
</html>
