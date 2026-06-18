document.addEventListener('DOMContentLoaded', function() {
    // Load recent orders from API (simulated)
    function loadRecentOrders() {
        // In a real app, this would fetch from your backend API
        console.log('Loading recent orders...');
        
        // Simulate API call
        setTimeout(() => {
            // Update UI with real data
            console.log('Recent orders loaded');
        }, 500);
    }
    
    // Load account stats from API (simulated)
    function loadAccountStats() {
        console.log('Loading account stats...');
        
        // Simulate API call
        setTimeout(() => {
            // Update UI with real data
            console.log('Account stats loaded');
        }, 500);
    }
    
    // Initialize the dashboard
    function initDashboard() {
        loadRecentOrders();
        loadAccountStats();
    }
    
    // Initialize the dashboard when the page loads
    initDashboard();
    
    // Mobile menu toggle for account sidebar
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const accountSidebar = document.querySelector('.account-sidebar');
    
    if (mobileMenuBtn && accountSidebar) {
        mobileMenuBtn.addEventListener('click', function() {
            accountSidebar.classList.toggle('mobile-visible');
        });
    }
    
    // Logout functionality
    const logoutLink = document.querySelector('.account-menu a[href="../logout"]');
    if (logoutLink) {
        logoutLink.addEventListener('click', function(e) {
            e.preventDefault();
            // In a real app, this would call your logout API
            console.log('User logged out');
            // Redirect to homepage
            window.location.href = '../index.jsp';
        });
    }
});
