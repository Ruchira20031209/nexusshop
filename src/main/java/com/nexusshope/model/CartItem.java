package com.nexusshope.model;

public class CartItem {
    private String cartItemID;
    private String cartID;
    private Product product;
    private int quantity;
    private double unitPrice;
    private double totalPrice;
    private String imageUrl;

    public CartItem() {}

    public CartItem(String cartItemID, String cartID, Product product, int quantity) {
        this.cartItemID = cartItemID;
        this.cartID = cartID;
        this.product = product;
        this.quantity = quantity;
        this.unitPrice = product.getPrice();
        calculateTotalPrice();
    }

    // Getters and Setters
    public String getCartItemID() { return cartItemID; }
    public void setCartItemID(String cartItemID) { this.cartItemID = cartItemID; }

    public String getCartID() { return cartID; }
    public void setCartID(String cartID) { this.cartID = cartID; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) {
        this.product = product;
        if (this.unitPrice == 0.0) {
            this.unitPrice = product.getPrice();
        }
    }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
        calculateTotalPrice();
    }

    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
        calculateTotalPrice();
    }

    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }

    public void calculateTotalPrice() {
        this.totalPrice = unitPrice * quantity;
    }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}