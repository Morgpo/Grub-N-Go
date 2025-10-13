from typing import List, Optional
from database import get_db_manager
from models import (
    Order, OrderCreate, OrderUpdate, OrderStatusEnum,
    OrderItem, OrderItemCreate, OrderItemUpdate,
    OrderTotalCalculation
)


class OrderCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def create_order(self, order_data: OrderCreate) -> int:
        """Create a new order."""
        query = "INSERT INTO `Order` (customer_id, restaurant_id, status, subtotal, tax, total) VALUES (%s, %s, %s, %s, %s, %s)"
        return self.db.execute_update(query, (
            order_data.customer_id,
            order_data.restaurant_id,
            order_data.status.value,
            order_data.subtotal,
            order_data.tax,
            order_data.total
        ))
    
    def get_order_by_id(self, order_id: int) -> Optional[Order]:
        """Get order by ID with customer and restaurant info."""
        query = """
        SELECT o.*, 
               c.customer_name, 
               r.restaurant_name 
        FROM `Order` o 
        JOIN Customer c ON o.customer_id = c.customer_id 
        JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
        WHERE o.order_id = %s
        """
        result = self.db.execute_query(query, (order_id,), fetch_one=True)
        return Order(**result) if result else None
    
    def get_orders_by_customer(self, customer_id: int) -> List[Order]:
        """Get all orders for a customer."""
        query = """
        SELECT o.*, r.restaurant_name 
        FROM `Order` o 
        JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
        WHERE o.customer_id = %s 
        ORDER BY o.created_at DESC
        """
        results = self.db.execute_query(query, (customer_id,))
        return [Order(**row) for row in results] if results else []
    
    def get_orders_by_restaurant(self, restaurant_id: int) -> List[Order]:
        """Get all orders for a restaurant."""
        query = """
        SELECT o.*, c.customer_name 
        FROM `Order` o 
        JOIN Customer c ON o.customer_id = c.customer_id 
        WHERE o.restaurant_id = %s 
        ORDER BY o.created_at DESC
        """
        results = self.db.execute_query(query, (restaurant_id,))
        return [Order(**row) for row in results] if results else []
    
    def get_orders_by_status(self, status: OrderStatusEnum) -> List[Order]:
        """Get orders by status."""
        query = """
        SELECT o.*, c.customer_name, r.restaurant_name 
        FROM `Order` o 
        JOIN Customer c ON o.customer_id = c.customer_id 
        JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
        WHERE o.status = %s 
        ORDER BY o.created_at DESC
        """
        results = self.db.execute_query(query, (status.value,))
        return [Order(**row) for row in results] if results else []
    
    def get_pending_orders_by_restaurant(self, restaurant_id: int) -> List[Order]:
        """Get pending orders for a restaurant."""
        query = """
        SELECT o.*, c.customer_name 
        FROM `Order` o 
        JOIN Customer c ON o.customer_id = c.customer_id 
        WHERE o.restaurant_id = %s AND o.status = 'PENDING' 
        ORDER BY o.submitted_at ASC
        """
        results = self.db.execute_query(query, (restaurant_id,))
        return [Order(**row) for row in results] if results else []
    
    def update_order(self, order_id: int, order_data: OrderUpdate) -> int:
        """Update order information."""
        updates = []
        params = []
        
        if order_data.status is not None:
            updates.append("status = %s")
            params.append(order_data.status.value)
        
        if order_data.subtotal is not None:
            updates.append("subtotal = %s")
            params.append(order_data.subtotal)
        
        if order_data.tax is not None:
            updates.append("tax = %s")
            params.append(order_data.tax)
        
        if order_data.total is not None:
            updates.append("total = %s")
            params.append(order_data.total)
        
        if not updates:
            return 0
        
        updates.append("updated_at = CURRENT_TIMESTAMP")
        params.append(order_id)
        
        query = f"UPDATE `Order` SET {', '.join(updates)} WHERE order_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def update_order_status(self, order_id: int, status: OrderStatusEnum) -> int:
        """Update order status with appropriate timestamps."""
        query = """
        UPDATE `Order` 
        SET status = %s, 
            submitted_at = CASE WHEN %s = 'PENDING' THEN CURRENT_TIMESTAMP ELSE submitted_at END,
            completed_at = CASE WHEN %s = 'COMPLETED' THEN CURRENT_TIMESTAMP ELSE completed_at END,
            archived_at = CASE WHEN %s = 'ARCHIVED' THEN CURRENT_TIMESTAMP ELSE archived_at END,
            updated_at = CURRENT_TIMESTAMP 
        WHERE order_id = %s
        """
        status_value = status.value
        return self.db.execute_update(query, (status_value, status_value, status_value, status_value, order_id))
    
    def update_order_totals(self, order_id: int, subtotal: float, tax: float, total: float) -> int:
        """Update order totals."""
        query = "UPDATE `Order` SET subtotal = %s, tax = %s, total = %s, updated_at = CURRENT_TIMESTAMP WHERE order_id = %s"
        return self.db.execute_update(query, (subtotal, tax, total, order_id))
    
    def delete_order(self, order_id: int) -> int:
        """Delete order."""
        query = "DELETE FROM `Order` WHERE order_id = %s"
        return self.db.execute_update(query, (order_id,))
    
    def calculate_order_total(self, order_id: int) -> Optional[OrderTotalCalculation]:
        """Get order total calculation from order items."""
        query = """
        SELECT order_id,
               SUM(quantity * unit_price) as calculated_subtotal
        FROM OrderItem 
        WHERE order_id = %s 
        GROUP BY order_id
        """
        result = self.db.execute_query(query, (order_id,), fetch_one=True)
        return OrderTotalCalculation(**result) if result else None


class OrderItemCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def create_order_item(self, order_item_data: OrderItemCreate) -> int:
        """Create a new order item."""
        query = "INSERT INTO OrderItem (order_id, menu_item_id, quantity, unit_price, notes) VALUES (%s, %s, %s, %s, %s)"
        return self.db.execute_update(query, (
            order_item_data.order_id,
            order_item_data.menu_item_id,
            order_item_data.quantity,
            order_item_data.unit_price,
            order_item_data.notes
        ))
    
    def get_order_item_by_id(self, order_item_id: int) -> Optional[OrderItem]:
        """Get order item by ID."""
        query = """
        SELECT oi.*, mi.name as item_name, mi.description 
        FROM OrderItem oi 
        JOIN MenuItem mi ON oi.menu_item_id = mi.menu_item_id 
        WHERE oi.order_item_id = %s
        """
        result = self.db.execute_query(query, (order_item_id,), fetch_one=True)
        return OrderItem(**result) if result else None
    
    def get_order_items_by_order(self, order_id: int) -> List[OrderItem]:
        """Get all order items for an order."""
        query = """
        SELECT oi.*, mi.name as item_name, mi.description 
        FROM OrderItem oi 
        JOIN MenuItem mi ON oi.menu_item_id = mi.menu_item_id 
        WHERE oi.order_id = %s 
        ORDER BY oi.order_item_id
        """
        results = self.db.execute_query(query, (order_id,))
        return [OrderItem(**row) for row in results] if results else []
    
    def get_order_items_with_full_info(self, order_id: int) -> List[dict]:
        """Get order items with full order and restaurant info."""
        query = """
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
        WHERE oi.order_id = %s
        """
        results = self.db.execute_query(query, (order_id,))
        return results if results else []
    
    def update_order_item(self, order_item_id: int, order_item_data: OrderItemUpdate) -> int:
        """Update order item information."""
        updates = []
        params = []
        
        if order_item_data.quantity is not None:
            updates.append("quantity = %s")
            params.append(order_item_data.quantity)
        
        if order_item_data.unit_price is not None:
            updates.append("unit_price = %s")
            params.append(order_item_data.unit_price)
        
        if order_item_data.notes is not None:
            updates.append("notes = %s")
            params.append(order_item_data.notes)
        
        if not updates:
            return 0
        
        params.append(order_item_id)
        query = f"UPDATE OrderItem SET {', '.join(updates)} WHERE order_item_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def update_order_item_quantity(self, order_item_id: int, quantity: int) -> int:
        """Update order item quantity only."""
        query = "UPDATE OrderItem SET quantity = %s WHERE order_item_id = %s"
        return self.db.execute_update(query, (quantity, order_item_id))
    
    def delete_order_item(self, order_item_id: int) -> int:
        """Delete order item."""
        query = "DELETE FROM OrderItem WHERE order_item_id = %s"
        return self.db.execute_update(query, (order_item_id,))
    
    def delete_all_order_items(self, order_id: int) -> int:
        """Delete all order items for an order."""
        query = "DELETE FROM OrderItem WHERE order_id = %s"
        return self.db.execute_update(query, (order_id,))
