from config import TBA_POLLING, TBA_POLLING_INTERVAL
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi_utils.tasks import repeat_every
from logging import info


app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:3000",
    "https://polarforecastfrc.com",
]


app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"Polar": "Forecast"}


@app.on_event("startup")
@repeat_every(seconds=TBA_POLLING_INTERVAL)
def update_database():
    info("Starting Polar Forecast")
        





