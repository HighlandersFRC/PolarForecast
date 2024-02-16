import base64
import io
import json
import logging
from types import TracebackType
from typing import Annotated
import zipfile
from bson import ObjectId
from fastapi import Depends, FastAPI, File, HTTPException, UploadFile
from fastapi.responses import JSONResponse, StreamingResponse
import numpy
from pydantic import BaseModel
from pymongo import MongoClient
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware
import pymongo
from GeneticPolar import analyzeData
from config import EDIT_PASSWORD, TBA_POLLING_INTERVAL, TBA_API_KEY, TBA_API_URL, MONGO_CONNECTION, ALLOW_ORIGINS
import requests
from fastapi_utils.tasks import repeat_every

logging.basicConfig(format="%(levelname)s:%(message)s", level=logging.DEBUG)
logging.info("Initialized Logger")

YEAR = '2023'

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST", "GET", "PUT", "DELETE"],
    allow_headers=["*"],
)


client = MongoClient(MONGO_CONNECTION)
testDB = client["Database_Test"]

testCollection = testDB["Test"]
TBACollection = testDB["TBA"]
TBACollection.create_index([("key", pymongo.ASCENDING)], unique=True)
ScoutDataCollection = testDB["ScoutingData"]
ScoutingData2024Collection = testDB["Scouting2024Data"]
ScoutingData2024Collection.create_index([("event_code", pymongo.ASCENDING), ("team_number", pymongo.ASCENDING), ("scout_info.name", pymongo.ASCENDING)], unique=True)
CalculatedDataCollection = testDB["CalculatedData"]
PictureCollection = testDB["Pictures"]
PictureCollection.create_index([("key", pymongo.ASCENDING)], unique=False)
PitScoutingCollection = testDB["PitScouting"]
PitScoutingCollection.create_index( [("event_code", pymongo.ASCENDING), ("team_number", pymongo.ASCENDING)], unique=True)
PitStatusCollection = testDB["PitScoutingStatus"]
PitStatusCollection.create_index( [("event_code", pymongo.ASCENDING)], unique=True)
CalculatedDataCollection.create_index(
    [("event_code", pymongo.ASCENDING)], unique=True)
PredictionCollection = testDB["Predictions"]
PredictionCollection.create_index(
    [("event_code", pymongo.ASCENDING)], unique=True)
ETagCollection = testDB["ETag"]
ETagCollection.create_index([("key", pymongo.ASCENDING)], unique = True)

@app.on_event("startup")
def onStart():  
    headers = {"accept": "application/json", "X-TBA-Auth-Key": TBA_API_KEY}
    events = json.loads(requests.get(
        TBA_API_URL+"events/"+YEAR, headers=headers).text)
    for i in range(len(events)):
        event = events[i]
        eventCode = YEAR+event["event_code"]
        try:
            CalculatedDataCollection.insert_one({"event_code": (eventCode), "data": {}})
        except:
            pass
        try:
            ETagCollection.insert_one({"key": eventCode, "etag": ""})
        except:
            pass
    
@app.get("/{year}/{event}/{team}/stats")
def get_event_Team_Stats(year: int, event: str, team: str):
    foundTeam = False
    data = CalculatedDataCollection.find_one({
        "event_code": str(year) + event,
    })
    data.pop('_id', None)
    i = 0
    for doc in data["data"]:
        i += 1
        if not i == 1:
            if doc ["key"] == team:
                foundTeam = True
                break
    if not foundTeam:
        raise HTTPException(400, "No team key \""+team+"\" in "+str(year)+event)
    try :
        pitData = PitScoutingCollection.find_one({"event_code": str(year) + event, "team_number": int(team[3:])})
        for key in pitData["data"]:
            if not key == "_id":
                doc[key] = pitData["data"][key]
        return doc
    except Exception as e:
        return doc

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
    return {"data": retval}

@app.get("/{year}/{event}/predictions")
def get_Event_Predictions(year: int, event: str):
    try:
        data = PredictionCollection.find_one({"event_code": str(year)+event})
        data.pop("_id")
        return {"data": data["data"]}
    except:
        return {"data": []}

@app.get("/{year}/{event}/{match_key}/match_details")
def get_match_details(year: int, event: str, match_key: str):
    try:
        event_code = str(year)+event
        tbaMatch = TBACollection.find_one({"key": match_key})
        tbaMatch.pop("_id")
        eventPredictions = PredictionCollection.find_one({"event_code": event_code})
        matchPrediction = {}
        for prediction in eventPredictions["data"]:
            if prediction["key"] == match_key:
                matchPrediction = prediction
                break
        blueTeamStats = []
        for team in matchPrediction["blue_teams"]:
            blueTeamStats.append(get_event_Team_Stats(year, event, team))
        redTeamStats = []
        for team in matchPrediction["red_teams"]:
            redTeamStats.append(get_event_Team_Stats(year, event, team))
        retval = {
            "match": tbaMatch,
            "prediction": matchPrediction,
            "red_teams": redTeamStats,
            "blue_teams": blueTeamStats
        }
        return retval
    except:
        raise HTTPException(400)

@app.get("/{year}/{event}/{team}/predictions")
def get_team_match_predictions(year: int, event: str, team: str):
    event_code = str(year) + event
    data = PredictionCollection.find_one({"event_code": event_code})
    matches = []
    for alliance in ["red", "blue"]:
        for match in data["data"]:
            if match[alliance+"_teams"].__contains__(team):
                matches.append(match)
    return {"data": matches}
    
@app.get("/{year}/{event}/stat_description")
def get_Stat_Descriptions():
    file = open("StatDescription.json")
    description = json.load(file)
    file.close()
    return description

@app.get("/{year}/{event}/{team}/PitScouting")
def get_pit_scouting_data(year: int, event:str, team:str):
    try :
        data = PitScoutingCollection.find_one({"event_code": str(year)+ event, "team_number": int(team[3:])})
        try:
            data.pop("_id")
        except:
            pass
        return data
    except Exception as e:
        raise HTTPException(404, str(e))
    
@app.get("/{year}/{event}/PitScoutingStatus")
def get_pit_scouting_status(year: int, event:str):
    data = PitStatusCollection.find_one({"event_code": str(year)+ event})
    return data
    
@app.post("/PitScouting/")
def post_pit_scouting_data(data: dict):
    status = getStatus(data, PitStatusCollection.find_one({"event_code": data["event_code"]}))
    status.pop("_id")
    PitStatusCollection.find_one_and_replace({"event_code": data["event_code"]}, status)
    try :
        PitScoutingCollection.insert_one(data)
    except Exception as e:
        data.pop("_id")
        PitScoutingCollection.find_one_and_replace({"event_code": data["event_code"], "team_number": data["team_number"]}, data)
    return {"message": "added it to the DB"}

def getStatus(data: dict, originalStatus: dict):
    status = "Incomplete"
    found = False
    if data["data"]["drive_train"] != "":
        if data["data"]["favorite_color"] != "":
            status = "Done"
    for entry in originalStatus["data"]:
        if entry["key"] == str(data["team_number"]):
            found = True
            entry["pit_status"] = status
    if (not found):
        raise HTTPException(400, "No Such Team")
    else :
        return originalStatus
    
numRuns = 0
    
@app.post("/MatchScouting/")
def post_match_scouting(data: dict):
    eventCode = data["event_code"]
    matchNumber = data["match_number"]
    teamNumber = data["team_number"]
    scoutName = data["scout_info"]["name"]
    if scoutName == "":
        raise HTTPException(400, "Check Your Scout Name")
    match = TBACollection.find_one({"key": f"{eventCode}_qm{str(matchNumber)}"})
    if match is None:
        raise HTTPException(400, "Check Your Match Number")
    exists = False
    for i in range(2):
        if i == 0:
            allianceStr = "blue"
        else:
            allianceStr = "red"
        if (match["alliances"][allianceStr]["team_keys"].__contains__("frc"+str(data["team_number"]))):
            exists = True
    if not exists:
        eventStatus = PitStatusCollection.find_one({"event_code": eventCode})
        teamNumberExists = False
        for x in eventStatus["data"]:
            if x["key"] == str(teamNumber):
                teamNumberExists = True
                break
        if teamNumberExists:
            raise HTTPException(400, "Check Your Match And Team Number")
        else:
            raise HTTPException(400, "Check Your Team Number")
    data["team_number"] = str(data["team_number"])
    try:
        ScoutingData2024Collection.insert_one(data)
    except pymongo.errors.DuplicateKeyError as e:
        raise HTTPException(status_code=307, detail="Duplicate Entry")
    data.pop("_id")
    return data

@app.put("/MatchScouting/")
def update_match_scouting(data: dict):
    eventCode = data["event_code"]
    matchNumber = data["match_number"]
    teamNumber = data["team_number"]
    scoutName = data["scout_info"]["name"]
    if scoutName == "":
        raise HTTPException(400, "Check Your Scout Name")
    match = TBACollection.find_one({"key": f"{eventCode}_qm{str(matchNumber)}"})
    if match is None:
        raise HTTPException(400, "Check Your Match Number")
    exists = False
    for i in range(2):
        if i == 0:
            allianceStr = "blue"
        else:
            allianceStr = "red"
        if (match["alliances"][allianceStr]["team_keys"].__contains__("frc"+str(data["team_number"]))):
            exists = True
    if not exists:
        eventStatus = PitStatusCollection.find_one({"event_code": eventCode})
        teamNumberExists = False
        for x in eventStatus["data"]:
            if x["key"] == str(teamNumber):
                teamNumberExists = True
                break
        if teamNumberExists:
            raise HTTPException(400, "Check Your Match And Team Number")
        else:
            raise HTTPException(400, "Check Your Team Number")
    data["team_number"] = str(data["team_number"])
    ScoutingData2024Collection.find_one_and_replace({"event_code": data["event_code"], "team_number": data["team_number"], "scout_info.name": data["scout_info"]["name"]}, data)
    return data

def get_pictures(team: str, event: str, year: int):
    key = str(year) + event + "_" + team
    # Query the collection using the key
    pictures = PictureCollection.find({"key": key})
    
    if pictures:
        return pictures
    else:
        raise HTTPException(status_code=404, detail="Pictures not found")

@app.get("/{year}/{event}/{team}/getPictures", response_class=JSONResponse)
async def get_pit_scouting_pictures(team: str, event: str, year: int, pictures: list = Depends(get_pictures)):
    if not pictures:
        raise HTTPException(status_code=404, detail="Pictures not found")

    # Create a list of image data
    image_data = []
    for picture in pictures:
        content_type = picture["content_type"]
        file_content = picture["file"]
        id = str(picture["_id"])
        # Encode the binary data as base64
        file_content_base64 = base64.b64encode(file_content).decode("utf-8")
        image_data.append({"content_type": content_type, "file": file_content_base64, "_id": id})

    # Return the list of image data as a JSON response
    return image_data

@app.post("/{year}/{event}/{team}/pictures/")
def post_pit_scouting_pictures(data: UploadFile, team: str, event:str, year:int):
    status = PitStatusCollection.find_one({"event_code": str(year)+event})
    picStatus = "Done"
    found = False
    for entry in status["data"]:
        if entry["key"] == team[3:]:
            found = True
            entry["picture_status"] = picStatus
    if not found:
        raise HTTPException(400, detail="No such team")
    PitStatusCollection.find_one_and_replace({"event_code": str(year)+event}, status)
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
    PictureCollection.insert_one(file_data)
    return {"message": "File uploaded successfully"}

class ID(BaseModel):
    id: str

@app.delete("/{year}/{event}/{team}/{password}/DeletePictures/")
def delete_pit_scouting_pictures(objectid: ID, team: str, event:str, year:int, password: str):
    if password == EDIT_PASSWORD:
        delete_result = PictureCollection.delete_many({"_id": ObjectId(objectid.id)})
        pictures = PictureCollection.find({
            "key": str(year) + event + "_" + team,
        })
        status = get_pit_status(year, event)
        if len(list(pictures)) == 0:
            rows = status["data"]
            for row in rows:
                if row["key"] == team[3:]:
                    row["picture_status"] = "Not Started"
        PitStatusCollection.find_one_and_replace({"event_code": str(year)+event}, status)
        return {"message": delete_result.raw_result}
    else:
        raise HTTPException(400, "Incorrect Password")

@app.get("/{year}/{event}/pitStatus")
def get_pit_status(year: int, event: str):
    retval = PitStatusCollection.find_one({"event_code": str(year)+event})
    retval.pop("_id")
    return retval

@app.get("/{year}/{event}/{team}/ScoutEntries")
def get_scout_entries(team: str, event: str, year: int):
    retval = list(ScoutingData2024Collection.find({"event_code": str(year)+event, "team_number": team[3:]}))
    for entry in retval:
        entry.pop("_id")
    return retval

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
    TBAData = list(TBACollection.find({'event_key': event_code}))
    ScoutingData = list(ScoutDataCollection.find(
        {'event_code': event_code}))
    if TBAData is not None:
        calculatedData = analyzeData([TBAData, ScoutingData])
        data = calculatedData.to_dict("list")
        data = convertData(data, YEAR, event_code)
        metadata = {"last_modified": datetime.utcnow().timestamp(),"etag": None,"tba": False}
        try:
            CalculatedDataCollection.insert_one({"event_code": event_code, "data": data, "metadata": metadata})
        except Exception as e:
            try:
                CalculatedDataCollection.update_one({"event_code": event_code}, {'$set': {"data": data, "metadata": metadata}})
            except Exception as ex:
                pass
        updatePredictions(TBAData, data, event_code)

def updatePredictions(TBAData, calculatedData, event_code):
    matchPredictions = []
    for match in TBAData:
        matchPrediction = {
            "comp_level": match["comp_level"],
            "key": match["key"],
            "match_number": match["match_number"],
            "set_number": match["set_number"],
            "blue_teams": match["alliances"]["blue"]["team_keys"],
            "blue_score": 0,
            "blue_highCubes": 0,
            "blue_highCones": 0,
            "blue_midCubes": 0,
            "blue_midCones": 0,
            "blue_low": 0,
            "blue_links": 0,
            "blue_autoChargeStation": 0,
            "blue_endGame": 0,
            "blue_autoElements": 0,
            "blue_chargeStation": 0,
            "blue_actual_score": match["alliances"]["blue"]["score"],
            "red_teams": match["alliances"]["red"]["team_keys"],
            "red_score": 0,
            "red_highCubes": 0,
            "red_highCones": 0,
            "red_midCubes": 0,
            "red_midCones": 0,
            "red_low": 0,
            "red_links": 0,
            "red_autoChargeStation": 0,
            "red_endGame": 0,
            "red_autoElements": 0,
            "red_chargeStation": 0,
            "red_actual_score": match["alliances"]["red"]["score"],
            "blue_win_rp": 2 if match["alliances"]["red"]["score"] < match["alliances"]["blue"]["score"] else 1 if match["alliances"]["red"]["score"] == match["alliances"]["blue"]["score"] else 0,
            "red_win_rp": 2 if match["alliances"]["red"]["score"] > match["alliances"]["blue"]["score"] else 1 if match["alliances"]["red"]["score"] == match["alliances"]["blue"]["score"] else 0,
            "blue_charge_rp": 0,
            "red_charge_rp": 0,
            "blue_link_rp": 0,
            "red_link_rp": 0
        }
        for alliance in match["alliances"]:
            for team in match["alliances"][alliance]["team_keys"]:
                teamData = {}
                for i in range(1, len(calculatedData)):
                    if calculatedData[i]["key"] == team:
                        teamData = calculatedData[i]
                matchPrediction[f"{alliance}_score"] += teamData["OPR"]
                matchPrediction[f"{alliance}_highCubes"] += (teamData["teleopHighCubes"] + teamData["autoHighCubes"])
                matchPrediction[f"{alliance}_highCones"] += (teamData["teleopHighCones"] + teamData["autoHighCones"])
                matchPrediction[f"{alliance}_midCubes"] += (teamData["teleopMidCubes"] + teamData["autoMidCubes"])
                matchPrediction[f"{alliance}_midCones"] += (teamData["teleopMidCones"] + teamData["autoMidCones"])
                matchPrediction[f"{alliance}_low"] += (teamData["teleopLow"] + teamData["autoLow"])
                matchPrediction[f"{alliance}_links"] += teamData["linkPoints"]
                matchPrediction[f"{alliance}_autoChargeStation"] += teamData["autoChargeStation"]
                matchPrediction[f"{alliance}_chargeStation"] += teamData["endGameChargeStation"]
                matchPrediction[f"{alliance}_endGame"] += teamData["endgamePoints"]
                matchPrediction[f"{alliance}_autoElements"] += teamData["autoElementsScored"]
        matchPredictions.append(matchPrediction)
    try:
        PredictionCollection.insert_one({"event_code": event_code, "data": matchPredictions})
    except Exception as e:
        try:
            PredictionCollection.find_one_and_replace({"event_code": event_code}, {"event_code": YEAR+event_code, "data": matchPredictions})
        except Exception as ex:
            pass
                
@app.put("/{password}/Deactivate")
def deactivate_match_data(data: dict, password: str):
    if password == EDIT_PASSWORD:
        data["active"] = False
        ScoutingData2024Collection.find_one_and_replace({"event_code": data["event_code"], "team_number": data["team_number"], "scout_info.name": data["scout_info"]["name"]}, data)
        return data
    else:
        raise HTTPException(400, "Incorrect Password")

@app.put("/{password}/Activate")
def activate_match_data(data: dict, password: str):
    if password == EDIT_PASSWORD:
        data["active"] = True
        ScoutingData2024Collection.find_one_and_replace({"event_code": data["event_code"], "team_number": data["team_number"], "scout_info.name": data["scout_info"]["name"]}, data)
        return data
    else:
        raise HTTPException(400, "Incorrect Password")

@app.get("/")
def read_root():
    return {"polar": "forecast"}

@app.on_event("startup")
@repeat_every(seconds=float(TBA_POLLING_INTERVAL))
def update_database():
    logging.info("Starting Polar Forecast")
    try:
        global numRuns
        etags = list(ETagCollection.find({}))
        for event in etags:
            headers = {"accept": "application/json",
                    "X-TBA-Auth-Key": TBA_API_KEY, "If-None-Match": event["etag"]}
            r = requests.get(TBA_API_URL+"event/"+
                            event["key"]+"/matches", headers=headers)
            if r.status_code == 200:
                event["etag"] = r.headers["ETag"]
                ETagCollection.find_one_and_replace({"key": event["key"]}, event)
                responseJson = json.loads(r.text)
                teams = []
                for x in responseJson:
                    for alliance in x["alliances"]:
                        teams.extend(x["alliances"][alliance]["team_keys"])
                    try:
                        TBACollection.insert_one(x)
                    except:
                        pass
                teams = [{"key": x[3:], "pit_status": "Not Started", "picture_status": "Not Started"} for x in list(set(teams))]
                try:
                    PitStatusCollection.insert_one({"event_code": event["key"], "data": teams })
                except Exception as e:
                    pass
                try:
                    updateData(event["key"])
                except Exception as e:
                    pass
            print(event["key"])
        numRuns += 1
    except Exception as e:
        print(e)