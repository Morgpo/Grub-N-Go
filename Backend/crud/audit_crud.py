from typing import List, Optional
from datetime import datetime
from database import get_db_manager
from models import AuditLog, AuditLogCreate, AuditActionEnum


class AuditLogCRUD:
    """CRUD operations for audit logging (BR-005, BR-039)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_audit_log(self, audit_data: AuditLogCreate) -> int:
        """Create a new audit log entry."""
        query = """INSERT INTO AuditLog (table_name, record_id, action, field_name, old_value, new_value, 
                   performed_by, ip_address, user_agent) 
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            audit_data.table_name, audit_data.record_id, audit_data.action.value,
            audit_data.field_name, audit_data.old_value, audit_data.new_value,
            audit_data.performed_by, audit_data.ip_address, audit_data.user_agent
        ))
    
    def log_create(self, table_name: str, record_id: int, performed_by: Optional[int],
                   ip_address: Optional[str] = None, user_agent: Optional[str] = None) -> int:
        """Helper method to log a CREATE action."""
        query = """INSERT INTO AuditLog (table_name, record_id, action, performed_by, ip_address, user_agent) 
                   VALUES (%s, %s, 'CREATE', %s, %s, %s)"""
        return self.db.execute_update(query, (table_name, record_id, performed_by, ip_address, user_agent))
    
    def log_update(self, table_name: str, record_id: int, field_name: str, 
                   old_value: Optional[str], new_value: Optional[str],
                   performed_by: Optional[int], ip_address: Optional[str] = None,
                   user_agent: Optional[str] = None) -> int:
        """Helper method to log an UPDATE action."""
        query = """INSERT INTO AuditLog (table_name, record_id, action, field_name, old_value, new_value, 
                   performed_by, ip_address, user_agent) 
                   VALUES (%s, %s, 'UPDATE', %s, %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            table_name, record_id, field_name, old_value, new_value,
            performed_by, ip_address, user_agent
        ))
    
    def log_delete(self, table_name: str, record_id: int, performed_by: Optional[int],
                   ip_address: Optional[str] = None, user_agent: Optional[str] = None) -> int:
        """Helper method to log a DELETE action."""
        query = """INSERT INTO AuditLog (table_name, record_id, action, performed_by, ip_address, user_agent) 
                   VALUES (%s, %s, 'DELETE', %s, %s, %s)"""
        return self.db.execute_update(query, (table_name, record_id, performed_by, ip_address, user_agent))
    
    def log_status_change(self, table_name: str, record_id: int, old_status: str, 
                         new_status: str, performed_by: Optional[int],
                         ip_address: Optional[str] = None, user_agent: Optional[str] = None) -> int:
        """Helper method to log a STATUS_CHANGE action."""
        query = """INSERT INTO AuditLog (table_name, record_id, action, field_name, old_value, new_value, 
                   performed_by, ip_address, user_agent) 
                   VALUES (%s, %s, 'STATUS_CHANGE', 'status', %s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            table_name, record_id, old_status, new_status,
            performed_by, ip_address, user_agent
        ))
    
    def get_audit_logs_for_record(self, table_name: str, record_id: int) -> List[AuditLog]:
        """Get audit logs for a specific record."""
        query = "SELECT * FROM AuditLog WHERE table_name = %s AND record_id = %s ORDER BY performed_at DESC"
        results = self.db.execute_query(query, (table_name, record_id))
        return [AuditLog(**row) for row in results] if results else []
    
    def get_recent_audit_logs(self, limit: int = 100) -> List[dict]:
        """Get recent audit logs with performer email."""
        query = """
        SELECT al.*, a.email as performed_by_email
        FROM AuditLog al
        LEFT JOIN Account a ON al.performed_by = a.account_id
        ORDER BY al.performed_at DESC
        LIMIT %s
        """
        results = self.db.execute_query(query, (limit,))
        return results if results else []
    
    def get_audit_logs_by_action(self, action: AuditActionEnum, limit: int = 100) -> List[dict]:
        """Get audit logs by action type."""
        query = """
        SELECT al.*, a.email as performed_by_email
        FROM AuditLog al
        LEFT JOIN Account a ON al.performed_by = a.account_id
        WHERE al.action = %s
        ORDER BY al.performed_at DESC
        LIMIT %s
        """
        results = self.db.execute_query(query, (action.value, limit))
        return results if results else []
    
    def get_audit_logs_by_user(self, user_id: int, limit: int = 100) -> List[AuditLog]:
        """Get audit logs by user."""
        query = "SELECT * FROM AuditLog WHERE performed_by = %s ORDER BY performed_at DESC LIMIT %s"
        results = self.db.execute_query(query, (user_id, limit))
        return [AuditLog(**row) for row in results] if results else []
    
    def get_audit_logs_by_date_range(self, start_date: datetime, end_date: datetime) -> List[dict]:
        """Get audit logs within date range."""
        query = """
        SELECT al.*, a.email as performed_by_email
        FROM AuditLog al
        LEFT JOIN Account a ON al.performed_by = a.account_id
        WHERE al.performed_at BETWEEN %s AND %s
        ORDER BY al.performed_at DESC
        """
        results = self.db.execute_query(query, (start_date, end_date))
        return results if results else []
    
    def get_audit_logs_by_table(self, table_name: str, limit: int = 100) -> List[AuditLog]:
        """Get audit logs for a specific table."""
        query = "SELECT * FROM AuditLog WHERE table_name = %s ORDER BY performed_at DESC LIMIT %s"
        results = self.db.execute_query(query, (table_name, limit))
        return [AuditLog(**row) for row in results] if results else []
