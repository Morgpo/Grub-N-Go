from fastapi import APIRouter, HTTPException, status
from typing import List
from models import (
    Order, OrderCreate, OrderUpdate, OrderStatusEnum,
    OrderItem, OrderItemCreate, OrderItemUpdate,
    OrderTotalCalculation
)
from crud.order_crud import OrderCRUD, OrderItemCRUD

router = APIRouter()

# Initialize CRUD instances
order_crud = OrderCRUD()
order_item_crud = OrderItemCRUD()


# Order routes
@router.post("/orders/", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_order(order_data: OrderCreate):
    """Create a new order."""
    try:
        order_id = order_crud.create_order(order_data)
        return {"order_id": order_id, "message": "Order created successfully"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/orders/{order_id}", response_model=Order)
async def get_order(order_id: int):
    """Get order by ID with customer and restaurant info."""
    order = order_crud.get_order_by_id(order_id)
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    return order


@router.get("/customers/{customer_id}/orders/", response_model=List[Order])
async def get_orders_by_customer(customer_id: int):
    """Get all orders for a customer."""
    return order_crud.get_orders_by_customer(customer_id)


@router.get("/restaurants/{restaurant_id}/orders/", response_model=List[Order])
async def get_orders_by_restaurant(restaurant_id: int):
    """Get all orders for a restaurant."""
    return order_crud.get_orders_by_restaurant(restaurant_id)


@router.get("/orders/status/{status}", response_model=List[Order])
async def get_orders_by_status(status: OrderStatusEnum):
    """Get orders by status."""
    return order_crud.get_orders_by_status(status)


@router.get("/restaurants/{restaurant_id}/orders/pending/", response_model=List[Order])
async def get_pending_orders_by_restaurant(restaurant_id: int):
    """Get pending orders for a restaurant."""
    return order_crud.get_pending_orders_by_restaurant(restaurant_id)


@router.put("/orders/{order_id}", response_model=dict)
async def update_order(order_id: int, order_data: OrderUpdate):
    """Update order information."""
    rows_affected = order_crud.update_order(order_id, order_data)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found or no changes made")
    return {"message": "Order updated successfully"}


@router.put("/orders/{order_id}/status", response_model=dict)
async def update_order_status(order_id: int, status: OrderStatusEnum):
    """Update order status with appropriate timestamps."""
    rows_affected = order_crud.update_order_status(order_id, status)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    return {"message": "Order status updated successfully"}


@router.put("/orders/{order_id}/totals", response_model=dict)
async def update_order_totals(order_id: int, subtotal: float, tax: float, total: float):
    """Update order totals."""
    if subtotal < 0 or tax < 0 or total < 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Totals cannot be negative")
    
    rows_affected = order_crud.update_order_totals(order_id, subtotal, tax, total)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    return {"message": "Order totals updated successfully"}


@router.get("/orders/{order_id}/calculate-total", response_model=OrderTotalCalculation)
async def calculate_order_total(order_id: int):
    """Get order total calculation from order items."""
    calculation = order_crud.calculate_order_total(order_id)
    if not calculation:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found or has no items")
    return calculation


@router.delete("/orders/{order_id}", response_model=dict)
async def delete_order(order_id: int):
    """Delete order."""
    rows_affected = order_crud.delete_order(order_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    return {"message": "Order deleted successfully"}


# Order Item routes
@router.post("/order-items/", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_order_item(order_item_data: OrderItemCreate):
    """Create a new order item."""
    try:
        order_item_id = order_item_crud.create_order_item(
            order_id=order_item_data.order_id,
            menu_item_id=order_item_data.menu_item_id,
            quantity=order_item_data.quantity,
            unit_price=float(order_item_data.unit_price),
            item_name=order_item_data.item_name,
            item_description=order_item_data.item_description,
            notes=order_item_data.notes
        )
        return {"order_item_id": order_item_id, "message": "Order item created successfully"}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/order-items/{order_item_id}", response_model=OrderItem)
async def get_order_item(order_item_id: int):
    """Get order item by ID."""
    order_item = order_item_crud.get_order_item_by_id(order_item_id)
    if not order_item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order item not found")
    return order_item


@router.get("/orders/{order_id}/items/", response_model=List[OrderItem])
async def get_order_items_by_order(order_id: int):
    """Get all order items for an order."""
    return order_item_crud.get_order_items_by_order(order_id)


@router.get("/orders/{order_id}/items/detailed/", response_model=List[dict])
async def get_order_items_with_full_info(order_id: int):
    """Get order items with full order and restaurant info."""
    return order_item_crud.get_order_items_with_full_info(order_id)


@router.put("/order-items/{order_item_id}", response_model=dict)
async def update_order_item(order_item_id: int, order_item_data: OrderItemUpdate):
    """Update order item information."""
    rows_affected = order_item_crud.update_order_item(order_item_id, order_item_data)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order item not found or no changes made")
    return {"message": "Order item updated successfully"}


@router.put("/order-items/{order_item_id}/quantity", response_model=dict)
async def update_order_item_quantity(order_item_id: int, quantity: int):
    """Update order item quantity only."""
    if quantity <= 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Quantity must be greater than 0")
    
    rows_affected = order_item_crud.update_order_item_quantity(order_item_id, quantity)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order item not found")
    return {"message": "Order item quantity updated successfully"}


@router.delete("/order-items/{order_item_id}", response_model=dict)
async def delete_order_item(order_item_id: int):
    """Delete order item."""
    rows_affected = order_item_crud.delete_order_item(order_item_id)
    if rows_affected == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order item not found")
    return {"message": "Order item deleted successfully"}


@router.delete("/orders/{order_id}/items/", response_model=dict)
async def delete_all_order_items(order_id: int):
    """Delete all order items for an order."""
    rows_affected = order_item_crud.delete_all_order_items(order_id)
    return {"message": f"Deleted {rows_affected} order items successfully"}
