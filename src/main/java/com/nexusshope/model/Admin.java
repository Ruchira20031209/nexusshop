package com.nexusshope.model;

import java.sql.Date;

public class Admin extends User {
    private String adminID;
    private Date registeredDate;
    private String department;

    public Admin() {}

    public Admin(String adminID, String userId, String fullName, String email, String password, String address,
                 String role, Date registeredDate, String department) {
        super(userId, fullName, email, password, address, role);
        this.adminID = adminID;
        this.registeredDate = registeredDate;
        this.department = department;
    }

    // Getters and Setters
    public String getAdminID() { return adminID; }
    public void setAdminID(String adminID) { this.adminID = adminID; }

    public Date getRegisteredDate() { return registeredDate; }
    public void setRegisteredDate(Date registeredDate) { this.registeredDate = registeredDate; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    @Override
    public String toString() {
        return "Admin{" +
                "adminID='" + adminID + '\'' +
                ", registeredDate=" + registeredDate +
                ", department='" + department + '\'' +
                "} " + super.toString();
    }
}