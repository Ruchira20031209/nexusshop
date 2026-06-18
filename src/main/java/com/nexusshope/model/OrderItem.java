package com.nexusshope.model;

public class OrderItem {
    private String orderItemID;
    private String orderID;
    private String productID;
    private String productName;
    private double unitPrice;
    private int quantity;
    private double totalPrice;
    private String imageUrl;

    // Constructors
    public OrderItem() {}

    public OrderItem(String productID, String productName, double unitPrice, int quantity, String imageUrl) {
        this.productID = productID;
        this.productName = productName;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.imageUrl = imageUrl;
        calculateTotalPrice();
    }

    // Business methods
    public void calculateTotalPrice() {
        this.totalPrice = unitPrice * quantity;
    }

    // Getters and Setters
    public String getOrderItemID() { return orderItemID; }
    public void setOrderItemID(String orderItemID) { this.orderItemID = orderItemID; }

    public String getOrderID() { return orderID; }
    public void setOrderID(String orderID) { this.orderID = orderID; }

    public String getProductID() { return productID; }
    public void setProductID(String productID) { this.productID = productID; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
        calculateTotalPrice();
    }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
        calculateTotalPrice();
    }

    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}