package com.nexusshope.dao;

import com.nexusshope.model.Order;
import com.nexusshope.model.OrderItem;
import java.sql.SQLException;
import java.util.List;

public interface OrderDAO {

    // Order operations
    Order createOrder(Order order) throws SQLException;
    Order getOrderById(String orderID) throws SQLException;
    List<Order> getOrdersByCustomer(String customerID) throws SQLException;
    boolean updateOrderStatus(String orderID, String status) throws SQLException;
    boolean updatePaymentStatus(String orderID, String paymentStatus, String transactionID) throws SQLException;

    // Order item operations
    boolean addOrderItem(OrderItem item) throws SQLException;
    List<OrderItem> getOrderItems(String orderID) throws SQLException;

    // Checkout operations
    boolean processCheckout(Order order, String paymentCardId) throws SQLException;
    boolean validateStock(String productID, int quantity) throws SQLException;
    boolean updateProductStock(String productID, int quantity) throws SQLException;

    // Utility methods
    int getOrderCountByCustomer(String customerID) throws SQLException;
    List<Order> getOrdersByStatus(String status) throws SQLException;
    List<Order> getAllOrders() throws SQLException;
    List<Order> getOrdersForDelivery() throws SQLException;


}