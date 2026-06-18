<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Product | NexusShop PM</title>
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
            min-height: 100vh;
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
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
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

        .cart-count {
            position: absolute;
            top: -8px;
            right: -8px;
            background: var(--accent);
            color: white;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.7rem;
            font-weight: bold;
            transition: var(--transition);
        }

        /* Mobile Menu Button */
        .mobile-menu-btn {
            display: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--dark);
            transition: var(--transition);
            background: transparent;
            border: none;
        }

        .mobile-menu-btn:hover {
            color: var(--primary);
            transform: scale(1.1);
        }

        /* Page Title */
        .page-title {
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

        .page-title::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 50%;
            height: 4px;
            background: linear-gradient(to right, var(--primary), var(--secondary));
            border-radius: 2px;
        }

        /* Form Styles */
        .add-form-container {
            background: white;
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: var(--dark);
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 0.8rem 1rem;
            border: 1px solid var(--gray);
            border-radius: 8px;
            font-family: var(--font-primary);
            font-size: 1rem;
            transition: var(--transition);
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(108, 92, 231, 0.1);
        }

        .form-group textarea {
            min-height: 120px;
            resize: vertical;
        }

        .form-section {
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 1px solid var(--gray);
        }

        .form-section-title {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: var(--primary);
            font-family: var(--font-secondary);
        }

        /* File Input Styling */
        .file-input-group {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .file-input-group input[type="file"] {
            padding: 0.5rem;
            border: 2px dashed var(--gray);
            border-radius: 8px;
            background: #f8f9fa;
            transition: var(--transition);
        }

        .file-input-group input[type="file"]:hover {
            border-color: var(--primary);
            background: #f0f2f5;
        }

        /* Specifications */
        .specs-container {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .spec-row {
            display: flex;
            gap: 1rem;
            align-items: center;
        }

        .spec-row input {
            flex: 1;
        }

        .remove-spec-btn {
            background: var(--danger);
            color: white;
            border: none;
            width: 40px;
            height: 40px;
            border-radius: 6px;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .remove-spec-btn:hover {
            background: #c23616;
            transform: scale(1.05);
        }

        .add-spec-btn {
            align-self: flex-start;
            background: var(--secondary);
            color: white;
            border: none;
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            cursor: pointer;
            transition: var(--transition);
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .add-spec-btn:hover {
            background: #00b8b3;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 206, 201, 0.4);
        }

        /* Action Buttons */
        .form-actions {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            margin-top: 2rem;
        }

        .action-btn {
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-approve {
            background: var(--success);
            color: white;
        }

        .btn-approve:hover {
            background: #00a085;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 184, 148, 0.4);
        }

        .btn-cancel {
            background: var(--gray);
            color: var(--dark);
        }

        .btn-cancel:hover {
            background: #c8d6e5;
            transform: translateY(-2px);
        }

        /* Error Messages */
        .error {
            color: var(--danger);
            background: rgba(214, 48, 49, 0.1);
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid var(--danger);
        }

        .error li {
            margin-bottom: 0.5rem;
        }

        .error li:last-child {
            margin-bottom: 0;
        }

        /* Back Link */
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--primary);
            font-weight: 500;
            margin-bottom: 2rem;
            transition: var(--transition);
        }

        .back-link:hover {
            color: var(--primary-dark);
            transform: translateX(-5px);
        }

        /* Form Tips */
        .form-tips {
            background: rgba(108, 92, 231, 0.05);
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-left: 4px solid var(--primary);
        }

        .form-tips h3 {
            color: var(--primary);
            margin-bottom: 0.5rem;
            font-size: 1rem;
        }

        .form-tips ul {
            list-style: disc;
            margin-left: 1.5rem;
            color: #666;
            font-size: 0.9rem;
        }

        .form-tips li {
            margin-bottom: 0.3rem;
        }

        /* Responsive Design */
        @media (max-width: 992px) {
            .main-nav {
                display: none;
                position: absolute;
                top: 100%;
                left: 0;
                width: 100%;
                background: var(--glass-bg);
                backdrop-filter: blur(10px);
                -webkit-backdrop-filter: blur(10px);
                padding: 1rem;
                box-shadow: var(--glass-shadow);
            }

            .main-nav.active {
                display: block;
            }

            .nav-list {
                flex-direction: column;
            }

            .nav-item {
                margin: 0.5rem 0;
            }

            .mobile-menu-btn {
                display: block;
            }

            .mobile-menu-btn.active i::before {
                content: '\f00d';
            }

            .user-actions .action-text {
                display: none;
            }

            .action-item {
                margin-left: 1rem;
            }
        }

        @media (max-width: 768px) {
            body {
                padding-top: 70px;
            }

            .header-container {
                padding: 0 1rem;
            }

            .logo-text {
                display: none;
            }

            .page-title {
                font-size: 2rem;
            }

            .add-form-container {
                padding: 1.5rem;
            }

            .spec-row {
                flex-direction: column;
            }

            .remove-spec-btn {
                width: 100%;
                margin-top: 0.5rem;
            }

            .form-actions {
                flex-direction: column;
            }

            .action-btn {
                width: 100%;
                justify-content: center;
            }
        }

        @media (max-width: 480px) {
            .container {
                padding: 0 1rem;
            }

            .add-form-container {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
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
                <li class="nav-item"><a href="${pageContext.request.contextPath}/products/?filter=deals" class="nav-link">Deals</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/products/?filter=new" class="nav-link">New Arrivals</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/about" class="nav-link">About</a></li>
            </ul>
        </nav>

        <!-- User Actions -->
        <div class="user-actions">
            <div class="action-item">
                <a href="${pageContext.request.contextPath}/pm/dashboard" class="action-link">
                    <i class="fas fa-tachometer-alt"></i>
                    <span class="action-text">Dashboard</span>
                </a>
            </div>
            <div class="action-item">
                <a href="${pageContext.request.contextPath}/logout" class="action-link" onclick="return confirm('Are you sure you want to logout?')">
                    <i class="fas fa-sign-out-alt"></i>
                    <span class="action-text">Logout</span>
                </a>
            </div>
        </div>

        <!-- Mobile Menu Button -->
        <div class="mobile-menu-btn">
            <i class="fas fa-bars"></i>
        </div>
    </div>
</header>

<!-- Main Content -->
<div class="container">
    <a href="${pageContext.request.contextPath}/pm/dashboard" class="back-link">
        <i class="fas fa-arrow-left"></i> Back to Dashboard
    </a>

    <h1 class="page-title">Add New Product</h1>

    <c:if test="${not empty errors}">
        <ul class="error">
            <c:forEach var="err" items="${errors}">
                <li>${err}</li>
            </c:forEach>
        </ul>
    </c:if>

    <div class="form-tips">
        <h3><i class="fas fa-lightbulb"></i> Quick Tips</h3>
        <ul>
            <li>Fill in all required fields marked with *</li>
            <li>Upload high-quality product images for better presentation</li>
            <li>Add detailed specifications to help customers make informed decisions</li>
            <li>Set appropriate stock levels to avoid overselling</li>
        </ul>
    </div>

    <div class="add-form-container">
        <form action="${pageContext.request.contextPath}/pm/add-product" method="post" enctype="multipart/form-data">
            <div class="form-section">
                <h2 class="form-section-title">Basic Information</h2>

                <div class="form-group">
                    <label for="name">Product Name *</label>
                    <input type="text" id="name" name="name" placeholder="Enter product name" required>
                </div>

                <div class="form-group">
                    <label for="sku">SKU (Stock Keeping Unit) *</label>
                    <input type="text" id="sku" name="sku" placeholder="Enter unique SKU" required>
                </div>

                <div class="form-group">
                    <label for="category">Category *</label>
                    <input type="text" id="category" name="category" placeholder="e.g., Laptops, Phones, Audio" required>
                </div>

                <div class="form-group">
                    <label for="price">Price ($) *</label>
                    <input type="number" id="price" name="price" step="0.01" placeholder="0.00" min="0" required>
                </div>

                <div class="form-group">
                    <label for="stock">Stock Quantity *</label>
                    <input type="number" id="stock" name="stock" placeholder="0" min="0" required>
                </div>

                <div class="form-group">
                    <label for="description">Product Description *</label>
                    <textarea id="description" name="description" placeholder="Describe the product features, benefits, and key specifications..." required></textarea>
                </div>
            </div>

            <!-- Images Section -->
            <div class="form-section">
                <h2 class="form-section-title">Product Images</h2>
                <p style="color: #666; margin-bottom: 1rem; font-size: 0.9rem;">Upload up to 5 high-quality images of your product</p>

                <div class="file-input-group">
                    <input type="file" name="image1" accept="image/*" required>
                    <input type="file" name="image2" accept="image/*">
                    <input type="file" name="image3" accept="image/*">
                    <input type="file" name="image4" accept="image/*">
                    <input type="file" name="image5" accept="image/*">
                </div>
            </div>

            <!-- Specifications Section -->
            <div class="form-section">
                <h2 class="form-section-title">Product Specifications</h2>
                <p style="color: #666; margin-bottom: 1rem; font-size: 0.9rem;">Add key specifications to help customers understand your product better</p>

                <div class="specs-container" id="specs">
                    <div class="spec-row">
                        <input type="text" name="specKey" placeholder="Key (e.g., Battery)" required>
                        <input type="text" name="specValue" placeholder="Value (e.g., 5000mAh)" required>
                        <button type="button" class="remove-spec-btn" style="display: none;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="spec-row">
                        <input type="text" name="specKey" placeholder="Key (e.g., Screen Size)">
                        <input type="text" name="specValue" placeholder="Value (e.g., 6.5 inches)">
                        <button type="button" class="remove-spec-btn" style="display: none;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="spec-row">
                        <input type="text" name="specKey" placeholder="Key (e.g., Storage)">
                        <input type="text" name="specValue" placeholder="Value (e.g., 128GB)">
                        <button type="button" class="remove-spec-btn" style="display: none;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="spec-row">
                        <input type="text" name="specKey" placeholder="Key (e.g., Processor)">
                        <input type="text" name="specValue" placeholder="Value (e.g., Snapdragon 888)">
                        <button type="button" class="remove-spec-btn" style="display: none;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="spec-row">
                        <input type="text" name="specKey" placeholder="Key (e.g., Camera)">
                        <input type="text" name="specValue" placeholder="Value (e.g., 48MP Triple)">
                        <button type="button" class="remove-spec-btn" style="display: none;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>

                    <button type="button" class="add-spec-btn" id="addSpecBtn">
                        <i class="fas fa-plus"></i> Add More Specifications
                    </button>
                </div>
            </div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/pm/dashboard" class="action-btn btn-cancel">
                    <i class="fas fa-times"></i> Cancel
                </a>
                <button type="submit" class="action-btn btn-approve">
                    <i class="fas fa-plus-circle"></i> Add Product
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    // Mobile menu toggle
    document.querySelector('.mobile-menu-btn').addEventListener('click', function() {
        document.querySelector('.main-nav').classList.toggle('active');
        this.classList.toggle('active');
    });

    // Add specification row
    document.getElementById('addSpecBtn').addEventListener('click', function() {
        const container = document.getElementById('specs');
        const newRow = document.createElement('div');
        newRow.className = 'spec-row';
        newRow.innerHTML = `
            <input type="text" name="specKey" placeholder="Key">
            <input type="text" name="specValue" placeholder="Value">
            <button type="button" class="remove-spec-btn">
                <i class="fas fa-times"></i>
            </button>
        `;

        // Insert before the add button
        container.insertBefore(newRow, this);

        // Add event listener to remove button
        newRow.querySelector('.remove-spec-btn').addEventListener('click', function() {
            newRow.remove();
        });
    });

    // Show remove buttons for existing rows (except first one)
    document.addEventListener('DOMContentLoaded', function() {
        const specRows = document.querySelectorAll('.spec-row');
        specRows.forEach((row, index) => {
            if (index > 0) { // Don't show remove button for first required row
                const removeBtn = row.querySelector('.remove-spec-btn');
                if (removeBtn) {
                    removeBtn.style.display = 'flex';
                    removeBtn.addEventListener('click', function() {
                        row.remove();
                    });
                }
            }
        });
    });

    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
        const nav = document.querySelector('.main-nav');
        const menuBtn = document.querySelector('.mobile-menu-btn');

        if (!nav.contains(event.target) && !menuBtn.contains(event.target) && nav.classList.contains('active')) {
            nav.classList.remove('active');
            menuBtn.classList.remove('active');
        }
    });
</script>
</body>
</html>