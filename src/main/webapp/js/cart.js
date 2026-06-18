document.addEventListener('DOMContentLoaded', function() {
    // Quantity controls
    const quantityBtns = document.querySelectorAll('.quantity-btn');
    
    quantityBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const input = this.parentElement.querySelector('.quantity-input');
            let value = parseInt(input.value);
            
            if (this.classList.contains('minus') {
                if (value > 1) {
                    input.value = value - 1;
                    updateCartItem(this.closest('.cart-item'));
                }
            } else if (this.classList.contains('plus')) {
                input.value = value + 1;
                updateCartItem(this.closest('.cart-item'));
            }
        });
    });
    
    // Quantity input change
    const quantityInputs = document.querySelectorAll('.quantity-input');
    
    quantityInputs.forEach(input => {
        input.addEventListener('change', function() {
            if (this.value < 1) this.value = 1;
            updateCartItem(this.closest('.cart-item'));
        });
    });
    
    // Remove item
    const removeBtns = document.querySelectorAll('.remove-btn');
    
    removeBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const cartItem = this.closest('.cart-item');
            cartItem.classList.add('removing');
            
            // Animation before removal
            setTimeout(() => {
                cartItem.remove();
                updateCartTotals();
                updateCartCount();
            }, 300);
        });
    });
    
    // Update cart button
    const updateBtn = document.querySelector('.update-btn');
    
    if (updateBtn) {
        updateBtn.addEventListener('click', function() {
            // In a real app, this would send updates to the server
            alert('Cart updated successfully!');
        });
    }
    
    // Apply coupon button
    const couponBtn = document.querySelector('.coupon-btn');
    
    if (couponBtn) {
        couponBtn.addEventListener('click', function(e) {
            e.preventDefault();
            const couponInput = document.querySelector('.coupon-input');
            
            if (couponInput.value.trim() === '') {
                alert('Please enter a coupon code');
                return;
            }
            
            // In a real app, this would validate with the server
            alert(`Coupon "${couponInput.value}" applied successfully!`);
            couponInput.value = '';
            
            // Simulate discount
            document.querySelector('.summary-row:nth-child(3) .row-value').textContent = '-$200.00';
            document.querySelector('.summary-row.total .row-value').textContent = '$3,599.96';
        });
    }
    
    // Calculate shipping button
    const calculateBtn = document.querySelector('.calculate-btn');
    
    if (calculateBtn) {
        calculateBtn.addEventListener('click', function() {
            // In a real app, this would calculate shipping costs
            alert('Shipping calculated! Free shipping applied.');
            document.querySelector('.summary-row:nth-child(2) .row-value').textContent = '$0.00';
            updateCartTotals();
        });
    }
    
    // Add to cart buttons in cross-sell
    const addToCartBtns = document.querySelectorAll('.add-to-cart');
    
    addToCartBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            // In a real app, this would add the product to cart
            alert('Product added to cart!');
            updateCartCount(1);
        });
    });
    
    // Helper function to update cart item
    function updateCartItem(item) {
        const price = parseFloat(item.querySelector('.current-price').textContent.replace('$', ''));
        const quantity = parseInt(item.querySelector('.quantity-input').value);
        const subtotal = item.querySelector('.item-subtotal');
        
        subtotal.textContent = '$' + (price * quantity).toFixed(2);
        updateCartTotals();
        updateCartCount();
    }
    
    // Helper function to update cart totals
    function updateCartTotals() {
        let subtotal = 0;
        const items = document.querySelectorAll('.cart-item');
        
        items.forEach(item => {
            const itemSubtotal = parseFloat(item.querySelector('.item-subtotal').textContent.replace('$', ''));
            subtotal += itemSubtotal;
        });
        
        // In a real app, this would calculate shipping and discounts from server
        const shipping = 0;
        const discount = 200;
        const total = subtotal + shipping - discount;
        
        document.querySelector('.summary-row:nth-child(1) .row-value').textContent = '$' + subtotal.toFixed(2);
        document.querySelector('.summary-row.total .row-value').textContent = '$' + total.toFixed(2);
    }
    
    // Helper function to update cart count in header
    function updateCartCount(change = 0) {
        const cartCount = document.querySelector('.cart-count');
        let count = parseInt(cartCount.textContent) || 0;
        
        if (change !== 0) {
            count += change;
        } else {
            // Recalculate based on actual items
            count = document.querySelectorAll('.cart-item').length;
        }
        
        cartCount.textContent = count;
        cartCount.classList.add('pulse');
        
        setTimeout(() => {
            cartCount.classList.remove('pulse');
        }, 500);
    }
    
    // Initialize cart
    updateCartTotals();
});