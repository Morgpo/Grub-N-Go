from typing import List, Optional
from database import get_db_manager
from models import (
    Transaction, TransactionCreate, TransactionUpdate,
    Refund, RefundCreate, RefundUpdate,
    TransactionTypeEnum, TransactionStatusEnum, RefundStatusEnum
)


class TransactionCRUD:
    """CRUD operations for payment transactions (BR-037, BR-038)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_transaction(self, transaction_data: TransactionCreate) -> int:
        """Create a new transaction."""
        query = """INSERT INTO Transaction (order_id, transaction_type, amount, status, payment_provider, external_transaction_id) 
                   VALUES (%s, %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            transaction_data.order_id, transaction_data.transaction_type.value,
            transaction_data.amount, transaction_data.status.value,
            transaction_data.payment_provider, transaction_data.external_transaction_id
        ))
    
    def get_transaction_by_id(self, transaction_id: int) -> Optional[Transaction]:
        """Get transaction by ID."""
        query = "SELECT * FROM Transaction WHERE transaction_id = %s"
        result = self.db.execute_query(query, (transaction_id,), fetch_one=True)
        return Transaction(**result) if result else None
    
    def get_transactions_by_order(self, order_id: int) -> List[Transaction]:
        """Get all transactions for an order."""
        query = "SELECT * FROM Transaction WHERE order_id = %s ORDER BY created_at DESC"
        results = self.db.execute_query(query, (order_id,))
        return [Transaction(**row) for row in results] if results else []
    
    def get_transactions_by_type_and_status(self, transaction_type: TransactionTypeEnum, 
                                           status: TransactionStatusEnum) -> List[dict]:
        """Get transactions by type and status."""
        query = """
        SELECT t.*, o.order_id, o.customer_id, o.restaurant_id
        FROM Transaction t
        JOIN `Order` o ON t.order_id = o.order_id
        WHERE t.transaction_type = %s AND t.status = %s
        ORDER BY t.created_at DESC
        """
        results = self.db.execute_query(query, (transaction_type.value, status.value))
        return results if results else []
    
    def get_pending_transactions(self) -> List[Transaction]:
        """Get pending transactions."""
        query = "SELECT * FROM Transaction WHERE status = 'PENDING' ORDER BY created_at ASC"
        results = self.db.execute_query(query)
        return [Transaction(**row) for row in results] if results else []
    
    def update_transaction(self, transaction_id: int, transaction_data: TransactionUpdate) -> int:
        """Update transaction information."""
        updates = []
        params = []
        
        if transaction_data.status is not None:
            updates.append("status = %s")
            params.append(transaction_data.status.value)
            updates.append("processed_at = CURRENT_TIMESTAMP")
        
        if transaction_data.error_message is not None:
            updates.append("error_message = %s")
            params.append(transaction_data.error_message)
        
        if not updates:
            return 0
        
        params.append(transaction_id)
        query = f"UPDATE Transaction SET {', '.join(updates)} WHERE transaction_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def mark_transaction_successful(self, transaction_id: int) -> int:
        """Mark transaction as successful."""
        query = "UPDATE Transaction SET status = 'SUCCESS', processed_at = CURRENT_TIMESTAMP WHERE transaction_id = %s"
        return self.db.execute_update(query, (transaction_id,))
    
    def mark_transaction_failed(self, transaction_id: int, error_message: str) -> int:
        """Mark transaction as failed."""
        query = "UPDATE Transaction SET status = 'FAILED', processed_at = CURRENT_TIMESTAMP, error_message = %s WHERE transaction_id = %s"
        return self.db.execute_update(query, (error_message, transaction_id))


class RefundCRUD:
    """CRUD operations for refunds (BR-032)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_refund(self, refund_data: RefundCreate) -> int:
        """Create a new refund request."""
        query = """INSERT INTO Refund (order_id, transaction_id, refund_amount, refund_reason, requested_by) 
                   VALUES (%s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            refund_data.order_id, refund_data.transaction_id,
            refund_data.refund_amount, refund_data.refund_reason,
            refund_data.requested_by
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
    
    def get_refunds_by_status(self, status: RefundStatusEnum) -> List[dict]:
        """Get refunds by status."""
        query = """
        SELECT r.*, o.customer_id, o.restaurant_id, c.customer_name, rest.restaurant_name
        FROM Refund r
        JOIN `Order` o ON r.order_id = o.order_id
        JOIN Customer c ON o.customer_id = c.customer_id
        JOIN Restaurant rest ON o.restaurant_id = rest.restaurant_id
        WHERE r.status = %s
        ORDER BY r.requested_at DESC
        """
        results = self.db.execute_query(query, (status.value,))
        return results if results else []
    
    def get_pending_refunds(self) -> List[dict]:
        """Get pending refunds."""
        query = """
        SELECT r.*, o.customer_id, o.restaurant_id
        FROM Refund r
        JOIN `Order` o ON r.order_id = o.order_id
        WHERE r.status = 'PENDING'
        ORDER BY r.requested_at ASC
        """
        results = self.db.execute_query(query)
        return results if results else []
    
    def update_refund(self, refund_id: int, refund_data: RefundUpdate) -> int:
        """Update refund information."""
        updates = []
        params = []
        
        if refund_data.status is not None:
            updates.append("status = %s")
            params.append(refund_data.status.value)
            updates.append("processed_at = CURRENT_TIMESTAMP")
        
        if refund_data.transaction_id is not None:
            updates.append("transaction_id = %s")
            params.append(refund_data.transaction_id)
        
        if not updates:
            return 0
        
        params.append(refund_id)
        query = f"UPDATE Refund SET {', '.join(updates)} WHERE refund_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def mark_refund_completed(self, refund_id: int) -> int:
        """Mark refund as completed."""
        query = "UPDATE Refund SET status = 'COMPLETED', processed_at = CURRENT_TIMESTAMP WHERE refund_id = %s"
        return self.db.execute_update(query, (refund_id,))
    
    def mark_refund_failed(self, refund_id: int) -> int:
        """Mark refund as failed."""
        query = "UPDATE Refund SET status = 'FAILED', processed_at = CURRENT_TIMESTAMP WHERE refund_id = %s"
        return self.db.execute_update(query, (refund_id,))
