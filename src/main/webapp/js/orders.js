document.addEventListener('DOMContentLoaded', function() {
    // DOM Elements
    const statusFilter = document.getElementById('status-filter');
    const dateFilter = document.getElementById('date-filter');
    const orderSearchInput = document.querySelector('.order-search .search-input');
    const ordersList = document.querySelector('.orders-list');
    const orderCards = document.querySelectorAll('.order-card');
    const paginationBtns = document.querySelectorAll('.pagination-btn');
    const pageNumbers = document.querySelectorAll('.page-number');
    const cancelOrderBtns = document.querySelectorAll('.cancel-order');
    const reorderBtns = document.querySelectorAll('.reorder-btn');
    const returnBtns = document.querySelectorAll('.return-btn');
    const reviewBtns = document.querySelectorAll('.review-btn');
    const trackLinks = document.querySelectorAll('.track-link');

    // Filter orders based on status and date
    function filterOrders() {
        const statusValue = statusFilter.value;
        const dateValue = dateFilter.value;
        
        orderCards.forEach(card => {
            const cardStatus = card.classList.contains('processing') ? 'processing' : 
                              card.classList.contains('shipped') ? 'shipped' : 
                              card.classList.contains('delivered') ? 'delivered' : 
                              card.classList.contains('cancelled') ? 'cancelled' : '';
            
            const cardDate = card.querySelector('.order-date').textContent;
            const orderDate = new Date(cardDate.replace('Placed on ', ''));
            const currentDate = new Date();
            const daysDifference = Math.floor((currentDate - orderDate) / (1000 * 60 * 60 * 24));
            
            // Status filter
            const statusMatch = statusValue === 'all' || statusValue === cardStatus;
            
            // Date filter
            let dateMatch = true;
            if (dateValue !== 'all') {
                if (dateValue === '30') {
                    dateMatch = daysDifference <= 30;
                } else if (dateValue === '90') {
                    dateMatch = daysDifference <= 90;
                } else {
                    const year = orderDate.getFullYear();
                    dateMatch = year.toString() === dateValue;
                }
            }
            
            // Show/hide based on filters
            if (statusMatch && dateMatch) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }

    // Search orders
    function searchOrders() {
        const searchTerm = orderSearchInput.value.toLowerCase();
        
        orderCards.forEach(card => {
            const orderNumber = card.querySelector('.order-number').textContent.toLowerCase();
            const orderItems = card.querySelectorAll('.item-info h3');
            let itemMatch = false;
            
            orderItems.forEach(item => {
                if (item.textContent.toLowerCase().includes(searchTerm)) {
                    itemMatch = true;
                }
            });
            
            if (orderNumber.includes(searchTerm) || itemMatch) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }

    // Pagination functionality
    function setupPagination() {
        pageNumbers.forEach(number => {
            number.addEventListener('click', function() {
                // Remove active class from all numbers
                pageNumbers.forEach(num => num.classList.remove('active'));
                
                // Add active class to clicked number
                this.classList.add('active');
                
                // In a real app, you would fetch the orders for this page
                console.log(`Loading page ${this.textContent}`);
            });
        });
        
        paginationBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                if (this.classList.contains('disabled')) return;
                
                const currentActive = document.querySelector('.page-number.active');
                let currentPage = parseInt(currentActive.textContent);
                
                if (this.textContent.includes('Previous')) {
                    if (currentPage > 1) {
                        currentPage--;
                    }
                } else {
                    if (currentPage < 5) { // Assuming 5 is the max page
                        currentPage++;
                    }
                }
                
                // Update active page
                pageNumbers.forEach(num => num.classList.remove('active'));
                pageNumbers[currentPage - 1].classList.add('active');
                
                // In a real app, you would fetch the orders for this page
                console.log(`Loading page ${currentPage}`);
            });
        });
    }

    // Order actions
    function setupOrderActions() {
        // Cancel order
        cancelOrderBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const orderCard = this.closest('.order-card');
                const orderNumber = orderCard.querySelector('.order-number').textContent;
                
                if (confirm(`Are you sure you want to cancel order ${orderNumber}?`)) {
                    // In a real app, you would make an API call here
                    orderCard.classList.remove('processing');
                    orderCard.classList.add('cancelled');
                    orderCard.querySelector('.status-badge').textContent = 'Cancelled';
                    orderCard.querySelector('.status-badge').className = 'status-badge';
                    
                    // Remove cancel button and add reorder
                    const actionsDiv = orderCard.querySelector('.order-actions');
                    this.remove();
                    actionsDiv.innerHTML += '<button class="reorder-btn">Reorder</button>';
                    
                    // Re-attach event listeners
                    setupOrderActions();
                }
            });
        });
        
        // Reorder
        reorderBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const orderCard = this.closest('.order-card');
                const orderNumber = orderCard.querySelector('.order-number').textContent;
                
                // In a real app, you would add these items to cart
                console.log(`Reordering ${orderNumber}`);
                alert('Items from this order have been added to your cart!');
            });
        });
        
        // Return item
        returnBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const orderCard = this.closest('.order-card');
                const orderNumber = orderCard.querySelector('.order-number').textContent;
                
                // In a real app, you would open a return form
                console.log(`Initiating return for ${orderNumber}`);
                alert('Return request initiated. Our team will contact you shortly.');
            });
        });
        
        // Write review
        reviewBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const orderItem = this.closest('.order-item');
                const productName = orderItem.querySelector('h3').textContent;
                
                // In a real app, you would open a review modal
                console.log(`Writing review for ${productName}`);
                alert(`Review form for ${productName} will open here.`);
            });
        });
        
        // Track package
        trackLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                const trackingNumber = this.previousElementSibling.textContent.replace('Tracking #: ', '');
                
                // In a real app, you would redirect to tracking service
                console.log(`Tracking package with number ${trackingNumber}`);
                alert(`Redirecting to tracking service for ${trackingNumber}`);
            });
        });
    }

    // View order details
    function setupViewOrderLinks() {
        const viewOrderLinks = document.querySelectorAll('.view-order');
        
        viewOrderLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                const orderNumber = this.getAttribute('href');
                
                // In a real app, you would redirect to order details page
                console.log(`Viewing details for order ${orderNumber}`);
                alert(`This would show details for order ${orderNumber}`);
            });
        });
    }

    // Initialize all functionality
    function init() {
        // Event listeners for filters
        statusFilter.addEventListener('change', filterOrders);
        dateFilter.addEventListener('change', filterOrders);
        
        // Event listener for search
        orderSearchInput.addEventListener('input', searchOrders);
        
        // Setup pagination
        setupPagination();
        
        // Setup order actions
        setupOrderActions();
        
        // Setup view order links
        setupViewOrderLinks();
    }

    // Initialize the script
    init();
});