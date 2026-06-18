-- Drop and recreate faqs table with product-specific FAQs
DROP TABLE faqs;

CREATE TABLE faqs (
    faqID VARCHAR(10) PRIMARY KEY,    -- F001, F002, etc.
    question NVARCHAR(500) NOT NULL,
    answer NVARCHAR(MAX) NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'general',
    product_type VARCHAR(100) NULL,   -- Specific product type (iPhone 15, MacBook Pro, etc.)
    product_category VARCHAR(50) NULL, -- General category (Mobile Phones, Laptops, etc.)
    is_product_specific BIT DEFAULT 0, -- 1 if specific to product, 0 if general
    created_date DATETIME DEFAULT GETDATE(),
    updated_date DATETIME DEFAULT GETDATE()
);

-- Indexes for performance
CREATE INDEX idx_faqs_category ON faqs(category);
CREATE INDEX idx_faqs_product_type ON faqs(product_type);
CREATE INDEX idx_faqs_product_category ON faqs(product_category);
CREATE INDEX idx_faqs_product_specific ON faqs(is_product_specific);

-- Insert general FAQs
INSERT INTO faqs (faqID, question, answer, category, is_product_specific) VALUES
('F001', 'How long does shipping take?', 'Standard shipping takes 3-5 business days. Express shipping takes 1-2 business days.', 'shipping', 0),
('F002', 'What is your return policy?', 'You can return items within 30 days of purchase for a full refund. Items must be in original condition.', 'returns', 0),
('F003', 'How do I reset my password?', 'Click on "Forgot Password" on the login page and follow the instructions sent to your email.', 'account', 0),
('F004', 'Do you offer international shipping?', 'Yes, we ship to most countries worldwide. International shipping times vary by destination.', 'shipping', 0),
('F005', 'What payment methods do you accept?', 'We accept Visa, Mastercard, American Express, Discover, PayPal, and Apple Pay.', 'payments', 0);

-- Insert product-specific FAQs
INSERT INTO faqs (faqID, question, answer, category, product_type, product_category, is_product_specific) VALUES
('F006', 'How do I enable Face ID on iPhone 15?', 'Go to Settings > Face ID & Passcode, then follow the setup instructions.', 'mobile_phones', 'iPhone 15', 'Mobile Phones', 1),
('F007', 'What is the warranty on MacBook Pro?', 'MacBook Pro comes with a 1-year limited warranty and 90 days of complimentary technical support.', 'laptops', 'MacBook Pro', 'Laptops', 1),
('F008', 'How to pair AirPods Pro with iPhone?', 'Open AirPods case near your iPhone, hold for 2 seconds, then tap "Connect".', 'audio', 'AirPods Pro', 'Audio', 1),
('F009', 'What is the battery life of Samsung Galaxy S24?', 'Up to 26 hours of talk time and 100+ hours of music playback.', 'mobile_phones', 'Samsung Galaxy S24', 'Mobile Phones', 1),
('F010', 'How to clean MacBook Pro screen?', 'Use a microfiber cloth slightly dampened with water. Do not use harsh chemicals.', 'laptops', 'MacBook Pro', 'Laptops', 1),
('F011', 'How to update firmware on AirPods Pro?', 'Connect to iPhone, go to Settings > General > About > AirPods Pro to check for updates.', 'audio', 'AirPods Pro', 'Audio', 1);

-- Stored procedure to get next FAQ ID (same as before)

DROP PROCEDURE GetNextFaqID;
CREATE PROCEDURE GetNextFaqID
    @NextFaqID VARCHAR(10) OUTPUT
AS
BEGIN
    DECLARE @MaxID INT;
    DECLARE @NextID INT;

    SELECT @MaxID = MAX(CAST(SUBSTRING(faqID, 2, LEN(faqID)-1) AS INT))
    FROM faqs
    WHERE faqID LIKE 'F[0-9]%';

    SET @NextID = ISNULL(@MaxID, 0) + 1;
    SET @NextFaqID = 'F' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3);
END;

-- Updated stored procedure to insert FAQ with product info
DROP PROCEDURE InsertFAQ;
CREATE PROCEDURE InsertFAQ
    @question NVARCHAR(500),
    @answer NVARCHAR(MAX),
    @category VARCHAR(50) = 'general',
    @product_type VARCHAR(100) = NULL,
    @product_category VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @faqID VARCHAR(10);
    DECLARE @is_product_specific BIT = 0;

    -- Determine if this is product-specific
    IF @product_type IS NOT NULL OR @product_category IS NOT NULL
        SET @is_product_specific = 1;

    EXEC GetNextFaqID @NextFaqID = @faqID OUTPUT;

    INSERT INTO faqs (faqID, question, answer, category, product_type, product_category, is_product_specific)
    VALUES (@faqID, @question, @answer, @category, @product_type, @product_category, @is_product_specific);

    SELECT @faqID AS NewFaqID;
END;

DROP TABLE carts;
CREATE TABLE carts (
    cartID VARCHAR(10) PRIMARY KEY,  -- C001, C002, etc.
    userID VARCHAR(10) NOT NULL,
    created_date DATETIME DEFAULT GETDATE(),
    updated_date DATETIME DEFAULT GETDATE(),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned')),
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    item_count INT DEFAULT 0,
    FOREIGN KEY (userID) REFERENCES users(user_id) 
);

-- Indexes for better performance
CREATE INDEX idx_carts_userID ON carts(userID);
CREATE INDEX idx_carts_status ON carts(status);

CREATE TABLE cart_items (
    cartItemID VARCHAR(10) PRIMARY KEY,  -- CI001, CI002, etc.
    cartID VARCHAR(10) NOT NULL,
    productID VARCHAR(10) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    added_date DATETIME DEFAULT GETDATE(),
    updated_date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (cartID) REFERENCES carts(cartID) ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES products(productID) ON DELETE CASCADE,
    UNIQUE (cartID, productID)  -- Prevent duplicate products in cart
);

-- Indexes for better performance
CREATE INDEX idx_cart_items_cartID ON cart_items(cartID);
CREATE INDEX idx_cart_items_productID ON cart_items(productID);

CREATE PROCEDURE GetNextCartID
    @NextCartID VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaxID INT = (SELECT MAX(CAST(SUBSTRING(cartID, 2, LEN(cartID)-1) AS INT)) FROM carts WHERE cartID LIKE 'C[0-9]%');
    DECLARE @NextID INT = ISNULL(@MaxID, 0) + 1;
    SET @NextCartID = 'C' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3);
END;

CREATE PROCEDURE GetNextCartItemID
    @NextCartItemID VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaxID INT = (SELECT MAX(CAST(SUBSTRING(cartItemID, 3, LEN(cartItemID)-2) AS INT)) FROM cart_items WHERE cartItemID LIKE 'CI[0-9]%');
    DECLARE @NextID INT = ISNULL(@MaxID, 0) + 1;
    SET @NextCartItemID = 'CI' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3);
END;

CREATE PROCEDURE GetOrCreateUserCart
    @userID VARCHAR(10),
    @CartID VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if user has an active cart
    SELECT @CartID = cartID 
    FROM carts 
    WHERE userID = @userID AND status = 'active';
    
    -- If no active cart exists, create one
    IF @CartID IS NULL
    BEGIN
        EXEC GetNextCartID @NextCartID = @CartID OUTPUT;
        
        INSERT INTO carts (cartID, userID, status)
        VALUES (@CartID, @userID, 'active');
    END
END;

CREATE PROCEDURE AddToCart
    @userID VARCHAR(10),
    @productID VARCHAR(10),
    @quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CartID VARCHAR(10);
    DECLARE @UnitPrice DECIMAL(10, 2);
    DECLARE @TotalPrice DECIMAL(10, 2);
    DECLARE @CartItemID VARCHAR(10);
    DECLARE @Stock INT;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get or create cart for user
        EXEC GetOrCreateUserCart @userID = @userID, @CartID = @CartID OUTPUT;
        
        -- Get product price and check stock
        SELECT @UnitPrice = price, @Stock = stock 
        FROM products 
        WHERE productID = @productID AND status = 'approved';
        
        IF @UnitPrice IS NULL
        BEGIN
            THROW 50001, 'Product not found or not available', 1;
        END
        
        IF @Stock < @quantity
        BEGIN
            THROW 50002, 'Insufficient stock', 1;
        END
        
        SET @TotalPrice = @UnitPrice * @quantity;
        
        -- Check if product already exists in cart
        IF EXISTS (SELECT 1 FROM cart_items WHERE cartID = @CartID AND productID = @productID)
        BEGIN
            -- Update existing item
            UPDATE cart_items 
            SET quantity = quantity + @quantity,
                total_price = total_price + @TotalPrice,
                updated_date = GETDATE()
            WHERE cartID = @CartID AND productID = @productID;
        END
        ELSE
        BEGIN
            -- Add new item
            EXEC GetNextCartItemID @NextCartItemID = @CartItemID OUTPUT;
            
            INSERT INTO cart_items (cartItemID, cartID, productID, quantity, unit_price, total_price)
            VALUES (@CartItemID, @CartID, @productID, @quantity, @UnitPrice, @TotalPrice);
        END
        
        -- Update cart totals
        UPDATE carts 
        SET total_amount = (SELECT SUM(total_price) FROM cart_items WHERE cartID = @CartID),
            item_count = (SELECT SUM(quantity) FROM cart_items WHERE cartID = @CartID),
            updated_date = GETDATE()
        WHERE cartID = @CartID;
        
        COMMIT TRANSACTION;
        
        SELECT 'success' AS status, @CartID AS cartID;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'error' AS status, ERROR_MESSAGE() AS message;
    END CATCH
END;

CREATE PROCEDURE RemoveFromCart
    @userID VARCHAR(10),
    @productID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CartID VARCHAR(10);
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get user's active cart
        SELECT @CartID = cartID 
        FROM carts 
        WHERE userID = @userID AND status = 'active';
        
        IF @CartID IS NULL
        BEGIN
            THROW 50001, 'No active cart found', 1;
        END
        
        -- Remove item
        DELETE FROM cart_items 
        WHERE cartID = @CartID AND productID = @productID;
        
        -- Update cart totals
        UPDATE carts 
        SET total_amount = ISNULL((SELECT SUM(total_price) FROM cart_items WHERE cartID = @CartID), 0),
            item_count = ISNULL((SELECT SUM(quantity) FROM cart_items WHERE cartID = @CartID), 0),
            updated_date = GETDATE()
        WHERE cartID = @CartID;
        
        COMMIT TRANSACTION;
        
        SELECT 'success' AS status;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'error' AS status, ERROR_MESSAGE() AS message;
    END CATCH
END;

DROP PROCEDURE GetCartContents;
CREATE PROCEDURE GetCartContents
    @userID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.cartID,
        c.total_amount AS cartTotal,
        c.item_count AS totalItems,
        ci.cartItemID,
        ci.productID,
        p.name AS productName,
        p.sku AS productSKU,
        ci.quantity,
        ci.unit_price AS unitPrice,
        ci.total_price AS totalPrice,
        p.stock AS availableStock
    FROM carts c
    LEFT JOIN cart_items ci ON c.cartID = ci.cartID
    LEFT JOIN products p ON ci.productID = p.productID
    WHERE c.userID = @userID AND c.status = 'active'
    ORDER BY ci.added_date DESC;
END;

CREATE PROCEDURE UpdateCartItemQuantity
    @userID VARCHAR(10),
    @productID VARCHAR(10),
    @quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CartID VARCHAR(10);
    DECLARE @UnitPrice DECIMAL(10, 2);
    DECLARE @Stock INT;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get user's active cart
        SELECT @CartID = cartID 
        FROM carts 
        WHERE userID = @userID AND status = 'active';
        
        IF @CartID IS NULL
        BEGIN
            THROW 50001, 'No active cart found', 1;
        END
        
        -- Check stock
        SELECT @Stock = stock 
        FROM products 
        WHERE productID = @productID;
        
        IF @Stock < @quantity
        BEGIN
            THROW 50002, 'Insufficient stock', 1;
        END
        
        -- Get unit price
        SELECT @UnitPrice = unit_price 
        FROM cart_items 
        WHERE cartID = @CartID AND productID = @productID;
        
        IF @UnitPrice IS NULL
        BEGIN
            THROW 50003, 'Item not found in cart', 1;
        END
        
        -- Update quantity
        UPDATE cart_items 
        SET quantity = @quantity,
            total_price = @UnitPrice * @quantity,
            updated_date = GETDATE()
        WHERE cartID = @CartID AND productID = @productID;
        
        -- Update cart totals
        UPDATE carts 
        SET total_amount = (SELECT SUM(total_price) FROM cart_items WHERE cartID = @CartID),
            item_count = (SELECT SUM(quantity) FROM cart_items WHERE cartID = @CartID),
            updated_date = GETDATE()
        WHERE cartID = @CartID;
        
        COMMIT TRANSACTION;
        
        SELECT 'success' AS status;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'error' AS status, ERROR_MESSAGE() AS message;
    END CATCH
END;

CREATE PROCEDURE ClearUserCart
    @userID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CartID VARCHAR(10);
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get user's active cart
        SELECT @CartID = cartID 
        FROM carts 
        WHERE userID = @userID AND status = 'active';
        
        IF @CartID IS NOT NULL
        BEGIN
            -- Remove all items from cart
            DELETE FROM cart_items WHERE cartID = @CartID;
            
            -- Reset cart totals
            UPDATE carts 
            SET total_amount = 0,
                item_count = 0,
                updated_date = GETDATE()
            WHERE cartID = @CartID;
        END
        
        COMMIT TRANSACTION;
        
        SELECT 'success' AS status;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 'error' AS status, ERROR_MESSAGE() AS message;
    END CATCH
END;

CREATE PROCEDURE GetCartSummary
    @userID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.cartID,
        c.total_amount AS cartTotal,
        c.item_count AS totalItems,
        COUNT(ci.cartItemID) AS uniqueItems
    FROM carts c
    LEFT JOIN cart_items ci ON c.cartID = ci.cartID
    WHERE c.userID = @userID AND c.status = 'active'
    GROUP BY c.cartID, c.total_amount, c.item_count;
END;

DROP PROCEDURE AddToCart;
-- In your AddToCart procedure, make sure it handles decimal/double correctly
CREATE PROCEDURE AddToCart
    @userID VARCHAR(10),
    @productID VARCHAR(10),
    @quantity INT
AS
BEGIN
    -- ... existing code ...
    DECLARE @UnitPrice DECIMAL(10, 2);
    DECLARE @TotalPrice DECIMAL(10, 2);
    -- ... rest of procedure ...
END;

DROP PROCEDURE IF EXISTS AddToCart;
GO


DROP PROCEDURE AddToCart;
CREATE PROCEDURE AddToCart
    @userID VARCHAR(10),
    @productID VARCHAR(10),
    @quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CartID VARCHAR(10);
    DECLARE @UnitPrice DECIMAL(10, 2);
    DECLARE @TotalPrice DECIMAL(10, 2);
    DECLARE @CartItemID VARCHAR(10);
    DECLARE @Stock INT;
    DECLARE @ProductExists BIT = 0;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Get or create cart for user
        EXEC GetOrCreateUserCart @userID = @userID, @CartID = @CartID OUTPUT;
        
        -- Get product price and check stock
        SELECT @UnitPrice = price, @Stock = stock 
        FROM products 
        WHERE productID = @productID;
        
        IF @UnitPrice IS NULL
        BEGIN
            THROW 50001, 'Product not found', 1;
        END
        
        IF @Stock < @quantity
        BEGIN
            THROW 50002, 'Insufficient stock', 1;
        END
        
        SET @TotalPrice = @UnitPrice * @quantity;
        
        -- Check if product already exists in cart
        SELECT @ProductExists = 1 
        FROM cart_items 
        WHERE cartID = @CartID AND productID = @productID;
        
        IF @ProductExists = 1
        BEGIN
            -- Update existing item
            UPDATE cart_items 
            SET quantity = quantity + @quantity,
                total_price = total_price + @TotalPrice,
                updated_date = GETDATE()
            WHERE cartID = @CartID AND productID = @productID;
        END
        ELSE
        BEGIN
            -- Add new item
            EXEC GetNextCartItemID @NextCartItemID = @CartItemID OUTPUT;
            
            INSERT INTO cart_items (cartItemID, cartID, productID, quantity, unit_price, total_price)
            VALUES (@CartItemID, @CartID, @productID, @quantity, @UnitPrice, @TotalPrice);
        END
        
        -- Update cart totals
        UPDATE carts 
        SET total_amount = (SELECT SUM(total_price) FROM cart_items WHERE cartID = @CartID),
            item_count = (SELECT SUM(quantity) FROM cart_items WHERE cartID = @CartID),
            updated_date = GETDATE()
        WHERE cartID = @CartID;
        
        COMMIT TRANSACTION;
        
        -- Return success result
        SELECT 'success' AS status, @CartID AS cartID;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Return error result
        SELECT 'error' AS status, ERROR_MESSAGE() AS message;
    END CATCH
END;
GO

DROP PROCEDURE IF EXISTS GetCartContents;
GO

CREATE PROCEDURE GetCartContents
    @userID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.cartID,
        c.total_amount AS cartTotal,
        c.item_count AS totalItems,
        ci.cartItemID,
        ci.productID,
        p.name AS productName,
        p.sku AS productSKU,
        p.category AS productCategory,
        ci.quantity,
        ci.unit_price AS unitPrice,
        ci.total_price AS totalPrice,
        p.stock AS availableStock,
        p.description AS productDescription
    FROM carts c
    INNER JOIN cart_items ci ON c.cartID = ci.cartID
    INNER JOIN products p ON ci.productID = p.productID
    WHERE c.userID = @userID AND c.status = 'active'
    ORDER BY ci.added_date DESC;
END;
GO

DROP PROCEDURE IF EXISTS GetCartContents;
GO

CREATE PROCEDURE GetCartContents
    @userID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.cartID,
        c.total_amount AS cartTotal,
        c.item_count AS totalItems,
        ci.cartItemID,
        ci.productID,
        p.name AS productName,
        p.sku AS productSKU,
        p.category AS productCategory,
        ci.quantity,
        ci.unit_price AS unitPrice,
        ci.total_price AS totalPrice,
        p.stock AS availableStock,
        p.description AS productDescription,
        -- Get primary image URL
        COALESCE(
            (SELECT TOP 1 image_url 
             FROM product_images 
             WHERE product_id = p.productID AND is_primary = 1),
            (SELECT TOP 1 image_url 
             FROM product_images 
             WHERE product_id = p.productID),
            '/images/default-product.jpg'
        ) AS imageUrl
    FROM carts c
    INNER JOIN cart_items ci ON c.cartID = ci.cartID
    INNER JOIN products p ON ci.productID = p.productID
    WHERE c.userID = @userID AND c.status = 'active'
    ORDER BY ci.added_date DESC;
END;
GO