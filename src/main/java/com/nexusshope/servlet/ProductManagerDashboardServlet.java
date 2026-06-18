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

@WebServlet("/pm/dashboard")
public class ProductManagerDashboardServlet extends HttpServlet {
    private ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isProductManager(req)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // Stats
            int totalProducts = productService.getTotalProductCount();
            int pendingCount = productService.getProductCountByStatus("pending");
            int approvedCount = productService.getProductCountByStatus("approved");
            int rejectedCount = productService.getProductCountByStatus("rejected");
            int onHoldCount = productService.getProductCountByStatus("on_hold");
            int lowStockCount = productService.getLowStockCount(10);
            int outOfStockCount = productService.getOutOfStockCount();

            req.setAttribute("totalProducts", totalProducts);
            req.setAttribute("pendingCount", pendingCount);
            req.setAttribute("approvedCount", approvedCount);
            req.setAttribute("rejectedCount", rejectedCount);
            req.setAttribute("onHoldCount", onHoldCount);
            req.setAttribute("lowStockCount", lowStockCount);
            req.setAttribute("outOfStockCount", outOfStockCount);

            // Pending list
            List<Product> pendingProducts = productService.getProductsByStatus("pending");
            req.setAttribute("pendingProducts", pendingProducts);

            // All products list
            List<Product> allProducts = productService.getAllProducts();
            req.setAttribute("allProducts", allProducts);

            req.getRequestDispatcher("/pm/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.getRequestDispatcher("/pm/dashboard.jsp").forward(req, resp);
        }
    }

    public boolean isProductManager(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        return user != null && "product_manager".equalsIgnoreCase(user.getRole());
    }
}