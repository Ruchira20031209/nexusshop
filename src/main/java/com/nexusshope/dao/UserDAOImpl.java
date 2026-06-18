package com.nexusshope.dao;

import com.nexusshope.model.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAOImpl extends AbstractDAO implements UserDAO {

    @Override
    public String insertUser(User user) throws SQLException {
        String sql = "INSERT INTO users (user_id, full_name, email, password, address, role) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUserId());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPassword());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getRole());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                return user.getUserId();
            }
            return null;
        }
    }

    @Override
    public String insertAdmin(Admin admin) throws SQLException {
        String userId = getNextUserId();
        admin.setUserId(userId);
        admin.setRole("admin");

        // Insert into users table
        insertUser(admin);

        String adminID = getNextAdminID();

        String sql = "INSERT INTO admins (adminID, user_id, registered_date, department) VALUES (?, ?, ?, ?)";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, adminID);
            ps.setString(2, userId);
            ps.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            ps.setString(4, admin.getDepartment());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                return adminID;
            }
            return null;
        }
    }

    @Override
    public String insertCustomer(Customer customer) throws SQLException {
        String userId = getNextUserId();
        customer.setUserId(userId);
        customer.setRole("customer");

        insertUser(customer);

        String customerID = getNextCustomerID();

        String sql = "INSERT INTO customers (customerID, user_id, phone_number, date_of_birth) VALUES (?, ?, ?, ?)";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, customerID);
            ps.setString(2, userId);
            ps.setString(3, customer.getPhoneNumber());
            ps.setDate(4, customer.getDateOfBirth());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                return customerID;
            }
            return null;
        }
    }

    @Override
    public String insertProductManager(ProductManager pm) throws SQLException {
        String userId = getNextUserId();
        pm.setUserId(userId);
        pm.setRole("product_manager");

        insertUser(pm);

        String pmID = getNextPMID();

        String sql = "INSERT INTO product_managers (pmID, user_id, department) VALUES (?, ?, ?)";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, pmID);
            ps.setString(2, userId);
            ps.setString(3, pm.getDepartment());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                return pmID;
            }
            return null;
        }
    }

    @Override
    public String insertSupplier(Supplier supplier) throws SQLException {
        String userId = getNextUserId();
        supplier.setUserId(userId);
        supplier.setRole("supplier");

        insertUser(supplier);

        String sID = getNextSupplierID();

        String sql = "INSERT INTO suppliers (sID, user_id, company_name, contact_person) VALUES (?, ?, ?, ?)";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, sID);
            ps.setString(2, userId);
            ps.setString(3, supplier.getCompanyName());
            ps.setString(4, supplier.getContactPerson());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                return sID;
            }
            return null;
        }
    }

    @Override
    public String insertCustomerServiceStaff(CustomerServiceStaff staff) throws SQLException {
        String userId = getNextUserId();
        staff.setUserId(userId);
        staff.setRole("customer_service");

        insertUser(staff);

        String csID = getNextCSID();

        String sql = "INSERT INTO customer_service_staff (csID, user_id, employee_id, department) VALUES (?, ?, ?, ?)";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, csID);
            ps.setString(2, userId);
            ps.setString(3, staff.getEmployeeId());
            ps.setString(4, staff.getDepartment());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                return csID;
            }
            return null;
        }
    }

    @Override
    public String insertDeliveryPerson(DeliveryPerson dp) throws SQLException {
        String userId = getNextUserId();
        dp.setUserId(userId);
        dp.setRole("delivery_person");

        insertUser(dp);

        String dsID = getNextDSID();

        String sql = "INSERT INTO delivery_persons (dsID, user_id, vehicle_type, license_plate, is_available) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, dsID);
            ps.setString(2, userId);
            ps.setString(3, dp.getVehicleType());
            ps.setString(4, dp.getLicensePlate());
            ps.setBoolean(5, dp.isAvailable());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                return dsID;
            }
            return null;
        }
    }

    @Override
    public String getSupplierSID(String userId) throws SQLException {
        String sql = "SELECT sID FROM suppliers WHERE user_id = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("sID");
                }
            }
        }
        return null;
    }

    // Helper methods to generate next IDs (improved version)
    private String getNextUserId() throws SQLException {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(user_id, 2, LEN(user_id)-1) AS INT)), 0) + 1 FROM users";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int nextId = rs.getInt(1);
                return "U" + String.format("%03d", nextId);
            }
        }
        return "U001";
    }

    private String getNextAdminID() throws SQLException {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(adminID, 3, LEN(adminID)-2) AS INT)), 0) + 1 FROM admins";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int nextId = rs.getInt(1);
                return "AD" + String.format("%03d", nextId);
            }
        }
        return "AD001";
    }

    private String getNextCustomerID() throws SQLException {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(customerID, 2, LEN(customerID)-1) AS INT)), 0) + 1 FROM customers";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int nextId = rs.getInt(1);
                return "C" + String.format("%03d", nextId);
            }
        }
        return "C001";
    }

    private String getNextPMID() throws SQLException {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(pmID, 3, LEN(pmID)-2) AS INT)), 0) + 1 FROM product_managers";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int nextId = rs.getInt(1);
                return "PM" + String.format("%03d", nextId);
            }
        }
        return "PM001";
    }

    private String getNextSupplierID() throws SQLException {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(sID, 3, LEN(sID)-2) AS INT)), 0) + 1 FROM suppliers";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int nextId = rs.getInt(1);
                return "SU" + String.format("%03d", nextId);
            }
        }
        return "SU001";
    }

    private String getNextCSID() throws SQLException {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(csID, 3, LEN(csID)-2) AS INT)), 0) + 1 FROM customer_service_staff";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int nextId = rs.getInt(1);
                return "CS" + String.format("%03d", nextId);
            }
        }
        return "CS001";
    }

    private String getNextDSID() throws SQLException {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(dsID, 3, LEN(dsID)-2) AS INT)), 0) + 1 FROM delivery_persons";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int nextId = rs.getInt(1);
                return "DS" + String.format("%03d", nextId);
            }
        }
        return "DS001";
    }

    @Override
    public User getUserByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getString("user_id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setAddress(rs.getString("address"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        }
        return null;
    }

    @Override
    public List<User> getAllUsers() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT user_id, full_name, email, role, address FROM users ORDER BY user_id";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getString("user_id"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setAddress(rs.getString("address"));
                users.add(user);
            }
        }
        return users;
    }

    @Override
    public void updateUserFullName(String userId, String fullName) throws SQLException {
        String sql = "UPDATE users SET full_name = ? WHERE user_id = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, userId);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateUserPassword(String userId, String password) throws SQLException {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, password); // ⚠️ In production, hash this!
            ps.setString(2, userId);
            ps.executeUpdate();
        }
    }

    @Override
    public User getUserById(String userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getString("user_id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setAddress(rs.getString("address"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        }
        return null;
    }

    @Override
    public void deleteUser(String userId) throws SQLException {
        // Due to ON DELETE CASCADE, this will auto-delete from role tables
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateUser(User user) throws SQLException {
        String sql = "UPDATE users SET full_name = ?, email = ?, address = ?, role = ? WHERE user_id = ?";
        try (Connection conn = openConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getAddress());
            ps.setString(4, user.getRole());
            ps.setString(5, user.getUserId());
            ps.executeUpdate();
        }
    }
}
