<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supplier Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body style="font-family: 'Poppins', Arial, sans-serif; background: linear-gradient(135deg,#f5f7fa,#e4e8f0); margin:0;">

<div style="width:100%; background:rgba(255,255,255,0.85); box-shadow:0 2px 8px rgba(108,92,231,.08); padding:1rem 0 1rem 0;">
    <div style="max-width:1080px; margin:0 auto; display:flex; align-items:center; justify-content:space-between; padding:0 1rem;">
        <div style="font-size:1.6rem; font-weight:700; color:#6c5ce7;">
            <span style="margin-right:10px;"><i class="fas fa-store"></i></span>
            Supplier Dashboard
        </div>
        <div>
            <a href="index.jsp" style="font-size:1.1rem; color:#5649c0; font-weight:600; text-decoration:none; margin-right:20px;">Home</a>
        </div>
    </div>
</div>

<div style="max-width:900px; margin:3rem auto 3rem auto; background:#fff; border-radius:12px; box-shadow:0 4px 20px rgba(108,92,231,.07); padding:2rem;">
    <h2 style="font-size:2rem; font-weight:600; margin-bottom:0.5em; color:#6c5ce7; text-align:center;">Supplier Dashboard</h2>

    <!-- Summary Cards -->
    <div style="display:flex; gap:20px; justify-content:center; margin-bottom:2rem;">
        <div style="background:#f5f6fa; padding:1em 2em; border-radius:12px; color:#2d3436; font-weight:500; box-shadow:0 1px 6px rgba(108,92,231,.08)">
            Products<br>
            <span style="font-size:1.3em;">
                    <c:set var="totalCount" value="0"/>
                    <c:forEach items="${products}" var="p"><c:set var="totalCount" value="${totalCount + 1}"/></c:forEach>
                    ${totalCount}
                </span>
        </div>
        <div style="background:#eaffe4; padding:1em 2em; border-radius:12px; color:#00b894; font-weight:500; box-shadow:0 1px 6px rgba(108,92,231,.08)">
            Approved<br>
            <span style="font-size:1.3em;">
                    <c:set var="approvedCount" value="0"/>
                    <c:forEach items="${products}" var="p"><c:if test="${p.status eq 'approved' || p.status eq 'active'}"><c:set var="approvedCount" value="${approvedCount + 1}"/></c:if></c:forEach>
                    ${approvedCount}
                </span>
        </div>
        <div style="background:#fff6e4; padding:1em 2em; border-radius:12px; color:#fdcb6e; font-weight:500; box-shadow:0 1px 6px rgba(108,92,231,.08)">
            Pending<br>
            <span style="font-size:1.3em;">
                    <c:set var="pendingCount" value="0"/>
                    <c:forEach items="${products}" var="p"><c:if test="${p.status eq 'pending'}"><c:set var="pendingCount" value="${pendingCount + 1}"/></c:if></c:forEach>
                    ${pendingCount}
                </span>
        </div>
    </div>

    <div style="text-align:right; margin-bottom:1em;">
        <a href="add-product.jsp" style="background:#6c5ce7; color:#fff; padding:0.7em 2em; border-radius:6px; font-weight:600; font-size:1.1em; text-decoration:none; box-shadow:0 2px 6px rgba(108,92,231,.08);">
            + Add New Product
        </a>
    </div>

    <!-- Approved Products Table -->
    <h3 style="color:#00b894; margin-bottom:0.5em;">Approved Products</h3>
    <table style="width:100%; border-collapse:collapse; margin-bottom:2em;">
        <thead>
        <tr style="background:#f5f6fa; color:#6c5ce7;">
            <th style="padding:10px;">ID</th>
            <th style="padding:10px;">Name</th>
            <th style="padding:10px;">Price</th>
            <th style="padding:10px;">Stock</th>
            <th style="padding:10px;">Status</th>
            <th style="padding:10px;">Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${products}" var="product">
            <c:if test="${product.status eq 'approved' || product.status eq 'active'}">
                <tr style="background:#f6fcf8;">
                    <td style="padding:8px;">${product.productID}</td>
                    <td style="padding:8px;">${product.name}</td>
                    <td style="padding:8px;">${product.price}</td>
                    <td style="padding:8px;">${product.stock}</td>
                    <td style="padding:8px;"><span style="background:#00b894; color:white; padding:4px 12px; border-radius:8px;">${product.status}</span></td>
                    <td style="padding:8px;">
                        <a href="edit-product.jsp?id=${product.productID}" style="color:#fdcb6e; padding:4px 10px; font-weight:600; text-decoration:none;">Edit</a>
                        <form action="product" method="post" style="display:inline;">
                            <input type="hidden" name="productID" value="${product.productID}" />
                            <input type="hidden" name="action" value="delete" />
                            <button type="submit" style="color:#fff; background:#d63031; border:none; padding:4px 10px; border-radius:6px; font-weight:600; cursor:pointer;">
                                Delete
                            </button>
                        </form>
                    </td>
                </tr>
            </c:if>
        </c:forEach>
        </tbody>
    </table>

    <!-- Pending Products Table -->
    <h3 style="color:#fdcb6e; margin-bottom:0.5em;">Pending Products</h3>
    <table style="width:100%; border-collapse:collapse;">
        <thead>
        <tr style="background:#f5f6fa; color:#fdcb6e;">
            <th style="padding:10px;">ID</th>
            <th style="padding:10px;">Name</th>
            <th style="padding:10px;">Price</th>
            <th style="padding:10px;">Stock</th>
            <th style="padding:10px;">Status</th>
            <th style="padding:10px;">Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${products}" var="product">
            <c:if test="${product.status eq 'pending'}">
                <tr style="background:#fffaf6;">
                    <td style="padding:8px;">${product.productID}</td>
                    <td style="padding:8px;">${product.name}</td>
                    <td style="padding:8px;">${product.price}</td>
                    <td style="padding:8px;">${product.stock}</td>
                    <td style="padding:8px;"><span style="background:#fdcb6e; color:white; padding:4px 12px; border-radius:8px;">${product.status}</span></td>
                    <td style="padding:8px;">
                        <a href="edit-product.jsp?id=${product.productID}" style="color:#fdcb6e; padding:4px 10px; font-weight:600; text-decoration:none;">Edit</a>
                        <form action="product" method="post" style="display:inline;">
                            <input type="hidden" name="productID" value="${product.productID}" />
                            <input type="hidden" name="action" value="delete" />
                            <button type="submit" style="color:#fff; background:#d63031; border:none; padding:4px 10px; border-radius:6px; font-weight:600; cursor:pointer;">
                                Delete
                            </button>
                        </form>
                    </td>
                </tr>
            </c:if>
        </c:forEach>
        </tbody>
    </table>

    <!-- Success/Error Messages -->
    <div style="margin-top:2em;">
        <% if (request.getAttribute("message") != null) { %>
        <div style="background:#eaffe4; color:#00b894; border-radius:6px; padding:12px 24px; margin-bottom:.5em;">
            <%= request.getAttribute("message") %>
        </div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
        <div style="background:#ffebe4; color:#d63031; border-radius:6px; padding:12px 24px; margin-bottom:.5em;">
            <%= request.getAttribute("error") %>
        </div>
        <% } %>
    </div>
</div>
</body>
</html>