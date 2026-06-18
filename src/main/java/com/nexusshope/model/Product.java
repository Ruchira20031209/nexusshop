package com.nexusshope.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class Product {
    private String productID;
    private String name;
    private String sku;
    private String category;
    private double price;
    private int stock;
    private String description;
    private String status;
    private String supplierId;
    private double rating;
    private java.sql.Timestamp createdDate;
    private java.sql.Timestamp updatedDate;
    private String primaryImageUrl;

    // New: rejectionNotes
    private String rejectionNotes;

    // New: List of specifications
    private List<ProductSpecification> specifications = new ArrayList<>();

    // Constructors
    public Product() {}

    public String getProductID() { return productID; }
    public void setProductID(String productID) { this.productID = productID; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }

    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getSupplierId() { return supplierId; }
    public void setSupplierId(String supplierId) { this.supplierId = supplierId; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public java.sql.Timestamp getCreatedDate() { return createdDate; }
    public void setCreatedDate(java.sql.Timestamp createdDate) { this.createdDate = createdDate; }

    public java.sql.Timestamp getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(java.sql.Timestamp updatedDate) { this.updatedDate = updatedDate; }

    // New: rejectionNotes getters/setters
    public String getRejectionNotes() { return rejectionNotes; }
    public void setRejectionNotes(String rejectionNotes) { this.rejectionNotes = rejectionNotes; }

    // New: Specs getters/setters
    public List<ProductSpecification> getSpecifications() { return specifications; }
    public void setSpecifications(List<ProductSpecification> specifications) { this.specifications = specifications; }

    public String getPrimaryImageUrl() { return primaryImageUrl; }
    public void setPrimaryImageUrl(String primaryImageUrl) { this.primaryImageUrl = primaryImageUrl; }
    @Override
    public String toString() {
        return "Product{" +
                "productID='" + productID + '\'' +
                ", name='" + name + '\'' +
                ", sku='" + sku + '\'' +
                ", category='" + category + '\'' +
                ", price=" + price +
                ", stock=" + stock +
                ", description='" + description + '\'' +
                ", status='" + status + '\'' +
                ", supplierId='" + supplierId + '\'' +
                ", rating=" + rating +
                ", rejectionNotes='" + rejectionNotes + '\'' +
                ", specifications=" + specifications +
                '}';
    }
}