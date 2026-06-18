<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  java.util.List<com.nexusshope.model.FAQ> faqs =
          (java.util.List<com.nexusshope.model.FAQ>) request.getAttribute("faqs");
  String message = (String) session.getAttribute("message");
  String error = (String) request.getAttribute("error");
  if (message != null) {
    session.removeAttribute("message");
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FAQ Management - NexusShop Admin</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/style.css">
  <link rel="stylesheet" href="../css/admin.css">
  <style>
    .category-badge {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 12px;
      font-size: 0.85em;
      font-weight: 500;
      text-transform: capitalize;
    }
    .category-general { background: #e3f2fd; color: #1976d2; }
    .category-shipping { background: #fff3e0; color: #f57c00; }
    .category-returns { background: #f1f8e9; color: #388e3c; }
    .category-account { background: #f3e5f5; color: #7b1fa2; }
    .notification {
      padding: 12px;
      margin-bottom: 20px;
      border-radius: 6px;
    }
    .notification.success { background: #e8f5e8; color: #2e7d32; }
    .notification.error { background: #ffebee; color: #c62828; }
    .product-tag { background: #f8f9fa; color: #495057; padding: 2px 6px; border-radius: 4px; font-size: 0.8em; }
  </style>
</head>
<body>
<!-- Header -->
<header class="header">
  <div class="header-container">
    <div class="logo">
      <a href="../index.jsp">
        <span class="logo-icon"><i class="fas fa-atom"></i></span>
        <span class="logo-text">NexusShop</span>
      </a>
    </div>
    <div class="user-actions">
      <span class="action-text">Welcome, Admin</span>
      <a href="../logout" class="action-link" onclick="return confirm('Are you sure you want to logout?')">
        <i class="fas fa-sign-out-alt"></i>
        <span class="action-text">Logout</span>
      </a>
    </div>
  </div>
</header>

<div class="admin-container">
  <div class="container">
    <div class="page-header">
      <h1 class="section-title">
        <i class="fas fa-question-circle"></i> FAQ Management
      </h1>
      <p class="section-subtitle">Manage frequently asked questions</p>
    </div>

    <% if (message != null) { %>
    <div class="notification success">
      <i class="fas fa-check-circle"></i>
      <span><%= message %></span>
    </div>
    <% } %>
    <% if (error != null) { %>
    <div class="notification error">
      <i class="fas fa-exclamation-circle"></i>
      <span><%= error %></span>
    </div>
    <% } %>

    <div class="admin-section">
      <div class="section-header">
        <h2>FAQ List</h2>
        <div class="section-actions">
          <a href="faq?action=addProductSpecific" class="btn btn-primary">
            <i class="fas fa-plus"></i> Add Product-Specific FAQ
          </a>
        </div>
      </div>

      <div class="table-container">
        <table class="admin-table">
          <thead>
          <tr>
            <th>ID</th>
            <th>Question</th>
            <th>Category</th>
            <th>Product Type</th>
            <th>Type</th>
            <th>Actions</th>
          </tr>
          </thead>
          <tbody>
          <% if (faqs != null && !faqs.isEmpty()) {
            for (com.nexusshope.model.FAQ faq : faqs) { %>
          <tr>
            <td><%= faq.getFaqID() %></td>
            <td><%= faq.getQuestion() %></td>
            <td>
                                <span class="category-badge category-<%= faq.getCategory() %>">
                                    <%= faq.getCategory() %>
                                </span>
            </td>
            <td>
              <% if (faq.isProductSpecific()) { %>
              <span class="product-tag"><%= faq.getProductCategory() %> - <%= faq.getProductType() %></span>
              <% } else { %>
              <span class="product-tag">General</span>
              <% } %>
            </td>
            <td>
                                <span class="category-badge <%= faq.isProductSpecific() ? "category-shipping" : "category-general" %>">
                                    <%= faq.isProductSpecific() ? "Product-Specific" : "General" %>
                                </span>
            </td>
            <td>
              <a href="faq?action=edit&faqID=<%= faq.getFaqID() %>" class="btn btn-warning btn-sm">
                <i class="fas fa-edit"></i> Edit
              </a>
              <form method="post" style="display:inline;"
                    onsubmit="return confirm('Delete this FAQ?');">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="faqID" value="<%= faq.getFaqID() %>">
                <button type="submit" class="btn btn-danger btn-sm">
                  <i class="fas fa-trash"></i> Delete
                </button>
              </form>
            </td>
          </tr>
          <% }
          } else { %>
          <tr>
            <td colspan="6" style="text-align: center; padding: 20px;">
              No FAQs found. <a href="faq?action=add">Add your first FAQ</a>.
            </td>
          </tr>
          <% } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<footer class="site-footer">
  <div class="footer-bottom">
    <p>&copy; 2025 NexusShop. All rights reserved.</p>
  </div>
</footer>
</body>
</html>