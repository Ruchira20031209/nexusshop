package com.nexusshope.designpatterns;

import com.nexusshope.designpatterns.OrderStatusStrategy;
import com.nexusshope.designpatterns.OrderStatusStrategyFactory;
import com.nexusshope.model.Order;
import java.sql.SQLException;

public class OrderStatusManager {
    private OrderStatusStrategy strategy;
    private Order order;

    public OrderStatusManager(Order order) {
        this.order = order;
        if (OrderStatusStrategyFactory.isValidTransition(order.getStatus())) {
            this.strategy = OrderStatusStrategyFactory.getStrategy(order.getStatus());
        }
    }

    public boolean canTransition() {
        return strategy != null && strategy.canTransitionFrom(order.getStatus());
    }

    public String getNextStatus() {
        return strategy != null ? strategy.getNextStatus() : order.getStatus();
    }

    public boolean transitionToNextStatus() throws SQLException {
        if (!canTransition()) {
            return false;
        }

        try {
            // Validate the transition
            strategy.validateTransition(order);

            // Execute pre-transition actions
            strategy.executePreTransition(order);

            // Update order status in database (this would be your DAO call)
            boolean statusUpdated = updateOrderStatusInDatabase(order.getOrderID(), getNextStatus());

            if (statusUpdated) {
                // Execute post-transition actions
                strategy.executePostTransition(order);
                return true;
            }

            return false;

        } catch (IllegalStateException e) {
            System.err.println("Status transition validation failed: " + e.getMessage());
            return false;
        }
    }

    public String getActionButtonText() {
        return strategy != null ? strategy.getActionButtonText() : "No Action";
    }

    public String getActionButtonIcon() {
        return strategy != null ? strategy.getActionButtonIcon() : "fas fa-ban";
    }

    public String getActionButtonColor() {
        return strategy != null ? strategy.getStatusColor() : "secondary";
    }

    public boolean hasAction() {
        return strategy != null;
    }

    private boolean updateOrderStatusInDatabase(String orderId, String newStatus) throws SQLException {
        // This would call your existing OrderDAO
        // For now, return true for demonstration
        System.out.println("Updating order " + orderId + " status to: " + newStatus);
        return true;
    }
}