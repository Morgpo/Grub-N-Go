from typing import List, Optional
from database import get_db_manager
from models import (
    Menu, MenuCreate, MenuUpdate,
    MenuItem, MenuItemCreate, MenuItemUpdate
)


class MenuCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def create_menu(self, menu_data: MenuCreate) -> int:
        """Create a new menu."""
        query = "INSERT INTO Menu (restaurant_id, name, is_active) VALUES (%s, %s, %s)"
        return self.db.execute_update(query, (menu_data.restaurant_id, menu_data.name, menu_data.is_active))
    
    def get_menu_by_id(self, menu_id: int) -> Optional[Menu]:
        """Get menu by ID."""
        query = "SELECT * FROM Menu WHERE menu_id = %s"
        result = self.db.execute_query(query, (menu_id,), fetch_one=True)
        return Menu(**result) if result else None
    
    def get_menus_by_restaurant(self, restaurant_id: int) -> List[Menu]:
        """Get all menus for a restaurant."""
        query = "SELECT * FROM Menu WHERE restaurant_id = %s ORDER BY created_at DESC"
        results = self.db.execute_query(query, (restaurant_id,))
        return [Menu(**row) for row in results] if results else []
    
    def get_active_menus_by_restaurant(self, restaurant_id: int) -> List[Menu]:
        """Get active menus for a restaurant."""
        query = "SELECT * FROM Menu WHERE restaurant_id = %s AND is_active = 1 ORDER BY name"
        results = self.db.execute_query(query, (restaurant_id,))
        return [Menu(**row) for row in results] if results else []
    
    def update_menu(self, menu_id: int, menu_data: MenuUpdate) -> int:
        """Update menu information."""
        updates = []
        params = []
        
        if menu_data.name is not None:
            updates.append("name = %s")
            params.append(menu_data.name)
        
        if menu_data.is_active is not None:
            updates.append("is_active = %s")
            params.append(menu_data.is_active)
        
        if not updates:
            return 0
        
        updates.append("updated_at = CURRENT_TIMESTAMP")
        params.append(menu_id)
        
        query = f"UPDATE Menu SET {', '.join(updates)} WHERE menu_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def toggle_menu_status(self, menu_id: int) -> int:
        """Toggle menu active status."""
        query = "UPDATE Menu SET is_active = NOT is_active, updated_at = CURRENT_TIMESTAMP WHERE menu_id = %s"
        return self.db.execute_update(query, (menu_id,))
    
    def delete_menu(self, menu_id: int) -> int:
        """Delete menu."""
        query = "DELETE FROM Menu WHERE menu_id = %s"
        return self.db.execute_update(query, (menu_id,))


class MenuItemCRUD:
    def __init__(self):
        self.db = get_db_manager()
    
    def create_menu_item(self, menu_item_data: MenuItemCreate) -> int:
        """Create a new menu item."""
        query = "INSERT INTO MenuItem (menu_id, name, description, price, is_available) VALUES (%s, %s, %s, %s, %s)"
        return self.db.execute_update(query, (
            menu_item_data.menu_id,
            menu_item_data.name,
            menu_item_data.description,
            menu_item_data.price,
            menu_item_data.is_available
        ))
    
    def get_menu_item_by_id(self, menu_item_id: int) -> Optional[MenuItem]:
        """Get menu item by ID with menu and restaurant information."""
        query = """
        SELECT mi.*, m.name as menu_name, m.restaurant_id 
        FROM MenuItem mi 
        JOIN Menu m ON mi.menu_id = m.menu_id 
        WHERE mi.menu_item_id = %s
        """
        result = self.db.execute_query(query, (menu_item_id,), fetch_one=True)
        return MenuItem(**result) if result else None
    
    def get_menu_items_by_menu(self, menu_id: int) -> List[MenuItem]:
        """Get all menu items for a menu."""
        query = "SELECT * FROM MenuItem WHERE menu_id = %s ORDER BY name"
        results = self.db.execute_query(query, (menu_id,))
        return [MenuItem(**row) for row in results] if results else []
    
    def get_available_menu_items_by_menu(self, menu_id: int) -> List[MenuItem]:
        """Get available menu items for a menu."""
        query = "SELECT * FROM MenuItem WHERE menu_id = %s AND is_available = 1 ORDER BY name"
        results = self.db.execute_query(query, (menu_id,))
        return [MenuItem(**row) for row in results] if results else []
    
    def get_menu_items_by_restaurant(self, restaurant_id: int) -> List[MenuItem]:
        """Get all menu items for a restaurant."""
        query = """
        SELECT mi.*, m.name as menu_name 
        FROM MenuItem mi 
        JOIN Menu m ON mi.menu_id = m.menu_id 
        WHERE m.restaurant_id = %s 
        ORDER BY m.name, mi.name
        """
        results = self.db.execute_query(query, (restaurant_id,))
        return [MenuItem(**row) for row in results] if results else []
    
    def search_menu_items_by_name(self, search_term: str) -> List[MenuItem]:
        """Search menu items by name."""
        query = """
        SELECT mi.*, m.name as menu_name, m.restaurant_id 
        FROM MenuItem mi 
        JOIN Menu m ON mi.menu_id = m.menu_id 
        WHERE mi.name LIKE %s 
        ORDER BY mi.name
        """
        search_pattern = f"%{search_term}%"
        results = self.db.execute_query(query, (search_pattern,))
        return [MenuItem(**row) for row in results] if results else []
    
    def update_menu_item(self, menu_item_id: int, menu_item_data: MenuItemUpdate) -> int:
        """Update menu item information."""
        updates = []
        params = []
        
        if menu_item_data.name is not None:
            updates.append("name = %s")
            params.append(menu_item_data.name)
        
        if menu_item_data.description is not None:
            updates.append("description = %s")
            params.append(menu_item_data.description)
        
        if menu_item_data.price is not None:
            updates.append("price = %s")
            params.append(menu_item_data.price)
        
        if menu_item_data.is_available is not None:
            updates.append("is_available = %s")
            params.append(menu_item_data.is_available)
        
        if not updates:
            return 0
        
        updates.append("updated_at = CURRENT_TIMESTAMP")
        params.append(menu_item_id)
        
        query = f"UPDATE MenuItem SET {', '.join(updates)} WHERE menu_item_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def update_menu_item_price(self, menu_item_id: int, new_price: float) -> int:
        """Update menu item price only."""
        query = "UPDATE MenuItem SET price = %s, updated_at = CURRENT_TIMESTAMP WHERE menu_item_id = %s"
        return self.db.execute_update(query, (new_price, menu_item_id))
    
    def toggle_menu_item_availability(self, menu_item_id: int) -> int:
        """Toggle menu item availability."""
        query = "UPDATE MenuItem SET is_available = NOT is_available, updated_at = CURRENT_TIMESTAMP WHERE menu_item_id = %s"
        return self.db.execute_update(query, (menu_item_id,))
    
    def delete_menu_item(self, menu_item_id: int) -> int:
        """Delete menu item."""
        query = "DELETE FROM MenuItem WHERE menu_item_id = %s"
        return self.db.execute_update(query, (menu_item_id,))
