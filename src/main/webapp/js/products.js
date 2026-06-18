// Enhanced products.js with modern functionality
document.addEventListener('DOMContentLoaded', function() {
    // Mobile menu toggle
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const mainNav = document.querySelector('.main-nav');

    if (mobileMenuBtn && mainNav) {
        mobileMenuBtn.addEventListener('click', function() {
            this.classList.toggle('active');
            mainNav.classList.toggle('active');
        });
    }

    // Filter form real-time updates
    const filterForm = document.getElementById('filter-form');
    if (filterForm) {
        const inputs = filterForm.querySelectorAll('input, select');

        inputs.forEach(input => {
            input.addEventListener('change', function() {
                // Add loading state
                filterForm.classList.add('loading');

                // Submit form after short delay for better UX
                setTimeout(() => {
                    filterForm.submit();
                }, 500);
            });
        });

        // Price range validation
        const priceMin = document.getElementById('price_min');
        const priceMax = document.getElementById('price_max');

        if (priceMin && priceMax) {
            priceMin.addEventListener('blur', validatePriceRange);
            priceMax.addEventListener('blur', validatePriceRange);
        }
    }

    // Product card animations
    const productCards = document.querySelectorAll('.product-card');
    productCards.forEach((card, index) => {
        // Staggered animation
        card.style.animationDelay = `${index * 0.1}s`;

        // Hover effects
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-10px) scale(1.02)';
        });

        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });

    // Load more functionality
    const loadMoreBtn = document.getElementById('loadMoreBtn');
    if (loadMoreBtn) {
        loadMoreBtn.addEventListener('click', loadMoreProducts);
    }

    // Initialize product interactions
    initProductInteractions();
});

function validatePriceRange() {
    const priceMin = document.getElementById('price_min');
    const priceMax = document.getElementById('price_max');

    if (priceMin.value && priceMax.value && parseFloat(priceMin.value) > parseFloat(priceMax.value)) {
        priceMin.setCustomValidity('Minimum price cannot be greater than maximum price');
        priceMin.reportValidity();
    } else {
        priceMin.setCustomValidity('');
    }
}

function loadMoreProducts() {
    const loadMoreBtn = document.getElementById('loadMoreBtn');
    const productsGrid = document.getElementById('productsGrid');

    // Show loading state
    loadMoreBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Loading...';
    loadMoreBtn.disabled = true;

    // Simulate API call (replace with actual endpoint)
    setTimeout(() => {
        // Add new products (in real app, this would come from server)
        const newProducts = generateSampleProducts(6);
        const fragment = document.createDocumentFragment();

        newProducts.forEach(product => {
            const productCard = createProductCard(product);
            fragment.appendChild(productCard);
        });

        productsGrid.appendChild(fragment);

        // Reset button state
        loadMoreBtn.innerHTML = '<i class="fas fa-spinner"></i> Load More Products';
        loadMoreBtn.disabled = false;

        // Re-initialize interactions for new cards
        initProductInteractions();

    }, 1500);
}

function initProductInteractions() {
    // Add to cart buttons
    const addToCartBtns = document.querySelectorAll('.add-to-cart-btn');
    addToCartBtns.forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const productId = this.getAttribute('onclick').match(/\d+/)[0];
            addToCart(parseInt(productId));
        });
    });

    // Buy now buttons
    const buyNowBtns = document.querySelectorAll('.buy-now-btn');
    buyNowBtns.forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const productId = this.getAttribute('onclick').match(/\d+/)[0];
            buyNow(parseInt(productId));
        });
    });

    // Wishlist buttons
    const wishlistBtns = document.querySelectorAll('.wishlist-btn');
    wishlistBtns.forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const productId = this.getAttribute('onclick').match(/\d+/)[0];
            addToWishlist(parseInt(productId));
        });
    });
}

function generateSampleProducts(count) {
    const products = [];
    const categories = ['Laptops', 'Phones', 'Audio', 'Accessories', 'Gaming'];

    for (let i = 0; i < count; i++) {
        products.push({
            id: 1000 + i,
            name: `Sample Product ${i + 1}`,
            category: categories[i % categories.length],
            price: (Math.random() * 500 + 50).toFixed(2),
            rating: (Math.random() * 2 + 3).toFixed(1),
            stock: Math.floor(Math.random() * 50),
            imageUrl: '/images/default.jpg'
        });
    }

    return products;
}

function createProductCard(product) {
    const card = document.createElement('div');
    card.className = 'product-card';
    card.setAttribute('data-price', product.price);
    card.setAttribute('data-rating', product.rating);
    card.style.animationDelay = '0s';
    card.style.opacity = '0';

    card.innerHTML = `
        <div class="product-badge">
            <span class="badge trending">Trending</span>
            ${product.price < 100 ? '<span class="badge discount">Hot Deal</span>' : ''}
        </div>
        
        <div class="product-image">
            <img src="${product.imageUrl}" alt="${product.name}" onerror="this.src='/images/default.jpg'">
            <div class="product-actions">
                <button class="action-btn wishlist-btn" onclick="addToWishlist(${product.id})" title="Add to Wishlist">
                    <i class="far fa-heart"></i>
                </button>
                <button class="action-btn compare-btn" onclick="addToCompare(${product.id})" title="Compare">
                    <i class="fas fa-exchange-alt"></i>
                </button>
                <button class="action-btn quick-view-btn" onclick="quickView(${product.id})" title="Quick View">
                    <i class="fas fa-eye"></i>
                </button>
            </div>
        </div>

        <div class="product-content">
            <h3 class="product-title">
                <a href="product_detail?id=${product.id}" class="product-link">${product.name}</a>
            </h3>
            <div class="product-category">${product.category}</div>
            
            <div class="product-rating">
                <div class="stars">
                    ${generateStarsHTML(product.rating)}
                </div>
                <span class="rating-count">(${product.rating})</span>
            </div>

            <div class="product-price">
                <span class="current-price">$${product.price}</span>
                ${product.price > 200 ? `<span class="original-price">$${(parseFloat(product.price) + 50).toFixed(2)}</span>` : ''}
            </div>

            <div class="product-stock">
                ${product.stock > 10 ?
        '<span class="stock in-stock"><i class="fas fa-check"></i> In Stock</span>' :
        product.stock > 0 ?
            `<span class="stock low-stock"><i class="fas fa-exclamation-triangle"></i> Only ${product.stock} left</span>` :
            '<span class="stock out-of-stock"><i class="fas fa-times"></i> Out of Stock</span>'
    }
            </div>

            <div class="product-actions-main">
                <button class="btn add-to-cart-btn" onclick="addToCart(${product.id})" ${product.stock === 0 ? 'disabled' : ''}>
                    <i class="fas fa-shopping-cart"></i>
                    Add to Cart
                </button>
                <a href="product_detail?id=${product.id}" class="btn view-details-btn">
                    <i class="fas fa-eye"></i>
                    Details
                </a>
                <button class="btn buy-now-btn" onclick="buyNow(${product.id})" ${product.stock === 0 ? 'disabled' : ''}>
                    <i class="fas fa-bolt"></i>
                    Buy Now
                </button>
            </div>
        </div>
    `;

    // Animate in
    setTimeout(() => {
        card.style.opacity = '1';
        card.style.transform = 'translateY(0)';
    }, 100);

    return card;
}

function generateStarsHTML(rating) {
    let stars = '';
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 >= 0.5;

    for (let i = 1; i <= 5; i++) {
        if (i <= fullStars) {
            stars += '<i class="fas fa-star"></i>';
        } else if (i === fullStars + 1 && hasHalfStar) {
            stars += '<i class="fas fa-star-half-alt"></i>';
        } else {
            stars += '<i class="far fa-star"></i>';
        }
    }
    return stars;
}

// Global functions for product interactions
window.addToCart = function(productId) {
    fetch('cart/add', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `productId=${productId}&quantity=1`
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                updateCartCount(data.totalItems);
                showNotification('Product added to cart!', 'success');
            } else {
                showNotification('Error adding product to cart', 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showNotification('Error adding product to cart', 'error');
        });
};

window.buyNow = function(productId) {
    addToCart(productId);
    setTimeout(() => {
        window.location.href = 'cart/view';
    }, 1000);
};

window.addToWishlist = function(productId) {
    showNotification('Added to wishlist!', 'success');
};

window.addToCompare = function(productId) {
    showNotification('Added to compare!', 'success');
};

window.quickView = function(productId) {
    showNotification('Quick view feature coming soon!', 'info');
};

function updateCartCount(count) {
    let cartCount = document.querySelector('.cart-count');
    if (!cartCount) {
        const cartLink = document.querySelector('.action-link[href*="cart"]');
        cartCount = document.createElement('span');
        cartCount.className = 'cart-count';
        cartLink.appendChild(cartCount);
    }
    cartCount.textContent = count;
    cartCount.classList.add('pulse');
    setTimeout(() => cartCount.classList.remove('pulse'), 500);
}

function showNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check' : type === 'error' ? 'exclamation-triangle' : 'info'}"></i>
        <span>${message}</span>
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}