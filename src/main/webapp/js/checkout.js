document.addEventListener('DOMContentLoaded', function() {
    // Form submission
    const checkoutForm = document.getElementById('codCheckoutForm');
    
    if (checkoutForm) {
        checkoutForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Validate form
            if (!validateForm()) {
                return;
            }
            
            // In a real app, this would submit to your backend
            console.log('Form submitted:', getFormData());
            
            // Show loading state
            const submitBtn = this.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
            
            // Simulate API call
            setTimeout(() => {
                // Redirect to order confirmation page
                window.location.href = '../order-complete/';
            }, 1500);
        });
    }
    
    // Form validation
    function validateForm() {
        let isValid = true;
        const form = document.getElementById('codCheckoutForm');
        const requiredFields = form.querySelectorAll('[required]');
        
        requiredFields.forEach(field => {
            if (!field.value.trim()) {
                field.style.borderColor = 'var(--danger)';
                isValid = false;
                
                // Reset border color when user starts typing
                field.addEventListener('input', function() {
                    this.style.borderColor = '#ddd';
                });
            }
        });
        
        // Check terms checkbox
        const termsCheckbox = form.querySelector('#terms');
        if (!termsCheckbox.checked) {
            alert('Please agree to the Terms and Conditions');
            isValid = false;
        }
        
        return isValid;
    }
    
    // Get form data
    function getFormData() {
        const form = document.getElementById('codCheckoutForm');
        const formData = new FormData(form);
        const data = {};
        
        formData.forEach((value, key) => {
            data[key] = value;
        });
        
        return data;
    }
    
    // Auto-fill logged in user's data (simulated)
    function autoFillUserData() {
        // In a real app, this would fetch from user session or API
        const userData = {
            firstName: 'John',
            lastName: 'Doe',
            email: 'john.doe@example.com',
            phone: '+1 (555) 123-4567',
            address: '123 Tech Street',
            city: 'San Francisco',
            state: 'CA',
            zip: '94107',
            country: 'US'
        };
        
        Object.keys(userData).forEach(key => {
            const field = document.getElementById(key);
            if (field) {
                field.value = userData[key];
            }
        });
    }
    
    // Initialize checkout
    autoFillUserData();
});