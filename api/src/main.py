import fastapi
from fastapi.middleware.cors import CORSMiddleware
from fastapi import WebSocket, WebSocketDisconnect
from src.ws import manager
from src.database import engine, SessionLocal
from src.db_models import Base, Machine
from src.routers import auth, laundry

Base.metadata.create_all(bind=engine)

db = SessionLocal()
try:
    if not db.query(Machine).first():
        db.add_all([
            Machine(id="machine_washer_1", type="washer", status="available"),
            Machine(id="machine_dryer_1", type="dryer", status="available")
        ])
        db.commit()
finally:
    db.close()

app = fastapi.FastAPI(
    title="Maxwell API",
    description="Laundry Booking API",
    version="0.0.1"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # todo: tighten this for production
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(laundry.router)

@app.get("/ping")
async def pong():
    return {
        "status": "success",
        "message": "pong lol",
    }

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)
