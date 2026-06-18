<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Order Confirmation - NexusHope</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .confirmation-container { max-width: 800px; margin: 0 auto; }
        .success-icon { font-size: 4rem; color: #28a745; }
    </style>
</head>
<body>


<div class="container confirmation-container mt-4">
    <c:if test="${not empty order}">
        <div class="text-center mb-4">
            <div class="success-icon">✓</div>
            <h2 class="text-success">Order Confirmed!</h2>
            <p class="lead">Thank you for your purchase. Your order has been successfully placed.</p>
        </div>

        <div class="card">
            <div class="card-header">
                <h5>Order Details</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <p><strong>Order ID:</strong> ${order.orderID}</p>
                        <p><strong>Order Date:</strong> ${order.orderDate}</p>
                        <p><strong>Status:</strong> <span class="badge bg-success">${order.status}</span></p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Total Amount:</strong> $${order.finalAmount}</p>
                        <p><strong>Payment Status:</strong> <span class="badge bg-success">${order.paymentStatus}</span></p>
                        <p><strong>Transaction ID:</strong> ${order.transactionID}</p>
                    </div>
                </div>

                <hr>
                <h6>Shipping Address</h6>
                <p>${order.shippingAddress}</p>

                <div class="mt-4">
                    <a href="${pageContext.request.contextPath}/order/detail?id=${order.orderID}"
                       class="btn btn-primary">View Order Details</a>
                    <a href="${pageContext.request.contextPath}/orders"
                       class="btn btn-outline-secondary">View All Orders</a>
                    <a href="${pageContext.request.contextPath}/products"
                       class="btn btn-outline-primary">Continue Shopping</a>
                </div>
            </div>
        </div>
    </c:if>

    <c:if test="${empty order}">
        <div class="alert alert-warning text-center">
            <h4>No Order Found</h4>
            <p>Unable to find order confirmation details.</p>
            <a href="${pageContext.request.contextPath}/orders" class="btn btn-primary">View Your Orders</a>
        </div>
    </c:if>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>