from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from crud.modifier_crud import ModifierCRUD, ModifierOptionCRUD
from models import (
    Modifier, ModifierCreate, ModifierUpdate,
    ModifierOption, ModifierOptionCreate, ModifierOptionUpdate,
    PaginationParams
)

router = APIRouter()
modifier_crud = ModifierCRUD()
modifier_option_crud = ModifierOptionCRUD()


# Modifier endpoints
@router.post("/menu-items/{menu_item_id}/modifiers", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_modifier(menu_item_id: int, modifier_data: ModifierCreate):
    """Create a new modifier for a menu item."""
    try:
        # Ensure the menu_item_id matches
        modifier_data.menu_item_id = menu_item_id
        modifier_id = modifier_crud.create_modifier(modifier_data)
        return {"message": "Modifier created successfully", "modifier_id": modifier_id}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create modifier: {str(e)}"
        )


@router.get("/modifiers/{modifier_id}", response_model=Modifier)
async def get_modifier(modifier_id: int):
    """Get modifier by ID."""
    modifier = modifier_crud.get_modifier_by_id(modifier_id)
    if not modifier:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Modifier not found"
        )
    return modifier


@router.get("/menu-items/{menu_item_id}/modifiers", response_model=List[Modifier])
async def get_menu_item_modifiers(menu_item_id: int):
    """Get all modifiers for a menu item."""
    try:
        modifiers = modifier_crud.get_modifiers_by_menu_item(menu_item_id)
        return modifiers
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve modifiers: {str(e)}"
        )


@router.get("/menu-items/{menu_item_id}/modifiers/required", response_model=List[Modifier])
async def get_required_modifiers(menu_item_id: int):
    """Get required modifiers for a menu item."""
    try:
        modifiers = modifier_crud.get_required_modifiers(menu_item_id)
        return modifiers
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve required modifiers: {str(e)}"
        )


@router.put("/modifiers/{modifier_id}", response_model=dict)
async def update_modifier(modifier_id: int, modifier_data: ModifierUpdate):
    """Update modifier information."""
    try:
        rows_affected = modifier_crud.update_modifier(modifier_id, modifier_data)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Modifier not found or no changes made"
            )
        return {"message": "Modifier updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update modifier: {str(e)}"
        )


@router.delete("/modifiers/{modifier_id}", response_model=dict)
async def delete_modifier(modifier_id: int):
    """Delete a modifier and all its options."""
    try:
        rows_affected = modifier_crud.delete_modifier(modifier_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Modifier not found"
            )
        return {"message": "Modifier deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete modifier: {str(e)}"
        )


# Modifier Option endpoints
@router.post("/modifiers/{modifier_id}/options", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_modifier_option(modifier_id: int, option_data: ModifierOptionCreate):
    """Create a new modifier option."""
    try:
        # Ensure the modifier_id matches
        option_data.modifier_id = modifier_id
        option_id = modifier_option_crud.create_modifier_option(option_data)
        return {"message": "Modifier option created successfully", "modifier_option_id": option_id}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create modifier option: {str(e)}"
        )


@router.get("/modifier-options/{modifier_option_id}", response_model=ModifierOption)
async def get_modifier_option(modifier_option_id: int):
    """Get modifier option by ID."""
    option = modifier_option_crud.get_modifier_option_by_id(modifier_option_id)
    if not option:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Modifier option not found"
        )
    return option


@router.get("/modifiers/{modifier_id}/options", response_model=List[ModifierOption])
async def get_modifier_options(modifier_id: int):
    """Get all options for a modifier."""
    try:
        options = modifier_option_crud.get_options_by_modifier(modifier_id)
        return options
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve modifier options: {str(e)}"
        )


@router.get("/modifiers/{modifier_id}/options/available", response_model=List[ModifierOption])
async def get_available_modifier_options(modifier_id: int):
    """Get available options for a modifier."""
    try:
        options = modifier_option_crud.get_available_options(modifier_id)
        return options
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve available options: {str(e)}"
        )


@router.put("/modifier-options/{modifier_option_id}", response_model=dict)
async def update_modifier_option(modifier_option_id: int, option_data: ModifierOptionUpdate):
    """Update modifier option information."""
    try:
        rows_affected = modifier_option_crud.update_modifier_option(modifier_option_id, option_data)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Modifier option not found or no changes made"
            )
        return {"message": "Modifier option updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update modifier option: {str(e)}"
        )


@router.post("/modifier-options/{modifier_option_id}/toggle-availability", response_model=dict)
async def toggle_option_availability(modifier_option_id: int):
    """Toggle the availability of a modifier option."""
    try:
        rows_affected = modifier_option_crud.toggle_availability(modifier_option_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Modifier option not found"
            )
        return {"message": "Option availability toggled successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to toggle option availability: {str(e)}"
        )


@router.delete("/modifier-options/{modifier_option_id}", response_model=dict)
async def delete_modifier_option(modifier_option_id: int):
    """Delete a modifier option."""
    try:
        rows_affected = modifier_option_crud.delete_modifier_option(modifier_option_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Modifier option not found"
            )
        return {"message": "Modifier option deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete modifier option: {str(e)}"
        )
