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

@WebServlet("/order/detail")
public class OrderDetailServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String orderID = request.getParameter("id");
        if (orderID == null || orderID.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        try {
            Order order = orderService.getOrder(orderID);

            // Security check - ensure user owns this order
            if (order != null && order.getCustomerID().equals(user.getUserId())) {
                request.setAttribute("order", order);
                request.getRequestDispatcher("/order-detail.jsp").forward(request, response);
            } else {
                session.setAttribute("error", "Order not found or access denied");
                response.sendRedirect(request.getContextPath() + "/orders");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error loading order details: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/orders");
        }
    }
}