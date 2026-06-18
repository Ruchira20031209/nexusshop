package com.nexusshope.service;

import com.nexusshope.dao.CartDAO;
import com.nexusshope.dao.CartDAOImpl;
import com.nexusshope.model.Cart;

import java.sql.SQLException;
import java.util.Objects;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CartService {
    private static final Logger LOGGER = Logger.getLogger(CartService.class.getName());

    private final CartDAO cartDAO;

    public CartService() {
        this(new CartDAOImpl());
    }

    public CartService(CartDAO cartDAO) {
        this.cartDAO = Objects.requireNonNull(cartDAO, "cartDAO");
    }

    public Cart getCart(String userID) {
        try {
            return cartDAO.getCartByUserID(userID);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to load cart for user " + userID, e);
            return null;
        }
    }

    public boolean addToCart(String userID, String productID, int quantity) {
        if (userID == null || productID == null || quantity <= 0) {
            LOGGER.warning("Invalid parameters supplied to addToCart");
            return false;
        }

        try {
            return cartDAO.addItemToCart(userID, productID, quantity);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to add product " + productID + " to cart for user " + userID, e);
            return false;
        }
    }

    public boolean removeFromCart(String userID, String productID) {
        try {
            return cartDAO.removeItemFromCart(userID, productID);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to remove product " + productID + " from cart for user " + userID, e);
            return false;
        }
    }

    public boolean updateQuantity(String userID, String productID, int quantity) {
        try {
            return cartDAO.updateItemQuantity(userID, productID, quantity);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to update cart quantity for user " + userID + " and product " + productID, e);
            return false;
        }
    }

    public boolean clearCart(String userID) {
        try {
            return cartDAO.clearCart(userID);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to clear cart for user " + userID, e);
            return false;
        }
    }

    public int getCartItemCount(String userID) {
        try {
            return cartDAO.getCartItemCount(userID);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to count cart items for user " + userID, e);
            return 0;
        }
    }

    public boolean itemExistsInCart(String userID, String productID) {
        try {
            return cartDAO.itemExistsInCart(userID, productID);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to check cart item for user " + userID + " and product " + productID, e);
            return false;
        }
    }
}
