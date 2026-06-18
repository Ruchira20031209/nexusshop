package com.nexusshope.servlet;

import com.nexusshope.model.Product;
import com.nexusshope.model.ProductImage;
import com.nexusshope.model.ProductSpecification;
import com.nexusshope.model.User;
import com.nexusshope.service.ProductService;
import com.nexusshope.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/supplier/product")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class ProductServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ProductServlet.class.getName());
    private ProductService productService = new ProductService();
    private UserService userService = new UserService(); // Make sure you have getSupplierSID method!

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isSupplier(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String userId = ((User) request.getSession().getAttribute("user")).getUserId();
        String supplierId;
        try {
            supplierId = userService.getSupplierSID(userId);
            if (supplierId == null) {
                request.setAttribute("error", "Invalid supplier ID");
                listProducts(request, response, supplierId); // Will fail, but handle
                return;
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching supplier ID: " + e.getMessage());
            request.setAttribute("error", "Error fetching supplier ID");
            try {
                listProducts(request, response, ""); // Dummy to avoid null
            } catch (SQLException ex) {
                throw new ServletException("Nested error", ex);
            }
            return;
        }

        try {
            if ("edit".equals(action)) {
                String productID = request.getParameter("productID");
                Product product = productService.getProductById(productID);
                if (product != null && supplierId.equals(product.getSupplierId())) {
                    request.setAttribute("product", product);
                    request.getRequestDispatcher("/supplier/edit-product.jsp").forward(request, response);
                    return;
                } else {
                    request.setAttribute("error", "Product not found or not yours");
                }
            } else if ("add".equals(action)) {
                request.getRequestDispatcher("/supplier/add-product.jsp").forward(request, response);
                return;
            }
            listProducts(request, response, supplierId);
        } catch (SQLException e) {
            LOGGER.severe("Error in doGet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                listProducts(request, response, supplierId);
            } catch (SQLException ex) {
                LOGGER.severe("Nested error in doGet: " + ex.getMessage());
                throw new ServletException("Nested database error", ex);
            }
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isSupplier(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String userId = ((User) request.getSession().getAttribute("user")).getUserId();
        String supplierId;
        try {
            supplierId = userService.getSupplierSID(userId);
            if (supplierId == null) {
                request.setAttribute("error", "Invalid supplier ID");
                listProducts(request, response, supplierId); // Will fail, but handle
                return;
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching supplier ID: " + e.getMessage());
            request.setAttribute("error", "Error fetching supplier ID");
            try {
                listProducts(request, response, ""); // Dummy to avoid null
            } catch (SQLException ex) {
                throw new ServletException("Nested error", ex);
            }
            return;
        }

        try {
            if ("add".equals(action)) {
                Product product = new Product();
                product.setName(request.getParameter("name"));
                product.setSku(request.getParameter("sku"));
                product.setCategory(request.getParameter("category"));
                product.setPrice(Double.parseDouble(request.getParameter("price")));
                product.setStock(Integer.parseInt(request.getParameter("stock")));
                product.setDescription(request.getParameter("description"));
                product.setSupplierId(supplierId);
                product.setStatus("pending");

                String productID = productService.addProduct(product);

                // Handle specifications
                int specCount = Integer.parseInt(request.getParameter("specCount"));
                for (int i = 1; i <= specCount; i++) {
                    String key = request.getParameter("specKey" + i);
                    String value = request.getParameter("specValue" + i);
                    if (key != null && !key.trim().isEmpty() && value != null && !value.trim().isEmpty()) {
                        ProductSpecification spec = new ProductSpecification(key, value);
                        spec.setProductID(productID);
                        productService.addProductSpecification(spec);
                    }
                }

                // Handle images
                List<Part> imageParts = new ArrayList<>();
                for (Part part : request.getParts()) {
                    if (part.getName().startsWith("image") && part.getSize() > 0) {
                        imageParts.add(part);
                    }
                }

                // Save images
                String baseDir = getServletContext().getRealPath("/images/products/" + productID);
                File dir = new File(baseDir);
                if (!dir.exists()) {
                    if (!dir.mkdirs()) {
                        LOGGER.severe("Failed to create directory: " + baseDir);
                        request.setAttribute("error", "Failed to create image directory");
                        listProducts(request, response, supplierId);
                        return;
                    }
                }

                for (int i = 0; i < imageParts.size(); i++) {
                    Part part = imageParts.get(i);
                    String fileName = extractFileName(part);
                    if (fileName != null && !fileName.isEmpty()) {
                        // Sanitize filename
                        fileName = System.currentTimeMillis() + "_" + fileName.replaceAll("[^a-zA-Z0-9._-]", "_");
                        String filePath = baseDir + File.separator + fileName;
                        part.write(filePath);
                        String relativePath = "/images/products/" + productID + "/" + fileName;
                        ProductImage image = new ProductImage(productID, relativePath, i == 0); // First image is primary
                        productService.addProductImage(image);
                    }
                }

                request.setAttribute("message", "Product added successfully!");
            } else if ("update".equals(action)) {
                String productID = request.getParameter("productID");
                Product product = productService.getProductById(productID);
                if (product != null && supplierId.equals(product.getSupplierId())) {
                    product.setName(request.getParameter("name"));
                    product.setSku(request.getParameter("sku"));
                    product.setCategory(request.getParameter("category"));
                    product.setPrice(Double.parseDouble(request.getParameter("price")));
                    product.setStock(Integer.parseInt(request.getParameter("stock")));
                    product.setDescription(request.getParameter("description"));
                    productService.updateProduct(product);

                    // Specifications - replace all
                    productService.deleteProductSpecifications(productID);
                    int specCount = Integer.parseInt(request.getParameter("specCount"));
                    for (int i = 1; i <= specCount; i++) {
                        String key = request.getParameter("specKey" + i);
                        String value = request.getParameter("specValue" + i);
                        if (key != null && !key.trim().isEmpty() && value != null && !value.trim().isEmpty()) {
                            ProductSpecification spec = new ProductSpecification(key, value);
                            spec.setProductID(productID);
                            productService.addProductSpecification(spec);
                        }
                    }

                    // Images - replace all if new uploaded
                    List<Part> imageParts = new ArrayList<>();
                    for (Part part : request.getParts()) {
                        if (part.getName().startsWith("image") && part.getSize() > 0) {
                            imageParts.add(part);
                        }
                    }
                    if (!imageParts.isEmpty()) {
                        productService.deleteProductImages(productID);
                        String baseDir = getServletContext().getRealPath("/images/products/" + productID);
                        File dir = new File(baseDir);
                        if (!dir.exists()) {
                            if (!dir.mkdirs()) {
                                LOGGER.severe("Failed to create directory: " + baseDir);
                                request.setAttribute("error", "Failed to create image directory");
                                listProducts(request, response, supplierId);
                                return;
                            }
                        }
                        for (int i = 0; i < imageParts.size(); i++) {
                            Part part = imageParts.get(i);
                            String fileName = extractFileName(part);
                            if (fileName != null && !fileName.isEmpty()) {
                                fileName = System.currentTimeMillis() + "_" + fileName.replaceAll("[^a-zA-Z0-9._-]", "_");
                                String filePath = baseDir + File.separator + fileName;
                                part.write(filePath);
                                String relativePath = "/images/products/" + productID + "/" + fileName;
                                ProductImage image = new ProductImage(productID, relativePath, i == 0);
                                productService.addProductImage(image);
                            }
                        }
                    }
                    request.setAttribute("message", "Product updated successfully!");
                } else {
                    request.setAttribute("error", "Product not found or not yours");
                }
            } else if ("delete".equals(action)) {
                String productID = request.getParameter("productID");
                Product product = productService.getProductById(productID);
                if (product != null && supplierId.equals(product.getSupplierId())) {
                    productService.deleteProduct(productID);
                    request.setAttribute("message", "Product deleted successfully!");
                } else {
                    request.setAttribute("error", "Product not found or not yours");
                }
            }
            listProducts(request, response, supplierId);
        } catch (SQLException e) {
            LOGGER.severe("Error in doPost: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                listProducts(request, response, supplierId);
            } catch (SQLException ex) {
                LOGGER.severe("Nested error in doPost: " + ex.getMessage());
                throw new ServletException("Nested database error", ex);
            }
        } catch (NumberFormatException e) {
            LOGGER.severe("Invalid input in doPost: " + e.getMessage());
            request.setAttribute("error", "Invalid number format in input: " + e.getMessage());
            try {
                listProducts(request, response, supplierId);
            } catch (SQLException ex) {
                LOGGER.severe("Nested error in doPost: " + ex.getMessage());
                throw new ServletException("Nested database error", ex);
            }
        } catch (Exception e) {
            LOGGER.severe("Unexpected error in doPost: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Unexpected error: " + e.getMessage());
            try {
                listProducts(request, response, supplierId);
            } catch (SQLException ex) {
                LOGGER.severe("Nested error in doPost: " + ex.getMessage());
                throw new ServletException("Nested database error", ex);
            }
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response, String supplierId)
            throws ServletException, IOException, SQLException {
        List<Product> products = productService.getProductsBySupplier(supplierId);
        request.setAttribute("products", products);
        request.getRequestDispatcher("/supplier/products.jsp").forward(request, response);
    }

    private boolean isSupplier(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        return user != null && "supplier".equals(user.getRole());
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
}
