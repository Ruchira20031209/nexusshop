package com.nexusshope.servlet;

import com.nexusshope.model.Product;
import com.nexusshope.model.ProductImage;
import com.nexusshope.model.ProductSpecification;
import com.nexusshope.service.ProductService;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/pm/edit-product")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class EditProductServlet extends HttpServlet {
    private ProductService productService = new ProductService();
    private static final String UPLOAD_DIR = "/images/products/";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!new ProductManagerDashboardServlet().isProductManager(req)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String productID = req.getParameter("productID");
        if (productID == null) {
            resp.sendRedirect(req.getContextPath() + "/pm/dashboard");
            return;
        }

        try {
            Product product = productService.getProductById(productID);
            if (product != null) {
                List<ProductImage> images = productService.getProductImages(productID);
                List<ProductSpecification> specs = productService.getProductSpecifications(productID);
                req.setAttribute("product", product);
                req.setAttribute("images", images);
                req.setAttribute("specs", specs);
                req.getRequestDispatcher("/pm/edit-product.jsp").forward(req, resp);
            } else {
                req.setAttribute("error", "Product not found.");
                resp.sendRedirect(req.getContextPath() + "/pm/dashboard");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Database error.");
            resp.sendRedirect(req.getContextPath() + "/pm/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!new ProductManagerDashboardServlet().isProductManager(req)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String productID = req.getParameter("productID");
        // Similar validations as AddProductServlet
        String name = req.getParameter("name");
        String sku = req.getParameter("sku");
        String category = req.getParameter("category");
        String priceStr = req.getParameter("price");
        String stockStr = req.getParameter("stock");
        String description = req.getParameter("description");
        String status = req.getParameter("status"); // Allow PM to change status

        List<String> errors = new ArrayList<>();
        if (name == null || name.trim().isEmpty()) errors.add("Name required.");
        if (sku == null || sku.trim().isEmpty()) errors.add("SKU required.");
        if (category == null || category.trim().isEmpty()) errors.add("Category required.");
        double price = 0;
        try {
            price = Double.parseDouble(priceStr);
            if (price <= 0) errors.add("Price must be positive.");
        } catch (NumberFormatException e) {
            errors.add("Invalid price.");
        }
        int stock = 0;
        try {
            stock = Integer.parseInt(stockStr);
            if (stock < 0) errors.add("Stock cannot be negative.");
        } catch (NumberFormatException e) {
            errors.add("Invalid stock.");
        }

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            try {
                req.setAttribute("product", productService.getProductById(productID)); // Refetch for form
            } catch (SQLException e) {
                e.printStackTrace();
                errors.add("Error loading product data");
                req.setAttribute("errors", errors);
            }
            doGet(req, resp);
            return;
        }

        try {
            Product product = productService.getProductById(productID);
            if (product != null) {
                product.setName(name);
                product.setSku(sku);
                product.setCategory(category);
                product.setPrice(Double.parseDouble(priceStr));
                product.setStock(Integer.parseInt(stockStr));
                product.setDescription(description);
                product.setStatus(status);

                boolean updated = productService.updateProduct(product);
                if (updated) {
                    // Delete old images/specs if requested (e.g., via checkboxes)
                    String[] deleteImages = req.getParameterValues("deleteImage");
                    if (deleteImages != null) {
                        for (String imageID : deleteImages) {
                            // Delete file and DB (implement file delete logic)
                            productService.deleteProductImages(imageID);
                        }
                    }

                    // Add new images
                    int imageIndex = productService.getProductImages(productID).size(); // Append
                    for (Part part : req.getParts()) {
                        if (part.getName().startsWith("newImage") && part.getSize() > 0) {
                            String fileName = extractFileName(part);
                            if (!fileName.isEmpty()) {
                                String productDir = req.getServletContext().getRealPath(UPLOAD_DIR + productID);
                                new File(productDir).mkdirs();
                                String filePath = productDir + File.separator + fileName;
                                part.write(filePath);
                                String relativePath = UPLOAD_DIR + productID + "/" + fileName;
                                ProductImage image = new ProductImage(productID, relativePath, imageIndex == 0 && imageIndex == 0); // First new as primary if none
                                productService.addProductImage(image);
                                imageIndex++;
                            }
                        }
                    }

                    // Update specs: Delete all and re-add (simple way)
                    productService.deleteProductSpecifications(productID);
                    String[] specKeys = req.getParameterValues("specKey");
                    String[] specValues = req.getParameterValues("specValue");
                    if (specKeys != null && specValues != null) {
                        for (int i = 0; i < specKeys.length; i++) {
                            if (!specKeys[i].trim().isEmpty() && !specValues[i].trim().isEmpty()) {
                                ProductSpecification spec = new ProductSpecification(specKeys[i], specValues[i]);
                                spec.setProductID(productID);
                                productService.addProductSpecification(spec);
                            }
                        }
                    }

                    req.getSession().setAttribute("message", "Product updated successfully.");
                    resp.sendRedirect(req.getContextPath() + "/pm/dashboard");
                } else {
                    errors.add("Failed to update product.");
                }
            } else {
                errors.add("Product not found.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            errors.add("Database error.");
            req.setAttribute("errors", errors);
            doGet(req, resp);
        } catch (NumberFormatException e) {
            errors.add("Invalid number format.");
            req.setAttribute("errors", errors);
            doGet(req, resp);
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1).replace("\"", "");
            }
        }
        return "";
    }
}