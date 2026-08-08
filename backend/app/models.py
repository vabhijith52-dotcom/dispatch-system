from sqlalchemy import (
    Column, Integer, String, Float, DateTime, ForeignKey, Text
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)


class Truck(Base):
    __tablename__ = "trucks"

    id = Column(Integer, primary_key=True, index=True)
    truck_code = Column(String, unique=True, nullable=False)
    plate_number = Column(String, nullable=True)
    expected_count = Column(Integer, nullable=False, default=0)
    loaded_count = Column(Integer, nullable=False, default=0)
    status = Column(String, nullable=False, default="waiting")
    # waiting | loading | completed | mismatch
    loading_started_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    events = relationship(
        "CountEvent", back_populates="truck", cascade="all, delete-orphan"
    )

    @property
    def remaining(self):
        return max(self.expected_count - self.loaded_count, 0)


class CountEvent(Base):
    __tablename__ = "count_events"

    id = Column(Integer, primary_key=True, index=True)
    truck_id = Column(Integer, ForeignKey("trucks.id"), nullable=False)
    event_type = Column(String, nullable=False, default="carton_added")
    track_id = Column(Integer, nullable=True)
    note = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    truck = relationship("Truck", back_populates="events")
