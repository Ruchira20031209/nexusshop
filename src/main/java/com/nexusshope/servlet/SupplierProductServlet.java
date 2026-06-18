package com.nexusshope.servlet;

import com.nexusshope.model.Product;
import com.nexusshope.model.ProductImage;
import com.nexusshope.model.User;
import com.nexusshope.service.ProductService;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/supplier/products") // ✅ Changed from "/supplier" to "/supplier/products"
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class SupplierProductServlet extends HttpServlet {

    private ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isSupplier(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) request.getSession().getAttribute("user");
        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                request.getRequestDispatcher("/supplier/add-product.jsp").forward(request, response);
            } else if ("edit".equals(action)) {
                String productID = request.getParameter("productID");
                Product product = productService.getProductById(productID);
                if (product != null && product.getSupplierId().equals(user.getUserId())) {
                    List<ProductImage> images = productService.getProductImages(productID);
                    request.setAttribute("product", product);
                    request.setAttribute("images", images);
                    request.getRequestDispatcher("/supplier/edit-product.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Product not found or access denied.");
                    listProducts(request, response, user.getUserId());
                }
            } else {
                listProducts(request, response, user.getUserId());
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                listProducts(request, response, user.getUserId());
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isSupplier(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) request.getSession().getAttribute("user");
        String action = request.getParameter("action");

        try {
            if ("create".equals(action)) {
                Product product = createProductFromRequest(request, user.getUserId());
                String newId = productService.addProduct(product);

                if (newId == null || newId.trim().isEmpty()) {
                    request.setAttribute("error", "Failed to create product. Please try again.");
                    doGet(request, response);
                    return;
                }

                // Only handle images if product ID is valid
                handleImageUploads(request, newId);

                HttpSession session = request.getSession();
                session.setAttribute("message", "Product added successfully! ID: " + newId);
                response.sendRedirect(request.getContextPath() + "/supplier/products");
            } else if ("update".equals(action)) {
                String productID = request.getParameter("productID");
                Product existing = productService.getProductById(productID);

                if (existing != null && existing.getSupplierId().equals(user.getUserId())) {
                    Product updated = createProductFromRequest(request, user.getUserId());
                    updated.setProductID(productID);
                    productService.updateProduct(updated);

                    // Handle image uploads
                    handleImageUploads(request, productID);

                    HttpSession session = request.getSession();
                    session.setAttribute("message", "Product updated successfully!");
                    response.sendRedirect(request.getContextPath() + "/supplier/products");
                } else {
                    request.setAttribute("error", "Access denied or product not found.");
                    doGet(request, response);
                }
            } else if ("delete".equals(action)) {
                String productID = request.getParameter("productID");
                Product product = productService.getProductById(productID);

                if (product != null && product.getSupplierId().equals(user.getUserId())) {
                    productService.deleteProduct(productID);
                    HttpSession session = request.getSession();
                    session.setAttribute("message", "Product deleted successfully!");
                }
                response.sendRedirect(request.getContextPath() + "/supplier/products");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Operation failed: " + e.getMessage());
            doGet(request, response);
        }
    }

    private Product createProductFromRequest(HttpServletRequest request, String supplierId) {
        Product product = new Product();
        product.setName(request.getParameter("name"));
        product.setSku(request.getParameter("sku"));
        product.setCategory(request.getParameter("category"));
        product.setPrice(Double.parseDouble(request.getParameter("price")));
        product.setStock(Integer.parseInt(request.getParameter("stock")));
        product.setDescription(request.getParameter("description"));
        product.setSupplierId(supplierId);
        product.setStatus("pending"); // Default status for new products

        // Handle rating
        String ratingParam = request.getParameter("rating");
        if (ratingParam != null && !ratingParam.trim().isEmpty()) {
            product.setRating(Float.parseFloat(ratingParam));
        }
        return product;
    }

    private void handleImageUploads(HttpServletRequest request, String productID) throws IOException, ServletException {
        try {
            for (Part part : request.getParts()) {
                if (part.getName().startsWith("image") && part.getSize() > 0) {
                    String fileName = extractFileName(part);
                    String filePath = "/images/products/" + productID + "/" + fileName;
                    part.write(request.getServletContext().getRealPath(filePath));
                    ProductImage image = new ProductImage();
                    image.setProductID(productID); // ← What if this is never called?
                    image.setImageUrl(filePath);
                    image.setPrimary("image1".equals(part.getName()));
                    productService.addProductImage(image);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Failed to save product images", e);
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response, String supplierId)
            throws ServletException, IOException, SQLException {
        List<Product> products = productService.getProductsBySupplier(supplierId);
        request.setAttribute("products", products);
        request.getRequestDispatcher("/supplier/products.jsp").forward(request, response);
    }

    private boolean isSupplier(HttpServletRequest request) {
        User user = (User) request.getSession().getAttribute("user");
        return user != null && "supplier".equals(user.getRole());
    }
}
