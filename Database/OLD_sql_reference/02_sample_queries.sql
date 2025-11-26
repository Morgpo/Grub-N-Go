USE GrubnGo;

-- =============================================================================
-- QUERY 1: CREATE - Place a New Order with Items and Modifiers
-- Real-world use: Customer places an order through the mobile app
-- =============================================================================

-- Step 1: Create the order
INSERT INTO `Order` (
    customer_id, restaurant_id, delivery_address_id, 
    delivery_street, delivery_city, delivery_state, delivery_postal_code, delivery_country,
    status, subtotal, tax, tax_rate, delivery_fee, service_fee, tip, discount, total, 
    payment_method_id, is_paid
) VALUES (
    1, 6, 1, 
    '123 Main St', 'San Francisco', 'CA', '94102', 'USA',
    'CREATED', 29.98, 2.62, 0.0875, 3.99, 1.99, 6.00, 0.00, 44.58, 
    1, 0
);

-- Step 2: Get the order ID for adding items
SET @new_order_id = LAST_INSERT_ID();

-- Step 3: Add order items with snapshots
INSERT INTO OrderItem (order_id, menu_item_id, item_name, item_description, quantity, unit_price, notes) VALUES
(@new_order_id, 2, 'Pepperoni Pizza', 'Classic pepperoni with mozzarella cheese', 1, 21.99, 'Extra cheese'),
(@new_order_id, 3, 'Caesar Salad', 'Romaine lettuce, parmesan, croutons, caesar dressing', 1, 12.99, 'Dressing on the side');

-- Step 4: Add modifier selections
INSERT INTO OrderItemModifier (order_item_id, modifier_option_id, modifier_name, option_name, price_delta)
SELECT oi.order_item_id, 3, 'Size', 'Large (14")', 3.00
FROM OrderItem oi 
WHERE oi.order_id = @new_order_id AND oi.menu_item_id = 2;

-- Verify the order creation
SELECT 
    o.order_id,
    c.customer_name,
    r.restaurant_name,
    o.status,
    o.total,
    GROUP_CONCAT(CONCAT(oi.quantity, 'x ', oi.item_name) SEPARATOR ', ') as items
FROM `Order` o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id
JOIN OrderItem oi ON o.order_id = oi.order_id
WHERE o.order_id = @new_order_id
GROUP BY o.order_id, c.customer_name, r.restaurant_name, o.status, o.total;

-- =============================================================================
-- QUERY 2: READ - Customer Order History with Detailed Information
-- Real-world use: Customer views their order history in the app
-- =============================================================================

SELECT 
    o.order_id,
    o.created_at as order_date,
    r.restaurant_name,
    o.status,
    o.total,
    COUNT(oi.order_item_id) as item_count,
    GROUP_CONCAT(
        CONCAT(oi.quantity, 'x ', oi.item_name, 
               CASE WHEN oi.notes IS NOT NULL 
                    THEN CONCAT(' (', oi.notes, ')') 
                    ELSE '' END
        ) SEPARATOR '; '
    ) as order_items,
    -- Calculate delivery time if delivered
    CASE 
        WHEN o.delivered_at IS NOT NULL 
        THEN TIMESTAMPDIFF(MINUTE, o.created_at, o.delivered_at)
        ELSE NULL 
    END as delivery_time_minutes
FROM `Order` o
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id
LEFT JOIN OrderItem oi ON o.order_id = oi.order_id
WHERE o.customer_id = 1
GROUP BY o.order_id, o.created_at, r.restaurant_name, o.status, o.total, o.delivered_at
ORDER BY o.created_at DESC
LIMIT 5;

-- =============================================================================
-- QUERY 3: UPDATE - Update Order Status with Timestamp Tracking
-- Real-world use: Restaurant updates order status as it progresses
-- =============================================================================

-- Update order status from CREATED to CONFIRMED
UPDATE `Order` 
SET 
    status = 'CONFIRMED',
    confirmed_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
WHERE order_id = @new_order_id AND status = 'CREATED';

-- Record the status change in audit log
INSERT INTO AuditLog (table_name, record_id, action, field_name, old_value, new_value, performed_by, ip_address)
VALUES ('Order', @new_order_id, 'STATUS_CHANGE', 'status', 'CREATED', 'CONFIRMED', 6, '192.168.1.200');

-- Verify the update
SELECT 
    order_id,
    status,
    created_at,
    confirmed_at,
    TIMESTAMPDIFF(SECOND, created_at, confirmed_at) as confirmation_delay_seconds
FROM `Order` 
WHERE order_id = @new_order_id;

-- =============================================================================
-- QUERY 4: JOIN - Restaurant Performance Dashboard
-- Real-world use: Restaurant owner views performance metrics
-- =============================================================================

SELECT 
    r.restaurant_name,
    r.operating_status,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'DELIVERED' THEN o.order_id END) as completed_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'CANCELLED' THEN o.order_id END) as cancelled_orders,
    -- Revenue calculations
    COALESCE(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.subtotal END), 0) as gross_revenue,
    COALESCE(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.tax END), 0) as tax_collected,
    COALESCE(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.tip END), 0) as tips_received,
    COALESCE(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total END), 0) as total_revenue,
    -- Performance metrics
    COALESCE(AVG(CASE WHEN o.status = 'DELIVERED' THEN o.total END), 0) as avg_order_value,
    COALESCE(AVG(CASE 
        WHEN o.delivered_at IS NOT NULL AND o.confirmed_at IS NOT NULL 
        THEN TIMESTAMPDIFF(MINUTE, o.confirmed_at, o.delivered_at) 
    END), 0) as avg_fulfillment_time_minutes,
    -- Order completion rate
    CASE 
        WHEN COUNT(o.order_id) > 0 
        THEN ROUND((COUNT(CASE WHEN o.status = 'DELIVERED' THEN 1 END) * 100.0 / COUNT(o.order_id)), 2)
        ELSE 0 
    END as completion_rate_percent
FROM Restaurant r
LEFT JOIN `Order` o ON r.restaurant_id = o.restaurant_id 
    AND o.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)  -- Last 30 days
WHERE r.restaurant_id = 6  -- Mario's Pizza Palace
GROUP BY r.restaurant_id, r.restaurant_name, r.operating_status;

-- =============================================================================
-- QUERY 5: AGGREGATE - Top Selling Menu Items Analysis
-- Real-world use: Restaurant analyzes popular items for inventory planning
-- =============================================================================

SELECT 
    mi.menu_item_id,
    mi.name as item_name,
    m.name as menu_name,
    mi.price as current_price,
    COUNT(DISTINCT oi.order_id) as orders_containing_item,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) as gross_revenue,
    AVG(oi.unit_price) as avg_selling_price,
    -- Calculate modifier revenue using LEFT JOIN
    COALESCE(SUM(oim.price_delta * oi.quantity), 0) as modifier_revenue,
    -- Performance ranking
    RANK() OVER (ORDER BY SUM(oi.quantity) DESC) as popularity_rank,
    -- Revenue contribution (calculated as subquery to avoid window function issues)
    ROUND(
        (SUM(oi.quantity * oi.unit_price) * 100.0) / (
            SELECT SUM(oi2.quantity * oi2.unit_price)
            FROM OrderItem oi2 
            JOIN `Order` o2 ON oi2.order_id = o2.order_id
            JOIN MenuItem mi2 ON oi2.menu_item_id = mi2.menu_item_id
            JOIN Menu m2 ON mi2.menu_id = m2.menu_id
            WHERE o2.status = 'DELIVERED'
                AND o2.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 90 DAY)
                AND m2.restaurant_id = 6
        ), 
        2
    ) as revenue_contribution_percent
FROM MenuItem mi
JOIN Menu m ON mi.menu_id = m.menu_id
LEFT JOIN OrderItem oi ON mi.menu_item_id = oi.menu_item_id
LEFT JOIN `Order` o ON oi.order_id = o.order_id AND o.status = 'DELIVERED'
LEFT JOIN OrderItemModifier oim ON oi.order_item_id = oim.order_item_id
WHERE o.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 90 DAY)  -- Last 90 days
    AND m.restaurant_id = 6  -- Mario's Pizza Palace
    AND o.order_id IS NOT NULL  -- Only include items that have been ordered
GROUP BY mi.menu_item_id, mi.name, m.name, mi.price
HAVING total_quantity_sold > 0
ORDER BY total_quantity_sold DESC, gross_revenue DESC
LIMIT 10;

-- =============================================================================
-- QUERY 6: COMPLEX JOIN - Customer Loyalty Analysis
-- Real-world use: Marketing team identifies VIP customers for promotions
-- =============================================================================

SELECT 
    c.customer_id,
    c.customer_name,
    c.phone,
    a.email,
    -- Order statistics
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'DELIVERED' THEN o.order_id END) as successful_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'CANCELLED' THEN o.order_id END) as cancelled_orders,
    -- Spending analysis
    COALESCE(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total END), 0) as total_spent,
    COALESCE(AVG(CASE WHEN o.status = 'DELIVERED' THEN o.total END), 0) as avg_order_value,
    -- Loyalty metrics
    MAX(o.created_at) as last_order_date,
    DATEDIFF(CURRENT_DATE, MAX(o.created_at)) as days_since_last_order,
    COUNT(DISTINCT o.restaurant_id) as restaurants_ordered_from,
    -- Preferred restaurant
    (SELECT r2.restaurant_name 
     FROM `Order` o2 
     JOIN Restaurant r2 ON o2.restaurant_id = r2.restaurant_id
     WHERE o2.customer_id = c.customer_id AND o2.status = 'DELIVERED'
     GROUP BY r2.restaurant_id, r2.restaurant_name
     ORDER BY COUNT(*) DESC 
     LIMIT 1) as favorite_restaurant,
    -- Customer segment classification
    CASE 
        WHEN COUNT(DISTINCT o.order_id) >= 10 AND SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total END) >= 300 
        THEN 'VIP'
        WHEN COUNT(DISTINCT o.order_id) >= 5 AND SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total END) >= 100 
        THEN 'Regular'
        WHEN COUNT(DISTINCT o.order_id) >= 2 
        THEN 'Occasional'
        ELSE 'New'
    END as customer_segment
FROM Customer c
JOIN Account a ON c.customer_id = a.account_id
LEFT JOIN `Order` o ON c.customer_id = o.customer_id
WHERE a.status = 'ACTIVE'
GROUP BY c.customer_id, c.customer_name, c.phone, a.email
ORDER BY total_spent DESC, total_orders DESC;

-- =============================================================================
-- QUERY 7: DELETE - Cancel Order and Process Refund
-- Real-world use: Customer cancels order and receives refund
-- =============================================================================

-- Set the order to cancel (use a delivered order for demo)
SET @order_to_cancel = 2;

-- Step 1: Update order status to cancelled
UPDATE `Order` 
SET 
    status = 'CANCELLED',
    cancelled_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
WHERE order_id = @order_to_cancel 
    AND status IN ('CREATED', 'CONFIRMED');  -- Only allow cancellation of early-stage orders

-- Step 2: Create refund record
INSERT INTO Refund (order_id, refund_amount, refund_reason, status, requested_by)
SELECT 
    order_id,
    total,
    'Customer cancellation',
    'PENDING',
    customer_id
FROM `Order` 
WHERE order_id = @order_to_cancel;

-- Step 3: Log the cancellation
INSERT INTO AuditLog (table_name, record_id, action, field_name, old_value, new_value, performed_by)
SELECT 
    'Order',
    @order_to_cancel,
    'STATUS_CHANGE',
    'status',
    'CONFIRMED',  -- Assuming it was confirmed
    'CANCELLED',
    customer_id
FROM `Order` 
WHERE order_id = @order_to_cancel;

-- Verify the cancellation
SELECT 
    o.order_id,
    o.status,
    o.cancelled_at,
    o.total as order_total,
    r.refund_amount,
    r.status as refund_status,
    r.requested_at
FROM `Order` o
LEFT JOIN Refund r ON o.order_id = r.order_id
WHERE o.order_id = @order_to_cancel;

-- =============================================================================
-- QUERY 8: AGGREGATE - Daily Sales Report with Trends
-- Real-world use: Management reviews daily sales performance
-- =============================================================================

SELECT 
    DATE(o.created_at) as order_date,
    DAYNAME(o.created_at) as day_of_week,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'DELIVERED' THEN o.order_id END) as completed_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    -- Revenue calculations
    SUM(CASE WHEN o.status = 'DELIVERED' THEN o.subtotal ELSE 0 END) as gross_sales,
    SUM(CASE WHEN o.status = 'DELIVERED' THEN o.tax ELSE 0 END) as tax_collected,
    SUM(CASE WHEN o.status = 'DELIVERED' THEN o.delivery_fee ELSE 0 END) as delivery_fees,
    SUM(CASE WHEN o.status = 'DELIVERED' THEN o.tip ELSE 0 END) as tips,
    SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END) as total_revenue,
    -- Performance metrics
    AVG(CASE WHEN o.status = 'DELIVERED' THEN o.total END) as avg_order_value,
    -- Completion rate
    CASE 
        WHEN COUNT(o.order_id) > 0 
        THEN ROUND((COUNT(CASE WHEN o.status = 'DELIVERED' THEN 1 END) * 100.0 / COUNT(o.order_id)), 1)
        ELSE 0 
    END as completion_rate_percent,
    -- Compare with previous day
    LAG(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END)) 
        OVER (ORDER BY DATE(o.created_at)) as previous_day_revenue,
    CASE 
        WHEN LAG(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END)) 
             OVER (ORDER BY DATE(o.created_at)) > 0
        THEN ROUND(
            ((SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END) - 
              LAG(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END)) 
              OVER (ORDER BY DATE(o.created_at))) * 100.0) /
            LAG(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END)) 
            OVER (ORDER BY DATE(o.created_at)), 1
        )
        ELSE 0
    END as revenue_change_percent
FROM `Order` o
WHERE o.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
GROUP BY DATE(o.created_at), DAYNAME(o.created_at)
ORDER BY order_date DESC;

-- =============================================================================
-- QUERY 9: COMPLEX JOIN - Menu Item Performance with Modifier Analysis
-- Real-world use: Restaurant optimizes menu and pricing strategy
-- =============================================================================

SELECT 
    mi.name as item_name,
    mi.price as base_price,
    COUNT(DISTINCT oi.order_id) as times_ordered,
    SUM(oi.quantity) as total_quantity,
    -- Base revenue (without modifiers)
    SUM(oi.quantity * oi.unit_price) as base_revenue,
    -- Modifier analysis
    COUNT(DISTINCT oim.order_item_modifier_id) as modifier_selections,
    COALESCE(SUM(oim.price_delta * oi.quantity), 0) as modifier_revenue,
    -- Total revenue including modifiers
    SUM(oi.quantity * oi.unit_price) + COALESCE(SUM(oim.price_delta * oi.quantity), 0) as total_revenue,
    -- Average prices
    AVG(oi.unit_price) as avg_base_selling_price,
    -- Calculate average total selling price properly
    (SUM(oi.quantity * oi.unit_price) + COALESCE(SUM(oim.price_delta * oi.quantity), 0)) / SUM(oi.quantity) as avg_total_selling_price,
    -- Most popular modifiers (using subquery without LIMIT in GROUP_CONCAT)
    (SELECT GROUP_CONCAT(DISTINCT CONCAT(oim3.modifier_name, ': ', oim3.option_name) SEPARATOR ', ')
     FROM OrderItemModifier oim3
     JOIN OrderItem oi3 ON oim3.order_item_id = oi3.order_item_id
     WHERE oi3.menu_item_id = mi.menu_item_id) as popular_modifiers,
    -- Profitability ranking
    RANK() OVER (ORDER BY (SUM(oi.quantity * oi.unit_price) + COALESCE(SUM(oim.price_delta * oi.quantity), 0)) DESC) as revenue_rank
FROM MenuItem mi
JOIN Menu m ON mi.menu_id = m.menu_id
LEFT JOIN OrderItem oi ON mi.menu_item_id = oi.menu_item_id
LEFT JOIN `Order` o ON oi.order_id = o.order_id AND o.status = 'DELIVERED'
LEFT JOIN OrderItemModifier oim ON oi.order_item_id = oim.order_item_id
WHERE m.restaurant_id = 6  -- Mario's Pizza Palace
    AND mi.is_available = 1
GROUP BY mi.menu_item_id, mi.name, mi.price
ORDER BY total_revenue DESC, times_ordered DESC;

-- =============================================================================
-- QUERY 10: AGGREGATE - Business Intelligence Dashboard
-- Real-world use: Executive dashboard showing key business metrics
-- =============================================================================

-- Create a comprehensive business summary
WITH monthly_metrics AS (
    SELECT 
        DATE_FORMAT(o.created_at, '%Y-%m') as month,
        COUNT(DISTINCT o.order_id) as total_orders,
        COUNT(DISTINCT o.customer_id) as unique_customers,
        COUNT(DISTINCT o.restaurant_id) as active_restaurants,
        SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END) as revenue,
        AVG(CASE WHEN o.status = 'DELIVERED' THEN o.total END) as avg_order_value,
        COUNT(CASE WHEN o.status = 'CANCELLED' THEN 1 END) as cancelled_orders
    FROM `Order` o
    WHERE o.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
    GROUP BY DATE_FORMAT(o.created_at, '%Y-%m')
),
customer_segments AS (
    SELECT 
        CASE 
            WHEN order_count >= 10 THEN 'VIP'
            WHEN order_count >= 5 THEN 'Regular' 
            WHEN order_count >= 2 THEN 'Occasional'
            ELSE 'New'
        END as segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_customer_value
    FROM (
        SELECT 
            c.customer_id,
            COUNT(o.order_id) as order_count,
            COALESCE(SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total END), 0) as total_spent
        FROM Customer c
        LEFT JOIN `Order` o ON c.customer_id = o.customer_id
        GROUP BY c.customer_id
    ) customer_stats
    GROUP BY segment
),
restaurant_performance AS (
    SELECT 
        r.restaurant_name,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(CASE WHEN o.status = 'DELIVERED' THEN o.total ELSE 0 END) as revenue,
        ROUND(AVG(CASE 
            WHEN o.delivered_at IS NOT NULL AND o.confirmed_at IS NOT NULL 
            THEN TIMESTAMPDIFF(MINUTE, o.confirmed_at, o.delivered_at) 
        END), 1) as avg_delivery_time_minutes,
        ROUND((COUNT(CASE WHEN o.status = 'DELIVERED' THEN 1 END) * 100.0 / NULLIF(COUNT(o.order_id), 0)), 1) as success_rate
    FROM Restaurant r
    LEFT JOIN `Order` o ON r.restaurant_id = o.restaurant_id 
        AND o.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
    GROUP BY r.restaurant_id, r.restaurant_name
)
-- Main dashboard query
SELECT 
    'MONTHLY TRENDS' as section,
    NULL as restaurant,
    NULL as segment,
    month as period,
    total_orders as orders,
    unique_customers as customers,
    ROUND(revenue, 2) as revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    NULL as delivery_time,
    ROUND((total_orders - cancelled_orders) * 100.0 / NULLIF(total_orders, 0), 1) as success_rate
FROM monthly_metrics
WHERE month >= DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH), '%Y-%m')

UNION ALL

SELECT 
    'CUSTOMER SEGMENTS' as section,
    NULL as restaurant,
    segment,
    NULL as period,
    customer_count as orders,
    NULL as customers,
    ROUND(avg_customer_value, 2) as revenue,
    NULL as avg_order_value,
    NULL as delivery_time,
    NULL as success_rate
FROM customer_segments

UNION ALL

SELECT 
    'RESTAURANT PERFORMANCE' as section,
    restaurant_name as restaurant,
    NULL as segment,
    'Last 30 Days' as period,
    total_orders as orders,
    NULL as customers,
    ROUND(revenue, 2) as revenue,
    NULL as avg_order_value,
    avg_delivery_time_minutes as delivery_time,
    success_rate
FROM restaurant_performance
WHERE total_orders > 0

ORDER BY 
    CASE section 
        WHEN 'MONTHLY TRENDS' THEN 1 
        WHEN 'CUSTOMER SEGMENTS' THEN 2 
        WHEN 'RESTAURANT PERFORMANCE' THEN 3 
    END,
    period DESC,
    revenue DESC;

-- =============================================================================
-- PERFORMANCE VALIDATION QUERIES
-- =============================================================================

-- Check query performance on large datasets
EXPLAIN SELECT 
    o.order_id,
    c.customer_name,
    r.restaurant_name,
    o.total
FROM `Order` o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN Restaurant r ON o.restaurant_id = r.restaurant_id
WHERE o.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
    AND o.status = 'DELIVERED'
ORDER BY o.created_at DESC;

-- Verify data integrity
SELECT 
    'Orders without items' as check_type,
    COUNT(*) as issue_count
FROM `Order` o
LEFT JOIN OrderItem oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL

UNION ALL

SELECT 
    'Items with incorrect totals' as check_type,
    COUNT(*) as issue_count
FROM `Order` o
JOIN (
    SELECT 
        oi.order_id,
        SUM(oi.quantity * oi.unit_price) + 
        COALESCE(SUM(oim.price_delta * oi.quantity), 0) as calculated_subtotal
    FROM OrderItem oi
    LEFT JOIN OrderItemModifier oim ON oi.order_item_id = oim.order_item_id
    GROUP BY oi.order_id
) calc ON o.order_id = calc.order_id
WHERE ABS(o.subtotal - calc.calculated_subtotal) > 0.01;

-- =============================================================================
-- END OF QUERIES
-- =============================================================================

SELECT 'All sample queries completed successfully!' as message;
