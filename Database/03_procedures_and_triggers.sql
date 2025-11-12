-- =============================================================================
-- GrubnGo Database: Stored Procedures and Triggers
-- =============================================================================
-- This file contains one trigger procedure and one stored procedure with
-- comprehensive documentation explaining their purpose and functionality.
-- 
-- Author: Database Team
-- Date: November 2025
-- Version: 1.0
-- =============================================================================

USE GrubnGo;

-- Change delimiter to handle procedure definitions
DELIMITER //

-- =============================================================================
-- TRIGGER: audit_menu_item_price_changes
-- =============================================================================
-- PURPOSE:
--   Automatically tracks price changes for menu items to maintain historical
--   pricing records for business analysis and order accuracy. This trigger
--   implements Business Rule BR-033 (Price source & history).
--
-- FUNCTIONALITY:
--   - Fires BEFORE UPDATE on MenuItem table
--   - Compares OLD.price with NEW.price
--   - If prices differ, creates a record in MenuItemPriceHistory
--   - Records who made the change and when
--   - Ensures historical pricing data is preserved for past orders
--
-- BUSINESS VALUE:
--   - Maintains audit trail of pricing decisions
--   - Enables price trend analysis for business intelligence
--   - Supports accurate historical order reporting
--   - Helps with competitive pricing analysis
--   - Provides data for revenue optimization
--
-- USAGE EXAMPLE:
--   When a restaurant updates: UPDATE MenuItem SET price = 19.99 WHERE menu_item_id = 1;
--   This trigger automatically creates a history record showing the old and new prices.
-- =============================================================================

CREATE TRIGGER audit_menu_item_price_changes
BEFORE UPDATE ON MenuItem
FOR EACH ROW
BEGIN
    -- Only create history record if price actually changed
    IF OLD.price != NEW.price THEN
        INSERT INTO MenuItemPriceHistory (
            menu_item_id, 
            old_price, 
            new_price, 
            changed_by,
            changed_at
        ) VALUES (
            NEW.menu_item_id,
            OLD.price,
            NEW.price,
            @current_user_id,  -- Should be set by application before updates
            CURRENT_TIMESTAMP
        );
        
        -- Also create an audit log entry for the price change
        INSERT INTO AuditLog (
            table_name,
            record_id,
            action,
            field_name,
            old_value,
            new_value,
            performed_by,
            performed_at
        ) VALUES (
            'MenuItem',
            NEW.menu_item_id,
            'UPDATE',
            'price',
            CAST(OLD.price AS CHAR),
            CAST(NEW.price AS CHAR),
            @current_user_id,
            CURRENT_TIMESTAMP
        );
    END IF;
END//

-- =============================================================================
-- STORED PROCEDURE: CalculateAndUpdateOrderTotals
-- =============================================================================
-- PURPOSE:
--   Calculates and updates all financial totals for an order based on its items,
--   modifiers, taxes, fees, and discounts. This procedure implements Business Rules
--   BR-026 (Order totals computed) and BR-034 (Taxes).
--
-- PARAMETERS:
--   @order_id (BIGINT): The ID of the order to calculate totals for
--   @tax_rate (DECIMAL): The tax rate to apply (e.g., 0.0875 for 8.75%)
--   @delivery_fee (DECIMAL): Delivery fee amount
--   @service_fee (DECIMAL): Service fee amount  
--   @discount_amount (DECIMAL): Discount amount to subtract
--   @tip_amount (DECIMAL): Customer tip amount
--
-- FUNCTIONALITY:
--   1. Validates that the order exists and is in a modifiable state
--   2. Calculates subtotal from order items and their modifiers
--   3. Applies tax rate to calculate tax amount
--   4. Computes final total including all fees, taxes, tips, and discounts
--   5. Updates the order record with calculated amounts
--   6. Creates audit trail of the calculation
--   7. Returns success/error status and calculated amounts
--
-- BUSINESS VALUE:
--   - Ensures accurate order pricing calculations
--   - Maintains consistency in financial calculations
--   - Provides centralized logic for complex pricing rules
--   - Supports different tax rates by location
--   - Enables easy modification of calculation rules
--   - Creates audit trail for financial compliance
--
-- USAGE EXAMPLE:
--   CALL CalculateAndUpdateOrderTotals(123, 0.0875, 3.99, 1.99, 0.00, 5.00);
--   This calculates totals for order 123 with 8.75% tax, $3.99 delivery fee,
--   $1.99 service fee, no discount, and $5.00 tip.
-- =============================================================================

CREATE PROCEDURE CalculateAndUpdateOrderTotals(
    IN p_order_id BIGINT,
    IN p_tax_rate DECIMAL(5,4),
    IN p_delivery_fee DECIMAL(10,2),
    IN p_service_fee DECIMAL(10,2),
    IN p_discount_amount DECIMAL(10,2),
    IN p_tip_amount DECIMAL(10,2),
    OUT p_success BOOLEAN,
    OUT p_error_message VARCHAR(500),
    OUT p_calculated_subtotal DECIMAL(10,2),
    OUT p_calculated_total DECIMAL(10,2)
)
BEGIN
    -- Variable declarations
    DECLARE v_order_exists INT DEFAULT 0;
    DECLARE v_order_status VARCHAR(50);
    DECLARE v_customer_id BIGINT;
    DECLARE v_restaurant_id BIGINT;
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_tax_amount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_total_amount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_item_count INT DEFAULT 0;
    
    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_error_message = 'Database error occurred during order calculation';
        GET DIAGNOSTICS CONDITION 1
            p_error_message = MESSAGE_TEXT;
    END;

    -- Initialize output parameters
    SET p_success = FALSE;
    SET p_error_message = '';
    SET p_calculated_subtotal = 0.00;
    SET p_calculated_total = 0.00;

    -- Start transaction
    START TRANSACTION;

    -- Define the main processing block with label
    proc_label: BEGIN
        -- Step 1: Validate input parameters
        IF p_order_id IS NULL OR p_order_id <= 0 THEN
            SET p_error_message = 'Invalid order ID provided';
            ROLLBACK;
            LEAVE proc_label;
        END IF;

        IF p_tax_rate IS NULL OR p_tax_rate < 0 OR p_tax_rate > 1 THEN
            SET p_error_message = 'Invalid tax rate. Must be between 0 and 1';
            ROLLBACK;
            LEAVE proc_label;
        END IF;

        -- Step 2: Check if order exists and get its status
        SELECT 
            COUNT(*), 
            MAX(status),
            MAX(customer_id),
            MAX(restaurant_id)
        INTO 
            v_order_exists, 
            v_order_status,
            v_customer_id,
            v_restaurant_id
        FROM `Order` 
        WHERE order_id = p_order_id;

        IF v_order_exists = 0 THEN
            SET p_error_message = 'Order not found';
            ROLLBACK;
            LEAVE proc_label;
        END IF;

        -- Step 3: Check if order can be modified
        IF v_order_status IN ('DELIVERED', 'CANCELLED', 'FAILED') THEN
            SET p_error_message = CONCAT('Cannot modify order in ', v_order_status, ' status');
            ROLLBACK;
            LEAVE proc_label;
        END IF;

        -- Step 4: Verify order has items
        SELECT COUNT(*)
        INTO v_item_count
        FROM OrderItem
        WHERE order_id = p_order_id;

        IF v_item_count = 0 THEN
            SET p_error_message = 'Order must contain at least one item';
            ROLLBACK;
            LEAVE proc_label;
        END IF;

        -- Step 5: Calculate subtotal including items and modifiers
        SELECT 
            COALESCE(SUM(
                oi.quantity * oi.unit_price + 
                COALESCE((
                    SELECT SUM(oim.price_delta * oi.quantity)
                    FROM OrderItemModifier oim
                    WHERE oim.order_item_id = oi.order_item_id
                ), 0)
            ), 0)
        INTO v_subtotal
        FROM OrderItem oi
        WHERE oi.order_id = p_order_id;

        -- Step 6: Calculate tax amount
        SET v_tax_amount = ROUND(v_subtotal * p_tax_rate, 2);

        -- Step 7: Calculate total amount
        SET v_total_amount = v_subtotal + v_tax_amount + p_delivery_fee + p_service_fee + p_tip_amount - p_discount_amount;

        -- Ensure total is not negative
        IF v_total_amount < 0 THEN
            SET v_total_amount = 0.00;
        END IF;

        -- Step 8: Update the order with calculated amounts
        UPDATE `Order` 
        SET 
            subtotal = v_subtotal,
            tax = v_tax_amount,
            tax_rate = p_tax_rate,
            delivery_fee = p_delivery_fee,
            service_fee = p_service_fee,
            tip = p_tip_amount,
            discount = p_discount_amount,
            total = v_total_amount,
            updated_at = CURRENT_TIMESTAMP
        WHERE order_id = p_order_id;

        -- Step 9: Create audit log entry
        INSERT INTO AuditLog (
            table_name,
            record_id,
            action,
            field_name,
            old_value,
            new_value,
            performed_by,
            performed_at,
            ip_address
        ) VALUES (
            'Order',
            p_order_id,
            'UPDATE',
            'totals_recalculated',
            NULL,
            CONCAT('Subtotal: ', v_subtotal, ', Tax: ', v_tax_amount, ', Total: ', v_total_amount),
            @current_user_id,
            CURRENT_TIMESTAMP,
            @current_user_ip
        );

        -- Step 10: Set output parameters
        SET p_success = TRUE;
        SET p_calculated_subtotal = v_subtotal;
        SET p_calculated_total = v_total_amount;
        SET p_error_message = 'Order totals calculated successfully';

        -- Commit the transaction
        COMMIT;
    END proc_label;

END//

-- =============================================================================
-- HELPER STORED PROCEDURE: GetOrderCalculationSummary
-- =============================================================================
-- PURPOSE:
--   Provides a detailed breakdown of order calculations for validation and
--   display purposes. This procedure is useful for customer receipts and
--   restaurant order management systems.
--
-- PARAMETERS:
--   @order_id (BIGINT): The ID of the order to get calculation summary for
--
-- RETURNS:
--   Result set with detailed breakdown of order calculations
-- =============================================================================

CREATE PROCEDURE GetOrderCalculationSummary(
    IN p_order_id BIGINT
)
BEGIN
    -- Declare variables for summary calculations
    DECLARE v_order_exists INT DEFAULT 0;
    
    -- Check if order exists
    SELECT COUNT(*)
    INTO v_order_exists
    FROM `Order`
    WHERE order_id = p_order_id;
    
    IF v_order_exists = 0 THEN
        SELECT 
            'ERROR' as status,
            'Order not found' as message,
            NULL as order_id;
    ELSE
        -- Return detailed order calculation breakdown
        SELECT 
            'SUCCESS' as status,
            'Order calculation summary retrieved' as message,
            o.order_id,
            c.customer_name,
            r.restaurant_name,
            o.status as order_status,
            o.created_at,
            
            -- Item breakdown
            item_summary.item_count,
            item_summary.items_subtotal,
            item_summary.modifiers_total,
            
            -- Order totals
            o.subtotal as stored_subtotal,
            o.tax,
            o.tax_rate,
            o.delivery_fee,
            o.service_fee,
            o.tip,
            o.discount,
            o.total as stored_total,
            
            -- Validation
            CASE 
                WHEN ABS(o.subtotal - (item_summary.items_subtotal + item_summary.modifiers_total)) < 0.01 
                THEN 'VALID' 
                ELSE 'INVALID' 
            END as subtotal_validation,
            
            CASE 
                WHEN ABS(o.total - (o.subtotal + o.tax + o.delivery_fee + o.service_fee + o.tip - o.discount)) < 0.01 
                THEN 'VALID' 
                ELSE 'INVALID' 
            END as total_validation
            
        FROM `Order` o
        JOIN Customer c ON o.customer_id = c.customer_id
        JOIN Restaurant r ON o.restaurant_id = r.restaurant_id
        LEFT JOIN (
            SELECT 
                oi.order_id,
                COUNT(oi.order_item_id) as item_count,
                SUM(oi.quantity * oi.unit_price) as items_subtotal,
                COALESCE(SUM(
                    (SELECT SUM(oim.price_delta * oi.quantity)
                     FROM OrderItemModifier oim 
                     WHERE oim.order_item_id = oi.order_item_id)
                ), 0) as modifiers_total
            FROM OrderItem oi
            WHERE oi.order_id = p_order_id
            GROUP BY oi.order_id
        ) item_summary ON o.order_id = item_summary.order_id
        WHERE o.order_id = p_order_id;
        
        -- Also return itemized breakdown
        SELECT 
            'ITEMS' as section,
            oi.order_item_id,
            oi.item_name,
            oi.quantity,
            oi.unit_price,
            oi.quantity * oi.unit_price as line_subtotal,
            COALESCE(
                (SELECT SUM(oim.price_delta * oi.quantity)
                 FROM OrderItemModifier oim 
                 WHERE oim.order_item_id = oi.order_item_id), 
                0
            ) as modifiers_total,
            (oi.quantity * oi.unit_price) + COALESCE(
                (SELECT SUM(oim.price_delta * oi.quantity)
                 FROM OrderItemModifier oim 
                 WHERE oim.order_item_id = oi.order_item_id), 
                0
            ) as line_total,
            oi.notes
        FROM OrderItem oi
        WHERE oi.order_id = p_order_id
        ORDER BY oi.order_item_id;
        
        -- Return modifier details
        SELECT 
            'MODIFIERS' as section,
            oim.order_item_id,
            oi.item_name,
            oim.modifier_name,
            oim.option_name,
            oim.price_delta,
            oi.quantity,
            oim.price_delta * oi.quantity as modifier_total
        FROM OrderItemModifier oim
        JOIN OrderItem oi ON oim.order_item_id = oi.order_item_id
        WHERE oi.order_id = p_order_id
        ORDER BY oim.order_item_id, oim.modifier_name;
    END IF;
END//

-- Reset delimiter
DELIMITER ;

-- =============================================================================
-- TRIGGER AND PROCEDURE TESTING EXAMPLES
-- =============================================================================

-- Example 1: Test the price change trigger
-- Set a user context (in real application, this would be set by the application)
SET @current_user_id = 6;  -- Restaurant account

-- Update a menu item price to trigger the audit
UPDATE MenuItem 
SET price = 19.99 
WHERE menu_item_id = 1 AND price != 19.99;

-- Verify the trigger created history records
SELECT 
    mph.*,
    mi.name as item_name
FROM MenuItemPriceHistory mph
JOIN MenuItem mi ON mph.menu_item_id = mi.menu_item_id
WHERE mph.menu_item_id = 1
ORDER BY mph.changed_at DESC
LIMIT 5;

-- Example 2: Test the order calculation procedure
-- Create variables to capture output
SET @success = FALSE;
SET @error_msg = '';
SET @calc_subtotal = 0.00;
SET @calc_total = 0.00;
SET @current_user_id = 1;  -- Customer account
SET @current_user_ip = '192.168.1.100';

-- Call the procedure for an existing order
CALL CalculateAndUpdateOrderTotals(
    1,           -- order_id
    0.0875,      -- tax_rate (8.75%)
    3.99,        -- delivery_fee
    1.99,        -- service_fee  
    0.00,        -- discount_amount
    5.00,        -- tip_amount
    @success,
    @error_msg,
    @calc_subtotal,
    @calc_total
);

-- Check the results
SELECT 
    @success as calculation_success,
    @error_msg as message,
    @calc_subtotal as calculated_subtotal,
    @calc_total as calculated_total;

-- Example 3: Get detailed order calculation summary
CALL GetOrderCalculationSummary(1);

-- =============================================================================
-- TRIGGER AND PROCEDURE DOCUMENTATION SUMMARY
-- =============================================================================

/*
TRIGGER: audit_menu_item_price_changes
- Automatically tracks price changes for menu items
- Maintains historical pricing data for business analysis
- Creates audit trail for price modifications
- Supports accurate historical order reporting

STORED PROCEDURE: CalculateAndUpdateOrderTotals
- Centralized order total calculation logic
- Handles complex pricing including items, modifiers, taxes, fees
- Provides validation and error handling
- Creates audit trail of calculations
- Ensures financial accuracy and compliance

STORED PROCEDURE: GetOrderCalculationSummary  
- Provides detailed breakdown of order calculations
- Validates calculation accuracy
- Useful for receipts and order management
- Returns itemized and modifier details

These database objects implement critical business rules and provide
reliable, auditable financial calculations for the GrubnGo platform.
They ensure data integrity, support business intelligence needs, and
provide the foundation for accurate financial reporting.
*/

-- Verify all objects were created successfully
SHOW TRIGGERS LIKE 'MenuItem';
SHOW PROCEDURE STATUS WHERE Name IN ('CalculateAndUpdateOrderTotals', 'GetOrderCalculationSummary');

SELECT 'Triggers and stored procedures created successfully!' as message;
