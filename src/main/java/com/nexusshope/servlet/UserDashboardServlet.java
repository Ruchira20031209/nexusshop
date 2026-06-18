// File: com/nexusshope/servlet/UserDashboardServlet.java
package com.nexusshope.servlet;

import com.nexusshope.model.Order;
import com.nexusshope.model.PaymentCard;
import com.nexusshope.model.User;
import com.nexusshope.service.OrderService;
import com.nexusshope.service.PaymentCardService;
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

@WebServlet("/myaccount")
public class UserDashboardServlet extends HttpServlet {

    private UserService userService = new UserService();
    private OrderService orderService = new OrderService();
    private PaymentCardService paymentCardService = new PaymentCardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        loadDashboardData(request, user);
        request.getRequestDispatcher("/myaccount.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String message = null;
        String messageType = "error";

        try {
            if ("updateName".equals(action)) {
                String newName = request.getParameter("newName");
                if (newName != null && !newName.trim().isEmpty()) {
                    user.setFullName(newName.trim());
                    userService.updateUserFullName(user.getUserId(), newName.trim());
                    session.setAttribute("user", user); // update session
                    message = "Name updated successfully!";
                    messageType = "success";
                }
            } else if ("updatePassword".equals(action)) {
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");
                if (newPassword != null && newPassword.equals(confirmPassword)) {
                    userService.updateUserPassword(user.getUserId(), newPassword);
                    message = "Password updated successfully!";
                    messageType = "success";
                } else {
                    message = "Passwords do not match.";
                }
            }
        } catch (SQLException e) {
            message = "Update failed. Please try again.";
        }

        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        loadDashboardData(request, user);
        request.getRequestDispatcher("/myaccount.jsp").forward(request, response);
    }

    private void loadDashboardData(HttpServletRequest request, User user) {
        request.setAttribute("user", user);

        try {
            List<Order> orders = orderService.getCustomerOrders(user.getUserId());
            request.setAttribute("orders", orders);
        } catch (Exception e) {
            request.setAttribute("orders", java.util.Collections.emptyList());
            request.setAttribute("error", "Unable to load your order history right now.");
        }

        try {
            List<PaymentCard> userCards = paymentCardService.getCardsByCustomer(user.getUserId());
            request.setAttribute("userCards", userCards);
        } catch (Exception e) {
            request.setAttribute("userCards", java.util.Collections.emptyList());
        }
    }
}
