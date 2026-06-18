// File: com/nexusshope/dao/PaymentCardDAOImpl.java
package com.nexusshope.dao;

import com.nexusshope.model.PaymentCard;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentCardDAOImpl extends AbstractDAO implements PaymentCardDAO {

    @Override
    public List<PaymentCard> getCardsByCustomer(String customerId) throws SQLException {
        List<PaymentCard> cards = new ArrayList<>();
        String sql = "SELECT * FROM payment_cards WHERE customer_id = ? ORDER BY is_default DESC, created_date DESC";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    cards.add(mapResultSetToCard(rs));
                }
            }
        }
        return cards;
    }

    @Override
    public PaymentCard getCardByNumber(String cardNumber) throws SQLException {
        String sql = "SELECT * FROM payment_cards WHERE card_number = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cardNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCard(rs);
                }
            }
        }
        return null;
    }

    @Override
    public String insertCard(PaymentCard card) throws SQLException {
        String sql = "{CALL InsertPaymentCard(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, card.getCustomerId());
            cs.setString(2, card.getCardHolderName());
            cs.setString(3, card.getCardType());
            cs.setString(4, card.getCardNumberMasked());
            cs.setInt(5, card.getExpiryMonth());
            cs.setInt(6, card.getExpiryYear());
            cs.setString(7, card.getCvv());
            cs.setString(8, card.getBillingAddress());
            cs.setBoolean(9, card.isDefault());

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("NewCardNumber");
                }
            }
        }
        return null;
    }

    @Override
    public boolean updateCard(PaymentCard card) throws SQLException {
        String sql = "UPDATE payment_cards SET card_holder_name = ?, card_type = ?, card_number_masked = ?, " +
                "expiry_month = ?, expiry_year = ?, cvv = ?, billing_address = ?, is_default = ?, " +
                "updated_date = GETDATE() WHERE card_number = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, card.getCardHolderName());
            ps.setString(2, card.getCardType());
            ps.setString(3, card.getCardNumberMasked());
            ps.setInt(4, card.getExpiryMonth());
            ps.setInt(5, card.getExpiryYear());
            ps.setString(6, card.getCvv());
            ps.setString(7, card.getBillingAddress());
            ps.setBoolean(8, card.isDefault());
            ps.setString(9, card.getCardNumber());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean deleteCard(String cardNumber) throws SQLException {
        String sql = "DELETE FROM payment_cards WHERE card_number = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cardNumber);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean setDefaultCard(String cardNumber, String customerId) throws SQLException {
        // First, set all cards for this customer to non-default
        String sql1 = "UPDATE payment_cards SET is_default = 0 WHERE customer_id = ?";
        // Then, set the specified card as default
        String sql2 = "UPDATE payment_cards SET is_default = 1 WHERE card_number = ?";

        try (Connection conn = openConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(sql1)) {
                ps1.setString(1, customerId);
                ps1.executeUpdate();
            }
            try (PreparedStatement ps2 = conn.prepareStatement(sql2)) {
                ps2.setString(1, cardNumber);
                ps2.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            //conn.rollback();
            throw e;
        }
    }

    @Override
    public PaymentCard getDefaultCard(String customerId) throws SQLException {
        String sql = "SELECT * FROM payment_cards WHERE customer_id = ? AND is_default = 1";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCard(rs);
                }
            }
        }
        return null;
    }

    private PaymentCard mapResultSetToCard(ResultSet rs) throws SQLException {
        PaymentCard card = new PaymentCard();
        card.setCardNumber(rs.getString("card_number"));
        card.setCustomerId(rs.getString("customer_id"));
        card.setCardHolderName(rs.getString("card_holder_name"));
        card.setCardType(rs.getString("card_type"));
        card.setCardNumberMasked(rs.getString("card_number_masked"));
        card.setExpiryMonth(rs.getInt("expiry_month"));
        card.setExpiryYear(rs.getInt("expiry_year"));
        card.setCvv(rs.getString("cvv"));
        card.setBillingAddress(rs.getString("billing_address"));
        card.setDefault(rs.getBoolean("is_default"));
        return card;
    }
}
