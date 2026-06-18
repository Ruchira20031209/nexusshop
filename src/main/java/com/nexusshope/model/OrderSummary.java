package com.nexusshope.model;

public class OrderSummary {
    private double subtotal;
    private double tax;
    private double shipping;
    private double total;
    private int itemCount;

    // Getters and Setters
    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }

    public double getTax() { return tax; }
    public void setTax(double tax) { this.tax = tax; }

    public double getShipping() { return shipping; }
    public void setShipping(double shipping) { this.shipping = shipping; }

    public double getTotal() { return total; }
    public void setTotal(double total) { this.total = total; }

    public int getItemCount() { return itemCount; }
    public void setItemCount(int itemCount) { this.itemCount = itemCount; }
}