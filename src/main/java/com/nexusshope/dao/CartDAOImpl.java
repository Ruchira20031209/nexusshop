package com.nexusshope.dao;

import com.nexusshope.model.Cart;
import com.nexusshope.model.CartItem;
import com.nexusshope.model.Product;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAOImpl extends AbstractDAO implements CartDAO {

    @Override
    public Cart getCartByUserID(String userID) throws SQLException {
        System.out.println("DEBUG: Getting cart for user: " + userID);
        Cart cart = null;

        // First, get or create cart
        String cartSQL = "{CALL GetOrCreateUserCart(?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(cartSQL)) {

            cs.setString(1, userID);
            cs.registerOutParameter(2, Types.VARCHAR);
            cs.execute();

            String cartID = cs.getString(2);
            System.out.println("DEBUG: Cart ID: " + cartID);

            if (cartID != null) {
                cart = new Cart(cartID, userID);

                // Now get cart items
                String itemsSQL = "{CALL GetCartContents(?)}";
                try (CallableStatement itemsCS = conn.prepareCall(itemsSQL)) {
                    itemsCS.setString(1, userID);
                    try (ResultSet rs = itemsCS.executeQuery()) {
                        List<CartItem> cartItems = new ArrayList<>();
                        double cartTotal = 0.0;
                        int totalItems = 0;

                        System.out.println("DEBUG: Loading cart items...");
                        int itemCount = 0;

                        while (rs.next()) {
                            itemCount++;
                            System.out.println("DEBUG: Found item " + itemCount + ": " + rs.getString("productID"));

                            CartItem item = mapResultSetToCartItem(rs);
                            cartItems.add(item);
                            cartTotal = rs.getDouble("cartTotal");
                            totalItems = rs.getInt("totalItems");
                        }

                        System.out.println("DEBUG: Total items loaded: " + itemCount);

                        cart.setItems(cartItems);
                        cart.setTotalItems(totalItems);
                        cart.setTotalAmount(cartTotal);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR in getCartByUserID: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        return cart;
    }

    @Override
    public String createCart(String userID) throws SQLException {
        String cartSQL = "{CALL GetOrCreateUserCart(?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(cartSQL)) {

            cs.setString(1, userID);
            cs.registerOutParameter(2, Types.VARCHAR);
            cs.execute();

            return cs.getString(2);
        }
    }

    @Override
    public boolean updateCart(Cart cart) throws SQLException {
        // Cart totals are automatically updated by database triggers/stored procedures
        return true;
    }

    @Override
    public boolean clearCart(String userID) throws SQLException {
        String sql = "{CALL ClearUserCart(?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, userID);
            cs.execute();

            ResultSet rs = cs.getResultSet();
            if (rs != null && rs.next()) {
                return "success".equals(rs.getString("status"));
            }
        }
        return false;
    }

    @Override
    public boolean addItemToCart(String userID, String productID, int quantity) throws SQLException {
        System.out.println("DEBUG: Adding to cart - User: " + userID + ", Product: " + productID + ", Qty: " + quantity);

        String sql = "{CALL AddToCart(?, ?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, userID);
            cs.setString(2, productID);
            cs.setInt(3, quantity);

            // Use execute() instead of executeUpdate() for procedures that return result sets
            boolean hasResults = cs.execute();

            if (hasResults) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        String status = rs.getString("status");
                        System.out.println("DEBUG: AddToCart result: " + status);
                        return "success".equals(status);
                    }
                }
            } else {
                System.out.println("DEBUG: No result set from AddToCart");
                // Check if any rows were affected as an alternative
                int updateCount = cs.getUpdateCount();
                System.out.println("DEBUG: Update count: " + updateCount);
                return updateCount > 0;
            }
        } catch (SQLException e) {
            System.err.println("ERROR in addItemToCart: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        return false;
    }

    @Override
    public boolean removeItemFromCart(String userID, String productID) throws SQLException {
        String sql = "{CALL RemoveFromCart(?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, userID);
            cs.setString(2, productID);
            cs.execute();

            ResultSet rs = cs.getResultSet();
            if (rs != null && rs.next()) {
                return "success".equals(rs.getString("status"));
            }
        }
        return false;
    }

    @Override
    public boolean updateItemQuantity(String userID, String productID, int quantity) throws SQLException {
        String sql = "{CALL UpdateCartItemQuantity(?, ?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, userID);
            cs.setString(2, productID);
            cs.setInt(3, quantity);
            cs.execute();

            ResultSet rs = cs.getResultSet();
            if (rs != null && rs.next()) {
                return "success".equals(rs.getString("status"));
            }
        }
        return false;
    }

    @Override
    public int getCartItemCount(String userID) throws SQLException {
        String sql = "{CALL GetCartSummary(?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, userID);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs != null && rs.next()) {
                    return rs.getInt("totalItems");
                }
            }
        }
        return 0;
    }

    @Override
    public boolean itemExistsInCart(String userID, String productID) throws SQLException {
        String sql = "SELECT 1 FROM cart_items ci " +
                "JOIN carts c ON ci.cartID = c.cartID " +
                "WHERE c.userID = ? AND ci.productID = ? AND c.status = 'active'";

        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userID);
            ps.setString(2, productID);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private CartItem mapResultSetToCartItem(ResultSet rs) throws SQLException {
        CartItem item = new CartItem();
        item.setCartItemID(rs.getString("cartItemID"));
        item.setCartID(rs.getString("cartID"));
        item.setQuantity(rs.getInt("quantity"));
        item.setUnitPrice(rs.getDouble("unitPrice"));
        item.setTotalPrice(rs.getDouble("totalPrice"));
        item.setImageUrl(rs.getString("imageUrl")); // Set image URL

        // Create and set product
        Product product = new Product();
        String productID = rs.getString("productID");
        String productName = rs.getString("productName");

        System.out.println("DEBUG: Mapping product - ID: " + productID + ", Name: " + productName + ", Image: " + rs.getString("imageUrl"));

        if (productID != null) {
            product.setProductID(productID);
            product.setName(productName);
            product.setSku(rs.getString("productSKU"));
            product.setCategory(rs.getString("productCategory"));
            product.setPrice(rs.getDouble("unitPrice"));
            product.setStock(rs.getInt("availableStock"));
            product.setDescription(rs.getString("productDescription"));

            item.setProduct(product);

            System.out.println("DEBUG: Mapped cart item - Product: " + product.getName() + ", Qty: " + item.getQuantity() + ", Image: " + item.getImageUrl());
        } else {
            System.out.println("DEBUG: Product ID is null in result set!");
        }

        return item;
    }

}
