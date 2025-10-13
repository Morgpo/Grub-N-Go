import os
from typing import Optional
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Settings:
    """Application settings configuration."""
    
    # Database settings
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: int = int(os.getenv("DB_PORT", "3306"))
    DB_NAME: str = os.getenv("DB_NAME", "GrubnGo")
    DB_USER: str = os.getenv("DB_USER", "root")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "password")
    
    # Application settings
    SECRET_KEY: str = os.getenv("SECRET_KEY", "fallback-secret-key")
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    @property
    def database_url(self) -> str:
        """Get MySQL database URL."""
        return f"mysql+mysql-connector://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
    
    @property
    def mysql_config(self) -> dict:
        """Get MySQL connector configuration."""
        return {
            "host": self.DB_HOST,
            "port": self.DB_PORT,
            "database": self.DB_NAME,
            "user": self.DB_USER,
            "password": self.DB_PASSWORD,
            "autocommit": False,
            "raise_on_warnings": True
        }

# Global settings instance
settings = Settings()
