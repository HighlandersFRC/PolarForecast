import base64
from functools import wraps
import io
import json
import logging
import math
from types import TracebackType
from typing import Annotated
import zipfile
from bson import ObjectId
from fastapi import Depends, FastAPI, File, HTTPException, Header, UploadFile
from fastapi.responses import JSONResponse, StreamingResponse
import numpy
from pydantic import BaseModel
from pymongo import MongoClient
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware
import pymongo
from models.pit_scouting_2025 import PitScouting2025
from models.alliance_request import AllianceRequest
from models.group import AllianceGroup, Group, GroupEvent, GroupEventSettings, GroupSettings
from models.group_join_request import GroupJoinRequest
from auth import add_user_to_group, check_token_active, create_join_code, delete_group_kc, fetch_group_members, find_user_groups, get_token_active, get_user_info, make_group, remove_user_from_group
from GeneticPolar import analyzeData
from config import EDIT_PASSWORD, TBA_POLLING_INTERVAL, TBA_API_KEY, TBA_API_URL, MONGO_CONNECTION, ALLOW_ORIGINS, get_redis_client
import requests
from fastapi_utils.tasks import repeat_every
from StatDescription import stat_description
logging.basicConfig(format="%(levelname)s:%(message)s", level=logging.DEBUG)
logging.info("Initialized Logger")

YEAR = '2024'
tags_metadata = [
    {
        "name": "stats",
        "description": "All of the stats Get endpoints.",
    },
    {
        "name": "scouting",
        "description": "All of the scouting data Get and Post endpoints.",
    },
    {
        "name": "users",
        "description": "Manage users.",
    },
    {
        "name": "groups",
        "description": "Manage groups.",
    },
    {
        "name": "alliances",
        "description": "Manage alliances.",
    },
    {
        "name": "miscellaneous",
        "description": "Other endpoints.",
    },
]

app = FastAPI(openapi_tags=tags_metadata)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["POST", "GET", "PUT", "DELETE"],
    allow_headers=["*"],
)

# Set Up the Database
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
    [("event_code", pymongo.ASCENDING), ("team_number", pymongo.ASCENDING), ("user_id", pymongo.ASCENDING)], unique=True)

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

GroupCollection = testDB["Groups"]
GroupCollection.create_index([("name", pymongo.ASCENDING),], unique=True)

AllianceRequestCollection = testDB["AllianceRequests"]
AllianceRequestCollection.create_index([
    ("group_1", pymongo.ASCENDING),
    ("group_2", pymongo.ASCENDING),
    ("event", pymongo.ASCENDING),
], unique=True)

GroupJoinRequestCollection = testDB["JoinRequests"]
GroupJoinRequestCollection.create_index([
    ("group_id", pymongo.ASCENDING),
    ("user_id", pymongo.ASCENDING),
], unique=True)

GroupDataCollection = testDB["GroupCalculatedData"]
GroupDataCollection.create_index(
    [("group_id", pymongo.ASCENDING), ("event_code", pymongo.ASCENDING)], unique=True)

GroupPredictionCollection = testDB["GroupPrediction"]
GroupPredictionCollection.create_index(
    [("group_id", pymongo.ASCENDING), ("event_code", pymongo.ASCENDING)], unique=True)

GroupPitStatusCollection = testDB['GroupPitScoutingStatus']
GroupPitStatusCollection.create_index(
    [("group_id", pymongo.ASCENDING), ("event_code", pymongo.ASCENDING)], unique=True)

redisClient = get_redis_client()


def store_in_cache(key, value, durationSeconds=300):
    try:
        redisClient.set(key, json.dumps(value), ex=durationSeconds)
    except Exception as e:
        pass


def get_from_cache(key):
    global redisClient
    if redisClient is None:
        logging.error("No Redis Cache")
        return None
    try:
        logging.info(f"Getting from cache {key}")
        return json.loads(redisClient.get(key))
    except Exception as e:
        logging.error(f"Error getting from cache {key}: {str(e)}")
        if Exception is ConnectionError:
            redisClient = get_redis_client()
        return None


def cacheValue(seconds: float = 300.0):
    def retFunc(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Convert positional arguments to strings
            keyargs = [str(arg) for arg in args]

            # Convert keyword arguments to strings
            keykwargs = [str(kwarg) + str(value)
                         for kwarg, value in kwargs.items()]

            # Create a unique cache key by combining all arguments with the function name
            key = ''.join(keyargs + keykwargs) + func.__name__

            # Check if the result is already in the cache
            value = get_from_cache(key)
            if value is not None:
                return value

            # Call the original function and store the result in cache
            result = func(*args, **kwargs)
            store_in_cache(key, result, durationSeconds=seconds)
            return result
        return wrapper
    return retFunc


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


@cacheValue()
def getGroupCalculatedData(event_code: str, group_id: str):
    return GroupDataCollection.find_one(
        {"event_code": event_code, "group_id": group_id})


@cacheValue()
def getEventCalculatedData(event_code: str):
    return CalculatedDataCollection.find_one({"event_code": event_code})


@cacheValue()
def getGroupPredictions(event_code: str, group_id: str):
    return GroupPredictionCollection.find_one(
        {"event_code": event_code, "group_id": group_id})


@cacheValue()
def getEventPredictions(event_code: str):
    return PredictionCollection.find_one({"event_code": event_code})


@app.get("/{year}/{event}/{team}/stats", tags=["stats"])
def get_event_Team_Stats(year: int, event: str, team: str, token: str = Header(None)):
    foundTeam = False
    if (token == None):
        data = getEventCalculatedData(str(year)+event)
    else:
        if get_token_active(token=token):
            groups = get_user_groups(token=token)
            foundGroup = False
            for group in groups:
                if len(group['path'].split("/")) == 2:
                    data = getGroupCalculatedData(str(year)+event, group['id'])
                    if data != None:
                        foundGroup = True
                    break
            if not foundGroup:
                data = getEventCalculatedData(str(year)+event)
        else:
            data = getEventCalculatedData(str(year)+event)
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


@app.get("/{year}/{event}/{team}/matches", tags=["stats"])
@cacheValue()
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


@app.get("/{year}/{event}/stats", tags=["stats"])
def get_Event_Stats(year: int, event: str, token: str = Header(None)):
    if (token == None):
        data = getEventCalculatedData(str(year)+event)
    else:
        if get_token_active(token=token):
            groups = get_user_groups(token=token)
            foundGroup = False
            for group in groups:
                if len(group['path'].split("/")) == 2:
                    data = getGroupCalculatedData(str(year)+event, group['id'])
                    if data != None:
                        foundGroup = True
                    break
            if not foundGroup:
                data = getEventCalculatedData(str(year)+event)
        else:
            data = getEventCalculatedData(str(year)+event)
    for i, team in enumerate(data["data"][1:]):
        if math.isnan(team["death_rate"]):
            team["death_rate"] = 0
        data["data"][i+1] = team
    data.pop("_id")
    return data


@app.get("/events/{year}", tags=["miscellaneous"])
@cacheValue()
def get_Year_Events(year: int):
    events = ETagCollection.find({})
    events = [event["event"] for event in events]
    return events


@app.get("/search_keys", tags=["miscellaneous"])
@cacheValue()
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


@app.get("/{year}/{event}/predictions", tags=["stats"])
def get_Event_Predictions(year: int, event: str, token: str = Header(None)):
    try:
        if (token == None):
            data = getEventPredictions(str(year)+event)
        else:
            if get_token_active(token=token):
                groups = get_user_groups(token=token)
                foundGroup = False
                for group in groups:
                    if len(group['path'].split("/")) == 2:
                        data = getGroupPredictions(
                            str(year)+event, group['id'])
                        if data != None:
                            foundGroup = True
                        break
                if not foundGroup:
                    data = getEventPredictions(str(year)+event)
            else:
                data = getEventPredictions(str(year)+event)
        data.pop("_id")
        return {"data": data["data"]}
    except:
        return {"data": []}


@app.get("/{year}/{event}/{match_key}/match_details", tags=["stats"])
def get_match_details(year: int, event: str, match_key: str, token: str = Header(None)):
    try:
        event_code = str(year)+event
        tbaMatch = TBACollection.find_one({"key": match_key})
        tbaMatch.pop("_id")
        matchPrediction = {}
        blueTeamStats = []
        redTeamStats = []
        try:
            if (token == None):
                eventPredictions = getEventPredictions(str(year)+event)
            else:
                if get_token_active(token=token):
                    groups = get_user_groups(token=token)
                    foundGroup = False
                    for group in groups:
                        if len(group['path'].split("/")) == 2:
                            eventPredictions = getGroupPredictions(
                                str(year)+event, group['id'])
                            if eventPredictions != None:
                                foundGroup = True
                            break
                    if not foundGroup:
                        eventPredictions = getEventPredictions(str(year)+event)
                else:
                    eventPredictions = getEventPredictions(str(year)+event)
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
        return retval
    except Exception as e:
        raise HTTPException(400, str(e))


@app.get("/{year}/{event}/{team}/predictions", tags=["stats"])
def get_team_match_predictions(year: int, event: str, team: str, token: str = Header(None)):
    event_code = str(year) + event
    if (token == None):
        data = getEventCalculatedData(str(year)+event)
    else:
        if get_token_active(token=token):
            groups = get_user_groups(token=token)
            foundGroup = False
            for group in groups:
                if len(group['path'].split("/")) == 2:
                    data = getGroupPredictions(
                        str(year)+event, group['id'])
                    if data != None:
                        foundGroup = True
                    break
            if not foundGroup:
                data = getEventPredictions(str(year)+event)
        else:
            data = getEventPredictions(str(year)+event)
    matches = []
    for alliance in ["red", "blue"]:
        for match in data["data"]:
            if match[alliance+"_teams"].__contains__(team):
                matches.append(match)
    return {"data": matches}


@app.get("/{year}/{event}/stat_description", tags=["miscellaneous"])
@cacheValue()
def get_Stat_Descriptions():
    return stat_description


@app.get("/{year}/{event}/{team}/PitScouting", tags=["scouting"], response_model=PitScouting2025)
def get_pit_scouting_data(year: int, event: str, team: str, token=Depends(check_token_active)):
    user_info = get_user_info(token=token)
    groups = [Group(**group)
              for group in get_user_groups_detailed(token=token)]
    if len(groups) == 0:
        try:
            data = PitScouting2025(**PitScoutingCollection.find_one(
                {"event_code": str(year) + event, "team_number": int(team[3:]), "user_id": user_info['sub']}))
            return data
        except Exception as e:
            raise HTTPException(404, str(e))
    group = groups[0]
    members = fetch_group_members(group.member_group_id)
    member_ids = [member['id'] for member in members]
    groupPitEntries = [PitScouting2025(**entry) for entry in PitScoutingCollection.find(
        {"event_code": str(year) + event, "team_number": int(team[3:]), "user_id": {"$in": member_ids}})]
    if len(groupPitEntries) == 0:
        raise HTTPException(404, f"No entries for {team} at {event} in {year}")
    latestEntry = groupPitEntries[0]
    for entry in groupPitEntries:
        if entry.time > latestEntry.time:
            latestEntry = entry
    return latestEntry.dict()


@app.get("/{year}/{event}/PitScoutingStatus", tags=["scouting"])
def get_pit_scouting_status(year: int, event: str):
    data = PitStatusCollection.find_one({"event_code": str(year) + event})
    return data


@app.post("/PitScouting/", tags=["scouting"])
def post_pit_scouting_data(data: PitScouting2025, token: str = Depends(check_token_active)):
    user_info = get_user_info(token)
    if (user_info['sub'] != data.user_id):
        raise HTTPException(
            400, 'The user id of the pit scouting entry and your user id do not match')
    status = getStatus(data, PitStatusCollection.find_one(
        {"event_code": data.event_code}))
    status.pop("_id")
    PitStatusCollection.find_one_and_replace(
        {"event_code": data.event_code}, status)
    groups = [Group(**group)
              for group in get_user_groups_detailed(token=token)]
    for group in groups:
        try:
            groupStatus = getStatus(data, GroupPitStatusCollection.find_one(
                {"event_code": data.event_code,
                    "group_id": group.group_id}
            ))
            groupStatus.pop("_id")
            GroupPitStatusCollection.find_one_and_replace(
                {"event_code": data.event_code, "group_id": group.group_id}, groupStatus)
        except:
            pass
    eventData = CalculatedDataCollection.find_one(
        {"event_code": data.event_code})
    teams = ETagCollection.find_one(
        {"key": data.event_code})["teams"]
    teams = [team[3:] for team in teams]
    team = str(data.team_number)
    if not teams.__contains__(team):
        raise HTTPException(400, "No team key '"+str(data.team_number) +
                            "' in "+data.event_code)
    for doc in eventData["data"][1:]:
        if doc["key"] == f"frc{team}":
            for key in data.data.dict():
                if not key == "_id":
                    doc[key] = data.data.dict()[key]
            break
    CalculatedDataCollection.find_one_and_replace(
        {"event_code": data.event_code}, eventData)
    for group in groups:
        try:
            groupData = GroupDataCollection.find_one(
                {"event_code": data.event_code, "group_id": group.group_id}
            )
            for doc in groupData["data"][1:]:
                if doc["key"] == f"frc{team}":
                    for key in data.data.dict():
                        if not key == "_id":
                            doc[key] = data.data.dict()[key]
                    break
            GroupDataCollection.find_one_and_replace(
                {"event_code": data.event_code, "group_id": group.group_id}, groupData)
        except:
            pass
    try:
        PitScoutingCollection.insert_one(data)
    except Exception as e:
        PitScoutingCollection.find_one_and_replace(
            {"event_code": data.event_code, "team_number": data.team_number, "user_id": data.user_id}, data.dict())
    return {"message": "added it to the DB"}


def getStatus(data: PitScouting2025, originalStatus: dict):
    status = "Incomplete"
    found = False
    if data.data.drive_train != "":
        if data.data.drive_train != "":
            status = "Done"
    for entry in originalStatus["data"]:
        if entry["key"] == str(data.team_number):
            found = True
            entry["pit_status"] = status
    if (not found):
        raise HTTPException(400, "No Such Team")
    else:
        return originalStatus


numRuns = 0


@app.post("/MatchScouting/", tags=["scouting"])
def post_match_scouting(data: dict, token: str = Depends(check_token_active)):
    data["scout_info"] = get_user_info(token)
    logging.info(str(data))
    eventCode = data["event_code"]
    event = ETagCollection.find_one({"key": eventCode})
    event["up_to_date"] = False
    ETagCollection.find_one_and_replace({"key": eventCode}, event)
    matchNumber = data["match_number"]
    teamNumber = data["team_number"]
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


@app.get("/Group/{group_name}/AllianceRequests", tags=["groups", "alliances"])
def get_group_alliance_requests(group_name: str, token: str = Depends(check_token_active)):
    if group_name == None:
        raise HTTPException(400, "Please provide a group name")
    try:
        DB_group = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(
            404, "The Group You Said You Are Part Of does not exist")
    kc_groups = get_user_groups(token=token)
    kc_group = {}
    for kc in kc_groups:
        if kc["id"] == DB_group.admin_group_id:
            kc_group = kc
            break
    if kc_group == {}:
        raise HTTPException(
            403, "You are not an admin of this group")
    requests = [AllianceRequest(
        **request) for request in AllianceRequestCollection.find({"group_1": group_name})]
    requests.extend([AllianceRequest(
        **request) for request in AllianceRequestCollection.find({"group_2": group_name})])
    return [request.dict() for request in requests]


@app.post("/Group/{group_name}/Event/{event}/Alliance/Request", tags=["alliances"])
def request_alliance(group_name: str | None = None, token: str = Depends(check_token_active), event: str | None = None, other_group: str | None = None):
    if group_name == None:
        raise HTTPException(400, "Please provide a group name")
    if event == None:
        raise HTTPException(400, "Please provide an event")
    if other_group == None:
        raise HTTPException(400, "Please provide an other group name")
    if token == None:
        raise HTTPException(400, "Please provide a token")
    if group_name == other_group:
        raise HTTPException(
            400, "You cannot request an alliance with yourself")
    kc_groups = get_user_groups(token)
    try:
        group = Group(**GroupCollection.find_one({'name': group_name}))
    except:
        raise HTTPException(
            404, "The Group You said you were part of is does not exist")
    kc_admin_group = {}
    for kc in kc_groups:
        if group.admin_group_id == kc['id']:
            kc_admin_group = kc
            break
    if kc_admin_group == {}:
        raise HTTPException(
            401, "You must be an admin of this group to request an alliance")
    events = group.events
    m_event = None
    for _event in events:
        if _event.event_code == event:
            m_event = _event
            break
    if m_event is None:
        raise HTTPException(
            400, f"Your Group is not part of event '{event}'")
    try:
        m_other_group = Group(
            **GroupCollection.find_one({'name': other_group}))
    except:
        raise HTTPException(
            404, "The Group you requested to alliance with does not exist")
    events = m_other_group.events
    m_event = None
    for _event in events:
        if _event.event_code == event:
            m_event = _event
            break
    if m_event is None:
        raise HTTPException(
            400, f"The Group you requested to alliance with is not part of event '{event}'")
    request = AllianceRequest(
        group_1=group_name,
        group_2=other_group,
        group_1_affiliation=group.affiliation,
        group_2_affiliation=m_other_group.affiliation,
        event=event,
        request_time=int(datetime.now().timestamp()),
        accepted=False,
    )
    duplicates = AllianceRequestCollection.find(
        {'group_1': request.group_2, 'group_2': request.group_1})
    if len(list(duplicates)) > 0:
        raise HTTPException(
            400, "There is already a request pending between these groups")
    try:
        AllianceRequestCollection.insert_one(request.dict())
    except pymongo.errors.DuplicateKeyError as e:
        raise HTTPException(400, "You have already requested for an alliance")
    return get_group_alliance_requests(group_name=group_name, token=token)


@app.post("/Group/{group_name}/Event/{event}/Alliance/Accept", tags=["alliances"])
def accept_alliance(group_name: str | None = None, token: str = Depends(check_token_active), alliance_request: AllianceRequest | None = None):
    if alliance_request is None:
        raise HTTPException(400, "Please provide an alliance request")
    if group_name == None:
        raise HTTPException(400, "Please provide a group name")
    if alliance_request.group_2 != group_name:
        raise HTTPException(
            400, "The group name you provided cannot accept the alliance request you provided")
    if alliance_request.accepted:
        raise HTTPException(
            400, "This alliance request has already been accepted")
    try:
        DB_entry = AllianceRequest(
            **AllianceRequestCollection.find_one(alliance_request.dict()))
    except:
        raise HTTPException(
            404, "The alliance tried to accept was never requested")
    kc_groups = get_user_groups(token)
    try:
        DB_group = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(
            404, "This group does not exist")
    kc_admin_group = {}
    for kc in kc_groups:
        if DB_group.admin_group_id == kc['id']:
            kc_admin_group = kc
            break
    if kc_admin_group == {}:
        raise HTTPException(
            401, "You must be an admin of this group to accept an alliance")
    DB_entry.accepted = True
    try:
        AllianceRequestCollection.find_one_and_update(
            {"group_1": alliance_request.group_1, "group_2": alliance_request.group_2, "event": alliance_request.event}, {'$set': {"accepted": True}})
    except Exception as e:
        raise HTTPException(400, "Failed to accept the alliance request")
    try:
        DB_other_group = Group(
            **GroupCollection.find_one({"name": alliance_request.group_1}))
    except:
        raise HTTPException(
            404, "The Group you tried to alliance with was never created")
    other_events = DB_other_group.events
    for _other_event in other_events:
        if _other_event.event_code == alliance_request.event:
            _other_event.alliance_groups.append(
                AllianceGroup(
                    group_id=DB_group.group_id,
                    name=DB_group.name,
                    affiliation=DB_group.affiliation,
                )
            )
            break
    GroupCollection.find_one_and_update(
        {"name": alliance_request.group_1}, {'$set': {"events": [__other_event.dict() for __other_event in other_events]}})
    events = DB_group.events
    for _event in events:
        if _event.event_code == alliance_request.event:
            _event.alliance_groups.append(
                AllianceGroup(
                    group_id=DB_other_group.group_id,
                    name=DB_other_group.name,
                    affiliation=DB_other_group.affiliation,
                )
            )
            break
    GroupCollection.find_one_and_update(
        {"name": alliance_request.group_2}, {'$set': {"events": [__event.dict() for __event in events]}})
    return get_group_alliance_requests(group_name=group_name, token=token)


@app.delete("/Group/{group_name}/Event/{event}/Alliance/Leave", tags=["alliances"])
def leave_alliance(group_name: str | None = None, token: str = Depends(check_token_active), event: str | None = None, other_group: str | None = None):
    if group_name == None or event == None or other_group == None:
        raise HTTPException(
            400, "Please provide a group name, event code, and other group name")
    if group_name == other_group:
        raise HTTPException(
            400, "You cannot leave an alliance with yourself")
    try:
        DB_Entry = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(
            404, "This group does not exist")
    if event not in [event.event_code for event in DB_Entry.events]:
        raise HTTPException(
            400, f"This group does not have an event with the code '{event}'")
    for _event in DB_Entry.events:
        if _event.event_code == event:
            m_event = _event
            break
    if other_group not in [allianceGroup.name for allianceGroup in m_event.alliance_groups]:
        raise HTTPException(
            400, f"This group does not have an alliance with the group '{other_group}'")
    try:
        DB_other_group = Group(
            **GroupCollection.find_one({"name": other_group}))
    except:
        raise HTTPException(
            404, "The Group you tried to leave an alliance with was never created")
    kc_events = get_user_groups(token)
    kc_group = {}
    for kc in kc_events:
        if kc['id'] == DB_Entry.admin_group_id:
            kc_group = kc
            break
    if kc_group == {}:
        raise HTTPException(
            401, "You must be an admin of this group to leave an alliance")
    for _event in DB_Entry.events:
        if _event.event_code == event:
            for allianceGroup in _event.alliance_groups:
                if allianceGroup.name == other_group:
                    _event.alliance_groups.remove(allianceGroup)
                    break
            break
    GroupCollection.find_one_and_update(
        {"name": group_name}, {'$set': {"events": [__event.dict() for __event in DB_Entry.events]}})
    for _event in DB_other_group.events:
        if _event.event_code == event:
            for allianceGroup in _event.alliance_groups:
                if allianceGroup.name == group_name:
                    _event.alliance_groups.remove(allianceGroup)
                    break
            break
    GroupCollection.find_one_and_update(
        {"name": other_group}, {'$set': {"events": [__event.dict() for __event in DB_other_group.events]}})
    eventAlliances = [AllianceRequest(**request) for request in AllianceRequestCollection.find(
        {"event": event, "accepted": True})]
    for alliance in eventAlliances:
        if alliance.group_1 == other_group or alliance.group_2 == other_group:
            if alliance.group_1 == group_name or alliance.group_2 == group_name:
                AllianceRequestCollection.find_one_and_delete(alliance.dict())
    return get_group(group_name=group_name, token=token)


@app.delete("/Group/{group_name}/Event/{event}/Alliance/Decline", tags=["alliances"])
def decline_alliance(group_name: str | None = None, event: str | None = None, token: str = Depends(check_token_active), alliance_request: AllianceRequest | None = None):
    if alliance_request == None:
        raise HTTPException(
            400, "Please provide an alliance request")
    if group_name == None:
        raise HTTPException(
            400, "Please provide a group name")
    if event == None:
        raise HTTPException(
            400, "Please provide an event code")
    if group_name != alliance_request.group_2:
        raise HTTPException(
            400, "Your group cannot decline this alliance request")
    if group_name == alliance_request.group_1:
        raise HTTPException(
            400, "You cannot decline this alliance with yourself")
    try:
        DB_Entry = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(
            404, "This group does not exist")
    try:
        DB_request = AllianceRequestCollection.find_one(
            alliance_request.dict())
    except:
        raise HTTPException(
            404, "This alliance request does not exist")
    kc_groups = get_user_groups(token)
    kc_group = {}
    for kc in kc_groups:
        if kc['id'] == DB_Entry.admin_group_id:
            kc_group = kc
            break
    if kc_group == {}:
        raise HTTPException(
            401, "You must be an admin of this group to decline an alliance")
    AllianceRequestCollection.find_one_and_delete(alliance_request.dict())
    return get_group_alliance_requests(group_name=group_name, token=token)


@app.delete("/Group/{group_name}/Event/{event}/Alliance/DeleteRequest", tags=["alliances"])
def remove_alliance(group_name: str, event: str, token: str = Depends(check_token_active), alliance_request: AllianceRequest | None = None):
    if alliance_request == None:
        raise HTTPException(
            400, "Please provide an alliance request")
    if group_name == None:
        raise HTTPException(
            400, "Please provide a group name")
    if event == None:
        raise HTTPException(
            400, "Please provide an event code")
    try:
        DB_Entry = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(
            404, "This group does not exist")
    kc_groups = get_user_groups(token)
    kc_admin_group = {}
    for kc in kc_groups:
        if kc['id'] == DB_Entry.admin_group_id:
            kc_admin_group = kc
            break
    if kc_admin_group == {}:
        raise HTTPException(
            401, "You must be an admin to delete an alliance request")
    if (alliance_request.group_1 != DB_Entry.name):
        raise HTTPException(
            401, f"You are not part of the group which issued this request")
    try:
        AllianceRequestCollection.find_one_and_delete(alliance_request.dict())
    except:
        raise HTTPException(
            400, "Failed to delete this request")
    return get_group_alliance_requests(group_name=group_name, token=token)


@app.post("/Group/{group_name}/Event/{event}/Add", tags=["groups"])
def add_event_to_group(group_name: str, event: str, token: str = Depends(check_token_active)):
    try:
        DB_Entry = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(
            404, "This group does not exist")
    if event in [event.event_code for event in DB_Entry.events]:
        raise HTTPException(
            400, f"This group already has an event with the code '{event}'")
    kc_groups = get_user_groups(token=token)
    admin = False
    for kc_group in kc_groups:
        if kc_group["id"] == DB_Entry.admin_group_id:
            admin = True
            break
    if not admin:
        raise HTTPException(
            401, "You must be an admin of this group to add events")
    new_event = GroupEvent(event_code=event, settings=GroupEventSettings(
        crowd_sourced_match_scouting=False, crowd_sourced_pit_scouting=False), alliance_groups=[])
    DB_Entry.events.append(new_event)
    GroupCollection.find_one_and_update(
        {"name": group_name}, {'$set': {"events": [event.dict() for event in DB_Entry.events]}})
    return get_group(group_name=group_name, token=token)


@app.post("/CreateGroup", tags=["groups"])
def create_group(group_name: str | None = None, token: str = Depends(check_token_active), event: str | None = None) -> Group:
    if len(get_user_groups(token)) != 0:
        HTTPException(400, "You are already part of a group")
    if group_name == None:
        raise HTTPException(400, "Please provide a group name")
    if (token is not None):
        user_info = get_user_info(token)
        events = []
        if event is not None:
            events = [GroupEvent(
                event_code=event,
                settings=GroupEventSettings(
                    crowd_sourced_match_scouting=True,
                    crowd_sourced_pit_scouting=True,
                ),
                alliance_groups=[]
            ),]
        try:
            if user_info.__contains__('team_number'):
                groupData = make_group(token, group_name, event)
                DBEntry = Group(
                    affiliation=f"frc{user_info['team_number']}",
                    group_id=groupData["group_id"],
                    join_code=groupData["code"],
                    name=group_name,
                    owner_group_id=groupData["owner_subgroup_id"],
                    admin_group_id=groupData["admin_subgroup_id"],
                    member_group_id=groupData["member_subgroup_id"],
                    events=events,
                    settings=GroupSettings(
                        approve_new_members=True,
                    ),
                )
        except KeyError:
            raise HTTPException(
                422, "Your User is Not Affiliated with a team. Contact the developers for help.")
        GroupCollection.insert_one(DBEntry.dict())
        return DBEntry


@app.get("/{year}/{event}/Groups", tags=["groups"])
def get_event_groups(year: int, event: str, token: str = Depends(check_token_active)):
    eventCode = f"{year}{event}"
    eventGroups = GroupCollection.find(
        {"events.event_code": eventCode})
    return [Group(**group).dict(exclude={"join_code", "settings", "events", "owner_group_id", "admin_group_id", "member_group_id", "group_id"}) for group in eventGroups]


@app.get("/Group/{group_name}", tags=["groups"])
def get_group(group_name: str, token: str = Depends(check_token_active)):
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found: {str(e)}")
    groups = get_user_groups(token)
    KCgroup = {}
    for group in groups:
        if group['id'] == DBgroup.group_id:
            KCgroup = group
            break
    if KCgroup == {}:
        raise HTTPException(403, f"You are not part of group '{group_name}'")
    retval = {}
    for group in groups:
        if group['id'] == DBgroup.owner_group_id:
            retval = {'group': DBgroup.dict(), 'group_role': 'owner'}
            break
        if group['id'] == DBgroup.admin_group_id:
            retval = {'group': DBgroup.dict(), 'group_role': 'admin'}
        if group['id'] == DBgroup.member_group_id:
            if (retval == {}):
                retval = {'group': DBgroup.dict(
                    exclude={'join_code'}), 'group_role': 'member'}
    if retval != {}:
        # Get either the current cached join code or create a new one
        if retval['group_role'] == 'owner' or retval['group_role'] == 'admin':
            @cacheValue(seconds=60*60*24*7)  # One Week
            def join_code(group_name):
                new_code = create_join_code()
                GroupCollection.find_one_and_update(
                    {"name": group_name}, {"$set": {"join_code": new_code}})
                return new_code
            retval['group']['join_code'] = join_code(group_name)
        return retval
    raise HTTPException(
        400, f"You somehow broke Polar Forecast's '{group_name}' Group")


@app.post("/Group/{group_name}/Join", tags=["groups"], response_model=list[GroupJoinRequest])
def join_group(group_name: str, join_code: str, token: str = Depends(check_token_active)):
    groups = get_user_groups(token)
    if len(groups) != 0:
        raise HTTPException(400, "You are already part of a group")
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found: {str(e)}")
    user_info = get_user_info(token)
    try:
        if user_info['team_number'] != DBgroup.affiliation[3:]:
            raise HTTPException(
                401, "You are not affiliated with the team which this group is affiliated")
    except KeyError as e:
        raise HTTPException(
            422, "You either are not affiliated with a team or the group is not affiliated with a team")
    KCgroup = {}
    for group in groups:
        if group['id'] == DBgroup.group_id:
            KCgroup = group
            break
    if KCgroup != {}:
        return get_user_join_requests(token=token)
    if len(groups) > 0:
        raise HTTPException(
            400, "You already have a group")
    if DBgroup.join_code != join_code:
        raise HTTPException(401, "Incorrect Join Code")
    # Add user to group
    newRequest = GroupJoinRequest(
        group_name=group_name,
        user_id=user_info['sub'],
        username=user_info['preferred_username'],
        request_time=datetime.now().timestamp(),
        group_id=DBgroup.group_id,
        accepted=False,
    )
    try:
        GroupJoinRequestCollection.insert_one(newRequest.dict())
    except Exception as e:
        raise HTTPException(
            400, f"You have already sent a join request")
    return get_user_join_requests(token=token)


@app.get("/Group/{group_name}/JoinRequests", tags=["groups"], response_model=list[GroupJoinRequest])
def get_group_join_requests(group_name: str | None = None, token: str = Depends(check_token_active)):
    if group_name == None:
        raise HTTPException(400, "Please provide a group name")
    try:
        DB_group = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(404, "This group does not exist")
    kc_groups = get_user_groups(token)
    admin_group = {}
    for group in kc_groups:
        if group['id'] == DB_group.admin_group_id:
            admin_group = group
            break
    if admin_group == {}:
        raise HTTPException(
            401, f"You are not an admin of group '{group_name}'")
    requests = [GroupJoinRequest(
        **request) for request in GroupJoinRequestCollection.find({"group_id": DB_group.group_id})]
    return requests


@app.post("/Group/{group_name}/JoinRequests/Accept", tags=["groups"], response_model=list[GroupJoinRequest])
def accept_join_request(group_name: str | None = None, request: GroupJoinRequest | None = None, token: str = Depends(check_token_active)):
    if group_name == None or request == None:
        raise HTTPException(
            400, "Please provide a group name and a join request")
    try:
        DB_group = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(404, "This group does not exist")
    kc_groups = get_user_groups(token)
    admin_group = {}
    for group in kc_groups:
        if group['id'] == DB_group.admin_group_id:
            admin_group = group
            break
    if admin_group == {}:
        raise HTTPException(
            401, f"You are not an admin of group '{group_name}'")
    try:
        DB_request = GroupJoinRequest(
            **GroupJoinRequestCollection.find_one(request.dict()))
    except Exception as e:
        raise HTTPException(404, f"Join Request Not Found: {str(e)}")
    if DB_request.accepted:
        raise HTTPException(
            400, f"Join Request has already been accepted")
    GroupJoinRequestCollection.delete_many({"user_id": request.user_id})
    request.accepted = True
    GroupJoinRequestCollection.insert_one(request.dict())
    add_user_to_group(user_id=request.user_id, group_id=request.group_id)
    add_user_to_group(user_id=request.user_id,
                      group_id=DB_group.member_group_id)
    return get_group_join_requests(group_name, token)


@app.delete("/Group/{group_name}/JoinRequests/Decline", tags=["groups"], response_model=list[GroupJoinRequest])
def decline_join_request(group_name: str | None = None, request: GroupJoinRequest | None = None, token: str = Depends(check_token_active)):
    if group_name == None or request == None:
        raise HTTPException(
            400, "Please provide a group name and a join request")
    try:
        DB_group = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(404, "This group does not exist")
    kc_groups = get_user_groups(token)
    admin_group = {}
    for group in kc_groups:
        if group['id'] == DB_group.admin_group_id:
            admin_group = group
            break
    if admin_group == {}:
        raise HTTPException(
            401, f"You are not an admin of group '{group_name}'")
    try:
        DB_request = GroupJoinRequest(
            **GroupJoinRequestCollection.find_one(request.dict()))
    except Exception as e:
        raise HTTPException(404, f"Join Request Not Found: {str(e)}")
    if DB_request.accepted:
        raise HTTPException(
            400, f"Join Request has already been accepted")
    GroupJoinRequestCollection.delete_one(request.dict())
    return get_group_join_requests(group_name, token)


@app.delete("/Group/{group_name}/DeleteJoinRequest", tags=["groups"], response_model=list[GroupJoinRequest])
def delete_group_join_request(group_name: str | None = None, token: str = Depends(check_token_active)):
    if group_name is None:
        raise HTTPException(
            400, "Please provide a group name")
    user_info = get_user_info(token)
    try:
        DB_request = GroupJoinRequest(
            **GroupJoinRequestCollection.find_one({"user_id": user_info["sub"], "group_name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Join Request Not Found")
    if (DB_request.accepted):
        raise HTTPException(
            400, 'You cannot delete a request which has been accepted')
    GroupJoinRequestCollection.delete_one(
        DB_request.dict())
    return get_user_join_requests(token=token)


@app.get("/Group/{group_name}/Members", tags=["groups"])
def get_group_members(group_name: str, token: str = Depends(check_token_active)):
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found: {str(e)}")
    groups = get_user_groups(token)
    KCgroup = {}
    for group in groups:
        if group['id'] == DBgroup.group_id:
            KCgroup = group
            break
    if KCgroup == {}:
        raise HTTPException(403, f"You are not part of group '{group_name}'")
    owners = fetch_group_members(group_id=DBgroup.owner_group_id)
    admins = fetch_group_members(group_id=DBgroup.admin_group_id)
    members = fetch_group_members(group_id=DBgroup.member_group_id)
    pop_keys = ['totp', 'createdTimestamp', 'enabled', 'emailVerified',
                'disableableCredentialTypes', 'requiredActions', 'notBefore', ]
    for i in range(len(owners)):
        for pop_key in pop_keys:
            try:
                owners[i].pop(pop_key)
            except Exception as e:
                print(e)
    for i in range(len(admins)):
        for pop_key in pop_keys:
            try:
                admins[i].pop(pop_key)
            except Exception as e:
                print(e)
    for i in range(len(members)):
        for pop_key in pop_keys:
            try:
                members[i].pop(pop_key)
            except Exception as e:
                print(e)
    for admin in admins:
        if members.__contains__(admin):
            members.remove(admin)
    for owner in owners:
        if admins.__contains__(owner):
            admins.remove(owner)
    return {
        "owners": owners,
        "admins": admins,
        "members": members,
    }


@app.put("/Group/{group_name}/Members/Demote", tags=["groups"])
def demote_group_member(group_name: str, demote_id: str, token: str = Depends(check_token_active)):
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found: {str(e)}")
    groups = get_user_groups(token)
    KCgroup = {}
    for group in groups:
        if group['id'] == DBgroup.owner_group_id:
            KCgroup = group
            break
    if KCgroup == {}:
        raise HTTPException(
            403, f"You are not an owner of group '{group_name}'")
    demoteGroups = find_user_groups(user_id=demote_id)
    KCgroup = {}
    for demoteGroup in demoteGroups:
        if demoteGroup["id"] == DBgroup.owner_group_id:
            KCgroup = {}
            break
        if demoteGroup["id"] == DBgroup.admin_group_id:
            KCgroup = demoteGroup
    if KCgroup == {}:
        raise HTTPException(
            403, f"The user you tried to demote is not a admin '{group_name}'")
    remove_user_from_group(user_id=demote_id, group_id=DBgroup.admin_group_id)
    return get_group_members(group_name=group_name, token=token)


@app.delete('/Group/{group_name}/Members/Kick', tags=["groups"])
def kick_group_member(group_name: str, kick_id: str, token: str = Depends(check_token_active)):
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found: {str(e)}")
    groups = get_user_groups(token)
    KCgroup = {}
    for group in groups:
        if group['id'] == DBgroup.admin_group_id:
            KCgroup = group
            break
    if KCgroup == {}:
        raise HTTPException(
            403, f"You are not an admin of group '{group_name}'")
    kickGroups = find_user_groups(user_id=kick_id)
    KCgroup = {}
    for kickGroup in kickGroups:
        if kickGroup["id"] == DBgroup.owner_group_id or kickGroup["id"] == DBgroup.admin_group_id:
            KCgroup = {}
            break
        if kickGroup["id"] == DBgroup.member_group_id:
            KCgroup = kickGroup
    if KCgroup == {}:
        raise HTTPException(
            403, f"The user you tried to kick is not a member '{group_name}'")
    GroupJoinRequestCollection.delete_one(
        {"user_id": kick_id, "group_name": group_name})
    remove_user_from_group(user_id=kick_id, group_id=DBgroup.member_group_id)
    remove_user_from_group(user_id=kick_id, group_id=DBgroup.group_id)
    return get_group_members(group_name=DBgroup.name, token=token)


@app.put("/Group/{group_name}/Members/PromoteMember", tags=["groups"])
def promote_group_member(group_name: str, promote_id: str, token: str = Depends(check_token_active)):
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found: {str(e)}")
    groups = get_user_groups(token)
    KCgroup = {}
    for group in groups:
        if group['id'] == DBgroup.owner_group_id:
            KCgroup = group
            break
    if KCgroup == {}:
        raise HTTPException(
            403, f"You are not an owner of group '{group_name}'")
    demoteGroups = find_user_groups(user_id=promote_id)
    KCgroup = {}
    for demoteGroup in demoteGroups:
        if demoteGroup["id"] == DBgroup.owner_group_id or demoteGroup["id"] == DBgroup.admin_group_id:
            KCgroup = {}
            break
        if demoteGroup["id"] == DBgroup.member_group_id:
            KCgroup = demoteGroup
    if KCgroup == {}:
        raise HTTPException(
            403, f"The user you tried to promote is not a member '{group_name}'")
    add_user_to_group(user_id=promote_id, group_id=DBgroup.admin_group_id)
    return get_group_members(group_name=group_name, token=token)


@app.put("/Group/{group_name}/Members/PromoteAdmin", tags=["groups"])
def promote_group_admin(group_name: str, promote_id: str, token: str = Depends(check_token_active)):
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found: {str(e)}")
    groups = get_user_groups(token)
    KCgroup = {}
    for group in groups:
        if group['id'] == DBgroup.owner_group_id:
            KCgroup = group
            break
    if KCgroup == {}:
        raise HTTPException(
            403, f"You are not an owner of group '{group_name}'")
    demoteGroups = find_user_groups(user_id=promote_id)
    KCgroup = {}
    for demoteGroup in demoteGroups:
        if demoteGroup["id"] == DBgroup.owner_group_id:
            KCgroup = {}
            break
        if demoteGroup["id"] == DBgroup.admin_group_id:
            KCgroup = demoteGroup
    if KCgroup == {}:
        raise HTTPException(
            403, f"The user you tried to promote is not a admin '{group_name}'")
    add_user_to_group(user_id=promote_id, group_id=DBgroup.owner_group_id)
    remove_user_from_group(user_id=get_user_info(
        token)['sub'], group_id=DBgroup.owner_group_id)
    return get_group_members(group_name=group_name, token=token)


@app.delete("/Group/{group_name}/Leave", tags=["groups"])
def leave_group(group_name: str, token: str = Depends(check_token_active)):
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found: {str(e)}")
    groups = get_user_groups(token)
    KCgroup = {}
    for group in groups:
        if group['id'] == DBgroup.group_id:
            KCgroup = group
            break
    if KCgroup == {}:
        raise HTTPException(
            403, f"You are not a member of group '{group_name}'")
    group_members = fetch_group_members(DBgroup.group_id, token)
    if len(group_members) != 1:
        for group in groups:
            if group['id'] == DBgroup.owner_group_id:
                raise HTTPException(
                    406, f"You must first promote an admin to owner before leaving")
    for group in groups:
        if group['id'] == DBgroup.admin_group_id:
            remove_user_from_group(user_id=get_user_info(
                token)['sub'], group_id=DBgroup.admin_group_id)
        if group['id'] == DBgroup.owner_group_id:
            remove_user_from_group(user_id=get_user_info(
                token)['sub'], group_id=DBgroup.owner_group_id)
    remove_user_from_group(user_id=get_user_info(
        token)['sub'], group_id=DBgroup.member_group_id)
    remove_user_from_group(user_id=get_user_info(
        token)['sub'], group_id=DBgroup.group_id)
    if len(group_members) == 1:
        delete_group(group_name=group_name)
        return {"message": "Successfully left and Successfully deleted the group"}
    return {"message": "User successfully left the group"}


@app.delete("/Group/{group_name}/Delete", tags=["groups"])
def delete_group(group_name: str, token: str = Depends(check_token_active)):
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found: {str(e)}")
    groups = get_user_groups(token)
    KCgroup = {}
    for group in groups:
        if group['id'] == DBgroup.owner_group_id:
            KCgroup = group
            break
    if KCgroup == {}:
        raise HTTPException(
            403, f"You are not an owner of group '{group_name}'")
    for event in DBgroup.events:
        for alliance in event.alliance_groups:
            leave_alliance(group_name=group_name, token=token,
                           event=event.event_code, other_group=alliance.name)
    join_requests = GroupJoinRequestCollection.delete_many(
        {"group_id": DBgroup.group_id})
    AllianceRequestCollection.delete_many(
        {"$or": [{"group_1": group_name}, {"group_2": group_name}]})
    GroupCollection.delete_one({"name": group_name})
    GroupDataCollection.delete_one({"group_id": DBgroup.group_id})
    GroupPitStatusCollection.delete_one({"group_id": DBgroup.group_id})
    GroupPredictionCollection.delete_one({"group_id": DBgroup.group_id})
    delete_group_kc(group_id=DBgroup.group_id)
    return {"message": "Group successfully deleted"}


@app.put("/MatchScouting/", tags=["scouting"])
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


@app.get("/{year}/{event}/{team}/getPictures", response_class=JSONResponse, tags=["scouting"])
async def get_pit_scouting_pictures(team: str, event: str, year: int):
    pictures = get_pictures(year=year, event=event, team=team)
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


@app.get("/{year}/{event}/getPictures", tags=["scouting"])
@cacheValue()
async def get_event_pictures(year: str, event: str):
    eventCode = str(year) + event
    # Query the collection using the key
    pictures = PictureCollection.find({"eventCode": eventCode})
    if not pictures:
        raise HTTPException(status_code=404, detail="Pictures not found")

    # Create a list of image data
    image_data = []
    for picture in pictures:
        content_type = picture["content_type"]
        file_content = picture["file"]
        team = picture["team"][3:]
        id = str(picture["_id"])
        # Encode the binary data as base64
        file_content_base64 = base64.b64encode(file_content).decode("utf-8")
        image_data.append({"content_type": content_type,
                          "file": file_content_base64, "_id": id, "team": team})

    # Return the list of image data as a JSON response
    return image_data


@app.post("/{year}/{event}/{team}/pictures/", tags=["scouting"])
def post_pit_scouting_pictures(data: UploadFile, team: str, event: str, year: int, token: str = Depends(check_token_active)):
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
        "scout_info": get_user_info(token)
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


@app.delete("/{year}/{event}/{team}/{password}/DeletePictures/", tags=["scouting"])
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


@app.get("/{year}/{event}/pitStatus", tags=["scouting"])
def get_pit_status(year: int, event: str):
    retval = PitStatusCollection.find_one({"event_code": str(year)+event})
    retval.pop("_id")
    return retval


@app.get("/{year}/{event}/{team}/ScoutEntries", tags=["scouting"])
@cacheValue()
def get_scout_team_entries(team: str, event: str, year: int):
    retval = list(ScoutingData2024Collection.find(
        {"event_code": str(year)+event, "team_number": team[3:]}))
    for entry in retval:
        entry.pop("_id")
    return retval


@app.get("/{year}/{event}/ScoutEntries", tags=["scouting"])
@cacheValue()
def get_scout_event_entries(event: str, year: int):
    retval = list(ScoutingData2024Collection.find(
        {"event_code": str(year)+event}))
    for entry in retval:
        entry.pop("_id")
    return retval


@app.get("/{year}/{event}/ScoutingData", tags=["scouting"])
@cacheValue()
def get_event_autos(year: int, event: str):
    autos = list(ScoutingData2024Collection.find(
        {"event_code": str(year)+event}))
    for auto in autos:
        auto.pop("_id")
    return autos


@app.post("/{year}/{event}/{team}/FollowUp", tags=["scouting"])
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


@app.get("/{year}/{event}/{team}/FollowUp", tags=["scouting"])
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


@app.get('/User/Groups', tags=["users"])
def get_user_groups(token: str = Depends(check_token_active)):
    user_data = get_user_info(token)
    userID = user_data["sub"]
    return find_user_groups(user_id=userID)


@app.get('/User/Groups/Detailed', tags=["users"], response_model=list[Group])
def get_user_groups_detailed(token: str = Depends(check_token_active)):
    kc_groups = get_user_groups(token=token)
    kc_root_groups = []
    for _kc_group in kc_groups:
        if len(_kc_group['path'].split('/')) == 2:
            kc_root_groups.append(_kc_group)
    kc_root_group_ids = [_kc_group['id'] for _kc_group in kc_root_groups]
    DBGroups = [Group(**DBGroup)
                for DBGroup in GroupCollection.find({"group_id": {"$in": kc_root_group_ids}})]
    returnGroups = []
    for DBGroup in DBGroups:
        isAdmin = False
        for _kc_group in kc_groups:
            if DBGroup.admin_group_id == _kc_group['id']:
                isAdmin = True
                break
        if isAdmin:
            returnGroups.append(DBGroup.dict())
        else:
            returnGroups.append(DBGroup.dict(exclude={'join_code'}))
    return returnGroups


@app.get('/User/GroupJoinRequests', tags=["users"], response_model=list[GroupJoinRequest])
def get_user_join_requests(token: str = Depends(check_token_active)):
    user_data = get_user_info(token)
    userID = user_data["sub"]
    requests = [GroupJoinRequest(
        **request).dict() for request in GroupJoinRequestCollection.find({"user_id": userID})]
    return requests


def convertData(calculatedData, year, event_code):
    keyStr = f"/year/{year}/event/{event_code}/teams/"
    keyList = [keyStr+"index"]
    try:
        rankings = ETagCollection.find_one({"key": event_code})["rankings"]
    except:
        rankings = [{"team_key": "frc"+str(team), "rank": 0}
                    for team in calculatedData["team_number"]]
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


def _getGroupMembers(group_id: str):
    try:
        DBgroup = Group(**GroupCollection.find_one({'group_id': group_id}))
    except Exception as e:
        print(group_id)
        print(e)
    owners = fetch_group_members(group_id=DBgroup.owner_group_id)
    admins = fetch_group_members(group_id=DBgroup.admin_group_id)
    members = fetch_group_members(group_id=DBgroup.member_group_id)
    pop_keys = ['totp', 'createdTimestamp', 'enabled', 'emailVerified',
                'disableableCredentialTypes', 'requiredActions', 'notBefore', ]
    for i in range(len(owners)):
        for pop_key in pop_keys:
            try:
                owners[i].pop(pop_key)
            except Exception as e:
                print(e)
    for i in range(len(admins)):
        for pop_key in pop_keys:
            try:
                admins[i].pop(pop_key)
            except Exception as e:
                print(e)
    for i in range(len(members)):
        for pop_key in pop_keys:
            try:
                members[i].pop(pop_key)
            except Exception as e:
                print(e)
    for admin in admins:
        if members.__contains__(admin):
            members.remove(admin)
    for owner in owners:
        if admins.__contains__(owner):
            admins.remove(owner)
    retval = {
        "owners": owners,
        "admins": admins,
        "members": members,
    }
    return retval


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
        logging.error(e)
    # if TBAData is not None:
    try:
        calculatedData, ratings = analyzeData([TBAData, ScoutingData])
        data = calculatedData.to_dict("list")
        data = convertData(data, YEAR, event_code)
    except Exception as e:
        logging.error(e)
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
                      "trap": 0, "auto_notes": 0, "climbing_points": 0, "climbing": 0, "mobility": 0, "death_rate": 0, "parking": 0, "auto_speaker": 0, "auto_amp": 0, "pass": 0, "teleop_speaker": 0, "teleop_amped_speaker": 0, "teleop_amp": 0, "harmony": 0, "mic": 0, "coopertition": 0, "simulated_rp": 0, "simulated_rank": 0} for team in teams])
    try:
        (data, predictions) = updatePredictions(TBAData, data, event_code)
        try:
            PredictionCollection.insert_one(
                {"event_code": event_code, "data": predictions})
        except Exception as e:
            try:
                PredictionCollection.find_one_and_replace({"event_code": event_code}, {
                    "event_code": event_code, "data": predictions})
            except Exception as ex:
                pass
    except Exception as e:
        logging.error(e)
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
        logging.error(e)
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
        logging.error(e)
    try:
        # print("Inserting data")
        CalculatedDataCollection.insert_one(
            {"event_code": event_code, "data": data, "metadata": metadata, "scout_ratings": ratings})
    except Exception as e:
        # logging.error(e)
        try:
            result = CalculatedDataCollection.update_one(
                {"event_code": event_code}, {'$set': {"data": data, "metadata": metadata, "scout_ratings": ratings}})
        except Exception as ex:
            print(ex)
            pass
    # TODO make it work without TBA Data and only scouting data


def updateGroupData(group: Group, event_code: str):
    TBAData = list(TBACollection.find({'event_key': event_code}))
    scouts = []
    numEntries = []
    for event in group.events:
        if event.event_code == event_code:
            users = _getGroupMembers(group.group_id)
            members = users['owners']
            members.extend(users['members'])
            members.extend(users['admins'])
            for alliance in event.alliance_groups:
                members.extend(_getGroupMembers(alliance.group_id))
            print(members)
            member_ids = [member["id"]
                          for member in members if isinstance(member, dict)]
            scoutingData = list(ScoutingData2024Collection.find(
                {"scout_info.id": {"$in": member_ids}}))
            try:
                calculatedData, ratings = analyzeData(
                    [TBAData, scoutingData])
                data = calculatedData.to_dict("list")
                data = convertData(data, YEAR, event_code)
            except Exception as e:
                logging.error(e)
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
                            "trap": 0, "auto_notes": 0, "climbing_points": 0, "climbing": 0, "mobility": 0, "death_rate": 0, "parking": 0, "auto_speaker": 0, "auto_amp": 0, "pass": 0, "teleop_speaker": 0, "teleop_amped_speaker": 0, "teleop_amp": 0, "harmony": 0, "mic": 0, "coopertition": 0, "simulated_rp": 0, "simulated_rank": 0} for team in teams])
            try:
                (data, predictions) = updatePredictions(
                    TBAData, data, event_code)
                try:
                    GroupPredictionCollection.insert_one(
                        {"event_code": event_code, "group_id": group.group_id, "data": predictions})
                except Exception as e:
                    try:
                        GroupPredictionCollection.find_one_and_replace({"event_code": event_code, "group_id": group.group_id}, {
                            "event_code": event_code, "group_id": group.group_id, "data": predictions})
                    except Exception as ex:
                        pass
            except Exception as e:
                logging.error(e)
                pass
            metadata = {"last_modified": datetime.utcnow().timestamp(),
                        "etag": None, "tba": False}
            try:
                # print("manufacturing scout rankings")
                ratings = {
                    "scouts": ratings["scouts"], "trustRatings": ratings["trustRatings"], "entries": []}
                ratings["entries"] = list(
                    numpy.zeros(len(ratings["scouts"])))
                for idx, scout in enumerate(ratings["scouts"]):
                    ratings["entries"][idx] = numEntries[scouts.index(
                        scout["name"])]
            except Exception as e:
                logging.error(e)
            try:
                prevData = GroupDataCollection.find_one(
                    {"event_code": event_code, "group_id": group.group_id})["data"][1:]
                for idx, team in enumerate(prevData):
                    for newTeam in data[1:]:
                        if team["key"] == newTeam["key"]:
                            for key in team:
                                if not newTeam.__contains__(key):
                                    newTeam[key] = team[key]
                                    # print(team[key])
                            break
            except Exception as e:
                logging.error(e)
            try:
                # print("Inserting data")
                GroupDataCollection.insert_one(
                    {"event_code": event_code, "group_id": group.group_id, "data": data, "metadata": metadata, "scout_ratings": ratings})
            except Exception as e:
                # logging.error(e)
                try:
                    result = GroupDataCollection.update_one(
                        {"event_code": event_code, "group_id": group.group_id}, {'$set': {"data": data, "metadata": metadata, "scout_ratings": ratings}})
                except Exception as ex:
                    print(ex)
                    pass


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
                if teamData != {}:
                    matchPrediction[f"{alliance}_score"] += teamData["OPR"]
                    matchPrediction[f"{alliance}_climbing"] += teamData["climbing"]
                    matchPrediction[f"{alliance}_auto_points"] += teamData["auto_points"]
                    matchPrediction[f"{alliance}_teleop_points"] += teamData["teleop_points"]
                    matchPrediction[f"{alliance}_endgame_points"] += teamData["endgame_points"] + \
                        teamData["harmony"]
                    matchPrediction[f"{alliance}_notes"] += teamData["notes"]
                    matchPrediction[f"{alliance}_coopertition"] += (
                        teamData["coopertition"]/3)

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
                    # logging.error(e)
                    pass
    sorted_list = sorted(
        calculatedData[1:], key=lambda x: x["simulated_rp"], reverse=True)
    for i, item in enumerate(sorted_list):
        sorted_list[i]["simulated_rank"] = int(i + 1)
    sorted_list.insert(0, calculatedData[0])
    return (sorted_list, matchPredictions)


@app.put("/{password}/Deactivate", tags=["scouting"])
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


@app.put("/{password}/Activate", tags=["scouting"])
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


@app.get("/", tags=["miscellaneous"])
def read_root():
    return {"polar": "forecast"}


@app.on_event("startup")
@repeat_every(seconds=float(TBA_POLLING_INTERVAL))
def update_database():
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
    logging.info("Starting Polar Forecast")
    groupsToUpdate = [
        Group(**group) for group in list(GroupCollection.find({"events.up_to_date": False}))]
    for group in groupsToUpdate:
        print(group.name)
        for event in group.events:
            print(event)
            if not event.up_to_date:
                try:
                    updateGroupData(group, event.event_code)
                    GroupCollection.update_one(
                        {'group_id': group.group_id}, {"$set": {"events.$[elem].up_to_date": True}}, array_filters=[{"elem.event_code": event.event_code}])
                except Exception as e:
                    print(e)
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
            except Exception as e:
                logging.error(e)

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
                # logging.error(e)
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
