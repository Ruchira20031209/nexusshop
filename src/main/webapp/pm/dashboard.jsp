<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Product Manager Dashboard | NexusShop</title>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        /* Base Styles & Variables */
        :root {
            --primary: #6c5ce7;
            --primary-light: #a29bfe;
            --primary-dark: #5649c0;
            --secondary: #00cec9;
            --accent: #fd79a8;
            --dark: #2d3436;
            --light: #f5f6fa;
            --gray: #dfe6e9;
            --success: #00b894;
            --warning: #fdcb6e;
            --danger: #d63031;

            --glass-bg: rgba(255, 255, 255, 0.2);
            --glass-border: rgba(255, 255, 255, 0.1);
            --glass-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.15);
            --text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);

            --font-primary: 'Poppins', sans-serif;
            --font-secondary: 'Montserrat', sans-serif;

            --transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: var(--font-primary);
            color: var(--dark);
            background-color: var(--light);
            line-height: 1.6;
            overflow-x: hidden;
            background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
            padding-top: 80px;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        ul {
            list-style: none;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        .section-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 2rem;
            font-family: var(--font-secondary);
            position: relative;
            display: inline-block;
            background: linear-gradient(to right, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .section-title::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 50%;
            height: 4px;
            background: linear-gradient(to right, var(--primary), var(--secondary));
            border-radius: 2px;
        }

        /* Floating Background Elements */
        .floating-bg {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            overflow: hidden;
        }

        .floating-circle {
            position: absolute;
            border-radius: 50%;
            background: linear-gradient(145deg, rgba(108, 92, 231, 0.1), rgba(0, 206, 201, 0.1));
            backdrop-filter: blur(5px);
            -webkit-backdrop-filter: blur(5px);
            z-index: 0;
            filter: brightness(1.2);
            opacity: 0.8;
        }

        .circle-1 {
            width: 300px;
            height: 300px;
            top: -100px;
            left: -100px;
            animation: float 8s ease-in-out infinite, pulse 4s ease-in-out infinite alternate;
            background: radial-gradient(circle, var(--primary-light) 0%, transparent 70%);
        }

        .circle-2 {
            width: 200px;
            height: 200px;
            bottom: 50px;
            right: 100px;
            animation: float 6s ease-in-out infinite reverse, pulse 5s ease-in-out infinite alternate-reverse;
            background: radial-gradient(circle, var(--secondary) 0%, transparent 70%);
        }

        .circle-3 {
            width: 150px;
            height: 150px;
            top: 200px;
            right: 300px;
            animation: float 5s ease-in-out infinite 1s, pulse 3s ease-in-out infinite alternate 1s;
            background: radial-gradient(circle, var(--accent) 0%, transparent 70%);
        }

        .circle-4 {
            width: 250px;
            height: 250px;
            bottom: -50px;
            left: 200px;
            animation: float 7s ease-in-out infinite 0.5s, pulse 4s ease-in-out infinite alternate 0.5s;
            background: radial-gradient(circle, var(--primary) 0%, transparent 70%);
        }

        /* Header Styles */
        .header {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 1000;
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border-bottom: 1px solid var(--glass-border);
            box-shadow: var(--glass-shadow);
            padding: 1rem 0;
            transition: var(--transition);
        }

        .header-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        /* Logo Styles */
        .logo a {
            display: flex;
            align-items: center;
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--primary);
            font-family: var(--font-secondary);
            transition: var(--transition);
        }

        .logo a:hover {
            transform: scale(1.05);
        }

        .logo-icon {
            margin-right: 0.5rem;
            font-size: 2rem;
            color: var(--secondary);
        }

        /* Navigation Styles */
        .main-nav .nav-list {
            display: flex;
        }

        .nav-item {
            margin: 0 1rem;
            position: relative;
        }

        .nav-link {
            font-weight: 500;
            font-size: 1rem;
            padding: 0.5rem 0;
            transition: var(--transition);
            position: relative;
            color: var(--dark);
        }

        .nav-link::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 0;
            height: 2px;
            background: var(--primary);
            transition: var(--transition);
        }

        .nav-link:hover::after {
            width: 100%;
        }

        .nav-link:hover {
            color: var(--primary);
        }

        /* User Actions Styles */
        .user-actions {
            display: flex;
            align-items: center;
        }

        .action-item {
            margin-left: 1.5rem;
            position: relative;
        }

        .action-link {
            display: flex;
            flex-direction: column;
            align-items: center;
            font-size: 0.9rem;
            transition: var(--transition);
            color: var(--dark);
        }

        .action-link i {
            font-size: 1.3rem;
            margin-bottom: 0.2rem;
            transition: var(--transition);
        }

        .action-link:hover {
            color: var(--primary);
            transform: translateY(-3px);
        }

        .action-link:hover i {
            transform: scale(1.2);
        }

        /* PM Dashboard Styles */
        .pm-dashboard {
            padding: 2rem 0;
        }

        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .dashboard-title {
            font-size: 2.5rem;
            font-weight: 700;
            font-family: var(--font-secondary);
            background: linear-gradient(to right, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .dashboard-actions {
            display: flex;
            gap: 1rem;
        }

        .btn {
            position: relative;
            overflow: hidden;
            border: none;
            padding: 0.8rem 1.5rem;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
            box-shadow: 0 10px 30px rgba(108, 92, 231, 0.4);
        }

        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-3px) scale(1.05);
            box-shadow: 0 15px 40px rgba(108, 92, 231, 0.6);
        }

        .btn-secondary {
            border: 2px solid var(--primary);
            color: var(--primary);
            background: transparent;
            transition: all 0.4s ease;
        }

        .btn-secondary:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 4px 15px rgba(108, 92, 231, 0.3);
        }

        /* Stats Section */
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 3rem;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 16px;
            padding: 1.5rem;
            text-align: center;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(0, 0, 0, 0.05);
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(to right, var(--primary), var(--secondary));
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }

        .stat-card:hover::before {
            transform: scaleX(1);
        }

        .stat-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 60px rgba(108, 92, 231, 0.3);
        }

        .stat-card h3 {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: #666;
        }

        .stat-card .count {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--primary);
        }

        .stat-card.pending .count {
            color: var(--warning);
        }

        .stat-card.low-stock .count {
            color: var(--accent);
        }

        .stat-card.out-of-stock .count {
            color: var(--danger);
        }

        /* Table Styles */
        .dashboard-section {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(0, 0, 0, 0.05);
        }

        .dashboard-section h2 {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
            color: var(--dark);
            font-family: var(--font-secondary);
            position: relative;
            display: inline-block;
        }

        .dashboard-section h2::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
            width: 40%;
            height: 3px;
            background: linear-gradient(to right, var(--primary), var(--secondary));
            border-radius: 2px;
        }

        .product-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .product-table th, .product-table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }

        .product-table th {
            background: rgba(108, 92, 231, 0.1);
            font-weight: 600;
            color: var(--primary);
            font-family: var(--font-secondary);
        }

        .product-table tr:hover {
            background: rgba(108, 92, 231, 0.05);
        }

        /* Action Buttons */
        .action-btn {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 6px;
            font-weight: 500;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            text-decoration: none;
        }

        .btn-approve {
            background: var(--success);
            color: white;
        }

        .btn-reject {
            background: var(--danger);
            color: white;
        }

        .btn-edit {
            background: var(--primary);
            color: white;
        }

        .btn-delete {
            background: var(--danger);
            color: white;
        }

        .btn-view {
            background: var(--secondary);
            color: white;
        }

        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        /* Form Styles */
        form {
            display: inline;
        }

        input[type="text"] {
            padding: 0.5rem;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 4px;
            font-family: var(--font-primary);
        }

        /* Messages */
        .success {
            background: var(--success);
            color: white;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .error {
            background: var(--danger);
            color: white;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        /* Animations */
        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(180deg); }
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive Styles */
        @media (max-width: 992px) {
            .main-nav {
                display: none;
            }

            .mobile-menu-btn {
                display: block;
            }

            .stats-cards {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .header-container {
                padding: 0 1rem;
            }

            .logo-text {
                display: none;
            }

            .user-actions .action-text {
                display: none;
            }

            .action-item {
                margin-left: 1rem;
            }

            .dashboard-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }

            .dashboard-actions {
                width: 100%;
                justify-content: flex-start;
            }

            .stats-cards {
                grid-template-columns: 1fr;
            }

            .product-table {
                display: block;
                overflow-x: auto;
            }
        }

        @media (max-width: 480px) {
            .dashboard-section {
                padding: 1rem;
            }

            .product-table th, .product-table td {
                padding: 0.5rem;
            }

            .action-btn {
                padding: 0.3rem 0.6rem;
                font-size: 0.8rem;
            }
        }
    </style>
</head>
<body class="pm-dashboard">
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
            <a href="${pageContext.request.contextPath}/">
                <span class="logo-icon"><i class="fas fa-atom"></i></span>
                <span class="logo-text">NexusShop</span>
            </a>
        </div>

        <!-- Navigation -->
        <nav class="main-nav">
            <ul class="nav-list">
                <li class="nav-item"><a href="${pageContext.request.contextPath}/" class="nav-link">Home</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/products" class="nav-link">Shop</a></li>

                <li class="nav-item"><a href="${pageContext.request.contextPath}/about" class="nav-link">About</a></li>
            </ul>
        </nav>

        <!-- User Actions -->
        <div class="user-actions">
            <div class="action-item">
                <a href="${pageContext.request.contextPath}/myaccount" class="action-link">
                    <i class="far fa-user"></i>
                    <span class="action-text">My Account</span>
                </a>
            </div>
            <div class="action-item">
                <a href="${pageContext.request.contextPath}/logout" class="action-link" onclick="return confirm('Are you sure you want to logout?');">
                    <i class="fas fa-sign-out-alt"></i>
                    <span class="action-text">Logout</span>
                </a>
            </div>
        </div>
    </div>
</header>
<br>
<br>
<div class="container">
    <!-- Dashboard Header -->
    <div class="dashboard-header">
        <h1 class="dashboard-title">Product Manager Dashboard</h1>
        <div class="dashboard-actions">
            <a href="${pageContext.request.contextPath}/pm/add-product" class="btn btn-primary">
                <i class="fas fa-plus"></i> Add New Product
            </a>
            <a href="${pageContext.request.contextPath}/pm/reports" class="btn btn-secondary">
                <i class="fas fa-chart-bar"></i> View Reports
            </a>
        </div>
    </div>

    <!-- Messages -->
    <c:if test="${not empty sessionScope.message}">
        <p class="success">${sessionScope.message}</p>
        <% session.removeAttribute("message"); %>
    </c:if>
    <c:if test="${not empty error}">
        <p class="error">${error}</p>
    </c:if>

    <!-- Stats Section -->
    <section class="stats-cards">
        <div class="stat-card">
            <h3>Total Products</h3>
            <div class="count">${totalProducts}</div>
        </div>
        <div class="stat-card pending">
            <h3>Pending</h3>
            <div class="count">${pendingCount}</div>
        </div>
        <div class="stat-card">
            <h3>Approved</h3>
            <div class="count">${approvedCount}</div>
        </div>
        <div class="stat-card">
            <h3>Rejected</h3>
            <div class="count">${rejectedCount}</div>
        </div>
        <div class="stat-card low-stock">
            <h3>Low Stock</h3>
            <div class="count">${lowStockCount}</div>
        </div>
        <div class="stat-card out-of-stock">
            <h3>Out of Stock</h3>
            <div class="count">${outOfStockCount}</div>
        </div>
    </section>

    <!-- Pending Review Queue -->
    <section class="dashboard-section">
        <h2>Pending Products</h2>
        <table class="product-table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Supplier</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="product" items="${pendingProducts}">
                <tr>
                    <td>${product.productID}</td>
                    <td>${product.name}</td>
                    <td>${product.supplierId}</td>
                    <td>${product.category}</td>
                    <td>${product.price}</td>
                    <td>${product.stock}</td>
                    <td>
                        <form action="${pageContext.request.contextPath}/pm/action" method="post" style="display:inline;">
                            <input type="hidden" name="productID" value="${product.productID}">
                            <input type="hidden" name="action" value="approve">
                            <button type="submit" class="action-btn btn-approve">
                                <i class="fas fa-check"></i> Approve
                            </button>
                        </form>
                        <form action="${pageContext.request.contextPath}/pm/action" method="post" style="display:inline;">
                            <input type="hidden" name="productID" value="${product.productID}">
                            <input type="hidden" name="action" value="reject">
                            <input type="text" name="rejectionNotes" placeholder="Reason" required>
                            <button type="submit" class="action-btn btn-reject">
                                <i class="fas fa-times"></i> Reject
                            </button>
                        </form>
                        <a href="${pageContext.request.contextPath}/pm/edit-product?productID=${product.productID}" class="action-btn btn-edit">
                            <i class="fas fa-edit"></i> Edit
                        </a>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </section>

    <!-- All Products -->
    <section class="dashboard-section">
        <h2>All Products</h2>
        <table class="product-table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Status</th>
                <th>Price</th>
                <th>Stock</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="product" items="${allProducts}">
                <tr>
                    <td>${product.productID}</td>
                    <td>${product.name}</td>
                    <td>${product.status}</td>
                    <td>${product.price}</td>
                    <td>${product.stock}</td>
                    <td>
                        <a href="${pageContext.request.contextPath}/pm/edit-product?productID=${product.productID}" class="action-btn btn-edit">
                            <i class="fas fa-edit"></i> Edit
                        </a>
                        <form action="${pageContext.request.contextPath}/pm/action" method="post" style="display:inline;">
                            <input type="hidden" name="productID" value="${product.productID}">
                            <input type="hidden" name="action" value="delete">
                            <button type="submit" class="action-btn btn-delete" onclick="return confirm('Are you sure?');">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </section>
</div>

<script>
    // Add animation to stats cards on page load
    document.addEventListener('DOMContentLoaded', function() {
        const statCards = document.querySelectorAll('.stat-card');
        statCards.forEach((card, index) => {
            card.style.animation = `fadeInUp 0.5s ease ${index * 0.1}s forwards`;
            card.style.opacity = '0';
        });
    });
</script>
</body>
</html>