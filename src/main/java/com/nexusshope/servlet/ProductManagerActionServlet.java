package com.nexusshope.servlet;

import com.nexusshope.service.ProductService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/pm/action")
public class ProductManagerActionServlet extends HttpServlet {
    private ProductService productService = new ProductService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!new ProductManagerDashboardServlet().isProductManager(req)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        String productID = req.getParameter("productID");
        String rejectionNotes = req.getParameter("rejectionNotes");

        try {
            boolean success = false;
            String message = "";

            if ("approve".equals(action)) {
                success = productService.updateProductStatus(productID, "approved", null);
                message = "Product approved successfully.";
            } else if ("reject".equals(action)) {
                if (rejectionNotes == null || rejectionNotes.trim().isEmpty()) {
                    req.getSession().setAttribute("error", "Rejection notes required.");
                    resp.sendRedirect(req.getContextPath() + "/pm/dashboard");
                    return;
                } else {
                    success = productService.updateProductStatus(productID, "rejected", rejectionNotes);
                    message = "Product rejected successfully.";
                }
            } else if ("hold".equals(action)) {
                // Try different status values that might be allowed
                String[] possibleStatusValues = {"onhold", "hold", "pending", "draft", "review", "suspended"};
                boolean statusUpdated = false;

                for (String statusValue : possibleStatusValues) {
                    try {
                        success = productService.updateProductStatus(productID, statusValue, null);
                        if (success) {
                            message = "Product put on hold successfully.";
                            statusUpdated = true;
                            break;
                        }
                    } catch (SQLException e) {
                        // Try next value
                        continue;
                    }
                }

                if (!statusUpdated) {
                    req.getSession().setAttribute("error", "Could not update status. Please check allowed status values.");
                    resp.sendRedirect(req.getContextPath() + "/pm/dashboard");
                    return;
                }
            }else if ("delete".equals(action)) {
                success = productService.deleteProduct(productID);
                message = "Product deleted successfully.";
            }

            if (success) {
                req.getSession().setAttribute("message", message);
            } else {
                req.getSession().setAttribute("error", "Action failed. Please try again.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.getSession().setAttribute("error", "Database error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/pm/dashboard");
    }
}