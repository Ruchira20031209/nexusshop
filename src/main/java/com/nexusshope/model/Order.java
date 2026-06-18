package com.nexusshope.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Order {
    private String orderID;
    private String customerID;
    private String cartID;
    private Timestamp orderDate;
    private double totalAmount;
    private double taxAmount;
    private double shippingAmount;
    private double discountAmount;
    private double finalAmount;
    private String status; // PENDING, CONFIRMED, PROCESSING, SHIPPED, DELIVERED, CANCELLED
    private String shippingAddress;
    private String billingAddress;
    private String paymentMethod;
    private String paymentStatus; // PENDING, PAID, FAILED, REFUNDED
    private String transactionID;
    private List<OrderItem> items;
    private PaymentCard paymentCard;

    // Constructors
    public Order() {
        this.items = new ArrayList<>();
        this.status = "PENDING";
        this.paymentStatus = "PENDING";
        this.orderDate = new Timestamp(System.currentTimeMillis());
    }

    public Order(String customerID, String cartID, double totalAmount, String shippingAddress) {
        this();
        this.customerID = customerID;
        this.cartID = cartID;
        this.totalAmount = totalAmount;
        this.shippingAddress = shippingAddress;
        this.billingAddress = shippingAddress;
        calculateFinalAmount();
    }

    // Business methods
    public void calculateFinalAmount() {
        this.finalAmount = totalAmount + taxAmount + shippingAmount - discountAmount;
    }

    public void addOrderItem(OrderItem item) {
        this.items.add(item);
    }

    public void removeOrderItem(String productID) {
        this.items.removeIf(item -> item.getProductID().equals(productID));
    }

    // Getters and Setters
    public String getOrderID() { return orderID; }
    public void setOrderID(String orderID) { this.orderID = orderID; }

    public String getCustomerID() { return customerID; }
    public void setCustomerID(String customerID) { this.customerID = customerID; }

    public String getCartID() { return cartID; }
    public void setCartID(String cartID) { this.cartID = cartID; }

    public Timestamp getOrderDate() { return orderDate; }
    public void setOrderDate(Timestamp orderDate) { this.orderDate = orderDate; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
        calculateFinalAmount();
    }

    public double getTaxAmount() { return taxAmount; }
    public void setTaxAmount(double taxAmount) {
        this.taxAmount = taxAmount;
        calculateFinalAmount();
    }

    public double getShippingAmount() { return shippingAmount; }
    public void setShippingAmount(double shippingAmount) {
        this.shippingAmount = shippingAmount;
        calculateFinalAmount();
    }

    public double getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(double discountAmount) {
        this.discountAmount = discountAmount;
        calculateFinalAmount();
    }

    public double getFinalAmount() { return finalAmount; }
    public void setFinalAmount(double finalAmount) { this.finalAmount = finalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }

    public String getBillingAddress() { return billingAddress; }
    public void setBillingAddress(String billingAddress) { this.billingAddress = billingAddress; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getTransactionID() { return transactionID; }
    public void setTransactionID(String transactionID) { this.transactionID = transactionID; }

    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }

    public PaymentCard getPaymentCard() { return paymentCard; }
    public void setPaymentCard(PaymentCard paymentCard) { this.paymentCard = paymentCard; }
}