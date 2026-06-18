package com.nexusshope.model;

import java.util.ArrayList;
import java.util.List;

public class Cart {
    private String cartID;
    private String userID;
    private String status;
    private double totalAmount;
    private int totalItems;
    private List<CartItem> items;

    // Constructors
    public Cart() {
        this.items = new ArrayList<>();
        this.totalAmount = 0.0;
        this.totalItems = 0;
        this.status = "active";
    }

    public Cart(String cartID, String userID) {
        this();
        this.cartID = cartID;
        this.userID = userID;
    }

    // Getters and Setters
    public String getCartID() { return cartID; }
    public void setCartID(String cartID) { this.cartID = cartID; }

    public String getUserID() { return userID; }
    public void setUserID(String userID) { this.userID = userID; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public int getTotalItems() { return totalItems; }
    public void setTotalItems(int totalItems) { this.totalItems = totalItems; }

    public List<CartItem> getItems() { return items; }
    public void setItems(List<CartItem> items) { this.items = items; }

    // Helper method to calculate totals from items
    public void calculateTotals() {
        if (items != null && !items.isEmpty()) {
            this.totalItems = items.stream().mapToInt(CartItem::getQuantity).sum();
            this.totalAmount = items.stream().mapToDouble(CartItem::getTotalPrice).sum();
        } else {
            this.totalItems = 0;
            this.totalAmount = 0.0;
        }
    }

    public boolean isEmpty() {
        return items == null || items.isEmpty();
    }
}