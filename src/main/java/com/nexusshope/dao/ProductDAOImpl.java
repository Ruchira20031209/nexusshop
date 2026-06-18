package com.nexusshope.dao;
import com.nexusshope.model.Product;
import com.nexusshope.model.ProductImage;
import com.nexusshope.model.ProductSpecification;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
public class ProductDAOImpl extends AbstractDAO implements ProductDAO {
    @Override
    public List<Product> getAllProducts() throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY productID";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product product = mapResultSetToProduct(rs);
                product.setSpecifications(getProductSpecifications(product.getProductID())); // Load specs
                products.add(product);
            }
        }
        return products;
    }
    @Override
    public List<Product> getProductsByStatus(String status) throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE status = ? ORDER BY productID";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapResultSetToProduct(rs);
                    product.setSpecifications(getProductSpecifications(product.getProductID()));
                    products.add(product);
                }
            }
        }
        return products;
    }
    @Override
    public List<Product> getProductsBySupplier(String supplierId) throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE supplier_id = ? ORDER BY productID";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapResultSetToProduct(rs);
                    product.setSpecifications(getProductSpecifications(product.getProductID()));
                    products.add(product);
                }
            }
        }
        return products;
    }
    @Override
    public List<Product> getProductsBySupplierAndStatus(String supplierId, String status) throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE supplier_id = ? AND status = ? ORDER BY productID";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supplierId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapResultSetToProduct(rs);
                    product.setSpecifications(getProductSpecifications(product.getProductID()));
                    products.add(product);
                }
            }
        }
        return products;
    }
    @Override
    public List<Product> getApprovedProducts(String search, String category, Double priceMin, Double priceMax) throws SQLException {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM products WHERE status = 'approved'");
        if (search != null) sql.append(" AND name LIKE ?");
        if (category != null) sql.append(" AND category = ?");
        if (priceMin != null) sql.append(" AND price >= ?");
        if (priceMax != null) sql.append(" AND price <= ?");
        sql.append(" ORDER BY productID");
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (search != null) ps.setString(paramIndex++, "%" + search + "%");
            if (category != null) ps.setString(paramIndex++, category);
            if (priceMin != null) ps.setDouble(paramIndex++, priceMin);
            if (priceMax != null) ps.setDouble(paramIndex++, priceMax);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapResultSetToProduct(rs);
                    product.setSpecifications(getProductSpecifications(product.getProductID()));
                    products.add(product);
                }
            }
        }
        return products;
    }

    @Override
    public String insertProduct(Product product) throws SQLException {
        String sql = "{CALL InsertProduct(?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, product.getName());
            cs.setString(2, product.getSku());
            cs.setString(3, product.getCategory());
            cs.setDouble(4, product.getPrice());
            cs.setInt(5, product.getStock());
            cs.setString(6, product.getDescription());
            cs.setString(7, product.getStatus());
            cs.setString(8, product.getSupplierId());
            cs.execute();
// Loop to handle multiple results (skip update counts, get ResultSet)
            do {
                ResultSet rs = cs.getResultSet();
                if (rs != null) {
                    try {
                        if (rs.next()) {
                            return rs.getString("NewProductID");
                        }
                    } finally {
                        rs.close();
                    }
                } else {
                    int updateCount = cs.getUpdateCount();
                    if (updateCount == -1) {
                        break; // No more results
                    }
                }
            } while (cs.getMoreResults());
        }
        return null;
    }

    @Override
    public boolean deleteProduct(String productID) throws SQLException {
        String sql = "DELETE FROM products WHERE productID = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productID);
            return ps.executeUpdate() > 0;
        }
    }
    @Override
    public List<ProductImage> getProductImages(String productID) throws SQLException {
        List<ProductImage> images = new ArrayList<>();
        String sql = "SELECT * FROM product_images WHERE product_id = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductImage image = new ProductImage();
                    image.setImageID(rs.getString("imageID"));
                    image.setProductID(rs.getString("product_id"));
                    image.setImageUrl(rs.getString("image_url"));
                    image.setPrimary(rs.getBoolean("is_primary"));
                    images.add(image);
                }
            }
        }
        return images;
    }
    @Override
    public void insertProductImage(ProductImage image) throws SQLException {
        String sql = "{CALL InsertProductImage(?, ?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, image.getProductID());
            cs.setString(2, image.getImageUrl());
            cs.setBoolean(3, image.isPrimary());
            cs.execute();
        }
    }
    @Override
    public boolean deleteProductImages(String productID) throws SQLException {
        String sql = "DELETE FROM product_images WHERE product_id = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productID);
            return ps.executeUpdate() > 0;
        }
    }
    @Override
    public boolean setPrimaryImage(String imageID, String productID) throws SQLException {
        String sql = "UPDATE product_images SET is_primary = 0 WHERE product_id = ?; UPDATE product_images SET is_primary = 1 WHERE imageID = ? AND product_id = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productID);
            ps.setString(2, imageID);
            ps.setString(3, productID);
            return ps.executeUpdate() > 0;
        }
    }
    @Override
    public int getStatusCount(String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM products WHERE status = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
    @Override
    public int getLowStockCount(int threshold) throws SQLException {
        String sql = "SELECT COUNT(*) FROM products WHERE stock <= ? AND stock > 0";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
    @Override
    public int getOutOfStockCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM products WHERE stock = 0";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    // New: Spec methods
    @Override
    public List<ProductSpecification> getProductSpecifications(String productID) throws SQLException {
        List<ProductSpecification> specs = new ArrayList<>();
        String sql = "SELECT * FROM product_specifications WHERE productID = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductSpecification spec = new ProductSpecification();
                    spec.setSpecID(rs.getString("specID"));
                    spec.setProductID(rs.getString("productID"));
                    spec.setSpecKey(rs.getString("specKey"));
                    spec.setSpecValue(rs.getString("specValue"));
                    specs.add(spec);
                }
            }
        }
        return specs;
    }
    @Override
    public void insertProductSpecification(ProductSpecification spec) throws SQLException {
        String sql = "{CALL InsertProductSpec(?, ?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, spec.getProductID());
            cs.setString(2, spec.getSpecKey());
            cs.setString(3, spec.getSpecValue());
            cs.execute();
        }
    }
    @Override
    public void deleteProductSpecifications(String productID) throws SQLException {
        String sql = "DELETE FROM product_specifications WHERE productID = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productID);
            ps.executeUpdate();
        }
    }
    // Helper method
    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductID(rs.getString("productID"));
        product.setName(rs.getString("name"));
        product.setSku(rs.getString("sku"));
        product.setCategory(rs.getString("category"));
        product.setPrice(rs.getDouble("price"));
        product.setStock(rs.getInt("stock"));
        product.setDescription(rs.getString("description"));
        product.setStatus(rs.getString("status"));
        product.setSupplierId(rs.getString("supplier_id"));
        product.setRating(rs.getDouble("rating"));
        product.setCreatedDate(rs.getTimestamp("created_date"));
        product.setUpdatedDate(rs.getTimestamp("updated_date"));
        return product;
    }

    // Updated (single instance): updateProduct with rejection_notes handling
    @Override
    public boolean updateProduct(Product product) throws SQLException {
        String sql = "UPDATE products SET name = ?, sku = ?, category = ?, price = ?, stock = ?, description = ?, status = ?, rating = ?, updated_date = GETDATE(), rejection_notes = ? WHERE productID = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getSku());
            ps.setString(3, product.getCategory());
            ps.setDouble(4, product.getPrice());
            ps.setInt(5, product.getStock());
            ps.setString(6, product.getDescription());
            ps.setString(7, product.getStatus());
            ps.setDouble(8, product.getRating());
            ps.setString(9, product.getRejectionNotes()); // Handles the new field
            ps.setString(10, product.getProductID());
            return ps.executeUpdate() > 0;
        }
    }

    // Updated (single instance): getProductById with rejection_notes handling
    @Override
    public Product getProductById(String productID) throws SQLException {
        String sql = "SELECT * FROM products WHERE productID = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product product = new Product();
                    product.setProductID(rs.getString("productID"));
                    product.setName(rs.getString("name"));
                    product.setSku(rs.getString("sku"));
                    product.setCategory(rs.getString("category"));
                    product.setPrice(rs.getDouble("price"));
                    product.setStock(rs.getInt("stock"));
                    product.setDescription(rs.getString("description"));
                    product.setStatus(rs.getString("status"));
                    product.setSupplierId(rs.getString("supplier_id"));
                    product.setRating(rs.getDouble("rating"));
                    product.setCreatedDate(rs.getTimestamp("created_date"));
                    product.setUpdatedDate(rs.getTimestamp("updated_date"));
                    product.setRejectionNotes(rs.getString("rejection_notes")); // Handles the new field
                    return product;
                }
            }
        }
        return null;
    }

    // New: Get total product count (if not already there)
    @Override
    public int getTotalProductCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection conn = openConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }


}
