from typing import List, Optional
from decimal import Decimal
from datetime import time, timedelta
from database import get_db_manager
from models import (
    Menu, MenuCreate, MenuUpdate,
    MenuItem, MenuItemCreate, MenuItemUpdate,
    MenuItemPriceHistory, MenuItemPriceHistoryCreate,
    Modifier, ModifierCreate, ModifierUpdate,
    ModifierOption, ModifierOptionCreate, ModifierOptionUpdate
)


def timedelta_to_time(td) -> Optional[time]:
    """Convert timedelta to time object. Returns None if input is None."""
    if td is None:
        return None
    if isinstance(td, time):
        return td
    if isinstance(td, timedelta):
        total_seconds = int(td.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        seconds = total_seconds % 60
        return time(hours, minutes, seconds)
    return None


def convert_menu_item_row(row: dict) -> dict:
    """Convert a menu item row from database, handling timedelta to time conversion."""
    if row:
        row = row.copy()
        if 'available_from' in row:
            row['available_from'] = timedelta_to_time(row['available_from'])
        if 'available_until' in row:
            row['available_until'] = timedelta_to_time(row['available_until'])
    return row


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
        """Create a new menu item (BR-016, BR-017)."""
        query = """INSERT INTO MenuItem (menu_id, name, description, price, is_available, available_from, available_until) 
                   VALUES (%s, %s, %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            menu_item_data.menu_id,
            menu_item_data.name,
            menu_item_data.description,
            menu_item_data.price,
            menu_item_data.is_available,
            menu_item_data.available_from,
            menu_item_data.available_until
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
        return MenuItem(**convert_menu_item_row(result)) if result else None
    
    def get_menu_items_by_menu(self, menu_id: int) -> List[MenuItem]:
        """Get all menu items for a menu."""
        query = "SELECT * FROM MenuItem WHERE menu_id = %s ORDER BY name"
        results = self.db.execute_query(query, (menu_id,))
        return [MenuItem(**convert_menu_item_row(row)) for row in results] if results else []
    
    def get_available_menu_items_by_menu(self, menu_id: int) -> List[MenuItem]:
        """Get available menu items for a menu."""
        query = "SELECT * FROM MenuItem WHERE menu_id = %s AND is_available = 1 ORDER BY name"
        results = self.db.execute_query(query, (menu_id,))
        return [MenuItem(**convert_menu_item_row(row)) for row in results] if results else []
    
    def get_available_menu_items_with_time_check(self, menu_id: int) -> List[MenuItem]:
        """Get available menu items considering time restrictions (BR-017)."""
        query = """SELECT * FROM MenuItem 
                   WHERE menu_id = %s 
                     AND is_available = 1
                     AND (available_from IS NULL OR CURTIME() >= available_from)
                     AND (available_until IS NULL OR CURTIME() <= available_until)
                   ORDER BY name"""
        results = self.db.execute_query(query, (menu_id,))
        return [MenuItem(**convert_menu_item_row(row)) for row in results] if results else []
    
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
        return [MenuItem(**convert_menu_item_row(row)) for row in results] if results else []
    
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
        return [MenuItem(**convert_menu_item_row(row)) for row in results] if results else []
    
    def get_menu_item_with_modifiers(self, menu_item_id: int) -> Optional[dict]:
        """Get menu item with all modifiers and options."""
        query = """
        SELECT mi.*,
               mod.modifier_id, mod.modifier_name, mod.min_selections, mod.max_selections, mod.is_required,
               mo.modifier_option_id, mo.option_name, mo.price_delta, mo.is_available as option_is_available
        FROM MenuItem mi
        LEFT JOIN Modifier mod ON mi.menu_item_id = mod.menu_item_id
        LEFT JOIN ModifierOption mo ON mod.modifier_id = mo.modifier_id
        WHERE mi.menu_item_id = %s
        ORDER BY mod.modifier_id, mo.modifier_option_id
        """
        results = self.db.execute_query(query, (menu_item_id,))
        return results if results else None
    
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
        
        if menu_item_data.available_from is not None:
            updates.append("available_from = %s")
            params.append(menu_item_data.available_from)
        
        if menu_item_data.available_until is not None:
            updates.append("available_until = %s")
            params.append(menu_item_data.available_until)
        
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


class MenuItemPriceHistoryCRUD:
    """CRUD operations for menu item price history (BR-033)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_price_history(self, history_data: MenuItemPriceHistoryCreate) -> int:
        """Create price history record (trigger this when price changes)."""
        query = """INSERT INTO MenuItemPriceHistory (menu_item_id, old_price, new_price, changed_by) 
                   VALUES (%s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            history_data.menu_item_id, history_data.old_price,
            history_data.new_price, history_data.changed_by
        ))
    
    def get_price_history_by_menu_item(self, menu_item_id: int) -> List[MenuItemPriceHistory]:
        """Get price history for a menu item."""
        query = "SELECT * FROM MenuItemPriceHistory WHERE menu_item_id = %s ORDER BY changed_at DESC"
        results = self.db.execute_query(query, (menu_item_id,))
        return [MenuItemPriceHistory(**row) for row in results] if results else []
    
    def get_recent_price_changes(self, restaurant_id: int, limit: int = 20) -> List[dict]:
        """Get recent price changes across all items."""
        query = """
        SELECT mph.*, mi.name as item_name, m.name as menu_name
        FROM MenuItemPriceHistory mph
        JOIN MenuItem mi ON mph.menu_item_id = mi.menu_item_id
        JOIN Menu m ON mi.menu_id = m.menu_id
        WHERE m.restaurant_id = %s
        ORDER BY mph.changed_at DESC
        LIMIT %s
        """
        results = self.db.execute_query(query, (restaurant_id, limit))
        return results if results else []


class ModifierCRUD:
    """CRUD operations for menu item modifiers (BR-020)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_modifier(self, modifier_data: ModifierCreate) -> int:
        """Create a new modifier for a menu item."""
        query = """INSERT INTO Modifier (menu_item_id, modifier_name, min_selections, max_selections, is_required) 
                   VALUES (%s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            modifier_data.menu_item_id, modifier_data.modifier_name,
            modifier_data.min_selections, modifier_data.max_selections,
            modifier_data.is_required
        ))
    
    def get_modifier_by_id(self, modifier_id: int) -> Optional[Modifier]:
        """Get modifier by ID."""
        query = "SELECT * FROM Modifier WHERE modifier_id = %s"
        result = self.db.execute_query(query, (modifier_id,), fetch_one=True)
        return Modifier(**result) if result else None
    
    def get_modifiers_by_menu_item(self, menu_item_id: int) -> List[Modifier]:
        """Get all modifiers for a menu item."""
        query = "SELECT * FROM Modifier WHERE menu_item_id = %s ORDER BY is_required DESC, modifier_name"
        results = self.db.execute_query(query, (menu_item_id,))
        return [Modifier(**row) for row in results] if results else []
    
    def get_modifier_with_options(self, modifier_id: int) -> Optional[dict]:
        """Get modifier with all options."""
        query = """
        SELECT mod.*, mo.modifier_option_id, mo.option_name, mo.price_delta, mo.is_available
        FROM Modifier mod
        LEFT JOIN ModifierOption mo ON mod.modifier_id = mo.modifier_id
        WHERE mod.modifier_id = %s
        ORDER BY mo.option_name
        """
        results = self.db.execute_query(query, (modifier_id,))
        return results if results else None
    
    def update_modifier(self, modifier_id: int, modifier_data: ModifierUpdate) -> int:
        """Update modifier information."""
        updates = []
        params = []
        
        if modifier_data.modifier_name is not None:
            updates.append("modifier_name = %s")
            params.append(modifier_data.modifier_name)
        
        if modifier_data.min_selections is not None:
            updates.append("min_selections = %s")
            params.append(modifier_data.min_selections)
        
        if modifier_data.max_selections is not None:
            updates.append("max_selections = %s")
            params.append(modifier_data.max_selections)
        
        if modifier_data.is_required is not None:
            updates.append("is_required = %s")
            params.append(modifier_data.is_required)
        
        if not updates:
            return 0
        
        params.append(modifier_id)
        query = f"UPDATE Modifier SET {', '.join(updates)} WHERE modifier_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def delete_modifier(self, modifier_id: int) -> int:
        """Delete modifier."""
        query = "DELETE FROM Modifier WHERE modifier_id = %s"
        return self.db.execute_update(query, (modifier_id,))


class ModifierOptionCRUD:
    """CRUD operations for modifier options (BR-020)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_modifier_option(self, option_data: ModifierOptionCreate) -> int:
        """Create a new modifier option."""
        query = """INSERT INTO ModifierOption (modifier_id, option_name, price_delta, is_available) 
                   VALUES (%s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            option_data.modifier_id, option_data.option_name,
            option_data.price_delta, option_data.is_available
        ))
    
    def get_modifier_option_by_id(self, modifier_option_id: int) -> Optional[ModifierOption]:
        """Get modifier option by ID."""
        query = "SELECT * FROM ModifierOption WHERE modifier_option_id = %s"
        result = self.db.execute_query(query, (modifier_option_id,), fetch_one=True)
        return ModifierOption(**result) if result else None
    
    def get_options_by_modifier(self, modifier_id: int) -> List[ModifierOption]:
        """Get all options for a modifier."""
        query = "SELECT * FROM ModifierOption WHERE modifier_id = %s ORDER BY option_name"
        results = self.db.execute_query(query, (modifier_id,))
        return [ModifierOption(**row) for row in results] if results else []
    
    def get_available_options_by_modifier(self, modifier_id: int) -> List[ModifierOption]:
        """Get available options for a modifier."""
        query = "SELECT * FROM ModifierOption WHERE modifier_id = %s AND is_available = 1 ORDER BY option_name"
        results = self.db.execute_query(query, (modifier_id,))
        return [ModifierOption(**row) for row in results] if results else []
    
    def update_modifier_option(self, modifier_option_id: int, option_data: ModifierOptionUpdate) -> int:
        """Update modifier option information."""
        updates = []
        params = []
        
        if option_data.option_name is not None:
            updates.append("option_name = %s")
            params.append(option_data.option_name)
        
        if option_data.price_delta is not None:
            updates.append("price_delta = %s")
            params.append(option_data.price_delta)
        
        if option_data.is_available is not None:
            updates.append("is_available = %s")
            params.append(option_data.is_available)
        
        if not updates:
            return 0
        
        params.append(modifier_option_id)
        query = f"UPDATE ModifierOption SET {', '.join(updates)} WHERE modifier_option_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def toggle_option_availability(self, modifier_option_id: int) -> int:
        """Toggle option availability."""
        query = "UPDATE ModifierOption SET is_available = NOT is_available WHERE modifier_option_id = %s"
        return self.db.execute_update(query, (modifier_option_id,))
    
    def delete_modifier_option(self, modifier_option_id: int) -> int:
        """Delete modifier option."""
        query = "DELETE FROM ModifierOption WHERE modifier_option_id = %s"
        return self.db.execute_update(query, (modifier_option_id,))
