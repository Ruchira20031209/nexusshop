// home-products.js - Load products for homepage sections
document.addEventListener('DOMContentLoaded', function() {
    // Load trending products
    loadTrendingProducts();

    // Load featured products
    loadFeaturedProducts();
});

function loadTrendingProducts() {
    fetch('products?limit=8')
        .then(response => response.json())
        .then(data => {
            const container = document.getElementById('trendingProducts');
            if (data.products && data.products.length > 0) {
                container.innerHTML = data.products.map(product => `
                    <div class="product-card">
                        <div class="product-image">
                            <img src="${product.imageUrl}" alt="${product.name}" onerror="this.src='/images/default.jpg'">
                            <div class="product-actions">
                                <a href="product_detail?id=${product.id}" class="view-btn">
                                    <i class="fas fa-eye"></i> View Details
                                </a>
                                <button class="add-to-cart-btn" onclick="addToCart(${product.id})">
                                    <i class="fas fa-shopping-cart"></i> Add to Cart
                                </button>
                            </div>
                        </div>
                        <div class="product-info">
                            <h4 class="product-title">${product.name}</h4>
                            <div class="product-price">
                                <span class="current-price">$${product.price.toFixed(2)}</span>
                            </div>
                            <div class="product-rating">
                                <div class="stars">
                                    ${generateStars(product.rating)}
                                </div>
                            </div>
                        </div>
                    </div>
                `).join('');
            } else {
                container.innerHTML = '<p>No trending products found.</p>';
            }
        })
        .catch(error => {
            console.error('Error loading trending products:', error);
            document.getElementById('trendingProducts').innerHTML = '<p>Error loading products.</p>';
        });
}

function loadFeaturedProducts() {
    fetch('products?limit=12')
        .then(response => response.json())
        .then(data => {
            const container = document.getElementById('featuredProducts');
            if (data.products && data.products.length > 0) {
                container.innerHTML = data.products.map(product => `
                    <div class="product-card">
                        <div class="product-image">
                            <img src="${product.imageUrl}" alt="${product.name}" onerror="this.src='/images/default.jpg'">
                            <div class="product-actions">
                                <a href="product_detail?id=${product.id}" class="view-btn">
                                    <i class="fas fa-eye"></i> View Details
                                </a>
                                <button class="add-to-cart-btn" onclick="addToCart(${product.id})">
                                    <i class="fas fa-shopping-cart"></i> Add to Cart
                                </button>
                            </div>
                        </div>
                        <div class="product-info">
                            <h4 class="product-title">${product.name}</h4>
                            <div class="product-price">
                                <span class="current-price">$${product.price.toFixed(2)}</span>
                            </div>
                            <div class="product-rating">
                                <div class="stars">
                                    ${generateStars(product.rating)}
                                </div>
                            </div>
                        </div>
                    </div>
                `).join('');
            } else {
                container.innerHTML = '<p>No featured products found.</p>';
            }
        })
        .catch(error => {
            console.error('Error loading featured products:', error);
            document.getElementById('featuredProducts').innerHTML = '<p>Error loading products.</p>';
        });
}

function generateStars(rating) {
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

function addToCart(productId) {
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
                // Update cart count
                const cartCount = document.querySelector('.cart-count');
                if (cartCount) {
                    cartCount.textContent = data.totalItems;
                    cartCount.classList.add('pulse');
                    setTimeout(() => cartCount.classList.remove('pulse'), 500);
                }

                // Show success message
                showNotification('Product added to cart!', 'success');
            } else {
                showNotification('Error adding product to cart', 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showNotification('Error adding product to cart', 'error');
        });
}

function showNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 5px;
        color: white;
        z-index: 10000;
        font-weight: 500;
        animation: slideInRight 0.3s ease;
    `;

    if (type === 'success') {
        notification.style.background = 'var(--success)';
    } else {
        notification.style.background = 'var(--danger)';
    }

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}