<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
  <title>Order History - NexusHope</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<div class="container mt-4">
  <h2 class="mb-4">Order History</h2>

  <c:if test="${not empty error}">
    <div class="alert alert-danger">${error}</div>
  </c:if>

  <c:choose>
    <c:when test="${not empty orders}">
      <div class="table-responsive">
        <table class="table table-striped">
          <thead>
          <tr>
            <th>Order ID</th>
            <th>Date</th>
            <th>Total</th>
            <th>Status</th>
            <th>Payment</th>
            <th>Actions</th>
          </tr>
          </thead>
          <tbody>
          <c:forEach var="order" items="${orders}">
            <tr>
              <td>${order.orderID}</td>
              <td>${order.orderDate}</td>
              <td>$${order.finalAmount}</td>
              <td>
                                        <span class="badge
                                            <c:choose>
                                                <c:when test="${order.status == 'DELIVERED'}">bg-success</c:when>
                                                <c:when test="${order.status == 'CANCELLED'}">bg-danger</c:when>
                                                <c:when test="${order.status == 'PROCESSING'}">bg-warning</c:when>
                                                <c:otherwise>bg-primary</c:otherwise>
                                            </c:choose>">
                                            ${order.status}
                                        </span>
              </td>
              <td>
                                        <span class="badge
                                            <c:choose>
                                                <c:when test="${order.paymentStatus == 'PAID'}">bg-success</c:when>
                                                <c:when test="${order.paymentStatus == 'FAILED'}">bg-danger</c:when>
                                                <c:otherwise>bg-warning</c:otherwise>
                                            </c:choose>">
                                            ${order.paymentStatus}
                                        </span>
              </td>
              <td>
                <a href="${pageContext.request.contextPath}/order/detail?id=${order.orderID}"
                   class="btn btn-sm btn-outline-primary">View Details</a>
                <c:if test="${order.status == 'PENDING' || order.status == 'CONFIRMED'}">
                  <a href="${pageContext.request.contextPath}/order/cancel?id=${order.orderID}"
                     class="btn btn-sm btn-outline-danger"
                     onclick="return confirm('Are you sure you want to cancel this order?')">Cancel</a>
                </c:if>
              </td>
            </tr>
          </c:forEach>
          </tbody>
        </table>
      </div>
    </c:when>
    <c:otherwise>
      <div class="alert alert-info text-center">
        <h4>No Orders Found</h4>
        <p>You haven't placed any orders yet.</p>
        <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">Start Shopping</a>
      </div>
    </c:otherwise>
  </c:choose>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>