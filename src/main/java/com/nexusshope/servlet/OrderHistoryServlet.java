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
import java.util.List;

@WebServlet("/orders")
public class OrderHistoryServlet extends HttpServlet {
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

        try {
            List<Order> orders = orderService.getCustomerOrders(user.getUserId());
            request.setAttribute("orders", orders);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading orders: " + e.getMessage());
        }

        request.getRequestDispatcher("/order-history.jsp").forward(request, response);
    }
}