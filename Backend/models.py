from datetime import datetime
from decimal import Decimal
from enum import Enum
from typing import Optional, List
from pydantic import BaseModel, Field, EmailStr


class RoleEnum(str, Enum):
    CUSTOMER = "CUSTOMER"
    RESTAURANT = "RESTAURANT"


class OrderStatusEnum(str, Enum):
    DRAFT = "DRAFT"
    PENDING = "PENDING"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"
    ARCHIVED = "ARCHIVED"


# Base models for requests
class AccountCreate(BaseModel):
    email: EmailStr
    password: str
    role: RoleEnum


class AccountUpdate(BaseModel):
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    role: Optional[RoleEnum] = None


class CustomerCreate(BaseModel):
    customer_name: str


class CustomerUpdate(BaseModel):
    customer_name: Optional[str] = None


class RestaurantCreate(BaseModel):
    restaurant_name: str
    is_open: bool = True


class RestaurantUpdate(BaseModel):
    restaurant_name: Optional[str] = None
    is_open: Optional[bool] = None


class MenuCreate(BaseModel):
    restaurant_id: int
    name: str
    is_active: bool = True


class MenuUpdate(BaseModel):
    name: Optional[str] = None
    is_active: Optional[bool] = None


class MenuItemCreate(BaseModel):
    menu_id: int
    name: str
    description: Optional[str] = None
    price: Decimal = Field(..., decimal_places=2)
    is_available: bool = True


class MenuItemUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[Decimal] = Field(None, decimal_places=2)
    is_available: Optional[bool] = None


class OrderCreate(BaseModel):
    customer_id: int
    restaurant_id: int
    status: OrderStatusEnum = OrderStatusEnum.DRAFT
    subtotal: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    tax: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    total: Decimal = Field(default=Decimal("0.00"), decimal_places=2)


class OrderUpdate(BaseModel):
    status: Optional[OrderStatusEnum] = None
    subtotal: Optional[Decimal] = Field(None, decimal_places=2)
    tax: Optional[Decimal] = Field(None, decimal_places=2)
    total: Optional[Decimal] = Field(None, decimal_places=2)


class OrderItemCreate(BaseModel):
    order_id: int
    menu_item_id: int
    quantity: int = Field(..., ge=1)
    unit_price: Decimal = Field(..., decimal_places=2)
    notes: Optional[str] = None


class OrderItemUpdate(BaseModel):
    quantity: Optional[int] = Field(None, ge=1)
    unit_price: Optional[Decimal] = Field(None, decimal_places=2)
    notes: Optional[str] = None


# Response models
class Account(BaseModel):
    account_id: int
    email: str
    role: RoleEnum
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class Customer(BaseModel):
    customer_id: int
    customer_name: str
    email: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class Restaurant(BaseModel):
    restaurant_id: int
    restaurant_name: str
    is_open: bool
    email: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class Menu(BaseModel):
    menu_id: int
    restaurant_id: int
    name: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class MenuItem(BaseModel):
    menu_item_id: int
    menu_id: int
    name: str
    description: Optional[str] = None
    price: Decimal
    is_available: bool
    created_at: datetime
    updated_at: datetime
    menu_name: Optional[str] = None
    restaurant_id: Optional[int] = None

    class Config:
        from_attributes = True


class Order(BaseModel):
    order_id: int
    customer_id: int
    restaurant_id: int
    status: OrderStatusEnum
    submitted_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    archived_at: Optional[datetime] = None
    subtotal: Decimal
    tax: Decimal
    total: Decimal
    created_at: datetime
    updated_at: datetime
    customer_name: Optional[str] = None
    restaurant_name: Optional[str] = None

    class Config:
        from_attributes = True


class OrderItem(BaseModel):
    order_item_id: int
    order_id: int
    menu_item_id: int
    quantity: int
    unit_price: Decimal
    notes: Optional[str] = None
    item_name: Optional[str] = None
    description: Optional[str] = None

    class Config:
        from_attributes = True


# Utility models
class PaginationParams(BaseModel):
    limit: int = Field(default=20, ge=1, le=100)
    offset: int = Field(default=0, ge=0)


class OrderTotalCalculation(BaseModel):
    order_id: int
    calculated_subtotal: Decimal

    class Config:
        from_attributes = True


class PopularMenuItem(BaseModel):
    menu_item_id: int
    name: str
    price: Decimal
    order_count: int
    total_quantity_sold: int

    class Config:
        from_attributes = True


class CustomerOrderSummary(BaseModel):
    customer_id: int
    customer_name: str
    total_orders: int
    total_spent: Decimal
    last_order_date: Optional[datetime] = None

    class Config:
        from_attributes = True


class RestaurantRevenueSummary(BaseModel):
    restaurant_id: int
    restaurant_name: str
    total_orders: int
    total_revenue: Decimal
    average_order_value: Decimal

    class Config:
        from_attributes = True
