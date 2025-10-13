from mysql.connector import pooling, Error
from contextlib import contextmanager
from typing import Dict, Any, List, Optional, Tuple
import logging
from config import settings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DatabaseManager:
    """Database connection and operations manager."""
    
    def __init__(self):
        self.pool = None
        self._initialize_pool()
    
    def _initialize_pool(self):
        """Initialize the connection pool."""
        try:
            pool_config = settings.mysql_config.copy()
            pool_config.update({
                "pool_name": "grubngo_pool",
                "pool_size": 10,
                "pool_reset_session": True
            })
            
            self.pool = pooling.MySQLConnectionPool(**pool_config)
            logger.info("Database connection pool initialized successfully")
            
        except Error as e:
            logger.error(f"Error initializing database pool: {e}")
            raise
    
    @contextmanager
    def get_connection(self):
        """Get a database connection from the pool."""
        connection = None
        try:
            connection = self.pool.get_connection()
            yield connection
        except Error as e:
            if connection:
                connection.rollback()
            logger.error(f"Database connection error: {e}")
            raise
        finally:
            if connection and connection.is_connected():
                connection.close()
    
    def execute_query(self, query: str, params: Optional[Tuple] = None, fetch_one: bool = False) -> Optional[List[Dict[str, Any]]]:
        """Execute a SELECT query and return results."""
        with self.get_connection() as connection:
            cursor = connection.cursor(dictionary=True)
            try:
                cursor.execute(query, params or ())
                
                if fetch_one:
                    result = cursor.fetchone()
                    return result
                else:
                    results = cursor.fetchall()
                    return results
                    
            except Error as e:
                logger.error(f"Query execution error: {e}")
                raise
            finally:
                cursor.close()
    
    def execute_update(self, query: str, params: Optional[Tuple] = None) -> int:
        """Execute an INSERT, UPDATE, or DELETE query and return affected rows."""
        with self.get_connection() as connection:
            cursor = connection.cursor()
            try:
                cursor.execute(query, params or ())
                connection.commit()
                
                # Return last inserted ID for INSERT queries, or affected rows for UPDATE/DELETE
                if query.strip().upper().startswith('INSERT'):
                    return cursor.lastrowid
                else:
                    return cursor.rowcount
                    
            except Error as e:
                connection.rollback()
                logger.error(f"Update execution error: {e}")
                raise
            finally:
                cursor.close()
    
    def execute_many(self, query: str, params_list: List[Tuple]) -> int:
        """Execute multiple queries with different parameters."""
        with self.get_connection() as connection:
            cursor = connection.cursor()
            try:
                cursor.executemany(query, params_list)
                connection.commit()
                return cursor.rowcount
                
            except Error as e:
                connection.rollback()
                logger.error(f"Batch execution error: {e}")
                raise
            finally:
                cursor.close()
    
    def test_connection(self) -> bool:
        """Test database connectivity."""
        try:
            with self.get_connection() as connection:
                cursor = connection.cursor()
                cursor.execute("SELECT 1")
                result = cursor.fetchone()
                cursor.close()
                return result[0] == 1
        except Error as e:
            logger.error(f"Connection test failed: {e}")
            return False


# Global database manager instance
db_manager = DatabaseManager()


def get_db_manager() -> DatabaseManager:
    """Get the database manager instance."""
    return db_manager
