package com.nexusshope.model;

public class DeliveryPerson extends User {
    private String dsID;
    private String vehicleType;
    private String licensePlate;
    private boolean isAvailable;

    public DeliveryPerson() {}

    public DeliveryPerson(String dsID, String userId, String fullName, String email, String password, String address,
                          String role, String vehicleType, String licensePlate, boolean isAvailable) {
        super(userId, fullName, email, password, address, role);
        this.dsID = dsID;
        this.vehicleType = vehicleType;
        this.licensePlate = licensePlate;
        this.isAvailable = isAvailable;
    }

    // Getters and Setters
    public String getDsID() { return dsID; }
    public void setDsID(String dsID) { this.dsID = dsID; }

    public String getVehicleType() { return vehicleType; }
    public void setVehicleType(String vehicleType) { this.vehicleType = vehicleType; }

    public String getLicensePlate() { return licensePlate; }
    public void setLicensePlate(String licensePlate) { this.licensePlate = licensePlate; }

    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }

    @Override
    public String toString() {
        return "DeliveryPerson{" +
                "dsID='" + dsID + '\'' +
                ", vehicleType='" + vehicleType + '\'' +
                ", licensePlate='" + licensePlate + '\'' +
                ", isAvailable=" + isAvailable +
                "} " + super.toString();
    }
}