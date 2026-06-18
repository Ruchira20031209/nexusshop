document.addEventListener('DOMContentLoaded', function() {
    // FAQ Accordion Functionality
    const faqItems = document.querySelectorAll('.faq-item');
    
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        
        question.addEventListener('click', () => {
            // Close all other items
            faqItems.forEach(otherItem => {
                if (otherItem !== item) {
                    otherItem.classList.remove('active');
                    otherItem.querySelector('.faq-answer').style.maxHeight = '0';
                }
            });
            
            // Toggle current item
            item.classList.toggle('active');
            const answer = item.querySelector('.faq-answer');
            
            if (item.classList.contains('active')) {
                answer.style.maxHeight = answer.scrollHeight + 'px';
            } else {
                answer.style.maxHeight = '0';
            }
        });
    });
    
    // FAQ Category Tabs
    const categories = document.querySelectorAll('.category');
    const categoryContents = document.querySelectorAll('.faq-category-content');
    
    categories.forEach(category => {
        category.addEventListener('click', () => {
            // Remove active class from all categories
            categories.forEach(cat => cat.classList.remove('active'));
            
            // Add active class to clicked category
            category.classList.add('active');
            
            // Get the category to show
            const categoryToShow = category.dataset.category;
            
            // Hide all category contents
            categoryContents.forEach(content => content.classList.remove('active'));
            
            // Show the selected category content
            document.getElementById(`${categoryToShow}-faqs`).classList.add('active');
            
            // Scroll to the top of the FAQ content
            document.querySelector('.faq-content').scrollIntoView({
                behavior: 'smooth'
            });
        });
    });
    
    // Search FAQ Functionality
    const searchInput = document.querySelector('.search-faq input');
    const searchButton = document.querySelector('.search-faq button');
    
    function searchFAQs() {
        const searchTerm = searchInput.value.toLowerCase().trim();
        
        if (searchTerm === '') {
            // Reset to default view if search is empty
            categories[0].click();
            return;
        }
        
        // Hide all category tabs
        categories.forEach(cat => cat.style.display = 'none');
        
        // Show all FAQ items and category contents
        faqItems.forEach(item => item.style.display = '');
        categoryContents.forEach(content => content.classList.add('active'));
        
        // Hide items that don't match the search
        let hasResults = false;
        
        faqItems.forEach(item => {
            const question = item.querySelector('h3').textContent.toLowerCase();
            const answer = item.querySelector('p').textContent.toLowerCase();
            
            if (question.includes(searchTerm) || answer.includes(searchTerm)) {
                item.style.display = '';
                hasResults = true;
            } else {
                item.style.display = 'none';
            }
        });
        
        // Show message if no results
        const noResults = document.createElement('div');
        noResults.className = 'no-results';
        noResults.innerHTML = `
            <i class="fas fa-search"></i>
            <h3>No results found for "${searchTerm}"</h3>
            <p>Try different keywords or check our <a href="contact.jsp">contact page</a> for help.</p>
        `;
        
        const faqContent = document.querySelector('.faq-content');
        const existingNoResults = document.querySelector('.no-results');
        
        if (!hasResults) {
            if (!existingNoResults) {
                faqContent.appendChild(noResults);
            }
        } else {
            if (existingNoResults) {
                existingNoResults.remove();
            }
        }
    }
    
    searchButton.addEventListener('click', searchFAQs);
    searchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            searchFAQs();
        }
    });
    
    // Initialize with first category active
    if (categories.length > 0) {
        categories[0].click();
    }
    
    // Mobile menu toggle
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const mainNav = document.querySelector('.main-nav');
    
    mobileMenuBtn.addEventListener('click', () => {
        mobileMenuBtn.classList.toggle('active');
        mainNav.classList.toggle('active');
    });
});
