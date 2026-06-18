package com.nexusshope.service;

import com.nexusshope.dao.UserDAO;
import com.nexusshope.dao.UserDAOImpl;
import com.nexusshope.model.Admin;
import com.nexusshope.model.Customer;
import com.nexusshope.model.CustomerServiceStaff;
import com.nexusshope.model.DeliveryPerson;
import com.nexusshope.model.ProductManager;
import com.nexusshope.model.Supplier;
import com.nexusshope.model.User;

import java.sql.SQLException;
import java.util.List;
import java.util.Objects;

public class UserService {
    private final UserDAO userDAO;

    private static final int MIN_PASSWORD_LENGTH = 8;
    private static final int MAX_PASSWORD_LENGTH = 128;

    public UserService() {
        this(new UserDAOImpl());
    }

    public UserService(UserDAO userDAO) {
        this.userDAO = Objects.requireNonNull(userDAO, "userDAO");
    }

    public String registerAdmin(Admin admin) throws SQLException {
        validateEmail(admin.getEmail());
        return userDAO.insertAdmin(admin);
    }

    public String registerCustomer(Customer customer) throws SQLException {
        validateEmail(customer.getEmail());
        validateCustomer(customer);
        return userDAO.insertCustomer(customer);
    }

    public String registerProductManager(ProductManager pm) throws SQLException {
        validateEmail(pm.getEmail());
        return userDAO.insertProductManager(pm);
    }

    public String registerSupplier(Supplier supplier) throws SQLException {
        validateEmail(supplier.getEmail());
        return userDAO.insertSupplier(supplier);
    }

    public String registerCustomerServiceStaff(CustomerServiceStaff staff) throws SQLException {
        validateEmail(staff.getEmail());
        return userDAO.insertCustomerServiceStaff(staff);
    }

    public String registerDeliveryPerson(DeliveryPerson dp) throws SQLException {
        validateEmail(dp.getEmail());
        return userDAO.insertDeliveryPerson(dp);
    }

    public User getUserByEmail(String email) throws SQLException {
        return userDAO.getUserByEmail(email);
    }

    private void validateEmail(String email) throws SQLException {
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email format");
        }

        User existingUser = userDAO.getUserByEmail(email);
        if (existingUser != null) {
            throw new IllegalArgumentException("Email already exists");
        }
    }

    private void validateCustomer(Customer customer) throws SQLException {
        if (customer.getPhoneNumber() == null || customer.getPhoneNumber().length() < 10) {
            throw new IllegalArgumentException("Invalid phone number");
        }
    }

    public List<User> getAllUsers() throws SQLException {
        return userDAO.getAllUsers();
    }

    public void updateUserFullName(String userId, String fullName) throws SQLException {
        userDAO.updateUserFullName(userId, fullName);
    }

    public void updateUserPassword(String userId, String password) throws SQLException {
        userDAO.updateUserPassword(userId, password);
    }

    public User getUserById(String userId) throws SQLException {
        return userDAO.getUserById(userId);
    }

    public String getSupplierSID(String userId) throws SQLException {
        return userDAO.getSupplierSID(userId);
    }

    public void deleteUser(String userId) throws SQLException {
        userDAO.deleteUser(userId);
    }

    public void updateUser(User user) throws SQLException {
        userDAO.updateUser(user);
    }

    public String checkPasswordStrength(String password) {
        if (password == null) {
            return "Very Weak";
        }

        int strength = 0;
        if (password.length() >= 8) {
            strength++;
        }
        if (password.length() >= 12) {
            strength++;
        }
        if (password.matches(".*[a-z].*")) {
            strength++;
        }
        if (password.matches(".*[A-Z].*")) {
            strength++;
        }
        if (password.matches(".*[0-9].*")) {
            strength++;
        }
        if (password.matches(".*[@#$%^&+=!].*")) {
            strength++;
        }

        switch (strength) {
            case 0:
            case 1:
            case 2:
                return "Very Weak";
            case 3:
                return "Weak";
            case 4:
                return "Medium";
            case 5:
                return "Strong";
            case 6:
                return "Very Strong";
            default:
                return "Very Weak";
        }
    }

    private void validatePassword(String password) {
        if (password == null) {
            throw new IllegalArgumentException("Password cannot be null");
        }
        if (password.length() < MIN_PASSWORD_LENGTH) {
            throw new IllegalArgumentException(
                    String.format("Password must be at least %d characters long", MIN_PASSWORD_LENGTH)
            );
        }
        if (password.length() > MAX_PASSWORD_LENGTH) {
            throw new IllegalArgumentException(
                    String.format("Password cannot exceed %d characters", MAX_PASSWORD_LENGTH)
            );
        }
        if (password.contains(" ")) {
            throw new IllegalArgumentException("Password cannot contain spaces");
        }
    }
}
