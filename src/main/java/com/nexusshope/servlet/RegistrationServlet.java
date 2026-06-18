package com.nexusshope.servlet;

import com.nexusshope.model.*;
import com.nexusshope.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/register")
public class RegistrationServlet extends HttpServlet {

    private UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        String role = request.getParameter("role");
        String formPage = resolveFormPage(role);
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String address = request.getParameter("address");

        if (role == null || role.trim().isEmpty()) {
            request.setAttribute("error", "Please select a role.");
            request.getRequestDispatcher("/" + formPage).forward(request, response);
            return;
        }

        try {
            String result = null;

            switch (role.toLowerCase()) {
                case "admin":
                    result = registerAdmin(request, fullName, email, password, address);
                    break;

                case "customer":
                    result = registerCustomer(request, fullName, email, password, address);
                    break;

                case "product_manager":
                    result = registerProductManager(request, fullName, email, password, address);
                    break;

                case "supplier":
                    result = registerSupplier(request, fullName, email, password, address);
                    break;

                case "customer_service":
                    result = registerCustomerServiceStaff(request, fullName, email, password, address);
                    break;

                case "delivery_person":
                    result = registerDeliveryPerson(request, fullName, email, password, address);
                    break;

                default:
                    request.setAttribute("error", "Invalid role specified: " + role);
                    request.getRequestDispatcher("/" + formPage).forward(request, response);
                    return;
            }

            if (result != null) {
                response.sendRedirect(
                        request.getContextPath()
                                + "/registrationSuccess.jsp?userId="
                                + URLEncoder.encode(result, StandardCharsets.UTF_8.name())
                );
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher("/" + formPage).forward(request, response);
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/" + formPage).forward(request, response);
        } catch (ParseException e) {
            request.setAttribute("error", "Date format error: " + e.getMessage());
            request.getRequestDispatcher("/" + formPage).forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Validation error: " + e.getMessage());
            request.getRequestDispatcher("/" + formPage).forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Unexpected error: " + e.getMessage());
            request.getRequestDispatcher("/" + formPage).forward(request, response);
        }
    }

    private String registerAdmin(HttpServletRequest request, String fullName, String email,
                                 String password, String address) throws SQLException {
        String department = request.getParameter("department");
        Admin admin = new Admin();
        admin.setFullName(fullName);
        admin.setEmail(email);
        admin.setPassword(password);
        admin.setAddress(address);
        admin.setDepartment(department);
        String adminId = userService.registerAdmin(admin);
        return adminId != null ? "Admin ID: " + adminId : null;
    }

    private String registerCustomer(HttpServletRequest request, String fullName, String email,
                                    String password, String address) throws SQLException, ParseException {
        String phone = request.getParameter("phone");
        String dobStr = request.getParameter("dob");
        Date dob = new SimpleDateFormat("yyyy-MM-dd").parse(dobStr);
        Customer customer = new Customer();
        customer.setFullName(fullName);
        customer.setEmail(email);
        customer.setPassword(password);
        customer.setAddress(address);
        customer.setPhoneNumber(phone);
        customer.setDateOfBirth(new java.sql.Date(dob.getTime()));
        String customerId = userService.registerCustomer(customer);
        return customerId != null ? "Customer ID: " + customerId : null;
    }

    private String registerProductManager(HttpServletRequest request, String fullName, String email,
                                          String password, String address) throws SQLException {
        String department = getDepartmentForRole(request, "product_manager");

        if (department == null || department.isEmpty()) {
            throw new IllegalArgumentException("Department is required for Product Manager");
        }

        ProductManager pm = new ProductManager();
        pm.setFullName(fullName);
        pm.setEmail(email);
        pm.setPassword(password);
        pm.setAddress(address);
        pm.setDepartment(department);
        String pmId = userService.registerProductManager(pm);
        return pmId != null ? "Product Manager ID: " + pmId : null;
    }

    private String registerSupplier(HttpServletRequest request, String fullName, String email,
                                    String password, String address) throws SQLException {
        String companyName = request.getParameter("companyName");
        String contactPerson = request.getParameter("contactPerson");
        Supplier supplier = new Supplier();
        supplier.setFullName(fullName);
        supplier.setEmail(email);
        supplier.setPassword(password);
        supplier.setAddress(address);
        supplier.setCompanyName(companyName);
        supplier.setContactPerson(contactPerson);
        String supplierId = userService.registerSupplier(supplier);
        return supplierId != null ? "Supplier ID: " + supplierId : null;
    }

    private String registerCustomerServiceStaff(HttpServletRequest request, String fullName, String email,
                                                String password, String address) throws SQLException {
        String employeeId = request.getParameter("employeeId");
        String department = request.getParameter("department");
        CustomerServiceStaff staff = new CustomerServiceStaff();
        staff.setFullName(fullName);
        staff.setEmail(email);
        staff.setPassword(password);
        staff.setAddress(address);
        staff.setEmployeeId(employeeId);
        staff.setDepartment(department);
        String csId = userService.registerCustomerServiceStaff(staff);
        return csId != null ? "Customer Service ID: " + csId : null;
    }

    private String registerDeliveryPerson(HttpServletRequest request, String fullName, String email,
                                          String password, String address) throws SQLException {
        String vehicleType = request.getParameter("vehicleType");
        String licensePlate = request.getParameter("licensePlate");
        boolean isAvailable = "true".equals(request.getParameter("isAvailable"));
        DeliveryPerson dp = new DeliveryPerson();
        dp.setFullName(fullName);
        dp.setEmail(email);
        dp.setPassword(password);
        dp.setAddress(address);
        dp.setVehicleType(vehicleType);
        dp.setLicensePlate(licensePlate);
        dp.setAvailable(isAvailable);
        String dsId = userService.registerDeliveryPerson(dp);
        return dsId != null ? "Delivery Person ID: " + dsId : null;
    }

    private String getDepartmentForRole(HttpServletRequest request, String role) {
        String department = request.getParameter("department");

        if (department != null && !department.trim().isEmpty()) {
            return department.trim();
        }

        if ("admin".equals(role) || "product_manager".equals(role) || "customer_service".equals(role)) {
            return null;
        }

        return null;
    }

    private String resolveFormPage(String role) {
        return "customer".equalsIgnoreCase(role) ? "register.jsp" : "registration.jsp";
    }
}
