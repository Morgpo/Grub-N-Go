from typing import List, Optional
from database import get_db_manager
from models import (
    Account, AccountCreate, AccountUpdate,
    Customer, CustomerCreate, CustomerUpdate,
    Restaurant, RestaurantCreate, RestaurantUpdate,
    PaginationParams
)
import hashlib


class AccountCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def _hash_password(self, password: str) -> str:
        """Hash password using SHA-256."""
        return hashlib.sha256(password.encode()).hexdigest()
    
    def create_account(self, account_data: AccountCreate) -> int:
        """Create a new account."""
        query = "INSERT INTO Account (email, password_hash, role) VALUES (%s, %s, %s)"
        password_hash = self._hash_password(account_data.password)
        params = (account_data.email, password_hash, account_data.role.value)
        return self.db.execute_update(query, params)
    
    def get_account_by_id(self, account_id: int) -> Optional[Account]:
        """Get account by ID."""
        query = "SELECT * FROM Account WHERE account_id = %s"
        result = self.db.execute_query(query, (account_id,), fetch_one=True)
        return Account(**result) if result else None
    
    def get_account_by_email(self, email: str) -> Optional[Account]:
        """Get account by email."""
        query = "SELECT * FROM Account WHERE email = %s"
        result = self.db.execute_query(query, (email,), fetch_one=True)
        return Account(**result) if result else None
    
    def get_accounts_by_role(self, role: str) -> List[Account]:
        """Get all accounts by role."""
        query = "SELECT * FROM Account WHERE role = %s"
        results = self.db.execute_query(query, (role,))
        return [Account(**row) for row in results] if results else []
    
    def get_accounts_paginated(self, pagination: PaginationParams) -> List[Account]:
        """Get all accounts with pagination."""
        query = "SELECT * FROM Account ORDER BY created_at DESC LIMIT %s OFFSET %s"
        results = self.db.execute_query(query, (pagination.limit, pagination.offset))
        return [Account(**row) for row in results] if results else []
    
    def update_account(self, account_id: int, account_data: AccountUpdate) -> int:
        """Update account information."""
        updates = []
        params = []
        
        if account_data.email is not None:
            updates.append("email = %s")
            params.append(account_data.email)
        
        if account_data.password is not None:
            updates.append("password_hash = %s")
            params.append(self._hash_password(account_data.password))
        
        if account_data.role is not None:
            updates.append("role = %s")
            params.append(account_data.role.value)
        
        if not updates:
            return 0
        
        updates.append("updated_at = CURRENT_TIMESTAMP")
        params.append(account_id)
        
        query = f"UPDATE Account SET {', '.join(updates)} WHERE account_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def update_password(self, account_id: int, new_password: str) -> int:
        """Update password only."""
        query = "UPDATE Account SET password_hash = %s, updated_at = CURRENT_TIMESTAMP WHERE account_id = %s"
        password_hash = self._hash_password(new_password)
        return self.db.execute_update(query, (password_hash, account_id))
    
    def delete_account(self, account_id: int) -> int:
        """Delete account (will cascade to Customer/Restaurant)."""
        query = "DELETE FROM Account WHERE account_id = %s"
        return self.db.execute_update(query, (account_id,))


class CustomerCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def create_customer(self, account_id: int, customer_data: CustomerCreate) -> int:
        """Create a new customer (account_id should already exist)."""
        query = "INSERT INTO Customer (customer_id, customer_name) VALUES (%s, %s)"
        return self.db.execute_update(query, (account_id, customer_data.customer_name))
    
    def get_customer_by_id(self, customer_id: int) -> Optional[Customer]:
        """Get customer by ID with account information."""
        query = """
        SELECT c.*, a.email, a.created_at, a.updated_at 
        FROM Customer c 
        JOIN Account a ON c.customer_id = a.account_id 
        WHERE c.customer_id = %s
        """
        result = self.db.execute_query(query, (customer_id,), fetch_one=True)
        return Customer(**result) if result else None
    
    def get_customer_by_email(self, email: str) -> Optional[Customer]:
        """Get customer by email."""
        query = """
        SELECT c.*, a.email, a.created_at, a.updated_at 
        FROM Customer c 
        JOIN Account a ON c.customer_id = a.account_id 
        WHERE a.email = %s
        """
        result = self.db.execute_query(query, (email,), fetch_one=True)
        return Customer(**result) if result else None
    
    def get_all_customers(self) -> List[Customer]:
        """Get all customers."""
        query = """
        SELECT c.*, a.email, a.created_at, a.updated_at 
        FROM Customer c 
        JOIN Account a ON c.customer_id = a.account_id 
        ORDER BY c.customer_name
        """
        results = self.db.execute_query(query)
        return [Customer(**row) for row in results] if results else []
    
    def update_customer(self, customer_id: int, customer_data: CustomerUpdate) -> int:
        """Update customer information."""
        if customer_data.customer_name is None:
            return 0
        
        query = "UPDATE Customer SET customer_name = %s WHERE customer_id = %s"
        return self.db.execute_update(query, (customer_data.customer_name, customer_id))
    
    def delete_customer(self, customer_id: int) -> int:
        """Delete customer."""
        query = "DELETE FROM Customer WHERE customer_id = %s"
        return self.db.execute_update(query, (customer_id,))


class RestaurantCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def create_restaurant(self, account_id: int, restaurant_data: RestaurantCreate) -> int:
        """Create a new restaurant (account_id should already exist)."""
        query = "INSERT INTO Restaurant (restaurant_id, restaurant_name, is_open) VALUES (%s, %s, %s)"
        return self.db.execute_update(query, (account_id, restaurant_data.restaurant_name, restaurant_data.is_open))
    
    def get_restaurant_by_id(self, restaurant_id: int) -> Optional[Restaurant]:
        """Get restaurant by ID with account information."""
        query = """
        SELECT r.*, a.email, a.created_at, a.updated_at 
        FROM Restaurant r 
        JOIN Account a ON r.restaurant_id = a.account_id 
        WHERE r.restaurant_id = %s
        """
        result = self.db.execute_query(query, (restaurant_id,), fetch_one=True)
        return Restaurant(**result) if result else None
    
    def get_restaurant_by_email(self, email: str) -> Optional[Restaurant]:
        """Get restaurant by email."""
        query = """
        SELECT r.*, a.email, a.created_at, a.updated_at 
        FROM Restaurant r 
        JOIN Account a ON r.restaurant_id = a.account_id 
        WHERE a.email = %s
        """
        result = self.db.execute_query(query, (email,), fetch_one=True)
        return Restaurant(**result) if result else None
    
    def get_all_restaurants(self) -> List[Restaurant]:
        """Get all restaurants."""
        query = """
        SELECT r.*, a.email, a.created_at, a.updated_at 
        FROM Restaurant r 
        JOIN Account a ON r.restaurant_id = a.account_id 
        ORDER BY r.restaurant_name
        """
        results = self.db.execute_query(query)
        return [Restaurant(**row) for row in results] if results else []
    
    def get_open_restaurants(self) -> List[Restaurant]:
        """Get open restaurants only."""
        query = """
        SELECT r.*, a.email, a.created_at, a.updated_at 
        FROM Restaurant r 
        JOIN Account a ON r.restaurant_id = a.account_id 
        WHERE r.is_open = 1 
        ORDER BY r.restaurant_name
        """
        results = self.db.execute_query(query)
        return [Restaurant(**row) for row in results] if results else []
    
    def update_restaurant(self, restaurant_id: int, restaurant_data: RestaurantUpdate) -> int:
        """Update restaurant information."""
        updates = []
        params = []
        
        if restaurant_data.restaurant_name is not None:
            updates.append("restaurant_name = %s")
            params.append(restaurant_data.restaurant_name)
        
        if restaurant_data.is_open is not None:
            updates.append("is_open = %s")
            params.append(restaurant_data.is_open)
        
        if not updates:
            return 0
        
        params.append(restaurant_id)
        query = f"UPDATE Restaurant SET {', '.join(updates)} WHERE restaurant_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def toggle_restaurant_status(self, restaurant_id: int) -> int:
        """Toggle restaurant open/closed status."""
        query = "UPDATE Restaurant SET is_open = NOT is_open WHERE restaurant_id = %s"
        return self.db.execute_update(query, (restaurant_id,))
    
    def delete_restaurant(self, restaurant_id: int) -> int:
        """Delete restaurant."""
        query = "DELETE FROM Restaurant WHERE restaurant_id = %s"
        return self.db.execute_update(query, (restaurant_id,))
