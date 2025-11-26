from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from datetime import time
from crud.business_hours_crud import BusinessHoursCRUD
from models import (
    BusinessHours, BusinessHoursCreate, BusinessHoursUpdate,
    DayOfWeekEnum, PaginationParams
)

router = APIRouter()
business_hours_crud = BusinessHoursCRUD()


@router.post("/restaurants/{restaurant_id}/business-hours", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_business_hours(restaurant_id: int, hours_data: BusinessHoursCreate):
    """Create business hours for a restaurant."""
    try:
        # Ensure the restaurant_id matches
        hours_data.restaurant_id = restaurant_id
        business_hours_id = business_hours_crud.create_business_hours(hours_data)
        return {"message": "Business hours created successfully", "business_hours_id": business_hours_id}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create business hours: {str(e)}"
        )


@router.post("/restaurants/{restaurant_id}/business-hours/standard", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_standard_hours(
    restaurant_id: int, 
    open_time: time, 
    close_time: time,
    closed_days: Optional[List[DayOfWeekEnum]] = None
):
    """Create standard business hours for all days of the week."""
    try:
        created_ids = business_hours_crud.create_standard_hours(
            restaurant_id, open_time, close_time, closed_days or []
        )
        return {
            "message": "Standard business hours created successfully", 
            "business_hours_ids": created_ids
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create standard hours: {str(e)}"
        )


@router.get("/business-hours/{business_hours_id}", response_model=BusinessHours)
async def get_business_hours(business_hours_id: int):
    """Get business hours by ID."""
    business_hours = business_hours_crud.get_business_hours_by_id(business_hours_id)
    if not business_hours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Business hours not found"
        )
    return business_hours


@router.get("/restaurants/{restaurant_id}/business-hours", response_model=List[BusinessHours])
async def get_restaurant_business_hours(restaurant_id: int):
    """Get all business hours for a restaurant."""
    try:
        business_hours = business_hours_crud.get_business_hours_by_restaurant(restaurant_id)
        return business_hours
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve business hours: {str(e)}"
        )


@router.get("/restaurants/{restaurant_id}/business-hours/day/{day_of_week}", response_model=BusinessHours)
async def get_business_hours_for_day(restaurant_id: int, day_of_week: DayOfWeekEnum):
    """Get business hours for a specific day."""
    business_hours = business_hours_crud.get_business_hours_for_day(restaurant_id, day_of_week)
    if not business_hours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Business hours not found for {day_of_week.value}"
        )
    return business_hours


@router.get("/restaurants/{restaurant_id}/business-hours/today", response_model=BusinessHours)
async def get_todays_hours(restaurant_id: int):
    """Get today's business hours for a restaurant."""
    business_hours = business_hours_crud.get_todays_hours(restaurant_id)
    if not business_hours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Today's business hours not found"
        )
    return business_hours


@router.get("/restaurants/{restaurant_id}/status/open-now", response_model=dict)
async def check_if_open_now(restaurant_id: int):
    """Check if restaurant is currently open."""
    try:
        status_info = business_hours_crud.check_if_open_now(restaurant_id)
        if not status_info:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Restaurant business hours not found"
            )
        return status_info
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to check restaurant status: {str(e)}"
        )


@router.get("/restaurants/open-now", response_model=List[dict])
async def get_open_restaurants_now():
    """Get all restaurants that are currently open."""
    try:
        open_restaurants = business_hours_crud.get_open_restaurants_now()
        return open_restaurants
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve open restaurants: {str(e)}"
        )


@router.put("/business-hours/{business_hours_id}", response_model=dict)
async def update_business_hours(business_hours_id: int, hours_data: BusinessHoursUpdate):
    """Update business hours."""
    try:
        rows_affected = business_hours_crud.update_business_hours(business_hours_id, hours_data)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Business hours not found or no changes made"
            )
        return {"message": "Business hours updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update business hours: {str(e)}"
        )


@router.post("/business-hours/{business_hours_id}/toggle-closed", response_model=dict)
async def toggle_closed_status(business_hours_id: int):
    """Toggle the closed status for business hours."""
    try:
        rows_affected = business_hours_crud.toggle_closed_status(business_hours_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Business hours not found"
            )
        return {"message": "Closed status toggled successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to toggle closed status: {str(e)}"
        )


@router.post("/restaurants/{restaurant_id}/close-today", response_model=dict)
async def close_restaurant_today(restaurant_id: int):
    """Mark restaurant as closed for today."""
    try:
        rows_affected = business_hours_crud.close_restaurant_today(restaurant_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Restaurant business hours not found for today"
            )
        return {"message": "Restaurant marked as closed for today"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to close restaurant: {str(e)}"
        )


@router.post("/restaurants/{restaurant_id}/open-today", response_model=dict)
async def open_restaurant_today(restaurant_id: int):
    """Mark restaurant as open for today."""
    try:
        rows_affected = business_hours_crud.open_restaurant_today(restaurant_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Restaurant business hours not found for today"
            )
        return {"message": "Restaurant marked as open for today"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to open restaurant: {str(e)}"
        )


@router.get("/restaurants/{restaurant_id}/next-opening", response_model=dict)
async def get_next_opening_time(restaurant_id: int):
    """Get the next time the restaurant will be open."""
    try:
        next_opening = business_hours_crud.get_next_opening_time(restaurant_id)
        if not next_opening:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No upcoming opening times found"
            )
        return next_opening
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to get next opening time: {str(e)}"
        )


@router.delete("/business-hours/{business_hours_id}", response_model=dict)
async def delete_business_hours(business_hours_id: int):
    """Delete business hours."""
    try:
        rows_affected = business_hours_crud.delete_business_hours(business_hours_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Business hours not found"
            )
        return {"message": "Business hours deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete business hours: {str(e)}"
        )
