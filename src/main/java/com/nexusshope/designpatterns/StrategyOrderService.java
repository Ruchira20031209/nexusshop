package com.nexusshope.designpatterns;

import com.nexusshope.dao.OrderDAO;
import com.nexusshope.dao.OrderDAOImpl;
import com.nexusshope.designpatterns.OrderStatusManager;
import com.nexusshope.model.Order;
import java.sql.SQLException;
import java.util.List;

public class StrategyOrderService {
    private OrderDAO orderDAO = new OrderDAOImpl();

    public boolean updateOrderStatus(String orderId, String newStatus) throws SQLException {
        Order order = orderDAO.getOrderById(orderId);
        if (order == null) {
            return false;
        }

        OrderStatusManager statusManager = new OrderStatusManager(order);

        if (!statusManager.canTransition()) {
            System.err.println("Invalid status transition from: " + order.getStatus());
            return false;
        }

        if (!statusManager.getNextStatus().equals(newStatus)) {
            System.err.println("Requested status " + newStatus + " doesn't match expected next status " + statusManager.getNextStatus());
            return false;
        }

        return statusManager.transitionToNextStatus();
    }

    public List<Order> getOrdersForDelivery() throws SQLException {
        List<Order> orders = orderDAO.getOrdersForDelivery();

        // Enhance orders with strategy information
        for (Order order : orders) {
            OrderStatusManager statusManager = new OrderStatusManager(order);
            // You can add strategy info to order if needed for UI
        }

        return orders;
    }
}