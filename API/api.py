import base64
import io
import json
import logging
import math
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

YEAR = '2024'

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

ScoutingData2024Collection = testDB["Scouting2024Data"]
ScoutingData2024Collection.create_index([("event_code", pymongo.ASCENDING), (
    "team_number", pymongo.ASCENDING), ("scout_info.name", pymongo.ASCENDING), ("match_number", pymongo.ASCENDING)], unique=True)

PictureCollection = testDB["Pictures"]
PictureCollection.create_index([("key", pymongo.ASCENDING)], unique=False)

PitScoutingCollection = testDB["PitScouting"]
PitScoutingCollection.create_index(
    [("event_code", pymongo.ASCENDING), ("team_number", pymongo.ASCENDING)], unique=True)

PitStatusCollection = testDB["PitScoutingStatus"]
PitStatusCollection.create_index(
    [("event_code", pymongo.ASCENDING)], unique=True)

CalculatedDataCollection = testDB["CalculatedData"]
CalculatedDataCollection.create_index(
    [("event_code", pymongo.ASCENDING)], unique=True)

PredictionCollection = testDB["Predictions"]
PredictionCollection.create_index(
    [("event_code", pymongo.ASCENDING)], unique=True)

ETagCollection = testDB["ETag"]
ETagCollection.create_index([("key", pymongo.ASCENDING)], unique=True)

FollowUpCollection = testDB["FollowUp"]
FollowUpCollection.create_index(
    [("event_code", pymongo.ASCENDING), ("team_key", pymongo.ASCENDING)], unique=True)


def flatten_dict(dd, separator="_", prefix=""):
    return (
        {
            prefix + separator + k if prefix else k: v
            for kk, vv in dd.items()
            for k, v in flatten_dict(vv, separator, kk).items()
        }
        if isinstance(dd, dict)
        else {prefix: dd}
    )


@app.on_event("startup")
def onStart():
    headers = {"accept": "application/json", "X-TBA-Auth-Key": TBA_API_KEY}
    events = json.loads(requests.get(
        TBA_API_URL+"events/"+YEAR, headers=headers).text)
    for i in range(len(events)):
        event = events[i]
        eventCode = YEAR+event["event_code"]
        try:
            CalculatedDataCollection.insert_one(
                {"event_code": (eventCode), "data": {}})
        except:
            pass
        try:
            ETagCollection.insert_one(
                {"key": eventCode, "etag": "", "teamEtag": "", "event": event, "up_to_date": False})
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
            if doc["key"] == team:
                foundTeam = True
                break
    if not foundTeam:
        raise HTTPException(400, "No team key '"+team +
                            "' in "+str(year)+event)
    return doc


@app.get("/{year}/{event}/{team}/matches")
def get_Team_Event_Matches(year: int, event: str, team: str):
    cursor = TBACollection.find({"event_key": str(
        year) + event, "alliances.blue.team_keys": {'$elemMatch': {'$eq': team}}})
    data = list(cursor)
    cursor = TBACollection.find({"event_key": str(
        year) + event, "alliances.red.team_keys": {'$elemMatch': {'$eq': team}}})
    data.extend(list(cursor))
    for doc in data:
        doc["_id"] = str(doc["_id"])
    return data


@app.get("/{year}/{event}/stats")
def get_Event_Stats(year: int, event: str):
    data = CalculatedDataCollection.find_one({"event_code": str(year) + event})
    for i, team in enumerate(data["data"][1:]):
        if math.isnan(team["death_rate"]):
            team["death_rate"] = 0
        data["data"][i+1] = team
    data.pop("_id")
    return data


@app.get("/events/{year}")
def get_Year_Events(year: int):
    events = ETagCollection.find({})
    events = [event["event"] for event in events]
    return events


@app.get("/search_keys")
def get_Search_Keys():
    events = ETagCollection.find({})
    events = [event["event"] for event in events]
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
        matchPrediction = {}
        blueTeamStats = []
        redTeamStats = []
        try:
            eventPredictions = PredictionCollection.find_one(
                {"event_code": event_code})
            for prediction in eventPredictions["data"]:
                if prediction["key"] == match_key:
                    matchPrediction = prediction
                    break
            for team in matchPrediction["blue_teams"]:
                blueTeamStats.append(get_event_Team_Stats(year, event, team))
            for team in matchPrediction["red_teams"]:
                redTeamStats.append(get_event_Team_Stats(year, event, team))
        except:
            pass
        retval = {
            "match": tbaMatch,
            "prediction": matchPrediction,
            "red_teams": redTeamStats,
            "blue_teams": blueTeamStats
        }
        # print(retval)
        return retval
    except Exception as e:
        raise HTTPException(400, str(e))


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
def get_pit_scouting_data(year: int, event: str, team: str):
    try:
        data = PitScoutingCollection.find_one(
            {"event_code": str(year) + event, "team_number": int(team[3:])})
        try:
            data.pop("_id")
        except:
            pass
        return data
    except Exception as e:
        raise HTTPException(404, str(e))


@app.get("/{year}/{event}/PitScoutingStatus")
def get_pit_scouting_status(year: int, event: str):
    data = PitStatusCollection.find_one({"event_code": str(year) + event})
    return data


@app.post("/PitScouting/")
def post_pit_scouting_data(data: dict):
    status = getStatus(data, PitStatusCollection.find_one(
        {"event_code": data["event_code"]}))
    status.pop("_id")
    PitStatusCollection.find_one_and_replace(
        {"event_code": data["event_code"]}, status)
    eventData = CalculatedDataCollection.find_one(
        {"event_code": data["event_code"]})
    teams = ETagCollection.find_one(
        {"key": data["event_code"]})["teams"]
    teams = [team[3:] for team in teams]
    i = 0
    team = str(data["team_number"])
    print(teams, team)
    if not teams.__contains__(team):
        raise HTTPException(400, "No team key '"+str(data["team_number"]) +
                            "' in "+data["event_code"])
    for doc in eventData["data"][1:]:
        # print(doc)
        i += 1
        if doc["key"] == f"frc{team}":
            for key in data["data"]:
                if not key == "_id":
                    doc[key] = data["data"][key]
            break
    CalculatedDataCollection.find_one_and_replace(
        {"event_code": data["event_code"]}, eventData)
    try:
        PitScoutingCollection.insert_one(data)
    except Exception as e:
        data.pop("_id")
        PitScoutingCollection.find_one_and_replace(
            {"event_code": data["event_code"], "team_number": data["team_number"]}, data)
    return {"message": "added it to the DB"}


def getStatus(data: dict, originalStatus: dict):
    status = "Incomplete"
    found = False
    if data["data"]["drive_train"] != "":
        if data["data"]["favorite_color"] != "":
            status = "Done"
    # print(originalStatus)
    for entry in originalStatus["data"]:
        if entry["key"] == str(data["team_number"]):
            print(entry["key"], data["team_number"])
            found = True
            entry["pit_status"] = status
    if (not found):
        raise HTTPException(400, "No Such Team")
    else:
        return originalStatus


numRuns = 0


@app.post("/MatchScouting/")
def post_match_scouting(data: dict):
    eventCode = data["event_code"]
    event = ETagCollection.find_one({"key": eventCode})
    event["up_to_date"] = False
    ETagCollection.find_one_and_replace({"key": eventCode}, event)
    matchNumber = data["match_number"]
    teamNumber = data["team_number"]
    scoutName = data["scout_info"]["name"]
    year = data["event_code"][-4:]
    eventKey = data["event_code"][:-4]
    if scoutName == "":
        raise HTTPException(400, "Check Your Scout Name")
    match = TBACollection.find_one(
        {"key": f"{eventCode}_qm{str(matchNumber)}"})
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
    status = PitStatusCollection.find_one({"event_code": data["event_code"]})
    if data["data"]["miscellaneous"]["died"]:
        for team in status["data"]:
            if team["key"] == data["team_number"]:
                if team["follow_up_status"] == "Done":
                    team["follow_up_status"] = "Incomplete"
                break
    try:
        ScoutingData2024Collection.insert_one(data)
    except pymongo.errors.DuplicateKeyError as e:
        raise HTTPException(status_code=307, detail="Duplicate Entry")
    if data["data"]["miscellaneous"]["died"] == 1:
        PitStatusCollection.find_one_and_replace(
            {"event_code": data["event_code"]}, status)
    data.pop("_id")
    return data


@app.put("/MatchScouting/")
def update_match_scouting(data: dict):
    eventCode = data["event_code"]
    matchNumber = data["match_number"]
    teamNumber = data["team_number"]
    scoutName = data["scout_info"]["name"]
    year = data["event_code"][-4:]
    eventKey = data["event_code"][:-4]
    event = ETagCollection.find_one({"key": eventCode})
    event["up_to_date"] = False
    ETagCollection.find_one_and_replace({"key": eventCode}, event)
    if scoutName == "":
        raise HTTPException(400, "Check Your Scout Name")
    match = TBACollection.find_one(
        {"key": f"{eventCode}_qm{str(matchNumber)}"})
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
    ScoutingData2024Collection.find_one_and_replace(
        {"event_code": data["event_code"], "team_number": data["team_number"], "scout_info.name": data["scout_info"]["name"]}, data)
    # print(data["data"]["miscellaneous"]["died"])
    if data["data"]["miscellaneous"]["died"] == 1:
        status = PitStatusCollection.find_one(
            {"event_code": data["event_code"]})
        for team in status["data"]:
            if team["key"] == data["team_number"]:
                if team["follow_up_status"] == "Done":
                    team["follow_up_status"] = "Incomplete"
                break
        PitStatusCollection.find_one_and_replace(
            {"event_code": data["event_code"]}, status)
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
        image_data.append({"content_type": content_type,
                          "file": file_content_base64, "_id": id})

    # Return the list of image data as a JSON response
    return image_data


@app.post("/{year}/{event}/{team}/pictures/")
def post_pit_scouting_pictures(data: UploadFile, team: str, event: str, year: int):
    status = PitStatusCollection.find_one({"event_code": str(year)+event})
    picStatus = "Done"
    found = False
    for entry in status["data"]:
        if entry["key"] == team[3:]:
            found = True
            entry["picture_status"] = picStatus
    if not found:
        raise HTTPException(400, detail="No such team")
    PitStatusCollection.find_one_and_replace(
        {"event_code": str(year)+event}, status)
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
def delete_pit_scouting_pictures(objectid: ID, team: str, event: str, year: int, password: str):
    if password == EDIT_PASSWORD:
        delete_result = PictureCollection.delete_many(
            {"_id": ObjectId(objectid.id)})
        pictures = PictureCollection.find({
            "key": str(year) + event + "_" + team,
        })
        status = get_pit_status(year, event)
        if len(list(pictures)) == 0:
            rows = status["data"]
            for row in rows:
                if row["key"] == team[3:]:
                    row["picture_status"] = "Not Started"
        PitStatusCollection.find_one_and_replace(
            {"event_code": str(year)+event}, status)
        return {"message": delete_result.raw_result}
    else:
        raise HTTPException(400, "Incorrect Password")


@app.get("/{year}/{event}/pitStatus")
def get_pit_status(year: int, event: str):
    retval = PitStatusCollection.find_one({"event_code": str(year)+event})
    retval.pop("_id")
    return retval


@app.get("/{year}/{event}/{team}/ScoutEntries")
def get_scout_team_entries(team: str, event: str, year: int):
    retval = list(ScoutingData2024Collection.find(
        {"event_code": str(year)+event, "team_number": team[3:]}))
    for entry in retval:
        entry.pop("_id")
    return retval


@app.get("/{year}/{event}/ScoutEntries")
def get_scout_event_entries(event: str, year: int):
    retval = list(ScoutingData2024Collection.find(
        {"event_code": str(year)+event}))
    for entry in retval:
        entry.pop("_id")
    return retval


@app.get("/{year}/{event}/ScoutingData")
def get_event_autos(year: int, event: str):
    autos = list(ScoutingData2024Collection.find(
        {"event_code": str(year)+event}))
    for auto in autos:
        auto.pop("_id")
    return autos


@app.post("/{year}/{event}/{team}/FollowUp")
def post_team_follow_up(data: list, year: int, event: str, team: str):
    if not len(data) == 0:
        for idx, death in enumerate(data):
            match_number = int(death["match_number"])
            teamInMatch = False
            teamDied = False
            matchScoutingEntries = get_scout_team_entries(team, event, year)
            # print(match_number)
            for entry in matchScoutingEntries:
                # print(entry["match_number"])
                if entry["match_number"] == match_number:
                    teamInMatch = True
                if entry['data']["miscellaneous"]["died"] == 1:
                    teamDied = True
            if not teamInMatch:
                raise HTTPException(
                    400, "Check Match Number for Death #"+str(idx+1))
            if not teamDied:
                raise HTTPException(400, "This Team Never Died in Match #" +
                                    str(int(match_number)+1)+" in Death #"+str(idx+1))
        sum = 0
        for death in data:
            if type(death["severity"]) == int:
                sum += death["severity"]
        average = sum/len(data)
        DBEntry = {"event_code": str(year)+event, "team_key": team,
                   "team_number": team[3:], "deaths": data, "average": average, "total": sum}
        try:
            FollowUpCollection.insert_one(DBEntry)
        except:
            FollowUpCollection.find_one_and_delete(
                {"event_code": str(year)+event, "team_key": team})
            FollowUpCollection.insert_one(DBEntry)
        newStatus = "Done"
        for death in data:
            if death["severity"] == '' or death["death_reason"] == '':
                newStatus = "Incomplete"
        statuses = PitStatusCollection.find_one(
            {"event_code": str(year)+event})
        for status in statuses["data"]:
            if status["key"] == team[3:]:
                status["follow_up_status"] = newStatus
        PitStatusCollection.find_one_and_delete(
            {"event_code": str(year)+event})
        PitStatusCollection.insert_one(statuses)
        DBEntry.pop("_id")
        return DBEntry
    else:
        raise HTTPException(400, "No Deaths Reported")


@app.get("/{year}/{event}/{team}/FollowUp")
def get_team_follow_up(team: str, event: str, year: int):
    data = FollowUpCollection.find_one(
        {"event_code": str(year)+event, "team_key": team})
    if data is not None:
        data.pop("_id")
        scoutEntries = get_scout_team_entries(team, event, year)
        deathEntries = []
        for entry in scoutEntries:
            if entry["data"]["miscellaneous"]["died"]:
                deathEntries.append(entry)
        for entry in deathEntries:
            notRecorded = True
            for death in data["deaths"]:
                if death["match_number"] == entry["match_number"]:
                    notRecorded = False
            if notRecorded:
                data["deaths"].append({"match_number": entry["match_number"],
                                       "death_reason": "",
                                       "severity": '', })
        return data
    else:
        scoutEntries = get_scout_team_entries(team, event, year)
        deathEntries = []
        for entry in scoutEntries:
            if entry["data"]["miscellaneous"]["died"]:
                deathEntries.append(entry)
        if len(deathEntries) == 0:
            return {"event_code": str(year)+event, "team_key": team, "team_number": team[3:], "deaths": [], "average": 0, "total": 0}
        else:
            deaths = []
            for entry in deathEntries:
                if not deaths.__contains__({"match_number": entry["match_number"],
                                            "death_reason": "",
                                            "severity": '', }):
                    deaths.append({"match_number": entry["match_number"],
                                   "death_reason": "",
                                   "severity": '', })
            return {"event_code": str(year)+event, "team_key": team, "team_number": team[3:], "deaths": deaths, "average": 0, "total": 0}


def convertData(calculatedData, year, event_code):
    keyStr = f"/year/{year}/event/{event_code}/teams/"
    keyList = [keyStr+"index"]
    try:
        rankings = ETagCollection.find_one({"key": event_code})["rankings"]
    except:
        rankings = [{"team_key": "frc"+str(team), "rank": 0} for team in calculatedData["team_number"]]
    for team in calculatedData["team_number"]:
        keyList.append(keyStr+team)
    retval0 = {"data": {"keys": keyList}}
    retvallist = [retval0]
    for team in calculatedData["team_number"]:
        data = {"historical": False, "key": "frc"+str(team), "rank": 0}
        for item in rankings:
            if item["team_key"] == data["key"]:
                data["rank"] = item["rank"]
                break
        idx = calculatedData["team_number"].index(team)
        for key in calculatedData:
            data[key] = calculatedData[key][idx]
        retvallist.append(data)
    return retvallist


def updateData(event_code: str):
    # print(event_code)
    TBAData = list(TBACollection.find({'event_key': event_code}))
    ScoutingData = list(ScoutingData2024Collection.find(
        {'event_code': event_code, 'active': True}))
    scouts = []
    numEntries = []
    try:
        for entry in ScoutingData:
            entry["scout_info"]["name"] = entry["scout_info"]["name"].replace(
                " ", "")
            if not scouts.__contains__(entry["scout_info"]["name"]):
                scouts.append(entry["scout_info"]["name"])
                numEntries.append(0)
            numEntries[scouts.index(entry["scout_info"]["name"])] += 1
    except Exception as e:
        print(e)
    # if TBAData is not None:
    try:
        calculatedData, ratings = analyzeData([TBAData, ScoutingData])
        data = calculatedData.to_dict("list")
        data = convertData(data, YEAR, event_code)
    except Exception as e:
        print(e)
        ratings = {"scouts": [], "trustRatings": []}
        keyStr = f"/year/{YEAR}/event/{event_code}/teams/"
        keyList = [keyStr+"index"]
        etagData = ETagCollection.find_one({"key": event_code})
        # print(etagData)
        teams = etagData["teams"]
        for team in teams:
            keyList.append(keyStr+team[3:])
        retval0 = {"data": {"keys": keyList}}
        data = [retval0]
        data.extend([{"historical": False, "key": team, "rank": 0, "team_number": team[3:], "match_count": 0, "OPR": 0, "endgame_points": 0, "teleop_points": 0, "auto_points": 0, "notes": 0, "teleop_notes": 0, "harmony_points": 0, "speaker_total": 0, "amp_total": 0, "trap_points": 0,
                        "trap": 0, "auto_notes": 0, "climbing_points": 0, "climbing": 0, "mobility": 0, "death_rate": 0, "parking": 0, "auto_speaker": 0, "auto_amp": 0, "pass": 0,"teleop_speaker": 0, "teleop_amped_speaker": 0, "teleop_amp": 0, "harmony": 0, "mic": 0, "coopertition": 0, "simulated_rp": 0, "simulated_rank": 0} for team in teams])
    try:
        data = updatePredictions(TBAData, data, event_code)
    except Exception as e:
        print(e)
        pass
    metadata = {"last_modified": datetime.utcnow().timestamp(),
                "etag": None, "tba": False}
    try:
        # print("manufacturing scout rankings")
        ratings = {
            "scouts": ratings["scouts"], "trustRatings": ratings["trustRatings"], "entries": []}
        ratings["entries"] = list(numpy.zeros(len(ratings["scouts"])))
        for idx, scout in enumerate(ratings["scouts"]):
            ratings["entries"][idx] = numEntries[scouts.index(
                scout["name"])]
    except Exception as e:
        print(e)
    try:
        prevData = CalculatedDataCollection.find_one(
            {"event_code": event_code})["data"][1:]
        for idx, team in enumerate(prevData):
                for newTeam in data[1:]:
                    if team["key"] == newTeam["key"]:
                        for key in team:
                            if not newTeam.__contains__(key):
                                newTeam[key] = team[key]
                                # print(team[key])
                        break
    except Exception as e:
        print(e)
    try:
        # print("Inserting data")
        CalculatedDataCollection.insert_one(
            {"event_code": event_code, "data": data, "metadata": metadata, "scout_ratings": ratings})
    except Exception as e:
        # print(e)
        try:
            result = CalculatedDataCollection.update_one(
                {"event_code": event_code}, {'$set': {"data": data, "metadata": metadata, "scout_ratings": ratings}})
        except Exception as ex:
            print(ex)
            pass
    # TODO make it work without TBA Data and only scouting data
    # if TBAData == [] and (ScoutingData is not [] or ScoutingData is not None):
    #     teams = []
    #     calculatedData = []
    #     for entry in ScoutingData:
    #         if not teams.__contains__(entry["team_number"]):
    #             teams.append(entry["team_number"])
    #     for team in teams:
    #         teamEntries = []
    #         for entry in ScoutingData:
    #             if entry["team_number"] == team:
    #                 teamEntries.append(entry)
    #         cumulativeData = {
    #             "historical": False,
    #             "key": "frc"+str(team),
    #             "team_number": str(team),
    #         }
    #         for entry in teamEntries:
    #             if entry["data"].__contains__("miscellaneous"):
    #                 entry["data"]["died"] = entry["data"]["miscellaneous"]["died"]
    #                 entry.pop("miscellaneous")
    #             if entry["data"].__contains__("selecte"):
    #                 entry["data"].pop("miscellaneous")
    #             flattenedData = flatten_dict(entry["data"])
    #             for key in flattenedData:
    #                 if not cumulativeData.__contains__(key):
    #                     cumulativeData[key] = 0
    #                 cumulativeData[key] += flattenedData[key]

    # pass


def updatePredictions(TBAData, calculatedData, event_code):
    matchPredictions = []
    for match in TBAData:
        if match["score_breakdown"] is not None:
            matchPrediction = {
                "comp_level": match["comp_level"],
                "key": match["key"],
                "match_number": match["match_number"],
                "set_number": match["set_number"],
                "blue_teams": match["alliances"]["blue"]["team_keys"],
                "blue_score": 0,
                "blue_climbing": 0,
                "blue_auto_points": 0,
                "blue_teleop_points": 0,
                "blue_endgame_points": 0,
                "blue_coopertition": 0,
                "blue_actual_score": match["score_breakdown"]["blue"]["totalPoints"],
                "blue_notes": 0,
                "red_teams": match["alliances"]["red"]["team_keys"],
                "red_score": 0,
                "red_climbing": 0,
                "red_auto_points": 0,
                "red_teleop_points": 0,
                "red_endgame_points": 0,
                "red_coopertition": 0,
                "red_notes": 0,
                "red_actual_score": match["score_breakdown"]["red"]["totalPoints"],
                "predicted": False,
            }
        else:
            matchPrediction = {
                "comp_level": match["comp_level"],
                "key": match["key"],
                "match_number": match["match_number"],
                "set_number": match["set_number"],
                "blue_teams": match["alliances"]["blue"]["team_keys"],
                "blue_score": 0,
                "blue_climbing": 0,
                "blue_auto_points": 0,
                "blue_teleop_points": 0,
                "blue_endgame_points": 0,
                "blue_coopertition": 0,
                "blue_notes": 0,
                "red_teams": match["alliances"]["red"]["team_keys"],
                "red_score": 0,
                "red_climbing": 0,
                "red_auto_points": 0,
                "red_teleop_points": 0,
                "red_endgame_points": 0,
                "red_coopertition": 0,
                "red_notes": 0,
                "predicted": True,
            }
        for alliance in match["alliances"]:
            for team in match["alliances"][alliance]["team_keys"]:
                teamData = {}
                for i in range(1, len(calculatedData)):
                    if calculatedData[i]["key"] == team:
                        teamData = calculatedData[i]
                matchPrediction[f"{alliance}_score"] += teamData["OPR"]
                matchPrediction[f"{alliance}_climbing"] += teamData["climbing"]
                matchPrediction[f"{alliance}_auto_points"] += teamData["auto_points"]
                matchPrediction[f"{alliance}_teleop_points"] += teamData["teleop_points"]
                matchPrediction[f"{alliance}_endgame_points"] += teamData["endgame_points"] + \
                    teamData["harmony"]
                matchPrediction[f"{alliance}_notes"] += teamData["notes"]
                matchPrediction[f"{alliance}_coopertition"] += teamData["coopertition"]

        for alliance in match["alliances"]:
            if alliance == "red":
                opponent = "blue"
            else:
                opponent = "red"
            matchPrediction[f"{alliance}_win_rp"] = 2 if matchPrediction[f"{opponent}_score"] < matchPrediction[
                f"{alliance}_score"] else 1 if matchPrediction[f"{opponent}_score"] == matchPrediction[f"{alliance}_score"] else 0
            matchPrediction[f"{alliance}_ensemble_rp"] = 1 if matchPrediction[f"{alliance}_endgame_points"] > 10 else 0
            matchPrediction[f"{alliance}_melody_rp"] = 1 if matchPrediction[f"{alliance}_notes"] >= 18 or (
                matchPrediction[f"{alliance}_notes"] >= 15 and matchPrediction[f"{alliance}_coopertition"] > 0.5) else 0
            matchPrediction[f"{alliance}_total_rp"] = matchPrediction[f"{alliance}_win_rp"] + \
                matchPrediction[f"{alliance}_ensemble_rp"] + \
                matchPrediction[f"{alliance}_melody_rp"]
            if not matchPrediction["predicted"]:
                matchPrediction[f"{alliance}_display_rp"] = match["score_breakdown"][alliance]["rp"]
            else:
                matchPrediction[f"{alliance}_display_rp"] = matchPrediction[f"{alliance}_total_rp"]
        matchPredictions.append(matchPrediction)
    try:
        PredictionCollection.insert_one(
            {"event_code": event_code, "data": matchPredictions})
    except Exception as e:
        try:
            PredictionCollection.find_one_and_replace({"event_code": event_code}, {
                                                      "event_code": event_code, "data": matchPredictions})
        except Exception as ex:
            pass
    for i in range(1, len(calculatedData)):
        calculatedData[i]["simulated_rp"] = 0
        calculatedData[i]["simulated_rank"] = int(0)
    for matchPrediction in matchPredictions:
        for alliance in ["red", "blue"]:
            for team in matchPrediction[f"{alliance}_teams"]:
                dataTeam = {}
                idx = 0
                try:
                    for i in range(1, len(calculatedData)):
                        if calculatedData[i]["key"] == team:
                            dataTeam = calculatedData[i]
                            idx = i
                            break
                    if matchPrediction["predicted"] and matchPrediction["comp_level"] == "qm":
                        dataTeam["simulated_rp"] += matchPrediction[f"{alliance}_total_rp"]
                    else:
                        for match in TBAData:
                            if match["key"] == matchPrediction["key"]:
                                dataTeam["simulated_rp"] += match["score_breakdown"][alliance]["rp"]
                    calculatedData[idx] = dataTeam
                except Exception as e:
                    # print(e)
                    pass
    sorted_list = sorted(
        calculatedData[1:], key=lambda x: x["simulated_rp"], reverse=True)
    for i, item in enumerate(sorted_list):
        sorted_list[i]["simulated_rank"] = int(i + 1)
    sorted_list.insert(0, calculatedData[0])
    return sorted_list


@app.put("/{password}/Deactivate")
def deactivate_match_data(data: dict, password: str):
    if password == EDIT_PASSWORD:
        data["active"] = False
        ScoutingData2024Collection.find_one_and_replace(
            {"event_code": data["event_code"], "team_number": data["team_number"], "scout_info.name": data["scout_info"]["name"]}, data)
        eventCode = data["event_code"]
        event = ETagCollection.find_one({"key": eventCode})
        event["up_to_date"] = False
        ETagCollection.find_one_and_replace({"key": eventCode}, event)
        return data
    else:
        raise HTTPException(400, "Incorrect Password")


@app.put("/{password}/Activate")
def activate_match_data(data: dict, password: str):
    if password == EDIT_PASSWORD:
        data["active"] = True
        ScoutingData2024Collection.find_one_and_replace(
            {"event_code": data["event_code"], "team_number": data["team_number"], "scout_info.name": data["scout_info"]["name"]}, data)
        eventCode = data["event_code"]
        event = ETagCollection.find_one({"key": eventCode})
        event["up_to_date"] = False
        ETagCollection.find_one_and_replace({"key": eventCode}, event)
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
            r = requests.get(TBA_API_URL+"event/" +
                             event["key"]+"/matches", headers=headers)
            try:
                headers["If-None-Match"] = event["teamEtag"]
                req = requests.get(
                    TBA_API_URL+"event/" + event["key"] + "/teams/keys", headers=headers)
                if req.status_code == 200:
                    teams = json.loads(req.text)
                    event["teamEtag"] = req.headers["Etag"]
                else:
                    print(req.status_code, event["key"])
                    teams = event["teams"]
            except Exception as e:
                # print(e)
                teams = []
            # print("got Teams")
            event["teams"] = teams
            # print(teams)
            # print(event)
            ETagCollection.find_one_and_replace(
                {"key": event["key"]}, event)
            # print(teams)
            teams = [{"key": x[3:], "pit_status": "Not Started",
                      "picture_status": "Not Started", "follow_up_status": "Done"} for x in list(set(teams))]
            try:
                existingTeams = PitStatusCollection.find_one(
                    {"event_code": event["key"]})["data"]
            except:
                existingTeams = []
            # print("961")
            returnTeams = []
            for team in teams:
                for existingTeam in existingTeams:
                    if existingTeam["key"] == team["key"]:
                        team = existingTeam
                        break
                returnTeams.append(team)
            # print("got new teams")
            try:
                # print(returnTeams)
                PitStatusCollection.insert_one(
                    {"event_code": event["key"], "data": returnTeams})
            except Exception as e:
                # logging.error(e)
                PitStatusCollection.find_one_and_replace({"event_code": event["key"]}, {
                                                         "event_code": event["key"], "data": returnTeams})
            # print("977")
            if r.status_code == 200 or not event["up_to_date"]:
                try:
                    headers.pop("If-None-Match")
                    rankings = json.loads(requests.get(
                        TBA_API_URL+"event/" + event["key"] + "/rankings", headers=headers).text)["rankings"]
                    event["rankings"] = rankings
                except Exception as e:
                    logging.error(str(e)+" "+event["key"])
                    event["rankings"] = []
                ETagCollection.find_one_and_replace(
                {"key": event["key"]}, event)
                responseJson = json.loads(r.text)
                for x in responseJson:
                    try:
                        x.pop("_id")
                    except Exception as e:
                        pass
                    try:
                        TBACollection.insert_one(x)
                    except:
                        TBACollection.find_one_and_update({"key": x["key"]}, {"$set": {"time": x["time"], "actual_time": x["actual_time"],
                                                                                       "post_result_time": x["post_result_time"], "score_breakdown": x["score_breakdown"], "alliances": x["alliances"]}})
                event["etag"] = r.headers["ETag"]
                event["up_to_date"] = True
                ETagCollection.find_one_and_replace(
                {"key": event["key"]}, event)
                # print(e)
                try:
                    updateData(event["key"])
                except Exception as e:
                    print(e, event["key"])
                    
                    pass
        numRuns += 1
    except Exception as e:
        logging.error(e)
        pass
    logging.info("Done with data update #" + str(numRuns))
