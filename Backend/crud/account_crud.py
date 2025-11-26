from typing import List, Optional
from database import get_db_manager
from models import (
    Account, AccountCreate, AccountUpdate,
    Customer, CustomerCreate, CustomerUpdate,
    Restaurant, RestaurantCreate, RestaurantUpdate,
    Address, AddressCreate, AddressUpdate,
    PaymentMethod, PaymentMethodCreate, PaymentMethodUpdate,
    BusinessHours, BusinessHoursCreate, BusinessHoursUpdate,
    PaginationParams, AccountStatusEnum
)
import hashlib


class AccountCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def _hash_password(self, password: str) -> str:
        """Hash password using SHA-256."""
        return hashlib.sha256(password.encode()).hexdigest()
    
    def create_account(self, account_data: AccountCreate, created_by: Optional[int] = None) -> int:
        """Create a new account with audit trail (BR-005)."""
        query = "INSERT INTO Account (email, password_hash, role, status, created_by) VALUES (%s, %s, %s, 'ACTIVE', %s)"
        password_hash = self._hash_password(account_data.password)
        params = (account_data.email, password_hash, account_data.role.value, created_by)
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
    
    def get_active_accounts(self) -> List[Account]:
        """Get active accounts only (BR-003)."""
        query = "SELECT * FROM Account WHERE status = 'ACTIVE'"
        results = self.db.execute_query(query)
        return [Account(**row) for row in results] if results else []
    
    def get_accounts_by_role_and_status(self, role: str, status: AccountStatusEnum) -> List[Account]:
        """Get all accounts by role and status."""
        query = "SELECT * FROM Account WHERE role = %s AND status = %s"
        results = self.db.execute_query(query, (role, status.value))
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
        
        if account_data.status is not None:
            updates.append("status = %s")
            params.append(account_data.status.value)
        
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
    
    def update_account_status(self, account_id: int, status: AccountStatusEnum) -> int:
        """Update account status (BR-003)."""
        query = "UPDATE Account SET status = %s, updated_at = CURRENT_TIMESTAMP WHERE account_id = %s"
        return self.db.execute_update(query, (status.value, account_id))
    
    def record_failed_login(self, account_id: int) -> int:
        """Record failed login attempt (BR-004)."""
        query = "UPDATE Account SET failed_login_attempts = failed_login_attempts + 1, last_login_attempt = CURRENT_TIMESTAMP WHERE account_id = %s"
        return self.db.execute_update(query, (account_id,))
    
    def reset_failed_logins(self, account_id: int) -> int:
        """Reset failed login attempts (BR-004)."""
        query = "UPDATE Account SET failed_login_attempts = 0, last_login_attempt = CURRENT_TIMESTAMP WHERE account_id = %s"
        return self.db.execute_update(query, (account_id,))
    
    def delete_account(self, account_id: int) -> int:
        """Delete account (will cascade to Customer/Restaurant)."""
        query = "DELETE FROM Account WHERE account_id = %s"
        return self.db.execute_update(query, (account_id,))


class CustomerCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def create_customer(self, account_id: int, customer_data: CustomerCreate) -> int:
        """Create a new customer (account_id should already exist) (BR-006)."""
        query = "INSERT INTO Customer (customer_id, customer_name, phone) VALUES (%s, %s, %s)"
        return self.db.execute_update(query, (account_id, customer_data.customer_name, customer_data.phone))
    
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
        """Get all active customers."""
        query = """
        SELECT c.*, a.email, a.status, a.created_at, a.updated_at 
        FROM Customer c 
        JOIN Account a ON c.customer_id = a.account_id 
        WHERE a.status = 'ACTIVE'
        ORDER BY c.customer_name
        """
        results = self.db.execute_query(query)
        return [Customer(**row) for row in results] if results else []
    
    def get_customers_paginated(self, pagination: PaginationParams) -> List[Customer]:
        """Get all customers with pagination."""
        query = """
        SELECT c.*, a.email, a.status, a.created_at, a.updated_at 
        FROM Customer c 
        JOIN Account a ON c.customer_id = a.account_id 
        ORDER BY c.customer_name
        LIMIT %s OFFSET %s
        """
        results = self.db.execute_query(query, (pagination.limit, pagination.offset))
        return [Customer(**row) for row in results] if results else []
    
    def update_customer(self, customer_id: int, customer_data: CustomerUpdate) -> int:
        """Update customer information."""
        updates = []
        params = []
        
        if customer_data.customer_name is not None:
            updates.append("customer_name = %s")
            params.append(customer_data.customer_name)
        
        if customer_data.phone is not None:
            updates.append("phone = %s")
            params.append(customer_data.phone)
        
        if not updates:
            return 0
        
        params.append(customer_id)
        query = f"UPDATE Customer SET {', '.join(updates)} WHERE customer_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def delete_customer(self, customer_id: int) -> int:
        """Delete customer."""
        query = "DELETE FROM Customer WHERE customer_id = %s"
        return self.db.execute_update(query, (customer_id,))


class RestaurantCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def create_restaurant(self, account_id: int, restaurant_data: RestaurantCreate) -> int:
        """Create a new restaurant (account_id should already exist) (BR-010, BR-012, BR-013)."""
        query = """INSERT INTO Restaurant (restaurant_id, restaurant_name, contact_phone, contact_email, operating_status, 
                   street_address, city, state, postal_code, country, latitude, longitude) 
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            account_id, restaurant_data.restaurant_name, restaurant_data.contact_phone,
            restaurant_data.contact_email, restaurant_data.operating_status.value,
            restaurant_data.street_address, restaurant_data.city, restaurant_data.state,
            restaurant_data.postal_code, restaurant_data.country,
            restaurant_data.latitude, restaurant_data.longitude
        ))
    
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
        """Get open restaurants only (BR-012)."""
        query = """
        SELECT r.*, a.email, a.status, a.created_at, a.updated_at 
        FROM Restaurant r 
        JOIN Account a ON r.restaurant_id = a.account_id 
        WHERE r.operating_status = 'OPEN' AND a.status = 'ACTIVE'
        ORDER BY r.restaurant_name
        """
        results = self.db.execute_query(query)
        return [Restaurant(**row) for row in results] if results else []
    
    def get_restaurants_by_location(self, city: str, state: str) -> List[Restaurant]:
        """Get restaurants by location (BR-013)."""
        query = """
        SELECT r.*, a.email, a.status 
        FROM Restaurant r 
        JOIN Account a ON r.restaurant_id = a.account_id 
        WHERE r.city = %s AND r.state = %s AND a.status = 'ACTIVE'
        ORDER BY r.restaurant_name
        """
        results = self.db.execute_query(query, (city, state))
        return [Restaurant(**row) for row in results] if results else []
    
    def get_restaurants_within_radius(self, latitude: float, longitude: float, radius_km: float) -> List[dict]:
        """Get restaurants within radius using Haversine formula (BR-013)."""
        query = """
        SELECT r.*, a.email, a.status,
            (6371 * acos(cos(radians(%s)) * cos(radians(r.latitude)) * 
            cos(radians(r.longitude) - radians(%s)) + 
            sin(radians(%s)) * sin(radians(r.latitude)))) AS distance_km
        FROM Restaurant r 
        JOIN Account a ON r.restaurant_id = a.account_id 
        WHERE r.latitude IS NOT NULL AND r.longitude IS NOT NULL
          AND a.status = 'ACTIVE'
        HAVING distance_km <= %s
        ORDER BY distance_km
        """
        results = self.db.execute_query(query, (latitude, longitude, latitude, radius_km))
        return results if results else []
    
    def update_restaurant(self, restaurant_id: int, restaurant_data: RestaurantUpdate) -> int:
        """Update restaurant information."""
        updates = []
        params = []
        
        if restaurant_data.restaurant_name is not None:
            updates.append("restaurant_name = %s")
            params.append(restaurant_data.restaurant_name)
        
        if restaurant_data.contact_phone is not None:
            updates.append("contact_phone = %s")
            params.append(restaurant_data.contact_phone)
        
        if restaurant_data.contact_email is not None:
            updates.append("contact_email = %s")
            params.append(restaurant_data.contact_email)
        
        if restaurant_data.operating_status is not None:
            updates.append("operating_status = %s")
            params.append(restaurant_data.operating_status.value)
        
        if restaurant_data.street_address is not None:
            updates.append("street_address = %s")
            params.append(restaurant_data.street_address)
        
        if restaurant_data.city is not None:
            updates.append("city = %s")
            params.append(restaurant_data.city)
        
        if restaurant_data.state is not None:
            updates.append("state = %s")
            params.append(restaurant_data.state)
        
        if restaurant_data.postal_code is not None:
            updates.append("postal_code = %s")
            params.append(restaurant_data.postal_code)
        
        if restaurant_data.country is not None:
            updates.append("country = %s")
            params.append(restaurant_data.country)
        
        if restaurant_data.latitude is not None:
            updates.append("latitude = %s")
            params.append(restaurant_data.latitude)
        
        if restaurant_data.longitude is not None:
            updates.append("longitude = %s")
            params.append(restaurant_data.longitude)
        
        if not updates:
            return 0
        
        params.append(restaurant_id)
        query = f"UPDATE Restaurant SET {', '.join(updates)} WHERE restaurant_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def update_operating_status(self, restaurant_id: int, status: str) -> int:
        """Update restaurant operating status (BR-012)."""
        query = "UPDATE Restaurant SET operating_status = %s WHERE restaurant_id = %s"
        return self.db.execute_update(query, (status, restaurant_id))
    
    def update_restaurant_location(self, restaurant_id: int, street_address: str, city: str, 
                                   state: str, postal_code: str, country: str,
                                   latitude: Optional[float], longitude: Optional[float]) -> int:
        """Update restaurant location only."""
        query = """UPDATE Restaurant 
                   SET street_address = %s, city = %s, state = %s, postal_code = %s, country = %s,
                       latitude = %s, longitude = %s
                   WHERE restaurant_id = %s"""
        return self.db.execute_update(query, (street_address, city, state, postal_code, country,
                                             latitude, longitude, restaurant_id))
    
    def delete_restaurant(self, restaurant_id: int) -> int:
        """Delete restaurant."""
        query = "DELETE FROM Restaurant WHERE restaurant_id = %s"
        return self.db.execute_update(query, (restaurant_id,))


class AddressCRUD:
    """CRUD operations for customer addresses (BR-007)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_address(self, address_data: AddressCreate) -> int:
        """Create a new address for a customer."""
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
        
        if not updates:
            return 0
        
        updates.append("updated_at = CURRENT_TIMESTAMP")
        params.append(address_id)
        
        query = f"UPDATE Address SET {', '.join(updates)} WHERE address_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def set_default_address(self, customer_id: int, address_id: int) -> int:
        """Set a new default address (unset old default first)."""
        # Unset all defaults for this customer
        self.db.execute_update("UPDATE Address SET is_default = 0 WHERE customer_id = %s", (customer_id,))
        # Set new default
        query = "UPDATE Address SET is_default = 1, updated_at = CURRENT_TIMESTAMP WHERE address_id = %s"
        return self.db.execute_update(query, (address_id,))
    
    def delete_address(self, address_id: int) -> int:
        """Delete address."""
        query = "DELETE FROM Address WHERE address_id = %s"
        return self.db.execute_update(query, (address_id,))


class PaymentMethodCRUD:
    """CRUD operations for customer payment methods (BR-008, BR-037)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_payment_method(self, payment_data: PaymentMethodCreate) -> int:
        """Create a new payment method for a customer."""
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
        
        if not updates:
            return 0
        
        updates.append("updated_at = CURRENT_TIMESTAMP")
        params.append(payment_method_id)
        
        query = f"UPDATE PaymentMethod SET {', '.join(updates)} WHERE payment_method_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def set_default_payment_method(self, customer_id: int, payment_method_id: int) -> int:
        """Set a new default payment method (unset old default first)."""
        # Unset all defaults for this customer
        self.db.execute_update("UPDATE PaymentMethod SET is_default = 0 WHERE customer_id = %s", (customer_id,))
        # Set new default
        query = "UPDATE PaymentMethod SET is_default = 1, updated_at = CURRENT_TIMESTAMP WHERE payment_method_id = %s"
        return self.db.execute_update(query, (payment_method_id,))
    
    def delete_payment_method(self, payment_method_id: int) -> int:
        """Delete payment method."""
        query = "DELETE FROM PaymentMethod WHERE payment_method_id = %s"
        return self.db.execute_update(query, (payment_method_id,))


class BusinessHoursCRUD:
    """CRUD operations for restaurant business hours (BR-012)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_business_hours(self, hours_data: BusinessHoursCreate) -> int:
        """Create business hours for a restaurant."""
        query = """INSERT INTO BusinessHours (restaurant_id, day_of_week, open_time, close_time, is_closed) 
                   VALUES (%s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            hours_data.restaurant_id, hours_data.day_of_week.value,
            hours_data.open_time, hours_data.close_time, hours_data.is_closed
        ))
    
    def get_business_hours_by_id(self, business_hours_id: int) -> Optional[BusinessHours]:
        """Get business hours by ID."""
        query = "SELECT * FROM BusinessHours WHERE business_hours_id = %s"
        result = self.db.execute_query(query, (business_hours_id,), fetch_one=True)
        return BusinessHours(**result) if result else None
    
    def get_business_hours_by_restaurant(self, restaurant_id: int) -> List[BusinessHours]:
        """Get all business hours for a restaurant."""
        query = """SELECT * FROM BusinessHours 
                   WHERE restaurant_id = %s 
                   ORDER BY FIELD(day_of_week, 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY')"""
        results = self.db.execute_query(query, (restaurant_id,))
        return [BusinessHours(**row) for row in results] if results else []
    
    def get_business_hours_for_day(self, restaurant_id: int, day_of_week: str) -> Optional[BusinessHours]:
        """Get business hours for specific day."""
        query = "SELECT * FROM BusinessHours WHERE restaurant_id = %s AND day_of_week = %s"
        result = self.db.execute_query(query, (restaurant_id, day_of_week), fetch_one=True)
        return BusinessHours(**result) if result else None
    
    def check_if_open_now(self, restaurant_id: int) -> Optional[dict]:
        """Check if restaurant is open now."""
        query = """
        SELECT bh.*, 
               CASE 
                   WHEN bh.is_closed = 1 THEN 0
                   WHEN CURTIME() BETWEEN bh.open_time AND bh.close_time THEN 1
                   ELSE 0
               END AS is_currently_open
        FROM BusinessHours bh
        WHERE bh.restaurant_id = %s 
          AND bh.day_of_week = UPPER(DATE_FORMAT(NOW(), '%%W'))
        """
        result = self.db.execute_query(query, (restaurant_id,), fetch_one=True)
        return result
    
    def update_business_hours(self, business_hours_id: int, hours_data: BusinessHoursUpdate) -> int:
        """Update business hours."""
        updates = []
        params = []
        
        if hours_data.open_time is not None:
            updates.append("open_time = %s")
            params.append(hours_data.open_time)
        
        if hours_data.close_time is not None:
            updates.append("close_time = %s")
            params.append(hours_data.close_time)
        
        if hours_data.is_closed is not None:
            updates.append("is_closed = %s")
            params.append(hours_data.is_closed)
        
        if not updates:
            return 0
        
        params.append(business_hours_id)
        query = f"UPDATE BusinessHours SET {', '.join(updates)} WHERE business_hours_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def toggle_closed_status(self, business_hours_id: int) -> int:
        """Toggle closed status for a day."""
        query = "UPDATE BusinessHours SET is_closed = NOT is_closed WHERE business_hours_id = %s"
        return self.db.execute_update(query, (business_hours_id,))
    
    def delete_business_hours(self, business_hours_id: int) -> int:
        """Delete business hours."""
        query = "DELETE FROM BusinessHours WHERE business_hours_id = %s"
        return self.db.execute_update(query, (business_hours_id,))
    
    def delete_all_business_hours(self, restaurant_id: int) -> int:
        """Delete all business hours for a restaurant."""
        query = "DELETE FROM BusinessHours WHERE restaurant_id = %s"
        return self.db.execute_update(query, (restaurant_id,))
