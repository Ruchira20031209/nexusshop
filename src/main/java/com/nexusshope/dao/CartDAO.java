package com.nexusshope.dao;

import com.nexusshope.model.Cart;
import com.nexusshope.model.CartItem;
import java.sql.SQLException;
import java.util.List;

public interface CartDAO {

    // Cart operations
    Cart getCartByUserID(String userID) throws SQLException;
    String createCart(String userID) throws SQLException;
    boolean updateCart(Cart cart) throws SQLException;
    boolean clearCart(String userID) throws SQLException;

    // Cart item operations
    boolean addItemToCart(String userID, String productID, int quantity) throws SQLException;
    boolean removeItemFromCart(String userID, String productID) throws SQLException;
    boolean updateItemQuantity(String userID, String productID, int quantity) throws SQLException;

    // Utility methods
    int getCartItemCount(String userID) throws SQLException;
    boolean itemExistsInCart(String userID, String productID) throws SQLException;
}