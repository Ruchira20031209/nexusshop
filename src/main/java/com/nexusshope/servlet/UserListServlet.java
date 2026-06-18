// File: com/nexusshope/servlet/UserListServlet.java
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
import java.util.List;

@WebServlet("/admin/users")
public class UserListServlet extends HttpServlet {

    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session == null ? null : (User) session.getAttribute("user");
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            List<User> users = userService.getAllUsers();
            request.setAttribute("userList", users);
        } catch (SQLException e) {
            request.setAttribute("error", "Failed to load users.");
        }
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }
}
