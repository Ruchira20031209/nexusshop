package com.nexusshope.servlet;

import com.nexusshope.model.User;
import com.nexusshope.service.CartService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/cart/remove")
public class RemoveFromCartServlet extends HttpServlet {
    private CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String productID = request.getParameter("productId");

        if (productID == null || productID.trim().isEmpty()) {
            session.setAttribute("error", "Product ID is required");
            response.sendRedirect(request.getContextPath() + "/cart/view");
            return;
        }

        try {
            boolean success = cartService.removeFromCart(user.getUserId(), productID);

            if (success) {
                session.setAttribute("message", "Product removed from cart successfully!");

                // Update cart count in session
                int cartCount = cartService.getCartItemCount(user.getUserId());
                session.setAttribute("cartCount", cartCount);
            } else {
                session.setAttribute("error", "Failed to remove product from cart");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error removing from cart: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/cart/view");
    }
}