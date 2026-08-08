from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.database import get_db
from app.auth import get_current_user
from app.models import Truck

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"])


@router.get("/summary")
def summary(db: Session = Depends(get_db), user=Depends(get_current_user)):
    total_trucks = db.query(func.count(Truck.id)).scalar()
    active = db.query(func.count(Truck.id)).filter(Truck.status == "loading").scalar()
    completed = db.query(func.count(Truck.id)).filter(Truck.status == "completed").scalar()
    waiting = db.query(func.count(Truck.id)).filter(Truck.status == "waiting").scalar()

    return {
        "total_trucks": total_trucks,
        "active": active,
        "completed": completed,
        "waiting": waiting,
    }
