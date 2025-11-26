from typing import List, Optional
from database import get_db_manager
from models import (
    Address, AddressCreate, AddressUpdate,
    PaginationParams
)


class AddressCRUD:
    """CRUD operations for customer addresses (BR-007)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_address(self, address_data: AddressCreate) -> int:
        """Create a new address for a customer."""
        # If this is set as default, unset other defaults first
        if address_data.is_default:
            self.unset_all_defaults(address_data.customer_id)
        
        query = """INSERT INTO Address (customer_id, address_label, street_address, city, state, postal_code, country, is_default) 
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            address_data.customer_id, address_data.address_label,
            address_data.street_address, address_data.city, address_data.state,
            address_data.postal_code, address_data.country, address_data.is_default
        ))
    
    def get_address_by_id(self, address_id: int) -> Optional[Address]:
        """Get address by ID."""
        query = "SELECT * FROM Address WHERE address_id = %s"
        result = self.db.execute_query(query, (address_id,), fetch_one=True)
        return Address(**result) if result else None
    
    def get_addresses_by_customer(self, customer_id: int) -> List[Address]:
        """Get all addresses for a customer."""
        query = "SELECT * FROM Address WHERE customer_id = %s ORDER BY is_default DESC, created_at DESC"
        results = self.db.execute_query(query, (customer_id,))
        return [Address(**row) for row in results] if results else []
    
    def get_default_address(self, customer_id: int) -> Optional[Address]:
        """Get default address for a customer."""
        query = "SELECT * FROM Address WHERE customer_id = %s AND is_default = 1 LIMIT 1"
        result = self.db.execute_query(query, (customer_id,), fetch_one=True)
        return Address(**result) if result else None
    
    def get_addresses_by_city_state(self, city: str, state: str) -> List[Address]:
        """Get addresses by city and state."""
        query = "SELECT * FROM Address WHERE city = %s AND state = %s ORDER BY street_address"
        results = self.db.execute_query(query, (city, state))
        return [Address(**row) for row in results] if results else []
    
    def update_address(self, address_id: int, address_data: AddressUpdate) -> int:
        """Update address information."""
        updates = []
        params = []
        
        if address_data.address_label is not None:
            updates.append("address_label = %s")
            params.append(address_data.address_label)
        
        if address_data.street_address is not None:
            updates.append("street_address = %s")
            params.append(address_data.street_address)
        
        if address_data.city is not None:
            updates.append("city = %s")
            params.append(address_data.city)
        
        if address_data.state is not None:
            updates.append("state = %s")
            params.append(address_data.state)
        
        if address_data.postal_code is not None:
            updates.append("postal_code = %s")
            params.append(address_data.postal_code)
        
        if address_data.country is not None:
            updates.append("country = %s")
            params.append(address_data.country)
        
        if address_data.is_default is not None:
            updates.append("is_default = %s")
            params.append(address_data.is_default)
            
            # If setting as default, unset other defaults first
            if address_data.is_default:
                # Get customer_id for this address
                address = self.get_address_by_id(address_id)
                if address:
                    self.unset_all_defaults(address.customer_id)
        
        if not updates:
            return 0
        
        updates.append("updated_at = CURRENT_TIMESTAMP")
        params.append(address_id)
        
        query = f"UPDATE Address SET {', '.join(updates)} WHERE address_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def set_default_address(self, customer_id: int, address_id: int) -> int:
        """Set a new default address (unset old default first)."""
        # Unset all defaults for this customer
        self.unset_all_defaults(customer_id)
        # Set new default
        query = "UPDATE Address SET is_default = 1, updated_at = CURRENT_TIMESTAMP WHERE address_id = %s"
        return self.db.execute_update(query, (address_id,))
    
    def unset_all_defaults(self, customer_id: int) -> int:
        """Unset all default addresses for a customer."""
        query = "UPDATE Address SET is_default = 0 WHERE customer_id = %s"
        return self.db.execute_update(query, (customer_id,))
    
    def delete_address(self, address_id: int) -> int:
        """Delete address."""
        query = "DELETE FROM Address WHERE address_id = %s"
        return self.db.execute_update(query, (address_id,))
    
    def delete_addresses_by_customer(self, customer_id: int) -> int:
        """Delete all addresses for a customer."""
        query = "DELETE FROM Address WHERE customer_id = %s"
        return self.db.execute_update(query, (customer_id,))
    
    def count_addresses_by_customer(self, customer_id: int) -> int:
        """Count addresses for a customer."""
        query = "SELECT COUNT(*) as count FROM Address WHERE customer_id = %s"
        result = self.db.execute_query(query, (customer_id,), fetch_one=True)
        return result['count'] if result else 0
