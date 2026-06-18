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

@WebServlet("/order/confirmation")
public class OrderConfirmationServlet extends HttpServlet {
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

        // Get order from session or redirect
        Order order = (Order) session.getAttribute("order");
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        request.setAttribute("order", order);
        request.getRequestDispatcher("/order-confirmation.jsp").forward(request, response);

        // Remove order from session after displaying
        session.removeAttribute("order");
    }
}