package com.nexusshope.designpatterns;

import com.nexusshope.model.Order;
import java.sql.SQLException;

public class ConfirmedStatusStrategy implements OrderStatusStrategy {

    @Override
    public boolean canTransitionFrom(String currentStatus) {
        return "CONFIRMED".equals(currentStatus);
    }

    @Override
    public String getNextStatus() {
        return "PROCESSING";
    }

    @Override
    public void validateTransition(Order order) throws IllegalStateException {
        if (!"PAID".equals(order.getPaymentStatus())) {
            throw new IllegalStateException("Cannot process order that is not paid");
        }
        if (order.getItems() == null || order.getItems().isEmpty()) {
            throw new IllegalStateException("Order has no items");
        }
    }

    @Override
    public void executePreTransition(Order order) throws SQLException {
        System.out.println("🔧 Starting order processing: " + order.getOrderID());
        // Validate stock availability
        // Assign to delivery person
        // Generate picking list
    }

    @Override
    public void executePostTransition(Order order) throws SQLException {
        System.out.println("✅ Order processing started: " + order.getOrderID());
        // Send notification to warehouse
        // Update order timeline
    }

    @Override
    public String getActionButtonText() {
        return "Start Processing";
    }

    @Override
    public String getActionButtonIcon() {
        return "fas fa-play-circle";
    }

    @Override
    public String getStatusColor() {
        return "warning";
    }
}