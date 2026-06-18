package com.nexusshope.dao;

import com.nexusshope.model.*;

import java.sql.SQLException;
import java.util.List;

public interface UserDAO {

    // Generic user insert
    String insertUser(User user) throws SQLException;

    // Role-specific inserts
    String insertAdmin(Admin admin) throws SQLException;
    String insertCustomer(Customer customer) throws SQLException;
    String insertProductManager(ProductManager pm) throws SQLException;
    String insertSupplier(Supplier supplier) throws SQLException;
    String insertCustomerServiceStaff(CustomerServiceStaff staff) throws SQLException;
    String insertDeliveryPerson(DeliveryPerson dp) throws SQLException;
    List<User> getAllUsers() throws SQLException;
    void updateUserFullName(String userId, String fullName) throws SQLException;
    void updateUserPassword(String userId, String password) throws SQLException;

    // Optional: Fetch by ID or email
    User getUserByEmail(String email) throws SQLException;
    User getUserById(String userId) throws SQLException;
    void deleteUser(String userId) throws SQLException;
    void updateUser(User user) throws SQLException;

    String getSupplierSID(String userId) throws SQLException;
}