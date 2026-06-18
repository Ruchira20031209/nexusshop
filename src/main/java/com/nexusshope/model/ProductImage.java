// File: com/nexusshope/model/ProductImage.java
package com.nexusshope.model;

public class ProductImage {
    private String imageID;
    private String productID;
    private String imageUrl;
    private boolean isPrimary;

    public ProductImage() {}

    public ProductImage(String productID, String imageUrl, boolean isPrimary) {
        this.productID = productID;
        this.imageUrl = imageUrl;
        this.isPrimary = isPrimary;
    }

    // Getters and Setters
    public String getImageID() { return imageID; }
    public void setImageID(String imageID) { this.imageID = imageID; }

    public String getProductID() { return productID; }
    public void setProductID(String productID) { this.productID = productID; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public boolean isPrimary() { return isPrimary; }
    public void setPrimary(boolean primary) { isPrimary = primary; }

    @Override
    public String toString() {
        return "ProductImage{" +
                "imageID='" + imageID + '\'' +
                ", productID='" + productID + '\'' +
                ", imageUrl='" + imageUrl + '\'' +
                ", isPrimary=" + isPrimary +
                '}';
    }
}