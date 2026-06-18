package com.nexusshope.service;

import com.nexusshope.dao.OrderDAO;
import com.nexusshope.dao.OrderDAOImpl;
import com.nexusshope.model.Cart;
import com.nexusshope.model.CartItem;
import com.nexusshope.model.Order;
import com.nexusshope.model.OrderItem;
import com.nexusshope.model.OrderSummary;
import com.nexusshope.model.PaymentCard;

import java.sql.SQLException;
import java.util.List;
import java.util.Objects;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OrderService {
    private static final Logger LOGGER = Logger.getLogger(OrderService.class.getName());

    private final OrderDAO orderDAO;
    private final CartService cartService;

    public OrderService() {
        this(new OrderDAOImpl(), new CartService());
    }

    public OrderService(OrderDAO orderDAO, CartService cartService) {
        this.orderDAO = Objects.requireNonNull(orderDAO, "orderDAO");
        this.cartService = Objects.requireNonNull(cartService, "cartService");
    }

    public Order createOrderFromCart(String userID, String shippingAddress, PaymentCard paymentCard) {
        try {
            Cart cart = cartService.getCart(userID);
            if (cart == null) {
                throw new IllegalStateException("Cart is null");
            }
            if (cart.isEmpty()) {
                throw new IllegalStateException("Cart is empty");
            }

            Order order = new Order();
            order.setCustomerID(userID);
            order.setCartID(cart.getCartID());
            order.setTotalAmount(cart.getTotalAmount());
            order.setShippingAddress(shippingAddress);
            order.setBillingAddress(shippingAddress);
            order.setPaymentMethod("CREDIT_CARD");
            order.setPaymentCard(paymentCard);
            order.setTaxAmount(calculateTax(cart.getTotalAmount()));
            order.setShippingAmount(calculateShipping(cart.getTotalAmount()));

            for (CartItem cartItem : cart.getItems()) {
                if (!orderDAO.validateStock(cartItem.getProduct().getProductID(), cartItem.getQuantity())) {
                    throw new IllegalStateException("Insufficient stock for product: " + cartItem.getProduct().getName());
                }

                OrderItem orderItem = new OrderItem(
                        cartItem.getProduct().getProductID(),
                        cartItem.getProduct().getName(),
                        cartItem.getUnitPrice(),
                        cartItem.getQuantity(),
                        cartItem.getImageUrl()
                );
                order.addOrderItem(orderItem);
            }

            Order createdOrder = orderDAO.createOrder(order);
            boolean paymentSuccess = orderDAO.processCheckout(createdOrder, paymentCard.getCardNumber());

            if (!paymentSuccess) {
                throw new RuntimeException("Payment processing failed");
            }

            cartService.clearCart(userID);
            return createdOrder;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to create order from cart for user " + userID, e);
            throw new RuntimeException("Error creating order: " + e.getMessage(), e);
        } catch (RuntimeException e) {
            LOGGER.log(Level.SEVERE, "Unexpected error while creating order for user " + userID, e);
            throw e;
        }
    }

    public Order getOrder(String orderID) {
        try {
            return orderDAO.getOrderById(orderID);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to load order " + orderID, e);
            return null;
        }
    }

    public List<Order> getCustomerOrders(String customerID) {
        try {
            return orderDAO.getOrdersByCustomer(customerID);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to load orders for customer " + customerID, e);
            return null;
        }
    }

    public boolean cancelOrder(String orderID) {
        try {
            return orderDAO.updateOrderStatus(orderID, "CANCELLED");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Unable to cancel order " + orderID, e);
            return false;
        }
    }

    private double calculateTax(double amount) {
        return amount * 0.08;
    }

    private double calculateShipping(double amount) {
        return amount > 50 ? 0 : 5.99;
    }

    private boolean processPayment(Order order, PaymentCard paymentCard) {
        try {
            boolean paymentSuccess = orderDAO.processCheckout(order, paymentCard.getCardNumber());
            if (paymentSuccess) {
                for (OrderItem item : order.getItems()) {
                    orderDAO.updateProductStock(item.getProductID(), item.getQuantity());
                }
            }
            return paymentSuccess;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unable to process payment for order " + order.getOrderID(), e);
            return false;
        }
    }

    public OrderSummary getOrderSummary(String userID) {
        try {
            Cart cart = cartService.getCart(userID);
            if (cart == null || cart.isEmpty()) {
                return null;
            }

            OrderSummary summary = new OrderSummary();
            summary.setSubtotal(cart.getTotalAmount());
            summary.setTax(calculateTax(cart.getTotalAmount()));
            summary.setShipping(calculateShipping(cart.getTotalAmount()));
            summary.setTotal(summary.getSubtotal() + summary.getTax() + summary.getShipping());
            summary.setItemCount(cart.getTotalItems());
            return summary;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unable to build order summary for user " + userID, e);
            return null;
        }
    }

    public List<Order> getAllOrders() throws SQLException {
        return orderDAO.getAllOrders();
    }

    public boolean updateOrderStatus(String orderID, String status) throws SQLException {
        return orderDAO.updateOrderStatus(orderID, status);
    }

    public List<Order> getOrdersForDelivery() throws SQLException {
        return orderDAO.getOrdersForDelivery();
    }
}
