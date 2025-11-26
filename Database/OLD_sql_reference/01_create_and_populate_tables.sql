-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS GrubnGo;
USE GrubnGo;

-- Drop existing tables in reverse dependency order for clean setup
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS AuditLog;
DROP TABLE IF EXISTS Refund;
DROP TABLE IF EXISTS Transaction;
DROP TABLE IF EXISTS OrderItemModifier;
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS `Order`;
DROP TABLE IF EXISTS ModifierOption;
DROP TABLE IF EXISTS Modifier;
DROP TABLE IF EXISTS MenuItemPriceHistory;
DROP TABLE IF EXISTS MenuItem;
DROP TABLE IF EXISTS Menu;
DROP TABLE IF EXISTS BusinessHours;
DROP TABLE IF EXISTS Restaurant;
DROP TABLE IF EXISTS PaymentMethod;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Account;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- TABLE CREATION SECTION
-- =============================================================================

-- Account table (BR-001 to BR-005)
CREATE TABLE Account (
    account_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('CUSTOMER', 'RESTAURANT') NOT NULL,
    status ENUM('ACTIVE', 'SUSPENDED', 'CLOSED') DEFAULT 'ACTIVE' NOT NULL,
    failed_login_attempts INT DEFAULT 0,
    last_login_attempt DATETIME NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by BIGINT NULL,
    FOREIGN KEY (created_by) REFERENCES Account(account_id) ON DELETE SET NULL
);

-- Customer table (BR-006 to BR-009)
CREATE TABLE Customer (
    customer_id BIGINT PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL,
    FOREIGN KEY (customer_id) REFERENCES Account(account_id) ON DELETE CASCADE
);

-- Address table for delivery addresses (BR-007)
CREATE TABLE Address (
    address_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    address_label VARCHAR(100) NULL,
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

-- PaymentMethod table (BR-008, BR-037)
CREATE TABLE PaymentMethod (
    payment_method_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    payment_type ENUM('CREDIT_CARD', 'DEBIT_CARD', 'PAYPAL', 'APPLE_PAY', 'GOOGLE_PAY') NOT NULL,
    payment_token VARCHAR(255) NOT NULL,
    card_last_four VARCHAR(4) NULL,
    card_brand VARCHAR(50) NULL,
    expiry_month INT NULL,
    expiry_year INT NULL,
    is_default TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- Restaurant table (BR-010 to BR-013)
CREATE TABLE Restaurant (
    restaurant_id BIGINT PRIMARY KEY,
    restaurant_name VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    contact_email VARCHAR(255) NULL,
    operating_status ENUM('OPEN', 'TEMPORARILY_CLOSED', 'PERMANENTLY_CLOSED') DEFAULT 'OPEN' NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA' NOT NULL,
    latitude DECIMAL(10, 8) NULL,
    longitude DECIMAL(11, 8) NULL,
    FOREIGN KEY (restaurant_id) REFERENCES Account(account_id) ON DELETE CASCADE
);

-- BusinessHours table (BR-012)
CREATE TABLE BusinessHours (
    business_hours_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    day_of_week ENUM('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY') NOT NULL,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    is_closed TINYINT(1) DEFAULT 0,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    UNIQUE KEY unique_restaurant_day (restaurant_id, day_of_week)
);

-- Menu table (BR-014, BR-015)
CREATE TABLE Menu (
    menu_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE
);

-- MenuItem table (BR-016 to BR-019)
CREATE TABLE MenuItem (
    menu_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    menu_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    is_available TINYINT(1) DEFAULT 1,
    available_from TIME NULL,
    available_until TIME NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id) ON DELETE CASCADE,
    UNIQUE KEY unique_menu_item_name (menu_id, name)
);

-- Price history table (BR-033)
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

-- Modifier table (BR-020)
CREATE TABLE Modifier (
    modifier_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    menu_item_id BIGINT NOT NULL,
    modifier_name VARCHAR(255) NOT NULL,
    min_selections INT DEFAULT 0,
    max_selections INT DEFAULT 1,
    is_required TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem(menu_item_id) ON DELETE CASCADE
);

-- ModifierOption table (BR-020)
CREATE TABLE ModifierOption (
    modifier_option_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    modifier_id BIGINT NOT NULL,
    option_name VARCHAR(255) NOT NULL,
    price_delta DECIMAL(10, 2) DEFAULT 0.00,
    is_available TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (modifier_id) REFERENCES Modifier(modifier_id) ON DELETE CASCADE
);

-- Order table (BR-021 to BR-032)
CREATE TABLE `Order` (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    restaurant_id BIGINT NOT NULL,
    delivery_address_id BIGINT NULL,
    delivery_street VARCHAR(255) NULL,
    delivery_city VARCHAR(100) NULL,
    delivery_state VARCHAR(50) NULL,
    delivery_postal_code VARCHAR(20) NULL,
    delivery_country VARCHAR(50) NULL,
    status ENUM('CREATED', 'CONFIRMED', 'PREPARING', 'READY', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'FAILED') DEFAULT 'CREATED' NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    confirmed_at DATETIME NULL,
    prepared_at DATETIME NULL,
    ready_at DATETIME NULL,
    picked_up_at DATETIME NULL,
    delivered_at DATETIME NULL,
    cancelled_at DATETIME NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_rate DECIMAL(5, 4) NULL,
    delivery_fee DECIMAL(10, 2) DEFAULT 0.00,
    service_fee DECIMAL(10, 2) DEFAULT 0.00,
    tip DECIMAL(10, 2) DEFAULT 0.00,
    discount DECIMAL(10, 2) DEFAULT 0.00,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    payment_method_id BIGINT NULL,
    is_paid TINYINT(1) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE,
    FOREIGN KEY (delivery_address_id) REFERENCES Address(address_id) ON DELETE SET NULL,
    FOREIGN KEY (payment_method_id) REFERENCES PaymentMethod(payment_method_id) ON DELETE SET NULL
);

-- OrderItem table (BR-024 to BR-028)
CREATE TABLE OrderItem (
    order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    menu_item_id BIGINT NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    item_description TEXT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    notes TEXT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem(menu_item_id) ON DELETE RESTRICT
);

-- OrderItemModifier table (BR-020)
CREATE TABLE OrderItemModifier (
    order_item_modifier_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_item_id BIGINT NOT NULL,
    modifier_option_id BIGINT NOT NULL,
    modifier_name VARCHAR(255) NOT NULL,
    option_name VARCHAR(255) NOT NULL,
    price_delta DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES OrderItem(order_item_id) ON DELETE CASCADE,
    FOREIGN KEY (modifier_option_id) REFERENCES ModifierOption(modifier_option_id) ON DELETE RESTRICT
);

-- Transaction table (BR-037, BR-038)
CREATE TABLE Transaction (
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    transaction_type ENUM('AUTHORIZATION', 'CAPTURE', 'REFUND', 'VOID') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING' NOT NULL,
    payment_provider VARCHAR(100) NULL,
    external_transaction_id VARCHAR(255) NULL,
    error_message TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE
);

-- Refund table (BR-032)
CREATE TABLE Refund (
    refund_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    transaction_id BIGINT NULL,
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

-- AuditLog table (BR-005, BR-039)
CREATE TABLE AuditLog (
    audit_log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    action ENUM('CREATE', 'UPDATE', 'DELETE', 'STATUS_CHANGE') NOT NULL,
    field_name VARCHAR(100) NULL,
    old_value TEXT NULL,
    new_value TEXT NULL,
    performed_by BIGINT NULL,
    performed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    FOREIGN KEY (performed_by) REFERENCES Account(account_id) ON DELETE SET NULL
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Account indexes
CREATE INDEX idx_account_email ON Account(email);
CREATE INDEX idx_account_role ON Account(role);
CREATE INDEX idx_account_status ON Account(status);

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

-- Order indexes
CREATE INDEX idx_order_customer ON `Order`(customer_id);
CREATE INDEX idx_order_restaurant ON `Order`(restaurant_id);
CREATE INDEX idx_order_status ON `Order`(status);
CREATE INDEX idx_order_created ON `Order`(created_at);
CREATE INDEX idx_order_customer_created ON `Order`(customer_id, created_at);

-- OrderItem indexes
CREATE INDEX idx_orderitem_order ON OrderItem(order_id);
CREATE INDEX idx_orderitem_menuitem ON OrderItem(menu_item_id);

-- Transaction indexes
CREATE INDEX idx_transaction_order ON Transaction(order_id);
CREATE INDEX idx_transaction_type ON Transaction(transaction_type);

-- AuditLog indexes
CREATE INDEX idx_audit_table_record ON AuditLog(table_name, record_id);
CREATE INDEX idx_audit_performed_by ON AuditLog(performed_by);
CREATE INDEX idx_audit_performed_at ON AuditLog(performed_at);

-- =============================================================================
-- SAMPLE DATA POPULATION
-- =============================================================================

-- Insert sample accounts (customers and restaurants)
INSERT INTO Account (email, password_hash, role, status, created_by) VALUES
('john.doe@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'CUSTOMER', 'ACTIVE', NULL),
('jane.smith@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'CUSTOMER', 'ACTIVE', NULL),
('bob.johnson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'CUSTOMER', 'ACTIVE', NULL),
('alice.brown@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'CUSTOMER', 'ACTIVE', NULL),
('charlie.davis@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'CUSTOMER', 'ACTIVE', NULL),
('marios.pizza@restaurant.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'RESTAURANT', 'ACTIVE', NULL),
('burger.palace@restaurant.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'RESTAURANT', 'ACTIVE', NULL),
('sushi.zen@restaurant.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'RESTAURANT', 'ACTIVE', NULL),
('taco.fiesta@restaurant.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'RESTAURANT', 'ACTIVE', NULL),
('cafe.brew@restaurant.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmVFYm6.xWOxhdG', 'RESTAURANT', 'ACTIVE', NULL);

-- Insert customers
INSERT INTO Customer (customer_id, customer_name, phone) VALUES
(1, 'John Doe', '555-0101'),
(2, 'Jane Smith', '555-0102'),
(3, 'Bob Johnson', '555-0103'),
(4, 'Alice Brown', '555-0104'),
(5, 'Charlie Davis', '555-0105');

-- Insert customer addresses
INSERT INTO Address (customer_id, address_label, street_address, city, state, postal_code, country, is_default) VALUES
(1, 'Home', '123 Main St', 'San Francisco', 'CA', '94102', 'USA', 1),
(1, 'Work', '456 Market St', 'San Francisco', 'CA', '94105', 'USA', 0),
(2, 'Home', '789 Pine St', 'San Francisco', 'CA', '94108', 'USA', 1),
(3, 'Home', '321 Oak St', 'Oakland', 'CA', '94607', 'USA', 1),
(4, 'Home', '654 Elm St', 'Berkeley', 'CA', '94702', 'USA', 1),
(5, 'Home', '987 Cedar Ave', 'San Jose', 'CA', '95112', 'USA', 1);

-- Insert payment methods
INSERT INTO PaymentMethod (customer_id, payment_type, payment_token, card_last_four, card_brand, expiry_month, expiry_year, is_default) VALUES
(1, 'CREDIT_CARD', 'tok_1234567890abcdef', '4242', 'Visa', 12, 2027, 1),
(1, 'PAYPAL', 'pp_john_doe_token', NULL, NULL, NULL, NULL, 0),
(2, 'CREDIT_CARD', 'tok_abcdef1234567890', '5555', 'Mastercard', 8, 2026, 1),
(3, 'DEBIT_CARD', 'tok_fedcba0987654321', '1234', 'Visa', 3, 2028, 1),
(4, 'APPLE_PAY', 'ap_alice_token_xyz', NULL, NULL, NULL, NULL, 1),
(5, 'GOOGLE_PAY', 'gp_charlie_token_abc', NULL, NULL, NULL, NULL, 1);

-- Insert restaurants
INSERT INTO Restaurant (restaurant_id, restaurant_name, contact_phone, contact_email, operating_status, 
                       street_address, city, state, postal_code, country, latitude, longitude) VALUES
(6, "Mario's Pizza Palace", '555-0201', 'orders@mariospizza.com', 'OPEN', 
 '100 Columbus Ave', 'San Francisco', 'CA', '94133', 'USA', 37.798535, -122.407104),
(7, 'Burger Palace', '555-0202', 'info@burgerpalace.com', 'OPEN',
 '200 Union St', 'San Francisco', 'CA', '94133', 'USA', 37.800181, -122.410140),
(8, 'Sushi Zen', '555-0203', 'reservations@sushizen.com', 'OPEN',
 '300 Grant Ave', 'San Francisco', 'CA', '94108', 'USA', 37.790834, -122.405415),
(9, 'Taco Fiesta', '555-0204', 'orders@tacofiesta.com', 'OPEN',
 '400 Valencia St', 'San Francisco', 'CA', '94103', 'USA', 37.765842, -122.421018),
(10, 'Cafe Brew', '555-0205', 'hello@cafebrew.com', 'TEMPORARILY_CLOSED',
  '500 Hayes St', 'San Francisco', 'CA', '94102', 'USA', 37.776818, -122.424506);

-- Insert business hours for restaurants
INSERT INTO BusinessHours (restaurant_id, day_of_week, open_time, close_time, is_closed) VALUES
-- Mario's Pizza Palace
(6, 'MONDAY', '11:00:00', '22:00:00', 0),
(6, 'TUESDAY', '11:00:00', '22:00:00', 0),
(6, 'WEDNESDAY', '11:00:00', '22:00:00', 0),
(6, 'THURSDAY', '11:00:00', '22:00:00', 0),
(6, 'FRIDAY', '11:00:00', '23:00:00', 0),
(6, 'SATURDAY', '11:00:00', '23:00:00', 0),
(6, 'SUNDAY', '12:00:00', '21:00:00', 0),
-- Burger Palace
(7, 'MONDAY', '10:00:00', '22:00:00', 0),
(7, 'TUESDAY', '10:00:00', '22:00:00', 0),
(7, 'WEDNESDAY', '10:00:00', '22:00:00', 0),
(7, 'THURSDAY', '10:00:00', '22:00:00', 0),
(7, 'FRIDAY', '10:00:00', '23:00:00', 0),
(7, 'SATURDAY', '10:00:00', '23:00:00', 0),
(7, 'SUNDAY', '11:00:00', '21:00:00', 0),
-- Sushi Zen
(8, 'MONDAY', '17:00:00', '22:00:00', 0),
(8, 'TUESDAY', '17:00:00', '22:00:00', 0),
(8, 'WEDNESDAY', '17:00:00', '22:00:00', 0),
(8, 'THURSDAY', '17:00:00', '22:00:00', 0),
(8, 'FRIDAY', '17:00:00', '23:00:00', 0),
(8, 'SATURDAY', '17:00:00', '23:00:00', 0),
(8, 'SUNDAY', '17:00:00', '21:00:00', 0),
-- Taco Fiesta
(9, 'MONDAY', '08:00:00', '20:00:00', 0),
(9, 'TUESDAY', '08:00:00', '20:00:00', 0),
(9, 'WEDNESDAY', '08:00:00', '20:00:00', 0),
(9, 'THURSDAY', '08:00:00', '20:00:00', 0),
(9, 'FRIDAY', '08:00:00', '21:00:00', 0),
(9, 'SATURDAY', '08:00:00', '21:00:00', 0),
(9, 'SUNDAY', '09:00:00', '19:00:00', 0),
-- Cafe Brew (closed)
(10, 'MONDAY', '07:00:00', '15:00:00', 1),
(10, 'TUESDAY', '07:00:00', '15:00:00', 1),
(10, 'WEDNESDAY', '07:00:00', '15:00:00', 1),
(10, 'THURSDAY', '07:00:00', '15:00:00', 1),
(10, 'FRIDAY', '07:00:00', '15:00:00', 1),
(10, 'SATURDAY', '08:00:00', '16:00:00', 1),
(10, 'SUNDAY', '08:00:00', '16:00:00', 1);

-- Insert menus
INSERT INTO Menu (restaurant_id, name, is_active) VALUES
(6, 'Main Menu', 1),
(6, 'Lunch Specials', 1),
(7, 'Burgers & Fries', 1),
(7, 'Breakfast Menu', 1),
(8, 'Dinner Menu', 1),
(8, 'Sushi Bar', 1),
(9, 'All Day Menu', 1),
(10, 'Coffee & Pastries', 0);

-- Insert menu items
INSERT INTO MenuItem (menu_id, name, description, price, is_available, available_from, available_until) VALUES
-- Mario's Pizza Palace - Main Menu
(1, 'Margherita Pizza', 'Fresh mozzarella, basil, and tomato sauce', 18.99, 1, NULL, NULL),
(1, 'Pepperoni Pizza', 'Classic pepperoni with mozzarella cheese', 21.99, 1, NULL, NULL),
(1, 'Caesar Salad', 'Romaine lettuce, parmesan, croutons, caesar dressing', 12.99, 1, NULL, NULL),
(1, 'Garlic Bread', 'Toasted bread with garlic butter and herbs', 6.99, 1, NULL, NULL),
-- Mario's Pizza Palace - Lunch Specials
(2, 'Personal Pizza Combo', 'Small pizza with salad and drink', 14.99, 1, '11:00:00', '15:00:00'),
(2, 'Pasta of the Day', 'Chef selection pasta with garlic bread', 13.99, 1, '11:00:00', '15:00:00'),
-- Burger Palace - Burgers & Fries
(3, 'Classic Burger', 'Beef patty, lettuce, tomato, onion, pickles', 15.99, 1, NULL, NULL),
(3, 'Cheeseburger', 'Classic burger with cheese', 17.99, 1, NULL, NULL),
(3, 'BBQ Bacon Burger', 'Burger with BBQ sauce and bacon', 19.99, 1, NULL, NULL),
(3, 'French Fries', 'Crispy golden fries', 5.99, 1, NULL, NULL),
(3, 'Onion Rings', 'Beer-battered onion rings', 7.99, 1, NULL, NULL),
-- Burger Palace - Breakfast Menu
(4, 'Breakfast Burger', 'Burger with egg and bacon', 16.99, 1, '06:00:00', '11:00:00'),
(4, 'Pancakes', 'Stack of fluffy pancakes', 9.99, 1, '06:00:00', '11:00:00'),
-- Sushi Zen - Dinner Menu
(5, 'Chicken Teriyaki', 'Grilled chicken with teriyaki sauce', 22.99, 1, NULL, NULL),
(5, 'Beef Yakitori', 'Grilled beef skewers', 24.99, 1, NULL, NULL),
(5, 'Miso Soup', 'Traditional soybean soup', 4.99, 1, NULL, NULL),
-- Sushi Zen - Sushi Bar
(6, 'California Roll', 'Crab, avocado, cucumber', 8.99, 1, NULL, NULL),
(6, 'Salmon Sashimi', 'Fresh salmon slices (6 pieces)', 14.99, 1, NULL, NULL),
(6, 'Tuna Roll', 'Fresh tuna roll', 12.99, 1, NULL, NULL),
-- Taco Fiesta - All Day Menu
(7, 'Beef Taco', 'Seasoned ground beef with toppings', 3.99, 1, NULL, NULL),
(7, 'Chicken Burrito', 'Grilled chicken burrito with rice and beans', 11.99, 1, NULL, NULL),
(7, 'Guacamole & Chips', 'Fresh guacamole with tortilla chips', 7.99, 1, NULL, NULL),
(7, 'Quesadilla', 'Cheese quesadilla with sour cream', 8.99, 1, NULL, NULL),
-- Cafe Brew - Coffee & Pastries (inactive)
(8, 'Espresso', 'Double shot espresso', 3.99, 0, NULL, NULL),
(8, 'Latte', 'Espresso with steamed milk', 5.99, 0, NULL, NULL),
(8, 'Croissant', 'Buttery flaky croissant', 4.99, 0, NULL, NULL);

-- Insert modifiers for customization
INSERT INTO Modifier (menu_item_id, modifier_name, min_selections, max_selections, is_required) VALUES
-- Pizza sizes
(1, 'Size', 1, 1, 1),
(2, 'Size', 1, 1, 1),
-- Burger add-ons
(7, 'Add-ons', 0, 5, 0),
(8, 'Add-ons', 0, 5, 0),
(9, 'Add-ons', 0, 5, 0),
-- Taco toppings
(19, 'Toppings', 0, 4, 0),
-- Burrito customization
(20, 'Protein Level', 0, 1, 0),
-- Coffee sizes
(24, 'Size', 1, 1, 1),
(25, 'Size', 1, 1, 1);

-- Insert modifier options
INSERT INTO ModifierOption (modifier_id, option_name, price_delta, is_available) VALUES
-- Pizza sizes
(1, 'Small (10")', -2.00, 1),
(1, 'Medium (12")', 0.00, 1),
(1, 'Large (14")', 3.00, 1),
(1, 'Extra Large (16")', 6.00, 1),
(2, 'Small (10")', -2.00, 1),
(2, 'Medium (12")', 0.00, 1),
(2, 'Large (14")', 3.00, 1),
(2, 'Extra Large (16")', 6.00, 1),
-- Burger add-ons
(3, 'Extra Cheese', 1.50, 1),
(3, 'Bacon', 2.50, 1),
(3, 'Avocado', 2.00, 1),
(3, 'Mushrooms', 1.00, 1),
(3, 'Jalapeños', 0.50, 1),
(4, 'Extra Cheese', 1.50, 1),
(4, 'Bacon', 2.50, 1),
(4, 'Avocado', 2.00, 1),
(4, 'Mushrooms', 1.00, 1),
(4, 'Jalapeños', 0.50, 1),
(5, 'Extra Cheese', 1.50, 1),
(5, 'Bacon', 2.50, 1),
(5, 'Avocado', 2.00, 1),
(5, 'Mushrooms', 1.00, 1),
(5, 'Jalapeños', 0.50, 1),
-- Taco toppings
(6, 'Lettuce', 0.00, 1),
(6, 'Tomatoes', 0.00, 1),
(6, 'Cheese', 0.50, 1),
(6, 'Sour Cream', 0.50, 1),
-- Burrito protein level
(7, 'Double Meat', 3.99, 1),
-- Coffee sizes
(8, 'Small', -1.00, 1),
(8, 'Medium', 0.00, 1),
(8, 'Large', 1.00, 1),
(9, 'Small', -1.00, 1),
(9, 'Medium', 0.00, 1),
(9, 'Large', 1.00, 1);

-- Insert sample orders
INSERT INTO `Order` (customer_id, restaurant_id, delivery_address_id, delivery_street, delivery_city, 
                     delivery_state, delivery_postal_code, delivery_country, status, subtotal, tax, 
                     tax_rate, delivery_fee, service_fee, tip, discount, total, payment_method_id, is_paid,
                     created_at, confirmed_at, prepared_at, ready_at, delivered_at) VALUES
(1, 6, 1, '123 Main St', 'San Francisco', 'CA', '94102', 'USA', 'DELIVERED', 
 24.99, 2.19, 0.0875, 3.99, 1.99, 5.00, 0.00, 38.16, 1, 1,
 '2024-11-01 18:30:00', '2024-11-01 18:32:00', '2024-11-01 18:45:00', '2024-11-01 19:00:00', '2024-11-01 19:25:00'),
(2, 7, 3, '789 Pine St', 'San Francisco', 'CA', '94108', 'USA', 'DELIVERED',
 21.98, 1.92, 0.0875, 2.99, 1.99, 4.00, 0.00, 32.88, 3, 1,
 '2024-11-02 12:15:00', '2024-11-02 12:17:00', '2024-11-02 12:25:00', '2024-11-02 12:35:00', '2024-11-02 12:50:00'),
(3, 8, 4, '321 Oak St', 'Oakland', 'CA', '94607', 'USA', 'CONFIRMED',
 27.98, 2.45, 0.0875, 4.99, 1.99, 0.00, 0.00, 37.41, 4, 0,
 '2024-11-11 19:45:00', '2024-11-11 19:47:00', NULL, NULL, NULL),
(4, 9, 5, '654 Elm St', 'Berkeley', 'CA', '94702', 'USA', 'PREPARING',
 16.97, 1.48, 0.0875, 3.99, 1.99, 3.00, 2.00, 27.43, 5, 1,
 '2024-11-11 11:20:00', '2024-11-11 11:22:00', '2024-11-11 11:25:00', NULL, NULL),
(1, 7, 2, '456 Market St', 'San Francisco', 'CA', '94105', 'USA', 'OUT_FOR_DELIVERY',
 19.99, 1.75, 0.0875, 2.99, 1.99, 4.50, 0.00, 31.22, 2, 1,
 '2024-11-11 13:00:00', '2024-11-11 13:02:00', '2024-11-11 13:15:00', '2024-11-11 13:30:00', NULL);

-- Insert order items with snapshots
INSERT INTO OrderItem (order_id, menu_item_id, item_name, item_description, quantity, unit_price, notes) VALUES
-- Order 1: Pizza order
(1, 1, 'Margherita Pizza', 'Fresh mozzarella, basil, and tomato sauce', 1, 21.99, 'Large size'),
(1, 4, 'Garlic Bread', 'Toasted bread with garlic butter and herbs', 1, 6.99, NULL),
-- Order 2: Burger order
(2, 7, 'Classic Burger', 'Beef patty, lettuce, tomato, onion, pickles', 1, 15.99, 'No onions'),
(2, 10, 'French Fries', 'Crispy golden fries', 1, 5.99, NULL),
-- Order 3: Sushi order
(3, 14, 'Chicken Teriyaki', 'Grilled chicken with teriyaki sauce', 1, 22.99, NULL),
(3, 16, 'Miso Soup', 'Traditional soybean soup', 1, 4.99, NULL),
-- Order 4: Taco order
(4, 19, 'Beef Taco', 'Seasoned ground beef with toppings', 2, 3.99, 'Extra spicy'),
(4, 21, 'Guacamole & Chips', 'Fresh guacamole with tortilla chips', 1, 7.99, NULL),
-- Order 5: Burger order
(5, 9, 'BBQ Bacon Burger', 'Burger with BBQ sauce and bacon', 1, 19.99, 'Medium rare');

-- Insert order item modifiers (snapshots of selected options)
INSERT INTO OrderItemModifier (order_item_id, modifier_option_id, modifier_name, option_name, price_delta) VALUES
-- Pizza size selection
(1, 3, 'Size', 'Large (14")', 3.00),
-- Burger add-ons
(3, 11, 'Add-ons', 'Extra Cheese', 1.50),
-- Taco toppings
(7, 22, 'Toppings', 'Lettuce', 0.00),
(7, 24, 'Toppings', 'Cheese', 0.50),
(8, 22, 'Toppings', 'Lettuce', 0.00);

-- Insert transactions
INSERT INTO Transaction (order_id, transaction_type, amount, status, payment_provider, external_transaction_id, processed_at) VALUES
(1, 'AUTHORIZATION', 38.16, 'SUCCESS', 'Stripe', 'pi_1ABC123DEF456', '2024-11-01 18:31:00'),
(1, 'CAPTURE', 38.16, 'SUCCESS', 'Stripe', 'pi_1ABC123DEF456', '2024-11-01 19:00:00'),
(2, 'AUTHORIZATION', 32.88, 'SUCCESS', 'PayPal', 'PAYID-ABCD123', '2024-11-02 12:16:00'),
(2, 'CAPTURE', 32.88, 'SUCCESS', 'PayPal', 'PAYID-ABCD123', '2024-11-02 12:35:00'),
(4, 'AUTHORIZATION', 27.43, 'SUCCESS', 'Apple Pay', 'ap_1XYZ789', '2024-11-11 11:21:00'),
(4, 'CAPTURE', 27.43, 'SUCCESS', 'Apple Pay', 'ap_1XYZ789', '2024-11-11 11:25:00'),
(5, 'AUTHORIZATION', 31.22, 'SUCCESS', 'Stripe', 'pi_2DEF456GHI789', '2024-11-11 13:01:00'),
(5, 'CAPTURE', 31.22, 'SUCCESS', 'Stripe', 'pi_2DEF456GHI789', '2024-11-11 13:30:00');

-- Insert a sample price history record
INSERT INTO MenuItemPriceHistory (menu_item_id, old_price, new_price, changed_by) VALUES
(1, 17.99, 18.99, 6);

-- Insert sample audit log entries
INSERT INTO AuditLog (table_name, record_id, action, field_name, old_value, new_value, performed_by, ip_address) VALUES
('Order', 1, 'STATUS_CHANGE', 'status', 'CREATED', 'CONFIRMED', 1, '192.168.1.100'),
('Order', 1, 'STATUS_CHANGE', 'status', 'CONFIRMED', 'PREPARING', 6, '192.168.1.200'),
('Order', 1, 'STATUS_CHANGE', 'status', 'PREPARING', 'READY', 6, '192.168.1.200'),
('Order', 1, 'STATUS_CHANGE', 'status', 'READY', 'OUT_FOR_DELIVERY', 6, '192.168.1.200'),
('Order', 1, 'STATUS_CHANGE', 'status', 'OUT_FOR_DELIVERY', 'DELIVERED', 6, '192.168.1.200'),
('MenuItem', 1, 'UPDATE', 'price', '17.99', '18.99', 6, '192.168.1.200');

-- =============================================================================
-- DATA VALIDATION
-- =============================================================================

-- Verify data insertion
SELECT 'Accounts created:' as summary, COUNT(*) as count FROM Account
UNION ALL
SELECT 'Customers created:', COUNT(*) FROM Customer
UNION ALL
SELECT 'Restaurants created:', COUNT(*) FROM Restaurant
UNION ALL
SELECT 'Menu items created:', COUNT(*) FROM MenuItem
UNION ALL
SELECT 'Orders created:', COUNT(*) FROM `Order`
UNION ALL
SELECT 'Transactions created:', COUNT(*) FROM Transaction;

-- =============================================================================
-- END OF SCRIPT
-- =============================================================================

COMMIT;

-- Display completion message
SELECT 'GrubnGo database setup completed successfully!' as message;
