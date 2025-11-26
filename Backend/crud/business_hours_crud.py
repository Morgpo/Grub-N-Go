from typing import List, Optional
from datetime import datetime, time
from database import get_db_manager
from models import (
    BusinessHours, BusinessHoursCreate, BusinessHoursUpdate,
    DayOfWeekEnum, PaginationParams
)


class BusinessHoursCRUD:
    """CRUD operations for restaurant business hours (BR-012)."""
    
    def __init__(self):
        self.db = get_db_manager()
    
    def create_business_hours(self, hours_data: BusinessHoursCreate) -> int:
        """Create business hours for a restaurant."""
        query = """INSERT INTO BusinessHours (restaurant_id, day_of_week, open_time, close_time, is_closed) 
                   VALUES (%s, %s, %s, %s, %s)"""
        return self.db.execute_update(query, (
            hours_data.restaurant_id, hours_data.day_of_week.value,
            hours_data.open_time, hours_data.close_time, hours_data.is_closed
        ))
    
    def create_standard_hours(self, restaurant_id: int, open_time: time, close_time: time, 
                            closed_days: List[DayOfWeekEnum] = None) -> List[int]:
        """Create standard business hours for all days of the week."""
        if closed_days is None:
            closed_days = []
        
        days = [DayOfWeekEnum.MONDAY, DayOfWeekEnum.TUESDAY, DayOfWeekEnum.WEDNESDAY, 
                DayOfWeekEnum.THURSDAY, DayOfWeekEnum.FRIDAY, DayOfWeekEnum.SATURDAY, DayOfWeekEnum.SUNDAY]
        
        created_ids = []
        for day in days:
            is_closed = day in closed_days
            hours_data = BusinessHoursCreate(
                restaurant_id=restaurant_id,
                day_of_week=day,
                open_time=open_time,
                close_time=close_time,
                is_closed=is_closed
            )
            created_ids.append(self.create_business_hours(hours_data))
        
        return created_ids
    
    def get_business_hours_by_id(self, business_hours_id: int) -> Optional[BusinessHours]:
        """Get business hours by ID."""
        query = "SELECT * FROM BusinessHours WHERE business_hours_id = %s"
        result = self.db.execute_query(query, (business_hours_id,), fetch_one=True)
        return BusinessHours(**result) if result else None
    
    def get_business_hours_by_restaurant(self, restaurant_id: int) -> List[BusinessHours]:
        """Get all business hours for a restaurant."""
        query = """SELECT * FROM BusinessHours 
                   WHERE restaurant_id = %s 
                   ORDER BY FIELD(day_of_week, 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY')"""
        results = self.db.execute_query(query, (restaurant_id,))
        return [BusinessHours(**row) for row in results] if results else []
    
    def get_business_hours_for_day(self, restaurant_id: int, day_of_week: DayOfWeekEnum) -> Optional[BusinessHours]:
        """Get business hours for specific day."""
        query = "SELECT * FROM BusinessHours WHERE restaurant_id = %s AND day_of_week = %s"
        result = self.db.execute_query(query, (restaurant_id, day_of_week.value), fetch_one=True)
        return BusinessHours(**result) if result else None
    
    def get_todays_hours(self, restaurant_id: int) -> Optional[BusinessHours]:
        """Get today's business hours."""
        query = """SELECT * FROM BusinessHours 
                   WHERE restaurant_id = %s 
                   AND day_of_week = UPPER(DATE_FORMAT(NOW(), '%%W'))"""
        result = self.db.execute_query(query, (restaurant_id,), fetch_one=True)
        return BusinessHours(**result) if result else None
    
    def check_if_open_now(self, restaurant_id: int) -> Optional[dict]:
        """Check if restaurant is open now."""
        query = """
        SELECT bh.*, 
               CASE 
                   WHEN bh.is_closed = 1 THEN 0
                   WHEN CURTIME() BETWEEN bh.open_time AND bh.close_time THEN 1
                   ELSE 0
               END AS is_currently_open
        FROM BusinessHours bh
        WHERE bh.restaurant_id = %s 
          AND bh.day_of_week = UPPER(DATE_FORMAT(NOW(), '%%W'))
        """
        result = self.db.execute_query(query, (restaurant_id,), fetch_one=True)
        return result
    
    def get_open_restaurants_now(self) -> List[dict]:
        """Get all restaurants that are currently open."""
        query = """
        SELECT DISTINCT r.restaurant_id, r.restaurant_name
        FROM Restaurant r
        JOIN BusinessHours bh ON r.restaurant_id = bh.restaurant_id
        WHERE bh.day_of_week = UPPER(DATE_FORMAT(NOW(), '%%W'))
          AND bh.is_closed = 0
          AND CURTIME() BETWEEN bh.open_time AND bh.close_time
          AND r.operating_status = 'OPEN'
        ORDER BY r.restaurant_name
        """
        results = self.db.execute_query(query)
        return results if results else []
    
    def update_business_hours(self, business_hours_id: int, hours_data: BusinessHoursUpdate) -> int:
        """Update business hours."""
        updates = []
        params = []
        
        if hours_data.open_time is not None:
            updates.append("open_time = %s")
            params.append(hours_data.open_time)
        
        if hours_data.close_time is not None:
            updates.append("close_time = %s")
            params.append(hours_data.close_time)
        
        if hours_data.is_closed is not None:
            updates.append("is_closed = %s")
            params.append(hours_data.is_closed)
        
        if not updates:
            return 0
        
        params.append(business_hours_id)
        query = f"UPDATE BusinessHours SET {', '.join(updates)} WHERE business_hours_id = %s"
        return self.db.execute_update(query, tuple(params))
    
    def update_hours_for_day(self, restaurant_id: int, day_of_week: DayOfWeekEnum, 
                           open_time: time, close_time: time, is_closed: bool = False) -> int:
        """Update business hours for a specific day."""
        query = """UPDATE BusinessHours 
                   SET open_time = %s, close_time = %s, is_closed = %s 
                   WHERE restaurant_id = %s AND day_of_week = %s"""
        return self.db.execute_update(query, (open_time, close_time, is_closed, restaurant_id, day_of_week.value))
    
    def toggle_closed_status(self, business_hours_id: int) -> int:
        """Toggle closed status for a day."""
        query = "UPDATE BusinessHours SET is_closed = NOT is_closed WHERE business_hours_id = %s"
        return self.db.execute_update(query, (business_hours_id,))
    
    def close_restaurant_today(self, restaurant_id: int) -> int:
        """Mark restaurant as closed for today."""
        query = """UPDATE BusinessHours 
                   SET is_closed = 1 
                   WHERE restaurant_id = %s 
                   AND day_of_week = UPPER(DATE_FORMAT(NOW(), '%%W'))"""
        return self.db.execute_update(query, (restaurant_id,))
    
    def open_restaurant_today(self, restaurant_id: int) -> int:
        """Mark restaurant as open for today."""
        query = """UPDATE BusinessHours 
                   SET is_closed = 0 
                   WHERE restaurant_id = %s 
                   AND day_of_week = UPPER(DATE_FORMAT(NOW(), '%%W'))"""
        return self.db.execute_update(query, (restaurant_id,))
    
    def delete_business_hours(self, business_hours_id: int) -> int:
        """Delete business hours."""
        query = "DELETE FROM BusinessHours WHERE business_hours_id = %s"
        return self.db.execute_update(query, (business_hours_id,))
    
    def delete_all_business_hours(self, restaurant_id: int) -> int:
        """Delete all business hours for a restaurant."""
        query = "DELETE FROM BusinessHours WHERE restaurant_id = %s"
        return self.db.execute_update(query, (restaurant_id,))
    
    def get_next_opening_time(self, restaurant_id: int) -> Optional[dict]:
        """Get the next time the restaurant will be open."""
        query = """
        SELECT bh.day_of_week, bh.open_time, bh.close_time
        FROM BusinessHours bh
        WHERE bh.restaurant_id = %s
          AND bh.is_closed = 0
          AND (
              (bh.day_of_week = UPPER(DATE_FORMAT(NOW(), '%%W')) AND bh.open_time > CURTIME())
              OR 
              (FIELD(bh.day_of_week, 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY') > 
               FIELD(UPPER(DATE_FORMAT(NOW(), '%%W')), 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'))
          )
        ORDER BY 
          CASE 
            WHEN bh.day_of_week = UPPER(DATE_FORMAT(NOW(), '%%W')) THEN 0
            ELSE FIELD(bh.day_of_week, 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY')
          END,
          bh.open_time
        LIMIT 1
        """
        result = self.db.execute_query(query, (restaurant_id,), fetch_one=True)
        return result
