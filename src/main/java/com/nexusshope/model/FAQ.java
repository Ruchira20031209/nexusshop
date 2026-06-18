// File: com/nexusshope/model/FAQ.java
package com.nexusshope.model;

import java.time.LocalDateTime;

public class FAQ {
    private String faqID;
    private String question;
    private String answer;
    private String category;
    private String productType;        // Specific product (iPhone 15, MacBook Pro)
    private String productCategory;    // General category (Mobile Phones, Laptops)
    private boolean isProductSpecific; // true if specific to product
    private LocalDateTime createdDate;
    private LocalDateTime updatedDate;

    // Constructors
    public FAQ() {}

    public FAQ(String faqID, String question, String answer, String category) {
        this.faqID = faqID;
        this.question = question;
        this.answer = answer;
        this.category = category;
    }

    // Getters and Setters
    public String getFaqID() { return faqID; }
    public void setFaqID(String faqID) { this.faqID = faqID; }

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getProductType() { return productType; }
    public void setProductType(String productType) { this.productType = productType; }

    public String getProductCategory() { return productCategory; }
    public void setProductCategory(String productCategory) { this.productCategory = productCategory; }

    public boolean isProductSpecific() { return isProductSpecific; }
    public void setProductSpecific(boolean productSpecific) { isProductSpecific = productSpecific; }

    public LocalDateTime getCreatedDate() { return createdDate; }
    public void setCreatedDate(LocalDateTime createdDate) { this.createdDate = createdDate; }

    public LocalDateTime getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(LocalDateTime updatedDate) { this.updatedDate = updatedDate; }

    @Override
    public String toString() {
        return "FAQ{" +
                "faqID='" + faqID + '\'' +
                ", question='" + question + '\'' +
                ", category='" + category + '\'' +
                ", productType='" + productType + '\'' +
                ", isProductSpecific=" + isProductSpecific +
                '}';
    }
}