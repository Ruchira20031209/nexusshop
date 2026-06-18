document.addEventListener('DOMContentLoaded', function() {
    // Toggle password visibility
    const togglePasswordButtons = document.querySelectorAll('.toggle-password');
    
    togglePasswordButtons.forEach(button => {
        button.addEventListener('click', function() {
            const input = this.parentElement.querySelector('input');
            const icon = this.querySelector('i');
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        });
    });



    // Password strength indicator (for registration page)
    const passwordInput = document.getElementById('registerPassword');
    if (passwordInput) {
        passwordInput.addEventListener('input', function() {
            const strengthBars = document.querySelectorAll('.strength-bar');
            const strengthText = document.querySelector('.strength-text');
            const password = this.value;
            
            // Reset all bars
            strengthBars.forEach(bar => {
                bar.style.backgroundColor = '#ddd';
            });
            
            // Very weak password
            if (password.length === 0) {
                strengthText.textContent = '';
                return;
            } else if (password.length < 4) {
                strengthBars[0].style.backgroundColor = 'var(--danger)';
                strengthText.textContent = 'Very Weak';
                strengthText.style.color = 'var(--danger)';
                return;
            }
            
            // Check password strength
            let strength = 0;
            
            // Length check
            if (password.length >= 8) strength++;
            if (password.length >= 12) strength++;
            
            // Complexity checks
            if (/[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;
            
            // Update UI based on strength
            if (strength <= 2) {
                strengthBars[0].style.backgroundColor = 'var(--danger)';
                strengthText.textContent = 'Weak';
                strengthText.style.color = 'var(--danger)';
            } else if (strength <= 4) {
                strengthBars[0].style.backgroundColor = 'var(--warning)';
                strengthBars[1].style.backgroundColor = 'var(--warning)';
                strengthText.textContent = 'Medium';
                strengthText.style.color = 'var(--warning)';
            } else {
                strengthBars[0].style.backgroundColor = 'var(--success)';
                strengthBars[1].style.backgroundColor = 'var(--success)';
                strengthBars[2].style.backgroundColor = 'var(--success)';
                strengthText.textContent = 'Strong';
                strengthText.style.color = 'var(--success)';
            }
        });
    }

    // Form validation and submission
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', function(e) {
            e.preventDefault();
            // In a real app, you would validate and send to server
            console.log('Login form submitted');
            // Redirect to account page after successful login
            window.location.href = 'index/';
        });
    }

    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Validate password match
            const password = document.getElementById('registerPassword').value;
            const confirmPassword = document.getElementById('registerConfirmPassword').value;
            
            if (password !== confirmPassword) {
                alert('Passwords do not match!');
                return;
            }
            

            
            // In a real app, you would validate and send to server
            console.log('Registration form submitted');
            
            // Redirect to account page after successful registration
            window.location.href = 'index/';
        });
    }

    // Social login buttons
    const socialButtons = document.querySelectorAll('.social-button');
    socialButtons.forEach(button => {
        button.addEventListener('click', function() {
            // In a real app, this would initiate OAuth flow
            console.log(`Sign in with ${this.textContent.trim()}`);
        });
    });
});