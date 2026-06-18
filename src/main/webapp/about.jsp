<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About NexusShop</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/about-style.css">
</head>
<body>
<div class="floating-bg">
    <div class="floating-circle circle-1"></div>
    <div class="floating-circle circle-2"></div>
    <div class="floating-circle circle-3"></div>
</div>

<header class="header">
    <div class="header-container">
        <div class="logo">
            <a href="index.jsp">
                <span class="logo-icon"><i class="fas fa-atom"></i></span>
                <span class="logo-text">NexusShop</span>
            </a>
        </div>
        <nav class="main-nav">
            <ul class="nav-list">
                <li class="nav-item"><a href="index.jsp" class="nav-link">Home</a></li>
                <li class="nav-item"><a href="products" class="nav-link">Shop</a></li>
                <li class="nav-item"><a href="about.jsp" class="nav-link active">About</a></li>
                <li class="nav-item"><a href="contact.jsp" class="nav-link">Contact</a></li>
            </ul>
        </nav>
    </div>
</header>

<main style="padding: 140px 20px 80px;">
    <section class="about-content">
        <div class="container">
            <div class="about-grid">
                <div class="about-text">
                    <h1 class="section-title">About NexusShop</h1>
                    <p>NexusShop is a university-style e-commerce project focused on electronics, order flow, account management, and supplier workflows.</p>
                    <p>This cleaned version keeps the project structure simple, restores missing pages, and makes the app easier to build, deploy, and maintain.</p>
                    <div class="mission-vision">
                        <div class="mission">
                            <h3><i class="fas fa-bullseye"></i> Our Mission</h3>
                            <p>Make online shopping features easier to learn, demo, and extend in one project.</p>
                        </div>
                        <div class="vision">
                            <h3><i class="fas fa-eye"></i> Our Vision</h3>
                            <p>A practical storefront app that covers customers, admins, suppliers, and delivery staff in one codebase.</p>
                        </div>
                    </div>
                </div>
                <div class="about-image">
                    <img src="images/banner1.png" alt="NexusShop banner">
                </div>
            </div>
        </div>
    </section>
</main>
</body>
</html>
