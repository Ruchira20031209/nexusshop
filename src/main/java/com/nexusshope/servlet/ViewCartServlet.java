package com.nexusshope.servlet;

import com.nexusshope.model.Cart;
import com.nexusshope.model.User;
import com.nexusshope.service.CartService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/cart/view")
public class ViewCartServlet extends HttpServlet {
    private CartService cartService = new CartService();

    // In ViewCartServlet.java
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
            Cart cart = cartService.getCart(user.getUserId());

            // Make sure cart is set in request attributes
            request.setAttribute("cart", cart);

            // Update cart count in session
            int cartCount = cartService.getCartItemCount(user.getUserId());
            session.setAttribute("cartCount", cartCount);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading cart: " + e.getMessage());
        }

        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }
}