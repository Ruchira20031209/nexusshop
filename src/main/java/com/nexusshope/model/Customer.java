package com.nexusshope.model;

import java.sql.Date;

public class Customer extends User {
    private String customerID;
    private String phoneNumber;
    private Date dateOfBirth;

    public Customer() {}

    public Customer(String customerID, String userId, String fullName, String email, String password, String address,
                    String role, String phoneNumber, Date dateOfBirth) {
        super(userId, fullName, email, password, address, role);
        this.customerID = customerID;
        this.phoneNumber = phoneNumber;
        this.dateOfBirth = dateOfBirth;
    }

    // Getters and Setters
    public String getCustomerID() { return customerID; }
    public void setCustomerID(String customerID) { this.customerID = customerID; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public Date getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    @Override
    public String toString() {
        return "Customer{" +
                "customerID='" + customerID + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", dateOfBirth=" + dateOfBirth +
                "} " + super.toString();
    }
}