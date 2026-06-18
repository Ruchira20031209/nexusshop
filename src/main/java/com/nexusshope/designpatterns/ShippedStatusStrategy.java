package com.nexusshope.designpatterns;

import com.nexusshope.model.Order;
import java.sql.SQLException;

public class ShippedStatusStrategy implements OrderStatusStrategy {

    @Override
    public boolean canTransitionFrom(String currentStatus) {
        return "SHIPPED".equals(currentStatus);
    }

    @Override
    public String getNextStatus() {
        return "DELIVERED";
    }

    @Override
    public void validateTransition(Order order) throws IllegalStateException {
        // Validate that order is actually out for delivery
        // Check delivery timeframe
    }

    @Override
    public void executePreTransition(Order order) throws SQLException {
        System.out.println("🎯 Finalizing delivery: " + order.getOrderID());
        // Prepare delivery confirmation
        // Update delivery timeline
    }

    @Override
    public void executePostTransition(Order order) throws SQLException {
        System.out.println("✅ Order delivered: " + order.getOrderID());
        // Send delivery confirmation to customer
        // Update order completion time
        // Trigger payment settlement if needed
    }

    @Override
    public String getActionButtonText() {
        return "Mark as Delivered";
    }

    @Override
    public String getActionButtonIcon() {
        return "fas fa-check-circle";
    }

    @Override
    public String getStatusColor() {
        return "success";
    }
}