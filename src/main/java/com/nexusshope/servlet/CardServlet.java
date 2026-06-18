// File: com/nexusshope/servlet/CardServlet.java
package com.nexusshope.servlet;

import com.nexusshope.model.PaymentCard;
import com.nexusshope.model.User;
import com.nexusshope.service.PaymentCardService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.time.Month;
import java.time.Year;
import java.util.List;

@WebServlet("/cards")
public class CardServlet extends HttpServlet {
    private PaymentCardService cardService = new PaymentCardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/myaccount");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String message = null;
        String messageType = "error";

        try {
            switch (action) {
                case "add":
                    message = handleAddCard(request, user);
                    messageType = "success";
                    break;

                case "delete":
                    message = handleDeleteCard(request, user);
                    messageType = "success";
                    break;

                case "setDefault":
                    message = handleSetDefaultCard(request, user);
                    messageType = "success";
                    break;

                case "update":
                    message = handleUpdateCard(request, user);
                    messageType = "success";
                    break;

                default:
                    message = "Invalid action.";
            }
        } catch (Exception e) {
            message = "Operation failed: " + e.getMessage();
            e.printStackTrace();
        }

        session.setAttribute("cardMessage", message);
        session.setAttribute("cardMessageType", messageType);

        response.sendRedirect(request.getContextPath() + "/myaccount");
    }

    private String handleAddCard(HttpServletRequest request, User user) throws SQLException {
        String cardNumber = request.getParameter("cardNumber").replace(" ", "");
        String cardHolderName = request.getParameter("cardHolderName");
        String cardType = request.getParameter("cardType");
        String cvv = request.getParameter("cvv");
        int expiryMonth = Integer.parseInt(request.getParameter("expiryMonth"));
        int expiryYear = Integer.parseInt(request.getParameter("expiryYear"));
        String billingAddress = request.getParameter("billingAddress");
        boolean isDefault = "on".equals(request.getParameter("isDefault")); // checkbox value

        // Validate card number format (16 digits)
        if (cardNumber.length() != 16 || !cardNumber.matches("\\d+")) {
            throw new IllegalArgumentException("Invalid card number format. Must be 16 digits.");
        }

        // Validate CVV (3-4 digits)
        if (cvv.length() < 3 || cvv.length() > 4 || !cvv.matches("\\d+")) {
            throw new IllegalArgumentException("Invalid CVV format. Must be 3-4 digits.");
        }

        // Validate expiry date
        validateExpiryDate(expiryMonth, expiryYear);

        // Mask the card number for storage
        String maskedNumber = "**** **** **** " + cardNumber.substring(12);

        PaymentCard card = new PaymentCard();
        card.setCustomerId(user.getUserId());
        card.setCardHolderName(cardHolderName);
        card.setCardType(cardType);
        card.setCardNumberMasked(maskedNumber);
        card.setExpiryMonth(expiryMonth);
        card.setExpiryYear(expiryYear);
        card.setCvv(cvv);
        card.setBillingAddress(billingAddress);
        card.setDefault(isDefault);

        String newCardNumber = cardService.addCard(card);

        if (newCardNumber == null) {
            throw new SQLException("Failed to add card to database.");
        }

        // If this is set as default, update other cards
        if (isDefault) {
            cardService.setDefaultCard(newCardNumber, user.getUserId());
        }

        return "Card added successfully! Card ID: " + newCardNumber;
    }

    private String handleDeleteCard(HttpServletRequest request, User user) throws SQLException {
        String cardNumber = request.getParameter("cardNumber");

        // Verify card belongs to user
        PaymentCard card = cardService.getCardByNumber(cardNumber);
        if (card == null || !card.getCustomerId().equals(user.getUserId())) {
            throw new IllegalArgumentException("Card not found or access denied.");
        }

        if (cardService.deleteCard(cardNumber)) {
            return "Card deleted successfully!";
        } else {
            throw new SQLException("Failed to delete card.");
        }
    }

    private String handleSetDefaultCard(HttpServletRequest request, User user) throws SQLException {
        String cardNumber = request.getParameter("cardNumber");

        // Verify card belongs to user
        PaymentCard card = cardService.getCardByNumber(cardNumber);
        if (card == null || !card.getCustomerId().equals(user.getUserId())) {
            throw new IllegalArgumentException("Card not found or access denied.");
        }

        if (cardService.setDefaultCard(cardNumber, user.getUserId())) {
            return "Default card updated successfully!";
        } else {
            throw new SQLException("Failed to update default card.");
        }
    }

    private String handleUpdateCard(HttpServletRequest request, User user) throws SQLException {
        String cardNumber = request.getParameter("cardNumber");
        String cardHolderName = request.getParameter("cardHolderName");
        String cardType = request.getParameter("cardType");
        String billingAddress = request.getParameter("billingAddress");
        boolean isDefault = "on".equals(request.getParameter("isDefault"));

        // Verify card belongs to user
        PaymentCard card = cardService.getCardByNumber(cardNumber);
        if (card == null || !card.getCustomerId().equals(user.getUserId())) {
            throw new IllegalArgumentException("Card not found or access denied.");
        }

        // Update card details
        card.setCardHolderName(cardHolderName);
        card.setCardType(cardType);
        card.setBillingAddress(billingAddress);
        card.setDefault(isDefault);

        if (cardService.updateCard(card)) {
            // If this is set as default, update other cards
            if (isDefault) {
                cardService.setDefaultCard(cardNumber, user.getUserId());
            }
            return "Card updated successfully!";
        } else {
            throw new SQLException("Failed to update card.");
        }
    }

    private void validateExpiryDate(int month, int year) {
        if (month < 1 || month > 12) {
            throw new IllegalArgumentException("Invalid expiry month. Must be 1-12.");
        }

        int currentYear = Year.now().getValue();
        if (year > currentYear + 20) {
            throw new IllegalArgumentException("Card expiry year is too far in the future.");
        }
    }
}
