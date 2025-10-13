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
        """Get popular menu items for a restaurant (most ordered)."""
        query = """
        SELECT mi.menu_item_id, 
               mi.name, 
               mi.price,
               COUNT(oi.order_item_id) as order_count,
               SUM(oi.quantity) as total_quantity_sold
        FROM MenuItem mi 
        LEFT JOIN OrderItem oi ON mi.menu_item_id = oi.menu_item_id 
        WHERE mi.menu_id IN (SELECT menu_id FROM Menu WHERE restaurant_id = %s)
        GROUP BY mi.menu_item_id, mi.name, mi.price 
        ORDER BY order_count DESC, total_quantity_sold DESC 
        LIMIT %s
        """
        results = self.db.execute_query(query, (restaurant_id, limit))
        return [PopularMenuItem(**row) for row in results] if results else []
    
    def get_customer_order_summary(self, customer_id: int) -> Optional[CustomerOrderSummary]:
        """Get customer order history summary."""
        query = """
        SELECT c.customer_id,
               c.customer_name,
               COUNT(o.order_id) as total_orders,
               COALESCE(SUM(o.total), 0) as total_spent,
               MAX(o.created_at) as last_order_date
        FROM Customer c 
        LEFT JOIN `Order` o ON c.customer_id = o.customer_id 
        WHERE c.customer_id = %s
        GROUP BY c.customer_id, c.customer_name
        """
        result = self.db.execute_query(query, (customer_id,), fetch_one=True)
        return CustomerOrderSummary(**result) if result else None
    
    def get_restaurant_revenue_summary(self, restaurant_id: int) -> Optional[RestaurantRevenueSummary]:
        """Get restaurant revenue summary."""
        query = """
        SELECT r.restaurant_id,
               r.restaurant_name,
               COUNT(o.order_id) as total_orders,
               COALESCE(SUM(o.total), 0) as total_revenue,
               COALESCE(AVG(o.total), 0) as average_order_value
        FROM Restaurant r 
        LEFT JOIN `Order` o ON r.restaurant_id = o.restaurant_id 
        WHERE r.restaurant_id = %s 
          AND (o.status IN ('COMPLETED', 'ARCHIVED') OR o.status IS NULL)
        GROUP BY r.restaurant_id, r.restaurant_name
        """
        result = self.db.execute_query(query, (restaurant_id,), fetch_one=True)
        return RestaurantRevenueSummary(**result) if result else None
    
    def get_all_customer_summaries(self) -> List[CustomerOrderSummary]:
        """Get order summaries for all customers."""
        query = """
        SELECT c.customer_id,
               c.customer_name,
               COUNT(o.order_id) as total_orders,
               COALESCE(SUM(o.total), 0) as total_spent,
               MAX(o.created_at) as last_order_date
        FROM Customer c 
        LEFT JOIN `Order` o ON c.customer_id = o.customer_id 
        GROUP BY c.customer_id, c.customer_name
        ORDER BY total_spent DESC
        """
        results = self.db.execute_query(query)
        return [CustomerOrderSummary(**row) for row in results] if results else []
    
    def get_all_restaurant_summaries(self) -> List[RestaurantRevenueSummary]:
        """Get revenue summaries for all restaurants."""
        query = """
        SELECT r.restaurant_id,
               r.restaurant_name,
               COUNT(o.order_id) as total_orders,
               COALESCE(SUM(o.total), 0) as total_revenue,
               COALESCE(AVG(o.total), 0) as average_order_value
        FROM Restaurant r 
        LEFT JOIN `Order` o ON r.restaurant_id = o.restaurant_id 
        WHERE o.status IN ('COMPLETED', 'ARCHIVED') OR o.status IS NULL
        GROUP BY r.restaurant_id, r.restaurant_name
        ORDER BY total_revenue DESC
        """
        results = self.db.execute_query(query)
        return [RestaurantRevenueSummary(**row) for row in results] if results else []
