<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Checkout - NexusHope</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .checkout-container { max-width: 1200px; margin: 0 auto; }
        .order-summary { background: #f8f9fa; border-radius: 10px; padding: 20px; }
        .form-section { margin-bottom: 30px; }
        .card-option { border: 2px solid #e9ecef; border-radius: 8px; padding: 15px; margin-bottom: 10px; cursor: pointer; }
        .card-option:hover { border-color: #007bff; }
        .card-option.selected { border-color: #007bff; background-color: #f8f9ff; }
        .payment-form { display: none; }
    </style>
</head>
<body>

<div class="container checkout-container mt-4">
    <h2 class="mb-4">Checkout</h2>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="row">
        <!-- Checkout Form -->
        <div class="col-md-8">
            <form action="${pageContext.request.contextPath}/checkout" method="post" id="checkoutForm">

                <!-- Shipping Address -->
                <div class="card form-section">
                    <div class="card-header">
                        <h5>Shipping Address</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label for="shippingAddress" class="form-label">Full Address *</label>
                            <textarea class="form-control" id="shippingAddress" name="shippingAddress"
                                      rows="3" required>${user.address}</textarea>
                        </div>
                    </div>
                </div>

                <!-- Payment Information -->
                <div class="card form-section">
                    <div class="card-header">
                        <h5>Payment Information</h5>
                    </div>
                    <div class="card-body">

                        <!-- Saved Cards Section -->
                        <c:if test="${hasSavedCards}">
                            <div class="mb-4">
                                <h6>Saved Payment Methods</h6>
                                <c:forEach var="card" items="${savedCards}">
                                    <div class="card-option" onclick="selectCard('${card.cardNumber}')">
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="selectedCard"
                                                   id="card${card.cardNumber}" value="${card.cardNumber}">
                                            <label class="form-check-label" for="card${card.cardNumber}">
                                                <strong>${card.cardType}</strong> - ${card.cardNumberMasked}
                                                <c:if test="${card.cardNumber == defaultCard.cardNumber}">
                                                    <span class="badge bg-primary">Default</span>
                                                </c:if>
                                                <br>
                                                <small class="text-muted">
                                                        ${card.cardHolderName} • Expires ${card.expiryMonth}/${card.expiryYear}
                                                </small>
                                            </label>
                                        </div>
                                    </div>
                                </c:forEach>

                                <div class="mt-3">
                                    <button type="button" class="btn btn-outline-primary btn-sm" onclick="showNewCardForm()">
                                        Use Different Card
                                    </button>
                                </div>
                            </div>
                        </c:if>

                        <!-- New Card Form - Show if no saved cards OR user chooses to use new card -->
                        <div id="newCardForm" class="payment-form <c:if test="${not hasSavedCards}">show</c:if>">
                            <input type="hidden" name="useNewCard" value="true">

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="cardHolderName" class="form-label">Card Holder Name *</label>
                                        <input type="text" class="form-control" id="cardHolderName"
                                               name="cardHolderName" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="cardNumber" class="form-label">Card Number *</label>
                                        <input type="text" class="form-control" id="cardNumber"
                                               name="cardNumber" placeholder="1234 5678 9012 3456" required>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="cardType" class="form-label">Card Type *</label>
                                        <select class="form-select" id="cardType" name="cardType" required>
                                            <option value="">Select Card Type</option>
                                            <option value="VISA">VISA</option>
                                            <option value="MASTERCARD">MasterCard</option>
                                            <option value="AMEX">American Express</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="expiryMonth" class="form-label">Expiry Month *</label>
                                        <select class="form-select" id="expiryMonth" name="expiryMonth" required>
                                            <option value="">Month</option>
                                            <c:forEach var="month" begin="1" end="12">
                                                <option value="${month}">${month}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="expiryYear" class="form-label">Expiry Year *</label>
                                        <select class="form-select" id="expiryYear" name="expiryYear" required>
                                            <option value="">Year</option>
                                            <c:forEach var="year" begin="2024" end="2030">
                                                <option value="${year}">${year}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="cvv" class="form-label">CVV *</label>
                                        <input type="text" class="form-control" id="cvv" name="cvv"
                                               placeholder="123" required maxlength="4">
                                    </div>
                                </div>
                                <div class="col-md-8">
                                    <div class="form-check mt-4">
                                        <input class="form-check-input" type="checkbox" id="saveCard" name="saveCard" value="true">
                                        <label class="form-check-label" for="saveCard">
                                            Save this card for future purchases
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary btn-lg">Place Order</button>
                    <a href="${pageContext.request.contextPath}/cart/view" class="btn btn-secondary">Back to Cart</a>
                </div>
            </form>
        </div>

        <!-- Order Summary -->
        <div class="col-md-4">
            <div class="order-summary">
                <h5 class="mb-3">Order Summary</h5>

                <c:if test="${not empty cart && not empty summary}">
                    <div class="d-flex justify-content-between mb-2">
                        <span>Items (${cart.totalItems}):</span>
                        <span>$${cart.totalAmount}</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Shipping:</span>
                        <span>$${summary.shipping}</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Tax:</span>
                        <span>$${summary.tax}</span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between mb-3 fw-bold">
                        <span>Total:</span>
                        <span>$${summary.total}</span>
                    </div>

                    <!-- Cart Items Preview -->
                    <h6 class="mt-4">Items in Cart:</h6>
                    <c:forEach var="item" items="${cart.items}" end="3">
                        <div class="d-flex align-items-center mb-2">
                            <img src="${item.imageUrl}" alt="${item.product.name}"
                                 class="rounded" width="40" height="40"
                                 onerror="this.src='https://via.placeholder.com/40'">
                            <div class="ms-2 flex-grow-1">
                                <small class="d-block">${item.product.name}</small>
                                <small class="text-muted">Qty: ${item.quantity} × $${item.unitPrice}</small>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${cart.totalItems > 4}">
                        <small class="text-muted">+ ${cart.totalItems - 4} more items</small>
                    </c:if>
                </c:if>
            </div>
        </div>
    </div>
</div>

<script>
    function selectCard(cardNumber) {
        // Remove selected class from all cards
        document.querySelectorAll('.card-option').forEach(card => {
            card.classList.remove('selected');
        });

        // Add selected class to clicked card
        event.currentTarget.classList.add('selected');

        // Check the radio button
        document.getElementById('card' + cardNumber).checked = true;

        // Hide new card form
        document.getElementById('newCardForm').style.display = 'none';
    }

    function showNewCardForm() {
        // Uncheck all saved card radio buttons
        document.querySelectorAll('input[name="selectedCard"]').forEach(radio => {
            radio.checked = false;
        });

        // Remove selected class from all cards
        document.querySelectorAll('.card-option').forEach(card => {
            card.classList.remove('selected');
        });

        // Show new card form
        document.getElementById('newCardForm').style.display = 'block';

        // Add required attributes to new card form fields
        document.getElementById('newCardForm').querySelectorAll('input, select').forEach(field => {
            field.required = true;
        });
    }

    // Initialize form based on saved cards
    document.addEventListener('DOMContentLoaded', function() {
        <c:if test="${hasSavedCards}">
        // Auto-select default card if available
        <c:if test="${not empty defaultCard}">
        selectCard('${defaultCard.cardNumber}');
        </c:if>
        </c:if>
    });

    document.addEventListener('DOMContentLoaded', function() {
        console.log('🔍 Checkout page loaded - checking form...');

        const form = document.querySelector('form');
        const submitBtn = document.querySelector('button[type="submit"]');

        console.log('Form found:', !!form);
        console.log('Submit button found:', !!submitBtn);

        if (!form) {
            console.error('❌ FORM NOT FOUND!');
            return;
        }

        // Test if form can be submitted programmatically
        console.log('Form action:', form.action);
        console.log('Form method:', form.method);

        // Add submit event listener
        form.addEventListener('submit', function(e) {
            console.log('✅ FORM SUBMIT EVENT FIRED!');
            console.log('Form is submitting to:', this.action);

            // Check required fields
            const shippingAddress = document.getElementById('shippingAddress');
            console.log('Shipping address:', shippingAddress ? shippingAddress.value : 'NOT FOUND');

            // Check payment method
            const selectedCard = document.querySelector('input[name="selectedCard"]:checked');
            console.log('Selected card:', selectedCard ? selectedCard.value : 'NONE');

            // Don't prevent default - let it submit
        });

        // Also add click event to button
        if (submitBtn) {
            submitBtn.addEventListener('click', function(e) {
                console.log('🖱️ BUTTON CLICKED!');
                console.log('Button type:', this.type);
            });
        }

        // Check for any JavaScript errors that might prevent submission
        window.addEventListener('error', function(e) {
            console.error('❌ JavaScript Error:', e.error);
        });
    });document.addEventListener('DOMContentLoaded', function() {
        console.log('🔍 Checkout page loaded - checking form...');

        const form = document.querySelector('form');
        const submitBtn = document.querySelector('button[type="submit"]');

        console.log('Form found:', !!form);
        console.log('Submit button found:', !!submitBtn);

        if (!form) {
            console.error('❌ FORM NOT FOUND!');
            return;
        }

        // Test if form can be submitted programmatically
        console.log('Form action:', form.action);
        console.log('Form method:', form.method);

        // Add submit event listener
        form.addEventListener('submit', function(e) {
            console.log('✅ FORM SUBMIT EVENT FIRED!');
            console.log('Form is submitting to:', this.action);

            // Check required fields
            const shippingAddress = document.getElementById('shippingAddress');
            console.log('Shipping address:', shippingAddress ? shippingAddress.value : 'NOT FOUND');

            // Check payment method
            const selectedCard = document.querySelector('input[name="selectedCard"]:checked');
            console.log('Selected card:', selectedCard ? selectedCard.value : 'NONE');

            // Don't prevent default - let it submit
        });

        // Also add click event to button
        if (submitBtn) {
            submitBtn.addEventListener('click', function(e) {
                console.log('🖱️ BUTTON CLICKED!');
                console.log('Button type:', this.type);
            });
        }

        // Check for any JavaScript errors that might prevent submission
        window.addEventListener('error', function(e) {
            console.error('❌ JavaScript Error:', e.error);
        });
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>