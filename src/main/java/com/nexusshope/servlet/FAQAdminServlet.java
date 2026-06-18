// File: com/nexusshope/servlet/FAQAdminServlet.java
package com.nexusshope.servlet;

import com.nexusshope.model.FAQ;
import com.nexusshope.service.FAQService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/faq")
public class FAQAdminServlet extends HttpServlet {

    private FAQService faqService = new FAQService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAuthorizedStaff(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        // Handle null action - default to list all FAQs
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "add":
                    showAddFAQForm(request, response, false);
                    break;

                case "addProductSpecific":
                    showAddFAQForm(request, response, true);
                    break;

                case "edit":
                    showEditFAQForm(request, response);
                    break;

                case "list": // Add this case
                default:
                    listFAQs(request, response);
                    break;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                listFAQs(request, response);
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAuthorizedStaff(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        // Handle null action for POST requests too
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "create":
                    handleCreateFAQ(request, response);
                    break;

                case "update":
                    handleUpdateFAQ(request, response);
                    break;

                case "delete":
                    handleDeleteFAQ(request, response);
                    break;

                case "list": // Add this case
                default:
                    listFAQs(request, response);
                    break;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Operation failed: " + e.getMessage());
            try {
                listFAQs(request, response);
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
        }
    }

    private void showAddFAQForm(HttpServletRequest request, HttpServletResponse response, boolean isProductSpecific)
            throws ServletException, IOException, SQLException {
        List<String> categories = faqService.getAllCategories();
        request.setAttribute("categories", categories);
        request.setAttribute("isProductSpecific", isProductSpecific);
        request.getRequestDispatcher("/admin/faq-form.jsp").forward(request, response);
    }

    private void showEditFAQForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String faqID = request.getParameter("faqID");
        if (faqID == null || faqID.trim().isEmpty()) {
            request.setAttribute("error", "FAQ ID is required.");
            listFAQs(request, response);
            return;
        }

        FAQ faq = faqService.getFAQById(faqID);
        if (faq != null) {
            List<String> categories = faqService.getAllCategories();
            request.setAttribute("faq", faq);
            request.setAttribute("categories", categories);
            request.setAttribute("isProductSpecific", faq.isProductSpecific());
            request.getRequestDispatcher("/admin/faq-form.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "FAQ not found.");
            listFAQs(request, response);
        }
    }

    private void handleCreateFAQ(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        String question = request.getParameter("question");
        String answer = request.getParameter("answer");
        String category = request.getParameter("category");
        String productSpecificParam = request.getParameter("productSpecific");
        String productCategory = request.getParameter("productCategory");
        String productType = request.getParameter("productType");

        // Validate required fields
        if (question == null || question.trim().isEmpty() ||
                answer == null || answer.trim().isEmpty() ||
                category == null || category.trim().isEmpty()) {
            request.setAttribute("error", "Question, answer, and category are required.");
            showAddFAQForm(request, response, "true".equals(productSpecificParam));
            return;
        }

        boolean isProductSpecific = "true".equals(productSpecificParam);

        FAQ faq = new FAQ();
        faq.setQuestion(question.trim());
        faq.setAnswer(answer.trim());
        faq.setCategory(category.trim());
        faq.setProductSpecific(isProductSpecific);

        if (isProductSpecific) {
            if (productCategory != null && !productCategory.trim().isEmpty()) {
                faq.setProductCategory(productCategory.trim());
            }
            if (productType != null && !productType.trim().isEmpty()) {
                faq.setProductType(productType.trim());
            }
        }

        String newId = faqService.addFAQ(faq);
        if (newId != null) {
            HttpSession session = request.getSession();
            session.setAttribute("message", "FAQ added successfully! ID: " + newId);
            response.sendRedirect("faq");
        } else {
            request.setAttribute("error", "Failed to add FAQ.");
            showAddFAQForm(request, response, isProductSpecific);
        }
    }

    private void handleUpdateFAQ(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        String faqID = request.getParameter("faqID");
        String question = request.getParameter("question");
        String answer = request.getParameter("answer");
        String category = request.getParameter("category");
        String productSpecificParam = request.getParameter("productSpecific");
        String productCategory = request.getParameter("productCategory");
        String productType = request.getParameter("productType");

        // Validate required fields
        if (faqID == null || faqID.trim().isEmpty() ||
                question == null || question.trim().isEmpty() ||
                answer == null || answer.trim().isEmpty() ||
                category == null || category.trim().isEmpty()) {
            request.setAttribute("error", "FAQ ID, question, answer, and category are required.");
            listFAQs(request, response);
            return;
        }

        boolean isProductSpecific = "true".equals(productSpecificParam);

        FAQ faq = new FAQ();
        faq.setFaqID(faqID.trim());
        faq.setQuestion(question.trim());
        faq.setAnswer(answer.trim());
        faq.setCategory(category.trim());
        faq.setProductSpecific(isProductSpecific);

        if (isProductSpecific) {
            if (productCategory != null && !productCategory.trim().isEmpty()) {
                faq.setProductCategory(productCategory.trim());
            } else {
                faq.setProductCategory(null); // Clear if not provided
            }
            if (productType != null && !productType.trim().isEmpty()) {
                faq.setProductType(productType.trim());
            } else {
                faq.setProductType(null); // Clear if not provided
            }
        } else {
            // Clear product-specific fields if not product-specific
            faq.setProductCategory(null);
            faq.setProductType(null);
        }

        faqService.updateFAQ(faq);
        HttpSession session = request.getSession();
        session.setAttribute("message", "FAQ updated successfully!");
        response.sendRedirect("faq");
    }

    private void handleDeleteFAQ(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String faqID = request.getParameter("faqID");
        if (faqID == null || faqID.trim().isEmpty()) {
            request.setAttribute("error", "FAQ ID is required for deletion.");
        } else {
            faqService.deleteFAQ(faqID);
            HttpSession session = request.getSession();
            session.setAttribute("message", "FAQ deleted successfully!");
        }
        response.sendRedirect("faq");
    }

    private void listFAQs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        List<FAQ> faqs = faqService.getAllFAQs();
        request.setAttribute("faqs", faqs);
        request.getRequestDispatcher("/admin/faq-list.jsp").forward(request, response);
    }

    private boolean isAuthorizedStaff(HttpServletRequest request) {
        com.nexusshope.model.User user = (com.nexusshope.model.User) request.getSession().getAttribute("user");
        if (user == null || user.getRole() == null) {
            return false;
        }

        String role = user.getRole().toLowerCase();
        return "admin".equals(role) || "customer_service".equals(role);
    }
}
