<%--
  Dynamic FAQ Page — Loads from DB
  Updated for NexusShop with com.nexusshope.model.FAQ
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.nexusshope.model.FAQ" %>
<%@ page import="java.util.List" %>
<%
    // Get data from FAQServlet
    List<FAQ> faqs = (List<FAQ>) request.getAttribute("faqs");
    List<String> categories = (List<String>) request.getAttribute("categories");
    String selectedCategory = (String) request.getAttribute("selectedCategory");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String error = (String) request.getAttribute("error");

    if (selectedCategory == null) selectedCategory = "general";
    if (faqs == null) faqs = java.util.Collections.emptyList();
    if (categories == null) categories = java.util.Arrays.asList("general", "shipping", "returns", "account", "orders", "payments");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FAQs - NexusShop</title>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <!-- CSS -->
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/faq.css">
    <style>
        .category.active {
            background: #6c5ce7;
            color: white;
        }
        .category.active i {
            color: white;
        }
        .faq-item.active .faq-answer {
            display: block;
        }
        .faq-answer {
            display: none;
            padding: 15px 0 0 30px;
            color: #666;
            line-height: 1.6;
        }
        .suggestions-dropdown {
            position: absolute;
            background: white;
            border: 1px solid #ddd;
            border-top: none;
            max-height: 200px;
            overflow-y: auto;
            z-index: 1000;
            width: 100%;
            display: none;
        }
        .suggestion-item {
            padding: 10px 15px;
            cursor: pointer;
            border-bottom: 1px solid #eee;
        }
        .suggestion-item:hover {
            background: #f8f9fa;
        }
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Enhanced FAQ Item Styling */
        .faq-item {
            border: 1px solid #e9ecef;
            border-radius: 12px;
            margin-bottom: 12px;
            overflow: hidden;
            transition: all 0.3s ease;
            background: white;
        }
        .faq-item:hover {
            border-color: #6c5ce7;
            box-shadow: 0 4px 12px rgba(108, 92, 231, 0.1);
        }
        .faq-item.active {
            border-color: #6c5ce7;
            box-shadow: 0 6px 20px rgba(108, 92, 231, 0.15);
        }
        .faq-question {
            padding: 20px 25px;
            cursor: pointer;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 15px;
            transition: background-color 0.3s ease;
        }
        .faq-question:hover {
            background-color: #f8f9ff;
        }
        .faq-question-content {
            display: flex;
            align-items: flex-start;
            gap: 15px;
            flex: 1;
        }
        .question-icon {
            color: #6c5ce7;
            font-size: 1.2em;
            margin-top: 2px;
            flex-shrink: 0;
            transition: transform 0.3s ease;
        }
        .faq-item.active .question-icon {
            transform: rotate(15deg);
            color: #5a4fd4;
        }
        .faq-question h3 {
            margin: 0;
            font-size: 1.1em;
            font-weight: 600;
            color: #2d3436;
            line-height: 1.5;
        }
        .faq-question .toggle-icon {
            color: #6c5ce7;
            font-size: 0.9em;
            transition: transform 0.3s ease;
            flex-shrink: 0;
            margin-top: 2px;
        }
        .faq-item.active .faq-question .toggle-icon {
            transform: rotate(180deg);
        }
        .faq-answer {
            padding: 0 25px 25px 70px;
            color: #666;
            line-height: 1.7;
            border-top: 1px solid #f1f3f4;
            margin-top: 0;
            background: #fafbff;
        }
        .faq-answer p {
            margin: 0;
            position: relative;
        }
        .faq-answer p:before {
            content: "•";
            color: #6c5ce7;
            font-weight: bold;
            position: absolute;
            left: -20px;
        }

        /* Enhanced Category Icons */
        .faq-categories {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        .category {
            background: white;
            border: 2px solid #e9ecef;
            border-radius: 12px;
            padding: 20px 15px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
        }
        .category:hover {
            border-color: #6c5ce7;
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(108, 92, 231, 0.15);
        }
        .category.active {
            background: #6c5ce7;
            border-color: #6c5ce7;
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(108, 92, 231, 0.25);
        }
        .category i {
            font-size: 1.8em;
            color: #6c5ce7;
            transition: all 0.3s ease;
            margin-bottom: 5px;
        }
        .category.active i {
            color: white;
            transform: scale(1.1);
        }
        .category span {
            font-weight: 600;
            font-size: 0.95em;
            color: #2d3436;
            transition: color 0.3s ease;
        }
        .category.active span {
            color: white;
        }

        /* Category-specific icon colors */
        .category[data-category="general"] i { color: #6c5ce7; }
        .category[data-category="orders"] i { color: #00b894; }
        .category[data-category="shipping"] i { color: #0984e3; }
        .category[data-category="returns"] i { color: #e17055; }
        .category[data-category="payments"] i { color: #00cec9; }
        .category[data-category="account"] i { color: #a29bfe; }

        .category.active[data-category="general"] i { color: white; }
        .category.active[data-category="orders"] i { color: white; }
        .category.active[data-category="shipping"] i { color: white; }
        .category.active[data-category="returns"] i { color: white; }
        .category.active[data-category="payments"] i { color: white; }
        .category.active[data-category="account"] i { color: white; }
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
            <a href="index.jsp">
                <span class="logo-icon"><i class="fas fa-atom"></i></span>
                <span class="logo-text">NexusShop</span>
            </a>
        </div>

        <!-- Navigation -->
        <nav class="main-nav">
            <ul class="nav-list">
                <li class="nav-item"><a href="index.jsp" class="nav-link">Home</a></li>
                <li class="nav-item"><a href="products" class="nav-link">Shop</a></li>
                <li class="nav-item"><a href="products?filter=deals" class="nav-link">Deals</a></li>
                <li class="nav-item"><a href="products?filter=new" class="nav-link">New Arrivals</a></li>
                <li class="nav-item"><a href="faq" class="nav-link active">FAQs</a></li>
            </ul>
        </nav>

        <!-- User Actions -->
        <div class="user-actions">
            <%
                com.nexusshope.model.User currentUser = (com.nexusshope.model.User) session.getAttribute("user");
                if (currentUser != null) {
            %>
            <div class="action-item">
                <a href="myaccount.jsp" class="action-link">
                    <i class="far fa-user"></i>
                    <span class="action-text">My Account</span>
                </a>
            </div>
            <%
            } else {
            %>
            <div class="action-item">
                <a href="login.jsp" class="action-link">
                    <i class="far fa-user"></i>
                    <span class="action-text">Login</span>
                </a>
            </div>
            <%
                }
            %>
            <div class="action-item">
                <a href="wishlist.jsp" class="action-link">  <!-- Changed from .html to .jsp -->
                    <i class="far fa-heart"></i>
                    <span class="action-text">Wishlist</span>
                </a>
            </div>
            <div class="action-item">
                <a href="cart/view" class="action-link">  <!-- Changed to cart servlet -->
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

<!-- FAQ Hero Section -->
<section class="faq-hero">
    <div class="container">
        <div class="faq-hero-content">
            <h1>Frequently Asked Questions</h1>
            <p>Find answers to common questions about our products, services, and policies.</p>
            <div class="search-faq">
                <form action="faq" method="GET" class="search-form">
                    <div class="search-input-group">
                        <input type="text" name="search" id="faqSearchInput" placeholder="Search FAQs..."
                               value="<%= searchKeyword != null ? searchKeyword : "" %>" class="search-input">
                        <button type="submit" class="search-btn" aria-label="Search">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                    <div id="suggestionsDropdown" class="suggestions-dropdown"></div>
                </form>
            </div>
        </div>
    </div>
</section>

<!-- FAQ Main Section -->
<section class="faq-section">
    <div class="container">
        <!-- Error Message -->
        <% if (error != null) { %>
        <div class="error-message">
            <i class="fas fa-exclamation-circle"></i>
            <span><%= error %></span>
        </div>
        <% } %>

        <!-- Category Sidebar -->
        <div class="faq-categories">
            <% for (String cat : categories) {
                if (cat == null) continue;
                String iconClass = "fas fa-question";
                String displayName = cat.substring(0, 1).toUpperCase() + cat.substring(1).toLowerCase();

                // Set appropriate icons for each category
                switch (cat.toLowerCase()) {
                    case "general":
                        iconClass = "fas fa-question-circle";
                        displayName = "General";
                        break;
                    case "orders":
                        iconClass = "fas fa-shopping-bag";
                        displayName = "Orders";
                        break;
                    case "shipping":
                        iconClass = "fas fa-shipping-fast";
                        displayName = "Shipping & Delivery";
                        break;
                    case "returns":
                        iconClass = "fas fa-exchange-alt";
                        displayName = "Returns & Refunds";
                        break;
                    case "payments":
                        iconClass = "fas fa-credit-card";
                        displayName = "Payments";
                        break;
                    case "account":
                        iconClass = "fas fa-user-cog";
                        displayName = "Account";
                        break;
                    case "products":
                        iconClass = "fas fa-box-open";
                        displayName = "Products";
                        break;
                    case "technical":
                        iconClass = "fas fa-cogs";
                        displayName = "Technical Support";
                        break;
                    case "warranty":
                        iconClass = "fas fa-shield-alt";
                        displayName = "Warranty";
                        break;
                }
            %>
            <div class="category <%= cat.equals(selectedCategory) ? "active" : "" %>" data-category="<%= cat %>">
                <i class="<%= iconClass %>"></i>
                <span><%= displayName %></span>
            </div>
            <% } %>
        </div>

        <!-- FAQ Content -->
        <div class="faq-content">
            <% if (!faqs.isEmpty()) { %>
            <div class="faq-category-content active">
                <h2><%= selectedCategory.substring(0, 1).toUpperCase() + selectedCategory.substring(1).toLowerCase() %> Questions</h2>
                <div class="faq-accordion">
                    <% for (FAQ faq : faqs) { %>
                    <div class="faq-item">
                        <div class="faq-question">
                            <div class="faq-question-content">
                                <i class="fas fa-question-circle question-icon"></i>
                                <h3><%= faq.getQuestion() %></h3>
                            </div>
                            <i class="fas fa-chevron-down toggle-icon"></i>
                        </div>
                        <div class="faq-answer">
                            <p><%= faq.getAnswer().replace("\n", "<br>") %></p>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } else { %>
            <div class="faq-category-content active">
                <h2>No FAQs Found</h2>
                <p>Try adjusting your search or category filter.</p>
            </div>
            <% } %>
        </div>

        <!-- Still Have Questions Section -->
        <div class="still-questions">
            <div class="still-questions-content">
                <h2>Still have questions?</h2>
                <p>Can't find the answer you're looking for? Our support team is happy to help.</p>
                <div class="contact-options">
                    <a href="contact" class="contact-option">
                        <i class="fas fa-envelope"></i>
                        <span>Contact Us</span>
                    </a>
                    <a href="tel:+18005551234" class="contact-option">
                        <i class="fas fa-phone-alt"></i>
                        <span>Call Us</span>
                    </a>
                    <a href="#" class="contact-option live-chat">
                        <i class="fas fa-comment-dots"></i>
                        <span>Live Chat</span>
                    </a>
                </div>
            </div>
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
                    <li><a href="products?filter=new">New Arrivals</a></li>
                    <li><a href="products?filter=featured">Featured</a></li>
                    <li><a href="products?filter=deals">Deals</a></li>
                    <li><a href="products?filter=bestsellers">Best Sellers</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Help</h3>
                <ul>
                    <li><a href="contact">Contact Us</a></li>
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
<script src="js/main.js"></script>
<script>
    // Category filtering — submit form on click
    document.querySelectorAll('.category').forEach(item => {
        item.addEventListener('click', function() {
            const category = this.getAttribute('data-category');
            const url = new URL(window.location);
            url.searchParams.set('category', category);
            // Keep search term if exists
            const currentSearch = url.searchParams.get('search');
            if (!currentSearch) {
                url.searchParams.delete('search');
            }
            window.location.href = url.toString();
        });
    });

    // Accordion toggle
    document.querySelectorAll('.faq-question').forEach(item => {
        item.addEventListener('click', function() {
            const parent = this.parentElement;
            parent.classList.toggle('active');
            const icon = this.querySelector('.toggle-icon');
            const questionIcon = this.querySelector('.question-icon');

            if (parent.classList.contains('active')) {
                icon.className = 'fas fa-chevron-up toggle-icon';
                questionIcon.className = 'fas fa-question-circle question-icon';
            } else {
                icon.className = 'fas fa-chevron-down toggle-icon';
                questionIcon.className = 'fas fa-question-circle question-icon';
            }
        });
    });

    // Search suggestions (optional - can be enhanced later)
    const searchInput = document.getElementById('faqSearchInput');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            // You can implement AJAX search suggestions here if needed
            const dropdown = document.getElementById('suggestionsDropdown');
            dropdown.style.display = 'none';
        });
    }
</script>
</body>
</html>