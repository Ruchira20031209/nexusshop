-- Drop database if exists to start fresh
DROP DATABASE IF EXISTS NexusShop2;
GO

-- Create and use database
CREATE DATABASE NexusShop2;
GO
USE NexusShop2;
GO

-- Users table
CREATE TABLE users (
    user_id VARCHAR(10) PRIMARY KEY,  -- U001, U002, etc.
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    role VARCHAR(50) NOT NULL
);
GO

-- Procedure for inserting generic user
CREATE PROCEDURE InsertUser
    @full_name VARCHAR(100),
    @email VARCHAR(100),
    @password VARCHAR(255),
    @address VARCHAR(255) = NULL,
    @role VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @next_id INT;
    DECLARE @user_id VARCHAR(10);
    
    -- Get the next ID number
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(user_id, 2, LEN(user_id)-1) AS INT)), 0) + 1
    FROM users;
    
    -- Format as U001, U002, etc.
    SET @user_id = 'U' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    INSERT INTO users (user_id, full_name, email, password, address, role)
    VALUES (@user_id, @full_name, @email, @password, @address, @role);
    
    SELECT @user_id AS new_user_id;
END;
GO

-- Admins table
CREATE TABLE admins (
    adminID VARCHAR(10) PRIMARY KEY,  -- AD001
    user_id VARCHAR(10),
    registered_date DATETIME DEFAULT GETDATE(),
    department VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
GO

-- Customers table
CREATE TABLE customers (
    customerID VARCHAR(10) PRIMARY KEY,  -- C001
    user_id VARCHAR(10),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
GO

-- Product managers table
CREATE TABLE product_managers (
    pmID VARCHAR(10) PRIMARY KEY,  -- PM001
    user_id VARCHAR(10),
    department VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
GO

-- Suppliers table
CREATE TABLE suppliers (
    sID VARCHAR(10) PRIMARY KEY,  -- SU001
    user_id VARCHAR(10),
    company_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
GO

-- Customer service staff table
CREATE TABLE customer_service_staff (
    csID VARCHAR(10) PRIMARY KEY,  -- CS001
    user_id VARCHAR(10),
    employee_id VARCHAR(50) NOT NULL UNIQUE,
    department VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
GO

-- Delivery persons table
CREATE TABLE delivery_persons (
    dsID VARCHAR(10) PRIMARY KEY,  -- DS001
    user_id VARCHAR(10),
    vehicle_type VARCHAR(50),
    license_plate VARCHAR(20),
    is_available BIT DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
GO

-- Indexes for users and role tables
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_role ON users (role);
CREATE INDEX idx_customers_phone ON customers (phone_number);
CREATE INDEX idx_product_managers_dept ON product_managers (department);
CREATE INDEX idx_suppliers_company ON suppliers (company_name);
CREATE INDEX idx_suppliers_contact ON suppliers (contact_person);
CREATE INDEX idx_cs_staff_employee_id ON customer_service_staff (employee_id);
CREATE INDEX idx_cs_staff_department ON customer_service_staff (department);
CREATE INDEX idx_delivery_persons_license ON delivery_persons (license_plate);
CREATE INDEX idx_delivery_persons_available ON delivery_persons (is_available);
GO

-- Procedure for inserting admin
CREATE PROCEDURE InsertAdmin
    @full_name VARCHAR(100),
    @email VARCHAR(100),
    @password VARCHAR(255),
    @address VARCHAR(255) = NULL,
    @department VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_id VARCHAR(10);
    DECLARE @admin_id VARCHAR(10);
    DECLARE @next_id INT;
    
    -- Get next user ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(user_id, 2, LEN(user_id)-1) AS INT)), 0) + 1
    FROM users;
    SET @user_id = 'U' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert user
    INSERT INTO users (user_id, full_name, email, password, address, role)
    VALUES (@user_id, @full_name, @email, @password, @address, 'admin');
    
    -- Get next admin ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(adminID, 3, LEN(adminID)-2) AS INT)), 0) + 1
    FROM admins;
    SET @admin_id = 'AD' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert admin
    INSERT INTO admins (adminID, user_id, registered_date, department)
    VALUES (@admin_id, @user_id, GETDATE(), @department);
    
    SELECT @admin_id AS new_admin_id, @user_id AS new_user_id;
END;
GO

-- Procedure for inserting customer
CREATE PROCEDURE InsertCustomer
    @full_name VARCHAR(100),
    @email VARCHAR(100),
    @password VARCHAR(255),
    @address VARCHAR(255) = NULL,
    @phone_number VARCHAR(20),
    @date_of_birth DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_id VARCHAR(10);
    DECLARE @customer_id VARCHAR(10);
    DECLARE @next_id INT;
    
    -- Get next user ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(user_id, 2, LEN(user_id)-1) AS INT)), 0) + 1
    FROM users;
    SET @user_id = 'U' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert user
    INSERT INTO users (user_id, full_name, email, password, address, role)
    VALUES (@user_id, @full_name, @email, @password, @address, 'customer');
    
    -- Get next customer ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(customerID, 2, LEN(customerID)-1) AS INT)), 0) + 1
    FROM customers;
    SET @customer_id = 'C' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert customer
    INSERT INTO customers (customerID, user_id, phone_number, date_of_birth)
    VALUES (@customer_id, @user_id, @phone_number, @date_of_birth);
    
    SELECT @customer_id AS new_customer_id, @user_id AS new_user_id;
END;
GO

-- Procedure for inserting product manager
CREATE PROCEDURE InsertProductManager
    @full_name VARCHAR(100),
    @email VARCHAR(100),
    @password VARCHAR(255),
    @address VARCHAR(255) = NULL,
    @department VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_id VARCHAR(10);
    DECLARE @pm_id VARCHAR(10);
    DECLARE @next_id INT;
    
    -- Get next user ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(user_id, 2, LEN(user_id)-1) AS INT)), 0) + 1
    FROM users;
    SET @user_id = 'U' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert user
    INSERT INTO users (user_id, full_name, email, password, address, role)
    VALUES (@user_id, @full_name, @email, @password, @address, 'product_manager');
    
    -- Get next PM ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(pmID, 3, LEN(pmID)-2) AS INT)), 0) + 1
    FROM product_managers;
    SET @pm_id = 'PM' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert PM
    INSERT INTO product_managers (pmID, user_id, department)
    VALUES (@pm_id, @user_id, @department);
    
    SELECT @pm_id AS new_pm_id, @user_id AS new_user_id;
END;
GO

-- Procedure for inserting supplier
CREATE PROCEDURE InsertSupplier
    @full_name VARCHAR(100),
    @email VARCHAR(100),
    @password VARCHAR(255),
    @address VARCHAR(255) = NULL,
    @company_name VARCHAR(100),
    @contact_person VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_id VARCHAR(10);
    DECLARE @supplier_id VARCHAR(10);
    DECLARE @next_id INT;
    
    -- Get next user ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(user_id, 2, LEN(user_id)-1) AS INT)), 0) + 1
    FROM users;
    SET @user_id = 'U' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert user
    INSERT INTO users (user_id, full_name, email, password, address, role)
    VALUES (@user_id, @full_name, @email, @password, @address, 'supplier');
    
    -- Get next supplier ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(sID, 3, LEN(sID)-2) AS INT)), 0) + 1
    FROM suppliers;
    SET @supplier_id = 'SU' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert supplier
    INSERT INTO suppliers (sID, user_id, company_name, contact_person)
    VALUES (@supplier_id, @user_id, @company_name, @contact_person);
    
    SELECT @supplier_id AS new_supplier_id, @user_id AS new_user_id;
END;
GO

-- Procedure for inserting customer service staff
CREATE PROCEDURE InsertCustomerServiceStaff
    @full_name VARCHAR(100),
    @email VARCHAR(100),
    @password VARCHAR(255),
    @address VARCHAR(255) = NULL,
    @employee_id VARCHAR(50),
    @department VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_id VARCHAR(10);
    DECLARE @cs_id VARCHAR(10);
    DECLARE @next_id INT;
    
    -- Get next user ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(user_id, 2, LEN(user_id)-1) AS INT)), 0) + 1
    FROM users;
    SET @user_id = 'U' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert user
    INSERT INTO users (user_id, full_name, email, password, address, role)
    VALUES (@user_id, @full_name, @email, @password, @address, 'customer_service');
    
    -- Get next CS ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(csID, 3, LEN(csID)-2) AS INT)), 0) + 1
    FROM customer_service_staff;
    SET @cs_id = 'CS' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert CS
    INSERT INTO customer_service_staff (csID, user_id, employee_id, department)
    VALUES (@cs_id, @user_id, @employee_id, @department);
    
    SELECT @cs_id AS new_cs_id, @user_id AS new_user_id;
END;
GO

-- Procedure for inserting delivery person
CREATE PROCEDURE InsertDeliveryPerson
    @full_name VARCHAR(100),
    @email VARCHAR(100),
    @password VARCHAR(255),
    @address VARCHAR(255) = NULL,
    @vehicle_type VARCHAR(50),
    @license_plate VARCHAR(20),
    @is_available BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_id VARCHAR(10);
    DECLARE @delivery_id VARCHAR(10);
    DECLARE @next_id INT;
    
    -- Get next user ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(user_id, 2, LEN(user_id)-1) AS INT)), 0) + 1
    FROM users;
    SET @user_id = 'U' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert user
    INSERT INTO users (user_id, full_name, email, password, address, role)
    VALUES (@user_id, @full_name, @email, @password, @address, 'delivery_person');
    
    -- Get next delivery ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(dsID, 3, LEN(dsID)-2) AS INT)), 0) + 1
    FROM delivery_persons;
    SET @delivery_id = 'DS' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert delivery
    INSERT INTO delivery_persons (dsID, user_id, vehicle_type, license_plate, is_available)
    VALUES (@delivery_id, @user_id, @vehicle_type, @license_plate, @is_available);
    
    SELECT @delivery_id AS new_delivery_id, @user_id AS new_user_id;
END;
GO

-- Generic insert procedure by role
CREATE PROCEDURE InsertUserByRole
    @full_name VARCHAR(100),
    @email VARCHAR(100),
    @password VARCHAR(255),
    @address VARCHAR(255) = NULL,
    @role VARCHAR(50),
    @department VARCHAR(100) = NULL,
    @phone_number VARCHAR(20) = NULL,
    @date_of_birth DATE = NULL,
    @company_name VARCHAR(100) = NULL,
    @contact_person VARCHAR(100) = NULL,
    @employee_id VARCHAR(50) = NULL,
    @vehicle_type VARCHAR(50) = NULL,
    @license_plate VARCHAR(20) = NULL,
    @is_available BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_id VARCHAR(10);
    DECLARE @next_id INT;
    
    -- Get next user ID
    SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(user_id, 2, LEN(user_id)-1) AS INT)), 0) + 1
    FROM users;
    SET @user_id = 'U' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
    
    -- Insert user
    INSERT INTO users (user_id, full_name, email, password, address, role)
    VALUES (@user_id, @full_name, @email, @password, @address, @role);
    
    -- Branch by role
    IF @role = 'admin'
    BEGIN
        SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(adminID, 3, LEN(adminID)-2) AS INT)), 0) + 1 FROM admins;
        DECLARE @admin_id VARCHAR(10) = 'AD' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
        INSERT INTO admins (adminID, user_id, registered_date, department) VALUES (@admin_id, @user_id, GETDATE(), @department);
        SELECT @admin_id AS new_specialized_id, @user_id AS new_user_id, 'admin' AS role_created;
    END
    ELSE IF @role = 'customer'
    BEGIN
        SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(customerID, 2, LEN(customerID)-1) AS INT)), 0) + 1 FROM customers;
        DECLARE @customer_id VARCHAR(10) = 'C' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
        INSERT INTO customers (customerID, user_id, phone_number, date_of_birth) VALUES (@customer_id, @user_id, @phone_number, @date_of_birth);
        SELECT @customer_id AS new_specialized_id, @user_id AS new_user_id, 'customer' AS role_created;
    END
    ELSE IF @role = 'product_manager'
    BEGIN
        SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(pmID, 3, LEN(pmID)-2) AS INT)), 0) + 1 FROM product_managers;
        DECLARE @pm_id VARCHAR(10) = 'PM' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
        INSERT INTO product_managers (pmID, user_id, department) VALUES (@pm_id, @user_id, @department);
        SELECT @pm_id AS new_specialized_id, @user_id AS new_user_id, 'product_manager' AS role_created;
    END
    ELSE IF @role = 'supplier'
    BEGIN
        SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(sID, 3, LEN(sID)-2) AS INT)), 0) + 1 FROM suppliers;
        DECLARE @supplier_id VARCHAR(10) = 'SU' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
        INSERT INTO suppliers (sID, user_id, company_name, contact_person) VALUES (@supplier_id, @user_id, @company_name, @contact_person);
        SELECT @supplier_id AS new_specialized_id, @user_id AS new_user_id, 'supplier' AS role_created;
    END
    ELSE IF @role = 'customer_service'
    BEGIN
        SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(csID, 3, LEN(csID)-2) AS INT)), 0) + 1 FROM customer_service_staff;
        DECLARE @cs_id VARCHAR(10) = 'CS' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
        INSERT INTO customer_service_staff (csID, user_id, employee_id, department) VALUES (@cs_id, @user_id, @employee_id, @department);
        SELECT @cs_id AS new_specialized_id, @user_id AS new_user_id, 'customer_service' AS role_created;
    END
    ELSE IF @role = 'delivery_person'
    BEGIN
        SELECT @next_id = ISNULL(MAX(CAST(SUBSTRING(dsID, 3, LEN(dsID)-2) AS INT)), 0) + 1 FROM delivery_persons;
        DECLARE @delivery_id VARCHAR(10) = 'DS' + RIGHT('000' + CAST(@next_id AS VARCHAR(3)), 3);
        INSERT INTO delivery_persons (dsID, user_id, vehicle_type, license_plate, is_available) VALUES (@delivery_id, @user_id, @vehicle_type, @license_plate, @is_available);
        SELECT @delivery_id AS new_specialized_id, @user_id AS new_user_id, 'delivery_person' AS role_created;
    END
END;
GO

-- FAQs table
CREATE TABLE faqs (
    faqID VARCHAR(10) PRIMARY KEY,  -- F001, F002, etc.
    question NVARCHAR(500) NOT NULL,
    answer NVARCHAR(MAX) NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'general'
);
GO

-- Procedure to get next FAQ ID
CREATE PROCEDURE GetNextFaqID
    @NextFaqID VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaxID INT = (SELECT MAX(CAST(SUBSTRING(faqID, 2, LEN(faqID)-1) AS INT)) FROM faqs WHERE faqID LIKE 'F[0-9]%');
    DECLARE @NextID INT = ISNULL(@MaxID, 0) + 1;
    SET @NextFaqID = 'F' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3);
END;
GO

-- Procedure to insert FAQ
CREATE PROCEDURE InsertFAQ
    @question NVARCHAR(500),
    @answer NVARCHAR(MAX),
    @category VARCHAR(50) = 'general'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @faqID VARCHAR(10);
    EXEC GetNextFaqID @NextFaqID = @faqID OUTPUT;
    INSERT INTO faqs (faqID, question, answer, category) VALUES (@faqID, @question, @answer, @category);
    SELECT @faqID AS NewFaqID;
END;
GO

-- Products table (now after suppliers)
CREATE TABLE products (
    productID VARCHAR(10) PRIMARY KEY,  -- P001, P002, etc.
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    description NVARCHAR(MAX),  -- Changed from TEXT
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'held')),
    supplier_id VARCHAR(10) ,
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5.00),
    created_date DATETIME DEFAULT GETDATE(),
    updated_date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(sID) ON DELETE CASCADE
);
GO

-- Product images table
CREATE TABLE product_images (
    imageID VARCHAR(10) PRIMARY KEY,  -- I001, I002, etc.
    product_id VARCHAR(10) NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BIT DEFAULT 0,
    upload_date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES products(productID) ON DELETE CASCADE
);
GO

-- Product specifications table
CREATE TABLE product_specifications (
    specID VARCHAR(10) PRIMARY KEY,  -- S001, S002, etc.
    productID VARCHAR(10) NOT NULL,
    specKey VARCHAR(100) NOT NULL,
    specValue VARCHAR(255) NOT NULL,
    FOREIGN KEY (productID) REFERENCES products(productID) ON DELETE CASCADE
);
GO

-- Indexes for products and related
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_supplier ON products(supplier_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_stock ON products(stock);
GO

-- Procedure to get next product ID
CREATE PROCEDURE GetNextProductID
    @NextProductID VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaxID INT = (SELECT MAX(CAST(SUBSTRING(productID, 2, LEN(productID)-1) AS INT)) FROM products WHERE productID LIKE 'P[0-9]%');
    DECLARE @NextID INT = ISNULL(@MaxID, 0) + 1;
    SET @NextProductID = 'P' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3);
END;
GO

DROP PROCEDURE InsertProduct;
-- Procedure to insert product
CREATE PROCEDURE InsertProduct
    @name VARCHAR(255),
    @sku VARCHAR(100),
    @category VARCHAR(100),
    @price DECIMAL(10, 2),
    @stock INT,
    @description NVARCHAR(MAX),
    @status VARCHAR(20) = 'pending',
    @supplier_id VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON; -- ✅ ADD THIS LINE

    DECLARE @productID VARCHAR(10);
    EXEC GetNextProductID @NextProductID = @productID OUTPUT;
    INSERT INTO products (productID, name, sku, category, price, stock, description, status, supplier_id)
    VALUES (@productID, @name, @sku, @category, @price, @stock, @description, @status, @supplier_id);
    SELECT @productID AS NewProductID;
END;
GO

-- Procedure to get next image ID

DROP PROCEDURE GetNextImageID;
CREATE PROCEDURE GetNextImageID
    @NextImageID VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaxID INT = (SELECT MAX(CAST(SUBSTRING(imageID, 2, LEN(imageID)-1) AS INT)) FROM product_images WHERE imageID LIKE 'I[0-9]%');
    DECLARE @NextID INT = ISNULL(@MaxID, 0) + 1;
    SET @NextImageID = 'I' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3);
END;
GO

-- Procedure to insert product image
CREATE PROCEDURE InsertProductImage
    @product_id VARCHAR(10),
    @image_url VARCHAR(500),
    @is_primary BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @imageID VARCHAR(10);
    EXEC GetNextImageID @NextImageID = @imageID OUTPUT;
    INSERT INTO product_images (imageID, product_id, image_url, is_primary) VALUES (@imageID, @product_id, @image_url, @is_primary);
END;
GO

-- Procedure to get next spec ID
CREATE PROCEDURE GetNextSpecID
    @NextSpecID VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaxID INT = (SELECT MAX(CAST(SUBSTRING(specID, 2, LEN(specID)-1) AS INT)) FROM product_specifications WHERE specID LIKE 'S[0-9]%');
    DECLARE @NextID INT = ISNULL(@MaxID, 0) + 1;
    SET @NextSpecID = 'S' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3);
END;
GO

-- Procedure to insert product spec
CREATE PROCEDURE InsertProductSpec
    @productID VARCHAR(10),
    @specKey VARCHAR(100),
    @specValue VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @specID VARCHAR(10);
    EXEC GetNextSpecID @NextSpecID = @specID OUTPUT;
    INSERT INTO product_specifications (specID, productID, specKey, specValue) VALUES (@specID, @productID, @specKey, @specValue);
END;
GO

-- Sample data: Insert a supplier first (using procedure for consistency)
EXEC InsertSupplier @full_name = 'Supplier Admin', @email = 'supplier@example.com', @password = 'pass123', @company_name = 'Tech Supplies Inc.', @contact_person = 'John Doe';
GO

-- Sample FAQs (direct insert with uppercase IDs for consistency)
INSERT INTO faqs (faqID, question, answer, category) VALUES
('F001', N'What is NexusShop?', N'NexusShop is a premier online retailer specializing in cutting-edge technology and electronics...', 'general'),
('F002', N'Where is NexusShop located?', N'Our headquarters are in San Francisco, California...', 'general'),
('F003', N'How can I contact customer service?', N'You can reach our customer service team 24/7 through the following methods...', 'general'),
('F004', N'Do you offer student discounts?', N'Yes! We offer a 10% discount for students with valid .edu email addresses...', 'general'),
('F005', N'How do I track my order?', N'Once your order ships, you''ll receive a confirmation email with tracking information...', 'general'),
('F006', N'How do I place an order?', N'Placing an order is simple: 1. Browse our products...', 'orders'),
('F007', N'Can I modify or cancel my order?', N'You can modify or cancel your order within 30 minutes...', 'orders'),
('F008', N'How do I check the status of my order?', N'You can check your order status by logging into your account...', 'orders'),
('F009', N'What should I do if I receive a damaged or incorrect item?', N'If you receive a damaged or incorrect item, please contact our customer service...', 'orders'),
('F010', N'Do you offer bulk discounts for large orders?', N'Yes, we offer special pricing for bulk orders...', 'orders'),
('F011', N'What shipping options do you offer?', N'We offer several shipping options: Standard, Expedited, Next Day...', 'shipping'),
('F012', N'How long does shipping take?', N'Processing time is typically 1-2 business days...', 'shipping'),
('F013', N'Do you ship internationally?', N'Yes, we ship to most countries worldwide...', 'shipping'),
('F014', N'Can I change my shipping address after placing an order?', N'Address changes must be made within 30 minutes...', 'shipping'),
('F015', N'What should I do if my package is lost or stolen?', N'If your tracking shows delivered but you haven''t received...', 'shipping'),
('F016', N'What is your return policy?', N'We offer a 30-day return policy for most items...', 'returns'),
('F017', N'How do I return an item?', N'To initiate a return: 1. Log into your account...', 'returns'),
('F018', N'How long does it take to process a refund?', N'Once we receive your return, processing typically takes 3-5 business days...', 'returns'),
('F019', N'Do you offer exchanges?', N'We currently don''t offer direct exchanges...', 'returns'),
('F020', N'What if I receive a defective product?', N'If you receive a defective product, contact us within 14 days...', 'returns'),
('F021', N'What payment methods do you accept?', N'We accept all major payment methods: Credit/Debit Cards, PayPal...', 'payments'),
('F022', N'Is it safe to enter my credit card information?', N'Yes, our checkout process is secure...', 'payments'),
('F023', N'Why was my payment declined?', N'Common reasons for payment declines include...', 'payments'),
('F024', N'Do you offer installment payment plans?', N'Yes, we offer installment plans through PayPal Credit, Affirm...', 'payments'),
('F025', N'Will I be charged sales tax?', N'Sales tax is calculated based on your shipping address...', 'payments'),
('F026', N'How do I create an account?', N'Creating an account is easy: 1. Click "Account"...', 'account'),
('F027', N'I forgot my password. How can I reset it?', N'To reset your password: 1. Go to the login page...', 'account'),
('F028', N'How do I update my account information?', N'To update your account: 1. Log into your account...', 'account'),
('F029', N'Can I merge multiple accounts?', N'Yes, we can merge accounts that have the same email address...', 'account'),
('F030', N'How do I delete my account?', N'To request account deletion: 1. Log into your account...', 'account');
GO

-- Sample products (direct insert after supplier exists)
INSERT INTO products (productID, name, sku, category, price, stock, description, status, supplier_id) VALUES
('P001', 'iPhone 15 Pro', 'IPH15PRO-256GB', 'Mobile Phones', 1199.99, 50, N'Latest iPhone with A17 Pro chip', 'approved', 'SU001'),
('P002', 'MacBook Pro 14"', 'MBP14M3-512GB', 'Laptops', 1999.99, 25, N'M3 chip, 8-core CPU, 10-core GPU', 'approved', 'SU001'),
('P003', 'AirPods Pro 2nd Gen', 'AP2PRO-CHARGING', 'Audio', 249.99, 100, N'Active Noise Cancellation', 'approved', 'SU001'),
('P004', 'Samsung Galaxy S24', 'SGS24-256GB', 'Mobile Phones', 899.99, 30, N'Snapdragon 8 Gen 3 processor', 'approved', 'SU001'),
('P005', 'Dell XPS 13', 'DXPS13I7-256GB', 'Laptops', 1299.99, 20, N'Intel i7, 16GB RAM, 512GB SSD', 'approved', 'SU001');
GO


USE NexusShop2;
GO

-- Add rejection_notes to products table if not exists
ALTER TABLE products
ADD rejection_notes VARCHAR(255) NULL;
GO

-- Drop the existing constraint
ALTER TABLE products DROP CONSTRAINT CK__products__status__71D1E811;

-- Add a new constraint with the values you want
ALTER TABLE products 
ADD CONSTRAINT CK_products_status 
CHECK (status IN ('pending', 'approved', 'rejected', 'on_hold', 'draft'));



-- Create internal supplier for Product Managers
EXEC InsertSupplier 
    @full_name = 'Internal PM Supplier', 
    @email = 'pm-supplier@nexusshop.com', 
    @password = 'pm123', 
    @company_name = 'NexusShop PM Internal', 
    @contact_person = 'PM Department';

-- Verify the supplier was created
SELECT * FROM suppliers;

CREATE PROCEDURE InsertProduct
    @name VARCHAR(255),
    @sku VARCHAR(100),
    @category VARCHAR(100),
    @price DECIMAL(10, 2),
    @stock INT,
    @description NVARCHAR(MAX),
    @status VARCHAR(20) = 'pending',
    @supplier_id VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @productID VARCHAR(10);
    
    -- Get the next product ID
    DECLARE @MaxID INT = (SELECT MAX(CAST(SUBSTRING(productID, 2, LEN(productID)-1) AS INT)) FROM products WHERE productID LIKE 'P[0-9]%');
    DECLARE @NextID INT = ISNULL(@MaxID, 0) + 1;
    SET @productID = 'P' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3);
    
    -- Insert the product
    INSERT INTO products (productID, name, sku, category, price, stock, description, status, supplier_id)
    VALUES (@productID, @name, @sku, @category, @price, @stock, @description, @status, @supplier_id);
    
    -- Return the new product ID
    SELECT @productID AS NewProductID;
END;
GO

-- Create payment cards table
CREATE TABLE payment_cards (
    card_number VARCHAR(10) PRIMARY KEY,  -- C001, C002, etc.
    customer_id VARCHAR(10) NOT NULL,     -- Foreign key to users table
    card_holder_name VARCHAR(100) NOT NULL,
    card_type VARCHAR(20) NOT NULL,       -- Visa, Mastercard, etc.
    card_number_masked VARCHAR(20) NOT NULL, -- e.g., "**** **** **** 1234"
    expiry_month INT NOT NULL CHECK (expiry_month >= 1 AND expiry_month <= 12),
    expiry_year INT NOT NULL CHECK (expiry_year >= YEAR(GETDATE()) AND expiry_year <= YEAR(GETDATE()) + 20),
    cvv VARCHAR(4) NOT NULL CHECK (LEN(cvv) IN (3, 4)),
    billing_address VARCHAR(255),
    is_default BIT DEFAULT 0,             -- 1 if this is the default card
    created_date DATETIME DEFAULT GETDATE(),
    updated_date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Index for performance
CREATE INDEX idx_cards_customer ON payment_cards(customer_id);
CREATE INDEX idx_cards_default ON payment_cards(is_default) WHERE is_default = 1;

-- Stored procedure to get next card number
CREATE PROCEDURE GetNextCardNumber
    @NextCardNumber VARCHAR(10) OUTPUT
AS
BEGIN
    DECLARE @MaxID INT;
    DECLARE @NextID INT;

    SELECT @MaxID = MAX(CAST(SUBSTRING(card_number, 2, LEN(card_number)-1) AS INT))
    FROM payment_cards
    WHERE card_number LIKE 'C[0-9]%';

    SET @NextID = ISNULL(@MaxID, 0) + 1;
    SET @NextCardNumber = 'C' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3);
END;

-- Stored procedure to insert a card
CREATE PROCEDURE InsertPaymentCard
    @customer_id VARCHAR(10),
    @card_holder_name VARCHAR(100),
    @card_type VARCHAR(20),
    @card_number_masked VARCHAR(20),
    @expiry_month INT,
    @expiry_year INT,
    @cvv VARCHAR(4),
    @billing_address VARCHAR(255) = NULL,
    @is_default BIT = 0
AS
BEGIN
    DECLARE @card_number VARCHAR(10);
    EXEC GetNextCardNumber @NextCardNumber = @card_number OUTPUT;
    
    INSERT INTO payment_cards (card_number, customer_id, card_holder_name, card_type, card_number_masked, 
                              expiry_month, expiry_year, cvv, billing_address, is_default)
    VALUES (@card_number, @customer_id, @card_holder_name, @card_type, @card_number_masked, 
            @expiry_month, @expiry_year, @cvv, @billing_address, @is_default);
    
    SELECT @card_number AS NewCardNumber;
END;

-- Sample data
INSERT INTO payment_cards (card_number, customer_id, card_holder_name, card_type, card_number_masked, expiry_month, expiry_year, cvv, is_default) VALUES
('C001', 'U001', 'John Doe', 'Visa', '**** **** **** 1234', 12, 2027, '123', 1),
('C002', 'U001', 'John Doe', 'Mastercard', '**** **** **** 5678', 6, 2026, '456', 0);

-- Check product statuses
SELECT productID, name, status, stock FROM products;

ALTER PROCEDURE ProcessCheckout
    @orderID VARCHAR(20),
    @cardNumber VARCHAR(20),  -- This can be the actual card number or saved card ID
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