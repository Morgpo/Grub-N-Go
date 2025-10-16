from fastapi import APIRouter, HTTPException, status, Depends
from typing import List, Optional
from crud.address_crud import AddressCRUD
from models import (
    Address, AddressCreate, AddressUpdate,
    PaginationParams
)

router = APIRouter()
address_crud = AddressCRUD()


@router.post("/customers/{customer_id}/addresses", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_address(customer_id: int, address_data: AddressCreate):
    """Create a new address for a customer."""
    try:
        # Ensure the customer_id matches
        address_data.customer_id = customer_id
        address_id = address_crud.create_address(address_data)
        return {"message": "Address created successfully", "address_id": address_id}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create address: {str(e)}"
        )


@router.get("/addresses/{address_id}", response_model=Address)
async def get_address(address_id: int):
    """Get address by ID."""
    address = address_crud.get_address_by_id(address_id)
    if not address:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Address not found"
        )
    return address


@router.get("/customers/{customer_id}/addresses", response_model=List[Address])
async def get_customer_addresses(customer_id: int):
    """Get all addresses for a customer."""
    try:
        addresses = address_crud.get_addresses_by_customer(customer_id)
        return addresses
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve addresses: {str(e)}"
        )


@router.get("/customers/{customer_id}/addresses/default", response_model=Address)
async def get_default_address(customer_id: int):
    """Get default address for a customer."""
    address = address_crud.get_default_address(customer_id)
    if not address:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No default address found for customer"
        )
    return address


@router.put("/addresses/{address_id}", response_model=dict)
async def update_address(address_id: int, address_data: AddressUpdate):
    """Update address information."""
    try:
        rows_affected = address_crud.update_address(address_id, address_data)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Address not found or no changes made"
            )
        return {"message": "Address updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update address: {str(e)}"
        )


@router.post("/customers/{customer_id}/addresses/{address_id}/set-default", response_model=dict)
async def set_default_address(customer_id: int, address_id: int):
    """Set an address as the default for a customer."""
    try:
        rows_affected = address_crud.set_default_address(customer_id, address_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Address not found"
            )
        return {"message": "Default address set successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to set default address: {str(e)}"
        )


@router.delete("/addresses/{address_id}", response_model=dict)
async def delete_address(address_id: int):
    """Delete an address."""
    try:
        rows_affected = address_crud.delete_address(address_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Address not found"
            )
        return {"message": "Address deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete address: {str(e)}"
        )


@router.get("/addresses/search", response_model=List[Address])
async def search_addresses_by_location(city: str, state: str):
    """Search addresses by city and state."""
    try:
        addresses = address_crud.get_addresses_by_city_state(city, state)
        return addresses
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to search addresses: {str(e)}"
        )
