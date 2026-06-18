// Main JavaScript for the e-commerce site
document.addEventListener('DOMContentLoaded', function() {
    // Mobile menu toggle
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const mainNav = document.querySelector('.main-nav');
    
    if (mobileMenuBtn && mainNav) {
        mobileMenuBtn.addEventListener('click', function() {
            mainNav.classList.toggle('active');
            mobileMenuBtn.classList.toggle('active');
        });
    }
    
    // Header scroll behavior
    const header = document.querySelector('.header');
    let lastScroll = 0;
    
    window.addEventListener('scroll', function() {
        const currentScroll = window.pageYOffset;
        
        if (currentScroll <= 0) {
            header.classList.remove('scroll-up');
            return;
        }
        
        if (currentScroll > lastScroll && !header.classList.contains('scroll-down')) {
            header.classList.remove('scroll-up');
            header.classList.add('scroll-down');
        } else if (currentScroll < lastScroll && header.classList.contains('scroll-down')) {
            header.classList.remove('scroll-down');
            header.classList.add('scroll-up');
        }
        
        lastScroll = currentScroll;
    });
    
    // View toggle for products
    const viewButtons = document.querySelectorAll('.view-btn');
    const productsContainer = document.getElementById('productsContainer');
    
    if (viewButtons && productsContainer) {
        viewButtons.forEach(button => {
            button.addEventListener('click', function() {
                // Remove active class from all buttons
                viewButtons.forEach(btn => btn.classList.remove('active'));
                // Add active class to clicked button
                this.classList.add('active');
                
                // Change view based on data-view attribute
                const viewType = this.getAttribute('data-view');
                productsContainer.className = 'products-container ' + viewType + '-view';
            });
        });
    }
    
    // Load more products functionality
    const loadMoreBtn = document.getElementById('loadMoreBtn');
    const showAllBtn = document.getElementById('showAllBtn');
    const showLessBtn = document.getElementById('showLessBtn');
    
    if (loadMoreBtn && showAllBtn && showLessBtn) {
        loadMoreBtn.addEventListener('click', function() {
            // Simulate loading more products
            console.log('Loading more products...');
            // In a real app, you would fetch more products from an API
        });
        
        showAllBtn.addEventListener('click', function() {
            // Show all products
            console.log('Showing all products...');
            this.style.display = 'none';
            showLessBtn.style.display = 'inline-block';
        });
        
        showLessBtn.addEventListener('click', function() {
            // Show less products
            console.log('Showing less products...');
            this.style.display = 'none';
            showAllBtn.style.display = 'inline-block';
        });
    }
});