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

@WebServlet("/pm/add-product")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class AddProductServlet extends HttpServlet {
    private ProductService productService = new ProductService();
    private static final String UPLOAD_DIR = "/images/products/";

    // Add this missing method
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                String fileName = s.substring(s.indexOf("=") + 2, s.length() - 1);
                // Extract only the file name, not the full path
                return fileName.substring(fileName.lastIndexOf("\\") + 1);
            }
        }
        return "";
    }

    // Add this helper method to count image parts for debugging
    private int countImageParts(HttpServletRequest req) throws IOException, ServletException {
        int count = 0;
        for (Part part : req.getParts()) {
            if (part.getName() != null && part.getName().startsWith("image") && part.getSize() > 0) {
                count++;
            }
        }
        return count;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!new ProductManagerDashboardServlet().isProductManager(req)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        req.getRequestDispatcher("/pm/add-product.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!new ProductManagerDashboardServlet().isProductManager(req)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // Validations
        String name = req.getParameter("name");
        String sku = req.getParameter("sku");
        String category = req.getParameter("category");
        String priceStr = req.getParameter("price");
        String stockStr = req.getParameter("stock");
        String description = req.getParameter("description");

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
            doGet(req, resp);
            return;
        }

        // Create product (PM adds as approved)
        Product product = new Product();
        product.setName(name);
        product.setSku(sku);
        product.setCategory(category);
        product.setPrice(price);
        product.setStock(stock);
        product.setDescription(description);
        product.setStatus("approved"); // Auto-approved
        product.setSupplierId("SU003"); // Dummy or null

        try {
            String productID = productService.addProduct(product);

            // DEBUG: Check if productID is returned
            System.out.println("Generated Product ID: " + productID);
            System.out.println("Number of image parts: " + countImageParts(req));

            if (productID != null && !productID.trim().isEmpty()) {
                // Handle images
                int imageIndex = 0;
                for (Part part : req.getParts()) {
                    if (part.getName() != null && part.getName().startsWith("image") && part.getSize() > 0) {
                        String fileName = extractFileName(part);
                        if (fileName != null && !fileName.isEmpty()) {
                            // Create product directory
                            String productDir = req.getServletContext().getRealPath(UPLOAD_DIR + productID);
                            File dir = new File(productDir);
                            if (!dir.exists()) {
                                dir.mkdirs();
                            }

                            String filePath = productDir + File.separator + fileName;
                            part.write(filePath);
                            String relativePath = UPLOAD_DIR + productID + "/" + fileName;

                            ProductImage image = new ProductImage();
                            image.setProductID(productID);
                            image.setImageUrl(relativePath);
                            image.setPrimary(imageIndex == 0); // First image as primary

                            productService.addProductImage(image);
                            imageIndex++;

                            System.out.println("Image saved: " + relativePath);
                        }
                    }
                }

                // Handle specs
                String[] specKeys = req.getParameterValues("specKey");
                String[] specValues = req.getParameterValues("specValue");
                if (specKeys != null && specValues != null && specKeys.length == specValues.length) {
                    for (int i = 0; i < specKeys.length; i++) {
                        if (specKeys[i] != null && !specKeys[i].trim().isEmpty() &&
                                specValues[i] != null && !specValues[i].trim().isEmpty()) {
                            ProductSpecification spec = new ProductSpecification();
                            spec.setProductID(productID);
                            spec.setSpecKey(specKeys[i].trim());
                            spec.setSpecValue(specValues[i].trim());
                            productService.addProductSpecification(spec);
                        }
                    }
                }

                req.getSession().setAttribute("message", "Product added successfully. ID: " + productID);
                resp.sendRedirect(req.getContextPath() + "/pm/dashboard");
            } else {
                errors.add("Failed to add product. No product ID returned.");
                req.setAttribute("errors", errors);
                doGet(req, resp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            errors.add("Database error: " + e.getMessage());
            req.setAttribute("errors", errors);
            doGet(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            errors.add("Unexpected error: " + e.getMessage());
            req.setAttribute("errors", errors);
            doGet(req, resp);
        }
    }
}