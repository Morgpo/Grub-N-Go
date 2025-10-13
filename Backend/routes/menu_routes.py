from fastapi import APIRouter, HTTPException, status
from typing import List
from models import (
    Menu, MenuCreate, MenuUpdate,
    MenuItem, MenuItemCreate, MenuItemUpdate
)
from crud.menu_crud import MenuCRUD, MenuItemCRUD

router = APIRouter()

# Initialize CRUD instances
menu_crud = MenuCRUD()
menu_item_crud = MenuItemCRUD()


# Menu routes
@router.post("/menus/", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_menu(menu_data: MenuCreate):
    """Create a new menu."""
    try:
        menu_id = menu_crud.create_menu(menu_data)
        return {"menu_id": menu_id, "message": "Menu created successfully"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/menus/{menu_id}", response_model=Menu)
async def get_menu(menu_id: int):
    """Get menu by ID."""
    menu = menu_crud.get_menu_by_id(menu_id)
    if not menu:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Menu not found")
    return menu


@router.get("/restaurants/{restaurant_id}/menus/", response_model=List[Menu])
async def get_menus_by_restaurant(restaurant_id: int):
    """Get all menus for a restaurant."""
    return menu_crud.get_menus_by_restaurant(restaurant_id)


@router.get("/restaurants/{restaurant_id}/menus/active/", response_model=List[Menu])
async def get_active_menus_by_restaurant(restaurant_id: int):
    """Get active menus for a restaurant."""
    return menu_crud.get_active_menus_by_restaurant(restaurant_id)


@router.put("/menus/{menu_id}", response_model=dict)
async def update_menu(menu_id: int, menu_data: MenuUpdate):
    """Update menu information."""
    rows_affected = menu_crud.update_menu(menu_id, menu_data)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Menu not found or no changes made")
    return {"message": "Menu updated successfully"}


@router.put("/menus/{menu_id}/toggle-status", response_model=dict)
async def toggle_menu_status(menu_id: int):
    """Toggle menu active status."""
    rows_affected = menu_crud.toggle_menu_status(menu_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Menu not found")
    return {"message": "Menu status toggled successfully"}


@router.delete("/menus/{menu_id}", response_model=dict)
async def delete_menu(menu_id: int):
    """Delete menu."""
    rows_affected = menu_crud.delete_menu(menu_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Menu not found")
    return {"message": "Menu deleted successfully"}


# Menu Item routes
@router.post("/menu-items/", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_menu_item(menu_item_data: MenuItemCreate):
    """Create a new menu item."""
    try:
        menu_item_id = menu_item_crud.create_menu_item(menu_item_data)
        return {"menu_item_id": menu_item_id, "message": "Menu item created successfully"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/menu-items/{menu_item_id}", response_model=MenuItem)
async def get_menu_item(menu_item_id: int):
    """Get menu item by ID."""
    menu_item = menu_item_crud.get_menu_item_by_id(menu_item_id)
    if not menu_item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Menu item not found")
    return menu_item


@router.get("/menus/{menu_id}/items/", response_model=List[MenuItem])
async def get_menu_items_by_menu(menu_id: int):
    """Get all menu items for a menu."""
    return menu_item_crud.get_menu_items_by_menu(menu_id)


@router.get("/menus/{menu_id}/items/available/", response_model=List[MenuItem])
async def get_available_menu_items_by_menu(menu_id: int):
    """Get available menu items for a menu."""
    return menu_item_crud.get_available_menu_items_by_menu(menu_id)


@router.get("/restaurants/{restaurant_id}/menu-items/", response_model=List[MenuItem])
async def get_menu_items_by_restaurant(restaurant_id: int):
    """Get all menu items for a restaurant."""
    return menu_item_crud.get_menu_items_by_restaurant(restaurant_id)


@router.get("/menu-items/search/", response_model=List[MenuItem])
async def search_menu_items(q: str):
    """Search menu items by name."""
    if not q or len(q.strip()) < 2:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Search term must be at least 2 characters")
    return menu_item_crud.search_menu_items_by_name(q.strip())


@router.put("/menu-items/{menu_item_id}", response_model=dict)
async def update_menu_item(menu_item_id: int, menu_item_data: MenuItemUpdate):
    """Update menu item information."""
    rows_affected = menu_item_crud.update_menu_item(menu_item_id, menu_item_data)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Menu item not found or no changes made")
    return {"message": "Menu item updated successfully"}


@router.put("/menu-items/{menu_item_id}/price", response_model=dict)
async def update_menu_item_price(menu_item_id: int, new_price: float):
    """Update menu item price only."""
    if new_price <= 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Price must be greater than 0")
    
    rows_affected = menu_item_crud.update_menu_item_price(menu_item_id, new_price)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Menu item not found")
    return {"message": "Menu item price updated successfully"}


@router.put("/menu-items/{menu_item_id}/toggle-availability", response_model=dict)
async def toggle_menu_item_availability(menu_item_id: int):
    """Toggle menu item availability."""
    rows_affected = menu_item_crud.toggle_menu_item_availability(menu_item_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Menu item not found")
    return {"message": "Menu item availability toggled successfully"}


@router.delete("/menu-items/{menu_item_id}", response_model=dict)
async def delete_menu_item(menu_item_id: int):
    """Delete menu item."""
    rows_affected = menu_item_crud.delete_menu_item(menu_item_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Menu item not found")
    return {"message": "Menu item deleted successfully"}
