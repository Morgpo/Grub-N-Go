-- GrubnGo Database CRUD Operations

-- BASICALLY JUST PLACEHOLDERS TO COPY/PASTE INTO BACKEND

-- Use ? placeholders for prepared statements in your backend
-- Refactored to support all Business Rules and new table structure

-- ========================================
-- ACCOUNT TABLE CRUD OPERATIONS (BR-001 to BR-005)
-- ========================================

-- CREATE Account with audit trail (BR-005)
INSERT INTO Account (email, password_hash, role, status, created_by) 
VALUES (?, ?, ?, 'ACTIVE', ?);

-- READ Account operations
-- Get account by ID
SELECT * FROM Account WHERE account_id = ?;

-- Get account by email
SELECT * FROM Account WHERE email = ?;

-- Get account by role
SELECT * FROM Account WHERE role = ?;

-- Get active accounts only (BR-003)
SELECT * FROM Account WHERE status = 'ACTIVE';

-- Get all accounts by role and status
SELECT * FROM Account WHERE role = ? AND status = ?;

-- Get all accounts with pagination
SELECT * FROM Account 
ORDER BY created_at DESC 
LIMIT ? OFFSET ?;

-- UPDATE Account
UPDATE Account 
SET email = ?, password_hash = ?, role = ?, status = ?, updated_at = CURRENT_TIMESTAMP 
WHERE account_id = ?;

-- Update password only
UPDATE Account 
SET password_hash = ?, updated_at = CURRENT_TIMESTAMP 
WHERE account_id = ?;

-- Update account status (BR-003)
UPDATE Account 
SET status = ?, updated_at = CURRENT_TIMESTAMP 
WHERE account_id = ?;

-- Record failed login attempt (BR-004)
UPDATE Account 
SET failed_login_attempts = failed_login_attempts + 1, 
    last_login_attempt = CURRENT_TIMESTAMP 
WHERE account_id = ?;

-- Reset failed login attempts (BR-004)
UPDATE Account 
SET failed_login_attempts = 0, 
    last_login_attempt = CURRENT_TIMESTAMP 
WHERE account_id = ?;

-- DELETE Account (will cascade to Customer/Restaurant)
DELETE FROM Account WHERE account_id = ?;

-- ========================================
-- CUSTOMER TABLE CRUD OPERATIONS (BR-006 to BR-009)
-- ========================================

-- CREATE Customer (account_id should already exist)
INSERT INTO Customer (customer_id, customer_name, phone) 
VALUES (?, ?, ?);

-- READ Customer operations
-- Get customer by ID with account info
SELECT c.*, a.email, a.status, a.created_at, a.updated_at 
FROM Customer c 
JOIN Account a ON c.customer_id = a.account_id 
WHERE c.customer_id = ?;

-- Get customer by email
SELECT c.*, a.email, a.status, a.created_at, a.updated_at 
FROM Customer c 
JOIN Account a ON c.customer_id = a.account_id 
WHERE a.email = ?;

-- Get all active customers
SELECT c.*, a.email, a.status, a.created_at, a.updated_at 
FROM Customer c 
JOIN Account a ON c.customer_id = a.account_id 
WHERE a.status = 'ACTIVE'
ORDER BY c.customer_name;

-- Get all customers with pagination
SELECT c.*, a.email, a.status, a.created_at, a.updated_at 
FROM Customer c 
JOIN Account a ON c.customer_id = a.account_id 
ORDER BY c.customer_name
LIMIT ? OFFSET ?;

-- UPDATE Customer
UPDATE Customer 
SET customer_name = ?, phone = ? 
WHERE customer_id = ?;

-- DELETE Customer
DELETE FROM Customer WHERE customer_id = ?;

-- ========================================
-- ADDRESS TABLE CRUD OPERATIONS (BR-007)
-- ========================================

-- CREATE Address
INSERT INTO Address (customer_id, address_label, street_address, city, state, postal_code, country, is_default) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?);

-- READ Address operations
-- Get address by ID
SELECT * FROM Address WHERE address_id = ?;

-- Get all addresses for a customer
SELECT * FROM Address 
WHERE customer_id = ? 
ORDER BY is_default DESC, created_at DESC;

-- Get default address for a customer
SELECT * FROM Address 
WHERE customer_id = ? AND is_default = 1 
LIMIT 1;

-- UPDATE Address
UPDATE Address 
SET address_label = ?, street_address = ?, city = ?, state = ?, 
    postal_code = ?, country = ?, is_default = ?, updated_at = CURRENT_TIMESTAMP 
WHERE address_id = ?;

-- Set new default address (unset old default first)
UPDATE Address SET is_default = 0 WHERE customer_id = ?;
UPDATE Address SET is_default = 1, updated_at = CURRENT_TIMESTAMP WHERE address_id = ?;

-- DELETE Address
DELETE FROM Address WHERE address_id = ?;

-- ========================================
-- PAYMENTMETHOD TABLE CRUD OPERATIONS (BR-008, BR-037)
-- ========================================

-- CREATE PaymentMethod
INSERT INTO PaymentMethod (customer_id, payment_type, payment_token, card_last_four, card_brand, expiry_month, expiry_year, is_default) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?);

-- READ PaymentMethod operations
-- Get payment method by ID
SELECT * FROM PaymentMethod WHERE payment_method_id = ?;

-- Get all payment methods for a customer
SELECT * FROM PaymentMethod 
WHERE customer_id = ? 
ORDER BY is_default DESC, created_at DESC;

-- Get default payment method for a customer
SELECT * FROM PaymentMethod 
WHERE customer_id = ? AND is_default = 1 
LIMIT 1;

-- UPDATE PaymentMethod
UPDATE PaymentMethod 
SET expiry_month = ?, expiry_year = ?, is_default = ?, updated_at = CURRENT_TIMESTAMP 
WHERE payment_method_id = ?;

-- Set new default payment method (unset old default first)
UPDATE PaymentMethod SET is_default = 0 WHERE customer_id = ?;
UPDATE PaymentMethod SET is_default = 1, updated_at = CURRENT_TIMESTAMP WHERE payment_method_id = ?;

-- DELETE PaymentMethod
DELETE FROM PaymentMethod WHERE payment_method_id = ?;

-- ========================================
-- RESTAURANT TABLE CRUD OPERATIONS (BR-010 to BR-013)
-- ========================================

-- CREATE Restaurant (account_id should already exist)
INSERT INTO Restaurant (restaurant_id, restaurant_name, contact_phone, contact_email, operating_status, 
                        street_address, city, state, postal_code, country, latitude, longitude) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- READ Restaurant operations
-- Get restaurant by ID with full info
SELECT r.*, a.email, a.status, a.created_at, a.updated_at 
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
WHERE r.restaurant_id = ?;

-- Get restaurant by email
SELECT r.*, a.email, a.status, a.created_at, a.updated_at 
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
WHERE a.email = ?;

-- Get all restaurants
SELECT r.*, a.email, a.status, a.created_at, a.updated_at 
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
ORDER BY r.restaurant_name;

-- Get open restaurants only (BR-012)
SELECT r.*, a.email, a.status, a.created_at, a.updated_at 
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
WHERE r.operating_status = 'OPEN' AND a.status = 'ACTIVE'
ORDER BY r.restaurant_name;

-- Get restaurants by location (BR-013)
SELECT r.*, a.email, a.status 
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
WHERE r.city = ? AND r.state = ? AND a.status = 'ACTIVE'
ORDER BY r.restaurant_name;

-- Get restaurants within radius (using Haversine formula)
SELECT r.*, a.email, a.status,
    (6371 * acos(cos(radians(?)) * cos(radians(r.latitude)) * 
    cos(radians(r.longitude) - radians(?)) + 
    sin(radians(?)) * sin(radians(r.latitude)))) AS distance_km
FROM Restaurant r 
JOIN Account a ON r.restaurant_id = a.account_id 
WHERE r.latitude IS NOT NULL AND r.longitude IS NOT NULL
  AND a.status = 'ACTIVE'
HAVING distance_km <= ?
ORDER BY distance_km;

-- UPDATE Restaurant
UPDATE Restaurant 
SET restaurant_name = ?, contact_phone = ?, contact_email = ?, operating_status = ?,
    street_address = ?, city = ?, state = ?, postal_code = ?, country = ?,
    latitude = ?, longitude = ?
WHERE restaurant_id = ?;

-- Update restaurant operating status (BR-012)
UPDATE Restaurant 
SET operating_status = ? 
WHERE restaurant_id = ?;

-- Update restaurant location only
UPDATE Restaurant 
SET street_address = ?, city = ?, state = ?, postal_code = ?, country = ?,
    latitude = ?, longitude = ?
WHERE restaurant_id = ?;

-- DELETE Restaurant
DELETE FROM Restaurant WHERE restaurant_id = ?;

-- ========================================
-- BUSINESSHOURS TABLE CRUD OPERATIONS (BR-012)
-- ========================================

-- CREATE BusinessHours
INSERT INTO BusinessHours (restaurant_id, day_of_week, open_time, close_time, is_closed) 
VALUES (?, ?, ?, ?, ?);

-- READ BusinessHours operations
-- Get business hours by ID
SELECT * FROM BusinessHours WHERE business_hours_id = ?;

-- Get all business hours for a restaurant
SELECT * FROM BusinessHours 
WHERE restaurant_id = ? 
ORDER BY FIELD(day_of_week, 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');

-- Get business hours for specific day
SELECT * FROM BusinessHours 
WHERE restaurant_id = ? AND day_of_week = ?;

-- Check if restaurant is open now
SELECT bh.*, 
       CASE 
           WHEN bh.is_closed = 1 THEN 0
           WHEN CURTIME() BETWEEN bh.open_time AND bh.close_time THEN 1
           ELSE 0
       END AS is_currently_open
FROM BusinessHours bh
WHERE bh.restaurant_id = ? 
  AND bh.day_of_week = UPPER(DATE_FORMAT(NOW(), '%W'));

-- UPDATE BusinessHours
UPDATE BusinessHours 
SET open_time = ?, close_time = ?, is_closed = ? 
WHERE business_hours_id = ?;

-- Toggle closed status for a day
UPDATE BusinessHours 
SET is_closed = NOT is_closed 
WHERE business_hours_id = ?;

-- DELETE BusinessHours
DELETE FROM BusinessHours WHERE business_hours_id = ?;

-- Delete all business hours for a restaurant
DELETE FROM BusinessHours WHERE restaurant_id = ?;

-- ========================================
-- MENU TABLE CRUD OPERATIONS (BR-014, BR-015)
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

-- Get active menus for a restaurant (BR-015)
SELECT * FROM Menu 
WHERE restaurant_id = ? AND is_active = 1 
ORDER BY name;

-- Get menus with item counts
SELECT m.*, COUNT(mi.menu_item_id) as item_count
FROM Menu m
LEFT JOIN MenuItem mi ON m.menu_id = mi.menu_id
WHERE m.restaurant_id = ?
GROUP BY m.menu_id, m.restaurant_id, m.name, m.is_active, m.created_at, m.updated_at
ORDER BY m.name;

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
-- MENUITEM TABLE CRUD OPERATIONS (BR-016 to BR-019)
-- ========================================

-- CREATE MenuItem
INSERT INTO MenuItem (menu_id, name, description, price, is_available, available_from, available_until) 
VALUES (?, ?, ?, ?, ?, ?, ?);

-- READ MenuItem operations
-- Get menu item by ID with modifiers
SELECT mi.*, m.name as menu_name, m.restaurant_id 
FROM MenuItem mi 
JOIN Menu m ON mi.menu_id = m.menu_id 
WHERE mi.menu_item_id = ?;

-- Get all menu items for a menu
SELECT * FROM MenuItem 
WHERE menu_id = ? 
ORDER BY name;

-- Get available menu items for a menu (BR-17)
SELECT * FROM MenuItem 
WHERE menu_id = ? AND is_available = 1 
ORDER BY name;

-- Get available menu items considering time restrictions (BR-017)
SELECT * FROM MenuItem 
WHERE menu_id = ? 
  AND is_available = 1
  AND (available_from IS NULL OR CURTIME() >= available_from)
  AND (available_until IS NULL OR CURTIME() <= available_until)
ORDER BY name;

-- Get all menu items for a restaurant
SELECT mi.*, m.name as menu_name, m.is_active as menu_is_active
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

-- Get menu item with all modifiers and options
SELECT mi.*,
       mod.modifier_id, mod.modifier_name, mod.min_selections, mod.max_selections, mod.is_required,
       mo.modifier_option_id, mo.option_name, mo.price_delta, mo.is_available as option_is_available
FROM MenuItem mi
LEFT JOIN Modifier mod ON mi.menu_item_id = mod.menu_item_id
LEFT JOIN ModifierOption mo ON mod.modifier_id = mo.modifier_id
WHERE mi.menu_item_id = ?
ORDER BY mod.modifier_id, mo.modifier_option_id;

-- UPDATE MenuItem
UPDATE MenuItem 
SET name = ?, description = ?, price = ?, is_available = ?, 
    available_from = ?, available_until = ?, updated_at = CURRENT_TIMESTAMP 
WHERE menu_item_id = ?;

-- Update price only (BR-033: will trigger price history)
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
-- MENUITEM PRICE HISTORY OPERATIONS (BR-033)
-- ========================================

-- CREATE Price History Record (trigger this when price changes)
INSERT INTO MenuItemPriceHistory (menu_item_id, old_price, new_price, changed_by) 
VALUES (?, ?, ?, ?);

-- READ Price History
-- Get price history for a menu item
SELECT * FROM MenuItemPriceHistory 
WHERE menu_item_id = ? 
ORDER BY changed_at DESC;

-- Get recent price changes across all items
SELECT mph.*, mi.name as item_name, m.name as menu_name
FROM MenuItemPriceHistory mph
JOIN MenuItem mi ON mph.menu_item_id = mi.menu_item_id
JOIN Menu m ON mi.menu_id = m.menu_id
WHERE m.restaurant_id = ?
ORDER BY mph.changed_at DESC
LIMIT ?;

-- ========================================
-- MODIFIER TABLE CRUD OPERATIONS (BR-020)
-- ========================================

-- CREATE Modifier
INSERT INTO Modifier (menu_item_id, modifier_name, min_selections, max_selections, is_required) 
VALUES (?, ?, ?, ?, ?);

-- READ Modifier operations
-- Get modifier by ID
SELECT * FROM Modifier WHERE modifier_id = ?;

-- Get all modifiers for a menu item
SELECT * FROM Modifier 
WHERE menu_item_id = ? 
ORDER BY is_required DESC, modifier_name;

-- Get modifier with all options
SELECT mod.*, mo.modifier_option_id, mo.option_name, mo.price_delta, mo.is_available
FROM Modifier mod
LEFT JOIN ModifierOption mo ON mod.modifier_id = mo.modifier_id
WHERE mod.modifier_id = ?
ORDER BY mo.option_name;

-- UPDATE Modifier
UPDATE Modifier 
SET modifier_name = ?, min_selections = ?, max_selections = ?, is_required = ? 
WHERE modifier_id = ?;

-- DELETE Modifier
DELETE FROM Modifier WHERE modifier_id = ?;

-- ========================================
-- MODIFIEROPTION TABLE CRUD OPERATIONS (BR-020)
-- ========================================

-- CREATE ModifierOption
INSERT INTO ModifierOption (modifier_id, option_name, price_delta, is_available) 
VALUES (?, ?, ?, ?);

-- READ ModifierOption operations
-- Get modifier option by ID
SELECT * FROM ModifierOption WHERE modifier_option_id = ?;

-- Get all options for a modifier
SELECT * FROM ModifierOption 
WHERE modifier_id = ? 
ORDER BY option_name;

-- Get available options for a modifier
SELECT * FROM ModifierOption 
WHERE modifier_id = ? AND is_available = 1 
ORDER BY option_name;

-- UPDATE ModifierOption
UPDATE ModifierOption 
SET option_name = ?, price_delta = ?, is_available = ? 
WHERE modifier_option_id = ?;

-- Toggle option availability
UPDATE ModifierOption 
SET is_available = NOT is_available 
WHERE modifier_option_id = ?;

-- DELETE ModifierOption
DELETE FROM ModifierOption WHERE modifier_option_id = ?;

-- ========================================
-- ORDER TABLE CRUD OPERATIONS (BR-021 to BR-032)
-- ========================================

-- CREATE Order (BR-021, BR-022, BR-023, BR-026)
INSERT INTO `Order` (customer_id, restaurant_id, delivery_address_id, 
                     delivery_street, delivery_city, delivery_state, delivery_postal_code, delivery_country,
                     status, subtotal, tax, tax_rate, delivery_fee, service_fee, tip, discount, total, 
                     payment_method_id) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- READ Order operations
-- Get order by ID with full details (BR-029)
SELECT o.*, 
       c.customer_name, c.phone as customer_phone,
       r.restaurant_name, r.contact_phone as restaurant_phone,
       pm.payment_type, pm.card_last_four
FROM `Order` o 
JOIN Customer c ON o.customer_id = c.customer_id 
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
LEFT JOIN PaymentMethod pm ON o.payment_method_id = pm.payment_method_id
WHERE o.order_id = ?;

-- Get all orders for a customer
SELECT o.*, r.restaurant_name, r.operating_status
FROM `Order` o 
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
WHERE o.customer_id = ? 
ORDER BY o.created_at DESC;

-- Get all orders for a restaurant
SELECT o.*, c.customer_name, c.phone as customer_phone
FROM `Order` o 
JOIN Customer c ON o.customer_id = c.customer_id 
WHERE o.restaurant_id = ? 
ORDER BY o.created_at DESC;

-- Get orders by status (BR-030)
SELECT o.*, c.customer_name, r.restaurant_name 
FROM `Order` o 
JOIN Customer c ON o.customer_id = c.customer_id 
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
WHERE o.status = ? 
ORDER BY o.created_at DESC;

-- Get active orders for a customer (not completed/cancelled)
SELECT o.*, r.restaurant_name 
FROM `Order` o 
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
WHERE o.customer_id = ? 
  AND o.status NOT IN ('DELIVERED', 'CANCELLED', 'FAILED')
ORDER BY o.created_at DESC;

-- Get pending/confirmed orders for a restaurant (BR-030)
SELECT o.*, c.customer_name, c.phone as customer_phone
FROM `Order` o 
JOIN Customer c ON o.customer_id = c.customer_id 
WHERE o.restaurant_id = ? 
  AND o.status IN ('CONFIRMED', 'PREPARING')
ORDER BY o.confirmed_at ASC;

-- Get orders within date range
SELECT o.*, c.customer_name, r.restaurant_name 
FROM `Order` o 
JOIN Customer c ON o.customer_id = c.customer_id 
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
WHERE o.created_at BETWEEN ? AND ?
ORDER BY o.created_at DESC;

-- UPDATE Order
UPDATE `Order` 
SET status = ?, subtotal = ?, tax = ?, tax_rate = ?, 
    delivery_fee = ?, service_fee = ?, tip = ?, discount = ?, total = ?,
    updated_at = CURRENT_TIMESTAMP 
WHERE order_id = ?;

-- Update order status with appropriate timestamp (BR-029, BR-030, BR-031)
UPDATE `Order` 
SET status = ?, 
    confirmed_at = CASE WHEN ? = 'CONFIRMED' THEN CURRENT_TIMESTAMP ELSE confirmed_at END,
    prepared_at = CASE WHEN ? = 'PREPARING' THEN CURRENT_TIMESTAMP ELSE prepared_at END,
    ready_at = CASE WHEN ? = 'READY' THEN CURRENT_TIMESTAMP ELSE ready_at END,
    picked_up_at = CASE WHEN ? = 'OUT_FOR_DELIVERY' THEN CURRENT_TIMESTAMP ELSE picked_up_at END,
    delivered_at = CASE WHEN ? = 'DELIVERED' THEN CURRENT_TIMESTAMP ELSE delivered_at END,
    cancelled_at = CASE WHEN ? = 'CANCELLED' THEN CURRENT_TIMESTAMP ELSE cancelled_at END,
    updated_at = CURRENT_TIMESTAMP 
WHERE order_id = ?;

-- Update order totals (BR-026)
UPDATE `Order` 
SET subtotal = ?, tax = ?, tax_rate = ?, delivery_fee = ?, 
    service_fee = ?, tip = ?, discount = ?, total = ?, 
    updated_at = CURRENT_TIMESTAMP 
WHERE order_id = ?;

-- Update payment status
UPDATE `Order` 
SET is_paid = ?, updated_at = CURRENT_TIMESTAMP 
WHERE order_id = ?;

-- Cancel order (BR-031)
UPDATE `Order` 
SET status = 'CANCELLED', cancelled_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP 
WHERE order_id = ?;

-- DELETE Order (typically shouldn't delete, use status instead)
DELETE FROM `Order` WHERE order_id = ?;

-- ========================================
-- ORDERITEM TABLE CRUD OPERATIONS (BR-024 to BR-028)
-- ========================================

-- CREATE OrderItem with snapshot (BR-018, BR-024, BR-025)
INSERT INTO OrderItem (order_id, menu_item_id, item_name, item_description, quantity, unit_price, notes) 
VALUES (?, ?, ?, ?, ?, ?, ?);

-- READ OrderItem operations
-- Get order item by ID
SELECT oi.*, mi.name as current_item_name, mi.price as current_price
FROM OrderItem oi 
LEFT JOIN MenuItem mi ON oi.menu_item_id = mi.menu_item_id 
WHERE oi.order_item_id = ?;

-- Get all order items for an order with modifiers
SELECT oi.*,
       oim.order_item_modifier_id, oim.modifier_name, oim.option_name, oim.price_delta
FROM OrderItem oi 
LEFT JOIN OrderItemModifier oim ON oi.order_item_id = oim.order_item_id
WHERE oi.order_id = ? 
ORDER BY oi.order_item_id, oim.order_item_modifier_id;

-- Get order items with calculated line totals
SELECT oi.order_item_id, oi.order_id, oi.item_name, oi.item_description,
       oi.quantity, oi.unit_price, oi.notes,
       (oi.quantity * oi.unit_price) as line_subtotal,
       COALESCE(SUM(oim.price_delta * oi.quantity), 0) as modifier_total,
       (oi.quantity * oi.unit_price) + COALESCE(SUM(oim.price_delta * oi.quantity), 0) as line_total
FROM OrderItem oi
LEFT JOIN OrderItemModifier oim ON oi.order_item_id = oim.order_item_id
WHERE oi.order_id = ?
GROUP BY oi.order_item_id, oi.order_id, oi.item_name, oi.item_description, 
         oi.quantity, oi.unit_price, oi.notes
ORDER BY oi.order_item_id;

-- Get order items with full order and restaurant info
SELECT oi.*, 
       o.status as order_status,
       r.restaurant_name,
       c.customer_name
FROM OrderItem oi 
JOIN `Order` o ON oi.order_id = o.order_id 
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
JOIN Customer c ON o.customer_id = c.customer_id
WHERE oi.order_id = ?;

-- UPDATE OrderItem (only allowed if order not finalized - BR-027)
UPDATE OrderItem 
SET quantity = ?, unit_price = ?, notes = ? 
WHERE order_item_id = ? 
  AND EXISTS (SELECT 1 FROM `Order` WHERE order_id = OrderItem.order_id 
              AND status NOT IN ('DELIVERED', 'CANCELLED'));

-- Update quantity only (with finalization check)
UPDATE OrderItem 
SET quantity = ? 
WHERE order_item_id = ? 
  AND EXISTS (SELECT 1 FROM `Order` WHERE order_id = OrderItem.order_id 
              AND status NOT IN ('DELIVERED', 'CANCELLED'));

-- DELETE OrderItem (only if order not finalized)
DELETE FROM OrderItem 
WHERE order_item_id = ? 
  AND EXISTS (SELECT 1 FROM `Order` WHERE order_id = OrderItem.order_id 
              AND status NOT IN ('DELIVERED', 'CANCELLED'));

-- Delete all order items for an order (only if not finalized)
DELETE FROM OrderItem 
WHERE order_id = ? 
  AND EXISTS (SELECT 1 FROM `Order` WHERE order_id = ? 
              AND status NOT IN ('DELIVERED', 'CANCELLED'));

-- ========================================
-- ORDERITEMMODIFIER TABLE CRUD OPERATIONS (BR-020)
-- ========================================

-- CREATE OrderItemModifier with snapshot
INSERT INTO OrderItemModifier (order_item_id, modifier_option_id, modifier_name, option_name, price_delta) 
VALUES (?, ?, ?, ?, ?);

-- READ OrderItemModifier operations
-- Get all modifiers for an order item
SELECT * FROM OrderItemModifier 
WHERE order_item_id = ? 
ORDER BY modifier_name, option_name;

-- Get modifiers with current pricing info
SELECT oim.*, mo.price_delta as current_price_delta, mo.is_available
FROM OrderItemModifier oim
LEFT JOIN ModifierOption mo ON oim.modifier_option_id = mo.modifier_option_id
WHERE oim.order_item_id = ?;

-- UPDATE OrderItemModifier (only if order not finalized)
UPDATE OrderItemModifier 
SET price_delta = ? 
WHERE order_item_modifier_id = ? 
  AND EXISTS (SELECT 1 FROM OrderItem oi 
              JOIN `Order` o ON oi.order_id = o.order_id 
              WHERE oi.order_item_id = OrderItemModifier.order_item_id 
                AND o.status NOT IN ('DELIVERED', 'CANCELLED'));

-- DELETE OrderItemModifier (only if order not finalized)
DELETE FROM OrderItemModifier 
WHERE order_item_modifier_id = ? 
  AND EXISTS (SELECT 1 FROM OrderItem oi 
              JOIN `Order` o ON oi.order_id = o.order_id 
              WHERE oi.order_item_id = OrderItemModifier.order_item_id 
                AND o.status NOT IN ('DELIVERED', 'CANCELLED'));

-- ========================================
-- TRANSACTION TABLE CRUD OPERATIONS (BR-037, BR-038)
-- ========================================

-- CREATE Transaction
INSERT INTO Transaction (order_id, transaction_type, amount, status, payment_provider, external_transaction_id) 
VALUES (?, ?, ?, ?, ?, ?);

-- READ Transaction operations
-- Get transaction by ID
SELECT * FROM Transaction WHERE transaction_id = ?;

-- Get all transactions for an order
SELECT * FROM Transaction 
WHERE order_id = ? 
ORDER BY created_at DESC;

-- Get transactions by type and status
SELECT t.*, o.order_id, o.customer_id, o.restaurant_id
FROM Transaction t
JOIN `Order` o ON t.order_id = o.order_id
WHERE t.transaction_type = ? AND t.status = ?
ORDER BY t.created_at DESC;

-- Get pending transactions
SELECT * FROM Transaction 
WHERE status = 'PENDING' 
ORDER BY created_at ASC;

-- UPDATE Transaction
UPDATE Transaction 
SET status = ?, processed_at = CURRENT_TIMESTAMP, error_message = ? 
WHERE transaction_id = ?;

-- Mark transaction as successful
UPDATE Transaction 
SET status = 'SUCCESS', processed_at = CURRENT_TIMESTAMP 
WHERE transaction_id = ?;

-- Mark transaction as failed
UPDATE Transaction 
SET status = 'FAILED', processed_at = CURRENT_TIMESTAMP, error_message = ? 
WHERE transaction_id = ?;

-- ========================================
-- REFUND TABLE CRUD OPERATIONS (BR-032)
-- ========================================

-- CREATE Refund
INSERT INTO Refund (order_id, transaction_id, refund_amount, refund_reason, requested_by) 
VALUES (?, ?, ?, ?, ?);

-- READ Refund operations
-- Get refund by ID
SELECT * FROM Refund WHERE refund_id = ?;

-- Get all refunds for an order
SELECT * FROM Refund 
WHERE order_id = ? 
ORDER BY requested_at DESC;

-- Get refunds by status
SELECT r.*, o.customer_id, o.restaurant_id, c.customer_name, rest.restaurant_name
FROM Refund r
JOIN `Order` o ON r.order_id = o.order_id
JOIN Customer c ON o.customer_id = c.customer_id
JOIN Restaurant rest ON o.restaurant_id = rest.restaurant_id
WHERE r.status = ?
ORDER BY r.requested_at DESC;

-- Get pending refunds
SELECT r.*, o.customer_id, o.restaurant_id
FROM Refund r
JOIN `Order` o ON r.order_id = o.order_id
WHERE r.status = 'PENDING'
ORDER BY r.requested_at ASC;

-- UPDATE Refund
UPDATE Refund 
SET status = ?, processed_at = CURRENT_TIMESTAMP, transaction_id = ? 
WHERE refund_id = ?;

-- Mark refund as completed
UPDATE Refund 
SET status = 'COMPLETED', processed_at = CURRENT_TIMESTAMP 
WHERE refund_id = ?;

-- Mark refund as failed
UPDATE Refund 
SET status = 'FAILED', processed_at = CURRENT_TIMESTAMP 
WHERE refund_id = ?;

-- ========================================
-- AUDITLOG TABLE CRUD OPERATIONS (BR-005, BR-039)
-- ========================================

-- CREATE AuditLog entry
INSERT INTO AuditLog (table_name, record_id, action, field_name, old_value, new_value, performed_by, ip_address, user_agent) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);

-- READ AuditLog operations
-- Get audit logs for a specific record
SELECT * FROM AuditLog 
WHERE table_name = ? AND record_id = ? 
ORDER BY performed_at DESC;

-- Get recent audit logs
SELECT al.*, a.email as performed_by_email
FROM AuditLog al
LEFT JOIN Account a ON al.performed_by = a.account_id
ORDER BY al.performed_at DESC
LIMIT ?;

-- Get audit logs by action type
SELECT al.*, a.email as performed_by_email
FROM AuditLog al
LEFT JOIN Account a ON al.performed_by = a.account_id
WHERE al.action = ?
ORDER BY al.performed_at DESC;

-- Get audit logs by user
SELECT * FROM AuditLog 
WHERE performed_by = ? 
ORDER BY performed_at DESC;

-- Get audit logs within date range
SELECT al.*, a.email as performed_by_email
FROM AuditLog al
LEFT JOIN Account a ON al.performed_by = a.account_id
WHERE al.performed_at BETWEEN ? AND ?
ORDER BY al.performed_at DESC;

-- ========================================
-- UTILITY QUERIES FOR BACKEND (BR-026, BR-040)
-- ========================================

-- Get order total calculation with modifiers (BR-026)
SELECT oi.order_id,
       SUM(oi.quantity * oi.unit_price) as items_subtotal,
       SUM(COALESCE(
           (SELECT SUM(oim.price_delta * oi.quantity) 
            FROM OrderItemModifier oim 
            WHERE oim.order_item_id = oi.order_item_id), 
           0)) as modifiers_total,
       SUM(oi.quantity * oi.unit_price) + 
       SUM(COALESCE(
           (SELECT SUM(oim.price_delta * oi.quantity) 
            FROM OrderItemModifier oim 
            WHERE oim.order_item_id = oi.order_item_id), 
           0)) as calculated_subtotal
FROM OrderItem oi
WHERE oi.order_id = ? 
GROUP BY oi.order_id;

-- Verify order totals match calculations
SELECT o.order_id,
       o.subtotal as stored_subtotal,
       COALESCE(calc.calculated_subtotal, 0) as calculated_subtotal,
       o.total as stored_total,
       (COALESCE(calc.calculated_subtotal, 0) + o.tax + o.delivery_fee + o.service_fee + o.tip - o.discount) as calculated_total
FROM `Order` o
LEFT JOIN (
    SELECT oi.order_id,
           SUM(oi.quantity * oi.unit_price + COALESCE(
               (SELECT SUM(oim.price_delta * oi.quantity) 
                FROM OrderItemModifier oim 
                WHERE oim.order_item_id = oi.order_item_id), 
               0)) as calculated_subtotal
    FROM OrderItem oi
    GROUP BY oi.order_id
) calc ON o.order_id = calc.order_id
WHERE o.order_id = ?;

-- Get popular menu items (most ordered) (BR-040)
SELECT mi.menu_item_id, 
       mi.name, 
       mi.price,
       COUNT(DISTINCT oi.order_id) as order_count,
       SUM(oi.quantity) as total_quantity_sold,
       SUM(oi.quantity * oi.unit_price) as total_revenue
FROM MenuItem mi 
LEFT JOIN OrderItem oi ON mi.menu_item_id = oi.menu_item_id 
LEFT JOIN `Order` o ON oi.order_id = o.order_id
WHERE mi.menu_id IN (SELECT menu_id FROM Menu WHERE restaurant_id = ?)
  AND (o.status IS NULL OR o.status IN ('DELIVERED'))
GROUP BY mi.menu_item_id, mi.name, mi.price 
ORDER BY order_count DESC, total_quantity_sold DESC 
LIMIT ?;

-- Get customer order history summary (BR-040)
SELECT c.customer_id,
       c.customer_name,
       c.phone,
       COUNT(o.order_id) as total_orders,
       COUNT(CASE WHEN o.status = 'DELIVERED' THEN 1 END) as completed_orders,
       COUNT(CASE WHEN o.status = 'CANCELLED' THEN 1 END) as cancelled_orders,
       SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END) as total_spent,
       AVG(CASE WHEN o.status = 'DELIVERED' THEN o.total END) as average_order_value,
       MAX(o.created_at) as last_order_date
FROM Customer c 
LEFT JOIN `Order` o ON c.customer_id = o.customer_id 
WHERE c.customer_id = ?
GROUP BY c.customer_id, c.customer_name, c.phone;

-- Get restaurant revenue summary (BR-040)
SELECT r.restaurant_id,
       r.restaurant_name,
       COUNT(o.order_id) as total_orders,
       COUNT(CASE WHEN o.status = 'DELIVERED' THEN 1 END) as completed_orders,
       COUNT(CASE WHEN o.status = 'CANCELLED' THEN 1 END) as cancelled_orders,
       SUM(CASE WHEN o.status = 'DELIVERED' THEN o.subtotal ELSE 0 END) as gross_revenue,
       SUM(CASE WHEN o.status = 'DELIVERED' THEN o.tax ELSE 0 END) as total_tax_collected,
       SUM(CASE WHEN o.status = 'DELIVERED' THEN o.tip ELSE 0 END) as total_tips,
       SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END) as total_revenue,
       AVG(CASE WHEN o.status = 'DELIVERED' THEN o.total END) as average_order_value
FROM Restaurant r 
LEFT JOIN `Order` o ON r.restaurant_id = o.restaurant_id 
WHERE r.restaurant_id = ? 
GROUP BY r.restaurant_id, r.restaurant_name;

-- Get restaurant revenue summary for date range
SELECT r.restaurant_id,
       r.restaurant_name,
       DATE(o.created_at) as order_date,
       COUNT(o.order_id) as daily_orders,
       SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END) as daily_revenue
FROM Restaurant r 
LEFT JOIN `Order` o ON r.restaurant_id = o.restaurant_id 
WHERE r.restaurant_id = ? 
  AND o.created_at BETWEEN ? AND ?
GROUP BY r.restaurant_id, r.restaurant_name, DATE(o.created_at)
ORDER BY order_date DESC;

-- Get order fulfillment metrics (BR-029, BR-040)
SELECT 
    COUNT(*) as total_orders,
    AVG(TIMESTAMPDIFF(MINUTE, confirmed_at, prepared_at)) as avg_prep_time_minutes,
    AVG(TIMESTAMPDIFF(MINUTE, confirmed_at, ready_at)) as avg_ready_time_minutes,
    AVG(TIMESTAMPDIFF(MINUTE, confirmed_at, delivered_at)) as avg_fulfillment_time_minutes,
    COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) as cancelled_count,
    COUNT(CASE WHEN status = 'DELIVERED' THEN 1 END) as delivered_count
FROM `Order`
WHERE restaurant_id = ?
  AND confirmed_at IS NOT NULL
  AND created_at BETWEEN ? AND ?;

-- Get active order status overview for restaurant
SELECT status, COUNT(*) as count
FROM `Order`
WHERE restaurant_id = ?
  AND status NOT IN ('DELIVERED', 'CANCELLED', 'FAILED')
GROUP BY status
ORDER BY FIELD(status, 'CREATED', 'CONFIRMED', 'PREPARING', 'READY', 'OUT_FOR_DELIVERY');

-- Check business rule constraints before operations
-- Validate menu item uniqueness within menu (BR-019)
SELECT COUNT(*) as count 
FROM MenuItem 
WHERE menu_id = ? AND name = ? AND menu_item_id != ?;

-- Validate order has items (BR-023)
SELECT COUNT(*) as item_count 
FROM OrderItem 
WHERE order_id = ?;

-- Validate account can perform operations (BR-003)
SELECT status 
FROM Account 
WHERE account_id = ?;

-- Check if restaurant is accepting orders (BR-012)
SELECT r.operating_status,
       CASE 
           WHEN r.operating_status != 'OPEN' THEN 0
           WHEN NOT EXISTS (
               SELECT 1 FROM BusinessHours bh
               WHERE bh.restaurant_id = r.restaurant_id
                 AND bh.day_of_week = UPPER(DATE_FORMAT(NOW(), '%W'))
                 AND bh.is_closed = 0
                 AND CURTIME() BETWEEN bh.open_time AND bh.close_time
           ) THEN 0
           ELSE 1
       END as can_accept_orders
FROM Restaurant r
WHERE r.restaurant_id = ?;
