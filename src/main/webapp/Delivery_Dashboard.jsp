<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Dashboard - NexusShop</title>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <!-- CSS -->
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/admin.css">
    <style>
        .delivery-dashboard {
            padding: 2rem 0;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .summary-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-left: 4px solid;
        }

        .summary-card.info { border-left-color: #17a2b8; }
        .summary-card.warning { border-left-color: #ffc107; }
        .summary-card.primary { border-left-color: #007bff; }
        .summary-card.success { border-left-color: #28a745; }

        .summary-icon {
            font-size: 2.5em;
            margin-bottom: 15px;
            opacity: 0.8;
        }

        .summary-card.info .summary-icon { color: #17a2b8; }
        .summary-card.warning .summary-icon { color: #ffc107; }
        .summary-card.primary .summary-icon { color: #007bff; }
        .summary-card.success .summary-icon { color: #28a745; }

        .summary-content h3 {
            margin: 0 0 10px 0;
            font-size: 1em;
            color: #666;
        }

        .summary-value {
            font-size: 2em;
            font-weight: 700;
        }

        .orders-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 20px;
        }

        .order-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 20px;
            border-left: 4px solid;
        }

        .order-card.pending { border-left-color: #ffc107; }
        .order-card.processing { border-left-color: #17a2b8; }
        .order-card.shipped { border-left-color: #007bff; }
        .order-card.delivered { border-left-color: #28a745; }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }

        .order-info h3 {
            margin: 0 0 5px 0;
            color: #333;
        }

        .order-meta {
            display: flex;
            gap: 15px;
            font-size: 0.85em;
            color: #666;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .status-badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: 500;
        }

        .status-pending { background: #fff3e0; color: #f57c00; }
        .status-processing { background: #e3f2fd; color: #1976d2; }
        .status-shipped { background: #e8f5e8; color: #2e7d32; }
        .status-delivered { background: #f1f8e9; color: #388e3c; }

        .order-details {
            margin-bottom: 20px;
        }

        .detail-item {
            margin-bottom: 10px;
        }

        .detail-item h4 {
            margin: 0 0 5px 0;
            font-size: 0.9em;
            color: #666;
        }

        .detail-item p {
            margin: 0;
            font-weight: 500;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .action-form {
            display: inline;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }

        .empty-state i {
            font-size: 4em;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        .empty-state h3 {
            margin: 0 0 10px 0;
            font-weight: 600;
        }

        .empty-state p {
            margin: 0;
            font-size: 1em;
        }
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
                <li class="nav-item"><a href="delivery" class="nav-link active">Delivery Dashboard</a></li>
            </ul>
        </nav>

        <!-- User Actions -->
        <div class="user-actions">
            <c:choose>
                <c:when test="${empty sessionScope.user}">
                    <div class="action-item">
                        <a href="login.jsp" class="action-link">
                            <i class="far fa-user"></i>
                            <span class="action-text">Login</span>
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="action-item">
                        <span class="action-text">Welcome, ${sessionScope.user.fullName}</span>
                    </div>
                    <div class="action-item">
                        <a href="logout" class="action-link">
                            <i class="fas fa-sign-out-alt"></i>
                            <span class="action-text">Logout</span>
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Mobile Menu Button -->
        <div class="mobile-menu-btn">
            <i class="fas fa-bars"></i>
        </div>
    </div>
</header>

<!-- Delivery Dashboard Content -->
<div class="delivery-dashboard">
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="section-title">
                <i class="fas fa-truck"></i> Delivery Dashboard
            </h1>
            <p class="section-subtitle">Manage your delivery assignments and track order status</p>
        </div>

        <!-- Notifications -->
        <c:if test="${not empty sessionScope.message}">
            <div class="notification success">
                <div class="notification-content">
                    <i class="fas fa-check-circle"></i>
                    <span>${sessionScope.message}</span>
                </div>
                <button class="notification-close">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <c:remove var="message" scope="session"/>
        </c:if>
        <c:if test="${not empty error}">
            <div class="notification error">
                <div class="notification-content">
                    <i class="fas fa-exclamation-circle"></i>
                    <span>${error}</span>
                </div>
                <button class="notification-close">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        </c:if>

        <!-- Refresh Button -->
        <div class="refresh-section" style="margin-bottom: 20px;">
            <form method="get" action="${pageContext.request.contextPath}/delivery" style="display: inline;">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-sync-alt"></i> Refresh Dashboard
                </button>
            </form>
        </div>



        <!-- Summary Cards -->
        <div class="summary-grid">
            <div class="summary-card info">
                <div class="summary-icon">
                    <i class="fas fa-clipboard-list"></i>
                </div>
                <div class="summary-content">
                    <h3>Total Assigned</h3>
                    <div class="summary-value">${totalOrders}</div>
                </div>
            </div>

            <div class="summary-card warning">
                <div class="summary-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="summary-content">
                    <h3>Pending Delivery</h3>
                    <div class="summary-value">${pendingOrders}</div>
                </div>
            </div>

            <div class="summary-card primary">
                <div class="summary-icon">
                    <i class="fas fa-shipping-fast"></i>
                </div>
                <div class="summary-content">
                    <h3>Out for Delivery</h3>
                    <div class="summary-value">${shippedOrders}</div>
                </div>
            </div>

            <div class="summary-card success">
                <div class="summary-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="summary-content">
                    <h3>Delivered Today</h3>
                    <div class="summary-value">${deliveredOrders}</div>
                </div>
            </div>
        </div>

        <!-- Orders Section -->
        <c:choose>
            <c:when test="${empty orders}">
                <div class="empty-state">
                    <i class="fas fa-clipboard-check"></i>
                    <h3>No Delivery Assignments</h3>
                    <p>You don't have any orders assigned for delivery at the moment.</p>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary" style="margin-top: 1.5rem;">
                        <i class="fas fa-store"></i> Back to Shop
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="orders-grid">
                    <c:forEach var="order" items="${orders}">
                        <div class="order-card
                            <c:choose>
                                <c:when test="${order.status == 'CONFIRMED'}">pending</c:when>
                                <c:when test="${order.status == 'PROCESSING'}">processing</c:when>
                                <c:when test="${order.status == 'SHIPPED'}">shipped</c:when>
                                <c:when test="${order.status == 'DELIVERED'}">delivered</c:when>
                            </c:choose>">

                            <div class="order-header">
                                <div class="order-info">
                                    <h3>Order #${order.orderID}</h3>
                                    <div class="order-meta">
                                        <div class="meta-item">
                                            <i class="fas fa-calendar"></i>
                                            <fmt:formatDate value="${order.orderDate}" pattern="MMM dd, yyyy HH:mm" />
                                        </div>
                                        <div class="meta-item">
                                            <i class="fas fa-dollar-sign"></i>
                                            $<fmt:formatNumber value="${order.finalAmount}" pattern="#,##0.00"/>
                                        </div>
                                    </div>
                                </div>
                                <span class="status-badge
                                    <c:choose>
                                        <c:when test="${order.status == 'CONFIRMED'}">status-pending</c:when>
                                        <c:when test="${order.status == 'PROCESSING'}">status-processing</c:when>
                                        <c:when test="${order.status == 'SHIPPED'}">status-shipped</c:when>
                                        <c:when test="${order.status == 'DELIVERED'}">status-delivered</c:when>
                                    </c:choose>">
                                        ${order.status}
                                </span>
                            </div>

                            <div class="order-details">
                                <div class="detail-item">
                                    <h4>Customer ID</h4>
                                    <p>${order.customerID}</p>
                                </div>
                                <div class="detail-item">
                                    <h4>Items</h4>
                                    <p>${order.items.size()} items</p>
                                </div>
                                <div class="detail-item">
                                    <h4>Payment</h4>
                                    <p>${order.paymentStatus}</p>
                                </div>
                                <div class="detail-item">
                                    <h4>Delivery Address</h4>
                                    <p>${order.shippingAddress}</p>
                                </div>
                            </div>

                            <div class="action-buttons">
                                <c:if test="${order.status == 'CONFIRMED'}">
                                    <form action="${pageContext.request.contextPath}/delivery" method="post" class="action-form">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="orderId" value="${order.orderID}">
                                        <input type="hidden" name="newStatus" value="PROCESSING">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-play-circle"></i> Start Processing
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${order.status == 'PROCESSING'}">
                                    <form action="${pageContext.request.contextPath}/delivery" method="post" class="action-form">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="orderId" value="${order.orderID}">
                                        <input type="hidden" name="newStatus" value="SHIPPED">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-shipping-fast"></i> Mark as Shipped
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${order.status == 'SHIPPED'}">
                                    <form action="${pageContext.request.contextPath}/delivery" method="post" class="action-form">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="orderId" value="${order.orderID}">
                                        <input type="hidden" name="newStatus" value="DELIVERED">
                                        <button type="submit" class="btn btn-success">
                                            <i class="fas fa-check-circle"></i> Mark as Delivered
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${order.status == 'DELIVERED'}">
                                    <button class="btn" disabled style="background: #d1fae5; color: #065f46;">
                                        <i class="fas fa-check-double"></i> Delivery Completed
                                    </button>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

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
            </div>

            <div class="footer-col">
                <h3>Delivery</h3>
                <ul>
                    <li><a href="delivery">Dashboard</a></li>
                    <li><a href="${pageContext.request.contextPath}/products">View Products</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Help</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/contact">Contact Us</a></li>
                    <li><a href="faq">FAQs</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Company</h3>
                <ul>
                    <li><a href="about.jsp">About Us</a></li>
                    <li><a href="privacy.jsp">Privacy Policy</a></li>
                    <li><a href="terms.jsp">Terms of Service</a></li>
                </ul>
            </div>
        </div>

        <div class="footer-bottom">
            <p>&copy; 2025 NexusShop. All rights reserved.</p>
        </div>
    </div>
</footer>

<!-- JavaScript -->
<script src="js/main.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Notification close functionality
        const notificationCloseButtons = document.querySelectorAll('.notification-close');
        notificationCloseButtons.forEach(button => {
            button.addEventListener('click', function() {
                this.closest('.notification').style.display = 'none';
            });
        });

        // Auto-hide notifications after 5 seconds
        const notifications = document.querySelectorAll('.notification');
        notifications.forEach(notification => {
            setTimeout(() => {
                notification.style.display = 'none';
            }, 5000);
        });

        // Add confirmation for delivery status updates
        const deliveryForms = document.querySelectorAll('.action-form');
        deliveryForms.forEach(form => {
            form.addEventListener('submit', function(e) {
                const status = this.querySelector('input[name="newStatus"]').value;
                const orderId = this.querySelector('input[name="orderId"]').value;

                let message = '';
                if (status === 'PROCESSING') {
                    message = `Are you sure you want to start processing Order #${orderId}?`;
                } else if (status === 'SHIPPED') {
                    message = `Are you sure you want to mark Order #${orderId} as Shipped?`;
                } else if (status === 'DELIVERED') {
                    message = `Are you sure you want to mark Order #${orderId} as Delivered?`;
                }

                if (message && !confirm(message)) {
                    e.preventDefault();
                }
            });
        });
    });
</script>
</body>
</html>