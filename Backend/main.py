from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging
from database import get_db_manager
from config import settings

# Import route modules
from routes import (
    account_routes, menu_routes, order_routes, utility_routes,
    address_routes, payment_method_routes, business_hours_routes,
    modifier_routes, refund_routes, auth_routes
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events."""
    # Startup
    logger.info("Starting GrubnGo API...")
    
    # Test database connection
    db_manager = get_db_manager()
    if db_manager.test_connection():
        logger.info("Database connection successful")
    else:
        logger.error("Database connection failed")
        raise Exception("Could not connect to database")
    
    yield
    
    # Shutdown
    logger.info("Shutting down GrubnGo API...")


# Create FastAPI app
app = FastAPI(
    title="GrubnGo API",
    description="A FastAPI backend for the GrubnGo food ordering platform",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include route modules
app.include_router(auth_routes.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(account_routes.router, prefix="/api/v1", tags=["Accounts"])
app.include_router(menu_routes.router, prefix="/api/v1", tags=["Menus"])
app.include_router(order_routes.router, prefix="/api/v1", tags=["Orders"])
app.include_router(utility_routes.router, prefix="/api/v1", tags=["Analytics"])

# New route modules for extended functionality
app.include_router(address_routes.router, prefix="/api/v1", tags=["Addresses"])
app.include_router(payment_method_routes.router, prefix="/api/v1", tags=["Payment Methods"])
app.include_router(business_hours_routes.router, prefix="/api/v1", tags=["Business Hours"])
app.include_router(modifier_routes.router, prefix="/api/v1", tags=["Modifiers"])
app.include_router(refund_routes.router, prefix="/api/v1", tags=["Refunds"])


@app.get("/", response_model=dict)
async def root():
    """Root endpoint."""
    return {
        "message": "Welcome to GrubnGo API",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc"
    }


@app.get("/health", response_model=dict)
async def health_check():
    """Health check endpoint."""
    try:
        db_manager = get_db_manager()
        db_healthy = db_manager.test_connection()
        
        return {
            "status": "healthy" if db_healthy else "unhealthy",
            "database": "connected" if db_healthy else "disconnected",
            "version": "1.0.0"
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Service unhealthy"
        )


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler."""
    logger.error(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"}
    )


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level="info"
    )
