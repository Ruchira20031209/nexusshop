package com.nexusshope.model;

public class ProductManager extends User {
    private String pmID;
    private String department;

    public ProductManager() {}

    public ProductManager(String pmID, String userId, String fullName, String email, String password, String address,
                          String role, String department) {
        super(userId, fullName, email, password, address, role);
        this.pmID = pmID;
        this.department = department;
    }

    // Getters and Setters
    public String getPmID() { return pmID; }
    public void setPmID(String pmID) { this.pmID = pmID; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    @Override
    public String toString() {
        return "ProductManager{" +
                "pmID='" + pmID + '\'' +
                ", department='" + department + '\'' +
                "} " + super.toString();
    }
}