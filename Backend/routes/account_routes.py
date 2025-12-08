from fastapi import APIRouter, HTTPException, status
from typing import List
from models import (
    Account, AccountResponse, AccountCreate, AccountUpdate,
    Customer, CustomerCreate, CustomerUpdate,
    Restaurant, RestaurantCreate, RestaurantUpdate,
    PaginationParams
)
from crud.account_crud import AccountCRUD, CustomerCRUD, RestaurantCRUD

router = APIRouter()

# Initialize CRUD instances
account_crud = AccountCRUD()
customer_crud = CustomerCRUD()
restaurant_crud = RestaurantCRUD()


# Account routes
@router.post("/accounts/", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_account(account_data: AccountCreate):
    """Create a new account."""
    try:
        account_id = account_crud.create_account(account_data)
        return {"account_id": account_id, "message": "Account created successfully"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/accounts/{account_id}", response_model=AccountResponse)
async def get_account(account_id: int):
    """Get account by ID."""
    account = account_crud.get_account_by_id(account_id)
    if not account:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    return account


@router.get("/accounts/email/{email}", response_model=AccountResponse)
async def get_account_by_email(email: str):
    """Get account by email."""
    account = account_crud.get_account_by_email(email)
    if not account:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    return account


@router.get("/accounts/role/{role}", response_model=List[AccountResponse])
async def get_accounts_by_role(role: str):
    """Get all accounts by role."""
    return account_crud.get_accounts_by_role(role)


@router.get("/accounts/", response_model=List[AccountResponse])
async def get_accounts_paginated(limit: int = 20, offset: int = 0):
    """Get all accounts with pagination."""
    pagination = PaginationParams(limit=limit, offset=offset)
    return account_crud.get_accounts_paginated(pagination)


@router.put("/accounts/{account_id}", response_model=dict)
async def update_account(account_id: int, account_data: AccountUpdate):
    """Update account information."""
    rows_affected = account_crud.update_account(account_id, account_data)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found or no changes made")
    return {"message": "Account updated successfully"}


@router.put("/accounts/{account_id}/password", response_model=dict)
async def update_password(account_id: int, new_password: str):
    """Update account password."""
    rows_affected = account_crud.update_password(account_id, new_password)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    return {"message": "Password updated successfully"}


@router.delete("/accounts/{account_id}", response_model=dict)
async def delete_account(account_id: int):
    """Delete account (will cascade to Customer/Restaurant)."""
    rows_affected = account_crud.delete_account(account_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    return {"message": "Account deleted successfully"}


# Customer routes
@router.post("/customers/", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_customer(account_id: int, customer_data: CustomerCreate):
    """Create a new customer (account_id should already exist)."""
    try:
        customer_crud.create_customer(account_id, customer_data)
        return {"customer_id": account_id, "message": "Customer created successfully"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/customers/{customer_id}", response_model=Customer)
async def get_customer(customer_id: int):
    """Get customer by ID."""
    customer = customer_crud.get_customer_by_id(customer_id)
    if not customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    return customer


@router.get("/customers/email/{email}", response_model=Customer)
async def get_customer_by_email(email: str):
    """Get customer by email."""
    customer = customer_crud.get_customer_by_email(email)
    if not customer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    return customer


@router.get("/customers/", response_model=List[Customer])
async def get_all_customers():
    """Get all customers."""
    return customer_crud.get_all_customers()


@router.put("/customers/{customer_id}", response_model=dict)
async def update_customer(customer_id: int, customer_data: CustomerUpdate):
    """Update customer information."""
    rows_affected = customer_crud.update_customer(customer_id, customer_data)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found or no changes made")
    return {"message": "Customer updated successfully"}


@router.delete("/customers/{customer_id}", response_model=dict)
async def delete_customer(customer_id: int):
    """Delete customer."""
    rows_affected = customer_crud.delete_customer(customer_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    return {"message": "Customer deleted successfully"}


# Restaurant routes
@router.post("/restaurants/", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_restaurant(account_id: int, restaurant_data: RestaurantCreate):
    """Create a new restaurant (account_id should already exist)."""
    try:
        restaurant_crud.create_restaurant(account_id, restaurant_data)
        return {"restaurant_id": account_id, "message": "Restaurant created successfully"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/restaurants/{restaurant_id}", response_model=Restaurant)
async def get_restaurant(restaurant_id: int):
    """Get restaurant by ID."""
    restaurant = restaurant_crud.get_restaurant_by_id(restaurant_id)
    if not restaurant:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurant not found")
    return restaurant


@router.get("/restaurants/email/{email}", response_model=Restaurant)
async def get_restaurant_by_email(email: str):
    """Get restaurant by email."""
    restaurant = restaurant_crud.get_restaurant_by_email(email)
    if not restaurant:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurant not found")
    return restaurant


@router.get("/restaurants/", response_model=List[Restaurant])
async def get_all_restaurants():
    """Get all restaurants."""
    return restaurant_crud.get_all_restaurants()


@router.get("/restaurants/open/", response_model=List[Restaurant])
async def get_open_restaurants():
    """Get open restaurants only."""
    return restaurant_crud.get_open_restaurants()


@router.put("/restaurants/{restaurant_id}", response_model=dict)
async def update_restaurant(restaurant_id: int, restaurant_data: RestaurantUpdate):
    """Update restaurant information."""
    rows_affected = restaurant_crud.update_restaurant(restaurant_id, restaurant_data)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurant not found or no changes made")
    return {"message": "Restaurant updated successfully"}


@router.put("/restaurants/{restaurant_id}/toggle-status", response_model=dict)
async def toggle_restaurant_status(restaurant_id: int):
    """Toggle restaurant open/closed status."""
    rows_affected = restaurant_crud.toggle_restaurant_status(restaurant_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurant not found")
    return {"message": "Restaurant status toggled successfully"}


@router.delete("/restaurants/{restaurant_id}", response_model=dict)
async def delete_restaurant(restaurant_id: int):
    """Delete restaurant."""
    rows_affected = restaurant_crud.delete_restaurant(restaurant_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurant not found")
    return {"message": "Restaurant deleted successfully"}
