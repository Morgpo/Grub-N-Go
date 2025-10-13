-- GrubnGo Database CRUD Operations
-- Parameterized SQL statements for backend automation
-- Use ? placeholders for prepared statements in your backend

-- ========================================
-- ACCOUNT TABLE CRUD OPERATIONS
-- ========================================

-- CREATE Account
INSERT INTO Account (email, password_hash, role) 
VALUES (?, ?, ?);

-- READ Account operations
-- Get account by ID
SELECT * FROM Account WHERE account_id = ?;

-- Get account by email
SELECT * FROM Account WHERE email = ?;

-- Get all accounts by role
SELECT * FROM Account WHERE role = ?;

-- Get all accounts with pagination
SELECT * FROM Account 
ORDER BY created_at DESC 
LIMIT ? OFFSET ?;

-- UPDATE Account
UPDATE Account 
SET email = ?, password_hash = ?, role = ?, updated_at = CURRENT_TIMESTAMP 
WHERE account_id = ?;

-- Update password only
UPDATE Account 
SET password_hash = ?, updated_at = CURRENT_TIMESTAMP 
WHERE account_id = ?;

-- DELETE Account (will cascade to Customer/Restaurant)
DELETE FROM Account WHERE account_id = ?;

-- ========================================
-- CUSTOMER TABLE CRUD OPERATIONS
-- ========================================

-- CREATE Customer (account_id should already exist)
INSERT INTO Customer (customer_id, customer_name) 
VALUES (?, ?);

-- READ Customer operations
-- Get customer by ID
SELECT c.*, a.email, a.created_at, a.updated_at 
FROM Customer c 
JOIN Account a ON c.customer_id = a.account_id 
WHERE c.customer_id = ?;

-- Get customer by email
SELECT c.*, a.email, a.created_at, a.updated_at 
FROM Customer c 
JOIN Account a ON c.customer_id = a.account_id 
WHERE a.email = ?;

-- Get all customers
SELECT c.*, a.email, a.created_at, a.updated_at 
FROM Customer c 
JOIN Account a ON c.customer_id = a.account_id 
ORDER BY c.customer_name;

-- UPDATE Customer
UPDATE Customer 
SET customer_name = ? 
WHERE customer_id = ?;

-- DELETE Customer
DELETE FROM Customer WHERE customer_id = ?;

-- ========================================
-- RESTAURANT TABLE CRUD OPERATIONS
-- ========================================

-- CREATE Restaurant (account_id should already exist)
INSERT INTO Restaurant (restaurant_id, restaurant_name, is_open) 
VALUES (?, ?, ?);

-- READ Restaurant operations
-- Get restaurant by ID
SELECT r.*, a.email, a.created_at, a.updated_at 
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
WHERE r.restaurant_id = ?;

-- Get restaurant by email
SELECT r.*, a.email, a.created_at, a.updated_at 
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
WHERE a.email = ?;

-- Get all restaurants
SELECT r.*, a.email, a.created_at, a.updated_at 
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
ORDER BY r.restaurant_name;

-- Get open restaurants only
SELECT r.*, a.email, a.created_at, a.updated_at 
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
WHERE r.is_open = 1 
ORDER BY r.restaurant_name;

-- UPDATE Restaurant
UPDATE Restaurant 
SET restaurant_name = ?, is_open = ? 
WHERE restaurant_id = ?;

-- Toggle restaurant open/closed status
UPDATE Restaurant 
SET is_open = NOT is_open 
WHERE restaurant_id = ?;

-- DELETE Restaurant
DELETE FROM Restaurant WHERE restaurant_id = ?;

-- ========================================
-- MENU TABLE CRUD OPERATIONS
-- ========================================

-- CREATE Menu
INSERT INTO Menu (restaurant_id, name, is_active) 
VALUES (?, ?, ?);

-- READ Menu operations
-- Get menu by ID
SELECT * FROM Menu WHERE menu_id = ?;

-- Get all menus for a restaurant
SELECT * FROM Menu 
WHERE restaurant_id = ? 
ORDER BY created_at DESC;

-- Get active menus for a restaurant
SELECT * FROM Menu 
WHERE restaurant_id = ? AND is_active = 1 
ORDER BY name;

-- UPDATE Menu
UPDATE Menu 
SET name = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP 
WHERE menu_id = ?;

-- Toggle menu active status
UPDATE Menu 
SET is_active = NOT is_active, updated_at = CURRENT_TIMESTAMP 
WHERE menu_id = ?;

-- DELETE Menu
DELETE FROM Menu WHERE menu_id = ?;

-- ========================================
-- MENUITEM TABLE CRUD OPERATIONS
-- ========================================

-- CREATE MenuItem
INSERT INTO MenuItem (menu_id, name, description, price, is_available) 
VALUES (?, ?, ?, ?, ?);

-- READ MenuItem operations
-- Get menu item by ID
SELECT mi.*, m.name as menu_name, m.restaurant_id 
FROM MenuItem mi 
JOIN Menu m ON mi.menu_id = m.menu_id 
WHERE mi.menu_item_id = ?;

-- Get all menu items for a menu
SELECT * FROM MenuItem 
WHERE menu_id = ? 
ORDER BY name;

-- Get available menu items for a menu
SELECT * FROM MenuItem 
WHERE menu_id = ? AND is_available = 1 
ORDER BY name;

-- Get all menu items for a restaurant
SELECT mi.*, m.name as menu_name 
FROM MenuItem mi 
JOIN Menu m ON mi.menu_id = m.menu_id 
WHERE m.restaurant_id = ? 
ORDER BY m.name, mi.name;

-- Search menu items by name
SELECT mi.*, m.name as menu_name, m.restaurant_id 
FROM MenuItem mi 
JOIN Menu m ON mi.menu_id = m.menu_id 
WHERE mi.name LIKE ? 
ORDER BY mi.name;

-- UPDATE MenuItem
UPDATE MenuItem 
SET name = ?, description = ?, price = ?, is_available = ?, updated_at = CURRENT_TIMESTAMP 
WHERE menu_item_id = ?;

-- Update price only
UPDATE MenuItem 
SET price = ?, updated_at = CURRENT_TIMESTAMP 
WHERE menu_item_id = ?;

-- Toggle availability
UPDATE MenuItem 
SET is_available = NOT is_available, updated_at = CURRENT_TIMESTAMP 
WHERE menu_item_id = ?;

-- DELETE MenuItem
DELETE FROM MenuItem WHERE menu_item_id = ?;

-- ========================================
-- ORDER TABLE CRUD OPERATIONS
-- ========================================

-- CREATE Order
INSERT INTO `Order` (customer_id, restaurant_id, status, subtotal, tax, total) 
VALUES (?, ?, ?, ?, ?, ?);

-- READ Order operations
-- Get order by ID with customer and restaurant info
SELECT o.*, 
       c.customer_name, 
       r.restaurant_name 
FROM `Order` o 
JOIN Customer c ON o.customer_id = c.customer_id 
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
WHERE o.order_id = ?;

-- Get all orders for a customer
SELECT o.*, r.restaurant_name 
FROM `Order` o 
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
WHERE o.customer_id = ? 
ORDER BY o.created_at DESC;

-- Get all orders for a restaurant
SELECT o.*, c.customer_name 
FROM `Order` o 
JOIN Customer c ON o.customer_id = c.customer_id 
WHERE o.restaurant_id = ? 
ORDER BY o.created_at DESC;

-- Get orders by status
SELECT o.*, c.customer_name, r.restaurant_name 
FROM `Order` o 
JOIN Customer c ON o.customer_id = c.customer_id 
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
WHERE o.status = ? 
ORDER BY o.created_at DESC;

-- Get pending orders for a restaurant
SELECT o.*, c.customer_name 
FROM `Order` o 
JOIN Customer c ON o.customer_id = c.customer_id 
WHERE o.restaurant_id = ? AND o.status = 'PENDING' 
ORDER BY o.submitted_at ASC;

-- UPDATE Order
UPDATE `Order` 
SET status = ?, subtotal = ?, tax = ?, total = ?, updated_at = CURRENT_TIMESTAMP 
WHERE order_id = ?;

-- Update order status with timestamp
UPDATE `Order` 
SET status = ?, 
    submitted_at = CASE WHEN ? = 'PENDING' THEN CURRENT_TIMESTAMP ELSE submitted_at END,
    completed_at = CASE WHEN ? = 'COMPLETED' THEN CURRENT_TIMESTAMP ELSE completed_at END,
    archived_at = CASE WHEN ? = 'ARCHIVED' THEN CURRENT_TIMESTAMP ELSE archived_at END,
    updated_at = CURRENT_TIMESTAMP 
WHERE order_id = ?;

-- Update order totals
UPDATE `Order` 
SET subtotal = ?, tax = ?, total = ?, updated_at = CURRENT_TIMESTAMP 
WHERE order_id = ?;

-- DELETE Order
DELETE FROM `Order` WHERE order_id = ?;

-- ========================================
-- ORDERITEM TABLE CRUD OPERATIONS
-- ========================================

-- CREATE OrderItem
INSERT INTO OrderItem (order_id, menu_item_id, quantity, unit_price, notes) 
VALUES (?, ?, ?, ?, ?);

-- READ OrderItem operations
-- Get order item by ID
SELECT oi.*, mi.name as item_name, mi.description 
FROM OrderItem oi 
JOIN MenuItem mi ON oi.menu_item_id = mi.menu_item_id 
WHERE oi.order_item_id = ?;

-- Get all order items for an order
SELECT oi.*, mi.name as item_name, mi.description 
FROM OrderItem oi 
JOIN MenuItem mi ON oi.menu_item_id = mi.menu_item_id 
WHERE oi.order_id = ? 
ORDER BY oi.order_item_id;

-- Get order items with full order and restaurant info
SELECT oi.*, 
       mi.name as item_name, 
       mi.description,
       o.status as order_status,
       r.restaurant_name 
FROM OrderItem oi 
JOIN MenuItem mi ON oi.menu_item_id = mi.menu_item_id 
JOIN Menu m ON mi.menu_id = m.menu_id 
JOIN Restaurant r ON m.restaurant_id = r.restaurant_id 
JOIN `Order` o ON oi.order_id = o.order_id 
WHERE oi.order_id = ?;

-- UPDATE OrderItem
UPDATE OrderItem 
SET quantity = ?, unit_price = ?, notes = ? 
WHERE order_item_id = ?;

-- Update quantity only
UPDATE OrderItem 
SET quantity = ? 
WHERE order_item_id = ?;

-- DELETE OrderItem
DELETE FROM OrderItem WHERE order_item_id = ?;

-- Delete all order items for an order
DELETE FROM OrderItem WHERE order_id = ?;

-- ========================================
-- UTILITY QUERIES FOR BACKEND
-- ========================================

-- Get order total calculation
SELECT order_id,
       SUM(quantity * unit_price) as calculated_subtotal
FROM OrderItem 
WHERE order_id = ? 
GROUP BY order_id;

-- Get popular menu items (most ordered)
SELECT mi.menu_item_id, 
       mi.name, 
       mi.price,
       COUNT(oi.order_item_id) as order_count,
       SUM(oi.quantity) as total_quantity_sold
FROM MenuItem mi 
LEFT JOIN OrderItem oi ON mi.menu_item_id = oi.menu_item_id 
WHERE mi.menu_id IN (SELECT menu_id FROM Menu WHERE restaurant_id = ?)
GROUP BY mi.menu_item_id, mi.name, mi.price 
ORDER BY order_count DESC, total_quantity_sold DESC 
LIMIT ?;

-- Get customer order history summary
SELECT c.customer_id,
       c.customer_name,
       COUNT(o.order_id) as total_orders,
       SUM(o.total) as total_spent,
       MAX(o.created_at) as last_order_date
FROM Customer c 
LEFT JOIN `Order` o ON c.customer_id = o.customer_id 
WHERE c.customer_id = ?
GROUP BY c.customer_id, c.customer_name;

-- Get restaurant revenue summary
SELECT r.restaurant_id,
       r.restaurant_name,
       COUNT(o.order_id) as total_orders,
       SUM(o.total) as total_revenue,
       AVG(o.total) as average_order_value
FROM Restaurant r 
LEFT JOIN `Order` o ON r.restaurant_id = o.restaurant_id 
WHERE r.restaurant_id = ? 
  AND o.status IN ('COMPLETED', 'ARCHIVED')
GROUP BY r.restaurant_id, r.restaurant_name;
