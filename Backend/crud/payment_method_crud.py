from typing import List, Optional
from database import get_db_manager
from models import (
    PaymentMethod, PaymentMethodCreate, PaymentMethodUpdate,
    PaymentTypeEnum, PaginationParams
)


class PaymentMethodCRUD:
    """CRUD operations for customer payment methods (BR-008, BR-037)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_payment_method(self, payment_data: PaymentMethodCreate) -> int:
        """Create a new payment method for a customer."""
        # If this is set as default, unset other defaults first
        if payment_data.is_default:
            self.unset_all_defaults(payment_data.customer_id)
        
        query = """INSERT INTO PaymentMethod (customer_id, payment_type, payment_token, card_last_four, 
                   card_brand, expiry_month, expiry_year, is_default) 
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            payment_data.customer_id, payment_data.payment_type.value,
            payment_data.payment_token, payment_data.card_last_four,
            payment_data.card_brand, payment_data.expiry_month,
            payment_data.expiry_year, payment_data.is_default
        ))
    
    def get_payment_method_by_id(self, payment_method_id: int) -> Optional[PaymentMethod]:
        """Get payment method by ID."""
        query = "SELECT * FROM PaymentMethod WHERE payment_method_id = %s"
        result = self.db.execute_query(query, (payment_method_id,), fetch_one=True)
        return PaymentMethod(**result) if result else None
    
    def get_payment_methods_by_customer(self, customer_id: int) -> List[PaymentMethod]:
        """Get all payment methods for a customer."""
        query = "SELECT * FROM PaymentMethod WHERE customer_id = %s ORDER BY is_default DESC, created_at DESC"
        results = self.db.execute_query(query, (customer_id,))
        return [PaymentMethod(**row) for row in results] if results else []
    
    def get_default_payment_method(self, customer_id: int) -> Optional[PaymentMethod]:
        """Get default payment method for a customer."""
        query = "SELECT * FROM PaymentMethod WHERE customer_id = %s AND is_default = 1 LIMIT 1"
        result = self.db.execute_query(query, (customer_id,), fetch_one=True)
        return PaymentMethod(**result) if result else None
    
    def get_payment_methods_by_type(self, customer_id: int, payment_type: PaymentTypeEnum) -> List[PaymentMethod]:
        """Get payment methods by type for a customer."""
        query = "SELECT * FROM PaymentMethod WHERE customer_id = %s AND payment_type = %s ORDER BY created_at DESC"
        results = self.db.execute_query(query, (customer_id, payment_type.value))
        return [PaymentMethod(**row) for row in results] if results else []
    
    def get_expiring_cards(self, customer_id: int, months_ahead: int = 3) -> List[PaymentMethod]:
        """Get cards expiring within specified months."""
        query = """SELECT * FROM PaymentMethod 
                   WHERE customer_id = %s 
                   AND payment_type = 'CARD' 
                   AND (expiry_year < YEAR(CURDATE()) 
                        OR (expiry_year = YEAR(CURDATE()) AND expiry_month <= MONTH(CURDATE()) + %s))
                   ORDER BY expiry_year, expiry_month"""
        results = self.db.execute_query(query, (customer_id, months_ahead))
        return [PaymentMethod(**row) for row in results] if results else []
    
    def update_payment_method(self, payment_method_id: int, payment_data: PaymentMethodUpdate) -> int:
        """Update payment method information."""
        updates = []
        params = []
        
        if payment_data.expiry_month is not None:
            updates.append("expiry_month = %s")
            params.append(payment_data.expiry_month)
        
        if payment_data.expiry_year is not None:
            updates.append("expiry_year = %s")
            params.append(payment_data.expiry_year)
        
        if payment_data.is_default is not None:
            updates.append("is_default = %s")
            params.append(payment_data.is_default)
            
            # If setting as default, unset other defaults first
            if payment_data.is_default:
                # Get customer_id for this payment method
                payment_method = self.get_payment_method_by_id(payment_method_id)
                if payment_method:
                    self.unset_all_defaults(payment_method.customer_id)
        
        if not updates:
            return 0
        
        updates.append("updated_at = CURRENT_TIMESTAMP")
        params.append(payment_method_id)
        
        query = f"UPDATE PaymentMethod SET {', '.join(updates)} WHERE payment_method_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def set_default_payment_method(self, customer_id: int, payment_method_id: int) -> int:
        """Set a new default payment method (unset old default first)."""
        # Unset all defaults for this customer
        self.unset_all_defaults(customer_id)
        # Set new default
        query = "UPDATE PaymentMethod SET is_default = 1, updated_at = CURRENT_TIMESTAMP WHERE payment_method_id = %s"
        return self.db.execute_update(query, (payment_method_id,))
    
    def unset_all_defaults(self, customer_id: int) -> int:
        """Unset all default payment methods for a customer."""
        query = "UPDATE PaymentMethod SET is_default = 0 WHERE customer_id = %s"
        return self.db.execute_update(query, (customer_id,))
    
    def delete_payment_method(self, payment_method_id: int) -> int:
        """Delete payment method."""
        query = "DELETE FROM PaymentMethod WHERE payment_method_id = %s"
        return self.db.execute_update(query, (payment_method_id,))
    
    def delete_payment_methods_by_customer(self, customer_id: int) -> int:
        """Delete all payment methods for a customer."""
        query = "DELETE FROM PaymentMethod WHERE customer_id = %s"
        return self.db.execute_update(query, (customer_id,))
    
    def count_payment_methods_by_customer(self, customer_id: int) -> int:
        """Count payment methods for a customer."""
        query = "SELECT COUNT(*) as count FROM PaymentMethod WHERE customer_id = %s"
        result = self.db.execute_query(query, (customer_id,), fetch_one=True)
        return result['count'] if result else 0
    
    def verify_payment_method_ownership(self, payment_method_id: int, customer_id: int) -> bool:
        """Verify that a payment method belongs to a customer."""
        query = "SELECT COUNT(*) as count FROM PaymentMethod WHERE payment_method_id = %s AND customer_id = %s"
        result = self.db.execute_query(query, (payment_method_id, customer_id), fetch_one=True)
        return result['count'] > 0 if result else False
