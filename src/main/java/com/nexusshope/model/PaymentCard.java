// File: com/nexusshope/model/PaymentCard.java
package com.nexusshope.model;

public class PaymentCard {
    private String cardNumber;
    private String customerId;
    private String cardHolderName;
    private String cardType; // Visa, Mastercard, etc.
    private String cardNumberMasked; // **** **** **** 1234
    private int expiryMonth;
    private int expiryYear;
    private String cvv;
    private String billingAddress;
    private boolean isDefault;

    public PaymentCard() {}

    public PaymentCard(String customerId, String cardHolderName, String cardType,
                       String cardNumberMasked, int expiryMonth, int expiryYear, String cvv) {
        this.customerId = customerId;
        this.cardHolderName = cardHolderName;
        this.cardType = cardType;
        this.cardNumberMasked = cardNumberMasked;
        this.expiryMonth = expiryMonth;
        this.expiryYear = expiryYear;
        this.cvv = cvv;
    }

    // Getters and Setters
    public String getCardNumber() { return cardNumber; }
    public void setCardNumber(String cardNumber) { this.cardNumber = cardNumber; }

    public String getCustomerId() { return customerId; }
    public void setCustomerId(String customerId) { this.customerId = customerId; }

    public String getCardHolderName() { return cardHolderName; }
    public void setCardHolderName(String cardHolderName) { this.cardHolderName = cardHolderName; }

    public String getCardType() { return cardType; }
    public void setCardType(String cardType) { this.cardType = cardType; }

    public String getCardNumberMasked() { return cardNumberMasked; }
    public void setCardNumberMasked(String cardNumberMasked) { this.cardNumberMasked = cardNumberMasked; }

    public int getExpiryMonth() { return expiryMonth; }
    public void setExpiryMonth(int expiryMonth) { this.expiryMonth = expiryMonth; }

    public int getExpiryYear() { return expiryYear; }
    public void setExpiryYear(int expiryYear) { this.expiryYear = expiryYear; }

    public String getCvv() { return cvv; }
    public void setCvv(String cvv) { this.cvv = cvv; }

    public String getBillingAddress() { return billingAddress; }
    public void setBillingAddress(String billingAddress) { this.billingAddress = billingAddress; }

    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean isDefault) { this.isDefault = isDefault; }

    @Override
    public String toString() {
        return "PaymentCard{" +
                "cardNumber='" + cardNumber + '\'' +
                ", cardHolderName='" + cardHolderName + '\'' +
                ", cardType='" + cardType + '\'' +
                ", expiryMonth=" + expiryMonth +
                ", expiryYear=" + expiryYear +
                ", isDefault=" + isDefault +
                '}';
    }
}