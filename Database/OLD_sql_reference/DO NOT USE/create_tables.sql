-- GrubnGo Database Schema
-- MySQL CREATE TABLE statements for all entities
-- Refactored to implement all Business Rules and enforce 3NF

-- ========================================
-- ACCOUNT & IDENTITY TABLES (BR-001 to BR-005)
-- ========================================

-- Create Account table first (no dependencies)
-- BR-001, BR-002, BR-003, BR-004, BR-005
CREATE TABLE Account (
    account_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('CUSTOMER', 'RESTAURANT') NOT NULL,
    status ENUM('ACTIVE', 'SUSPENDED', 'CLOSED') DEFAULT 'ACTIVE' NOT NULL, -- BR-003
    failed_login_attempts INT DEFAULT 0, -- BR-004: rate limiting
    last_login_attempt DATETIME NULL, -- BR-004
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT NULL, -- BR-005: audit trail
    FOREIGN KEY (created_by) REFERENCES Account(account_id) ON DELETE SET NULL
);

-- ========================================
-- CUSTOMER TABLES (BR-006 to BR-009)
-- ========================================

-- Create Customer table (depends on Account)
-- BR-001, BR-006, BR-009
CREATE TABLE Customer (
    customer_id BIGINT PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL, -- BR-006: contact method
    FOREIGN KEY (customer_id) REFERENCES Account(account_id) ON DELETE CASCADE
);

-- Create Address table for customer delivery addresses (BR-007)
CREATE TABLE Address (
    address_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    address_label VARCHAR(100) NULL, -- e.g., "Home", "Work"
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA' NOT NULL,
    is_default TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- Create PaymentMethod table for customer payment methods (BR-008, BR-037)
CREATE TABLE PaymentMethod (
    payment_method_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    payment_type ENUM('CARD', 'GIFT_CARD', 'WALLET') NOT NULL,
    payment_token VARCHAR(255) NOT NULL, -- tokenized, never raw card numbers
    card_last_four VARCHAR(4) NULL,
    card_brand VARCHAR(50) NULL, -- Visa, Mastercard, etc.
    expiry_month INT NULL,
    expiry_year INT NULL,
    is_default TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- ========================================
-- RESTAURANT TABLES (BR-010 to BR-013)
-- ========================================

-- Create Restaurant table (depends on Account)
-- BR-010, BR-011, BR-012, BR-013
CREATE TABLE Restaurant (
    restaurant_id BIGINT PRIMARY KEY,
    restaurant_name VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL, -- BR-010: contact info
    contact_email VARCHAR(255) NULL,
    operating_status ENUM('OPEN', 'TEMPORARILY_CLOSED', 'PERMANENTLY_CLOSED') DEFAULT 'OPEN' NOT NULL, -- BR-012
    -- Location information (BR-013)
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA' NOT NULL,
    latitude DECIMAL(10, 8) NULL,
    longitude DECIMAL(11, 8) NULL,
    FOREIGN KEY (restaurant_id) REFERENCES Account(account_id) ON DELETE CASCADE
);

-- Create BusinessHours table for restaurant operating hours (BR-012)
CREATE TABLE BusinessHours (
    business_hours_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    day_of_week ENUM('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY') NOT NULL,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    is_closed TINYINT(1) DEFAULT 0, -- for special closures on specific days
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    UNIQUE KEY unique_restaurant_day (restaurant_id, day_of_week)
);

-- ========================================
-- MENU & MENUITEM TABLES (BR-014 to BR-020)
-- ========================================

-- Create Menu table (depends on Restaurant)
-- BR-014, BR-015
CREATE TABLE Menu (
    menu_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_active TINYINT(1) DEFAULT 1, -- BR-015
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE
);

-- Create MenuItem table (depends on Menu)
-- BR-016, BR-017, BR-018, BR-019
CREATE TABLE MenuItem (
    menu_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    menu_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    is_available TINYINT(1) DEFAULT 1, -- BR-017
    -- Time-based availability (BR-017)
    available_from TIME NULL,
    available_until TIME NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id) ON DELETE CASCADE,
    UNIQUE KEY unique_menu_item_name (menu_id, name) -- BR-019: uniqueness within menu
);

-- Create price history table for audit trail (BR-033)
CREATE TABLE MenuItemPriceHistory (
    price_history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    menu_item_id BIGINT NOT NULL,
    old_price DECIMAL(10, 2) NOT NULL,
    new_price DECIMAL(10, 2) NOT NULL,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by BIGINT NULL,
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem(menu_item_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES Account(account_id) ON DELETE SET NULL
);

-- Create Modifier table for menu item modifiers (BR-020)
CREATE TABLE Modifier (
    modifier_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    menu_item_id BIGINT NOT NULL,
    modifier_name VARCHAR(255) NOT NULL, -- e.g., "Size", "Add-ons"
    min_selections INT DEFAULT 0, -- minimum required selections
    max_selections INT DEFAULT 1, -- maximum allowed selections
    is_required TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem(menu_item_id) ON DELETE CASCADE
);

-- Create ModifierOption table for individual modifier choices (BR-020)
CREATE TABLE ModifierOption (
    modifier_option_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    modifier_id BIGINT NOT NULL,
    option_name VARCHAR(255) NOT NULL, -- e.g., "Small", "Large", "Extra Cheese"
    price_delta DECIMAL(10, 2) DEFAULT 0.00, -- price adjustment (+/-)
    is_available TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (modifier_id) REFERENCES Modifier(modifier_id) ON DELETE CASCADE
);

-- ========================================
-- ORDER & ORDERITEM TABLES (BR-021 to BR-029)
-- ========================================

-- Create Order table (depends on Customer and Restaurant)
-- BR-021, BR-022, BR-023, BR-026, BR-027, BR-029, BR-030, BR-031
CREATE TABLE `Order` (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL, -- BR-021
    restaurant_id BIGINT NOT NULL, -- BR-022
    -- Address snapshot (BR-007)
    delivery_address_id BIGINT NULL,
    delivery_street VARCHAR(255) NULL,
    delivery_city VARCHAR(100) NULL,
    delivery_state VARCHAR(50) NULL,
    delivery_postal_code VARCHAR(20) NULL,
    delivery_country VARCHAR(50) NULL,
    -- Order status and lifecycle (BR-030, BR-031)
    status ENUM('CREATED', 'CONFIRMED', 'PREPARING', 'READY', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'FAILED') DEFAULT 'CREATED' NOT NULL,
    -- Timestamps for lifecycle tracking (BR-029)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    confirmed_at DATETIME NULL,
    prepared_at DATETIME NULL,
    ready_at DATETIME NULL,
    picked_up_at DATETIME NULL,
    delivered_at DATETIME NULL,
    cancelled_at DATETIME NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Pricing fields (BR-026, BR-033, BR-034, BR-035)
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_rate DECIMAL(5, 4) NULL, -- BR-034: store tax rate used
    delivery_fee DECIMAL(10, 2) DEFAULT 0.00,
    service_fee DECIMAL(10, 2) DEFAULT 0.00,
    tip DECIMAL(10, 2) DEFAULT 0.00, -- BR-035
    discount DECIMAL(10, 2) DEFAULT 0.00,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    -- Payment tracking
    payment_method_id BIGINT NULL,
    is_paid TINYINT(1) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    FOREIGN KEY (delivery_address_id) REFERENCES Address(address_id) ON DELETE SET NULL,
    FOREIGN KEY (payment_method_id) REFERENCES PaymentMethod(payment_method_id) ON DELETE SET NULL
);

-- Create OrderItem table with snapshots (depends on Order and MenuItem)
-- BR-024, BR-025, BR-018, BR-028
CREATE TABLE OrderItem (
    order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    menu_item_id BIGINT NOT NULL, -- reference for tracking
    -- Snapshot fields (BR-018, BR-027)
    item_name VARCHAR(255) NOT NULL, -- snapshot of name
    item_description TEXT NULL, -- snapshot of description
    quantity INT NOT NULL DEFAULT 1, -- BR-025
    unit_price DECIMAL(10, 2) NOT NULL, -- snapshot of price at order time
    notes TEXT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem(menu_item_id) ON DELETE RESTRICT -- BR-028
);

-- Create OrderItemModifier to track selected modifiers (BR-020)
CREATE TABLE OrderItemModifier (
    order_item_modifier_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_item_id BIGINT NOT NULL,
    modifier_option_id BIGINT NOT NULL,
    -- Snapshot fields
    modifier_name VARCHAR(255) NOT NULL,
    option_name VARCHAR(255) NOT NULL,
    price_delta DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES OrderItem(order_item_id) ON DELETE CASCADE,
    FOREIGN KEY (modifier_option_id) REFERENCES ModifierOption(modifier_option_id) ON DELETE RESTRICT
);

-- ========================================
-- PAYMENT & TRANSACTION TABLES (BR-037, BR-038)
-- ========================================

-- Create Transaction table for payment audit trail (BR-037, BR-038)
CREATE TABLE Transaction (
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    transaction_type ENUM('AUTHORIZATION', 'CAPTURE', 'REFUND', 'VOID') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING' NOT NULL,
    payment_provider VARCHAR(100) NULL, -- e.g., "Stripe", "PayPal"
    external_transaction_id VARCHAR(255) NULL, -- provider's transaction ID
    error_message TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE
);

-- Create Refund table for refund tracking (BR-032)
CREATE TABLE Refund (
    refund_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    transaction_id BIGINT NULL, -- reference to refund transaction
    refund_amount DECIMAL(10, 2) NOT NULL,
    refund_reason TEXT NULL,
    status ENUM('PENDING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING' NOT NULL,
    requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME NULL,
    requested_by BIGINT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES Transaction(transaction_id) ON DELETE SET NULL,
    FOREIGN KEY (requested_by) REFERENCES Account(account_id) ON DELETE SET NULL
);

-- ========================================
-- AUDIT & LOGGING TABLES (BR-005, BR-039, BR-040)
-- ========================================

-- Create AuditLog table for comprehensive audit trail (BR-005, BR-039)
CREATE TABLE AuditLog (
    audit_log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    action ENUM('CREATE', 'UPDATE', 'DELETE', 'STATUS_CHANGE') NOT NULL,
    field_name VARCHAR(100) NULL,
    old_value TEXT NULL,
    new_value TEXT NULL,
    performed_by BIGINT NULL, -- account_id of user who performed action
    performed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    FOREIGN KEY (performed_by) REFERENCES Account(account_id) ON DELETE SET NULL
);

-- ========================================
-- INDEXES FOR PERFORMANCE
-- ========================================

-- Account indexes
CREATE INDEX idx_account_email ON Account(email);
CREATE INDEX idx_account_role ON Account(role);
CREATE INDEX idx_account_status ON Account(status);

-- Customer indexes
CREATE INDEX idx_customer_phone ON Customer(phone);

-- Address indexes
CREATE INDEX idx_address_customer ON Address(customer_id);
CREATE INDEX idx_address_default ON Address(customer_id, is_default);

-- PaymentMethod indexes
CREATE INDEX idx_payment_method_customer ON PaymentMethod(customer_id);
CREATE INDEX idx_payment_method_default ON PaymentMethod(customer_id, is_default);

-- Restaurant indexes
CREATE INDEX idx_restaurant_status ON Restaurant(operating_status);
CREATE INDEX idx_restaurant_location ON Restaurant(city, state);

-- BusinessHours indexes
CREATE INDEX idx_business_hours_restaurant ON BusinessHours(restaurant_id);

-- Menu indexes
CREATE INDEX idx_menu_restaurant ON Menu(restaurant_id);
CREATE INDEX idx_menu_active ON Menu(restaurant_id, is_active);

-- MenuItem indexes
CREATE INDEX idx_menuitem_menu ON MenuItem(menu_id);
CREATE INDEX idx_menuitem_available ON MenuItem(menu_id, is_available);

-- MenuItemPriceHistory indexes
CREATE INDEX idx_price_history_item ON MenuItemPriceHistory(menu_item_id);

-- Modifier indexes
CREATE INDEX idx_modifier_menuitem ON Modifier(menu_item_id);

-- ModifierOption indexes
CREATE INDEX idx_modifier_option_modifier ON ModifierOption(modifier_id);

-- Order indexes
CREATE INDEX idx_order_customer ON `Order`(customer_id);
CREATE INDEX idx_order_restaurant ON `Order`(restaurant_id);
CREATE INDEX idx_order_status ON `Order`(status);
CREATE INDEX idx_order_created ON `Order`(created_at);
CREATE INDEX idx_order_customer_created ON `Order`(customer_id, created_at);
CREATE INDEX idx_order_restaurant_status ON `Order`(restaurant_id, status);

-- OrderItem indexes
CREATE INDEX idx_orderitem_order ON OrderItem(order_id);
CREATE INDEX idx_orderitem_menuitem ON OrderItem(menu_item_id);

-- OrderItemModifier indexes
CREATE INDEX idx_order_item_modifier_item ON OrderItemModifier(order_item_id);

-- Transaction indexes
CREATE INDEX idx_transaction_order ON Transaction(order_id);
CREATE INDEX idx_transaction_type ON Transaction(transaction_type);
CREATE INDEX idx_transaction_external ON Transaction(external_transaction_id);

-- Refund indexes
CREATE INDEX idx_refund_order ON Refund(order_id);
CREATE INDEX idx_refund_status ON Refund(status);

-- AuditLog indexes
CREATE INDEX idx_audit_table_record ON AuditLog(table_name, record_id);
CREATE INDEX idx_audit_performed_by ON AuditLog(performed_by);
CREATE INDEX idx_audit_performed_at ON AuditLog(performed_at);
