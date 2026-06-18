<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    boolean submitted = "POST".equalsIgnoreCase(request.getMethod());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact NexusShop</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .contact-shell {
            max-width: 900px;
            margin: 140px auto 80px;
            padding: 0 20px;
        }
        .contact-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 18px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.08);
            padding: 32px;
        }
        .contact-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 20px;
        }
        .info-box {
            background: #f8fafc;
            border-radius: 14px;
            padding: 18px;
        }
        .contact-form {
            display: grid;
            gap: 14px;
            margin-top: 24px;
        }
        .contact-form input,
        .contact-form textarea {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #d9e2ec;
            border-radius: 10px;
            font: inherit;
        }
        .contact-form textarea {
            min-height: 140px;
            resize: vertical;
        }
        .contact-form button {
            width: fit-content;
            padding: 12px 18px;
            border: none;
            border-radius: 10px;
            background: #6c5ce7;
            color: #fff;
            font-weight: 600;
            cursor: pointer;
        }
        .notice {
            margin-top: 16px;
            padding: 12px 14px;
            border-radius: 10px;
            background: #e8f7ee;
            color: #1f7a44;
            font-weight: 500;
        }
    </style>
</head>
<body>
<div class="contact-shell">
    <div class="contact-card">
        <h1 class="section-title">Contact Us</h1>
        <p>If you need help with an order, account, or product listing, send us a message below.</p>

        <div class="contact-grid" style="margin-top: 24px;">
            <div class="info-box">
                <h3><i class="fas fa-envelope"></i> Email</h3>
                <p>support@nexusshop.local</p>
            </div>
            <div class="info-box">
                <h3><i class="fas fa-phone"></i> Phone</h3>
                <p>+94 11 000 0000</p>
            </div>
            <div class="info-box">
                <h3><i class="fas fa-clock"></i> Support Hours</h3>
                <p>Monday to Friday, 9:00 AM to 6:00 PM</p>
            </div>
        </div>

        <% if (submitted) { %>
        <div class="notice">Your message has been captured in this demo page. Connect this form to email or a support table if you want persistent tickets.</div>
        <% } %>

        <form method="post" action="contact.jsp" class="contact-form">
            <input type="text" name="name" placeholder="Your name" required>
            <input type="email" name="email" placeholder="Your email" required>
            <input type="text" name="subject" placeholder="Subject" required>
            <textarea name="message" placeholder="How can we help?" required></textarea>
            <button type="submit"><i class="fas fa-paper-plane"></i> Send Message</button>
        </form>
    </div>
</div>
</body>
</html>
