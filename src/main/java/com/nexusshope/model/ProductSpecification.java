package com.nexusshope.model;

public class ProductSpecification {
    private String specID;
    private String productID;
    private String specKey;
    private String specValue;

    public ProductSpecification() {}

    public ProductSpecification(String specKey, String specValue) {
        this.specKey = specKey;
        this.specValue = specValue;
    }

    // Getters/Setters
    public String getSpecID() { return specID; }
    public void setSpecID(String specID) { this.specID = specID; }

    public String getProductID() { return productID; }
    public void setProductID(String productID) { this.productID = productID; }

    public String getSpecKey() { return specKey; }
    public void setSpecKey(String specKey) { this.specKey = specKey; }

    public String getSpecValue() { return specValue; }
    public void setSpecValue(String specValue) { this.specValue = specValue; }

    @Override
    public String toString() {
        return specKey + ": " + specValue;
    }
}