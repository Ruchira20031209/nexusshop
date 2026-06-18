package com.nexusshope.servlet;

import com.nexusshope.model.Product;
import com.nexusshope.model.User;
import com.nexusshope.service.ProductService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/supplier") // ✅ Keep this as /supplier for dashboard
public class SupplierDashboardServlet extends HttpServlet {
    private ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null || !"supplier".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String supplierId = user.getUserId();
        try {
            List<Product> allProducts = productService.getProductsBySupplier(supplierId);
            List<Product> lowStock = productService.getLowStockCount(10) > 0 ?
                    productService.getProductsBySupplier(supplierId).stream()
                            .filter(p -> p.getStock() <= 10 && p.getStock() > 0)
                            .collect(java.util.stream.Collectors.toList()) : java.util.Collections.emptyList();
            List<Product> outOfStock = productService.getOutOfStockCount() > 0 ?
                    productService.getProductsBySupplier(supplierId).stream()
                            .filter(p -> p.getStock() == 0)
                            .collect(java.util.stream.Collectors.toList()) : java.util.Collections.emptyList();

            req.setAttribute("allProducts", allProducts);
            req.setAttribute("lowStockProducts", lowStock);
            req.setAttribute("outOfStockProducts", outOfStock);

            req.getRequestDispatcher("/supplier/supplier-dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.getRequestDispatcher("/supplier/supplier-dashboard.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null || !"supplier".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            String productId = req.getParameter("productId");
            int newStock = Integer.parseInt(req.getParameter("stock"));

            if (newStock < 0) {
                req.setAttribute("error", "Stock cannot be negative.");
                doGet(req, resp);
                return;
            }

            Product product = productService.getProductById(productId);
            if (product != null && product.getSupplierId().equals(user.getUserId()) && "approved".equalsIgnoreCase(product.getStatus())) {
                product.setStock(newStock);
                if (productService.updateProduct(product)) {
                    req.getSession().setAttribute("message", "Stock updated successfully.");
                } else {
                    req.setAttribute("error", "Failed to update stock.");
                }
            } else {
                req.setAttribute("error", "Product not found, not owned by you, or not approved.");
            }
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid input.");
        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }

        doGet(req, resp);
    }
}
