-- GrubnGo Database Schema
-- MySQL CREATE TABLE statements for all entities

-- Create Account table first (no dependencies)
CREATE TABLE Account (
    account_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('CUSTOMER', 'RESTAURANT') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Customer table (depends on Account)
CREATE TABLE Customer (
    customer_id BIGINT PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Account(account_id) ON DELETE CASCADE
);

-- Create Restaurant table (depends on Account)
CREATE TABLE Restaurant (
    restaurant_id BIGINT PRIMARY KEY,
    restaurant_name VARCHAR(255) NOT NULL,
    is_open TINYINT(1) DEFAULT 1,
    FOREIGN KEY (restaurant_id) REFERENCES Account(account_id) ON DELETE CASCADE
);

-- Create Menu table (depends on Restaurant)
CREATE TABLE Menu (
    menu_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE
);

-- Create MenuItem table (depends on Menu)
CREATE TABLE MenuItem (
    menu_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    menu_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    is_available TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id) ON DELETE CASCADE
);

-- Create Order table (depends on Customer and Restaurant)
CREATE TABLE `Order` (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    restaurant_id BIGINT NOT NULL,
    status ENUM('DRAFT', 'PENDING', 'COMPLETED', 'CANCELLED', 'ARCHIVED') DEFAULT 'DRAFT',
    submitted_at DATETIME NULL,
    completed_at DATETIME NULL,
    archived_at DATETIME NULL,
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE
);

-- Create OrderItem table (depends on Order and MenuItem)
CREATE TABLE OrderItem (
    order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    menu_item_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    notes TEXT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES MenuItem(menu_item_id) ON DELETE RESTRICT
);

-- Add indexes for better performance
CREATE INDEX idx_account_email ON Account(email);
CREATE INDEX idx_account_role ON Account(role);
CREATE INDEX idx_menu_restaurant ON Menu(restaurant_id);
CREATE INDEX idx_menuitem_menu ON MenuItem(menu_id);
CREATE INDEX idx_order_customer ON `Order`(customer_id);
CREATE INDEX idx_order_restaurant ON `Order`(restaurant_id);
CREATE INDEX idx_order_status ON `Order`(status);
CREATE INDEX idx_orderitem_order ON OrderItem(order_id);
CREATE INDEX idx_orderitem_menuitem ON OrderItem(menu_item_id);
