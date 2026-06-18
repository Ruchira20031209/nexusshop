// File: com/nexusshope/dao/FAQDAO.java
package com.nexusshope.dao;

import com.nexusshope.model.FAQ;

import java.sql.SQLException;
import java.util.List;

public interface FAQDAO {
    List<FAQ> getAllFAQs() throws SQLException;
    FAQ getFAQById(String faqID) throws SQLException;
    String insertFAQ(FAQ faq) throws SQLException;
    void updateFAQ(FAQ faq) throws SQLException;
    void deleteFAQ(String faqID) throws SQLException;
    List<String> getAllCategories() throws SQLException;

    List<FAQ> getFAQsByProductType(String productType) throws SQLException;

    List<FAQ> getFAQsByProductCategory(String productCategory) throws SQLException;

    List<FAQ> getGeneralFAQs() throws SQLException;
}
