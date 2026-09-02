import os
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from dotenv import load_dotenv
import sys

load_dotenv()
SECRET_ACTIVATION_CODE = os.getenv("SECRET_CODE")

if SECRET_ACTIVATION_CODE is None or len(SECRET_ACTIVATION_CODE) == 0:
    print("SECRET_CODE environment variable could not be found. Please specify one.")
    sys.exit(1)

os.makedirs("./data", exist_ok=True)
SQLALCHEMY_DATABASE_URL = "sqlite:///./data/maxwell.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
