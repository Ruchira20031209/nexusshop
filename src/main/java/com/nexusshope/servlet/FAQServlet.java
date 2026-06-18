// File: com/nexusshope/servlet/FAQServlet.java
package com.nexusshope.servlet;

import com.nexusshope.model.FAQ;
import com.nexusshope.service.FAQService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/faq")
public class FAQServlet extends HttpServlet {

    private FAQService faqService = new FAQService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String categoryParam = request.getParameter("category");
            String search = request.getParameter("search");

            // Create effectively final variable for lambda
            final String category = (categoryParam == null || categoryParam.trim().isEmpty())
                    ? "general"
                    : categoryParam.trim();

            List<FAQ> allFAQs = faqService.getAllFAQs();
            List<String> categories = faqService.getAllCategories();

            // Now this works! ✅
            List<FAQ> filteredFAQs = allFAQs.stream()
                    .filter(faq -> faq.getCategory().equals(category))
                    .collect(Collectors.toList());

            // Filter by search term if provided
            if (search != null && !search.trim().isEmpty()) {
                final String searchTerm = search.trim().toLowerCase(); // Also make this final
                filteredFAQs = filteredFAQs.stream()
                        .filter(faq -> faq.getQuestion().toLowerCase().contains(searchTerm) ||
                                faq.getAnswer().toLowerCase().contains(searchTerm))
                        .collect(Collectors.toList());
            }

            request.setAttribute("faqs", filteredFAQs);
            request.setAttribute("categories", categories);
            request.setAttribute("selectedCategory", category);
            request.setAttribute("searchKeyword", search);

            request.getRequestDispatcher("/faq.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load FAQs. Please try again later.");
            request.getRequestDispatcher("/faq.jsp").forward(request, response);
        }
    }
}