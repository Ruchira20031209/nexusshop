package com.nexusshope.service;

import com.nexusshope.dao.FAQDAO;
import com.nexusshope.dao.FAQDAOImpl;
import com.nexusshope.model.FAQ;

import java.sql.SQLException;
import java.util.List;
import java.util.Objects;

public class FAQService {
    private final FAQDAO faqDAO;

    public FAQService() {
        this(new FAQDAOImpl());
    }

    public FAQService(FAQDAO faqDAO) {
        this.faqDAO = Objects.requireNonNull(faqDAO, "faqDAO");
    }

    public List<FAQ> getAllFAQs() throws SQLException {
        return faqDAO.getAllFAQs();
    }

    public FAQ getFAQById(String faqID) throws SQLException {
        return faqDAO.getFAQById(faqID);
    }

    public String addFAQ(FAQ faq) throws SQLException {
        return faqDAO.insertFAQ(faq);
    }

    public void updateFAQ(FAQ faq) throws SQLException {
        faqDAO.updateFAQ(faq);
    }

    public void deleteFAQ(String faqID) throws SQLException {
        faqDAO.deleteFAQ(faqID);
    }

    public List<String> getAllCategories() throws SQLException {
        return faqDAO.getAllCategories();
    }

    public List<FAQ> getFAQsByProductType(String productType) throws SQLException {
        return faqDAO.getFAQsByProductType(productType);
    }

    public List<FAQ> getFAQsByProductCategory(String productCategory) throws SQLException {
        return faqDAO.getFAQsByProductCategory(productCategory);
    }

    public List<FAQ> getGeneralFAQs() throws SQLException {
        return faqDAO.getGeneralFAQs();
    }
}
