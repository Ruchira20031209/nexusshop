package com.nexusshope.dao;
import com.nexusshope.model.Product;
import com.nexusshope.model.ProductImage;
import com.nexusshope.model.ProductSpecification;
import java.sql.SQLException;
import java.util.List;
public interface ProductDAO {
    // Product operations
    List<Product> getAllProducts() throws SQLException;
    List<Product> getProductsByStatus(String status) throws SQLException;
    List<Product> getProductsBySupplier(String supplierId) throws SQLException;
    List<Product> getProductsBySupplierAndStatus(String supplierId, String status) throws SQLException;
    List<Product> getApprovedProducts(String search, String category, Double priceMin, Double priceMax) throws SQLException;
    Product getProductById(String productID) throws SQLException;
    String insertProduct(Product product) throws SQLException;
    boolean updateProduct(Product product) throws SQLException;
    boolean deleteProduct(String productID) throws SQLException;
    // Image operations
    List<ProductImage> getProductImages(String productID) throws SQLException;
    void insertProductImage(ProductImage image) throws SQLException;
    boolean deleteProductImages(String productID) throws SQLException;
    boolean setPrimaryImage(String imageID, String productID) throws SQLException;
    int getStatusCount(String status) throws SQLException;
    int getLowStockCount(int threshold) throws SQLException;
    int getOutOfStockCount() throws SQLException;
    int getTotalProductCount() throws SQLException;
    // New: Spec methods
    List<ProductSpecification> getProductSpecifications(String productID) throws SQLException;
    void insertProductSpecification(ProductSpecification spec) throws SQLException;
    void deleteProductSpecifications(String productID) throws SQLException;
}