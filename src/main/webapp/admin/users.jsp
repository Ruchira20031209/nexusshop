<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    java.util.List<com.nexusshope.model.User> users =
            (java.util.List<com.nexusshope.model.User>) request.getAttribute("userList");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/admin.css">
</head>
<body>
<div class="admin-container">
    <div class="container" style="padding-top: 40px;">
        <div class="page-header">
            <h1 class="section-title"><i class="fas fa-users"></i> User Management</h1>
            <p class="section-subtitle">Review and manage registered users.</p>
        </div>

        <% if (error != null) { %>
        <div class="notification error" style="margin-bottom: 20px;">
            <span><%= error %></span>
        </div>
        <% } %>

        <div class="table-container">
            <table class="admin-table">
                <thead>
                <tr>
                    <th>User ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Address</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <% if (users != null && !users.isEmpty()) { %>
                <% for (com.nexusshope.model.User user : users) { %>
                <tr>
                    <td><%= user.getUserId() %></td>
                    <td><%= user.getFullName() %></td>
                    <td><%= user.getEmail() %></td>
                    <td><%= user.getRole() %></td>
                    <td><%= user.getAddress() == null ? "-" : user.getAddress() %></td>
                    <td>
                        <form method="post" action="../admin" onsubmit="return confirm('Delete this user?');">
                            <input type="hidden" name="action" value="deleteUser">
                            <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                            <button type="submit" class="btn btn-danger btn-sm">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </form>
                    </td>
                </tr>
                <% } %>
                <% } else { %>
                <tr>
                    <td colspan="6" style="text-align:center; padding: 24px;">No users found.</td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
