<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login | NexusShop</title>
  <!-- Font Awesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
  <!-- CSS -->
  <link rel="stylesheet" href="css/style.css">
  <link rel="stylesheet" href="css/auth.css">
  <style>
    .error-message {
      color: #e74c3c;
      text-align: center;
      margin-bottom: 15px;
      font-size: 0.95em;
      font-weight: 500;
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

<main class="auth-container">
  <div class="container">
    <div class="auth-card">
      <div class="auth-header">
        <h1>Welcome Back</h1>
        <p>Sign in to access your account and start shopping</p>
      </div>

      <form class="auth-form" method="POST" action="login">
        <!-- ✅ Display error if exists -->
        <%
          String error = (String) request.getAttribute("error");
          if (error != null) {
        %>
        <div class="error-message">
          <%= error %>
        </div>
        <%
          }
        %>

        <div class="form-group">
          <label for="loginEmail">Email</label>
          <input type="email" id="loginEmail" name="email" required
                 value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
          <i class="fas fa-envelope input-icon"></i>
        </div>

        <div class="form-group">
          <label for="loginPassword">Password</label>
          <input type="password" id="loginPassword" name="password" required>
          <i class="fas fa-lock input-icon"></i>
          <button type="button" class="toggle-password" onclick="togglePassword()">
            <i class="fas fa-eye"></i>
          </button>
        </div>

        <div class="form-options">
          <div class="remember-me">
            <input type="checkbox" id="rememberMe" name="rememberMe">
            <label for="rememberMe">Remember me</label>
          </div>
          <a href="forgot-password.jsp" class="forgot-password">Forgot password?</a>
        </div>

        <button type="submit" class="auth-button">Sign In</button>

        <div class="auth-divider">
          <span>or</span>
        </div>

        <div class="social-login">
          <button type="button" class="social-button google" disabled>
            <i class="fab fa-google"></i> Continue with Google
          </button>
          <button type="button" class="social-button facebook" disabled>
            <i class="fab fa-facebook-f"></i> Continue with Facebook
          </button>
        </div>

        <div class="auth-footer">
          Don't have an account? <a href="register.jsp" class="auth-link">Sign up</a>
        </div>
      </form>
    </div>
  </div>
</main>

<script>
  function togglePassword() {
    const pass = document.getElementById('loginPassword');
    const icon = document.querySelector('.toggle-password i');
    if (pass.type === 'password') {
      pass.type = 'text';
      icon.className = 'fas fa-eye-slash';
    } else {
      pass.type = 'password';
      icon.className = 'fas fa-eye';
    }
  }
</script>
</body>
</html>
