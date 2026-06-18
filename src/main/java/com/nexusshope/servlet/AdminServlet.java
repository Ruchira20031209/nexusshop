package com.nexusshope.servlet;

import com.nexusshope.model.Order;
import com.nexusshope.model.User;
import com.nexusshope.service.OrderService;
import com.nexusshope.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    private UserService userService = new UserService();
    private OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Check if user is admin
        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Load users
            List<User> users = userService.getAllUsers();
            request.setAttribute("users", users);

            // Load orders
            List<Order> orders = orderService.getAllOrders();
            request.setAttribute("orders", orders);

            // Calculate dashboard statistics
            int totalOrders = orders.size();
            int pendingOrders = (int) orders.stream()
                    .filter(order -> "PENDING".equals(order.getStatus()))
                    .count();
            double totalRevenue = orders.stream()
                    .filter(order -> "PAID".equals(order.getPaymentStatus()))
                    .mapToDouble(Order::getFinalAmount)
                    .sum();
            int totalCustomers = (int) users.stream()
                    .filter(u -> "customer".equals(u.getRole()))
                    .count();

            request.setAttribute("totalOrders", totalOrders);
            request.setAttribute("pendingOrders", pendingOrders);
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("totalCustomers", totalCustomers);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading admin data: " + e.getMessage());
        }

        request.getRequestDispatcher("/admin_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            switch (action) {
                case "updateOrderStatus":
                    updateOrderStatus(request, response);
                    break;
                case "viewOrder":
                    viewOrder(request, response);
                    break;
                case "deleteUser":
                    deleteUser(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error processing request: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin");
        }
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String orderId = request.getParameter("orderId");
        String newStatus = request.getParameter("newStatus");

        if (orderId != null && newStatus != null && !newStatus.isEmpty()) {
            boolean success = orderService.updateOrderStatus(orderId, newStatus);
            HttpSession session = request.getSession();
            if (success) {
                session.setAttribute("message", "Order status updated successfully!");
            } else {
                session.setAttribute("error", "Failed to update order status");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin");
    }

    private void viewOrder(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String orderId = request.getParameter("orderId");
        Order order = orderService.getOrder(orderId);

        if (order != null) {
            request.setAttribute("order", order);
            request.getRequestDispatcher("/order-detail.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("error", "Order not found");
            response.sendRedirect(request.getContextPath() + "/admin");
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        String userId = request.getParameter("userId");
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (userId == null || userId.trim().isEmpty()) {
            session.setAttribute("error", "User ID is required.");
        } else if (currentUser != null && userId.equals(currentUser.getUserId())) {
            session.setAttribute("error", "You cannot delete your own admin account while logged in.");
        } else {
            userService.deleteUser(userId);
            session.setAttribute("message", "User deleted successfully!");
        }

        response.sendRedirect(request.getContextPath() + "/admin");
    }
}
