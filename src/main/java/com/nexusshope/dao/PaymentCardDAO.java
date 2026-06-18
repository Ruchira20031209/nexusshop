// File: com/nexusshope/dao/PaymentCardDAO.java
package com.nexusshope.dao;

import com.nexusshope.model.PaymentCard;

import java.sql.SQLException;
import java.util.List;

public interface PaymentCardDAO {
    List<PaymentCard> getCardsByCustomer(String customerId) throws SQLException;
    PaymentCard getCardByNumber(String cardNumber) throws SQLException;
    String insertCard(PaymentCard card) throws SQLException;
    boolean updateCard(PaymentCard card) throws SQLException;
    boolean deleteCard(String cardNumber) throws SQLException;
    boolean setDefaultCard(String cardNumber, String customerId) throws SQLException;
    PaymentCard getDefaultCard(String customerId) throws SQLException;
}