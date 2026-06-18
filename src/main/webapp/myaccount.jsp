<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.nexusshope.model.User" %>
<%@ page import="com.nexusshope.model.PaymentCard" %>
<%@ page import="com.nexusshope.service.PaymentCardService" %>
<%
    // Get user from session
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get messages from session (set by servlets)
    String message = (String) session.getAttribute("message");
    String cardMessage = (String) session.getAttribute("cardMessage");
    String messageType = (String) session.getAttribute("messageType");
    String cardMessageType = (String) session.getAttribute("cardMessageType");

    // Clear session attributes after displaying
    if (message != null) session.removeAttribute("message");
    if (cardMessage != null) session.removeAttribute("cardMessage");
    if (messageType != null) session.removeAttribute("messageType");
    if (cardMessageType != null) session.removeAttribute("cardMessageType");

    // Combine messages
    String finalMessage = cardMessage != null ? cardMessage : message;
    String finalMessageType = cardMessageType != null ? cardMessageType : messageType;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Account - NexusShop</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/user-dashboard.css">
    <style>
        /* Modern Header Styles */
        .modern-header {
            background: linear-gradient(90deg, #f8f9fa 0%, #ffffff 100%);
            border-bottom: 1px solid #e9ecef;
            padding: 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .header-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            padding: 10px 20px;
            gap: 20px;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 700;
            color: #333;
            text-decoration: none;
        }

        .logo i {
            font-size: 1.4em;
        }

        .logo-text {
            font-family: 'Poppins', sans-serif;
            font-weight: 600;
            font-size: 1.1em;
        }

        .search-bar {
            flex: 1;
            max-width: 400px;
        }

        .search-bar form {
            display: flex;
            background: white;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 1px 5px rgba(0,0,0,0.05);
        }

        .search-bar input {
            flex: 1;
            padding: 10px 15px;
            border: none;
            outline: none;
            font-size: 0.9em;
        }

        .search-bar button {
            background: #6c5ce7;
            color: white;
            border: none;
            padding: 10px 15px;
            cursor: pointer;
            transition: background 0.2s;
        }

        .search-bar button:hover {
            background: #554bd3;
        }

        .main-nav ul {
            display: flex;
            list-style: none;
            gap: 20px;
            margin: 0;
            padding: 0;
        }

        .main-nav a {
            color: #333;
            text-decoration: none;
            font-weight: 500;
            padding: 8px 12px;
            border-radius: 4px;
            transition: background 0.2s;
        }

        .main-nav a:hover {
            background: #f1f3f5;
        }

        .user-actions {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .action-link {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #333;
            text-decoration: none;
            padding: 8px 12px;
            border-radius: 4px;
            transition: background 0.2s;
        }

        .action-link:hover {
            background: #f1f3f5;
        }

        .action-link i {
            font-size: 1.1em;
        }

        .cart-count {
            background: #ff4757;
            color: white;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8em;
            margin-left: 6px;
        }

        .user-profile {
            position: relative;
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            padding: 8px 12px;
            border-radius: 4px;
            transition: background 0.2s;
        }

        .user-profile:hover {
            background: #f1f3f5;
        }

        .user-profile .dropdown-menu {
            display: none;
            position: absolute;
            top: 100%;
            right: 0;
            background: white;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            min-width: 160px;
            z-index: 1000;
        }

        .user-profile:hover .dropdown-menu {
            display: block;
        }

        .dropdown-menu a {
            display: block;
            padding: 10px 20px;
            color: #333;
            text-decoration: none;
            transition: background 0.2s;
        }

        .dropdown-menu a:hover {
            background: #f8f9fa;
        }

        /* Payment Cards Section Styles */
        .cards-section {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            margin-top: 20px;
        }

        .cards-section h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 1.5em;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            margin-bottom: 12px;
            transition: box-shadow 0.2s;
        }

        .card-item:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .card-info {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .card-icon {
            font-size: 2em;
            color: #6c5ce7;
        }

        .card-details h4 {
            margin: 0 0 5px 0;
            font-size: 1.1em;
            color: #333;
        }

        .card-details p {
            margin: 3px 0;
            color: #666;
            font-size: 0.9em;
        }

        .expiry-date {
            font-size: 0.85em;
            color: #888;
        }

        .default-badge {
            display: inline-block;
            background: #4caf50;
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.75em;
            font-weight: 600;
            margin-top: 5px;
        }

        .card-actions {
            display: flex;
            gap: 10px;
        }

        .btn-card {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.9em;
            font-weight: 500;
            transition: all 0.2s;
        }

        .btn-default {
            background: #2196f3;
            color: white;
        }

        .btn-default:hover {
            background: #1976d2;
        }

        .btn-delete {
            background: #f44336;
            color: white;
        }

        .btn-delete:hover {
            background: #d32f2f;
        }

        .add-card-form {
            margin-top: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }

        .add-card-form h3 {
            margin-bottom: 20px;
            color: #333;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 15px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            margin-bottom: 6px;
            color: #555;
            font-weight: 500;
            font-size: 0.9em;
        }

        .form-group input,
        .form-group select {
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.95em;
            transition: border-color 0.2s;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #6c5ce7;
        }

        .form-group input[type="checkbox"] {
            width: auto;
            margin-right: 8px;
        }

        .btn-primary {
            background: #6c5ce7;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1em;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: background 0.2s;
            margin-top: 10px;
        }

        .btn-primary:hover {
            background: #554bd3;
        }

        .message {
            padding: 12px 16px;
            margin-bottom: 20px;
            border-radius: 6px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .message.success {
            background: #e8f5e8;
            color: #2e7d32;
        }

        .message.error {
            background: #ffebee;
            color: #c62828;
        }

        .empty {
            text-align: center;
            color: #666;
            margin: 20px 0;
            padding: 40px 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }

        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }

            .card-item {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }

            .card-actions {
                width: 100%;
                justify-content: flex-end;
            }
        }
    </style>
</head>
<body>
<!-- Floating Background -->
<div class="floating-bg">
    <div class="floating-circle circle-1"></div>
    <div class="floating-circle circle-2"></div>
    <div class="floating-circle circle-3"></div>
</div>

<!-- Modern Header -->
<header class="modern-header">
    <div class="header-container">
        <div class="logo">
            <a href="index.jsp">
                <i class="fas fa-atom" style="color: #6c5ce7; font-size: 1.5em;"></i>
                <span class="logo-text">NexusShop</span>
            </a>
        </div>

        <div class="search-bar">
            <form action="products" method="get">
                <input type="text" name="search" placeholder="Search products..." value="${param.search}" />
                <button type="submit"><i class="fas fa-search"></i></button>
            </form>
        </div>

        <nav class="main-nav">
            <ul class="nav-list">
                <li><a href="index.jsp">Home</a></li>
                <li><a href="products">Shop</a></li>
                <li><a href="about.jsp">About</a></li>
            </ul>
        </nav>

        <div class="user-actions">
            <div class="action-item user-profile">
                <i class="fas fa-user-circle"></i>
                <span class="username"><%= user.getFullName().split(" ")[0] %></span>
                <div class="dropdown-menu">
                    <a href="myaccount.jsp">My Account</a>
                    <a href="logout" onclick="return confirm('Are you sure you want to logout?')">Logout</a>
                </div>
            </div>
            <a href="wishlist.jsp" class="action-link">
                <i class="far fa-heart"></i>
                <span>Wishlist</span>
            </a>
            <a href="cart/view" class="action-link">
                <i class="fas fa-shopping-cart"></i>
                <span>Cart</span>
                <span class="cart-count">0</span>
            </a>
        </div>
    </div>
</header>

<!-- Dashboard Content -->
<section class="dashboard">
    <div class="dashboard-container">
        <div class="dashboard-header">
            <h1 class="dashboard-title"><i class="fas fa-user-circle"></i> My Account</h1>
            <p class="dashboard-subtitle">Manage your profile, orders, and preferences</p>
        </div>

        <% if (finalMessage != null) { %>
        <div class="message <%= finalMessageType %>">
            <i class="fas fa-<%= "success".equals(finalMessageType) ? "check-circle" : "exclamation-circle" %>"></i>
            <span><%= finalMessage %></span>
        </div>
        <% } %>

        <div class="dashboard-grid">
            <!-- Profile Section -->
            <div class="profile-section">
                <h2>Account Information</h2>
                <div class="profile-info">
                    <p><strong>Name:</strong> <%= user.getFullName() %></p>
                    <p><strong>Email:</strong> <%= user.getEmail() %></p>
                    <p><strong>Role:</strong> <%= user.getRole() %></p>
                </div>

                <!-- Update Name Form -->
                <form class="update-form" method="post">
                    <input type="hidden" name="action" value="updateName">
                    <label for="newName">Update Name:</label>
                    <input type="text" id="newName" name="newName" value="<%= user.getFullName() %>" required>
                    <button type="submit" class="btn"><i class="fas fa-edit"></i> Update Name</button>
                </form>

                <!-- Update Password Form -->
                <form class="update-form" method="post" onsubmit="return validatePassword()">
                    <input type="hidden" name="action" value="updatePassword">
                    <label for="newPassword">New Password:</label>
                    <input type="password" id="newPassword" name="newPassword" required>
                    <label for="confirmPassword">Confirm Password:</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required>
                    <button type="submit" class="btn"><i class="fas fa-lock"></i> Update Password</button>
                </form>

                <a href="my-tickets.jsp" class="logout-btn"><i class="fas fa-ticket-alt"></i> My Tickets</a>
            </div>

            <!-- Orders Section -->
            <div class="orders-section">
                <h2>My Orders</h2>
                <%
                    java.util.List<?> orders = (java.util.List<?>) request.getAttribute("orders");
                    if (orders == null || orders.isEmpty()) {
                %>
                <p class="empty">You haven't placed any orders yet.</p>
                <%
                } else {
                %>
                <table class="orders-table">
                    <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Date</th>
                        <th>Total</th>
                        <th>Status</th>
                    </tr>
                    </thead>
                    <tbody>
                    <!-- Loop orders here when implemented -->
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>

        <!-- Payment Cards Section -->
        <div class="cards-section">
            <h2><i class="fas fa-credit-card"></i> Payment Cards</h2>

            <%
                // Load user's cards from request attribute (set by CardServlet)
                java.util.List<PaymentCard> userCards =
                        (java.util.List<PaymentCard>) request.getAttribute("userCards");
                if (userCards == null) {
                    // Fallback: load directly if not set by servlet
                    PaymentCardService cardService = new PaymentCardService();
                    try {
                        userCards = cardService.getCardsByCustomer(user.getUserId());
                    } catch (Exception e) {
                        userCards = new java.util.ArrayList<>();
                        e.printStackTrace();
                    }
                }
            %>

            <!-- Existing Cards -->
            <% if (!userCards.isEmpty()) { %>
            <% for (PaymentCard card : userCards) { %>
            <div class="card-item">
                <div class="card-info">
                    <div class="card-icon">
                        <i class="fab fa-cc-visa"></i>
                    </div>
                    <div class="card-details">
                        <h4><%= card.getCardNumberMasked() %></h4>
                        <p><%= card.getCardHolderName() %> • <%= card.getCardType() %></p>
                        <p class="expiry-date">Expires: <%= card.getExpiryMonth() %>/<%= card.getExpiryYear() %></p>
                        <% if (card.isDefault()) { %>
                        <span class="default-badge">Default Card</span>
                        <% } %>
                    </div>
                </div>
                <div class="card-actions">
                    <% if (!card.isDefault()) { %>
                    <form method="post" style="display:inline;" action="cards">
                        <input type="hidden" name="action" value="setDefault">
                        <input type="hidden" name="cardNumber" value="<%= card.getCardNumber() %>">
                        <button type="submit" class="btn-card btn-default">Set Default</button>
                    </form>
                    <% } %>
                    <form method="post" style="display:inline;" action="cards"
                          onsubmit="return confirm('Delete this card?')">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="cardNumber" value="<%= card.getCardNumber() %>">
                        <button type="submit" class="btn-card btn-delete">Delete</button>
                    </form>
                </div>
            </div>
            <% } %>
            <% } else { %>
            <p class="empty">No payment cards added yet.</p>
            <% } %>

            <!-- Add New Card Form -->
            <div class="add-card-form">
                <h3><i class="fas fa-plus"></i> Add New Card</h3>
                <form method="post" action="cards" onsubmit="return validateCardForm()">
                    <input type="hidden" name="action" value="add">

                    <div class="form-row">
                        <div class="form-group">
                            <label for="cardNumber">Card Number *</label>
                            <input type="text" id="cardNumber" name="cardNumber" required
                                   placeholder="1234 5678 9012 3456" maxlength="19">
                        </div>

                        <div class="form-group">
                            <label for="cardHolderName">Cardholder Name *</label>
                            <input type="text" id="cardHolderName" name="cardHolderName" required
                                   placeholder="John Doe">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="cardType">Card Type *</label>
                            <select id="cardType" name="cardType" required>
                                <option value="">Select Card Type</option>
                                <option value="Visa">Visa</option>
                                <option value="Mastercard">Mastercard</option>
                                <option value="American Express">American Express</option>
                                <option value="Discover">Discover</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="cvv">CVV *</label>
                            <input type="text" id="cvv" name="cvv" required
                                   placeholder="123" maxlength="4">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="expiryMonth">Expiry Month *</label>
                            <select id="expiryMonth" name="expiryMonth" required>
                                <option value="">Month</option>
                                <% for (int i = 1; i <= 12; i++) { %>
                                <option value="<%= i %>"><%= String.format("%02d", i) %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="expiryYear">Expiry Year *</label>
                            <select id="expiryYear" name="expiryYear" required>
                                <option value="">Year</option>
                                <% int currentYear = java.time.Year.now().getValue(); %>
                                <% for (int i = currentYear; i <= currentYear + 20; i++) { %>
                                <option value="<%= i %>"><%= i %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="billingAddress">Billing Address (Optional)</label>
                        <input type="text" id="billingAddress" name="billingAddress"
                               placeholder="123 Main St, City, Country">
                    </div>

                    <div class="form-group" style="flex-direction: row; align-items: center;">
                        <input type="checkbox" id="isDefault" name="isDefault" value="on">
                        <label for="isDefault" style="margin-bottom: 0;">Set as default payment method</label>
                    </div>

                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Add Card
                    </button>
                </form>
            </div>
        </div>
    </div>
</section>

<!-- Footer -->
<footer class="site-footer">
    <div class="footer-container">
        <div class="footer-grid">
            <div class="footer-col">
                <div class="logo">
                    <a href="${pageContext.request.contextPath}/index.jsp">
                        <span class="logo-icon"><i class="fas fa-atom"></i></span>
                        <span class="logo-text">NexusShop</span>
                    </a>
                </div>
                <p class="footer-about">Your go-to destination for cutting-edge technology and electronics.</p>
                <div class="social-links">
                    <a href="#" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
                    <a href="#" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                    <a href="#" aria-label="YouTube"><i class="fab fa-youtube"></i></a>
                </div>
            </div>
            <div class="footer-col">
                <h3>Shop</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/products">All Products</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?filter=new">New Arrivals</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?filter=featured">Featured</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?filter=deals">Deals</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h3>Support</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/contact">Contact Us</a></li>
                    <li><a href="${pageContext.request.contextPath}/faq.jsp">FAQs</a></li>
                    <li><a href="${pageContext.request.contextPath}/shipping.jsp">Shipping</a></li>
                    <li><a href="${pageContext.request.contextPath}/returns.jsp">Returns</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h3>Company</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/about.jsp">About Us</a></li>
                    <li><a href="${pageContext.request.contextPath}/careers.jsp">Careers</a></li>
                    <li><a href="${pageContext.request.contextPath}/privacy.jsp">Privacy Policy</a></li>
                    <li><a href="${pageContext.request.contextPath}/terms.jsp">Terms of Service</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2025 NexusShop. All rights reserved.</p>
            <div class="payment-methods">
                <i class="fab fa-cc-visa" aria-label="Visa"></i>
                <i class="fab fa-cc-mastercard" aria-label="Mastercard"></i>
                <i class="fab fa-cc-paypal" aria-label="PayPal"></i>
                <i class="fab fa-cc-apple-pay" aria-label="Apple Pay"></i>
            </div>
        </div>
    </div>
</footer>

<script>
    function validatePassword() {
        const pass = document.getElementById('newPassword').value;
        const confirm = document.getElementById('confirmPassword').value;
        if (pass !== confirm) {
            alert('Passwords do not match!');
            return false;
        }
        return true;
    }

    function validateCardForm() {
        const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
        const cvv = document.getElementById('cvv').value;

        // Validate card number format (basic check)
        if (!/^\d{16}$/.test(cardNumber)) {
            alert('Please enter a valid 16-digit card number.');
            return false;
        }

        // Validate CVV
        if (!/^\d{3,4}$/.test(cvv)) {
            alert('Please enter a valid CVV (3-4 digits).');
            return false;
        }

        // Validate expiry date (not expired)
        const month = parseInt(document.getElementById('expiryMonth').value);
        const year = parseInt(document.getElementById('expiryYear').value);
        const currentDate = new Date();
        const currentMonth = currentDate.getMonth() + 1;
        const currentYear = currentDate.getFullYear();

        if (year < currentYear || (year === currentYear && month < currentMonth)) {
            alert('Card expiry date cannot be in the past.');
            return false;
        }

        return true;
    }

    // Format card number as user types
    document.getElementById('cardNumber').addEventListener('input', function(e) {
        let value = e.target.value.replace(/\D/g, '');
        if (value.length > 16) value = value.substring(0, 16);
        value = value.replace(/(\d{4})/g, '$1 ').trim();
        e.target.value = value;
    });
</script>
</body>
</html>