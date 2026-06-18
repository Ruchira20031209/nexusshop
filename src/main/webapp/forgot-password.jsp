<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    boolean submitted = "POST".equalsIgnoreCase(request.getMethod());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<main style="max-width: 640px; margin: 140px auto 80px; padding: 0 20px;">
    <section style="background:#fff; border-radius:18px; padding:32px; box-shadow:0 18px 50px rgba(0,0,0,0.08);">
        <h1 class="section-title">Forgot Password</h1>
        <p>This demo page accepts an email and shows a confirmation message. Add an email provider or token flow when you are ready.</p>
        <% if (submitted) { %>
        <p style="margin-top:16px; padding:12px; border-radius:10px; background:#e8f7ee; color:#1f7a44;">If this email exists, a reset link would be sent.</p>
        <% } %>
        <form method="post" action="forgot-password.jsp" style="display:grid; gap:14px; margin-top:20px;">
            <input type="email" name="email" placeholder="Enter your email" required style="padding:12px; border:1px solid #d9e2ec; border-radius:10px;">
            <button type="submit" style="padding:12px 18px; border:none; border-radius:10px; background:#6c5ce7; color:#fff; font-weight:600;">Send Reset Link</button>
        </form>
    </section>
</main>
</body>
</html>
