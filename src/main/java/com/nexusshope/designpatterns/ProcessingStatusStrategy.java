package com.nexusshope.designpatterns;

import com.nexusshope.model.Order;
import java.sql.SQLException;

public class ProcessingStatusStrategy implements OrderStatusStrategy {

    @Override
    public boolean canTransitionFrom(String currentStatus) {
        return "PROCESSING".equals(currentStatus);
    }

    @Override
    public String getNextStatus() {
        return "SHIPPED";
    }

    @Override
    public void validateTransition(Order order) throws IllegalStateException {
        if (order.getShippingAddress() == null || order.getShippingAddress().trim().isEmpty()) {
            throw new IllegalStateException("Shipping address is required");
        }
        // Check if order is ready for shipping (packaged, labeled, etc.)
    }

    @Override
    public void executePreTransition(Order order) throws SQLException {
        System.out.println("🚚 Preparing order for shipment: " + order.getOrderID());
        // Generate shipping label
        // Assign tracking number
        // Update inventory (reduce stock)
    }

    @Override
    public void executePostTransition(Order order) throws SQLException {
        System.out.println("📦 Order shipped: " + order.getOrderID());
        // Send shipping confirmation to customer
        // Notify delivery person
    }

    @Override
    public String getActionButtonText() {
        return "Mark as Shipped";
    }

    @Override
    public String getActionButtonIcon() {
        return "fas fa-shipping-fast";
    }

    @Override
    public String getStatusColor() {
        return "primary";
    }
}