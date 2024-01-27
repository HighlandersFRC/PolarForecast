import io
import json
import logging
from typing import Annotated
import zipfile
from fastapi import Depends, FastAPI, File, HTTPException, UploadFile
from fastapi.responses import StreamingResponse
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
ScoutingData2024Collection = testDB["Scouting2024Data"]
CalculatedDataCollection = testDB["CalculatedData"]
PictureCollection = testDB["Pictures"]
PictureCollection.create_index([("key", pymongo.ASCENDING)], unique=False)
CalculatedDataCollection.create_index(
    [("event_code", pymongo.ASCENDING)], unique=True)


class ScoutingPicture(BaseModel):
    file: Annotated[bytes, File()]
    year: int
    event: str
    team: str

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
def event_Team_Stats(year: int, event: str, team: str):
    print(team, str(year)+event)
    data = CalculatedDataCollection.find_one({
        "event_code": str(year) + event,
    })
    data.pop('_id', None)
    i = 0
    for doc in data["data"]["data"]:
        i += 1
        if not i == 1:
            if doc["key"] == team:
                return doc
    raise HTTPException(400, "No team key \""+team+"\" in "+str(year)+event)
    

@app.get("/{year}/{event}/{team}/matches")
def get_Team_Event_Matches(year: int, event:str, team:str):
    cursor = TBACollection.find({"event_key": str(year)+ event, "alliances.blue.team_keys": {'$elemMatch': {'$eq': team}}})
    data = list(cursor)
    cursor = TBACollection.find({"event_key": str(year)+ event, "alliances.red.team_keys": {'$elemMatch': {'$eq': team}}})
    data.extend(list(cursor))
    for doc in data:
        doc["_id"] = str(doc["_id"])
    return data

@app.get("/{year}/{event}/stats")
def get_Event_Stats(year:int, event:str):
    data = CalculatedDataCollection.find_one({"event_code": str(year)+ event})
    data.pop("_id")
    return data

@app.get("/events/{year}")
def get_Year_Events(year:int):
    global events
    return events

@app.get("/search_keys")
def get_Search_Keys():
    global events
    retval = []
    for event in events:
        retval.append({
            "key": str(event["year"])+str(event["event_code"]),
            "display": f"{event['year']} {event['name']} [{event['event_code']}]",
            "page": f"/data/event/{event['year']}/{event['event_code']}",
            "start": event["start_date"],
            "end": event["end_date"],
        })
    return retval

@app.get("/{year}/{event}/predictions")
def getEventPredictions():
    return {"data": []}

@app.get("/{year}/{event}/stat_description")
def get_Stat_Descriptions():
    return json.load(open("StatDescription.json"))

events = []
etag = []
numRuns = 0
@app.get("/{year}/{event}/{match_key}/match_details")
def get_Match_Details(match_key: str):
    matchData = TBACollection.find_one({"key": match_key})
    if matchData is not None:
        matchData.pop("_id")
    return matchData
    
@app.post("/MatchScouting/")
def post_match_scouting(data: dict):
    ScoutingData2024Collection.insert_one(data)
    data.pop("_id")
    return data

@app.post("/{year}/{event}/{team}/pictures/")
def post_pit_scouting_pictures(data: UploadFile, team: str, event:str, year:int):
    file_content = data.file.read()
    additional_fields = {
        "key": str(year) + event + "_" + team,
        "team": team,
        "eventCode": str(year) + event,
    }

    file_data = {
        "filename": data.filename,
        "content_type": data.content_type,
        "file": file_content,
        **additional_fields,
    }
    try :
        PictureCollection.insert_one(file_data)
    except :
        PictureCollection.find_one_and_replace({"key": additional_fields["key"]}, file_data)
    return {"message": "File uploaded successfully"}

from fastapi import FastAPI, HTTPException
from pymongo import MongoClient
from bson import ObjectId
from fastapi.responses import StreamingResponse
import io

app = FastAPI()

# Connect to MongoDB
client = MongoClient("mongodb://localhost:27017/")
db = client["your_database_name"]
picture_collection = db["your_collection_name"]

def get_pictures(team: str, event: str, year: int):
    key = str(year) + event + "_" + team

    # Query the collection using the key
    pictures = picture_collection.find({"key": key})

    if pictures:
        return pictures
    else:
        raise HTTPException(status_code=404, detail="Pictures not found")

@app.get("/{year}/{event}/{team}/getPictures")
async def get_pit_scouting_pictures(team: str, event: str, year: int, pictures: list = Depends(get_pictures)):
    if not pictures:
        raise HTTPException(status_code=404, detail="Pictures not found")

    # Create a list of image data
    image_data = []
    for picture in pictures:
        content_type = picture["content_type"]
        file_content = picture["file"]
        image_data.append({"content_type": content_type, "file": file_content.decode("utf-8")})

    # Return the list of image data as a JSON response
    return image_data

def convertData(calculatedData, year, event_code):
    keyStr = f"/year/{year}/event/{event_code}/teams/"
    keyList = [keyStr+"index"]
    for team in calculatedData["team_number"]:
        keyList.append(keyStr+team)
    retval0 = {"data":{"keys":keyList}}
    retvallist = [retval0]
    for team in calculatedData["team_number"]:
        data = {"historical": False, "key": "frc"+str(team)}
        idx = calculatedData["team_number"].index(team)
        data["mobility"] = calculatedData["mobility"][idx]
        data["autoChargeStation"] = calculatedData["auto_docking"][idx]
        data["endGameChargeStation"] = calculatedData["teleop_docking"][idx]
        data["rank"] = 0
        data["autoHighCubes"] = calculatedData["auto_hcu"][idx]
        data["autoHighCones"] = calculatedData["auto_hco"][idx]
        data["autoMidCones"] = calculatedData["auto_mco"][idx]
        data["autoMidCubes"] = calculatedData["auto_mcu"][idx]
        data["autoLow"] = calculatedData["auto_lp"][idx]
        data["teleopHighCubes"] = calculatedData["teleop_hcu"][idx]
        data["teleopHighCones"] = calculatedData["teleop_hco"][idx]
        data["teleopMidCones"] = calculatedData["teleop_mco"][idx]
        data["teleopMidCubes"] = calculatedData["teleop_mcu"][idx]
        data["teleopLow"] = calculatedData["teleop_lp"][idx]
        data["autoElementsScored"] = calculatedData["auto_pieces"][idx]
        data["teleopElementsScored"] = calculatedData["teleop_pieces"][idx]
        data["elementsScored"] = calculatedData["pieces_scored"][idx]
        data["links"] = calculatedData["links"][idx]
        data["linkPoints"] = calculatedData["link_points"][idx]
        data["autoPoints"] = calculatedData["auto_points"][idx]
        data["teleopPoints"] = calculatedData["teleop_points"][idx]
        data["endgamePoints"] = calculatedData["endgame_points"][idx]
        data["OPR"] = calculatedData["opr"][idx]
        data["simulatedRanking"] = 0
        data["expectedRanking"] = 0
        data["schedule"] = 0
        retvallist.append(data)
    return retvallist

def updateData(event_code: str):
    print(YEAR+event_code)
    TBAData = list(TBACollection.find({'event_key': str(YEAR)+event_code}))

    ScoutingData = list(ScoutDataCollection.find(
        {'event_code': YEAR+event_code}))
    if not TBAData is None:
        print("found sources")
        calculatedData = analyzeData([TBAData, ScoutingData])
        data = calculatedData.to_dict("list")
        data = convertData(data, YEAR, event_code)
        print("updating data")
        metadata = {"last_modified": datetime.utcnow().timestamp(),"etag": None,"tba": False}
        try:
            CalculatedDataCollection.insert_one({"event_code": YEAR+event_code, "data": data, "metadata": metadata})
        except Exception as e:
            try:
                CalculatedDataCollection.update_one({"event_code": YEAR+event_code}, {'$set': {"data": data, "metadata": metadata}})
            except Exception as ex:
                print(f"Update error: {ex}")
                print("couldn't update")

@app.on_event("startup")
@repeat_every(seconds=float(TBA_POLLING_INTERVAL))
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
