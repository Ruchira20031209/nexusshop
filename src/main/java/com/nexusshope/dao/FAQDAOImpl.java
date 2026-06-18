// File: com/nexusshope/dao/FAQDAOImpl.java
package com.nexusshope.dao;

import com.nexusshope.model.FAQ;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FAQDAOImpl extends AbstractDAO implements FAQDAO {

    @Override
    public List<FAQ> getAllFAQs() throws SQLException {
        List<FAQ> faqs = new ArrayList<>();
        String sql = "SELECT * FROM faqs ORDER BY faqID";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                faqs.add(mapResultSetToFAQ(rs));
            }
        }
        return faqs;
    }

    @Override
    public FAQ getFAQById(String faqID) throws SQLException {
        String sql = "SELECT faqID, question, answer, category FROM faqs WHERE faqID = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, faqID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    FAQ faq = new FAQ();
                    faq.setFaqID(rs.getString("faqID"));
                    faq.setQuestion(rs.getString("question"));
                    faq.setAnswer(rs.getString("answer"));
                    faq.setCategory(rs.getString("category"));
                    return faq;
                }
            }
        }
        return null;
    }

    @Override
    public String insertFAQ(FAQ faq) throws SQLException {
        String sql = "{CALL InsertFAQ(?, ?, ?)}";
        try (Connection conn = openConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, faq.getQuestion());
            cs.setString(2, faq.getAnswer());
            cs.setString(3, faq.getCategory());
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("NewFaqID");
                }
            }
        }
        return null;
    }

    @Override
    public void updateFAQ(FAQ faq) throws SQLException {
        String sql = "UPDATE faqs SET question = ?, answer = ?, category = ? WHERE faqID = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, faq.getQuestion());
            ps.setString(2, faq.getAnswer());
            ps.setString(3, faq.getCategory());
            ps.setString(4, faq.getFaqID());
            ps.executeUpdate();
        }
    }

    @Override
    public void deleteFAQ(String faqID) throws SQLException {
        String sql = "DELETE FROM faqs WHERE faqID = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, faqID);
            ps.executeUpdate();
        }
    }

    @Override
    public List<String> getAllCategories() throws SQLException {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM faqs ORDER BY category";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        }
        // Add default categories if needed
        if (!categories.contains("general")) categories.add("general");
        if (!categories.contains("shipping")) categories.add("shipping");
        if (!categories.contains("returns")) categories.add("returns");
        if (!categories.contains("account")) categories.add("account");
        return categories;
    }

    @Override
    public List<FAQ> getFAQsByProductType(String productType) throws SQLException {
        List<FAQ> faqs = new ArrayList<>();
        String sql = "SELECT * FROM faqs WHERE product_type = ? AND is_product_specific = 1 ORDER BY faqID";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    faqs.add(mapResultSetToFAQ(rs));
                }
            }
        }
        return faqs;
    }

    @Override
    public List<FAQ> getFAQsByProductCategory(String productCategory) throws SQLException {
        List<FAQ> faqs = new ArrayList<>();
        String sql = "SELECT * FROM faqs WHERE product_category = ? AND is_product_specific = 1 ORDER BY faqID";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productCategory);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    faqs.add(mapResultSetToFAQ(rs));
                }
            }
        }
        return faqs;
    }

    @Override
    public List<FAQ> getGeneralFAQs() throws SQLException {
        List<FAQ> faqs = new ArrayList<>();
        String sql = "SELECT * FROM faqs WHERE is_product_specific = 0 ORDER BY faqID";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                faqs.add(mapResultSetToFAQ(rs));
            }
        }
        return faqs;
    }

    // Add this helper method
    private FAQ mapResultSetToFAQ(ResultSet rs) throws SQLException {
        FAQ faq = new FAQ();
        faq.setFaqID(rs.getString("faqID"));
        faq.setQuestion(rs.getString("question"));
        faq.setAnswer(rs.getString("answer"));
        faq.setCategory(rs.getString("category"));
        faq.setProductType(rs.getString("product_type"));
        faq.setProductCategory(rs.getString("product_category"));
        faq.setProductSpecific(rs.getBoolean("is_product_specific"));
        return faq;
    }
}
