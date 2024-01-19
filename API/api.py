import copy
import json
import logging
import traceback
from fastapi import FastAPI
from pydantic import BaseModel
from pymongo import MongoClient
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware
import pymongo
from GeneticPolar import analyzeData
from config import TBA_POLLING_INTERVAL, TBA_API_KEY, TBA_API_URL, MONGO_CONNECTION, ALLOW_ORIGINS
import requests
from fastapi_utils.tasks import repeat_every

logging.basicConfig(format="%(levelname)s:%(message)s", level=logging.DEBUG)
logging.info("Initialized Logger")

YEAR = '2023'

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOW_ORIGINS,
    allow_credentials=True,
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)


client = MongoClient(MONGO_CONNECTION)
testDB = client["Database_Test"]
testCollection = testDB["Test"]
TBACollection = testDB["TBA"]
TBACollection.create_index([("key", pymongo.ASCENDING)], unique=True)
ScoutDataCollection = testDB["ScoutingData"]
CalculatedDataCollection = testDB["CalculatedData"]
CalculatedDataCollection.create_index(
    [("event_code", pymongo.ASCENDING)], unique=True)

class Name(BaseModel):
    firstName: str
    lastName: str


def searchName(name):
    return testCollection.find({'name': name}, {'_id': 0})


def addNameEntry(myDict: dict):
    entry = testCollection.insert_one(myDict)


@app.post("/addScoutingData/")
async def add_Name(name: Name):
    nameStr = name.firstName+" "+name.lastName
    myDict = {
        "time": datetime.now(),
        "name": nameStr,
        "first_name": name.firstName,
        "last_name": name.lastName
    }
    entry = copy.deepcopy(myDict)
    addNameEntry(entry)
    return myDict


@app.on_event("startup")
def onStart():
    global etag
    global events
    headers = {"accept": "application/json", "X-TBA-Auth-Key": TBA_API_KEY}
    events = json.loads(requests.get(
        TBA_API_URL+"events/"+YEAR, headers=headers).text)
    for i in range(len(events)):
        etag.append('')
        
    for event in events:
        try:
            CalculatedDataCollection.insert_one({"event_code": YEAR+event["event_code"], "data": {}})
        except:
            pass

@app.get("/{year}/{event}/{team}/stats")
def eventTeamStats(year: int, event: str, team: str):
    data = {}
    data["historical"]: False
    data["key"]: team

events = []
etag = []
numRuns = 0


def updateData(event_code: str):
    print(YEAR+event_code)
    TBAData = list(TBACollection.find({'event_key': str(YEAR)+event_code}))
    
    ScoutingData = list(ScoutDataCollection.find(
        {'event_code': YEAR+event_code}))
    if not TBAData is None:
        print("found sources")
        calculatedData = analyzeData([TBAData, ScoutingData])
        print("updating data")
        try:
            CalculatedDataCollection.insert_one({"event_code": YEAR+event_code, "data": calculatedData.to_dict("list")})
        except Exception as e:
            try:
                CalculatedDataCollection.update_one({"event_code": YEAR+event_code}, {'$set': {"data": calculatedData.to_dict("list")}})
            except Exception as ex:
                print(f"Update error: {ex}")
                print("couldn't update")

@app.on_event("startup")
@repeat_every(seconds=TBA_POLLING_INTERVAL)
def update_database():
    logging.info("Starting Polar Forecast")
    try:
        print("new request")
        global etag
        global numRuns
        print(len(etag))
        i = 0
        for event in events:
            headers = {"accept": "application/json",
                    "X-TBA-Auth-Key": TBA_API_KEY, "If-None-Match": etag[i]}
            r = requests.get(TBA_API_URL+"event/"+YEAR +
                            event["event_code"]+"/matches", headers=headers)
            print(r.status_code)
            if r.status_code == 200:
                etag[i] = r.headers["ETag"]
                responseJson = json.loads(r.text)
                for x in responseJson:
                    try:
                        TBACollection.insert_one(x)
                    except:
                        pass
                try:
                    updateData(event["event_code"])
                except Exception as e:
                    print(e)
            i += 1
            print(i)
        numRuns += 1
    except Exception as e:
        print(e.with_traceback())

# @app.on_event("startup")
# @repeat_every(seconds=20)
# def code():
#     try:
#         updateData("code")
#     except Exception as e:
#         print(e)
#         traceback.print_exc()