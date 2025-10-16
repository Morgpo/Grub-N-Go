from typing import List, Optional
from datetime import datetime
from database import get_db_manager
from models import (
    Refund, RefundCreate, RefundUpdate,
    RefundStatusEnum, PaginationParams
)


class RefundCRUD:
    """CRUD operations for order refunds (BR-032)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_refund(self, refund_data: RefundCreate, requested_by: Optional[int] = None) -> int:
        """Create a new refund request."""
        query = """INSERT INTO Refund (order_id, refund_amount, refund_reason, status, requested_by) 
                   VALUES (%s, %s, %s, 'PENDING', %s)"""
        return self.db.execute_update(query, (
            refund_data.order_id, refund_data.refund_amount,
            refund_data.refund_reason, requested_by
        ))
    
    def get_refund_by_id(self, refund_id: int) -> Optional[Refund]:
        """Get refund by ID."""
        query = "SELECT * FROM Refund WHERE refund_id = %s"
        result = self.db.execute_query(query, (refund_id,), fetch_one=True)
        return Refund(**result) if result else None
    
    def get_refunds_by_order(self, order_id: int) -> List[Refund]:
        """Get all refunds for an order."""
        query = "SELECT * FROM Refund WHERE order_id = %s ORDER BY requested_at DESC"
        results = self.db.execute_query(query, (order_id,))
        return [Refund(**row) for row in results] if results else []
    
    def get_refunds_by_status(self, status: RefundStatusEnum, pagination: Optional[PaginationParams] = None) -> List[Refund]:
        """Get refunds by status."""
        query = "SELECT * FROM Refund WHERE status = %s ORDER BY requested_at DESC"
        params = [status.value]
        
        if pagination:
            query += " LIMIT %s OFFSET %s"
            params.extend([pagination.limit, pagination.offset])
        
        results = self.db.execute_query(query, tuple(params))
        return [Refund(**row) for row in results] if results else []
    
    def get_pending_refunds(self, pagination: Optional[PaginationParams] = None) -> List[Refund]:
        """Get all pending refunds."""
        return self.get_refunds_by_status(RefundStatusEnum.PENDING, pagination)
    
    def get_refunds_by_customer(self, customer_id: int, pagination: Optional[PaginationParams] = None) -> List[dict]:
        """Get refunds for a customer with order details."""
        query = """
        SELECT r.*, o.customer_id, o.restaurant_id, o.total as order_total,
               res.restaurant_name
        FROM Refund r
        JOIN `Order` o ON r.order_id = o.order_id
        JOIN Restaurant res ON o.restaurant_id = res.restaurant_id
        WHERE o.customer_id = %s
        ORDER BY r.requested_at DESC
        """
        params = [customer_id]
        
        if pagination:
            query += " LIMIT %s OFFSET %s"
            params.extend([pagination.limit, pagination.offset])
        
        results = self.db.execute_query(query, tuple(params))
        return results if results else []
    
    def get_refunds_by_restaurant(self, restaurant_id: int, pagination: Optional[PaginationParams] = None) -> List[dict]:
        """Get refunds for a restaurant with order details."""
        query = """
        SELECT r.*, o.customer_id, o.restaurant_id, o.total as order_total,
               c.customer_name
        FROM Refund r
        JOIN `Order` o ON r.order_id = o.order_id
        JOIN Customer c ON o.customer_id = c.customer_id
        WHERE o.restaurant_id = %s
        ORDER BY r.requested_at DESC
        """
        params = [restaurant_id]
        
        if pagination:
            query += " LIMIT %s OFFSET %s"
            params.extend([pagination.limit, pagination.offset])
        
        results = self.db.execute_query(query, tuple(params))
        return results if results else []
    
    def get_total_refunded_amount(self, order_id: int) -> float:
        """Get total amount refunded for an order."""
        query = """SELECT COALESCE(SUM(refund_amount), 0) as total_refunded 
                   FROM Refund 
                   WHERE order_id = %s AND status = 'COMPLETED'"""
        result = self.db.execute_query(query, (order_id,), fetch_one=True)
        return float(result['total_refunded']) if result else 0.0
    
    def update_refund(self, refund_id: int, refund_data: RefundUpdate) -> int:
        """Update refund information."""
        updates = []
        params = []
        
        if refund_data.status is not None:
            updates.append("status = %s")
            params.append(refund_data.status.value)
        
        if refund_data.processed_at is not None:
            updates.append("processed_at = %s")
            params.append(refund_data.processed_at)
        
        if not updates:
            return 0
        
        params.append(refund_id)
        query = f"UPDATE Refund SET {', '.join(updates)} WHERE refund_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def approve_refund(self, refund_id: int, transaction_id: Optional[int] = None) -> int:
        """Approve and process a refund."""
        updates = ["status = 'COMPLETED'", "processed_at = CURRENT_TIMESTAMP"]
        params = []
        
        if transaction_id:
            updates.append("transaction_id = %s")
            params.append(transaction_id)
        
        params.append(refund_id)
        query = f"UPDATE Refund SET {', '.join(updates)} WHERE refund_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def reject_refund(self, refund_id: int) -> int:
        """Reject a refund request."""
        query = "UPDATE Refund SET status = 'FAILED', processed_at = CURRENT_TIMESTAMP WHERE refund_id = %s"
        return self.db.execute_update(query, (refund_id,))
    
    def link_transaction(self, refund_id: int, transaction_id: int) -> int:
        """Link a refund to a transaction."""
        query = "UPDATE Refund SET transaction_id = %s WHERE refund_id = %s"
        return self.db.execute_update(query, (transaction_id, refund_id))
    
    def delete_refund(self, refund_id: int) -> int:
        """Delete refund (only for PENDING status)."""
        query = "DELETE FROM Refund WHERE refund_id = %s AND status = 'PENDING'"
        return self.db.execute_update(query, (refund_id,))
    
    def get_refund_statistics(self, start_date: Optional[datetime] = None, 
                            end_date: Optional[datetime] = None) -> dict:
        """Get refund statistics for a date range."""
        base_query = """
        SELECT 
            COUNT(*) as total_refunds,
            COUNT(CASE WHEN status = 'PENDING' THEN 1 END) as pending_refunds,
            COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_refunds,
            COUNT(CASE WHEN status = 'FAILED' THEN 1 END) as failed_refunds,
            COALESCE(SUM(CASE WHEN status = 'COMPLETED' THEN refund_amount ELSE 0 END), 0) as total_refunded_amount,
            COALESCE(AVG(CASE WHEN status = 'COMPLETED' THEN refund_amount END), 0) as avg_refund_amount
        FROM Refund
        WHERE 1=1
        """
        
        params = []
        if start_date:
            base_query += " AND requested_at >= %s"
            params.append(start_date)
        
        if end_date:
            base_query += " AND requested_at <= %s"
            params.append(end_date)
        
        result = self.db.execute_query(base_query, tuple(params), fetch_one=True)
        return result if result else {}
    
    def count_refunds_by_status(self, status: RefundStatusEnum) -> int:
        """Count refunds by status."""
        query = "SELECT COUNT(*) as count FROM Refund WHERE status = %s"
        result = self.db.execute_query(query, (status.value,), fetch_one=True)
        return result['count'] if result else 0
