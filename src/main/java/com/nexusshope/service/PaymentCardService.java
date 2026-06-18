package com.nexusshope.service;

import com.nexusshope.dao.PaymentCardDAO;
import com.nexusshope.dao.PaymentCardDAOImpl;
import com.nexusshope.model.PaymentCard;

import java.sql.SQLException;
import java.util.List;
import java.util.Objects;

public class PaymentCardService {
    private final PaymentCardDAO cardDAO;

    public PaymentCardService() {
        this(new PaymentCardDAOImpl());
    }

    public PaymentCardService(PaymentCardDAO cardDAO) {
        this.cardDAO = Objects.requireNonNull(cardDAO, "cardDAO");
    }

    public List<PaymentCard> getCardsByCustomer(String customerId) throws SQLException {
        return cardDAO.getCardsByCustomer(customerId);
    }

    public PaymentCard getCardByNumber(String cardNumber) throws SQLException {
        return cardDAO.getCardByNumber(cardNumber);
    }

    public String addCard(PaymentCard card) throws SQLException {
        return cardDAO.insertCard(card);
    }

    public boolean updateCard(PaymentCard card) throws SQLException {
        return cardDAO.updateCard(card);
    }

    public boolean deleteCard(String cardNumber) throws SQLException {
        return cardDAO.deleteCard(cardNumber);
    }

    public boolean setDefaultCard(String cardNumber, String customerId) throws SQLException {
        return cardDAO.setDefaultCard(cardNumber, customerId);
    }

    public PaymentCard getDefaultCard(String customerId) throws SQLException {
        return cardDAO.getDefaultCard(customerId);
    }
}
