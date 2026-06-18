package com.nexusshope.model;

public class CustomerServiceStaff extends User {
    private String csID;
    private String employeeId;
    private String department;

    public CustomerServiceStaff() {}

    public CustomerServiceStaff(String csID, String userId, String fullName, String email, String password, String address,
                                String role, String employeeId, String department) {
        super(userId, fullName, email, password, address, role);
        this.csID = csID;
        this.employeeId = employeeId;
        this.department = department;
    }

    // Getters and Setters
    public String getCsID() { return csID; }
    public void setCsID(String csID) { this.csID = csID; }

    public String getEmployeeId() { return employeeId; }
    public void setEmployeeId(String employeeId) { this.employeeId = employeeId; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    @Override
    public String toString() {
        return "CustomerServiceStaff{" +
                "csID='" + csID + '\'' +
                ", employeeId='" + employeeId + '\'' +
                ", department='" + department + '\'' +
                "} " + super.toString();
    }
}