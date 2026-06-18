package com.nexusshope.servlet;

import com.nexusshope.model.Order;
import com.nexusshope.model.User;
import com.nexusshope.service.OrderService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/delivery")
public class DeliveryServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Check if user is delivery person
        if (user == null || !"delivery_person".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Get orders that are ready for delivery (CONFIRMED, PROCESSING, SHIPPED status)
            List<Order> orders = orderService.getOrdersForDelivery();

            // Calculate statistics
            int totalOrders = orders.size();
            int pendingOrders = (int) orders.stream()
                    .filter(order -> "CONFIRMED".equals(order.getStatus()))
                    .count();
            int shippedOrders = (int) orders.stream()
                    .filter(order -> "SHIPPED".equals(order.getStatus()))
                    .count();
            int deliveredOrders = (int) orders.stream()
                    .filter(order -> "DELIVERED".equals(order.getStatus()))
                    .count();

            request.setAttribute("orders", orders);
            request.setAttribute("totalOrders", totalOrders);
            request.setAttribute("pendingOrders", pendingOrders);
            request.setAttribute("shippedOrders", shippedOrders);
            request.setAttribute("deliveredOrders", deliveredOrders);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading delivery orders: " + e.getMessage());
        }

        request.getRequestDispatcher("/Delivery_Dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"delivery_person".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            if ("updateStatus".equals(action)) {
                updateOrderStatus(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error processing request: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/delivery");
        }
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String orderId = request.getParameter("orderId");
        String newStatus = request.getParameter("newStatus");

        if (orderId != null && newStatus != null) {
            boolean success = orderService.updateOrderStatus(orderId, newStatus);
            HttpSession session = request.getSession();
            if (success) {
                session.setAttribute("message", "Order status updated successfully to: " + newStatus);
            } else {
                session.setAttribute("error", "Failed to update order status");
            }
        }

        response.sendRedirect(request.getContextPath() + "/delivery");
    }
}