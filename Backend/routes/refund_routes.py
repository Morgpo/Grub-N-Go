from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from datetime import datetime
from crud.refund_crud import RefundCRUD
from models import (
    Refund, RefundCreate, RefundUpdate,
    RefundStatusEnum, PaginationParams
)

router = APIRouter()
refund_crud = RefundCRUD()


@router.post("/orders/{order_id}/refunds", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_refund(order_id: int, refund_data: RefundCreate, requested_by: Optional[int] = None):
    """Create a new refund request for an order."""
    try:
        # Ensure the order_id matches
        refund_data.order_id = order_id
        refund_id = refund_crud.create_refund(refund_data, requested_by)
        return {"message": "Refund request created successfully", "refund_id": refund_id}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create refund: {str(e)}"
        )


@router.get("/refunds/{refund_id}", response_model=Refund)
async def get_refund(refund_id: int):
    """Get refund by ID."""
    refund = refund_crud.get_refund_by_id(refund_id)
    if not refund:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Refund not found"
        )
    return refund


@router.get("/orders/{order_id}/refunds", response_model=List[Refund])
async def get_order_refunds(order_id: int):
    """Get all refunds for an order."""
    try:
        refunds = refund_crud.get_refunds_by_order(order_id)
        return refunds
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve refunds: {str(e)}"
        )


@router.get("/refunds/status/{status}", response_model=List[Refund])
async def get_refunds_by_status(status: RefundStatusEnum, limit: int = 20, offset: int = 0):
    """Get refunds by status with pagination."""
    try:
        pagination = PaginationParams(limit=limit, offset=offset)
        refunds = refund_crud.get_refunds_by_status(status, pagination)
        return refunds
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve refunds: {str(e)}"
        )


@router.get("/refunds/pending", response_model=List[Refund])
async def get_pending_refunds(limit: int = 20, offset: int = 0):
    """Get all pending refunds."""
    try:
        pagination = PaginationParams(limit=limit, offset=offset)
        refunds = refund_crud.get_pending_refunds(pagination)
        return refunds
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve pending refunds: {str(e)}"
        )


@router.get("/customers/{customer_id}/refunds", response_model=List[dict])
async def get_customer_refunds(customer_id: int, limit: int = 20, offset: int = 0):
    """Get refunds for a customer with order details."""
    try:
        pagination = PaginationParams(limit=limit, offset=offset)
        refunds = refund_crud.get_refunds_by_customer(customer_id, pagination)
        return refunds
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve customer refunds: {str(e)}"
        )


@router.get("/restaurants/{restaurant_id}/refunds", response_model=List[dict])
async def get_restaurant_refunds(restaurant_id: int, limit: int = 20, offset: int = 0):
    """Get refunds for a restaurant with order details."""
    try:
        pagination = PaginationParams(limit=limit, offset=offset)
        refunds = refund_crud.get_refunds_by_restaurant(restaurant_id, pagination)
        return refunds
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve restaurant refunds: {str(e)}"
        )


@router.get("/orders/{order_id}/refunds/total", response_model=dict)
async def get_total_refunded_amount(order_id: int):
    """Get total amount refunded for an order."""
    try:
        total_refunded = refund_crud.get_total_refunded_amount(order_id)
        return {"order_id": order_id, "total_refunded_amount": total_refunded}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to calculate total refunded amount: {str(e)}"
        )


@router.put("/refunds/{refund_id}", response_model=dict)
async def update_refund(refund_id: int, refund_data: RefundUpdate):
    """Update refund information."""
    try:
        rows_affected = refund_crud.update_refund(refund_id, refund_data)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Refund not found or no changes made"
            )
        return {"message": "Refund updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update refund: {str(e)}"
        )


@router.post("/refunds/{refund_id}/approve", response_model=dict)
async def approve_refund(refund_id: int, transaction_id: Optional[int] = None):
    """Approve and process a refund."""
    try:
        rows_affected = refund_crud.approve_refund(refund_id, transaction_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Refund not found"
            )
        return {"message": "Refund approved and processed successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to approve refund: {str(e)}"
        )


@router.post("/refunds/{refund_id}/reject", response_model=dict)
async def reject_refund(refund_id: int):
    """Reject a refund request."""
    try:
        rows_affected = refund_crud.reject_refund(refund_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Refund not found"
            )
        return {"message": "Refund rejected successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to reject refund: {str(e)}"
        )


@router.post("/refunds/{refund_id}/link-transaction/{transaction_id}", response_model=dict)
async def link_transaction_to_refund(refund_id: int, transaction_id: int):
    """Link a refund to a transaction."""
    try:
        rows_affected = refund_crud.link_transaction(refund_id, transaction_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Refund not found"
            )
        return {"message": "Transaction linked to refund successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to link transaction: {str(e)}"
        )


@router.get("/refunds/statistics", response_model=dict)
async def get_refund_statistics(start_date: Optional[datetime] = None, end_date: Optional[datetime] = None):
    """Get refund statistics for a date range."""
    try:
        statistics = refund_crud.get_refund_statistics(start_date, end_date)
        return statistics
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve refund statistics: {str(e)}"
        )


@router.delete("/refunds/{refund_id}", response_model=dict)
async def delete_refund(refund_id: int):
    """Delete a refund (only allowed for PENDING status)."""
    try:
        rows_affected = refund_crud.delete_refund(refund_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Refund not found or cannot be deleted (only PENDING refunds can be deleted)"
            )
        return {"message": "Refund deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete refund: {str(e)}"
        )
