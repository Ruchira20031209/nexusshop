<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Product</title>
    <script>
        let specCount = 1;
        function addSpec() {
            specCount++;
            const div = document.createElement('div');
            div.innerHTML = `
            <label>Spec Key ${specCount}:</label>
            <input type="text" name="specKey${specCount}" required>
            <label>Spec Value ${specCount}:</label>
            <input type="text" name="specValue${specCount}" required>
            <br><br>
        `;
            document.getElementById('specs').appendChild(div);
            document.getElementById('specCount').value = specCount;
        }

        let imageCount = 1;
        function addImage() {
            imageCount++;
            const div = document.createElement('div');
            div.innerHTML = `
            <label>Image ${imageCount}:</label>
            <input type="file" name="image${imageCount}" accept="image/*">
            <br><br>
        `;
            document.getElementById('images').appendChild(div);
            document.getElementById('imageCount').value = imageCount; // Track total images
        }
    </script>
</head>
<body>
<h2>Add Product</h2>
<form action="<c:url value='/supplier/product'/>" method="post" enctype="multipart/form-data">
    <input type="hidden" name="action" value="add">
    <label>Name:</label><br>
    <input type="text" name="name" required><br><br>
    <label>SKU:</label><br>
    <input type="text" name="sku" required><br><br>
    <label>Category:</label><br>
    <input type="text" name="category" required><br><br>
    <label>Price:</label><br>
    <input type="number" name="price" required><br><br>
    <label>Stock:</label><br>
    <input type="number" name="stock" required><br><br>
    <label>Description:</label><br>
    <textarea name="description"></textarea><br><br>

    <!-- Specifications -->
    <h3>Specifications</h3>
    <div id="specs">
        <label>Spec Key 1:</label>
        <input type="text" name="specKey1" required>

        <label>Spec Value 1:</label>

        <input type="text" name="specValue1" required><br><br>
    </div>
    <button type="button" onclick="addSpec()">Add More Spec</button><br><br>
    <input type="hidden" id="specCount" name="specCount" value="1">

    <!-- Images -->
    <h3>Images</h3>
    <div id="images">
        <label>Image 1:</label>
        <input type="file" name="image1" accept="image/*" required><br><br>
    </div>
    <button type="button" onclick="addImage()">Add More Image</button><br><br>

    <input type="submit" value="Add Product">
</form>
</body>
</html>