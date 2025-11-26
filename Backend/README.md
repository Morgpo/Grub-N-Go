# GrubnGo Backend API

A FastAPI backend for the GrubnGo food ordering platform that interfaces with a MySQL database.

## Setup

### Prerequisites

- Python 3.8+
- MySQL Server running on localhost
- Virtual environment (handled by setup script)

### === README INSTRUCTIONS ===
**Configure the database:**
   - Copy `.env.example` to `.env`
   - Update the database configuration in `.env`

### Installation

1. **Set up the virtual environment and install dependencies:**
   ```bash
   python3 setup/setup_venv.py
   ```

2. **Activate the virtual environment:**
   ```bash
   source ./.venv/bin/activate
   ```

3. **Configure the database:**
   - Copy `.env.example` to `.env`
   - Update the database configuration in `.env`
   ```bash
   cp .env.example .env
   ```

The API will be available at `http://localhost:8000`

## API Documentation

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

## Environment Variables

Create a `.env` file based on `.env.example`:

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_NAME=GrubnGo
DB_USER=root
DB_PASSWORD=your_password

# Application Configuration
SECRET_KEY=your-secret-key-here
DEBUG=True
```

## API Endpoints

### Accounts
- `POST /api/v1/accounts/` - Create account
- `GET /api/v1/accounts/{id}` - Get account by ID
- `GET /api/v1/accounts/email/{email}` - Get account by email
- `PUT /api/v1/accounts/{id}` - Update account
- `DELETE /api/v1/accounts/{id}` - Delete account

### Customers
- `POST /api/v1/customers/` - Create customer
- `GET /api/v1/customers/{id}` - Get customer by ID
- `GET /api/v1/customers/` - Get all customers
- `PUT /api/v1/customers/{id}` - Update customer

### Restaurants
- `POST /api/v1/restaurants/` - Create restaurant
- `GET /api/v1/restaurants/{id}` - Get restaurant by ID
- `GET /api/v1/restaurants/` - Get all restaurants
- `GET /api/v1/restaurants/open/` - Get open restaurants
- `PUT /api/v1/restaurants/{id}` - Update restaurant

### Menus
- `POST /api/v1/menus/` - Create menu
- `GET /api/v1/menus/{id}` - Get menu by ID
- `GET /api/v1/restaurants/{id}/menus/` - Get restaurant menus
- `PUT /api/v1/menus/{id}` - Update menu

### Menu Items
- `POST /api/v1/menu-items/` - Create menu item
- `GET /api/v1/menu-items/{id}` - Get menu item by ID
- `GET /api/v1/menus/{id}/items/` - Get menu items
- `PUT /api/v1/menu-items/{id}` - Update menu item

### Orders
- `POST /api/v1/orders/` - Create order
- `GET /api/v1/orders/{id}` - Get order by ID
- `GET /api/v1/customers/{id}/orders/` - Get customer orders
- `GET /api/v1/restaurants/{id}/orders/` - Get restaurant orders
- `PUT /api/v1/orders/{id}` - Update order

### Order Items
- `POST /api/v1/order-items/` - Create order item
- `GET /api/v1/order-items/{id}` - Get order item by ID
- `GET /api/v1/orders/{id}/items/` - Get order items
- `PUT /api/v1/order-items/{id}` - Update order item

### Analytics
- `GET /api/v1/restaurants/{id}/popular-items/` - Get popular menu items
- `GET /api/v1/customers/{id}/summary/` - Get customer order summary
- `GET /api/v1/restaurants/{id}/revenue-summary/` - Get restaurant revenue

## Project Structure

```
Backend/
├── .venv/                 # Virtual environment
├── setup/                 # Setup scripts and requirements
├── crud/                  # Database CRUD operations
├── routes/                # API route handlers
├── config.py              # Configuration management
├── database.py            # Database connection and utilities
├── models.py              # Pydantic models
├── main.py                # FastAPI application
├── .env.example           # Environment variables template
└── README.md              # This file
```

## Error Handling

The API includes comprehensive error handling:
- 400 Bad Request for invalid input
- 404 Not Found for missing resources
- 500 Internal Server Error for unexpected errors

## Database Schema

The API works with the MySQL schema defined in `../sql_reference/create_tables.sql` which includes:
- Account (base authentication)
- Customer (customer profiles)
- Restaurant (restaurant profiles)
- Menu (restaurant menus)
- MenuItem (menu items)
- Order (customer orders)
- OrderItem (items in orders)

## Development

To add new features:
1. Add new models to `models.py`
2. Create CRUD operations in `crud/`
3. Add API routes in `routes/`
4. Include routes in `main.py`

Run the development server with auto-reload:
```bash
python main.py
```