package com.nexusshope.service;

import com.nexusshope.dao.ProductDAO;
import com.nexusshope.dao.ProductDAOImpl;
import com.nexusshope.model.Product;
import com.nexusshope.model.ProductImage;
import com.nexusshope.model.ProductSpecification;

import java.sql.SQLException;
import java.util.List;
import java.util.Objects;

public class ProductService {
    private final ProductDAO productDAO;

    public ProductService() {
        this(new ProductDAOImpl());
    }

    public ProductService(ProductDAO productDAO) {
        this.productDAO = Objects.requireNonNull(productDAO, "productDAO");
    }

    public List<Product> getAllProducts() throws SQLException {
        return productDAO.getAllProducts();
    }

    public boolean updateProductStatus(String productID, String newStatus, String rejectionNotes) throws SQLException {
        Product product = getProductById(productID);
        if (product != null) {
            product.setStatus(newStatus);
            if ("rejected".equals(newStatus) && rejectionNotes != null) {
                product.setRejectionNotes(rejectionNotes);
            }
            return updateProduct(product);
        }
        return false;
    }

    public int getProductCountByStatus(String status) throws SQLException {
        return productDAO.getStatusCount(status);
    }

    public int getTotalProductCount() throws SQLException {
        return productDAO.getTotalProductCount();
    }

    public List<Product> getProductsByStatus(String status) throws SQLException {
        return productDAO.getProductsByStatus(status);
    }

    public List<Product> getProductsBySupplier(String supplierId) throws SQLException {
        return productDAO.getProductsBySupplier(supplierId);
    }

    public List<Product> getProductsBySupplierAndStatus(String supplierId, String status) throws SQLException {
        return productDAO.getProductsBySupplierAndStatus(supplierId, status);
    }

    public List<Product> getApprovedProducts(String search, String category, Double priceMin, Double priceMax) throws SQLException {
        return productDAO.getApprovedProducts(search, category, priceMin, priceMax);
    }

    public Product getProductById(String productID) throws SQLException {
        return productDAO.getProductById(productID);
    }

    public String addProduct(Product product) throws SQLException {
        return productDAO.insertProduct(product);
    }

    public boolean updateProduct(Product product) throws SQLException {
        return productDAO.updateProduct(product);
    }

    public boolean deleteProduct(String productID) throws SQLException {
        return productDAO.deleteProduct(productID);
    }

    public List<ProductImage> getProductImages(String productID) throws SQLException {
        return productDAO.getProductImages(productID);
    }

    public void addProductImage(ProductImage image) throws SQLException {
        productDAO.insertProductImage(image);
    }

    public boolean deleteProductImages(String productID) throws SQLException {
        return productDAO.deleteProductImages(productID);
    }

    public boolean setPrimaryImage(String imageID, String productID) throws SQLException {
        return productDAO.setPrimaryImage(imageID, productID);
    }

    public int getStatusCount(String status) throws SQLException {
        return productDAO.getStatusCount(status);
    }

    public int getLowStockCount(int threshold) throws SQLException {
        return productDAO.getLowStockCount(threshold);
    }

    public int getOutOfStockCount() throws SQLException {
        return productDAO.getOutOfStockCount();
    }

    public List<ProductSpecification> getProductSpecifications(String productID) throws SQLException {
        return productDAO.getProductSpecifications(productID);
    }

    public void addProductSpecification(ProductSpecification spec) throws SQLException {
        productDAO.insertProductSpecification(spec);
    }

    public void deleteProductSpecifications(String productID) throws SQLException {
        productDAO.deleteProductSpecifications(productID);
    }

    public List<Product> getProductsWithImages(String search, String category, Double priceMin, Double priceMax) throws SQLException {
        List<Product> products = productDAO.getApprovedProducts(search, category, priceMin, priceMax);

        for (Product product : products) {
            try {
                List<ProductImage> images = getProductImages(product.getProductID());
                if (images != null && !images.isEmpty()) {
                    images.stream()
                            .filter(ProductImage::isPrimary)
                            .findFirst()
                            .orElse(images.get(0))
                            .getImageUrl();
                }
            } catch (SQLException e) {
                System.err.println("Error loading image for product: " + product.getProductID());
            }
        }

        return products;
    }
}
