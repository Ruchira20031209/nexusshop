// product-detail.js (unchanged, as not relevant to issues)
document.addEventListener('DOMContentLoaded', function() {
    // Thumbnail image switcher
    const thumbnails = document.querySelectorAll('.thumbnail');
    const mainImage = document.getElementById('mainProductImage');

    thumbnails.forEach(thumbnail => {
        thumbnail.addEventListener('click', function() {
            // Remove active class from all thumbnails
            thumbnails.forEach(t => t.classList.remove('active'));

            // Add active class to clicked thumbnail
            this.classList.add('active');

            // Change main image
            const newImageSrc = this.getAttribute('data-image');
            mainImage.src = newImageSrc;
        });
    });

    // Color variant selector
    const colorOptions = document.querySelectorAll('.color-option');

    colorOptions.forEach(option => {
        option.addEventListener('click', function() {
            // Remove active class from all color options
            colorOptions.forEach(o => o.classList.remove('active'));

            // Add active class to clicked option
            this.classList.add('active');

            // In a real app, you would update the product image/variant here
            console.log('Selected color:', this.getAttribute('data-color'));
        });
    });

    // Storage variant selector
    const storageOptions = document.querySelectorAll('.storage-option');

    storageOptions.forEach(option => {
        option.addEventListener('click', function() {
            // Remove active class from all storage options
            storageOptions.forEach(o => o.classList.remove('active'));

            // Add active class to clicked option
            this.classList.add('active');

            // In a real app, you would update the product price/variant here
            console.log('Selected storage:', this.textContent);
        });
    });

    // Memory variant selector
    const memoryOptions = document.querySelectorAll('.memory-option');

    memoryOptions.forEach(option => {
        option.addEventListener('click', function() {
            // Remove active class from all memory options
            memoryOptions.forEach(o => o.classList.remove('active'));

            // Add active class to clicked option
            this.classList.add('active');

            // In a real app, you would update the product price/variant here
            console.log('Selected memory:', this.textContent);
        });
    });

    // Quantity selector
    const minusBtn = document.querySelector('.quantity-btn.minus');
    const plusBtn = document.querySelector('.quantity-btn.plus');
    const quantityInput = document.querySelector('.quantity-input');

    minusBtn.addEventListener('click', function() {
        let currentValue = parseInt(quantityInput.value);
        if (currentValue > 1) {
            quantityInput.value = currentValue - 1;
        }
    });

    plusBtn.addEventListener('click', function() {
        let currentValue = parseInt(quantityInput.value);
        quantityInput.value = currentValue + 1;
    });

    // Add to cart button
    const addToCartBtn = document.querySelector('.add-to-cart-btn');
    addToCartBtn.addEventListener('click', function() {
        // In a real app, this would add the product to cart
        console.log('Added to cart');
    });

    // Buy now button
    const buyNowBtn = document.querySelector('.buy-now-btn');
    buyNowBtn.addEventListener('click', function() {
        // In a real app, this would proceed to checkout
        console.log('Proceeding to checkout');
    });

    // Tabs functionality
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            const tabId = this.getAttribute('data-tab');

            // Remove active from all buttons and contents
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));

            // Add active to clicked button and corresponding content
            this.classList.add('active');
            document.getElementById(tabId).classList.add('active');
        });
    });

    // Load recently viewed products (sample data)
    const recentlyViewedGrid = document.querySelector('.recently-viewed-grid');
    if (recentlyViewedGrid) {
        const recentlyViewed = [
            {
                id: 9,
                name: "AirPods Pro 2",
                price: 249.99,
                originalPrice: null,
                image: "images/products/airpods-pro.jpg",
                rating: 4.8,
                reviews: 156,
                badge: "New"
            },
            {
                id: 10,
                name: "Google Pixel 7",
                price: 599.99,
                originalPrice: 699.99,
                image: "images/products/pixel-7.jpg",
                rating: 4.5,
                reviews: 112,
                badge: null
            },
            {
                id: 11,
                name: "Sony PlayStation 5",
                price: 499.99,
                originalPrice: null,
                image: "images/products/ps5.jpg",
                rating: 4.9,
                reviews: 345,
                badge: "Popular"
            },
            {
                id: 12,
                name: "Microsoft Surface Pro 9",
                price: 999.99,
                originalPrice: 1099.99,
                image: "images/products/surface-pro.jpg",
                rating: 4.4,
                reviews: 78,
                badge: "Deal"
            },
            {
                id: 13,
                name: "JBL Flip 6",
                price: 129.99,
                originalPrice: null,
                image: "images/products/jbl-flip.jpg",
                rating: 4.6,
                reviews: 201,
                badge: null
            },
            {
                id: 14,
                name: "Apple Pencil 2",
                price: 129.99,
                originalPrice: null,
                image: "images/products/apple-pencil.jpg",
                rating: 4.7,
                reviews: 89,
                badge: null
            },
            {
                id: 15,
                name: "Mac Mini M2",
                price: 599.99,
                originalPrice: 699.99,
                image: "images/products/mac-mini.jpg",
                rating: 4.6,
                reviews: 47,
                badge: "Deal"
            }
        ];

        recentlyViewed.forEach(product => {
            const productCard = createProductCard(product);
            recentlyViewedGrid.appendChild(productCard);
        });
    }

    // Helper function to create product cards
    function createProductCard(product) {
        const card = document.createElement('div');
        card.className = 'product-card';
        card.innerHTML = `
            ${product.badge ? `<span class="product-badge">${product.badge}</span>` : ''}
            <div class="product-image">
                <img src="${product.image}" alt="${product.name}">
                <div class="product-actions">
                    <button class="view-btn">
                        <i class="fas fa-eye"></i> Quick View
                    </button>
                </div>
            </div>
            <div class="product-info">
                <h4 class="product-title">${product.name}</h4>
                <div class="product-price">
                    <span class="current-price">$${product.price.toFixed(2)}</span>
                    ${product.originalPrice ? `<span class="original-price">$${product.originalPrice.toFixed(2)}</span>` : ''}
                </div>
                <div class="product-rating">
                    <div class="stars">
                        ${generateStars(product.rating)}
                    </div>
                    <span class="rating-count">(${product.reviews})</span>
                </div>
            </div>
        `;

        // Add click event to quick view button
        const quickViewBtn = card.querySelector('.view-btn');
        quickViewBtn.addEventListener('click', function() {
            // In a real app, this would open a quick view modal
            console.log('Quick view:', product.name);
        });

        return card;
    }

    // Helper function to generate star rating HTML
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
});