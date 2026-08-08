from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TruckCreate(BaseModel):
    truck_code: str
    expected_count: int
    plate_number: Optional[str] = None


class TruckUpdate(BaseModel):
    expected_count: Optional[int] = None
    plate_number: Optional[str] = None
    status: Optional[str] = None


class TruckOut(BaseModel):
    id: int
    truck_code: str
    plate_number: Optional[str]
    expected_count: int
    loaded_count: int
    remaining: int
    status: str
    loading_started_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class CountEventOut(BaseModel):
    id: int
    truck_id: int
    event_type: str
    track_id: Optional[int]
    note: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
