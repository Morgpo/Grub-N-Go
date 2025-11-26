from typing import List, Optional
from database import get_db_manager
from models import (
    Modifier, ModifierCreate, ModifierUpdate,
    ModifierOption, ModifierOptionCreate, ModifierOptionUpdate,
    PaginationParams
)


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
        query = "SELECT * FROM Modifier WHERE menu_item_id = %s ORDER BY modifier_name"
        results = self.db.execute_query(query, (menu_item_id,))
        return [Modifier(**row) for row in results] if results else []
    
    def get_required_modifiers(self, menu_item_id: int) -> List[Modifier]:
        """Get required modifiers for a menu item."""
        query = "SELECT * FROM Modifier WHERE menu_item_id = %s AND is_required = 1 ORDER BY modifier_name"
        results = self.db.execute_query(query, (menu_item_id,))
        return [Modifier(**row) for row in results] if results else []
    
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
        """Delete modifier (will cascade to options)."""
        query = "DELETE FROM Modifier WHERE modifier_id = %s"
        return self.db.execute_update(query, (modifier_id,))
    
    def delete_modifiers_by_menu_item(self, menu_item_id: int) -> int:
        """Delete all modifiers for a menu item."""
        query = "DELETE FROM Modifier WHERE menu_item_id = %s"
        return self.db.execute_update(query, (menu_item_id,))


class ModifierOptionCRUD:
    """CRUD operations for modifier options."""
    
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
    
    def get_available_options(self, modifier_id: int) -> List[ModifierOption]:
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
    
    def toggle_availability(self, modifier_option_id: int) -> int:
        """Toggle option availability."""
        query = "UPDATE ModifierOption SET is_available = NOT is_available WHERE modifier_option_id = %s"
        return self.db.execute_update(query, (modifier_option_id,))
    
    def delete_modifier_option(self, modifier_option_id: int) -> int:
        """Delete modifier option."""
        query = "DELETE FROM ModifierOption WHERE modifier_option_id = %s"
        return self.db.execute_update(query, (modifier_option_id,))
    
    def delete_options_by_modifier(self, modifier_id: int) -> int:
        """Delete all options for a modifier."""
        query = "DELETE FROM ModifierOption WHERE modifier_id = %s"
        return self.db.execute_update(query, (modifier_id,))
