package com.nexusshope.designpatterns;

import com.nexusshope.model.Order;
import java.sql.SQLException;

public class DeliveredStatusStrategy implements OrderStatusStrategy {

    @Override
    public boolean canTransitionFrom(String currentStatus) {
        return "DELIVERED".equals(currentStatus);
    }

    @Override
    public String getNextStatus() {
        return "COMPLETED"; // Final state
    }

    @Override
    public void validateTransition(Order order) throws IllegalStateException {
        // Final validation - ensure delivery was successful
    }

    @Override
    public void executePreTransition(Order order) throws SQLException {
        System.out.println("🏁 Finalizing order: " + order.getOrderID());
        // Close order processing
    }

    @Override
    public void executePostTransition(Order order) throws SQLException {
        System.out.println("🎉 Order completed: " + order.getOrderID());
        // Send thank you email
        // Request customer feedback
        // Archive order data
    }

    @Override
    public String getActionButtonText() {
        return "Complete Order";
    }

    @Override
    public String getActionButtonIcon() {
        return "fas fa-flag-checkered";
    }

    @Override
    public String getStatusColor() {
        return "secondary";
    }
}