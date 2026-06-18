<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - NexusShop</title>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <!-- CSS -->
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/admin.css">
    <style>
        /* Role Badges */
        .role-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
        }
        .role-admin { background: #e3f2fd; color: #1976d2; }
        .role-product_manager { background: #fff3e0; color: #f57c00; }
        .role-supplier { background: #f3e5f5; color: #7b1fa2; }
        .role-customer_service { background: #e8f5e8; color: #2e7d32; }
        .role-delivery_person { background: #ffebee; color: #c62828; }
        .role-customer { background: #f1f8e9; color: #388e3c; }

        /* Status Badges */
        .status-badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: 500;
        }
        .status-active { background: #e8f5e8; color: #2e7d32; }
        .status-pending { background: #fff3e0; color: #f57c00; }
        .status-confirmed { background: #e3f2fd; color: #1976d2; }
        .status-processing { background: #fff8e1; color: #ffa000; }
        .status-shipped { background: #e8f5e8; color: #2e7d32; }
        .status-delivered { background: #f1f8e9; color: #388e3c; }
        .status-cancelled { background: #ffebee; color: #c62828; }
        .status-paid { background: #e8f5e8; color: #2e7d32; }
        .status-failed { background: #ffebee; color: #c62828; }

        .no-action { color: #999; }
        .user-info .user-name { font-weight: 600; }
        .user-info .user-email { font-size: 0.85em; color: #666; margin-top: 2px; }

        /* Status Select Dropdown */
        .status-select {
            padding: 4px 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 0.85em;
            background: white;
            cursor: pointer;
        }

        .status-select:focus {
            outline: none;
            border-color: #007bff;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }

        .empty-state i {
            margin-bottom: 15px;
            opacity: 0.5;
        }

        .empty-state h3 {
            margin: 10px 0;
            font-weight: 600;
        }

        .empty-state p {
            margin: 0;
            font-size: 0.9em;
        }

        /* Order Table Enhancements */
        .order-row:hover {
            background-color: #f8f9fa;
        }

        .text-muted {
            color: #6c757d !important;
        }

        .text-center {
            text-align: center;
        }

        /* Dashboard Stats */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-left: 4px solid #007bff;
        }

        .stat-card.total-orders { border-left-color: #007bff; }
        .stat-card.pending-orders { border-left-color: #ffc107; }
        .stat-card.revenue { border-left-color: #28a745; }
        .stat-card.customers { border-left-color: #6f42c1; }

        .stat-icon {
            font-size: 2.5em;
            margin-bottom: 15px;
            opacity: 0.8;
        }

        .stat-number {
            font-size: 2em;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #666;
            font-size: 0.9em;
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
                <li class="nav-item"><a href="admin" class="nav-link active">Admin</a></li>
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
                        <a href="logout" class="action-link" onclick="return confirm('Are you sure you want to logout?')">
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

<!-- Admin Dashboard Content -->
<div class="admin-container">
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1 class="section-title">
                <i class="fas fa-crown"></i> Admin Dashboard
            </h1>
            <p class="page-subtitle">Manage your store, orders, and users</p>
        </div>

        <!-- Notifications -->
        <c:if test="${not empty sessionScope.message}">
            <div class="notification success">
                <div class="notification-content">
                    <i class="fas fa-check-circle"></i>
                    <span>${sessionScope.message}</span>
                </div>
                <button class="notification-close" onclick="this.parentElement.style.display='none'">
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
                <button class="notification-close" onclick="this.parentElement.style.display='none'">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        </c:if>

        <!-- Dashboard Statistics -->
        <div class="stats-grid">
            <div class="stat-card total-orders">
                <div class="stat-icon">
                    <i class="fas fa-shopping-cart"></i>
                </div>
                <div class="stat-number">${totalOrders}</div>
                <div class="stat-label">Total Orders</div>
            </div>
            <div class="stat-card pending-orders">
                <div class="stat-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-number">${pendingOrders}</div>
                <div class="stat-label">Pending Orders</div>
            </div>
            <div class="stat-card revenue">
                <div class="stat-icon">
                    <i class="fas fa-dollar-sign"></i>
                </div>
                <div class="stat-number">$<fmt:formatNumber value="${totalRevenue}" pattern="#,##0.00"/></div>
                <div class="stat-label">Total Revenue</div>
            </div>
            <div class="stat-card customers">
                <div class="stat-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-number">${totalCustomers}</div>
                <div class="stat-label">Total Customers</div>
            </div>
        </div>

        <!-- Orders Management Section -->
        <div class="admin-section">
            <div class="section-header">
                <h2 class="section-title">Orders Management</h2>
                <div class="section-actions">
                    <form method="get" style="display:inline;">
                        <input type="hidden" name="action" value="refreshOrders">
                        <button type="submit" class="btn btn-secondary">
                            <i class="fas fa-sync-alt"></i> Refresh Orders
                        </button>
                    </form>
                </div>
            </div>

            <!-- Order Status Tabs -->
            <div class="role-tabs">
                <button class="role-tab active" data-order-status="all">All Orders</button>
                <button class="role-tab" data-order-status="PENDING">Pending</button>
                <button class="role-tab" data-order-status="CONFIRMED">Confirmed</button>
                <button class="role-tab" data-order-status="PROCESSING">Processing</button>
                <button class="role-tab" data-order-status="SHIPPED">Shipped</button>
                <button class="role-tab" data-order-status="DELIVERED">Delivered</button>
                <button class="role-tab" data-order-status="CANCELLED">Cancelled</button>
            </div>

            <!-- Orders Table -->
            <div class="table-container">
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Customer</th>
                        <th>Date</th>
                        <th>Items</th>
                        <th>Total Amount</th>
                        <th>Status</th>
                        <th>Payment</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        java.util.List<com.nexusshope.model.Order> orders =
                                (java.util.List<com.nexusshope.model.Order>) request.getAttribute("orders");
                        if (orders != null && !orders.isEmpty()) {
                            for (com.nexusshope.model.Order order : orders) {
                    %>
                    <tr class="order-row" data-order-status="<%= order.getStatus() %>">
                        <td>
                            <strong><%= order.getOrderID() %></strong>
                            <% if (order.getTransactionID() != null) { %>
                            <br><small class="text-muted">TXN: <%= order.getTransactionID() %></small>
                            <% } %>
                        </td>
                        <td>
                            <div class="user-info">
                                <div class="user-name"><%= order.getCustomerID() %></div>
                                <div class="user-email">
                                    <%= order.getShippingAddress().length() > 30 ?
                                            order.getShippingAddress().substring(0, 30) + "..." :
                                            order.getShippingAddress() %>
                                </div>
                            </div>
                        </td>
                        <td>
                            <fmt:formatDate value="<%= order.getOrderDate() %>" pattern="MMM dd, yyyy HH:mm"/>
                        </td>
                        <td>
                            <%= order.getItems() != null ? order.getItems().size() : 0 %> items
                        </td>
                        <td>
                            <strong>$<fmt:formatNumber value="<%= order.getFinalAmount() %>" pattern="#,##0.00"/></strong>
                        </td>
                        <td>
                            <%
                                String status = order.getStatus();
                                String statusClass = "";
                                String statusIcon = "";

                                switch(status) {
                                    case "PENDING":
                                        statusClass = "status-pending";
                                        statusIcon = "fas fa-clock";
                                        break;
                                    case "CONFIRMED":
                                        statusClass = "status-confirmed";
                                        statusIcon = "fas fa-check-circle";
                                        break;
                                    case "PROCESSING":
                                        statusClass = "status-processing";
                                        statusIcon = "fas fa-cog";
                                        break;
                                    case "SHIPPED":
                                        statusClass = "status-shipped";
                                        statusIcon = "fas fa-shipping-fast";
                                        break;
                                    case "DELIVERED":
                                        statusClass = "status-delivered";
                                        statusIcon = "fas fa-box-open";
                                        break;
                                    case "CANCELLED":
                                        statusClass = "status-cancelled";
                                        statusIcon = "fas fa-times-circle";
                                        break;
                                    default:
                                        statusClass = "status-pending";
                                        statusIcon = "fas fa-question-circle";
                                }
                            %>
                            <span class="status-badge <%= statusClass %>">
                                <i class="<%= statusIcon %>"></i> <%= status %>
                            </span>
                        </td>
                        <td>
                            <%
                                String paymentStatus = order.getPaymentStatus();
                                String paymentClass = "";
                                String paymentIcon = "";

                                if ("PAID".equals(paymentStatus)) {
                                    paymentClass = "status-paid";
                                    paymentIcon = "fas fa-check-circle";
                                } else if ("PENDING".equals(paymentStatus)) {
                                    paymentClass = "status-pending";
                                    paymentIcon = "fas fa-clock";
                                } else if ("FAILED".equals(paymentStatus)) {
                                    paymentClass = "status-failed";
                                    paymentIcon = "fas fa-exclamation-circle";
                                } else {
                                    paymentClass = "status-pending";
                                    paymentIcon = "fas fa-question-circle";
                                }
                            %>
                            <span class="status-badge <%= paymentClass %>">
                                <i class="<%= paymentIcon %>"></i> <%= paymentStatus %>
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <!-- View Order Details -->
                                <form method="post" style="display:inline;" action="admin">
                                    <input type="hidden" name="action" value="viewOrder">
                                    <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                    <button type="submit" class="btn btn-info btn-sm">
                                        <i class="fas fa-eye"></i> View
                                    </button>
                                </form>

                                <!-- Update Status -->
                                <% if (!"DELIVERED".equals(status) && !"CANCELLED".equals(status)) { %>
                                <form method="post" style="display:inline;" action="admin">
                                    <input type="hidden" name="action" value="updateOrderStatus">
                                    <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                    <select name="newStatus" onchange="this.form.submit()" class="status-select">
                                        <option value="">Update Status</option>
                                        <option value="CONFIRMED" <%= "CONFIRMED".equals(status) ? "selected" : "" %>>Confirm</option>
                                        <option value="PROCESSING" <%= "PROCESSING".equals(status) ? "selected" : "" %>>Process</option>
                                        <option value="SHIPPED" <%= "SHIPPED".equals(status) ? "selected" : "" %>>Ship</option>
                                        <option value="DELIVERED" <%= "DELIVERED".equals(status) ? "selected" : "" %>>Deliver</option>
                                        <option value="CANCELLED">Cancel</option>
                                    </select>
                                </form>
                                <% } else { %>
                                <span class="no-action">Completed</span>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="8" class="text-center">
                            <div class="empty-state">
                                <i class="fas fa-shopping-cart fa-3x"></i>
                                <h3>No Orders Found</h3>
                                <p>There are no orders in the system yet.</p>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Users Management Section -->
        <div class="admin-section">
            <div class="section-header">
                <h2 class="section-title">Users Management</h2>
                <div class="section-actions">
                    <form method="get" style="display:inline;">
                        <button type="submit" class="btn btn-secondary">
                            <i class="fas fa-sync-alt"></i> Refresh
                        </button>
                    </form>
                </div>
            </div>

            <!-- Role Tabs -->
            <div class="role-tabs">
                <button class="role-tab active" data-role="all">All Users</button>
                <button class="role-tab" data-role="admin">Admins</button>
                <button class="role-tab" data-role="product_manager">Product Managers</button>
                <button class="role-tab" data-role="supplier">Suppliers</button>
                <button class="role-tab" data-role="customer_service">Customer Service</button>
                <button class="role-tab" data-role="delivery_person">Delivery Persons</button>
                <button class="role-tab" data-role="customer">Customers</button>
            </div>

            <!-- Users Table -->
            <div class="table-container">
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        java.util.List<com.nexusshope.model.User> users =
                                (java.util.List<com.nexusshope.model.User>) request.getAttribute("users");
                        if (users != null) {
                            for (com.nexusshope.model.User user : users) {
                    %>
                    <tr class="user-row" data-role="<%= user.getRole() %>">
                        <td><%= user.getUserId() %></td>
                        <td>
                            <div class="user-info">
                                <div class="user-name"><%= user.getFullName() %></div>
                            </div>
                        </td>
                        <td><%= user.getEmail() %></td>
                        <td>
            <span class="role-badge role-<%= user.getRole() %>">
                <% if ("admin".equals(user.getRole())) { %>
                    <i class="fas fa-crown"></i> Admin
                <% } else if ("product_manager".equals(user.getRole())) { %>
                    <i class="fas fa-box"></i> Product Manager
                <% } else if ("supplier".equals(user.getRole())) { %>
                    <i class="fas fa-truck"></i> Supplier
                <% } else if ("customer_service".equals(user.getRole())) { %>
                    <i class="fas fa-headset"></i> Customer Service
                <% } else if ("delivery_person".equals(user.getRole())) { %>
                    <i class="fas fa-shipping-fast"></i> Delivery Person
                <% } else { %>
                    <i class="fas fa-user"></i> Customer
                <% } %>
            </span>
                        </td>
                        <td><span class="status-badge status-active">Active</span></td>
                        <td>
                            <div class="action-buttons">
                                <% if (!"admin".equals(user.getRole())) { %>
                                <!-- Edit Button -->
                                <form method="post" style="display:inline;" action="admin">
                                    <input type="hidden" name="action" value="editUserForm">
                                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                    <button type="submit" class="btn btn-warning btn-sm">
                                        <i class="fas fa-edit"></i> Edit
                                    </button>
                                </form>
                                <form method="post" style="display:inline;"
                                      onsubmit="return confirm('Delete user?');">
                                    <input type="hidden" name="action" value="deleteUser">
                                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                    <button type="submit" class="btn btn-danger btn-sm">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </form>
                                <% } else { %>
                                <span class="no-action">—</span>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="admin-section">
            <h2 class="section-title">Quick Actions</h2>
            <div class="quick-actions-grid">
                <a href="product_manager" class="quick-action-card">
                    <div class="quick-action-icon"><i class="fas fa-boxes"></i></div>
                    <h3>Product Manager</h3>
                    <p>Manage products and inventory</p>
                </a>

                <a href="admin/faq" class="quick-action-card">
                    <div class="quick-action-icon">
                        <i class="fas fa-question-circle"></i>
                    </div>
                    <h3>FAQ Manager</h3>
                    <p>Manage frequently asked questions</p>
                </a>

                <a href="admin?action=reports" class="quick-action-card">
                    <div class="quick-action-icon"><i class="fas fa-chart-bar"></i></div>
                    <h3>Reports</h3>
                    <p>View analytics and sales</p>
                </a>
                <a href="admin?action=settings" class="quick-action-card">
                    <div class="quick-action-icon"><i class="fas fa-cog"></i></div>
                    <h3>Settings</h3>
                    <p>Store configuration</p>
                </a>
                <a href="index.jsp" class="quick-action-card">
                    <div class="quick-action-icon"><i class="fas fa-store"></i></div>
                    <h3>Back to Shop</h3>
                    <p>Return to storefront</p>
                </a>
            </div>
        </div>
    </div>
</div>

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
                <p>Your premier destination for cutting-edge technology.</p>
            </div>
            <div class="footer-col">
                <h3>Admin</h3>
                <ul>
                    <li><a href="admin">Dashboard</a></li>
                    <li><a href="product_manager">Product Manager</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h3>Help</h3>
                <ul>
                    <li><a href="contact">Contact Us</a></li>
                    <li><a href="faq">FAQs</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h3>Legal</h3>
                <ul>
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

<script>
    // Role filtering
    document.querySelectorAll('.role-tab').forEach(tab => {
        tab.addEventListener('click', () => {
            document.querySelectorAll('.role-tab').forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            const role = tab.dataset.role;
            document.querySelectorAll('.user-row').forEach(row => {
                row.style.display = (role === 'all' || row.dataset.role === role) ? '' : 'none';
            });
        });
    });

    // Order status filtering
    document.querySelectorAll('[data-order-status]').forEach(tab => {
        tab.addEventListener('click', () => {
            document.querySelectorAll('[data-order-status]').forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            const status = tab.dataset.orderStatus;
            document.querySelectorAll('.order-row').forEach(row => {
                row.style.display = (status === 'all' || row.dataset.orderStatus === status) ? '' : 'none';
            });
        });
    });

    // Auto-hide notifications
    setTimeout(() => {
        const notifs = document.querySelectorAll('.notification');
        notifs.forEach(n => n.style.display = 'none');
    }, 5000);
</script>
</body>
</html>
