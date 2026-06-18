package com.nexusshope.dao;

import com.nexusshope.model.Order;
import com.nexusshope.model.OrderItem;
import com.nexusshope.model.PaymentCard;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAOImpl extends AbstractDAO implements OrderDAO {

    @Override
    public Order createOrder(Order order) throws SQLException {
        String sql = "{CALL CreateOrder(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";

        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            // Set parameters
            cs.setString(1, order.getCustomerID());
            cs.setString(2, order.getCartID());
            cs.setDouble(3, order.getTotalAmount());
            cs.setDouble(4, order.getTaxAmount());
            cs.setDouble(5, order.getShippingAmount());
            cs.setDouble(6, order.getDiscountAmount());
            cs.setString(7, order.getShippingAddress());
            cs.setString(8, order.getBillingAddress());
            cs.setString(9, order.getPaymentMethod());
            cs.setString(10, order.getPaymentCard() != null ? order.getPaymentCard().getCardNumber() : null);
            cs.registerOutParameter(11, Types.VARCHAR);

            System.out.println("🔍 Executing CreateOrder stored procedure...");
            boolean hasResults = cs.execute();

            String orderID = cs.getString(11);
            System.out.println("🔍 Order ID returned from stored procedure: " + orderID);

            if (orderID == null) {
                // Try to get from result set if output parameter didn't work
                if (hasResults) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs != null && rs.next()) {
                            orderID = rs.getString("NewOrderID");
                            System.out.println("🔍 Order ID from result set: " + orderID);
                        }
                    }
                }
            }

            if (orderID == null) {
                throw new SQLException("CreateOrder stored procedure returned NULL orderID");
            }

            order.setOrderID(orderID);
            System.out.println("✅ Order created with ID: " + orderID);

            // Add order items
            for (OrderItem item : order.getItems()) {
                item.setOrderID(orderID); // Make sure orderID is set
                System.out.println("🔍 Adding order item for order: " + orderID);
                addOrderItem(item);
            }

            return order;
        }
    }

    @Override
    public Order getOrderById(String orderID) throws SQLException {
        String sql = "{CALL GetOrderById(?)}";
        Order order = null;

        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, orderID);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    order = mapResultSetToOrder(rs);

                    // Load order items
                    List<OrderItem> items = getOrderItems(orderID);
                    order.setItems(items);
                }
            }
        }
        return order;
    }

    @Override
    public List<Order> getOrdersByCustomer(String customerID) throws SQLException {
        String sql = "{CALL GetOrdersByCustomer(?)}";
        List<Order> orders = new ArrayList<>();

        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, customerID);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    Order order = mapResultSetToOrder(rs);
                    orders.add(order);
                }
            }
        }
        return orders;
    }

    @Override
    public boolean updateOrderStatus(String orderID, String status) throws SQLException {
        String sql = "{CALL UpdateOrderStatus(?, ?)}";

        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, orderID);
            cs.setString(2, status);

            int rowsAffected = cs.executeUpdate();
            return rowsAffected > 0;
        }
    }

    @Override
    public boolean updatePaymentStatus(String orderID, String paymentStatus, String transactionID) throws SQLException {
        String sql = "{CALL UpdatePaymentStatus(?, ?, ?)}";

        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, orderID);
            cs.setString(2, paymentStatus);
            cs.setString(3, transactionID);

            int rowsAffected = cs.executeUpdate();
            return rowsAffected > 0;
        }
    }

    @Override
    public boolean addOrderItem(OrderItem item) throws SQLException {
        String sql = "{CALL AddOrderItem(?, ?, ?, ?, ?, ?)}";

        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, item.getOrderID());
            cs.setString(2, item.getProductID());
            cs.setString(3, item.getProductName());
            cs.setDouble(4, item.getUnitPrice());
            cs.setInt(5, item.getQuantity());
            cs.setString(6, item.getImageUrl());

            int rowsAffected = cs.executeUpdate();
            return rowsAffected > 0;
        }
    }

    @Override
    public List<OrderItem> getOrderItems(String orderID) throws SQLException {
        String sql = "{CALL GetOrderItems(?)}";
        List<OrderItem> items = new ArrayList<>();

        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, orderID);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemID(rs.getString("orderItemID"));
                    item.setOrderID(rs.getString("orderID"));
                    item.setProductID(rs.getString("productID"));
                    item.setProductName(rs.getString("productName"));
                    item.setUnitPrice(rs.getDouble("unitPrice"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setTotalPrice(rs.getDouble("totalPrice"));
                    item.setImageUrl(rs.getString("imageUrl"));

                    items.add(item);
                }
            }
        }
        return items;
    }

    @Override
    public boolean processCheckout(Order order, String paymentCardId) throws SQLException {
        // This would integrate with payment gateway in real implementation
        // For now, we'll simulate payment processing

        String sql = "{CALL ProcessCheckout(?, ?, ?)}";

        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, order.getOrderID());
            cs.setString(2, paymentCardId);
            cs.registerOutParameter(3, Types.VARCHAR);

            cs.execute();

            String transactionID = cs.getString(3);
            order.setTransactionID(transactionID);

            // Update payment status
            return updatePaymentStatus(order.getOrderID(), "PAID", transactionID);
        }
    }

    @Override
    public boolean validateStock(String productID, int quantity) throws SQLException {
        String sql = "SELECT stock FROM products WHERE productID = ?";

        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, productID);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int availableStock = rs.getInt("stock");
                    return availableStock >= quantity;
                }
            }
        }
        return false;
    }

    @Override
    public boolean updateProductStock(String productID, int quantity) throws SQLException {
        String sql = "UPDATE products SET stock = stock - ? WHERE productID = ?";

        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, quantity);
            ps.setString(2, productID);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        }
    }

    @Override
    public int getOrderCountByCustomer(String customerID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM orders WHERE customerID = ?";

        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, customerID);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    @Override
    public List<Order> getOrdersByStatus(String status) throws SQLException {
        String sql = "{CALL GetOrdersByStatus(?)}";
        List<Order> orders = new ArrayList<>();

        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, status);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    Order order = mapResultSetToOrder(rs);
                    orders.add(order);
                }
            }
        }
        return orders;
    }

    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderID(rs.getString("orderID"));
        order.setCustomerID(rs.getString("customerID"));
        order.setCartID(rs.getString("cartID"));
        order.setOrderDate(rs.getTimestamp("orderDate"));
        order.setTotalAmount(rs.getDouble("totalAmount"));
        order.setTaxAmount(rs.getDouble("taxAmount"));
        order.setShippingAmount(rs.getDouble("shippingAmount"));
        order.setDiscountAmount(rs.getDouble("discountAmount"));
        order.setFinalAmount(rs.getDouble("finalAmount"));
        order.setStatus(rs.getString("status"));
        order.setShippingAddress(rs.getString("shippingAddress"));
        order.setBillingAddress(rs.getString("billingAddress"));
        order.setPaymentMethod(rs.getString("paymentMethod"));
        order.setPaymentStatus(rs.getString("paymentStatus"));
        order.setTransactionID(rs.getString("transactionID"));
        return order;
    }

    public List<Order> getAllOrders() throws SQLException {
        String sql = "SELECT * FROM orders ORDER BY orderDate DESC";
        List<Order> orders = new ArrayList<>();

        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Order order = extractOrderFromResultSet(rs); // Fixed method name
                // Load order items
                List<OrderItem> items = getOrderItemsByOrderId(order.getOrderID()); // Fixed method name
                order.setItems(items);
                orders.add(order);
            }
        }
        return orders;
    }

    public List<Order> getOrdersForDelivery() throws SQLException {
        // Get orders that are PROCESSING or SHIPPED (ready for delivery)
        String sql = "SELECT * FROM orders WHERE status IN ('PROCESSING', 'SHIPPED', 'DELIVERED') ORDER BY orderDate DESC";
        List<Order> orders = new ArrayList<>();

        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Order order = extractOrderFromResultSet(rs); // Fixed method name
                // Load order items
                List<OrderItem> items = getOrderItemsByOrderId(order.getOrderID()); // Fixed method name
                order.setItems(items);
                orders.add(order);
            }
        }
        return orders;
    }



    // Add this helper method to map ResultSet to OrderItem
    private OrderItem mapResultSetToOrderItem(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();
        item.setOrderItemID(rs.getString("orderItemID"));
        item.setOrderID(rs.getString("orderID"));
        item.setProductID(rs.getString("productID"));
        item.setProductName(rs.getString("productName"));
        item.setUnitPrice(rs.getDouble("unitPrice"));
        item.setQuantity(rs.getInt("quantity"));
        item.setTotalPrice(rs.getDouble("totalPrice"));
        item.setImageUrl(rs.getString("imageUrl"));
        return item;
    }

    private Order extractOrderFromResultSet(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderID(rs.getString("orderID"));
        order.setCustomerID(rs.getString("customerID"));
        order.setCartID(rs.getString("cartID"));
        order.setOrderDate(rs.getTimestamp("orderDate"));
        order.setTotalAmount(rs.getDouble("totalAmount"));
        order.setTaxAmount(rs.getDouble("taxAmount"));
        order.setShippingAmount(rs.getDouble("shippingAmount"));
        order.setDiscountAmount(rs.getDouble("discountAmount"));
        order.setFinalAmount(rs.getDouble("finalAmount"));
        order.setStatus(rs.getString("status"));
        order.setShippingAddress(rs.getString("shippingAddress"));
        order.setBillingAddress(rs.getString("billingAddress"));
        order.setPaymentMethod(rs.getString("paymentMethod"));
        order.setPaymentStatus(rs.getString("paymentStatus"));
        order.setTransactionID(rs.getString("transactionID"));
        return order;
    }

    private List<OrderItem> getOrderItemsByOrderId(String orderID) throws SQLException {
        String sql = "SELECT * FROM order_items WHERE orderID = ?";
        List<OrderItem> items = new ArrayList<>();

        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, orderID);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = extractOrderItemFromResultSet(rs);
                    items.add(item);
                }
            }
        }
        return items;
    }

    private OrderItem extractOrderItemFromResultSet(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();
        item.setOrderItemID(rs.getString("orderItemID"));
        item.setOrderID(rs.getString("orderID"));
        item.setProductID(rs.getString("productID"));
        item.setProductName(rs.getString("productName"));
        item.setUnitPrice(rs.getDouble("unitPrice"));
        item.setQuantity(rs.getInt("quantity"));
        item.setTotalPrice(rs.getDouble("totalPrice"));
        item.setImageUrl(rs.getString("imageUrl"));
        return item;
    }


}
