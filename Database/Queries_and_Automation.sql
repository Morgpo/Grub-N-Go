USE GrubnGo;

-- =============================================================================
-- SECTION 1: REPORT QUERY WITH JOIN + GROUP BY
-- Purpose: Summarize delivered orders per restaurant over the last 30 days.
-- =============================================================================
SELECT 
    r.restaurant_name,
    DATE(o.created_at) AS order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.subtotal) AS gross_sales,
    SUM(o.total) AS total_revenue
FROM Restaurant r
JOIN `Order` o ON r.restaurant_id = o.restaurant_id
WHERE o.status = 'DELIVERED'
  AND o.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
GROUP BY r.restaurant_id, r.restaurant_name, DATE(o.created_at)
ORDER BY total_revenue DESC;

-- =============================================================================
-- SECTION 2: QUERY USING A SUBQUERY
-- Purpose: Identify customers whose delivered order spend is above the average.
-- =============================================================================
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.total) AS lifetime_value
FROM Customer c
JOIN `Order` o ON c.customer_id = o.customer_id
WHERE o.status = 'DELIVERED'
GROUP BY c.customer_id, c.customer_name
HAVING lifetime_value > (
    SELECT AVG(customer_totals.total_spent)
    FROM (
        SELECT 
            o2.customer_id,
            SUM(o2.total) AS total_spent
        FROM `Order` o2
        WHERE o2.status = 'DELIVERED'
        GROUP BY o2.customer_id
    ) AS customer_totals
)
ORDER BY lifetime_value DESC;

-- =============================================================================
-- SECTION 3: VIEW CREATION AND USAGE
-- Purpose: Create a reusable view that summarizes restaurant metrics for the
-- recent 30-day window, then demonstrate querying the view.
-- =============================================================================
DROP VIEW IF EXISTS vw_last_30_day_restaurant_metrics;
CREATE VIEW vw_last_30_day_restaurant_metrics AS
SELECT 
    r.restaurant_id,
    r.restaurant_name,
    DATE_FORMAT(o.created_at, '%Y-%m') AS reporting_month,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    SUM(o.total) AS delivered_revenue,
    AVG(TIMESTAMPDIFF(MINUTE, o.confirmed_at, o.delivered_at)) AS avg_fulfillment_minutes
FROM Restaurant r
JOIN `Order` o ON r.restaurant_id = o.restaurant_id
WHERE o.status = 'DELIVERED'
  AND o.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
GROUP BY r.restaurant_id, r.restaurant_name, DATE_FORMAT(o.created_at, '%Y-%m');

-- Demonstrate usage of the view.
SELECT 
    reporting_month,
    restaurant_name,
    delivered_orders,
    ROUND(delivered_revenue, 2) AS delivered_revenue,
    ROUND(avg_fulfillment_minutes, 1) AS avg_fulfillment_minutes
FROM vw_last_30_day_restaurant_metrics
ORDER BY reporting_month DESC, delivered_revenue DESC;

-- =============================================================================
-- SECTION 4: TRIGGER CREATION AND DEMONSTRATION
-- Purpose: Show a trigger that reacts to inserts by populating an audit table.
-- The trigger is scoped to demo tables to avoid impacting production data.
-- =============================================================================
DROP TABLE IF EXISTS Demo_OrderEvent;
CREATE TABLE Demo_OrderEvent (
    order_event_id INT AUTO_INCREMENT PRIMARY KEY,
    external_order_ref VARCHAR(50) NOT NULL,
    restaurant_id INT NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Demo_OrderEventLog;
CREATE TABLE Demo_OrderEventLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_event_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    recorded_total DECIMAL(10, 2) NOT NULL,
    log_note VARCHAR(255) NOT NULL,
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_demo_order_event_audit;
DELIMITER //
CREATE TRIGGER trg_demo_order_event_audit
AFTER INSERT ON Demo_OrderEvent
FOR EACH ROW
BEGIN
    INSERT INTO Demo_OrderEventLog (
        order_event_id,
        restaurant_id,
        recorded_total,
        log_note
    )
    VALUES (
        NEW.order_event_id,
        NEW.restaurant_id,
        NEW.total,
        'Inserted by trg_demo_order_event_audit'
    );
END //
DELIMITER ;

-- Demonstrate the trigger by inserting a new demo order event.
INSERT INTO Demo_OrderEvent (external_order_ref, restaurant_id, subtotal, total)
VALUES ('DEMO-ORDER-1001', 6, 32.50, 35.55);

-- Capture the identity of the inserted demo order event.
SET @demo_order_event_id = LAST_INSERT_ID();

-- Show the trigger output stored in the audit log.
SELECT 
    log_id,
    order_event_id,
    restaurant_id,
    recorded_total,
    log_note,
    recorded_at
FROM Demo_OrderEventLog
WHERE order_event_id = @demo_order_event_id;

-- Optional cleanup (uncomment if you want to remove demo artifacts after running).
-- DROP VIEW IF EXISTS vw_last_30_day_restaurant_metrics;
-- DROP TRIGGER IF EXISTS trg_demo_order_event_audit;
-- DROP TABLE IF EXISTS Demo_OrderEventLog;
-- DROP TABLE IF EXISTS Demo_OrderEvent;
