package com.nexusshope.servlet;

import com.nexusshope.model.*;
import com.nexusshope.service.CartService;
import com.nexusshope.service.OrderService;
import com.nexusshope.service.PaymentCardService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private CartService cartService = new CartService();
    private OrderService orderService = new OrderService();
    private PaymentCardService paymentCardService = new PaymentCardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== CHECKOUT GET REQUEST STARTED ===");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        System.out.println("User in session: " + (user != null ? user.getUserId() : "NULL"));

        if (user == null) {
            System.out.println("No user found, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Get cart and order summary
            System.out.println("Getting cart for user: " + user.getUserId());
            Cart cart = cartService.getCart(user.getUserId());
            System.out.println("Cart retrieved: " + (cart != null ? "Cart ID: " + cart.getCartID() + ", Items: " + cart.getItems().size() : "NULL"));

            OrderSummary summary = orderService.getOrderSummary(user.getUserId());
            System.out.println("Order summary: " + (summary != null ? "Total: $" + summary.getTotal() : "NULL"));

            if (cart == null || cart.isEmpty()) {
                System.out.println("Cart is empty, redirecting to cart");
                session.setAttribute("error", "Your cart is empty");
                response.sendRedirect(request.getContextPath() + "/cart/view");
                return;
            }

            // Get saved payment cards
            System.out.println("Getting saved payment cards for user: " + user.getUserId());
            List<PaymentCard> savedCards = paymentCardService.getCardsByCustomer(user.getUserId());
            PaymentCard defaultCard = paymentCardService.getDefaultCard(user.getUserId());

            System.out.println("Saved cards found: " + savedCards.size());
            System.out.println("Default card: " + (defaultCard != null ? defaultCard.getCardNumber() : "NULL"));

            request.setAttribute("cart", cart);
            request.setAttribute("summary", summary);
            request.setAttribute("savedCards", savedCards);
            request.setAttribute("defaultCard", defaultCard);
            request.setAttribute("hasSavedCards", !savedCards.isEmpty());

        } catch (Exception e) {
            System.err.println("ERROR in doGet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error loading checkout: " + e.getMessage());
        }

        System.out.println("=== CHECKOUT GET REQUEST COMPLETED ===");
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== CHECKOUT POST REQUEST STARTED ===");
        System.out.println("Request URL: " + request.getRequestURL());
        System.out.println("Request Method: " + request.getMethod());

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        System.out.println("User in session: " + (user != null ? user.getUserId() : "NULL"));

        if (user == null) {
            System.out.println("❌ No user in session, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Get ALL parameters first
            System.out.println("📋 ALL FORM PARAMETERS:");
            Enumeration<String> paramNames = request.getParameterNames();
            boolean hasParams = false;
            while (paramNames.hasMoreElements()) {
                hasParams = true;
                String paramName = paramNames.nextElement();
                String paramValue = request.getParameter(paramName);
                System.out.println("   " + paramName + " = " + paramValue);
            }
            if (!hasParams) {
                System.out.println("❌ NO FORM PARAMETERS RECEIVED!");
            }

            // Get specific parameters
            String shippingAddress = request.getParameter("shippingAddress");
            String selectedCardId = request.getParameter("selectedCard");
            String useNewCard = request.getParameter("useNewCard");
            String saveCard = request.getParameter("saveCard");

            System.out.println("🎯 KEY PARAMETERS:");
            System.out.println("   shippingAddress = " + shippingAddress);
            System.out.println("   selectedCard = " + selectedCardId);
            System.out.println("   useNewCard = " + useNewCard);
            System.out.println("   saveCard = " + saveCard);

            // Validate shipping address
            if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
                System.out.println("❌ Shipping address validation failed - EMPTY");
                session.setAttribute("error", "Shipping address is required");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }
            System.out.println("✅ Shipping address validated: " + shippingAddress);

            PaymentCard paymentCard = null;

            // Determine payment method
            boolean usingSavedCard = (selectedCardId != null && !selectedCardId.isEmpty());
            boolean usingNewCard = (useNewCard != null);

            System.out.println("💳 PAYMENT METHOD ANALYSIS:");
            System.out.println("   Using saved card: " + usingSavedCard);
            System.out.println("   Using new card: " + usingNewCard);

            if (usingSavedCard) {
                System.out.println("🔍 Processing saved card: " + selectedCardId);
                paymentCard = paymentCardService.getCardByNumber(selectedCardId);
                if (paymentCard == null) {
                    System.out.println("❌ Saved card not found: " + selectedCardId);
                    session.setAttribute("error", "Selected payment card not found");
                    response.sendRedirect(request.getContextPath() + "/checkout");
                    return;
                }
                System.out.println("✅ Saved card found: " + paymentCard.getCardNumberMasked());
            } else if (usingNewCard) {
                System.out.println("🆕 Processing new card");
                // Handle new card logic...
            } else {
                System.out.println("❌ NO PAYMENT METHOD SELECTED!");
                session.setAttribute("error", "Please select a payment method");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            System.out.println("🛒 Creating order from cart...");
            Order order = orderService.createOrderFromCart(user.getUserId(), shippingAddress, paymentCard);

            if (order != null) {
                System.out.println("✅ Order created successfully! Order ID: " + order.getOrderID());
                session.setAttribute("message", "Order placed successfully! Order ID: " + order.getOrderID());
                session.setAttribute("order", order);
                System.out.println("🔄 Redirecting to order confirmation");
                response.sendRedirect(request.getContextPath() + "/order/confirmation");
            } else {
                System.out.println("❌ Order creation failed - returned null");
                session.setAttribute("error", "Failed to place order. Please try again.");
                response.sendRedirect(request.getContextPath() + "/checkout");
            }

        } catch (Exception e) {
            System.err.println("💥 ERROR in doPost: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Error during checkout: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/checkout");
        }

        System.out.println("=== CHECKOUT POST REQUEST COMPLETED ===");
    }
}