from typing import List, Optional
from database import get_db_manager
from models import (
    PopularMenuItem,
    CustomerOrderSummary,
    RestaurantRevenueSummary
)


class UtilityCRUD:
    """Utility CRUD operations for analytics and reporting."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def get_popular_menu_items(self, restaurant_id: int, limit: int = 10) -> List[PopularMenuItem]:
        """Get popular menu items for a restaurant (BR-028 - only from DELIVERED orders)."""
        query = """
        SELECT mi.menu_item_id, 
               mi.name, 
               mi.price,
               COUNT(oi.order_item_id) as order_count,
               SUM(oi.quantity) as total_quantity_sold,
               SUM(oi.quantity * oi.unit_price) as total_revenue
        FROM MenuItem mi 
        LEFT JOIN OrderItem oi ON mi.menu_item_id = oi.menu_item_id 
        LEFT JOIN `Order` o ON oi.order_id = o.order_id
        WHERE mi.menu_id IN (SELECT menu_id FROM Menu WHERE restaurant_id = %s)
          AND (o.status = 'DELIVERED' OR o.status IS NULL)
        GROUP BY mi.menu_item_id, mi.name, mi.price 
        ORDER BY order_count DESC, total_quantity_sold DESC 
        LIMIT %s
        """
        results = self.db.execute_query(query, (restaurant_id, limit))
        return [PopularMenuItem(**row) for row in results] if results else []
    
    def get_customer_order_summary(self, customer_id: int) -> Optional[CustomerOrderSummary]:
        """Get customer order history summary with phone."""
        query = """
        SELECT c.customer_id,
               c.customer_name,
               c.phone,
               COUNT(o.order_id) as total_orders,
               COALESCE(SUM(o.total), 0) as total_spent,
               MAX(o.created_at) as last_order_date
        FROM Customer c 
        LEFT JOIN `Order` o ON c.customer_id = o.customer_id 
        WHERE c.customer_id = %s
        GROUP BY c.customer_id, c.customer_name, c.phone
        """
        result = self.db.execute_query(query, (customer_id,), fetch_one=True)
        return CustomerOrderSummary(**result) if result else None
    
    def get_restaurant_revenue_summary(self, restaurant_id: int) -> Optional[RestaurantRevenueSummary]:
        """Get restaurant revenue summary (BR-028 - only DELIVERED orders)."""
        query = """
        SELECT r.restaurant_id,
               r.restaurant_name,
               r.operating_status,
               COUNT(o.order_id) as total_orders,
               COALESCE(SUM(o.total), 0) as total_revenue,
               COALESCE(AVG(o.total), 0) as average_order_value
        FROM Restaurant r 
        LEFT JOIN `Order` o ON r.restaurant_id = o.restaurant_id 
        WHERE r.restaurant_id = %s 
          AND (o.status = 'DELIVERED' OR o.status IS NULL)
        GROUP BY r.restaurant_id, r.restaurant_name, r.operating_status
        """
        result = self.db.execute_query(query, (restaurant_id,), fetch_one=True)
        return RestaurantRevenueSummary(**result) if result else None
    
    def get_all_customer_summaries(self) -> List[CustomerOrderSummary]:
        """Get order summaries for all customers."""
        query = """
        SELECT c.customer_id,
               c.customer_name,
               c.phone,
               COUNT(o.order_id) as total_orders,
               COALESCE(SUM(o.total), 0) as total_spent,
               MAX(o.created_at) as last_order_date
        FROM Customer c 
        LEFT JOIN `Order` o ON c.customer_id = o.customer_id 
        GROUP BY c.customer_id, c.customer_name, c.phone
        ORDER BY total_spent DESC
        """
        results = self.db.execute_query(query)
        return [CustomerOrderSummary(**row) for row in results] if results else []
    
    def get_all_restaurant_summaries(self) -> List[RestaurantRevenueSummary]:
        """Get revenue summaries for all restaurants (BR-028 - only DELIVERED orders)."""
        query = """
        SELECT r.restaurant_id,
               r.restaurant_name,
               r.operating_status,
               COUNT(o.order_id) as total_orders,
               COALESCE(SUM(o.total), 0) as total_revenue,
               COALESCE(AVG(o.total), 0) as average_order_value
        FROM Restaurant r 
        LEFT JOIN `Order` o ON r.restaurant_id = o.restaurant_id 
        WHERE o.status = 'DELIVERED' OR o.status IS NULL
        GROUP BY r.restaurant_id, r.restaurant_name, r.operating_status
        ORDER BY total_revenue DESC
        """
        results = self.db.execute_query(query)
        return [RestaurantRevenueSummary(**row) for row in results] if results else []
    
    # Business Rule Validation Methods
    
    def check_restaurant_accepting_orders(self, restaurant_id: int) -> bool:
        """Check if restaurant is accepting orders (BR-024)."""
        query = "SELECT operating_status FROM Restaurant WHERE restaurant_id = %s"
        result = self.db.execute_query(query, (restaurant_id,), fetch_one=True)
        return result and result['operating_status'] == 'ACCEPTING_ORDERS' if result else False
    
    def check_account_active(self, account_id: int) -> bool:
        """Check if account is active (BR-001, BR-002, BR-003)."""
        query = "SELECT status FROM Account WHERE account_id = %s"
        result = self.db.execute_query(query, (account_id,), fetch_one=True)
        return result and result['status'] == 'ACTIVE' if result else False
    
    def validate_menu_item_uniqueness(self, menu_id: int, item_name: str, exclude_item_id: Optional[int] = None) -> bool:
        """Validate menu item name is unique within menu (BR-019)."""
        if exclude_item_id:
            query = "SELECT COUNT(*) as count FROM MenuItem WHERE menu_id = %s AND name = %s AND menu_item_id != %s"
            result = self.db.execute_query(query, (menu_id, item_name, exclude_item_id), fetch_one=True)
        else:
            query = "SELECT COUNT(*) as count FROM MenuItem WHERE menu_id = %s AND name = %s"
            result = self.db.execute_query(query, (menu_id, item_name), fetch_one=True)
        return result and result['count'] == 0 if result else False
    
    def validate_modifier_uniqueness(self, menu_item_id: int, modifier_name: str, exclude_modifier_id: Optional[int] = None) -> bool:
        """Validate modifier name is unique for menu item (BR-020)."""
        if exclude_modifier_id:
            query = "SELECT COUNT(*) as count FROM Modifier WHERE menu_item_id = %s AND name = %s AND modifier_id != %s"
            result = self.db.execute_query(query, (menu_item_id, modifier_name, exclude_modifier_id), fetch_one=True)
        else:
            query = "SELECT COUNT(*) as count FROM Modifier WHERE menu_item_id = %s AND name = %s"
            result = self.db.execute_query(query, (menu_item_id, modifier_name), fetch_one=True)
        return result and result['count'] == 0 if result else False
    
    def check_menu_item_available(self, menu_item_id: int) -> bool:
        """Check if menu item is available (BR-022)."""
        query = "SELECT is_available FROM MenuItem WHERE menu_item_id = %s"
        result = self.db.execute_query(query, (menu_item_id,), fetch_one=True)
        return result and result['is_available'] == 1 if result else False
    
    def get_restaurant_business_hours(self, restaurant_id: int, day_of_week: str) -> Optional[dict]:
        """Get business hours for restaurant on specific day (BR-023)."""
        query = "SELECT * FROM BusinessHours WHERE restaurant_id = %s AND day_of_week = %s"
        result = self.db.execute_query(query, (restaurant_id, day_of_week), fetch_one=True)
        return result
    
    def get_order_refund_amount(self, order_id: int) -> float:
        """Calculate total refunded amount for an order (BR-038)."""
        query = "SELECT COALESCE(SUM(refund_amount), 0) as total_refunded FROM Refund WHERE order_id = %s AND status = 'APPROVED'"
        result = self.db.execute_query(query, (order_id,), fetch_one=True)
        return result['total_refunded'] if result else 0.0
