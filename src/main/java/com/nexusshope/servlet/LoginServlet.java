package com.nexusshope.servlet;

import com.nexusshope.model.User;
import com.nexusshope.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String contextPath = request.getContextPath();

        try {
            User user = userService.getUserByEmail(email);

            if (user == null || !user.getPassword().equals(password)) {
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            String role = user.getRole();
            switch (role == null ? "" : role.toLowerCase()) {
                case "admin":
                    response.sendRedirect(contextPath + "/admin");
                    break;
                case "customer":
                    response.sendRedirect(contextPath + "/index.jsp");
                    break;
                case "product_manager":
                    response.sendRedirect(contextPath + "/pm/dashboard");
                    break;
                case "supplier":
                    response.sendRedirect(contextPath + "/supplier/product");
                    break;
                case "customer_service":
                    response.sendRedirect(contextPath + "/admin/faq");
                    break;
                case "delivery_person":
                    response.sendRedirect(contextPath + "/delivery");
                    break;
                default:
                    request.setAttribute("error", "Unknown user role.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Database error. Please try again later.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
