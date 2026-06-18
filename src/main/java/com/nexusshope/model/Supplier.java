package com.nexusshope.model;

public class Supplier extends User {
    private String sID;
    private String companyName;
    private String contactPerson;

    public Supplier() {}

    public Supplier(String sID, String userId, String fullName, String email, String password, String address,
                    String role, String companyName, String contactPerson) {
        super(userId, fullName, email, password, address, role);
        this.sID = sID;
        this.companyName = companyName;
        this.contactPerson = contactPerson;
    }

    // Getters and Setters
    public String getsID() { return sID; }
    public void setsID(String sID) { this.sID = sID; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getContactPerson() { return contactPerson; }
    public void setContactPerson(String contactPerson) { this.contactPerson = contactPerson; }

    @Override
    public String toString() {
        return "Supplier{" +
                "sID='" + sID + '\'' +
                ", companyName='" + companyName + '\'' +
                ", contactPerson='" + contactPerson + '\'' +
                "} " + super.toString();
    }
}