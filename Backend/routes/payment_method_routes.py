from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from crud.payment_method_crud import PaymentMethodCRUD
from models import (
    PaymentMethod, PaymentMethodCreate, PaymentMethodUpdate,
    PaymentTypeEnum, PaginationParams
)

router = APIRouter()
payment_crud = PaymentMethodCRUD()


@router.post("/customers/{customer_id}/payment-methods", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_payment_method(customer_id: int, payment_data: PaymentMethodCreate):
    """Create a new payment method for a customer."""
    try:
        # Ensure the customer_id matches
        payment_data.customer_id = customer_id
        payment_method_id = payment_crud.create_payment_method(payment_data)
        return {"message": "Payment method created successfully", "payment_method_id": payment_method_id}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create payment method: {str(e)}"
        )


@router.get("/payment-methods/{payment_method_id}", response_model=PaymentMethod)
async def get_payment_method(payment_method_id: int):
    """Get payment method by ID."""
    payment_method = payment_crud.get_payment_method_by_id(payment_method_id)
    if not payment_method:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment method not found"
        )
    return payment_method


@router.get("/customers/{customer_id}/payment-methods", response_model=List[PaymentMethod])
async def get_customer_payment_methods(customer_id: int):
    """Get all payment methods for a customer."""
    try:
        payment_methods = payment_crud.get_payment_methods_by_customer(customer_id)
        return payment_methods
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve payment methods: {str(e)}"
        )


@router.get("/customers/{customer_id}/payment-methods/default", response_model=PaymentMethod)
async def get_default_payment_method(customer_id: int):
    """Get default payment method for a customer."""
    payment_method = payment_crud.get_default_payment_method(customer_id)
    if not payment_method:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No default payment method found for customer"
        )
    return payment_method


@router.get("/customers/{customer_id}/payment-methods/by-type/{payment_type}", response_model=List[PaymentMethod])
async def get_payment_methods_by_type(customer_id: int, payment_type: PaymentTypeEnum):
    """Get payment methods by type for a customer."""
    try:
        payment_methods = payment_crud.get_payment_methods_by_type(customer_id, payment_type)
        return payment_methods
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve payment methods: {str(e)}"
        )


@router.get("/customers/{customer_id}/payment-methods/expiring", response_model=List[PaymentMethod])
async def get_expiring_cards(customer_id: int, months_ahead: int = 3):
    """Get cards expiring within specified months."""
    try:
        payment_methods = payment_crud.get_expiring_cards(customer_id, months_ahead)
        return payment_methods
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to retrieve expiring cards: {str(e)}"
        )


@router.put("/payment-methods/{payment_method_id}", response_model=dict)
async def update_payment_method(payment_method_id: int, payment_data: PaymentMethodUpdate):
    """Update payment method information."""
    try:
        rows_affected = payment_crud.update_payment_method(payment_method_id, payment_data)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Payment method not found or no changes made"
            )
        return {"message": "Payment method updated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update payment method: {str(e)}"
        )


@router.post("/customers/{customer_id}/payment-methods/{payment_method_id}/set-default", response_model=dict)
async def set_default_payment_method(customer_id: int, payment_method_id: int):
    """Set a payment method as the default for a customer."""
    try:
        rows_affected = payment_crud.set_default_payment_method(customer_id, payment_method_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Payment method not found"
            )
        return {"message": "Default payment method set successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to set default payment method: {str(e)}"
        )


@router.delete("/payment-methods/{payment_method_id}", response_model=dict)
async def delete_payment_method(payment_method_id: int):
    """Delete a payment method."""
    try:
        rows_affected = payment_crud.delete_payment_method(payment_method_id)
        if rows_affected == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Payment method not found"
            )
        return {"message": "Payment method deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to delete payment method: {str(e)}"
        )
