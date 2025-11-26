from typing import List, Optional
from datetime import datetime
from decimal import Decimal
from database import get_db_manager
from models import (
    MenuItemPriceHistory, MenuItemPriceHistoryCreate,
    PaginationParams
)


class MenuItemPriceHistoryCRUD:
    """CRUD operations for menu item price history (BR-033)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_price_history(self, history_data: MenuItemPriceHistoryCreate) -> int:
        """Create a price history record."""
        query = """INSERT INTO MenuItemPriceHistory (menu_item_id, old_price, new_price, changed_by) 
                   VALUES (%s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            history_data.menu_item_id, history_data.old_price,
            history_data.new_price, history_data.changed_by
        ))
    
    def log_price_change(self, menu_item_id: int, old_price: Decimal, new_price: Decimal, 
                        changed_by: Optional[int] = None) -> int:
        """Log a price change for a menu item."""
        history_data = MenuItemPriceHistoryCreate(
            menu_item_id=menu_item_id,
            old_price=old_price,
            new_price=new_price,
            changed_by=changed_by
        )
        return self.create_price_history(history_data)
    
    def get_price_history_by_id(self, price_history_id: int) -> Optional[MenuItemPriceHistory]:
        """Get price history by ID."""
        query = "SELECT * FROM MenuItemPriceHistory WHERE price_history_id = %s"
        result = self.db.execute_query(query, (price_history_id,), fetch_one=True)
        return MenuItemPriceHistory(**result) if result else None
    
    def get_price_history_by_menu_item(self, menu_item_id: int, 
                                     pagination: Optional[PaginationParams] = None) -> List[MenuItemPriceHistory]:
        """Get price history for a menu item."""
        query = "SELECT * FROM MenuItemPriceHistory WHERE menu_item_id = %s ORDER BY changed_at DESC"
        params = [menu_item_id]
        
        if pagination:
            query += " LIMIT %s OFFSET %s"
            params.extend([pagination.limit, pagination.offset])
        
        results = self.db.execute_query(query, tuple(params))
        return [MenuItemPriceHistory(**row) for row in results] if results else []
    
    def get_price_history_by_restaurant(self, restaurant_id: int, 
                                      pagination: Optional[PaginationParams] = None) -> List[dict]:
        """Get price history for all menu items of a restaurant."""
        query = """
        SELECT ph.*, mi.name as item_name, m.name as menu_name
        FROM MenuItemPriceHistory ph
        JOIN MenuItem mi ON ph.menu_item_id = mi.menu_item_id
        JOIN Menu m ON mi.menu_id = m.menu_id
        WHERE m.restaurant_id = %s
        ORDER BY ph.changed_at DESC
        """
        params = [restaurant_id]
        
        if pagination:
            query += " LIMIT %s OFFSET %s"
            params.extend([pagination.limit, pagination.offset])
        
        results = self.db.execute_query(query, tuple(params))
        return results if results else []
    
    def get_recent_price_changes(self, days: int = 30, 
                               pagination: Optional[PaginationParams] = None) -> List[dict]:
        """Get recent price changes across all menu items."""
        query = """
        SELECT ph.*, mi.name as item_name, m.name as menu_name, 
               r.restaurant_name, a.email as changed_by_email
        FROM MenuItemPriceHistory ph
        JOIN MenuItem mi ON ph.menu_item_id = mi.menu_item_id
        JOIN Menu m ON mi.menu_id = m.menu_id
        JOIN Restaurant r ON m.restaurant_id = r.restaurant_id
        LEFT JOIN Account a ON ph.changed_by = a.account_id
        WHERE ph.changed_at >= DATE_SUB(NOW(), INTERVAL %s DAY)
        ORDER BY ph.changed_at DESC
        """
        params = [days]
        
        if pagination:
            query += " LIMIT %s OFFSET %s"
            params.extend([pagination.limit, pagination.offset])
        
        results = self.db.execute_query(query, tuple(params))
        return results if results else []
    
    def get_price_changes_by_user(self, changed_by: int, 
                                pagination: Optional[PaginationParams] = None) -> List[dict]:
        """Get price changes made by a specific user."""
        query = """
        SELECT ph.*, mi.name as item_name, m.name as menu_name, r.restaurant_name
        FROM MenuItemPriceHistory ph
        JOIN MenuItem mi ON ph.menu_item_id = mi.menu_item_id
        JOIN Menu m ON mi.menu_id = m.menu_id
        JOIN Restaurant r ON m.restaurant_id = r.restaurant_id
        WHERE ph.changed_by = %s
        ORDER BY ph.changed_at DESC
        """
        params = [changed_by]
        
        if pagination:
            query += " LIMIT %s OFFSET %s"
            params.extend([pagination.limit, pagination.offset])
        
        results = self.db.execute_query(query, tuple(params))
        return results if results else []
    
    def get_largest_price_increases(self, limit: int = 10) -> List[dict]:
        """Get the largest price increases."""
        query = """
        SELECT ph.*, mi.name as item_name, m.name as menu_name, r.restaurant_name,
               (ph.new_price - ph.old_price) as price_increase,
               ROUND(((ph.new_price - ph.old_price) / ph.old_price) * 100, 2) as percentage_increase
        FROM MenuItemPriceHistory ph
        JOIN MenuItem mi ON ph.menu_item_id = mi.menu_item_id
        JOIN Menu m ON mi.menu_id = m.menu_id
        JOIN Restaurant r ON m.restaurant_id = r.restaurant_id
        WHERE ph.new_price > ph.old_price
        ORDER BY (ph.new_price - ph.old_price) DESC
        LIMIT %s
        """
        results = self.db.execute_query(query, (limit,))
        return results if results else []
    
    def get_largest_price_decreases(self, limit: int = 10) -> List[dict]:
        """Get the largest price decreases."""
        query = """
        SELECT ph.*, mi.name as item_name, m.name as menu_name, r.restaurant_name,
               (ph.old_price - ph.new_price) as price_decrease,
               ROUND(((ph.old_price - ph.new_price) / ph.old_price) * 100, 2) as percentage_decrease
        FROM MenuItemPriceHistory ph
        JOIN MenuItem mi ON ph.menu_item_id = mi.menu_item_id
        JOIN Menu m ON mi.menu_id = m.menu_id
        JOIN Restaurant r ON m.restaurant_id = r.restaurant_id
        WHERE ph.new_price < ph.old_price
        ORDER BY (ph.old_price - ph.new_price) DESC
        LIMIT %s
        """
        results = self.db.execute_query(query, (limit,))
        return results if results else []
    
    def get_current_vs_original_price(self, menu_item_id: int) -> Optional[dict]:
        """Get current price vs original price for a menu item."""
        query = """
        SELECT 
            mi.price as current_price,
            (SELECT ph.old_price FROM MenuItemPriceHistory ph 
             WHERE ph.menu_item_id = %s 
             ORDER BY ph.changed_at ASC LIMIT 1) as original_price,
            COUNT(ph.price_history_id) as total_changes
        FROM MenuItem mi
        LEFT JOIN MenuItemPriceHistory ph ON mi.menu_item_id = ph.menu_item_id
        WHERE mi.menu_item_id = %s
        GROUP BY mi.menu_item_id, mi.price
        """
        result = self.db.execute_query(query, (menu_item_id, menu_item_id), fetch_one=True)
        return result
    
    def get_price_volatility_report(self, restaurant_id: int, days: int = 30) -> List[dict]:
        """Get price volatility report for a restaurant."""
        query = """
        SELECT 
            mi.menu_item_id,
            mi.name as item_name,
            COUNT(ph.price_history_id) as change_count,
            MIN(ph.new_price) as min_price,
            MAX(ph.new_price) as max_price,
            AVG(ph.new_price) as avg_price,
            STDDEV(ph.new_price) as price_volatility
        FROM MenuItem mi
        JOIN Menu m ON mi.menu_id = m.menu_id
        LEFT JOIN MenuItemPriceHistory ph ON mi.menu_item_id = ph.menu_item_id
            AND ph.changed_at >= DATE_SUB(NOW(), INTERVAL %s DAY)
        WHERE m.restaurant_id = %s
        GROUP BY mi.menu_item_id, mi.name
        HAVING COUNT(ph.price_history_id) > 0
        ORDER BY price_volatility DESC
        """
        results = self.db.execute_query(query, (days, restaurant_id))
        return results if results else []
    
    def delete_old_price_history(self, days_to_keep: int = 365) -> int:
        """Delete old price history records (data retention)."""
        query = """DELETE FROM MenuItemPriceHistory 
                   WHERE changed_at < DATE_SUB(NOW(), INTERVAL %s DAY)"""
        return self.db.execute_update(query, (days_to_keep,))
    
    def get_price_history_count(self, menu_item_id: int) -> int:
        """Get count of price history records for a menu item."""
        query = "SELECT COUNT(*) as count FROM MenuItemPriceHistory WHERE menu_item_id = %s"
        result = self.db.execute_query(query, (menu_item_id,), fetch_one=True)
        return result['count'] if result else 0
