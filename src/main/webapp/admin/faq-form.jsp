<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  com.nexusshope.model.FAQ faq = (com.nexusshope.model.FAQ) request.getAttribute("faq");
  java.util.List<String> categories = (java.util.List<String>) request.getAttribute("categories");
  Boolean isProductSpecific = (Boolean) request.getAttribute("isProductSpecific");
  String error = (String) request.getAttribute("error");
  boolean isEdit = faq != null;

  if (isProductSpecific == null) isProductSpecific = false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= isEdit ? "Edit" : "Add" %> FAQ - NexusShop Admin</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/style.css">
  <link rel="stylesheet" href="../css/admin.css">
  <style>
    .form-section { margin-top: 20px; }
    .form-card { background: white; border-radius: 10px; padding: 25px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
    .form-group { margin-bottom: 20px; }
    .form-label { display: block; margin-bottom: 8px; font-weight: 600; color: #333; }
    .form-input, .form-select, .form-textarea {
      width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 1em;
    }
    .form-textarea { min-height: 120px; resize: vertical; }
    .form-actions { display: flex; gap: 12px; margin-top: 25px; }
    .btn { padding: 10px 20px; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; }
    .btn-primary { background: #6c5ce7; color: white; }
    .btn-secondary { background: #6c757d; color: white; }
    .notification.error {
      padding: 12px; margin-bottom: 20px; border-radius: 6px;
      background: #ffebee; color: #c62828;
      display: flex; align-items: center; gap: 10px;
    }
    .product-specific-fields { display: <%= isProductSpecific ? "block" : "none" %>; }
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
        <i class="fas fa-<%= isEdit ? "edit" : "plus" %>"></i> <%= isEdit ? "Edit" : "Add" %> FAQ
      </h1>
      <p class="section-subtitle"><%= isEdit ? "Update" : "Create" %> a frequently asked question</p>
    </div>

    <% if (error != null) { %>
    <div class="notification error">
      <i class="fas fa-exclamation-circle"></i>
      <span><%= error %></span>
    </div>
    <% } %>

    <div class="form-section">
      <div class="form-card">
        <form action="faq" method="post">
          <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">
          <% if (isEdit) { %>
          <input type="hidden" name="faqID" value="<%= faq.getFaqID() %>">
          <% } %>

          <div class="form-group">
            <label for="question" class="form-label">Question *</label>
            <input type="text" id="question" name="question" required
                   value="<%= isEdit ? faq.getQuestion() : "" %>"
                   class="form-input" placeholder="Enter the question">
          </div>

          <div class="form-group">
            <label for="answer" class="form-label">Answer *</label>
            <textarea id="answer" name="answer" required
                      class="form-textarea" placeholder="Enter the detailed answer"><%= isEdit ? faq.getAnswer() : "" %></textarea>
          </div>

          <div class="form-group">
            <label for="category" class="form-label">Category *</label>
            <select id="category" name="category" required class="form-select">
              <% for (String category : categories) { %>
              <option value="<%= category %>"
                      <%= isEdit && category.equals(faq.getCategory()) ? "selected" : "" %>>
                <%= category.replace("_", " ") %>
              </option>
              <% } %>
            </select>
          </div>

          <!-- Product-Specific Fields -->
          <div class="form-group">
            <label class="form-label">
              <input type="checkbox" id="productSpecific" name="productSpecific" value="true"
                <%= isProductSpecific || (isEdit && faq.isProductSpecific()) ? "checked" : "" %>
                     onchange="toggleProductFields(this.checked)">
              Product-Specific FAQ?
            </label>
          </div>

          <div id="productFields" class="product-specific-fields">
            <div class="form-group">
              <label for="productCategory" class="form-label">Product Category</label>
              <select id="productCategory" name="productCategory" class="form-select">
                <option value="">Select Product Category</option>
                <option value="Mobile Phones" <%= isEdit && "Mobile Phones".equals(faq.getProductCategory()) ? "selected" : "" %>>Mobile Phones</option>
                <option value="Laptops" <%= isEdit && "Laptops".equals(faq.getProductCategory()) ? "selected" : "" %>>Laptops</option>
                <option value="Audio" <%= isEdit && "Audio".equals(faq.getProductCategory()) ? "selected" : "" %>>Audio</option>
                <option value="Accessories" <%= isEdit && "Accessories".equals(faq.getProductCategory()) ? "selected" : "" %>>Accessories</option>
                <option value="Gaming" <%= isEdit && "Gaming".equals(faq.getProductCategory()) ? "selected" : "" %>>Gaming</option>
                <option value="Tablets" <%= isEdit && "Tablets".equals(faq.getProductCategory()) ? "selected" : "" %>>Tablets</option>
                <option value="TVs" <%= isEdit && "TVs".equals(faq.getProductCategory()) ? "selected" : "" %>>TVs</option>
              </select>
            </div>

            <div class="form-group">
              <label for="productType" class="form-label">Specific Product Type</label>
              <input type="text" id="productType" name="productType"
                     value="<%= isEdit ? faq.getProductType() : "" %>"
                     class="form-input" placeholder="e.g., iPhone 15, MacBook Pro">
            </div>
          </div>

          <div class="form-actions">
            <button type="submit" class="btn btn-primary">
              <i class="fas fa-save"></i> <%= isEdit ? "Update" : "Add" %> FAQ
            </button>
            <a href="faq" class="btn btn-secondary">
              <i class="fas fa-arrow-left"></i> Back to List
            </a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<footer class="site-footer">
  <div class="footer-bottom">
    <p>&copy; 2025 NexusShop. All rights reserved.</p>
  </div>
</footer>

<script>
  function toggleProductFields(isChecked) {
    document.getElementById('productFields').style.display = isChecked ? 'block' : 'none';
  }
</script>
</body>
</html>