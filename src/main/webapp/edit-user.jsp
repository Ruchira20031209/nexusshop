<%--
  Created by IntelliJ IDEA.
  User: vimu
  Date: 10/19/2025
  Time: 9:00 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.nexusshope.model.User user = (com.nexusshope.model.User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect("admin");
        return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - NexusShop Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/admin.css">
    <style>
        .form-section { margin-top: 20px; }
        .form-card { background: white; border-radius: 10px; padding: 25px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        .user-header { display: flex; align-items: center; margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid #eee; }
        .user-avatar { font-size: 2.5em; color: #6c5ce7; margin-right: 15px; }
        .user-info h3 { margin: 0; color: #333; }
        .user-info p { margin: 5px 0 0; color: #666; font-size: 0.9em; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-label { display: block; margin-bottom: 6px; font-weight: 600; color: #333; }
        .form-input, .form-select { width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 1em; }
        .form-hint { font-size: 0.85em; color: #666; margin-top: 5px; }
        .form-warning { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 10px; border-radius: 6px; margin-top: 10px; display: flex; align-items: center; gap: 8px; }
        .role-descriptions { margin-top: 15px; padding: 15px; background: #f8f9fa; border-radius: 8px; display: none; }
        .role-desc { display: none; }
        .form-section-divider { margin: 30px 0 20px; padding-bottom: 15px; border-bottom: 1px solid #eee; }
        .form-section-divider h3 { margin: 0; color: #333; }
        .password-container { position: relative; }
        .password-toggle { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; color: #666; cursor: pointer; }
        .form-actions { display: flex; gap: 12px; margin-top: 25px; flex-wrap: wrap; }
        .btn { padding: 10px 20px; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; }
        .btn-primary { background: #6c5ce7; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-danger { background: #e74c3c; color: white; }
        .btn-large { padding: 12px 24px; font-size: 1.05em; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: white; margin: 10% auto; padding: 25px; width: 90%; max-width: 500px; border-radius: 10px; }
        .modal-header h3 { margin: 0; color: #e74c3c; }
        .modal-body { margin: 20px 0; }
        .modal-actions { display: flex; gap: 12px; justify-content: flex-end; }
        .notification { padding: 12px; margin-bottom: 20px; border-radius: 6px; }
        .notification.error { background: #ffebee; color: #c62828; display: flex; align-items: center; gap: 10px; }
    </style>
</head>
<body>
<!-- Floating Background Elements -->
<div class="floating-bg">
    <div class="floating-circle circle-1"></div>
    <div class="floating-circle circle-2"></div>
    <div class="floating-circle circle-3"></div>
    <div class="floating-circle circle-4"></div>
</div>

<!-- Header Section -->
<header class="header">
    <div class="header-container">
        <div class="logo">
            <a href="index.jsp">
                <span class="logo-icon"><i class="fas fa-atom"></i></span>
                <span class="logo-text">NexusShop</span>
            </a>
        </div>
        <nav class="main-nav">
            <ul class="nav-list">
                <li class="nav-item"><a href="index.jsp" class="nav-link">Home</a></li>
                <li class="nav-item"><a href="products" class="nav-link">Shop</a></li>
                <li class="nav-item"><a href="admin" class="nav-link active">Admin</a></li>
            </ul>
        </nav>
        <div class="user-actions">
            <span class="action-text">Welcome, Admin</span>
            <a href="logout" class="action-link" onclick="return confirm('Are you sure you want to logout?')">
                <i class="fas fa-sign-out-alt"></i>
                <span class="action-text">Logout</span>
            </a>
        </div>
    </div>
</header>

<!-- Edit User Content -->
<div class="admin-container">
    <div class="container">
        <div class="page-header">
            <h1 class="section-title">
                <i class="fas fa-user-edit"></i> Edit User
            </h1>
            <p class="section-subtitle">Update user information and role permissions</p>
        </div>

        <% if (error != null) { %>
        <div class="notification error">
            <i class="fas fa-exclamation-circle"></i>
            <span><%= error %></span>
        </div>
        <% } %>

        <div class="form-section">
            <div class="form-card">
                <form action="admin" method="post" class="user-form">
                    <input type="hidden" name="action" value="updateUser">
                    <input type="hidden" name="id" value="<%= user.getUserId() %>">

                    <div class="user-header">
                        <div class="user-avatar">
                            <i class="fas fa-user-circle"></i>
                        </div>
                        <div class="user-info">
                            <h3><%= user.getFullName() %></h3>
                            <p>User ID: <%= user.getUserId() %> | Role: <%= user.getRole() %></p>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="fullName" class="form-label">
                                <i class="fas fa-user"></i> Full Name *
                            </label>
                            <input type="text" id="fullName" name="fullName" required
                                   value="<%= user.getFullName() %>" class="form-input">
                            <div class="form-hint">User's complete name</div>
                        </div>

                        <div class="form-group">
                            <label for="email" class="form-label">
                                <i class="fas fa-envelope"></i> Email Address *
                            </label>
                            <input type="email" id="email" name="email" required
                                   value="<%= user.getEmail() %>" class="form-input">
                            <div class="form-hint">Unique email for login</div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="address" class="form-label">
                            <i class="fas fa-map-marker-alt"></i> Address
                        </label>
                        <input type="text" id="address" name="address"
                               value="<%= user.getAddress() != null ? user.getAddress() : "" %>"
                               class="form-input">
                        <div class="form-hint">Optional shipping/billing address</div>
                    </div>

                    <div class="form-group">
                        <label for="role" class="form-label">
                            <i class="fas fa-user-tag"></i> Role *
                        </label>
                        <select id="role" name="role" required class="form-select"
                                <%= "admin".equals(user.getRole()) ? "disabled" : "" %>>
                            <option value="customer" <%= "customer".equals(user.getRole()) ? "selected" : "" %>>Customer</option>
                            <option value="product_manager" <%= "product_manager".equals(user.getRole()) ? "selected" : "" %>>Product Manager</option>
                            <option value="supplier" <%= "supplier".equals(user.getRole()) ? "selected" : "" %>>Supplier</option>
                            <option value="customer_service" <%= "customer_service".equals(user.getRole()) ? "selected" : "" %>>Customer Service</option>
                            <option value="delivery_person" <%= "delivery_person".equals(user.getRole()) ? "selected" : "" %>>Delivery Person</option>
                            <option value="admin" <%= "admin".equals(user.getRole()) ? "selected" : "" %>>Admin</option>
                        </select>
                        <div class="form-hint">Determines user permissions and access</div>

                        <% if ("admin".equals(user.getRole())) { %>
                        <div class="form-warning">
                            <i class="fas fa-exclamation-triangle"></i>
                            <span>Admin role cannot be modified for security reasons.</span>
                        </div>
                        <% } %>
                    </div>

                    <!-- Password Update Section -->
                    <div class="form-section-divider">
                        <h3><i class="fas fa-key"></i> Password Update (Optional)</h3>
                        <p>Leave blank to keep current password</p>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label for="newPassword" class="form-label">
                                <i class="fas fa-lock"></i> New Password
                            </label>
                            <div class="password-container">
                                <input type="password" id="newPassword" name="newPassword" class="form-input">
                                <button type="button" class="password-toggle">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                            <div class="form-hint">Minimum 8 characters with letters and numbers</div>
                        </div>

                        <div class="form-group">
                            <label for="confirmPassword" class="form-label">
                                <i class="fas fa-lock"></i> Confirm Password
                            </label>
                            <div class="password-container">
                                <input type="password" id="confirmPassword" name="confirmPassword" class="form-input">
                                <button type="button" class="password-toggle">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                            <div class="form-hint">Must match new password</div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary btn-large">
                            <i class="fas fa-save"></i> Update User
                        </button>
                        <a href="admin" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </a>
                        <% if (!"admin".equals(user.getRole())) { %>
                        <button type="button" class="btn btn-danger" id="deleteBtn">
                            <i class="fas fa-trash"></i> Delete User
                        </button>
                        <% } %>
                    </div>
                </form>

                <!-- Delete Confirmation Modal -->
                <div class="modal" id="deleteModal">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h3><i class="fas fa-exclamation-triangle"></i> Confirm Deletion</h3>
                        </div>
                        <div class="modal-body">
                            <p>Are you sure you want to delete user <strong><%= user.getFullName() %></strong>?</p>
                            <p class="text-warning">This action cannot be undone. All user data will be permanently removed.</p>
                        </div>
                        <div class="modal-actions">
                            <form action="admin" method="post" style="display: inline;">
                                <input type="hidden" name="action" value="deleteUser">
                                <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                <button type="submit" class="btn btn-danger">
                                    <i class="fas fa-trash"></i> Delete Permanently
                                </button>
                            </form>
                            <button type="button" class="btn btn-secondary" id="cancelDelete">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Footer -->
<footer class="site-footer">
    <div class="footer-container">
        <div class="footer-bottom">
            <p>&copy; 2025 NexusShop. All rights reserved.</p>
        </div>
    </div>
</footer>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Password toggle
        const passwordToggles = document.querySelectorAll('.password-toggle');
        passwordToggles.forEach(toggle => {
            toggle.addEventListener('click', function() {
                const input = this.parentElement.querySelector('input');
                const type = input.type === 'password' ? 'text' : 'password';
                input.type = type;
                this.innerHTML = type === 'password' ?
                    '<i class="fas fa-eye"></i>' : '<i class="fas fa-eye-slash"></i>';
            });
        });

        // Delete modal
        const deleteBtn = document.getElementById('deleteBtn');
        const deleteModal = document.getElementById('deleteModal');
        const cancelDelete = document.getElementById('cancelDelete');

        if (deleteBtn && deleteModal) {
            deleteBtn.addEventListener('click', () => deleteModal.style.display = 'block');
            cancelDelete.addEventListener('click', () => deleteModal.style.display = 'none');
            window.addEventListener('click', (e) => {
                if (e.target === deleteModal) deleteModal.style.display = 'none';
            });
        }
    });
</script>
</body>
</html>