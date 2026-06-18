-- Create Orders Table
CREATE TABLE orders (
    orderID VARCHAR(20) PRIMARY KEY,
    customerID VARCHAR(10) NOT NULL,
    cartID VARCHAR(10) NOT NULL,
    orderDate DATETIME DEFAULT GETDATE(),
    totalAmount DECIMAL(10,2) NOT NULL,
    taxAmount DECIMAL(10,2) DEFAULT 0,
    shippingAmount DECIMAL(10,2) DEFAULT 0,
    discountAmount DECIMAL(10,2) DEFAULT 0,
    finalAmount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    shippingAddress VARCHAR(500) NOT NULL,
    billingAddress VARCHAR(500) NOT NULL,
    paymentMethod VARCHAR(50) NOT NULL,
    paymentStatus VARCHAR(20) DEFAULT 'PENDING',
    transactionID VARCHAR(100),
    createdDate DATETIME DEFAULT GETDATE(),
    updatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (customerID) REFERENCES Customers(customerID),
    FOREIGN KEY (cartID) REFERENCES carts(cartID)
);

-- Create Order Items Table
CREATE TABLE order_items (
    orderItemID VARCHAR(20) PRIMARY KEY,
    orderID VARCHAR(20) NOT NULL,
    productID VARCHAR(10) NOT NULL,
    productName VARCHAR(255) NOT NULL,
    unitPrice DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    totalPrice DECIMAL(10,2) NOT NULL,
    imageUrl VARCHAR(500),
    createdDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (orderID) REFERENCES orders(orderID) ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES products(productID)
);



-- Create Sequence for Order IDs
CREATE SEQUENCE OrderIDSeq
    START WITH 1
    INCREMENT BY 1;

-- Create Sequence for Order Item IDs
CREATE SEQUENCE OrderItemIDSeq
    START WITH 1
    INCREMENT BY 1;

-- Create Sequence for Payment Card IDs
CREATE SEQUENCE PaymentCardIDSeq
    START WITH 1
    INCREMENT BY 1;

-- Stored Procedures

-- Create Order
CREATE PROCEDURE CreateOrder
    @customerID VARCHAR(20),
    @cartID VARCHAR(20),
    @totalAmount DECIMAL(10,2),
    @taxAmount DECIMAL(10,2),
    @shippingAmount DECIMAL(10,2),
    @discountAmount DECIMAL(10,2),
    @shippingAddress VARCHAR(500),
    @billingAddress VARCHAR(500),
    @paymentMethod VARCHAR(50),
    @cardNumber VARCHAR(20),
    @orderID VARCHAR(20) OUTPUT
AS
BEGIN
    DECLARE @nextOrderID INT;
    SELECT @nextOrderID = NEXT VALUE FOR OrderIDSeq;
    SET @orderID = 'ORD' + RIGHT('000' + CAST(@nextOrderID AS VARCHAR(10)), 3);
    
    INSERT INTO orders (
        orderID, customerID, cartID, totalAmount, taxAmount, 
        shippingAmount, discountAmount, finalAmount, shippingAddress, 
        billingAddress, paymentMethod
    )
    VALUES (
        @orderID, @customerID, @cartID, @totalAmount, @taxAmount,
        @shippingAmount, @discountAmount, 
        (@totalAmount + @taxAmount + @shippingAmount - @discountAmount),
        @shippingAddress, @billingAddress, @paymentMethod
    );
END;

-- Add Order Item
CREATE PROCEDURE AddOrderItem
    @orderID VARCHAR(20),
    @productID VARCHAR(20),
    @productName VARCHAR(255),
    @unitPrice DECIMAL(10,2),
    @quantity INT,
    @imageUrl VARCHAR(500)
AS
BEGIN
    DECLARE @nextOrderItemID INT;
    DECLARE @orderItemID VARCHAR(20);
    
    SELECT @nextOrderItemID = NEXT VALUE FOR OrderItemIDSeq;
    SET @orderItemID = 'ORDITM' + RIGHT('000' + CAST(@nextOrderItemID AS VARCHAR(10)), 3);
    
    INSERT INTO order_items (
        orderItemID, orderID, productID, productName, unitPrice, 
        quantity, totalPrice, imageUrl
    )
    VALUES (
        @orderItemID, @orderID, @productID, @productName, @unitPrice,
        @quantity, (@unitPrice * @quantity), @imageUrl
    );
END;

-- Get Order By ID
CREATE PROCEDURE GetOrderById
    @orderID VARCHAR(20)
AS
BEGIN
    SELECT * FROM orders WHERE orderID = @orderID;
END;

-- Get Orders By Customer
CREATE PROCEDURE GetOrdersByCustomer
    @customerID VARCHAR(20)
AS
BEGIN
    SELECT * FROM orders 
    WHERE customerID = @customerID 
    ORDER BY orderDate DESC;
END;

-- Get Order Items
CREATE PROCEDURE GetOrderItems
    @orderID VARCHAR(20)
AS
BEGIN
    SELECT * FROM order_items WHERE orderID = @orderID;
END;

-- Update Order Status
CREATE PROCEDURE UpdateOrderStatus
    @orderID VARCHAR(20),
    @status VARCHAR(20)
AS
BEGIN
    UPDATE orders 
    SET status = @status, updatedDate = GETDATE()
    WHERE orderID = @orderID;
END;

-- Update Payment Status
CREATE PROCEDURE UpdatePaymentStatus
    @orderID VARCHAR(20),
    @paymentStatus VARCHAR(20),
    @transactionID VARCHAR(100)
AS
BEGIN
    UPDATE orders 
    SET paymentStatus = @paymentStatus, 
        transactionID = @transactionID,
        updatedDate = GETDATE()
    WHERE orderID = @orderID;
END;

-- Process Checkout
CREATE PROCEDURE ProcessCheckout
    @orderID VARCHAR(20),
    @cardNumber VARCHAR(20),
    @transactionID VARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @newTransactionID VARCHAR(100);
    SET @newTransactionID = 'TXN' + CONVERT(VARCHAR(20), GETDATE(), 112) + 
                           RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR(6)), 6);
    
    UPDATE orders 
    SET paymentStatus = 'PAID',
        status = 'CONFIRMED',
        transactionID = @newTransactionID,
        updatedDate = GETDATE()
    WHERE orderID = @orderID;
    
    SET @transactionID = @newTransactionID;
    
    -- Update product stock
    UPDATE p
    SET p.stock = p.stock - oi.quantity
    FROM products p
    INNER JOIN order_items oi ON p.productID = oi.productID
    WHERE oi.orderID = @orderID;
END;

-- Save Payment Card


-- Get Customer Payment Cards
CREATE PROCEDURE GetCustomerPaymentCards
    @customerID VARCHAR(20)
AS
BEGIN
    SELECT * FROM payment_cards 
    WHERE customerID = @customerID 
    ORDER BY isDefault DESC, createdDate DESC;
END;

SELECT * FROM customers WHERE customerID = 'U008';


-- Drop the existing foreign key constraint
ALTER TABLE orders DROP CONSTRAINT FK_orders_userID;

-- Add new foreign key that references users table
ALTER TABLE orders ADD CONSTRAINT FK_orders_userID 
FOREIGN KEY (customerID) REFERENCES users(user_id);

-- Also update payment_cards table if it has the same issue
ALTER TABLE payment_cards DROP CONSTRAINT FK__payment_cards__customer__;
ALTER TABLE payment_cards ADD CONSTRAINT FK_payment_cards_userID 
FOREIGN KEY (customer_id) REFERENCES users(user_id);

-- Check if U008 exists in customers table
SELECT * FROM customers WHERE customerID = 'U008';

-- If no results, create the customer record
INSERT INTO customers (customerID, name, email, phone, address, created_date)
SELECT 
    user_id, 
    username, 
    email, 
    COALESCE(phone, 'N/A'), 
    COALESCE(address, 'N/A'), 
    GETDATE()
FROM users 
WHERE user_id = 'U008';

-- Verify it was created
SELECT * FROM customers WHERE customerID = 'U008';

-- First, drop the problematic foreign key constraint
ALTER TABLE orders DROP CONSTRAINT FK__orders__customer__5F492382;

-- Then create a new foreign key that references users table
ALTER TABLE orders ADD CONSTRAINT FK_orders_customerID 
FOREIGN KEY (customerID) REFERENCES users(user_id);

-- Also check and fix payment_cards table if needed
ALTER TABLE payment_cards DROP CONSTRAINT FK__payment_cards__customer__...;
ALTER TABLE payment_cards ADD CONSTRAINT FK_payment_cards_customer_id 
FOREIGN KEY (customer_id) REFERENCES users(user_id);

-- Test the CreateOrder stored procedure manually
DECLARE @NewOrderID VARCHAR(20);
EXEC CreateOrder 
    @customerID = 'U008',
    @cartID = 'C002', 
    @totalAmount = 400.00,
    @taxAmount = 32.00,
    @shippingAmount = 0.00,
    @discountAmount = 0.00,
    @shippingAddress = '123 Test Street',
    @billingAddress = '123 Test Street', 
    @paymentMethod = 'CREDIT_CARD',
    @cardNumber = 'C001',
    @orderID = @NewOrderID OUTPUT;
    
SELECT @NewOrderID AS GeneratedOrderID;


DROP PROCEDURE CreateOrder;
CREATE PROCEDURE CreateOrder
    @customerID VARCHAR(20),
    @cartID VARCHAR(20),
    @totalAmount DECIMAL(10,2),
    @taxAmount DECIMAL(10,2),
    @shippingAmount DECIMAL(10,2),
    @discountAmount DECIMAL(10,2),
    @shippingAddress VARCHAR(500),
    @billingAddress VARCHAR(500),
    @paymentMethod VARCHAR(50),
    @cardNumber VARCHAR(20),
    @orderID VARCHAR(20) OUTPUT
AS
BEGIN
    DECLARE @nextOrderID INT;
    
    -- Get next order ID from sequence
    SELECT @nextOrderID = NEXT VALUE FOR OrderIDSeq;
    SET @orderID = 'ORD' + RIGHT('000' + CAST(@nextOrderID AS VARCHAR(10)), 3);
    
    PRINT 'Generated Order ID: ' + @orderID; -- Debug line
    
    INSERT INTO orders (
        orderID, customerID, cartID, totalAmount, taxAmount, 
        shippingAmount, discountAmount, finalAmount, shippingAddress, 
        billingAddress, paymentMethod
    )
    VALUES (
        @orderID, @customerID, @cartID, @totalAmount, @taxAmount,
        @shippingAmount, @discountAmount, 
        (@totalAmount + @taxAmount + @shippingAmount - @discountAmount),
        @shippingAddress, @billingAddress, @paymentMethod
    );
    
    -- Make sure to return the orderID
    SELECT @orderID;
END;

-- Check if sequence exists
SELECT name, current_value, increment_by 
FROM sys.sequences 
WHERE name = 'OrderIDSeq';

-- If it doesn't exist, create it
IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'OrderIDSeq')
BEGIN
    CREATE SEQUENCE OrderIDSeq
        START WITH 1
        INCREMENT BY 1;
    PRINT 'OrderIDSeq sequence created';
END
ELSE
BEGIN
    PRINT 'OrderIDSeq sequence already exists';
END

-- Test the sequence
SELECT NEXT VALUE FOR OrderIDSeq AS NextOrderID;

-- Drop the existing procedure
DROP PROCEDURE IF EXISTS CreateOrder;
GO

-- Create the fixed procedure

DROP PROCEDURE CreateOrder;
CREATE PROCEDURE CreateOrder
    @customerID VARCHAR(20),
    @cartID VARCHAR(20),
    @totalAmount DECIMAL(10,2),
    @taxAmount DECIMAL(10,2),
    @shippingAmount DECIMAL(10,2),
    @discountAmount DECIMAL(10,2),
    @shippingAddress VARCHAR(500),
    @billingAddress VARCHAR(500),
    @paymentMethod VARCHAR(50),
    @cardNumber VARCHAR(20),
    @orderID VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @nextOrderID INT;
    
    -- Get next order ID from sequence
    SELECT @nextOrderID = NEXT VALUE FOR OrderIDSeq;
    SET @orderID = 'ORD' + RIGHT('000' + CAST(@nextOrderID AS VARCHAR(10)), 3);
    
    PRINT 'Generated Order ID: ' + @orderID;
    
    INSERT INTO orders (
        orderID, customerID, cartID, totalAmount, taxAmount, 
        shippingAmount, discountAmount, finalAmount, shippingAddress, 
        billingAddress, paymentMethod, status, paymentStatus
    )
    VALUES (
        @orderID, @customerID, @cartID, @totalAmount, @taxAmount,
        @shippingAmount, @discountAmount, 
        (@totalAmount + @taxAmount + @shippingAmount - @discountAmount),
        @shippingAddress, @billingAddress, @paymentMethod,
        'PENDING', 'PENDING'
    );
    
    -- Return the orderID
    SELECT @orderID AS NewOrderID;
END;
GO

-- Test the stored procedure
DECLARE @NewOrderID VARCHAR(20);
EXEC CreateOrder 
    @customerID = 'U008',
    @cartID = 'C002', 
    @totalAmount = 400.00,
    @taxAmount = 32.00,
    @shippingAmount = 0.00,
    @discountAmount = 0.00,
    @shippingAddress = '123 Test Street',
    @billingAddress = '123 Test Street', 
    @paymentMethod = 'CREDIT_CARD',
    @cardNumber = 'C001',
    @orderID = @NewOrderID OUTPUT;
    
SELECT @NewOrderID AS GeneratedOrderID;

-- Check if order was inserted
SELECT * FROM orders WHERE orderID = @NewOrderID;

-- Drop and recreate AddOrderItem
DROP PROCEDURE IF EXISTS AddOrderItem;
GO


DROP PROCEDURE AddOrderItem;
CREATE PROCEDURE AddOrderItem
    @orderID VARCHAR(20),
    @productID VARCHAR(20),
    @productName VARCHAR(255),
    @unitPrice DECIMAL(10,2),
    @quantity INT,
    @imageUrl VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @nextOrderItemID INT;
    DECLARE @orderItemID VARCHAR(20);
    
    -- Get next order item ID
    SELECT @nextOrderItemID = NEXT VALUE FOR OrderItemIDSeq;
    SET @orderItemID = 'ORDITM' + RIGHT('000' + CAST(@nextOrderItemID AS VARCHAR(10)), 3);
    
    INSERT INTO order_items (
        orderItemID, orderID, productID, productName, unitPrice, 
        quantity, totalPrice, imageUrl
    )
    VALUES (
        @orderItemID, @orderID, @productID, @productName, @unitPrice,
        @quantity, (@unitPrice * @quantity), @imageUrl
    );
END;
GO