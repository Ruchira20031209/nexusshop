<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Product | NexusShop PM</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<h1>Edit Product: ${product.name}</h1>

<c:if test="${not empty errors}">
    <ul class="error">
        <c:forEach var="err" items="${errors}">
            <li>${err}</li>
        </c:forEach>
    </ul>
</c:if>

<form action="${pageContext.request.contextPath}/pm/edit-product" method="post" enctype="multipart/form-data">
    <input type="hidden" name="productID" value="${product.productID}">
    <div class="form-group">
        <label for="name">Name</label>
        <input type="text" id="name" name="name" value="${product.name}" required>
    </div>
    <div class="form-group">
        <label for="sku">SKU</label>
        <input type="text" id="sku" name="sku" value="${product.sku}" required>
    </div>
    <div class="form-group">
        <label for="category">Category</label>
        <input type="text" id="category" name="category" value="${product.category}" required>
    </div>
    <div class="form-group">
        <label for="price">Price</label>
        <input type="number" id="price" name="price" step="0.01" value="${product.price}" required>
    </div>
    <div class="form-group">
        <label for="stock">Stock</label>
        <input type="number" id="stock" name="stock" value="${product.stock}" required>
    </div>
    <div class="form-group">
        <label for="description">Description</label>
        <textarea id="description" name="description" required>${product.description}</textarea>
    </div>
    <div class="form-group">
        <label for="status">Status</label>
        <select id="status" name="status">
            <option value="pending" ${product.status == 'pending' ? 'selected' : ''}>Pending</option>
            <option value="approved" ${product.status == 'approved' ? 'selected' : ''}>Approved</option>
            <option value="rejected" ${product.status == 'rejected' ? 'selected' : ''}>Rejected</option>

        </select>
    </div>

    <!-- Images -->
    <div class="form-group">
        <label>Current Images</label>
        <c:forEach var="image" items="${images}">
            <div>
                <img src="${pageContext.request.contextPath}${image.imageUrl}" alt="Image" width="100">
                <input type="checkbox" name="deleteImage" value="${image.imageID}"> Delete
            </div>
        </c:forEach>
        <label>New Images</label>
        <input type="file" name="newImage1" accept="image/*">
        <input type="file" name="newImage2" accept="image/*">
        <!-- Add more if needed -->
    </div>

    <!-- Specifications -->
    <div class="form-group">
        <label>Specifications</label>
        <c:forEach var="spec" items="${specs}">
            <div>
                <input type="text" name="specKey" value="${spec.specKey}" placeholder="Key">
                <input type="text" name="specValue" value="${spec.specValue}" placeholder="Value">
            </div>
        </c:forEach>
        <!-- Add extra for new specs -->
        <div>
            <input type="text" name="specKey" placeholder="New Key">
            <input type="text" name="specValue" placeholder="New Value">
        </div>
        <!-- Repeat for a few more -->
    </div>

    <button type="submit" class="action-btn btn-approve">Update Product</button>
</form>
<a href="${pageContext.request.contextPath}/pm/dashboard">Back to Dashboard</a>
</body>
</html>