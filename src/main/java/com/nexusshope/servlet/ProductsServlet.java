// File: com/nexusshope/servlet/ProductsServlet.java
package com.nexusshope.servlet;

import com.nexusshope.model.Product;
import com.nexusshope.model.ProductImage;
import com.nexusshope.service.ProductService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/products")
public class ProductsServlet extends HttpServlet {
    private ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String category = request.getParameter("category");
        String priceMin = request.getParameter("price_min");
        String priceMax = request.getParameter("price_max");

        try {
            List<Product> products;
            Double minPrice = null, maxPrice = null;

            // Parse price filters
            if (priceMin != null && !priceMin.trim().isEmpty()) {
                minPrice = Double.parseDouble(priceMin);
            }
            if (priceMax != null && !priceMax.trim().isEmpty()) {
                maxPrice = Double.parseDouble(priceMax);
            }

            if (search != null && !search.trim().isEmpty()) {
                // Search products
                products = productService.getApprovedProducts(search.trim(), category, minPrice, maxPrice);
                request.setAttribute("searchQuery", search.trim());
            } else if (category != null && !category.trim().isEmpty()) {
                // Filter by category
                products = productService.getApprovedProducts(null, category.trim(), minPrice, maxPrice);
                request.setAttribute("selectedCategory", category.trim());
            } else {
                // Get all approved products
                products = productService.getApprovedProducts(null, null, minPrice, maxPrice);
            }

            // Load product images for each product
            Map<String, String> productImageMap = new HashMap<>();
            for (Product product : products) {
                try {
                    List<ProductImage> images = productService.getProductImages(product.getProductID());
                    if (images != null && !images.isEmpty()) {
                        // Find primary image or use first image
                        String imageUrl = images.stream()
                                .filter(ProductImage::isPrimary)
                                .findFirst()
                                .orElse(images.get(0))
                                .getImageUrl();
                        productImageMap.put(product.getProductID(), imageUrl);
                    }
                } catch (SQLException e) {
                    // Log error but continue with other products
                    System.err.println("Error loading images for product " + product.getProductID() + ": " + e.getMessage());
                }
            }

            // Get unique categories for filter
            List<String> categories = getUniqueCategories();

            request.setAttribute("categories", categories);
            request.setAttribute("products", products);
            request.setAttribute("productImageMap", productImageMap);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load products: " + e.getMessage());
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price format");
        }

        request.getRequestDispatcher("/products.jsp").forward(request, response);
    }

    private List<String> getUniqueCategories() throws SQLException {
        // You can implement this to get unique categories from database
        // For now, return some common categories
        ProductService productService = new ProductService();
        List<Product> allProducts = productService.getApprovedProducts(null, null, null, null);
        return allProducts.stream()
                .map(Product::getCategory)
                .distinct()
                .collect(java.util.stream.Collectors.toList());
    }
}