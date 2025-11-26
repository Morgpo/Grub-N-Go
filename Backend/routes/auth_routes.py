from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional
from models import RoleEnum
from crud.account_crud import AccountCRUD, CustomerCRUD, RestaurantCRUD
import hashlib

router = APIRouter()

# Initialize CRUD instances
account_crud = AccountCRUD()
customer_crud = CustomerCRUD()
restaurant_crud = RestaurantCRUD()


class LoginRequest(BaseModel):
    email: str
    password: str


class RegisterRequest(BaseModel):
    email: str
    password: str
    role: str  # Will be validated as RoleEnum
    name: str
    phone: str
    # Restaurant-specific fields
    streetAddress: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postalCode: Optional[str] = None


class LoginResponse(BaseModel):
    account_id: int
    email: str
    role: str
    message: str


class RegisterResponse(BaseModel):
    account_id: int
    email: str
    role: str
    message: str


def _hash_password(password: str) -> str:
    """Hash password using SHA-256."""
    return hashlib.sha256(password.encode()).hexdigest()


@router.post("/login", response_model=LoginResponse)
async def login(credentials: LoginRequest):
    """Authenticate user and return account information."""
    try:
        # Get account by email
        account = account_crud.get_account_by_email(credentials.email)
        
        if not account:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Check if account is active
        if account.status != "ACTIVE":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account is not active"
            )
        
        # Verify password
        password_hash = _hash_password(credentials.password)
        if password_hash != account.password_hash:
            # Record failed login attempt
            account_crud.record_failed_login(account.account_id)
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Reset failed login attempts on successful login
        account_crud.reset_failed_logins(account.account_id)
        
        return LoginResponse(
            account_id=account.account_id,
            email=account.email,
            role=account.role,
            message="Login successful"
        )
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Login failed: {str(e)}"
        )


@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: RegisterRequest):
    """Register a new user (customer or restaurant)."""
    try:
        # Validate role
        role_str = user_data.role.upper()
        if role_str not in ["CUSTOMER", "RESTAURANT"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Role must be either CUSTOMER or RESTAURANT"
            )
        
        role_enum = RoleEnum(role_str)
        
        # Check if email already exists
        existing_account = account_crud.get_account_by_email(user_data.email)
        if existing_account:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        # Create account
        from models import AccountCreate
        account_data = AccountCreate(
            email=user_data.email,
            password=user_data.password,
            role=role_enum
        )
        account_id = account_crud.create_account(account_data)
        
        # Create customer or restaurant profile
        if role_enum == RoleEnum.CUSTOMER:
            from models import CustomerCreate
            customer_data = CustomerCreate(
                customer_name=user_data.name,
                phone=user_data.phone
            )
            customer_crud.create_customer(account_id, customer_data)
        
        elif role_enum == RoleEnum.RESTAURANT:
            from models import RestaurantCreate, OperatingStatusEnum
            # For restaurant registration with address info
            restaurant_data = RestaurantCreate(
                restaurant_name=user_data.name,
                contact_phone=user_data.phone,
                contact_email=user_data.email,
                operating_status=OperatingStatusEnum.TEMPORARILY_CLOSED,  # Default to temporarily closed until setup complete
                street_address=user_data.streetAddress or "",
                city=user_data.city or "",
                state=user_data.state or "",
                postal_code=user_data.postalCode or "",
                country="USA",
                latitude=None,
                longitude=None
            )
            restaurant_crud.create_restaurant(account_id, restaurant_data)
        
        return RegisterResponse(
            account_id=account_id,
            email=user_data.email,
            role=role_str,
            message="Registration successful"
        )
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Registration failed: {str(e)}"
        )
