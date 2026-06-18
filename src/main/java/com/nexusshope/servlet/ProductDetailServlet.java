// File: com/nexusshope/servlet/ProductDetailServlet.java
package com.nexusshope.servlet;

import com.nexusshope.model.Product;
import com.nexusshope.model.ProductImage;
import com.nexusshope.model.ProductSpecification;
import com.nexusshope.service.ProductService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

@WebServlet("/product-detail")
public class ProductDetailServlet extends HttpServlet {
    private ProductService productService = new ProductService();

    // Track product view counts (in-memory, consider database for persistence)
    private static final ConcurrentHashMap<String, AtomicInteger> productViewCounts = new ConcurrentHashMap<>();

    // Track recently viewed products per session
    private static final int MAX_RECENT_VIEWS = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productId = request.getParameter("id");

        // Log the request for debugging
        log("Product detail request for ID: " + productId + " from IP: " + getClientIP(request));

        if (productId == null || productId.trim().isEmpty()) {
            handleError(request, response, "Product ID is required.", 400);
            return;
        }

        // Validate product ID format
        if (!isValidProductId(productId)) {
            handleError(request, response, "Invalid product ID format.", 400);
            return;
        }

        try {
            // Get product details
            Product product = productService.getProductById(productId);

            if (product == null) {
                handleError(request, response, "Product not found with ID: " + productId, 404);
                return;
            }

            // Check if product is approved (only show approved products to customers)
            if (!"approved".equalsIgnoreCase(product.getStatus())) {
                handleError(request, response, "This product is not available for viewing.", 404);
                return;
            }

            // In your ProductDetailServlet, update the image loading section:
// Get product images
            List<ProductImage> productImages = new ArrayList<>();
            try {
                productImages = productService.getProductImages(productId);

                // Fix image URLs by adding context path if needed
                for (ProductImage image : productImages) {
                    String imageUrl = image.getImageUrl();
                    if (imageUrl != null && !imageUrl.startsWith("http") && !imageUrl.startsWith("/")) {
                        // If it's a relative path without leading slash, add one
                        image.setImageUrl("/" + imageUrl);
                    }
                }
            } catch (SQLException e) {
                log("Error loading product images for product ID: " + productId, e);
                // Continue without images rather than failing completely
            }

            // Get product specifications
            List<ProductSpecification> productSpecs = new ArrayList<>();
            try {
                productSpecs = productService.getProductSpecifications(productId);
            } catch (SQLException e) {
                log("Error loading product specifications for product ID: " + productId, e);
                // Continue without specs rather than failing completely
            }

            // Track product view
            trackProductView(productId, request);

            // Set attributes for JSP
            request.setAttribute("product", product);
            request.setAttribute("productImages", productImages);
            request.setAttribute("productSpecs", productSpecs);

            // Set recent products in session
            setRecentViewedProduct(request, product);

            // Forward to JSP
            request.getRequestDispatcher("/productdetail.jsp").forward(request, response);

        } catch (SQLException e) {
            log("Database error while loading product with ID: " + productId, e);
            handleError(request, response, "Database error occurred. Please try again later.", 500);
        } catch (Exception e) {
            log("Unexpected error while loading product with ID: " + productId, e);
            handleError(request, response, "An unexpected error occurred. Please try again.", 500);
        }
    }

    /**
     * Handle errors with proper status codes and logging
     */
    private void handleError(HttpServletRequest request, HttpServletResponse response,
                             String errorMessage, int statusCode) throws ServletException, IOException {
        log("Product detail error: " + errorMessage);
        response.setStatus(statusCode);
        request.setAttribute("error", errorMessage);
        request.getRequestDispatcher("/productdetail.jsp").forward(request, response);
    }

    /**
     * Validate product ID format (P followed by digits)
     */
    private boolean isValidProductId(String productId) {
        return productId != null && productId.matches("P\\d+");
    }

    /**
     * Track product views with thread-safe counter
     */
    private void trackProductView(String productId, HttpServletRequest request) {
        // Increment global view count
        productViewCounts.computeIfAbsent(productId, k -> new AtomicInteger(0)).incrementAndGet();

        // Log view for analytics
        String clientIP = getClientIP(request);
        String userAgent = request.getHeader("User-Agent");
        log("Product view - ID: " + productId + ", IP: " + clientIP + ", User-Agent: " +
                (userAgent != null ? userAgent.substring(0, Math.min(userAgent.length(), 50)) : "Unknown"));
    }

    /**
     * Get client IP address
     */
    private String getClientIP(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    /**
     * Add product to recently viewed list in session
     */
    private void setRecentViewedProduct(HttpServletRequest request, Product product) {
        HttpSession session = request.getSession();

        @SuppressWarnings("unchecked")
        List<Product> recentProducts = (List<Product>) session.getAttribute("recentlyViewed");

        if (recentProducts == null) {
            recentProducts = new ArrayList<>();
        }

        // Remove if already exists (to avoid duplicates)
        recentProducts.removeIf(p -> p.getProductID().equals(product.getProductID()));

        // Add to beginning
        recentProducts.add(0, product);

        // Limit size
        if (recentProducts.size() > MAX_RECENT_VIEWS) {
            recentProducts = recentProducts.subList(0, MAX_RECENT_VIEWS);
        }

        session.setAttribute("recentlyViewed", recentProducts);
    }

    /**
     * Get view count for a specific product
     */
    public static int getProductViewCount(String productId) {
        AtomicInteger count = productViewCounts.get(productId);
        return count != null ? count.get() : 0;
    }

    /**
     * Get all product view counts (for admin purposes)
     */
    public static ConcurrentHashMap<String, AtomicInteger> getAllProductViewCounts() {
        return new ConcurrentHashMap<>(productViewCounts);
    }

    /**
     * Reset view counts (useful for testing)
     */
    public static void resetViewCounts() {
        productViewCounts.clear();
    }

    @Override
    public void init() throws ServletException {
        log("ProductDetailServlet initialized");
    }

    @Override
    public void destroy() {
        log("ProductDetailServlet destroyed. Total products tracked: " + productViewCounts.size());
        productViewCounts.clear();
    }
}