import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://dispatch_user:dispatch_pass@localhost:5432/dispatch_db",
    )
    ASYNC_DATABASE_URL: str = os.getenv(
        "ASYNC_DATABASE_URL",
        "postgresql://dispatch_user:dispatch_pass@localhost:5432/dispatch_db",
    )

    APP_USERNAME: str = os.getenv("APP_USERNAME", "admin")
    APP_PASSWORD: str = os.getenv("APP_PASSWORD", "admin123")
    JWT_SECRET: str = os.getenv("JWT_SECRET", "dev_secret_change_me")
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRE_MINUTES: int = int(os.getenv("JWT_EXPIRE_MINUTES", "720"))

    VIDEO_SOURCE_PATH: str = os.getenv("VIDEO_SOURCE_PATH", "./sample_video/test.mp4")
    YOLO_MODEL_PATH: str = os.getenv("YOLO_MODEL_PATH", "./models/best.pt")
    DOOR_LINE_Y_RATIO: float = 0.0  # unused, kept only so old .env files don't error
    CONF_THRESHOLD: float = float(os.getenv("CONF_THRESHOLD", "0.35"))
    CARTON_CLASS_NAME: str = os.getenv("CARTON_CLASS_NAME", "Carton_box")
    TRUCK_CLASS_NAME: str = os.getenv("TRUCK_CLASS_NAME", "Truck")
    PLATE_CLASS_NAME: str = os.getenv("PLATE_CLASS_NAME", "Number plate")
    OPEN_DOOR_CLASS_NAME: str = os.getenv("OPEN_DOOR_CLASS_NAME", "open_door")

    OUTPUT_DIR: str = os.getenv("OUTPUT_DIR", "./output")
    FORCE_REPROCESS: bool = os.getenv("FORCE_REPROCESS", "0") == "1"

    BACKEND_PORT: int = int(os.getenv("BACKEND_PORT", "8000"))


settings = Settings()
