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

@WebServlet("/cart/update")
public class UpdateCartServlet extends HttpServlet {
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
        String quantityStr = request.getParameter("quantity");

        if (productID == null || quantityStr == null) {
            session.setAttribute("error", "Product ID and quantity are required");
            response.sendRedirect(request.getContextPath() + "/cart/view");
            return;
        }

        try {
            int quantity = Integer.parseInt(quantityStr);
            boolean success = cartService.updateQuantity(user.getUserId(), productID, quantity);

            if (success) {
                session.setAttribute("message", "Cart updated successfully!");

                // Update cart count in session
                int cartCount = cartService.getCartItemCount(user.getUserId());
                session.setAttribute("cartCount", cartCount);
            } else {
                session.setAttribute("error", "Failed to update cart");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid quantity format");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error updating cart: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/cart/view");
    }
}