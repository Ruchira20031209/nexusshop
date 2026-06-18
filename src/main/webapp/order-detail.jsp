<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Order Details - NexusHope</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<div class="container mt-4">
    <c:if test="${not empty order}">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Order Details: ${order.orderID}</h2>
            <a href="${pageContext.request.contextPath}/orders" class="btn btn-outline-secondary">Back to Orders</a>
        </div>

        <!-- Order Summary -->
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Order Information</h5>
                    </div>
                    <div class="card-body">
                        <p><strong>Order Date:</strong> ${order.orderDate}</p>
                        <p><strong>Status:</strong>
                            <span class="badge
                                    <c:choose>
                                        <c:when test="${order.status == 'DELIVERED'}">bg-success</c:when>
                                        <c:when test="${order.status == 'CANCELLED'}">bg-danger</c:when>
                                        <c:when test="${order.status == 'PROCESSING'}">bg-warning</c:when>
                                        <c:otherwise>bg-primary</c:otherwise>
                                    </c:choose>">
                                    ${order.status}
                            </span>
                        </p>
                        <p><strong>Payment Status:</strong>
                            <span class="badge
                                    <c:choose>
                                        <c:when test="${order.paymentStatus == 'PAID'}">bg-success</c:when>
                                        <c:when test="${order.paymentStatus == 'FAILED'}">bg-danger</c:when>
                                        <c:otherwise>bg-warning</c:otherwise>
                                    </c:choose>">
                                    ${order.paymentStatus}
                            </span>
                        </p>
                        <p><strong>Transaction ID:</strong> ${order.transactionID}</p>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Amount Details</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <span>Subtotal:</span>
                            <span>$${order.totalAmount}</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span>Tax:</span>
                            <span>$${order.taxAmount}</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span>Shipping:</span>
                            <span>$${order.shippingAmount}</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span>Discount:</span>
                            <span>$${order.discountAmount}</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between fw-bold">
                            <span>Total:</span>
                            <span>$${order.finalAmount}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Shipping Information -->
        <div class="card mb-4">
            <div class="card-header">
                <h5>Shipping Information</h5>
            </div>
            <div class="card-body">
                <p><strong>Shipping Address:</strong> ${order.shippingAddress}</p>
                <p><strong>Billing Address:</strong> ${order.billingAddress}</p>
                <p><strong>Payment Method:</strong> ${order.paymentMethod}</p>
            </div>
        </div>

        <!-- Order Items -->
        <div class="card">
            <div class="card-header">
                <h5>Order Items (${order.items.size()})</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                        <tr>
                            <th>Product</th>
                            <th>Price</th>
                            <th>Quantity</th>
                            <th>Total</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="item" items="${order.items}">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <img src="${item.imageUrl}" alt="${item.productName}"
                                             class="rounded me-3" width="60" height="60"
                                             onerror="this.src='https://via.placeholder.com/60'">
                                        <div>
                                            <h6 class="mb-0">${item.productName}</h6>
                                            <small class="text-muted">SKU: ${item.productID}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>$${item.unitPrice}</td>
                                <td>${item.quantity}</td>
                                <td>$${item.totalPrice}</td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </c:if>

    <c:if test="${empty order}">
        <div class="alert alert-warning text-center">
            <h4>Order Not Found</h4>
            <p>The requested order could not be found.</p>
            <a href="${pageContext.request.contextPath}/orders" class="btn btn-primary">View Your Orders</a>
        </div>
    </c:if>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>