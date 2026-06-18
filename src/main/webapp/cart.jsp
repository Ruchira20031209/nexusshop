<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Shopping Cart - NexusShop</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cart.css">
</head>
<body>
<div class="floating-bg">
  <div class="floating-circle circle-1"></div>
  <div class="floating-circle circle-2"></div>
  <div class="floating-circle circle-3"></div>
  <div class="floating-circle circle-4"></div>
</div>

<!-- Header Matching Products Page -->
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
        <a href="wishlist.jsp" class="action-link">
          <i class="far fa-heart"></i>
          <span class="action-text">Wishlist</span>
        </a>
      </div>

      <div class="action-item">
        <a href="${pageContext.request.contextPath}/cart/view" class="action-link">
          <i class="fas fa-shopping-cart"></i>
          <span class="action-text">Cart</span>
          <c:if test="${not empty sessionScope.cartCount and sessionScope.cartCount > 0}">
            <span class="cart-count">${sessionScope.cartCount}</span>
          </c:if>
        </a>
      </div>
    </div>

    <div class="mobile-menu-btn">
      <i class="fas fa-bars"></i>
    </div>
  </div>
</header>

<!-- Main Cart Content -->
<main class="shopping-cart">
  <div class="container">
    <!-- Cart Header -->
    <div class="cart-header">
      <h1 class="page-title">Your Shopping Cart</h1>
      <p class="page-subtitle">Review your items and proceed to checkout</p>

      <!-- Progress Steps -->
      <div class="cart-steps">
        <div class="step active">
          <div class="step-number">1</div>
          <div class="step-text">Shopping Cart</div>
        </div>
        <div class="step">
          <div class="step-number">2</div>
          <div class="step-text">Checkout</div>
        </div>
        <div class="step">
          <div class="step-number">3</div>
          <div class="step-text">Order Complete</div>
        </div>
      </div>
    </div>

    <!-- Messages -->
    <c:if test="${not empty message}">
      <div class="notification success">
        <i class="fas fa-check-circle"></i>
        <span>${message}</span>
      </div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="notification error">
        <i class="fas fa-exclamation-triangle"></i>
        <span>${error}</span>
      </div>
    </c:if>

    <c:choose>
      <c:when test="${cart eq null or cart.items eq null or cart.items.size() == 0}">
        <!-- Empty Cart State -->
        <div class="empty-cart glass-effect">
          <div class="empty-cart-icon">
            <i class="fas fa-shopping-cart"></i>
          </div>
          <h2>Your cart is empty</h2>
          <p>Looks like you haven't added any items to your cart yet.</p>
          <a href="${pageContext.request.contextPath}/products" class="btn primary">
            <i class="fas fa-shopping-bag"></i> Start Shopping
          </a>
        </div>
      </c:when>
      <c:otherwise>
        <!-- Cart Content -->
        <div class="cart-content">
          <!-- Cart Items Section -->
          <div class="cart-items glass-effect">
            <div class="cart-table-header">
              <div class="header-product">Product</div>
              <div class="header-price">Price</div>
              <div class="header-quantity">Quantity</div>
              <div class="header-subtotal">Subtotal</div>
              <div class="header-actions">Actions</div>
            </div>

            <c:forEach var="item" items="${cart.items}">
              <div class="cart-item" data-product-id="${item.product.productID}">
                <div class="item-product">
                  <div class="product-image">
                    <c:choose>
                      <c:when test="${not empty item.imageUrl}">
                        <img src="${pageContext.request.contextPath}${item.imageUrl}"
                             alt="${item.product.name}"
                             onerror="this.src='${pageContext.request.contextPath}/images/default-product.jpg'">
                      </c:when>
                      <c:otherwise>
                        <!-- Fallback placeholder -->
                        <div style="width: 80px; height: 80px; background: linear-gradient(45deg, #667eea, #764ba2);
                          display: flex; align-items: center; justify-content: center; color: white; border-radius: 8px;">
                          <i class="fas fa-box"></i>
                        </div>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <div class="product-info">
                    <h3 class="product-title">${item.product.name}</h3>
                    <div class="product-sku">SKU: ${item.product.sku}</div>
                    <div class="product-availability">
                      <c:choose>
                        <c:when test="${item.product.stock > 10}">
                          <i class="fas fa-check-circle" style="color: #2e7d32;"></i> In Stock
                        </c:when>
                        <c:when test="${item.product.stock > 0}">
                          <i class="fas fa-exclamation-triangle" style="color: #f57c00;"></i> Only ${item.product.stock} left
                        </c:when>
                        <c:otherwise>
                          <i class="fas fa-times-circle" style="color: #c62828;"></i> Out of Stock
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </div>
                </div>

                <div class="item-price">
                  <div class="current-price">$${item.unitPrice}</div>
                  <c:if test="${item.unitPrice > 200}">
                    <div class="original-price" style="text-decoration: line-through; color: #999; font-size: 0.9em;">
                      $${item.unitPrice + 50}
                    </div>
                  </c:if>
                </div>

                <div class="item-quantity">
                  <form action="${pageContext.request.contextPath}/cart/update" method="post" class="quantity-form">
                    <input type="hidden" name="productId" value="${item.product.productID}">
                    <div class="quantity-selector">
                      <button type="button" class="quantity-btn minus" onclick="decreaseQuantity('${item.product.productID}', ${item.product.stock})">
                        <i class="fas fa-minus"></i>
                      </button>
                      <input type="number" name="quantity" class="quantity-input"
                             value="${item.quantity}" min="1" max="${item.product.stock}"
                             data-product-id="${item.product.productID}" required>
                      <button type="button" class="quantity-btn plus" onclick="increaseQuantity('${item.product.productID}', ${item.product.stock})">
                        <i class="fas fa-plus"></i>
                      </button>
                    </div>
                    <button type="submit" class="update-btn" style="display: none;">Update</button>
                  </form>
                </div>

                <div class="item-subtotal">
                  $${item.totalPrice}
                </div>

                <div class="item-actions">
                  <form action="${pageContext.request.contextPath}/cart/remove" method="post" class="remove-form">
                    <input type="hidden" name="productId" value="${item.product.productID}">
                    <button type="submit" class="remove-btn" onclick="return confirmRemove()">
                      <i class="fas fa-trash"></i>
                    </button>
                  </form>
                </div>
              </div>
            </c:forEach>

            <!-- Cart Actions -->
            <div class="cart-actions">
              <div class="coupon-section">
                <input type="text" class="coupon-input" placeholder="Enter coupon code">
                <button type="button" class="coupon-btn">Apply Coupon</button>
              </div>
              <a href="${pageContext.request.contextPath}/products" class="continue-shopping">
                <i class="fas fa-arrow-left"></i> Continue Shopping
              </a>
            </div>
          </div>

          <!-- Cart Summary -->
          <div class="cart-summary">
            <div class="summary-card glass-effect">
              <h3 class="summary-title">Order Summary</h3>

              <%
                // Get cart from request scope
                Object cartObj = request.getAttribute("cart");
                com.nexusshope.model.Cart cart = null;

                if (cartObj instanceof com.nexusshope.model.Cart) {
                  cart = (com.nexusshope.model.Cart) cartObj;
                }

                // Safe order summary calculations
                double subtotal = 0.0;
                int itemCount = 0;
                boolean hasValidCart = false;

                if (cart != null) {
                  try {
                    java.util.List<com.nexusshope.model.CartItem> items = cart.getItems();
                    if (items != null && !items.isEmpty()) {
                      hasValidCart = true;
                      for (com.nexusshope.model.CartItem item : items) {
                        if (item != null) {
                          subtotal += item.getTotalPrice();
                          itemCount += item.getQuantity();
                        }
                      }
                    }
                  } catch (Exception e) {
                    // Cart exists but has issues
                    System.out.println("DEBUG: Error processing cart: " + e.getMessage());
                  }
                }

                // If no valid cart data, check session for cart count
                if (!hasValidCart) {
                  Object cartCountObj = session.getAttribute("cartCount");
                  if (cartCountObj instanceof Integer) {
                    itemCount = (Integer) cartCountObj;
                  }
                }

                // Basic calculations
                double shipping = subtotal >= 100 ? 0.0 : 10.0;
                double tax = subtotal * 0.08;
                double discount = subtotal > 200 ? subtotal * 0.10 : 0.0;
                double total = subtotal + shipping + tax - discount;
              %>
              <!-- Item Count -->
              <div class="summary-info">
                <i class="fas fa-shopping-bag"></i>
                <%= itemCount %> items in cart
              </div>

              <!-- Show empty state if no items -->
              <% if (itemCount == 0) { %>
              <div class="empty-cart-message" style="text-align: center; padding: 20px; color: #666;">
                <i class="fas fa-shopping-cart" style="font-size: 2em; margin-bottom: 10px;"></i>
                <p>Your cart is empty</p>
              </div>
              <% } else { %>

              <!-- Price Breakdown -->
              <div class="summary-row">
                <span class="row-label">Subtotal</span>
                <span class="row-value">$<%= String.format("%.2f", subtotal) %></span>
              </div>

              <div class="summary-row">
                <span class="row-label">Shipping</span>
                <span class="row-value <%= shipping == 0 ? "free" : "" %>">
                <%= shipping == 0 ? "FREE" : "$10.00" %>
            </span>
              </div>

              <div class="summary-row">
                <span class="row-label">Tax (8%)</span>
                <span class="row-value">$<%= String.format("%.2f", tax) %></span>
              </div>

              <% if (discount > 0) { %>
              <div class="summary-row discount">
                <span class="row-label">Discount (10% OFF)</span>
                <span class="row-value">-$<%= String.format("%.2f", discount) %></span>
              </div>
              <% } %>

              <!-- Total -->
              <div class="summary-row total">
                <span class="row-label">Total Amount</span>
                <span class="row-value">$<%= String.format("%.2f", total) %></span>
              </div>

              <!-- Shipping Progress -->
              <% if (subtotal < 100) { %>
              <div class="shipping-progress">
                <div class="progress-info">
                  <i class="fas fa-rocket"></i>
                  <strong>Free Shipping</strong> on orders over $100
                </div>
                <div class="progress-container">
                  <div class="progress-bar">
                    <div class="progress-fill" style="width: <%= Math.min((subtotal / 100) * 100, 100) %>%"></div>
                  </div>
                  <div class="progress-labels">
                    <span>$<%= String.format("%.2f", subtotal) %></span>
                    <span>$100</span>
                  </div>
                </div>
                <div class="progress-message">
                  Add $<%= String.format("%.2f", 100 - subtotal) %> more for FREE shipping!
                </div>
              </div>
              <% } else { %>
              <div class="free-shipping-achieved">
                <i class="fas fa-check-circle"></i>
                <strong>FREE Shipping</strong> unlocked!
              </div>
              <% } %>

              <% } %>

              <!-- Action Buttons -->
              <div class="summary-actions">
                <% if (itemCount > 0) { %>
                <a href="${pageContext.request.contextPath}/checkout" class="checkout-btn primary">
                  <i class="fas fa-lock"></i>
                  <span>Proceed to Checkout</span>
                  <small>$<%= String.format("%.2f", total) %></small>
                </a>
                <% } else { %>
                <!-- Add this to the bottom of your cart.jsp, after the cart items table -->
                <c:if test="${not empty cart && not cart.isEmpty()}">
                  <div class="row mt-4">
                    <div class="col-md-8"></div>
                    <div class="col-md-4">
                      <div class="d-grid gap-2">
                        <a href="${pageContext.request.contextPath}/checkout"
                           class="btn btn-primary btn-lg">Proceed to Checkout</a>
                      </div>
                    </div>
                  </div>
                </c:if>
                <% } %>

                <a href="${pageContext.request.contextPath}/products" class="continue-link">
                  <i class="fas fa-arrow-left"></i> Continue Shopping
                </a>
              </div>
            </div>

            <!-- Security Badges -->
            <div class="security-badges">
              <div class="badge-item">
                <i class="fas fa-shield-alt"></i>
                <span>Secure Checkout</span>
              </div>
              <div class="badge-item">
                <i class="fas fa-truck"></i>
                <span>Free Shipping Over $100</span>
              </div>
              <div class="badge-item">
                <i class="fas fa-undo"></i>
                <span>30-Day Returns</span>
              </div>
            </div>
          </div>

        <!-- Cross-sell Products -->
        <div class="cross-sell">
          <h2 class="section-title">You Might Also Like</h2>
          <div class="cross-sell-grid">
            <!-- These would be populated with related products -->
            <div class="cross-sell-item glass-effect">
              <div class="product-image">
                <div style="width: 100%; height: 120px; background: linear-gradient(45deg, #667eea, #764ba2);
                                          display: flex; align-items: center; justify-content: center; color: white; border-radius: 8px;">
                  <i class="fas fa-headphones"></i>
                </div>
              </div>
              <h3 class="product-title">Premium Wireless Headphones</h3>
              <div class="product-price">
                <span class="current-price">$129.99</span>
                <span class="original-price" style="text-decoration: line-through; color: #999; font-size: 0.9em;">$149.99</span>
              </div>
              <form action="${pageContext.request.contextPath}/cart/add" method="post" style="margin: 0;">
                <input type="hidden" name="productId" value="P006">
                <input type="hidden" name="quantity" value="1">
                <button type="submit" class="add-to-cart" style="width: 100%; padding: 10px; background: #6c5ce7; color: white; border: none; border-radius: 5px; cursor: pointer;">
                  <i class="fas fa-cart-plus"></i> Add to Cart
                </button>
              </form>
            </div>

            <div class="cross-sell-item glass-effect">
              <div class="product-image">
                <div style="width: 100%; height: 120px; background: linear-gradient(45deg, #667eea, #764ba2);
                                          display: flex; align-items: center; justify-content: center; color: white; border-radius: 8px;">
                  <i class="fas fa-mobile-alt"></i>
                </div>
              </div>
              <h3 class="product-title">Protective Phone Case</h3>
              <div class="product-price">
                <span class="current-price">$24.99</span>
              </div>
              <form action="${pageContext.request.contextPath}/cart/add" method="post" style="margin: 0;">
                <input type="hidden" name="productId" value="P007">
                <input type="hidden" name="quantity" value="1">
                <button type="submit" class="add-to-cart" style="width: 100%; padding: 10px; background: #6c5ce7; color: white; border: none; border-radius: 5px; cursor: pointer;">
                  <i class="fas fa-cart-plus"></i> Add to Cart
                </button>
              </form>
            </div>

            <div class="cross-sell-item glass-effect">
              <div class="product-image">
                <div style="width: 100%; height: 120px; background: linear-gradient(45deg, #667eea, #764ba2);
                                          display: flex; align-items: center; justify-content: center; color: white; border-radius: 8px;">
                  <i class="fas fa-bolt"></i>
                </div>
              </div>
              <h3 class="product-title">Fast Charging Cable</h3>
              <div class="product-price">
                <span class="current-price">$19.99</span>
                <span class="original-price" style="text-decoration: line-through; color: #999; font-size: 0.9em;">$29.99</span>
              </div>
              <form action="${pageContext.request.contextPath}/cart/add" method="post" style="margin: 0;">
                <input type="hidden" name="productId" value="P008">
                <input type="hidden" name="quantity" value="1">
                <button type="submit" class="add-to-cart" style="width: 100%; padding: 10px; background: #6c5ce7; color: white; border: none; border-radius: 5px; cursor: pointer;">
                  <i class="fas fa-cart-plus"></i> Add to Cart
                </button>
              </form>
            </div>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
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
          <li><a href="${pageContext.request.contextPath}/products?filter=new">New Arrivals</a></li>
          <li><a href="${pageContext.request.contextPath}/products?filter=featured">Featured</a></li>
          <li><a href="${pageContext.request.contextPath}/products?filter=deals">Deals</a></li>
          <li><a href="${pageContext.request.contextPath}/products?filter=bestsellers">Best Sellers</a></li>
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
  // Quantity controls
  function increaseQuantity(productId, maxStock) {
    const input = document.querySelector(`input[data-product-id="${productId}"]`);
    const currentValue = parseInt(input.value);
    if (currentValue < maxStock) {
      input.value = currentValue + 1;
      highlightQuantityChange(input);
      // Auto-submit the form
      input.closest('.quantity-form').submit();
    }
  }

  function decreaseQuantity(productId, maxStock) {
    const input = document.querySelector(`input[data-product-id="${productId}"]`);
    const currentValue = parseInt(input.value);
    if (currentValue > 1) {
      input.value = currentValue - 1;
      highlightQuantityChange(input);
      // Auto-submit the form
      input.closest('.quantity-form').submit();
    }
  }

  function highlightQuantityChange(input) {
    input.classList.add('quantity-changed');
    setTimeout(() => {
      input.classList.remove('quantity-changed');
    }, 1000);
  }

  // Remove confirmation
  function confirmRemove() {
    return confirm('Are you sure you want to remove this item from your cart?');
  }

  // Notification system
  function showNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;

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

  // Auto-update quantity on manual input change
  document.addEventListener('DOMContentLoaded', function() {
    const quantityInputs = document.querySelectorAll('.quantity-input');
    quantityInputs.forEach(input => {
      input.addEventListener('change', function() {
        // Update cart via form submission
        this.closest('.quantity-form').submit();
      });
    });

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
  });
</script>
</body>
</html>