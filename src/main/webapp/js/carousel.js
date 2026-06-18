// Hero Carousel Functionality
document.addEventListener('DOMContentLoaded', function() {
    const carouselTrack = document.querySelector('.carousel-track');
    const carouselSlides = document.querySelectorAll('.carousel-slide');
    const prevBtn = document.querySelector('.control-prev');
    const nextBtn = document.querySelector('.control-next');
    const dotsContainer = document.querySelector('.carousel-dots');
    const priceTag = document.querySelector('.price-tag');
    const oldPrice = document.querySelector('.old-price');
    const newPrice = document.querySelector('.new-price');
    
    if (!carouselTrack || !carouselSlides.length) return;
    
    let currentIndex = 0;
    const slideCount = carouselSlides.length;
    
    // Create dots
    carouselSlides.forEach((_, index) => {
        const dot = document.createElement('div');
        dot.classList.add('dot');
        if (index === 0) dot.classList.add('active');
        dot.addEventListener('click', () => goToSlide(index));
        dotsContainer.appendChild(dot);
    });
    
    const dots = document.querySelectorAll('.carousel-dots .dot');
    
    // Update carousel position
    function updateCarousel() {
        carouselTrack.style.transform = `translateX(-${currentIndex * 100}%)`;
        
        // Update active slide
        carouselSlides.forEach((slide, index) => {
            if (index === currentIndex) {
                slide.classList.add('active');
                // Update price tag
                const oldPriceValue = slide.getAttribute('data-price-old');
                const newPriceValue = slide.getAttribute('data-price-new');
                oldPrice.textContent = `$${oldPriceValue}`;
                newPrice.textContent = `$${newPriceValue}`;
            } else {
                slide.classList.remove('active');
            }
        });
        
        // Update active dot
        dots.forEach((dot, index) => {
            if (index === currentIndex) {
                dot.classList.add('active');
            } else {
                dot.classList.remove('active');
            }
        });
    }
    
    // Go to specific slide
    function goToSlide(index) {
        currentIndex = index;
        updateCarousel();
    }
    
    // Next slide
    function nextSlide() {
        currentIndex = (currentIndex + 1) % slideCount;
        updateCarousel();
    }
    
    // Previous slide
    function prevSlide() {
        currentIndex = (currentIndex - 1 + slideCount) % slideCount;
        updateCarousel();
    }
    
    // Event listeners
    if (prevBtn) prevBtn.addEventListener('click', prevSlide);
    if (nextBtn) nextBtn.addEventListener('click', nextSlide);
    
    // Auto-rotate carousel
    let carouselInterval = setInterval(nextSlide, 5000);
    
    // Pause on hover
    carouselTrack.addEventListener('mouseenter', () => {
        clearInterval(carouselInterval);
    });
    
    carouselTrack.addEventListener('mouseleave', () => {
        carouselInterval = setInterval(nextSlide, 5000);
    });
    
    // Initialize
    updateCarousel();
    
    // Special offers slider
    const offerSlides = document.querySelectorAll('.offer-slide');
    if (offerSlides.length > 1) {
        let offerIndex = 0;
        
        function updateOfferSlider() {
            offerSlides.forEach((slide, index) => {
                if (index === offerIndex) {
                    slide.classList.add('active');
                } else {
                    slide.classList.remove('active');
                }
            });
            
            offerIndex = (offerIndex + 1) % offerSlides.length;
        }
        
        setInterval(updateOfferSlider, 5000);
    }
});