from fastapi import APIRouter, HTTPException, status
from typing import List
from models import (
    PopularMenuItem,
    CustomerOrderSummary,
    RestaurantRevenueSummary
)
from crud.utility_crud import UtilityCRUD

router = APIRouter()

# Initialize CRUD instance
utility_crud = UtilityCRUD()


@router.get("/restaurants/{restaurant_id}/popular-items/", response_model=List[PopularMenuItem])
async def get_popular_menu_items(restaurant_id: int, limit: int = 10):
    """Get popular menu items for a restaurant (most ordered)."""
    if limit <= 0 or limit > 50:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Limit must be between 1 and 50")
    
    return utility_crud.get_popular_menu_items(restaurant_id, limit)


@router.get("/customers/{customer_id}/summary/", response_model=CustomerOrderSummary)
async def get_customer_order_summary(customer_id: int):
    """Get customer order history summary."""
    summary = utility_crud.get_customer_order_summary(customer_id)
    if not summary:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Customer not found")
    return summary


@router.get("/restaurants/{restaurant_id}/revenue-summary/", response_model=RestaurantRevenueSummary)
async def get_restaurant_revenue_summary(restaurant_id: int):
    """Get restaurant revenue summary."""
    summary = utility_crud.get_restaurant_revenue_summary(restaurant_id)
    if not summary:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurant not found")
    return summary


@router.get("/customers/summaries/", response_model=List[CustomerOrderSummary])
async def get_all_customer_summaries():
    """Get order summaries for all customers."""
    return utility_crud.get_all_customer_summaries()


@router.get("/restaurants/revenue-summaries/", response_model=List[RestaurantRevenueSummary])
async def get_all_restaurant_summaries():
    """Get revenue summaries for all restaurants."""
    return utility_crud.get_all_restaurant_summaries()
