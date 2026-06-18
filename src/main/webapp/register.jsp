<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register | NexusShop</title>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <!-- CSS -->
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/auth.css">
    <style>
        /* Password Strength Indicator Styles */
        .password-strength {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: -10px;
            margin-bottom: 15px;
        }

        .strength-bar {
            flex: 1;
            height: 4px;
            background: #e0e0e0;
            border-radius: 2px;
            transition: all 0.3s ease;
        }

        .strength-bar.active {
            background: #e74c3c;
        }

        .strength-bar.active.medium {
            background: #f39c12;
        }

        .strength-bar.active.strong {
            background: #27ae60;
        }

        .strength-text {
            font-size: 0.85em;
            font-weight: 500;
            color: #e74c3c;
            min-width: 70px;
            transition: color 0.3s ease;
        }

        .strength-text.medium {
            color: #f39c12;
        }

        .strength-text.strong {
            color: #27ae60;
        }

        .password-requirements {
            font-size: 0.8em;
            color: #666;
            margin-top: -10px;
            margin-bottom: 15px;
            padding-left: 5px;
        }

        .password-requirements ul {
            list-style: none;
            padding: 0;
            margin: 5px 0;
        }

        .password-requirements li {
            padding: 3px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .password-requirements li i {
            font-size: 0.9em;
            color: #999;
        }

        .password-requirements li.valid i {
            color: #27ae60;
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

<!-- Main Content -->
<main class="auth-container">
    <div class="container">
        <div class="auth-card">
            <div class="auth-header">
                <h1>Create Account</h1>
                <p>Join NexusShop to enjoy personalized shopping experience</p>
            </div>

            <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
            <div class="error-message" style="color:#e74c3c; text-align:center; margin-bottom:15px;">
                <%= error %>
            </div>
            <%
                }
            %>

            <form method="POST" action="register" onsubmit="return validateForm()">
                <input type="hidden" name="role" value="customer">

                <div class="form-group">
                    <label for="registerName">Full Name</label>
                    <input type="text" id="registerName" name="fullName" required>
                    <i class="fas fa-user input-icon"></i>
                </div>

                <div class="form-group">
                    <label for="registerEmail">Email</label>
                    <input type="email" id="registerEmail" name="email" required>
                    <i class="fas fa-envelope input-icon"></i>
                </div>

                <div class="form-group">
                    <label for="registerPassword">Password</label>
                    <input type="password" id="registerPassword" name="password" required>
                    <i class="fas fa-lock input-icon"></i>
                    <button type="button" class="toggle-password" onclick="togglePassword('registerPassword', this)" aria-label="Show password">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>

                <div class="password-strength">
                    <span class="strength-bar" id="bar1"></span>
                    <span class="strength-bar" id="bar2"></span>
                    <span class="strength-bar" id="bar3"></span>
                    <span class="strength-text" id="strengthText">Weak</span>
                </div>

                <div class="password-requirements">
                    <ul>
                        <li id="req-length"><i class="fas fa-circle"></i> At least 8 characters</li>
                        <li id="req-uppercase"><i class="fas fa-circle"></i> One uppercase letter</li>
                        <li id="req-lowercase"><i class="fas fa-circle"></i> One lowercase letter</li>
                        <li id="req-number"><i class="fas fa-circle"></i> One number</li>
                        <li id="req-special"><i class="fas fa-circle"></i> One special character</li>
                    </ul>
                </div>

                <div class="form-group">
                    <label for="registerConfirmPassword">Confirm Password</label>
                    <input type="password" id="registerConfirmPassword" name="confirmPassword" required>
                    <i class="fas fa-lock input-icon"></i>
                    <button type="button" class="toggle-password" onclick="togglePassword('registerConfirmPassword', this)" aria-label="Show password">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>

                <div class="form-group">
                    <label for="registerAddress">Address (Optional)</label>
                    <input type="text" id="registerAddress" name="address">
                    <i class="fas fa-map-marker-alt input-icon"></i>
                </div>

                <div class="form-group">
                    <label for="registerPhone">Phone Number</label>
                    <input type="tel" id="registerPhone" name="phone" required>
                    <i class="fas fa-phone input-icon"></i>
                </div>

                <div class="form-group">
                    <label for="registerDOB">Date of Birth</label>
                    <input type="date" id="registerDOB" name="dob" required>
                    <i class="fas fa-calendar input-icon"></i>
                </div>

                <button type="submit" class="auth-button">Create Account</button>

                <div class="auth-divider">
                    <span>or</span>
                </div>

                <div class="social-login">
                    <button type="button" class="social-button google">
                        <i class="fab fa-google"></i> Continue with Google
                    </button>
                    <button type="button" class="social-button facebook">
                        <i class="fab fa-facebook-f"></i> Continue with Facebook
                    </button>
                </div>

                <div class="auth-footer">
                    Already have an account? <a href="login.jsp" class="auth-link">Sign in</a>
                </div>
            </form>
        </div>
    </div>
</main>

<!-- JavaScript -->
<script src="js/main.js"></script>
<script src="js/auth.js"></script>

<script>
    // Password Strength Check Function
    function checkPasswordStrength(password) {
        let strength = 0;
        const requirements = {
            length: password.length >= 8,
            uppercase: /[A-Z]/.test(password),
            lowercase: /[a-z]/.test(password),
            number: /[0-9]/.test(password),
            special: /[!@#$%^&*(),.?":{}|<>]/.test(password)
        };

        // Update requirement indicators
        document.getElementById('req-length').classList.toggle('valid', requirements.length);
        document.getElementById('req-uppercase').classList.toggle('valid', requirements.uppercase);
        document.getElementById('req-lowercase').classList.toggle('valid', requirements.lowercase);
        document.getElementById('req-number').classList.toggle('valid', requirements.number);
        document.getElementById('req-special').classList.toggle('valid', requirements.special);

        // Calculate strength
        Object.values(requirements).forEach(met => {
            if (met) strength++;
        });

        // Update strength bars and text
        const bar1 = document.getElementById('bar1');
        const bar2 = document.getElementById('bar2');
        const bar3 = document.getElementById('bar3');
        const strengthText = document.getElementById('strengthText');

        // Reset bars
        bar1.classList.remove('active', 'medium', 'strong');
        bar2.classList.remove('active', 'medium', 'strong');
        bar3.classList.remove('active', 'medium', 'strong');
        strengthText.classList.remove('medium', 'strong');

        if (password.length === 0) {
            strengthText.textContent = 'Weak';
            return;
        }

        if (strength <= 2) {
            // Weak
            bar1.classList.add('active');
            strengthText.textContent = 'Weak';
        } else if (strength <= 4) {
            // Medium
            bar1.classList.add('active', 'medium');
            bar2.classList.add('active', 'medium');
            strengthText.textContent = 'Medium';
            strengthText.classList.add('medium');
        } else {
            // Strong
            bar1.classList.add('active', 'strong');
            bar2.classList.add('active', 'strong');
            bar3.classList.add('active', 'strong');
            strengthText.textContent = 'Strong';
            strengthText.classList.add('strong');
        }
    }

    // Password toggle function
    function togglePassword(inputId, button) {
        const input = document.getElementById(inputId);
        const icon = button.querySelector('i');

        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }

    // Add event listener for password input
    document.addEventListener('DOMContentLoaded', function() {
        const passwordInput = document.getElementById('registerPassword');

        passwordInput.addEventListener('input', function() {
            checkPasswordStrength(this.value);
        });
    });

    // Form validation
    function validateForm() {
        const phone = document.getElementById('registerPhone').value;
        const dob = document.getElementById('registerDOB').value;
        const password = document.getElementById('registerPassword').value;
        const confirmPassword = document.getElementById('registerConfirmPassword').value;

        // Validate phone number (at least 10 digits)
        const phoneDigits = phone.replace(/\D/g, '');
        if (phoneDigits.length < 10) {
            alert('Phone number must be at least 10 digits');
            return false;
        }

        // Validate date of birth (not in the future and at least 13 years old)
        const today = new Date();
        const birthDate = new Date(dob);
        if (birthDate > today) {
            alert('Date of birth cannot be in the future');
            return false;
        }

        const age = today.getFullYear() - birthDate.getFullYear();
        const monthDiff = today.getMonth() - birthDate.getMonth();
        if (age < 13 || (age === 13 && monthDiff < 0)) {
            alert('You must be at least 13 years old to register');
            return false;
        }

        // Validate password match
        if (password !== confirmPassword) {
            alert('Passwords do not match');
            return false;
        }

        // Validate password strength
        if (password.length < 8) {
            alert('Password must be at least 8 characters long');
            return false;
        }

        if (!/[A-Z]/.test(password)) {
            alert('Password must contain at least one uppercase letter');
            return false;
        }

        if (!/[a-z]/.test(password)) {
            alert('Password must contain at least one lowercase letter');
            return false;
        }

        if (!/[0-9]/.test(password)) {
            alert('Password must contain at least one number');
            return false;
        }

        if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
            alert('Password must contain at least one special character');
            return false;
        }

        return true;
    }
</script>
</body>
</html>
