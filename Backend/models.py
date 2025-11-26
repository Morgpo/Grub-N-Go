from datetime import datetime, time
from decimal import Decimal
from enum import Enum
from typing import Optional, List
from pydantic import BaseModel, Field, EmailStr


class RoleEnum(str, Enum):
    CUSTOMER = "CUSTOMER"
    RESTAURANT = "RESTAURANT"


class AccountStatusEnum(str, Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    SUSPENDED = "SUSPENDED"


class OrderStatusEnum(str, Enum):
    CREATED = "CREATED"
    CONFIRMED = "CONFIRMED"
    PREPARING = "PREPARING"
    READY = "READY"
    OUT_FOR_DELIVERY = "OUT_FOR_DELIVERY"
    DELIVERED = "DELIVERED"
    CANCELLED = "CANCELLED"
    FAILED = "FAILED"


class OperatingStatusEnum(str, Enum):
    OPEN = "OPEN"
    TEMPORARILY_CLOSED = "TEMPORARILY_CLOSED"
    PERMANENTLY_CLOSED = "PERMANENTLY_CLOSED"


class PaymentTypeEnum(str, Enum):
    CREDIT_CARD = "CREDIT_CARD"
    DEBIT_CARD = "DEBIT_CARD"
    PAYPAL = "PAYPAL"
    APPLE_PAY = "APPLE_PAY"
    GOOGLE_PAY = "GOOGLE_PAY"


class DayOfWeekEnum(str, Enum):
    MONDAY = "MONDAY"
    TUESDAY = "TUESDAY"
    WEDNESDAY = "WEDNESDAY"
    THURSDAY = "THURSDAY"
    FRIDAY = "FRIDAY"
    SATURDAY = "SATURDAY"
    SUNDAY = "SUNDAY"


# Base models for requests
class AccountCreate(BaseModel):
    email: EmailStr
    password: str
    role: RoleEnum


class AccountUpdate(BaseModel):
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    role: Optional[RoleEnum] = None
    status: Optional[AccountStatusEnum] = None


class CustomerCreate(BaseModel):
    customer_name: str
    phone: Optional[str] = None


class CustomerUpdate(BaseModel):
    customer_name: Optional[str] = None
    phone: Optional[str] = None


class RestaurantCreate(BaseModel):
    restaurant_name: str
    contact_phone: str
    contact_email: Optional[str] = None
    operating_status: OperatingStatusEnum = OperatingStatusEnum.OPEN
    street_address: str
    city: str
    state: str
    postal_code: str
    country: str = "USA"
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class RestaurantUpdate(BaseModel):
    restaurant_name: Optional[str] = None
    contact_phone: Optional[str] = None
    contact_email: Optional[str] = None
    operating_status: Optional[OperatingStatusEnum] = None
    street_address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


# Address models
class AddressCreate(BaseModel):
    customer_id: int
    address_label: Optional[str] = None
    street_address: str
    city: str
    state: str
    postal_code: str
    country: str = "USA"
    is_default: bool = False


class AddressUpdate(BaseModel):
    address_label: Optional[str] = None
    street_address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    is_default: Optional[bool] = None


# Payment Method models
class PaymentMethodCreate(BaseModel):
    customer_id: int
    payment_type: PaymentTypeEnum
    payment_token: str
    card_last_four: Optional[str] = None
    card_brand: Optional[str] = None
    expiry_month: Optional[int] = None
    expiry_year: Optional[int] = None
    is_default: bool = False


class PaymentMethodUpdate(BaseModel):
    expiry_month: Optional[int] = None
    expiry_year: Optional[int] = None
    is_default: Optional[bool] = None


# Business Hours models
class BusinessHoursCreate(BaseModel):
    restaurant_id: int
    day_of_week: DayOfWeekEnum
    open_time: time
    close_time: time
    is_closed: bool = False


class BusinessHoursUpdate(BaseModel):
    open_time: Optional[time] = None
    close_time: Optional[time] = None
    is_closed: Optional[bool] = None


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
    available_from: Optional[time] = None
    available_until: Optional[time] = None


class MenuItemUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[Decimal] = Field(None, decimal_places=2)
    is_available: Optional[bool] = None
    available_from: Optional[time] = None
    available_until: Optional[time] = None


class OrderCreate(BaseModel):
    customer_id: int
    restaurant_id: int
    delivery_address_id: Optional[int] = None
    delivery_street: Optional[str] = None
    delivery_city: Optional[str] = None
    delivery_state: Optional[str] = None
    delivery_postal_code: Optional[str] = None
    delivery_country: Optional[str] = None
    status: OrderStatusEnum = OrderStatusEnum.CREATED
    subtotal: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    tax: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    tax_rate: Optional[Decimal] = Field(None, decimal_places=4)
    delivery_fee: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    service_fee: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    tip: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    discount: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    total: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    payment_method_id: Optional[int] = None
    is_paid: bool = False


class OrderUpdate(BaseModel):
    status: Optional[OrderStatusEnum] = None
    delivery_address_id: Optional[int] = None
    delivery_street: Optional[str] = None
    delivery_city: Optional[str] = None
    delivery_state: Optional[str] = None
    delivery_postal_code: Optional[str] = None
    delivery_country: Optional[str] = None
    subtotal: Optional[Decimal] = Field(None, decimal_places=2)
    tax: Optional[Decimal] = Field(None, decimal_places=2)
    tax_rate: Optional[Decimal] = Field(None, decimal_places=4)
    delivery_fee: Optional[Decimal] = Field(None, decimal_places=2)
    service_fee: Optional[Decimal] = Field(None, decimal_places=2)
    tip: Optional[Decimal] = Field(None, decimal_places=2)
    discount: Optional[Decimal] = Field(None, decimal_places=2)
    total: Optional[Decimal] = Field(None, decimal_places=2)
    payment_method_id: Optional[int] = None
    is_paid: Optional[bool] = None


class OrderItemCreate(BaseModel):
    order_id: int
    menu_item_id: int
    item_name: str
    item_description: Optional[str] = None
    quantity: int = Field(..., ge=1)
    unit_price: Decimal = Field(..., decimal_places=2)
    notes: Optional[str] = None


class OrderItemUpdate(BaseModel):
    item_name: Optional[str] = None
    item_description: Optional[str] = None
    quantity: Optional[int] = Field(None, ge=1)
    unit_price: Optional[Decimal] = Field(None, decimal_places=2)
    notes: Optional[str] = None


# Response models
class Account(BaseModel):
    account_id: int
    email: str
    password_hash: str  # Internal use only, not returned in API responses
    role: RoleEnum
    status: AccountStatusEnum
    failed_login_attempts: int = 0
    last_login_attempt: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    created_by: Optional[int] = None

    class Config:
        from_attributes = True


class AccountResponse(BaseModel):
    """Account response model without password_hash for API responses."""
    account_id: int
    email: str
    role: RoleEnum
    status: AccountStatusEnum
    failed_login_attempts: int = 0
    last_login_attempt: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    created_by: Optional[int] = None

    class Config:
        from_attributes = True


class Customer(BaseModel):
    customer_id: int
    customer_name: str
    phone: Optional[str] = None
    email: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class Restaurant(BaseModel):
    restaurant_id: int
    restaurant_name: str
    contact_phone: str
    contact_email: Optional[str] = None
    operating_status: OperatingStatusEnum
    street_address: str
    city: str
    state: str
    postal_code: str
    country: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    email: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class Address(BaseModel):
    address_id: int
    customer_id: int
    address_label: Optional[str] = None
    street_address: str
    city: str
    state: str
    postal_code: str
    country: str
    is_default: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class PaymentMethod(BaseModel):
    payment_method_id: int
    customer_id: int
    payment_type: PaymentTypeEnum
    payment_token: str
    card_last_four: Optional[str] = None
    card_brand: Optional[str] = None
    expiry_month: Optional[int] = None
    expiry_year: Optional[int] = None
    is_default: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class BusinessHours(BaseModel):
    business_hours_id: int
    restaurant_id: int
    day_of_week: DayOfWeekEnum
    open_time: time
    close_time: time
    is_closed: bool
    
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
    available_from: Optional[time] = None
    available_until: Optional[time] = None
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
    delivery_address_id: Optional[int] = None
    delivery_street: Optional[str] = None
    delivery_city: Optional[str] = None
    delivery_state: Optional[str] = None
    delivery_postal_code: Optional[str] = None
    delivery_country: Optional[str] = None
    status: OrderStatusEnum
    created_at: datetime
    confirmed_at: Optional[datetime] = None
    prepared_at: Optional[datetime] = None
    ready_at: Optional[datetime] = None
    picked_up_at: Optional[datetime] = None
    delivered_at: Optional[datetime] = None
    cancelled_at: Optional[datetime] = None
    updated_at: datetime
    subtotal: Decimal
    tax: Decimal
    tax_rate: Optional[Decimal] = None
    delivery_fee: Decimal
    service_fee: Decimal
    tip: Decimal
    discount: Decimal
    total: Decimal
    payment_method_id: Optional[int] = None
    is_paid: bool
    customer_name: Optional[str] = None
    restaurant_name: Optional[str] = None

    class Config:
        from_attributes = True


class OrderItem(BaseModel):
    order_item_id: int
    order_id: int
    menu_item_id: int
    item_name: str
    item_description: Optional[str] = None
    quantity: int
    unit_price: Decimal
    notes: Optional[str] = None

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


# Additional transaction and audit models
class TransactionTypeEnum(str, Enum):
    AUTHORIZATION = "AUTHORIZATION"
    CAPTURE = "CAPTURE"
    REFUND = "REFUND"
    VOID = "VOID"


class TransactionStatusEnum(str, Enum):
    PENDING = "PENDING"
    SUCCESS = "SUCCESS"
    FAILED = "FAILED"


class RefundStatusEnum(str, Enum):
    PENDING = "PENDING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"


class AuditActionEnum(str, Enum):
    CREATE = "CREATE"
    UPDATE = "UPDATE"
    DELETE = "DELETE"
    STATUS_CHANGE = "STATUS_CHANGE"


# Modifier models
class ModifierCreate(BaseModel):
    menu_item_id: int
    modifier_name: str
    min_selections: int = 0
    max_selections: int = 1
    is_required: bool = False


class ModifierUpdate(BaseModel):
    modifier_name: Optional[str] = None
    min_selections: Optional[int] = None
    max_selections: Optional[int] = None
    is_required: Optional[bool] = None


class Modifier(BaseModel):
    modifier_id: int
    menu_item_id: int
    modifier_name: str
    min_selections: int
    max_selections: int
    is_required: bool
    created_at: datetime

    class Config:
        from_attributes = True


class ModifierOptionCreate(BaseModel):
    modifier_id: int
    option_name: str
    price_delta: Decimal = Field(default=Decimal("0.00"), decimal_places=2)
    is_available: bool = True


class ModifierOptionUpdate(BaseModel):
    option_name: Optional[str] = None
    price_delta: Optional[Decimal] = Field(None, decimal_places=2)
    is_available: Optional[bool] = None


class ModifierOption(BaseModel):
    modifier_option_id: int
    modifier_id: int
    option_name: str
    price_delta: Decimal
    is_available: bool
    created_at: datetime

    class Config:
        from_attributes = True


# Transaction models
class TransactionCreate(BaseModel):
    order_id: int
    transaction_type: TransactionTypeEnum
    amount: Decimal = Field(..., decimal_places=2)
    payment_provider: Optional[str] = None
    external_transaction_id: Optional[str] = None


class TransactionUpdate(BaseModel):
    status: Optional[TransactionStatusEnum] = None
    error_message: Optional[str] = None
    processed_at: Optional[datetime] = None


class Transaction(BaseModel):
    transaction_id: int
    order_id: int
    transaction_type: TransactionTypeEnum
    amount: Decimal
    status: TransactionStatusEnum
    payment_provider: Optional[str] = None
    external_transaction_id: Optional[str] = None
    error_message: Optional[str] = None
    created_at: datetime
    processed_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Refund models
class RefundCreate(BaseModel):
    order_id: int
    refund_amount: Decimal = Field(..., decimal_places=2)
    refund_reason: Optional[str] = None


class RefundUpdate(BaseModel):
    status: Optional[RefundStatusEnum] = None
    processed_at: Optional[datetime] = None


class Refund(BaseModel):
    refund_id: int
    order_id: int
    transaction_id: Optional[int] = None
    refund_amount: Decimal
    refund_reason: Optional[str] = None
    status: RefundStatusEnum
    requested_at: datetime
    processed_at: Optional[datetime] = None
    requested_by: Optional[int] = None

    class Config:
        from_attributes = True


# Audit models
class AuditLogCreate(BaseModel):
    table_name: str
    record_id: int
    action: AuditActionEnum
    field_name: Optional[str] = None
    old_value: Optional[str] = None
    new_value: Optional[str] = None
    performed_by: Optional[int] = None
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None


class AuditLog(BaseModel):
    audit_log_id: int
    table_name: str
    record_id: int
    action: AuditActionEnum
    field_name: Optional[str] = None
    old_value: Optional[str] = None
    new_value: Optional[str] = None
    performed_by: Optional[int] = None
    performed_at: datetime
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None

    class Config:
        from_attributes = True


# Price history model
class MenuItemPriceHistoryCreate(BaseModel):
    menu_item_id: int
    old_price: Decimal = Field(..., decimal_places=2)
    new_price: Decimal = Field(..., decimal_places=2)
    changed_by: Optional[int] = None


class MenuItemPriceHistory(BaseModel):
    price_history_id: int
    menu_item_id: int
    old_price: Decimal
    new_price: Decimal
    changed_at: datetime
    changed_by: Optional[int] = None

    class Config:
        from_attributes = True


# Order item modifier model
class OrderItemModifierCreate(BaseModel):
    order_item_id: int
    modifier_option_id: int
    modifier_name: str
    option_name: str
    price_delta: Decimal = Field(..., decimal_places=2)


class OrderItemModifier(BaseModel):
    order_item_modifier_id: int
    order_item_id: int
    modifier_option_id: int
    modifier_name: str
    option_name: str
    price_delta: Decimal

    class Config:
        from_attributes = True
