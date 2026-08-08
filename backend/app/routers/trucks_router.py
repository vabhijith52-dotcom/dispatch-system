from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.auth import get_current_user
from app.models import Truck, CountEvent
from app.schemas import TruckCreate, TruckUpdate, TruckOut, CountEventOut

router = APIRouter(prefix="/api/trucks", tags=["trucks"])


def _to_out(truck: Truck) -> TruckOut:
    return TruckOut(
        id=truck.id,
        truck_code=truck.truck_code,
        plate_number=truck.plate_number,
        expected_count=truck.expected_count,
        loaded_count=truck.loaded_count,
        remaining=truck.remaining,
        status=truck.status,
        loading_started_at=truck.loading_started_at,
        created_at=truck.created_at,
        updated_at=truck.updated_at,
    )


@router.get("", response_model=List[TruckOut])
def list_trucks(db: Session = Depends(get_db), user=Depends(get_current_user)):
    trucks = db.query(Truck).order_by(Truck.created_at.desc()).all()
    return [_to_out(t) for t in trucks]


@router.post("", response_model=TruckOut)
def create_truck(
    payload: TruckCreate, db: Session = Depends(get_db), user=Depends(get_current_user)
):
    # This is how the dispatcher manually enters the expected count
    # before loading starts.
    existing = db.query(Truck).filter(Truck.truck_code == payload.truck_code).first()
    if existing:
        raise HTTPException(status_code=400, detail="Truck code already exists")

    truck = Truck(
        truck_code=payload.truck_code,
        expected_count=payload.expected_count,
        plate_number=payload.plate_number,
        status="waiting",
        loaded_count=0,
    )
    db.add(truck)
    db.commit()
    db.refresh(truck)
    return _to_out(truck)


@router.patch("/{truck_id}", response_model=TruckOut)
def update_truck(
    truck_id: int,
    payload: TruckUpdate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    truck = db.query(Truck).filter(Truck.id == truck_id).first()
    if not truck:
        raise HTTPException(status_code=404, detail="Truck not found")

    if payload.expected_count is not None:
        truck.expected_count = payload.expected_count
    if payload.plate_number is not None:
        truck.plate_number = payload.plate_number
    if payload.status is not None:
        truck.status = payload.status

    db.add(truck)
    db.commit()
    db.refresh(truck)
    return _to_out(truck)


@router.get("/{truck_id}/events", response_model=List[CountEventOut])
def truck_events(
    truck_id: int, db: Session = Depends(get_db), user=Depends(get_current_user)
):
    events = (
        db.query(CountEvent)
        .filter(CountEvent.truck_id == truck_id)
        .order_by(CountEvent.created_at.desc())
        .limit(200)
        .all()
    )
    return events
