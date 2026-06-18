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

@WebServlet("/cart/add")
public class AddToCartServlet extends HttpServlet {
    private CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("DEBUG: AddToCartServlet called");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            System.out.println("DEBUG: User not logged in, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String productID = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

        System.out.println("DEBUG: Parameters - productId: " + productID + ", quantity: " + quantityStr);

        if (productID == null || productID.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        int quantity = 1;
        if (quantityStr != null && !quantityStr.trim().isEmpty()) {
            try {
                quantity = Integer.parseInt(quantityStr);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/products");
                return;
            }
        }

        try {
            System.out.println("DEBUG: Calling cartService.addToCart");
            boolean success = cartService.addToCart(user.getUserId(), productID, quantity);

            if (success) {
                System.out.println("DEBUG: Item added successfully");
                session.setAttribute("message", "Product added to cart successfully!");

                // Update cart count in session
                int cartCount = cartService.getCartItemCount(user.getUserId());
                session.setAttribute("cartCount", cartCount);
                System.out.println("DEBUG: Cart count updated to: " + cartCount);
            } else {
                System.out.println("DEBUG: Failed to add item to cart");
                session.setAttribute("error", "Failed to add product to cart");
            }

        } catch (Exception e) {
            System.err.println("ERROR in AddToCartServlet: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Error adding to cart: " + e.getMessage());
        }

        String referer = request.getHeader("Referer");
        System.out.println("DEBUG: Redirecting to: " + referer);
        if (referer != null && !referer.contains("/cart/")) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }
}