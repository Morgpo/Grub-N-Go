from typing import List, Optional
from database import get_db_manager
from models import (
    Order, OrderCreate, OrderUpdate, OrderStatusEnum,
    OrderItem, OrderItemCreate, OrderItemUpdate,
    OrderItemModifier, OrderItemModifierCreate,
    OrderTotalCalculation
)


class OrderCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def create_order(self, order_data: OrderCreate) -> int:
        """Create a new order (BR-021, BR-022, BR-023, BR-026)."""
        query = """INSERT INTO `Order` (customer_id, restaurant_id, delivery_address_id, 
                   delivery_street, delivery_city, delivery_state, delivery_postal_code, delivery_country,
                   status, subtotal, tax, tax_rate, delivery_fee, service_fee, tip, discount, total, 
                   payment_method_id) 
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            order_data.customer_id,
            order_data.restaurant_id,
            order_data.delivery_address_id,
            order_data.delivery_street,
            order_data.delivery_city,
            order_data.delivery_state,
            order_data.delivery_postal_code,
            order_data.delivery_country,
            order_data.status.value,
            order_data.subtotal,
            order_data.tax,
            order_data.tax_rate,
            order_data.delivery_fee,
            order_data.service_fee,
            order_data.tip,
            order_data.discount,
            order_data.total,
            order_data.payment_method_id
        ))
    
    def get_order_by_id(self, order_id: int) -> Optional[Order]:
        """Get order by ID with full details (BR-029)."""
        query = """
        SELECT o.*, 
               c.customer_name, c.phone as customer_phone,
               r.restaurant_name, r.contact_phone as restaurant_phone,
               pm.payment_type, pm.card_last_four
        FROM `Order` o 
        JOIN Customer c ON o.customer_id = c.customer_id 
        JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
        LEFT JOIN PaymentMethod pm ON o.payment_method_id = pm.payment_method_id
        WHERE o.order_id = %s
        """
        result = self.db.execute_query(query, (order_id,), fetch_one=True)
        return Order(**result) if result else None
    
    def get_orders_by_customer(self, customer_id: int) -> List[Order]:
        """Get all orders for a customer."""
        query = """
        SELECT o.*, r.restaurant_name, r.operating_status
        FROM `Order` o 
        JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
        WHERE o.customer_id = %s 
        ORDER BY o.created_at DESC
        """
        results = self.db.execute_query(query, (customer_id,))
        return [Order(**row) for row in results] if results else []
    
    def get_active_orders_by_customer(self, customer_id: int) -> List[Order]:
        """Get active orders for a customer (not completed/cancelled)."""
        query = """
        SELECT o.*, r.restaurant_name 
        FROM `Order` o 
        JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
        WHERE o.customer_id = %s 
          AND o.status NOT IN ('DELIVERED', 'CANCELLED', 'FAILED')
        ORDER BY o.created_at DESC
        """
        results = self.db.execute_query(query, (customer_id,))
        return [Order(**row) for row in results] if results else []
    
    def get_orders_by_restaurant(self, restaurant_id: int) -> List[Order]:
        """Get all orders for a restaurant."""
        query = """
        SELECT o.*, c.customer_name, c.phone as customer_phone
        FROM `Order` o 
        JOIN Customer c ON o.customer_id = c.customer_id 
        WHERE o.restaurant_id = %s 
        ORDER BY o.created_at DESC
        """
        results = self.db.execute_query(query, (restaurant_id,))
        return [Order(**row) for row in results] if results else []
    
    def get_active_orders_by_restaurant(self, restaurant_id: int) -> List[Order]:
        """Get pending/confirmed orders for a restaurant (BR-030)."""
        query = """
        SELECT o.*, c.customer_name, c.phone as customer_phone
        FROM `Order` o 
        JOIN Customer c ON o.customer_id = c.customer_id 
        WHERE o.restaurant_id = %s 
          AND o.status IN ('CONFIRMED', 'PREPARING')
        ORDER BY o.confirmed_at ASC
        """
        results = self.db.execute_query(query, (restaurant_id,))
        return [Order(**row) for row in results] if results else []
    
    def get_orders_by_date_range(self, start_date, end_date) -> List[Order]:
        """Get orders within date range."""
        query = """
        SELECT o.*, c.customer_name, r.restaurant_name 
        FROM `Order` o 
        JOIN Customer c ON o.customer_id = c.customer_id 
        JOIN Restaurant r ON o.restaurant_id = r.restaurant_id 
        WHERE o.created_at BETWEEN %s AND %s
        ORDER BY o.created_at DESC
        """
        results = self.db.execute_query(query, (start_date, end_date))
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
        
        if order_data.tax_rate is not None:
            updates.append("tax_rate = %s")
            params.append(order_data.tax_rate)
        
        if order_data.delivery_fee is not None:
            updates.append("delivery_fee = %s")
            params.append(order_data.delivery_fee)
        
        if order_data.service_fee is not None:
            updates.append("service_fee = %s")
            params.append(order_data.service_fee)
        
        if order_data.tip is not None:
            updates.append("tip = %s")
            params.append(order_data.tip)
        
        if order_data.discount is not None:
            updates.append("discount = %s")
            params.append(order_data.discount)
        
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
        """Update order status with appropriate timestamp (BR-029, BR-030, BR-031)."""
        query = """
        UPDATE `Order` 
        SET status = %s, 
            confirmed_at = CASE WHEN %s = 'CONFIRMED' THEN CURRENT_TIMESTAMP ELSE confirmed_at END,
            prepared_at = CASE WHEN %s = 'PREPARING' THEN CURRENT_TIMESTAMP ELSE prepared_at END,
            ready_at = CASE WHEN %s = 'READY' THEN CURRENT_TIMESTAMP ELSE ready_at END,
            picked_up_at = CASE WHEN %s = 'OUT_FOR_DELIVERY' THEN CURRENT_TIMESTAMP ELSE picked_up_at END,
            delivered_at = CASE WHEN %s = 'DELIVERED' THEN CURRENT_TIMESTAMP ELSE delivered_at END,
            cancelled_at = CASE WHEN %s = 'CANCELLED' THEN CURRENT_TIMESTAMP ELSE cancelled_at END,
            updated_at = CURRENT_TIMESTAMP 
        WHERE order_id = %s
        """
        status_value = status.value
        return self.db.execute_update(query, (status_value, status_value, status_value, status_value, 
                                             status_value, status_value, status_value, order_id))
    
    def update_order_totals(self, order_id: int, subtotal: float, tax: float, tax_rate: Optional[float],
                           delivery_fee: float, service_fee: float, tip: float, discount: float, total: float) -> int:
        """Update order totals (BR-026)."""
        query = """UPDATE `Order` 
                   SET subtotal = %s, tax = %s, tax_rate = %s, delivery_fee = %s, 
                       service_fee = %s, tip = %s, discount = %s, total = %s, 
                       updated_at = CURRENT_TIMESTAMP 
                   WHERE order_id = %s"""
        return self.db.execute_update(query, (subtotal, tax, tax_rate, delivery_fee, 
                                             service_fee, tip, discount, total, order_id))
    
    def update_payment_status(self, order_id: int, is_paid: bool) -> int:
        """Update payment status."""
        query = "UPDATE `Order` SET is_paid = %s, updated_at = CURRENT_TIMESTAMP WHERE order_id = %s"
        return self.db.execute_update(query, (is_paid, order_id))
    
    def cancel_order(self, order_id: int) -> int:
        """Cancel order (BR-031)."""
        query = "UPDATE `Order` SET status = 'CANCELLED', cancelled_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE order_id = %s"
        return self.db.execute_update(query, (order_id,))
    
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
    
    def create_order_item(self, order_id: int, menu_item_id: int, quantity: int, 
                         unit_price: float, item_name: str, item_description: Optional[str] = None,
                         notes: Optional[str] = None) -> int:
        """Create a new order item with snapshot (BR-027)."""
        query = """INSERT INTO OrderItem 
                   (order_id, menu_item_id, quantity, unit_price, item_name, item_description, notes) 
                   VALUES (%s, %s, %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (order_id, menu_item_id, quantity, unit_price, 
                                             item_name, item_description, notes))
    
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
    
    def check_order_item_modifiable(self, order_item_id: int) -> bool:
        """Check if order item can be modified (BR-027 - only PENDING orders)."""
        query = """SELECT o.status FROM `Order` o 
                   JOIN OrderItem oi ON o.order_id = oi.order_id 
                   WHERE oi.order_item_id = %s"""
        result = self.db.execute_query(query, (order_item_id,), fetch_one=True)
        return result and result['status'] == 'PENDING' if result else False
    
    def update_order_item(self, order_item_id: int, quantity: Optional[int] = None, 
                         notes: Optional[str] = None) -> int:
        """Update order item (BR-027 - immutable after order confirmation)."""
        if not self.check_order_item_modifiable(order_item_id):
            raise ValueError("Order item cannot be modified after order confirmation (BR-027)")
        
        updates = []
        params = []
        
        if quantity is not None:
            updates.append("quantity = %s")
            params.append(quantity)
        
        if notes is not None:
            updates.append("notes = %s")
            params.append(notes)
        
        if not updates:
            return 0
        
        params.append(order_item_id)
        query = f"UPDATE OrderItem SET {', '.join(updates)} WHERE order_item_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def update_order_item_quantity(self, order_item_id: int, quantity: int) -> int:
        """Update order item quantity only (BR-027 - only PENDING orders)."""
        if not self.check_order_item_modifiable(order_item_id):
            raise ValueError("Order item quantity cannot be modified after order confirmation (BR-027)")
        query = "UPDATE OrderItem SET quantity = %s WHERE order_item_id = %s"
        return self.db.execute_update(query, (quantity, order_item_id))
    
    def delete_order_item(self, order_item_id: int) -> int:
        """Delete order item (BR-027 - only from PENDING orders)."""
        if not self.check_order_item_modifiable(order_item_id):
            raise ValueError("Order item cannot be deleted after order confirmation (BR-027)")
        query = "DELETE FROM OrderItem WHERE order_item_id = %s"
        return self.db.execute_update(query, (order_item_id,))
    
    def delete_all_order_items(self, order_id: int) -> int:
        """Delete all order items for an order (BR-027 - only PENDING orders)."""
        # Check if order is PENDING
        check_query = "SELECT status FROM `Order` WHERE order_id = %s"
        result = self.db.execute_query(check_query, (order_id,), fetch_one=True)
        if result and result['status'] != 'PENDING':
            raise ValueError("Order items cannot be deleted after order confirmation (BR-027)")
        
        query = "DELETE FROM OrderItem WHERE order_id = %s"
        return self.db.execute_update(query, (order_id,))


class OrderItemModifierCRUD:
    """CRUD operations for order item modifiers with snapshots (BR-020, BR-027)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_order_item_modifier(self, order_item_id: int, modifier_option_id: int, 
                                   modifier_name: str, option_name: str, price_delta: float) -> int:
        """Create order item modifier with snapshot (BR-027)."""
        query = """INSERT INTO OrderItemModifier 
                   (order_item_id, modifier_option_id, modifier_name, option_name, price_delta) 
                   VALUES (%s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (order_item_id, modifier_option_id, 
                                             modifier_name, option_name, price_delta))
    
    def get_order_item_modifier_by_id(self, order_item_modifier_id: int) -> Optional[dict]:
        """Get order item modifier by ID."""
        query = "SELECT * FROM OrderItemModifier WHERE order_item_modifier_id = %s"
        result = self.db.execute_query(query, (order_item_modifier_id,), fetch_one=True)
        return result
    
    def get_order_item_modifiers(self, order_item_id: int) -> List[dict]:
        """Get all modifiers for an order item."""
        query = """SELECT * FROM OrderItemModifier 
                   WHERE order_item_id = %s 
                   ORDER BY order_item_modifier_id"""
        results = self.db.execute_query(query, (order_item_id,))
        return results if results else []
    
    def get_order_modifiers_with_info(self, order_id: int) -> List[dict]:
        """Get all modifiers for all items in an order."""
        query = """
        SELECT oim.*, oi.order_id, oi.quantity as item_quantity
        FROM OrderItemModifier oim
        JOIN OrderItem oi ON oim.order_item_id = oi.order_item_id
        WHERE oi.order_id = %s
        ORDER BY oi.order_item_id, oim.order_item_modifier_id
        """
        results = self.db.execute_query(query, (order_id,))
        return results if results else []
    
    def check_order_item_modifier_deletable(self, order_item_id: int) -> bool:
        """Check if order item modifiers can be deleted (BR-027 - only PENDING orders)."""
        query = """SELECT o.status FROM `Order` o 
                   JOIN OrderItem oi ON o.order_id = oi.order_id 
                   WHERE oi.order_item_id = %s"""
        result = self.db.execute_query(query, (order_item_id,), fetch_one=True)
        return result and result['status'] == 'PENDING' if result else False
    
    def delete_order_item_modifier(self, order_item_modifier_id: int) -> int:
        """Delete order item modifier (BR-027 - only from PENDING orders)."""
        # Get order_item_id first
        get_query = "SELECT order_item_id FROM OrderItemModifier WHERE order_item_modifier_id = %s"
        result = self.db.execute_query(get_query, (order_item_modifier_id,), fetch_one=True)
        
        if result and not self.check_order_item_modifier_deletable(result['order_item_id']):
            raise ValueError("Order item modifier cannot be deleted after order confirmation (BR-027)")
        
        query = "DELETE FROM OrderItemModifier WHERE order_item_modifier_id = %s"
        return self.db.execute_update(query, (order_item_modifier_id,))
    
    def delete_all_order_item_modifiers(self, order_item_id: int) -> int:
        """Delete all modifiers for an order item (BR-027 - only PENDING orders)."""
        if not self.check_order_item_modifier_deletable(order_item_id):
            raise ValueError("Order item modifiers cannot be deleted after order confirmation (BR-027)")
        
        query = "DELETE FROM OrderItemModifier WHERE order_item_id = %s"
        return self.db.execute_update(query, (order_item_id,))
    
    def calculate_modifiers_total(self, order_item_id: int) -> float:
        """Calculate total price delta from modifiers for an order item."""
        query = """SELECT SUM(price_delta) as total_modifier_price 
                   FROM OrderItemModifier 
                   WHERE order_item_id = %s"""
        result = self.db.execute_query(query, (order_item_id,), fetch_one=True)
        return result['total_modifier_price'] if result and result['total_modifier_price'] else 0.0
