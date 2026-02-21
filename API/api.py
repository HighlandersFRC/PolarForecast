import base64
from functools import wraps
import io
import json
import logging
import math
import random
import string
from types import TracebackType
from typing import Annotated
import uuid
import zipfile
from better_profanity import profanity
from bson import ObjectId
from fastapi import Depends, FastAPI, File, HTTPException, Header, UploadFile
from fastapi.responses import JSONResponse, StreamingResponse
import numpy
from pydantic import BaseModel
from pymongo import MongoClient
from datetime import datetime, timedelta
from fastapi.middleware.cors import CORSMiddleware
import pymongo
from models.tba_match_2026 import TBAMatch2026
from models.match_scouting_2026 import MatchScouting2026
from models.death_scouting_form import Death, DeathScoutingForm
from models.pit_scouting_status import PitScoutingStatus
from models.picture_data import PictureData
from models.pit_scouting_2026 import PitScouting2026
from models.alliance_request import AllianceRequest
from models.group import AllianceGroup, Group, GroupEvent, GroupEventSettings, GroupSettings
from models.group_join_request import GroupJoinRequest
from auth import add_user_to_group, check_token_active, create_join_code, delete_group_kc, fetch_group_members, find_user_groups, get_token_active, get_user_info, make_group, remove_user_from_group, scout_info_from_id, scout_info_from_token
from GeneticPolar import analyzeData
from config import EDIT_PASSWORD, TBA_POLLING_INTERVAL, TBA_API_KEY, TBA_API_URL, MONGO_CONNECTION, ALLOW_ORIGINS, get_blob_storage_client, get_redis_client
import requests
from fastapi_utils.tasks import repeat_every
from StatDescription import stat_description
from azure.storage.blob import generate_blob_sas, BlobSasPermissions, PublicAccess
from fastapi.exceptions import RequestValidationError



logging.basicConfig(format="%(levelname)s:%(message)s", level=logging.DEBUG)
logging.info("Initialized Logger")

YEAR = '2026'
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

@app.exception_handler(RequestValidationError)
async def handler(_, exc):
    print(exc.errors())
    raise


# Set Up the Database
client = MongoClient(MONGO_CONNECTION)
testDB = client["Igloo"]

testCollection = testDB["Test"]

TBACollection = testDB["TBA"]
TBACollection.create_index([("key", pymongo.ASCENDING)], unique=True)

MatchScoutingCollection = testDB["Scouting2026Data"]
MatchScoutingCollection.create_index([("event_code", pymongo.ASCENDING), (
    "team_number", pymongo.ASCENDING), ("scout_info.user_id", pymongo.ASCENDING), ("match_number", pymongo.ASCENDING)], unique=True)

PictureCollection = testDB["Pictures"]
PictureCollection.create_index([("key", pymongo.ASCENDING)], unique=False)

PitScoutingCollection = testDB["PitScouting"]
PitScoutingCollection.create_index(
    [("event_code", pymongo.ASCENDING), ("team_number", pymongo.ASCENDING), ("scout_info.user_id", pymongo.ASCENDING)], unique=True)

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
    [("event_code", pymongo.ASCENDING), ("team_key", pymongo.ASCENDING), ("scout_info.user_id", pymongo.ASCENDING)], unique=True)

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

GlobalRankingsCollection = testDB['GlobalRankings']
GlobalRankingsCollection.create_index(
    [("team", pymongo.ASCENDING)], unique=True)

redisClient = get_redis_client()
azureClient = get_blob_storage_client()
try:
    try:
        azureClient.create_container("highlanderscouting")
    except Exception as e:
        print(e)
        pass
    RobotPicturesClient = azureClient.get_container_client(
        container="highlanderscouting")
except Exception as e:
    print(e)
    pass


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


@cacheValue()
def getEventTeams(event_code: str):
    return ETagCollection.find_one({"key": event_code})["teams"]


@cacheValue()
def getEventRankings(event_code: str):
    return ETagCollection.find_one({"key": event_code})["rankings"]


@cacheValue()
def join_code(group_name):
    DBEntry = Group(**GroupCollection.find_one({"name": group_name}))
    if (DBEntry.join_code_expiration < datetime.now().timestamp()):
        new_code = create_join_code()
        GroupCollection.find_one_and_update(
            {"name": group_name}, {"$set": {"join_code": new_code, "join_code_expiration": int((datetime.now()+timedelta(days=7)).timestamp())}})
        return new_code
    else:
        return DBEntry.join_code


@app.get("/{year}/{event}/{team}/stats", tags=["stats"])
def get_event_Team_Stats(year: int, event: str, team: str, token: str = Header(None)):
    event_code = str(year) + event
    foundTeam = False
    data = None # Initialize to None

    if (token == None):
        data = getEventCalculatedData(event_code)
    else:
        if get_token_active(token=token):
            groups = [Group(**group) for group in get_user_groups_detailed(token=token)]
            foundGroup = False
            for group in groups:
                if event_code in [x.event_code for x in group.events]:
                    data = getGroupCalculatedData(event_code, group.group_id)
                    if data != None:
                        foundGroup = True
                        break
            if not foundGroup:
                data = getEventCalculatedData(event_code)
        else:
            data = getEventCalculatedData(event_code)

    # --- ADD THIS CHECK HERE ---
    if data is None or "data" not in data:
        raise HTTPException(404, f"No data found for event {event_code}")
    # ---------------------------

    for doc in data["data"][1:]:   # skip first metadata object
        if doc.get("key") == team:
            return doc

    raise HTTPException(404, f"No team key '{team}' in {event_code}")
        


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
    event_code = str(year)+event
    if (token == None):
        data = getEventCalculatedData(event_code)
    else:
        if get_token_active(token=token):
            groups = [Group(**group)
                      for group in get_user_groups_detailed(token=token)]
            foundGroup = False
            for group in groups:
                if event_code in [x.event_code for x in group.events]:
                    data = getGroupCalculatedData(event_code, group.group_id)
                    if data != None:
                        foundGroup = True
                    break
            if not foundGroup:
                data = getEventCalculatedData(event_code)
        else:
            data = getEventCalculatedData(event_code)
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
@cacheValue(seconds=60*60*24)  # Cache it for a day
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
    event_code = str(year)+event
    try:
        if (token == None):
            data = getEventPredictions(event_code)
        else:
            if get_token_active(token=token):
                groups = [Group(**group)
                          for group in get_user_groups_detailed(token=token)]
                foundGroup = False
                for group in groups:
                    if event_code in [x.event_code for x in group.events]:
                        data = getGroupPredictions(
                            event_code, group.group_id)
                        if data != None:
                            foundGroup = True
                        break
                if not foundGroup:
                    data = getEventPredictions(event_code)
            else:
                data = getEventPredictions(event_code)
        data.pop("_id")
        return {"data": data["data"]}
    except Exception as e:
        print(e)
        return {"data": []}


@app.get("/{year}/{event}/{match_key}/match_details", tags=["stats"])
def get_match_details(year: int, event: str, match_key: str, token: str = Header(None)):
    try:
        event_code = str(year)+event
        tbaMatch = TBACollection.find_one({"key": match_key})
        tbaMatch.pop("_id")
        matchPrediction = None
        blueTeamStats = []
        redTeamStats = []
        try:
            if (token == None):
                eventPredictions = getEventPredictions(event_code)
            else:
                if get_token_active(token=token):
                    groups = [Group(**group)
                              for group in get_user_groups_detailed(token=token)]
                    foundGroup = False
                    for group in groups:
                        if event_code in [x.event_code for x in group.events]:
                            eventPredictions = getGroupPredictions(
                                event_code, group.group_id)
                            if eventPredictions != None:
                                foundGroup = True
                            break
                    if not foundGroup:
                        eventPredictions = getEventPredictions(event_code)
                else:
                    eventPredictions = getEventPredictions(event_code)
            for prediction in eventPredictions["data"]:
                if prediction["key"] == match_key:
                    matchPrediction = prediction
                    break
            for team in matchPrediction["blue_teams"]:
                blueTeamStats.append(
                    get_event_Team_Stats(year, event, team, token))
            for team in matchPrediction["red_teams"]:
                redTeamStats.append(
                    get_event_Team_Stats(year, event, team, token))
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
        data = getEventPredictions(event_code)
    else:
        if get_token_active(token=token):
            groups = [Group(**group)
                      for group in get_user_groups_detailed(token=token)]
            foundGroup = False
            for group in groups:
                if event_code in [x.event_code for x in group.events]:
                    data = getGroupPredictions(
                        event_code, group.group_id)
                    if data != None:
                        foundGroup = True
                    break
            if not foundGroup:
                data = getEventPredictions(event_code)
        else:
            data = getEventPredictions(event_code)
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


@app.get(
    "/{year}/{event}/{team}/PitScouting",
    tags=["scouting"],
    response_model=PitScouting2026
)
def get_pit_scouting_data(
    year: int,
    event: str,
    team: str,
    token=Depends(check_token_active)
):
    user_info = get_user_info(token=token)
    event_code = f"{year}{event}"

    data = PitScoutingCollection.find_one({
        "event_code": event_code,
        "team_number": int(team[3:]),
        "scout_info.user_id": user_info["sub"]
    })

    if not data:
        # Instead of returning None, return an empty dict
        return {
            "scout_info": scout_info_from_token(token),
            "team_number": int(team[3:]),
            "time": 0,
            "event_code": event_code,
            "data": {},  # empty PitData2026 placeholder
            "user_id": "",
            "auto": {}
        }

    return PitScouting2026(**data)



@app.get("/{year}/{event}/PitScoutingStatus", tags=["scouting"])
def get_pit_scouting_status(year: int, event: str, token: str = Depends(check_token_active)):
    groups = [Group(**group)
              for group in get_user_groups_detailed(token=token)]
    if (len(groups) == 0):
        raise HTTPException(400, "You are not part of any groups")
    group = groups[0]
    data = GroupPitStatusCollection.find_one(
        {'event_code': str(year) + event, 'group_id': group.group_id})
    data.pop("_id")
    return data

@app.post("/PitScouting/", tags=["scouting"])
def post_pit_scouting_data(
    data: PitScouting2026,
    token: str = Depends(check_token_active)
):
    # ---- Server-controlled fields ----
    data.time = int(datetime.utcnow().timestamp())
    data.scout_info = scout_info_from_token(token)

    # ---- Sanitize user-entered strings ----
    data.data.favorite_color = profanity.censor(
        data.data.favorite_color
    )

    # ---- Validate event + team ----
    try:
        teams = getEventTeams(data.event_code)
    except Exception:
        raise HTTPException(404, "Event does not exist")

    teams = [team[3:] for team in teams]  # strip 'frc'
    team = str(data.team_number) # Temporary hardcoded team number for testing; replace with data.team_number in production

    if team not in teams:
        raise HTTPException(
            400,
            f"No team key '{data.team_number}' in {data.event_code}"
        )

    # ---- Debug: Print what we're trying to insert ----
    print(f"Attempting to insert/update pit scouting data:")
    print(f"Event: {data.event_code}")
    print(f"Team: {data.team_number}")
    print(f"User ID: {data.scout_info.user_id}")
    
    # Convert to dict for MongoDB
    data_dict = data.dict()
    print(f"Data to insert: {data_dict}")

    # ---- Check if entry already exists ----
    existing_entry = PitScoutingCollection.find_one({
        "event_code": data.event_code,
        "team_number": data.team_number,
        "scout_info.user_id": data.scout_info.user_id
    })
    
    if existing_entry:
        print(f"Entry exists, updating...")
        # Update existing entry
        result = PitScoutingCollection.update_one(
            {
                "event_code": data.event_code,
                "team_number": data.team_number,
                "scout_info.user_id": data.scout_info.user_id
            },
            {"$set": data_dict}
        )
        print(f"Update result: matched={result.matched_count}, modified={result.modified_count}")
    else:
        print(f"No existing entry, inserting new...")
        # Insert new entry
        try:
            result = PitScoutingCollection.insert_one(data_dict)
            print(f"Insert result: inserted_id={result.inserted_id}")
        except pymongo.errors.DuplicateKeyError as e:
            print(f"Duplicate key error: {e}")
            # Try to update if duplicate (race condition)
            result = PitScoutingCollection.update_one(
                {
                    "event_code": data.event_code,
                    "team_number": data.team_number,
                    "scout_info.user_id": data.scout_info.user_id
                },
                {"$set": data_dict},
                upsert=True
            )
            print(f"Upsert after duplicate: matched={result.matched_count}, modified={result.modified_count}, upserted_id={result.upserted_id}")

    # ---- Verify the data was saved ----
    saved_data = PitScoutingCollection.find_one({
        "event_code": data.event_code,
        "team_number": data.team_number,
        "scout_info.user_id": data.scout_info.user_id
    })
    
    if saved_data:
        print(f"✅ Data successfully saved: {saved_data.get('_id')}")
    else:
        print(f"❌ Data NOT saved - check MongoDB error logs")
        raise HTTPException(500, "Failed to save data to database")

    # ---- Get user's groups ----
    groups = [
        Group(**group)
        for group in get_user_groups_detailed(token=token)
    ]
    
    print(f"User belongs to {len(groups)} groups")

    # ---- Update groups ----
    for group in groups:
        print(f"Processing group: {group.name}")
        try:
            # Check if this group is tracking this event
            for event in group.events:
                if event.event_code == data.event_code:
                    print(f"  Updating status for event: {event.event_code}")
                    updateGroupStatus(group, data.event_code)
                    updateGroupGridPitData(group, data.event_code)
                    break
            else:
                print(f"  Group {group.name} is not tracking event {data.event_code}")
        except Exception as e:
            print(f"  Error updating group {group.name}: {str(e)}")
            import traceback
            traceback.print_exc()
            continue

    return {"message": "Successfully saved pit scouting data"}






def getStatus(data: PitScouting2026, originalStatus: dict):
    status = "Incomplete"
    found = False

    # ---- Determine pit completion ----
    if data.data.drive_train:
        status = "Done"

    # ---- Update team entry ----
    for entry in originalStatus.get("data", []):
        if entry.get("key") == str(data.team_number):
            found = True
            entry["pit_status"] = status
            break

    if not found:
        raise HTTPException(400, "No Such Team")

    return originalStatus


def updateGroupData(group: Group, event_code: str, event_type: int):
    TBAData = [TBAMatch2026(**x) for x in TBACollection.find({'event_key': event_code})]

    for event in group.events:
        if event.event_code == event_code:
            members = fetch_group_members(group.group_id)
            member_ids = [member['id'] for member in members]

            # Fetch alliance members
            alliance_members = []
            for groupEvent in group.events:
                if groupEvent.event_code == event_code:
                    for alliance in groupEvent.alliance_groups:
                        alliance_members.extend(fetch_group_members(alliance.group_id))
            alliance_member_ids = [member['id'] for member in alliance_members]

            # Fetch match scouting entries
            member_entries = [MatchScouting2026(**entry) for entry in MatchScoutingCollection.find({
                'event_code': event_code, 'scout_info.user_id': {'$in': member_ids}
            })]

            alliance_entries = [MatchScouting2026(**entry) for entry in MatchScoutingCollection.find({
                'event_code': event_code, 'scout_info.user_id': {'$in': alliance_member_ids}
            })]

            try:
                calculatedData, ratings = analyzeData(TBAData, member_entries + alliance_entries)
                print("analyzed")
                data = calculatedData.to_dict("list")
                data = convertData(data, 2026, event_code)
            except Exception as e:
                logging.error(e)
                ratings = {"scouts": [], "trustRatings": []}

                keyStr = f"/year/2026/event/{event_code}/teams/"
                keyList = [keyStr + "index"]

                etagData = ETagCollection.find_one({"key": event_code})
                teams = etagData["teams"]
                for team in teams:
                    keyList.append(keyStr + team[3:])

            
                retval0 = {"data": {"keys": keyList}}
                data = [retval0]
                data.extend([{
                    "historical": False,
                    "key": team,
                    "rank": 0,
                    "team_number": team[3:],
                    "match_count": 0,
                    "OPR": 0,
                    "endgame_points": 0,
                    "teleop_points": 0,
                    "auto_points": 0,
                    "climbing_points": 0,
                    "total_pieces": 0,
                    "auto_scoring": {},
                    "teleop_scoring": {},
                    "mobility": 0,
                    "foul_points": 0,
                    "death_rate": 0,
                    "parking": 0,
                    "coopertition": 0,
                    "simulated_rp": 0,
                    "simulated_rank": 0
                } for team in teams])

            try:
                data, predictions = updatePredictions(TBAData, data, eventType=event_type)
                try:
                    GroupPredictionCollection.insert_one({
                        "event_code": event_code,
                        "group_id": group.group_id,
                        "data": predictions
                    })
                except Exception:
                    GroupPredictionCollection.find_one_and_replace(
                        {"event_code": event_code, "group_id": group.group_id},
                        {"event_code": event_code, "group_id": group.group_id, "data": predictions}
                    )
            except Exception as e:
                logging.error(e)
                pass

            metadata = {"last_modified": datetime.utcnow().timestamp(), "etag": None, "tba": False}

            try:
                # Ratings calculation
                ratings = {
                    "scouts": [scout_info_from_id(scout_id).dict() for scout_id in ratings["scouts"]],
                    "trustRatings": ratings["trustRatings"],
                    "entries": list(numpy.zeros(len(ratings["scouts"]))),
                    "contribution": list(numpy.zeros(len(ratings["scouts"])))
                }
                for idx, scout in enumerate(ratings["scouts"]):
                    for entry in member_entries + alliance_entries:
                        if entry.scout_info.user_id == scout['user_id']:
                            ratings["entries"][idx] += 1
                    ratings["contribution"][idx] = (ratings["trustRatings"][idx] ** 2) * ratings["entries"][idx]
            except Exception as e:
                logging.error(e)

            try:
                GroupDataCollection.insert_one({
                    "event_code": event_code,
                    "group_id": group.group_id,
                    "data": data,
                    "metadata": metadata,
                    "scout_ratings": ratings
                })
            except Exception:
                GroupDataCollection.find_one_and_replace(
                    {"event_code": event_code, "group_id": group.group_id},
                    {"event_code": event_code, "group_id": group.group_id, "data": data, "metadata": metadata, "scout_ratings": ratings}
                )

            break



def updateGroupStatus(group: Group, event_code: str):
    statuses: list[PitScoutingStatus] = []

    # ---- Initialize all teams ----
    teams = getEventTeams(event_code)
    for team in teams:
        statuses.append(
            PitScoutingStatus(
                key=team[3:],
                pit_status="Not Started",
                picture_status="Not Started",
                follow_up_status="Not Started",
            )
        )

    # ---- Gather group + alliance members ----
    members = fetch_group_members(group.group_id)
    for event in group.events:
        if event.event_code == event_code:
            for alliance in event.alliance_groups:
                members.extend(fetch_group_members(alliance.group_id))

    member_ids = [member["id"] for member in members]

    # ---- Load scouting data (2026) ----
    pitScoutingEntries = [
        PitScouting2026(**entry)
        for entry in PitScoutingCollection.find(
            {"event_code": event_code, "scout_info.user_id": {"$in": member_ids}}
        )
    ]

    # FIXED: Handle float time values for MatchScouting2026
    matchScoutingEntries = []
    for entry in MatchScoutingCollection.find(
        {"event_code": event_code, "scout_info.user_id": {"$in": member_ids}}
    ):
        # Convert float time to int if needed
        if "time" in entry and isinstance(entry["time"], float):
            entry["time"] = int(entry["time"])
        try:
            matchScoutingEntries.append(MatchScouting2026(**entry))
        except Exception as e:
            print(f"Error parsing match scouting entry: {e}")
            continue

    # FIXED: Handle float time values for DeathScoutingForm
    followUpScoutingEntries = []
    for entry in FollowUpCollection.find(
        {"event_code": event_code, "scout_info.user_id": {"$in": member_ids}}
    ):
        # Convert float time to int if needed
        if "time" in entry and isinstance(entry["time"], float):
            entry["time"] = int(entry["time"])
        try:
            followUpScoutingEntries.append(DeathScoutingForm(**entry))
        except Exception as e:
            print(f"Error parsing follow-up entry: {e}")
            continue

    # FIXED: Handle float time values for PictureData
    pictures = []
    for entry in PictureCollection.find(
        {"event_code": event_code, "scout_info.user_id": {"$in": member_ids}}
    ):
        # Convert float time to int if needed
        if "time" in entry and isinstance(entry["time"], float):
            entry["time"] = int(entry["time"])
        try:
            pictures.append(PictureData(**entry))
        except Exception as e:
            print(f"Error parsing picture entry: {e}")
            continue

    # ---- Compute status per team ----
    for status in statuses:
        team_number = int(status.key)

        # ===== PIT SCOUTING =====
        teamPitEntries = [
            x for x in pitScoutingEntries if x.team_number == team_number
        ]

        if teamPitEntries:
            latestEntry = max(teamPitEntries, key=lambda x: x.time)

            if (
                latestEntry.data.drive_train
                and latestEntry.data.favorite_color
            ):
                status.pit_status = "Done"
            else:
                status.pit_status = "Incomplete"
        else:
            status.pit_status = "Not Started"

        # ===== FOLLOW-UP SCOUTING =====
        teamFollowUps = [
            x for x in followUpScoutingEntries
            if x.team_key == f"frc{status.key}"
        ]

        deathMatches = [
            x for x in matchScoutingEntries
            if x.data.miscellaneous.died and x.team_number == team_number
        ]

        if teamFollowUps:
            latestFollowUp = max(teamFollowUps, key=lambda x: x.time)
            status.follow_up_status = "Done"

            for match in deathMatches:
                if match.match_number not in [
                    death.match_number
                    for death in latestFollowUp.deaths
                    if death.death_reason != ""
                ]:
                    status.follow_up_status = "Incomplete"
                    break
        else:
            if not deathMatches:
                status.follow_up_status = "Done"
            else:
                status.follow_up_status = "Not Started"

        # ===== PICTURES =====
        teamPictures = [
            x for x in pictures if x.team_number == team_number
        ]

        if teamPictures:
            image_types = {pic.image_type for pic in teamPictures}

            if {"full_robot", "manipulator", "wires"} <= image_types:
                status.picture_status = "Done"
            else:
                status.picture_status = "Incomplete"
        else:
            status.picture_status = "Not Started"

    # ---- Store group status ----
    GroupPitStatusCollection.update_one(
        {"event_code": event_code, "group_id": group.group_id},
        {"$set": {"data": [x.dict() for x in statuses]}},
        upsert=True
    )



def updateGroupGridPitData(group: Group, event_code: str):
    data = GroupDataCollection.find_one(
        {"group_id": group.group_id, "event_code": event_code}
    )

    if not data or "data" not in data:
        return

    # ---- Gather group + alliance members ----
    members = fetch_group_members(group.group_id)
    for event in group.events:
        if event.event_code == event_code:
            for alliance in event.alliance_groups:
                members.extend(fetch_group_members(alliance.group_id))

    member_ids = [member["id"] for member in members]

    # ---- Load pit scouting (2026) ----
    pitEntries = [
        PitScouting2026(**entry)
        for entry in PitScoutingCollection.find(
            {"event_code": event_code, "scout_info.user_id": {"$in": member_ids}}
        )
    ]

    # ---- Update grid rows per team ----
    for doc in data["data"]:
        if "key" not in doc:
            continue

        team_number = int(doc["key"])

        teamPitEntries = [
            x for x in pitEntries if x.team_number == team_number
        ]

        if not teamPitEntries:
            continue

        latestEntry = max(teamPitEntries, key=lambda x: x.time)
        dictEntry = latestEntry.data.dict()

        for key, value in dictEntry.items():
            if key != "_id":
                doc[key] = value

    # ---- Persist updates ----
    GroupDataCollection.update_one(
        {"group_id": group.group_id, "event_code": event_code},
        {"$set": {"data": data["data"]}}
    )



numRuns = 0


@app.post("/MatchScouting/", tags=["scouting"])
def post_match_scouting(
    data: MatchScouting2026,
    token: str = Depends(check_token_active)
):
    # ---- Server-controlled fields ----
    data.scout_info = scout_info_from_token(token)
    data.time = int(datetime.utcnow().timestamp())

    eventCode = data.event_code
    matchNumber = data.match_number
    teamNumber = data.team_number

    # ---- Fetch match from TBA cache ----
    match = TBACollection.find_one(
        {"key": f"{eventCode}_qm{matchNumber}"}
    )

    # ---- Sanitize comments ----
    data.data.miscellaneous.comments = profanity.censor(
        data.data.miscellaneous.comments
    )

    if match is None:
        raise HTTPException(400, "Check Your Match Number")

    # ---- Validate team is in match ----
    exists = False
    for allianceStr in ("blue", "red"):
        if f"frc{teamNumber}" in match["alliances"][allianceStr]["team_keys"]:
            exists = True
            break

    if not exists:
        eventTeams = getEventTeams(eventCode)
        if str(teamNumber) in [team[3:] for team in eventTeams]:
            raise HTTPException(400, "Check Your Match And Team Number")
        else:
            raise HTTPException(400, "Check Your Team Number")

    # ---- Insert match scouting ----
    try:
        MatchScoutingCollection.insert_one(data.dict())
    except pymongo.errors.DuplicateKeyError:
        raise HTTPException(status_code=307, detail="Duplicate Entry")

    # ---- Determine affected groups ----
    groups = [
        Group(**group)
        for group in get_user_groups_detailed(token=token)
    ]

    groupsNeedingUpdate = (
        [
            Group(**group)
            for group in GroupCollection.find({
                "events": {
                    "$elemMatch": {
                        "event_code": data.event_code,
                        "alliance_groups.group_id": {
                            "$in": [g.group_id for g in groups]
                        }
                    }
                }
            })
        ]
        + groups
    )

    # ---- Update group pit/follow-up status if robot died ----
    if data.data.miscellaneous.died:
        for group in groupsNeedingUpdate:
            try:
                updateGroupStatus(group, data.event_code)
            except Exception:
                pass

    # ---- Re-run analysis for all affected groups ----
    for group in groupsNeedingUpdate:
        primeGroupForAnalysis(
            group=group,
            event_code=data.event_code
        )

    return data.dict()


@app.post("/MatchScouting/Offline/", tags=["scouting"])
def post_offline_match_scouting(
    data: MatchScouting2026,
    token: str = Depends(check_token_active)
):
    # ---- Auth / permission check ----
    user_info = get_user_info(token)

    user_groups = [group["id"] for group in get_user_groups(token)]
    scout_groups = [
        group["id"]
        for group in find_user_groups(user_id=data.scout_info.user_id)
    ]

    if not any(group in user_groups for group in scout_groups):
        raise HTTPException(
            403,
            "You can only submit match scouting data for members of your group"
        )

    # ---- Server-controlled fields ----
    data.time = int(datetime.utcnow().timestamp())

    eventCode = data.event_code
    matchNumber = data.match_number
    teamNumber = data.team_number

    # ---- Fetch match from TBA cache ----
    match = TBACollection.find_one(
        {"key": f"{eventCode}_qm{matchNumber}"}
    )

    # ---- Sanitize comments ----
    data.data.miscellaneous.comments = profanity.censor(
        data.data.miscellaneous.comments
    )

    if match is None:
        raise HTTPException(400, "Check Your Match Number")

    # ---- Validate team is in match ----
    exists = False
    for allianceStr in ("blue", "red"):
        if f"frc{teamNumber}" in match["alliances"][allianceStr]["team_keys"]:
            exists = True
            break

    if not exists:
        eventTeams = getEventTeams(eventCode)
        if str(teamNumber) in [team[3:] for team in eventTeams]:
            raise HTTPException(400, "Check Your Match And Team Number")
        else:
            raise HTTPException(400, "Check Your Team Number")

    # ---- Insert or replace match scouting ----
    try:
        MatchScoutingCollection.insert_one(data.dict())
    except pymongo.errors.DuplicateKeyError:
        MatchScoutingCollection.find_one_and_replace(
            {
                "event_code": data.event_code,
                "match_number": data.match_number,
                "team_number": data.team_number,
                "scout_info.user_id": data.scout_info.user_id,
            },
            data.dict(),
            upsert=True
        )

    # ---- Determine affected groups ----
    groups = [
        Group(**group)
        for group in get_user_groups_detailed(token=token)
    ]

    groupsNeedingUpdate = (
        [
            Group(**group)
            for group in GroupCollection.find({
                "events": {
                    "$elemMatch": {
                        "event_code": data.event_code,
                        "alliance_groups.group_id": {
                            "$in": [g.group_id for g in groups]
                        }
                    }
                }
            })
        ]
        + groups
    )

    # ---- Update group status if robot died ----
    if data.data.miscellaneous.died:
        for group in groupsNeedingUpdate:
            try:
                updateGroupStatus(group, data.event_code)
            except Exception:
                pass

    # ---- Re-run analysis ----
    for group in groupsNeedingUpdate:
        primeGroupForAnalysis(
            group=group,
            event_code=data.event_code
        )

    return data.dict()


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
    # if m_event is None:
    #     raise HTTPException(
    #         400, f"Your Group is not part of event '{event}'")
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
    updateGroupStatus(DB_group, alliance_request.event)
    updateGroupGridPitData(DB_group, alliance_request.event)
    updateGroupStatus(DB_other_group, alliance_request.event)
    updateGroupGridPitData(DB_other_group, alliance_request.event)
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
    updateGroupStatus(DB_Entry, alliance.event)
    updateGroupGridPitData(DB_Entry, alliance.event)
    updateGroupStatus(DB_other_group, alliance.event)
    updateGroupGridPitData(DB_other_group, alliance.event)
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
def delete_alliance_request(group_name: str, event: str, token: str = Depends(check_token_active), alliance_request: AllianceRequest | None = None):
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
        crowd_sourced_match_scouting=False, crowd_sourced_pit_scouting=False), up_to_date=False, alliance_groups=[])
    DB_Entry.events.append(new_event)
    GroupCollection.find_one_and_update(
        {"name": group_name}, {'$set': {"events": [event.dict() for event in DB_Entry.events]}})
    updateGroupStatus(DB_Entry, event)
    updateGroupData(DB_Entry, event)
    updateGroupGridPitData(DB_Entry, event)
    return get_group(group_name=group_name, token=token)


@app.delete("/Group/{group_name}/Event/{event}/Remove", tags=["groups"])
def remove_event_from_group(group_name: str, event: str, token: str = Depends(check_token_active)):
    try:
        DB_Entry = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(
            404, "This group does not exist")
    if event not in [event.event_code for event in DB_Entry.events]:
        raise HTTPException(
            400, f"This group is not part of an event with the code '{event}'")
    groupEvent = [x for x in DB_Entry.events if x.event_code == event][0]
    kc_groups = get_user_groups(token=token)
    admin = False
    for kc_group in kc_groups:
        if kc_group["id"] == DB_Entry.admin_group_id:
            admin = True
            break
    if not admin:
        raise HTTPException(
            401, "You must be an admin of this group to remove events")
    for alliance in groupEvent.alliance_groups:
        leave_alliance(group_name=group_name, token=token,
                       event=event, other_group=alliance.name)
    allianceRequests = get_group_alliance_requests(
        group_name=group_name, token=token)
    for allianceRequest in allianceRequests:
        delete_alliance_request(group_name=group_name, event=event,
                                token=token, alliance_request=AllianceRequest(**allianceRequest))
    DB_Entry.events = [
        x for x in DB_Entry.events if x.event_code != event]
    GroupCollection.find_one_and_update(
        {"name": group_name}, {'$set': {"events": [event.dict() for event in DB_Entry.events]}})
    return get_group(group_name=group_name, token=token)


@app.post("/CreateGroup", tags=["groups"])
def create_group(group_name: str | None = None, token: str = Depends(check_token_active), event: str | None = None) -> Group:
    if len(get_user_groups(token)) != 0:
        HTTPException(400, "You are already part of a group")
    if group_name == None:
        raise HTTPException(400, "Please provide a group name")
    for char in group_name:
        if char not in string.ascii_lowercase+string.ascii_uppercase+string.digits:
            raise HTTPException(
                400, "Make sure your group name has no special characters (no spaces)")
    if profanity.contains_profanity(group_name):
        raise HTTPException(400, "Do not use profanity in a group name")
    user_info = get_user_info(token)
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
                events=[],
                settings=GroupSettings(
                    approve_new_members=True,
                ),
            )
    except KeyError:
        raise HTTPException(
            422, "Your User is Not Affiliated with a team. Contact the developers for help.")
    GroupCollection.insert_one(DBEntry.dict())
    if (event is not None):
        add_event_to_group(group_name=group_name, event=event, token=token)
    return DBEntry


@app.get("/{year}/{event}/Groups", tags=["groups"])
def get_event_groups(year: int, event: str, token: str = Depends(check_token_active)):
    eventCode = f"{year}{event}"
    eventGroups = GroupCollection.find(
        {"events.event_code": eventCode})
    return [Group(**group).dict(exclude={"join_code", "settings", "events", "owner_group_id", "admin_group_id", "member_group_id", "group_id"}) for group in eventGroups]


@app.get("/Group/{group_name}/Event/{event_code}/ScoutingReport", tags=["groups"])
def get_group_event_scouting_report(group_name: str, event_code: str, token: str = Depends(check_token_active)):
    try:
        DB_group = Group(**GroupCollection.find_one({"name": group_name}))
    except:
        raise HTTPException(404, "This group does not exist")
    kc_groups = get_user_groups(token=token)
    member = False
    for kc_group in kc_groups:
        if kc_group["id"] == DB_group.member_group_id:
            member = True
            break
    if not member:
        raise HTTPException(
            403, "You are not a member of this group")
    group_reports = GroupDataCollection.find({
        "group_id": DB_group.group_id,
        "event_code": event_code
    })

    report_entries = []

    for report in group_reports:
        
        scout_ratings = report.get("scout_ratings", {})
        scouts = scout_ratings.get("scouts", [])
        trust = scout_ratings.get("trustRatings", [])
        entries = scout_ratings.get("entries", [])
        contribution = scout_ratings.get("contribution", [])

        for i in range(len(scouts)):
            if str(scouts[i]["team_number"]) == DB_group.affiliation[3:]:
                report_entries.append({
                    "scout": scouts[i],
                    "eventCode": report.get("event_code", ""),
                    "groupId": report.get("group_id", ""),
                    "trustRatings": trust[i] if i < len(trust) else 0.0,
                    "entries": entries[i] if i < len(entries) else 0,
                    "contribution": contribution[i] if i < len(contribution) else 0.0
                })
            else:
                report_entries.append({
                    "scout": {
                        "team_number": scouts[i]["team_number"],
                        "user_id": scouts[i]["user_id"],
                    },
                    "eventCode": report.get("event_code", ""),
                    "groupId": report.get("group_id", ""),
                    "trustRatings": trust[i] if i < len(trust) else 0.0,
                    "entries": entries[i] if i < len(entries) else 0,
                    "contribution": contribution[i] if i < len(contribution) else 0.0
                })
    return {
        "group": group_name,
        "event": event_code,
        "report": report_entries
    }



@app.get("/Group/{group_name}", tags=["groups"])
def get_group(group_name: str, token: str = Depends(check_token_active)):
    try:
        DBgroup = Group(**GroupCollection.find_one({"name": group_name}))
    except Exception as e:
        raise HTTPException(404, f"Group Not Found")
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
            retval['group']['join_code'] = join_code(group_name)
        return retval
    raise HTTPException(
        400, f"You somehow broke Polar Forecast's '{group_name}' Group")


@app.post("/Group/{group_name}/Join", tags=["groups"], response_model=list[GroupJoinRequest])
def join_group(group_name: str, join_code: str, token: str = Depends(check_token_active)):
    groups = get_user_groups(token)
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
    for event in DB_group.events:
        updateGroupStatus(group=DB_group, event_code=event.event_code)
        updateGroupGridPitData(group=DB_group, event_code=event.event_code)
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
    for event in DBgroup.events:
        updateGroupStatus(group=DBgroup, event_code=event.event_code)
        updateGroupGridPitData(group=DBgroup, event_code=event.event_code)
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
    group_members = fetch_group_members(DBgroup.group_id)
    if len(group_members) != 1:
        for group in groups:
            if group['id'] == DBgroup.owner_group_id:
                raise HTTPException(
                    406, f"You must first promote an admin to owner before leaving")
    else:
        delete_group(group_name=group_name, token=token)
        return {"message": "Successfully left and Successfully deleted the group"}
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
    GroupJoinRequestCollection.delete_one(
        {"user_id": get_user_info(token)['sub'], "group_name": group_name})
    for event in DBgroup.events:
        updateGroupStatus(group=DBgroup, event_code=event.event_code)
        updateGroupGridPitData(group=DBgroup, event_code=event.event_code)
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
def update_match_scouting(data: MatchScouting2026, token: str = Depends(check_token_active)):
    data.scout_info = scout_info_from_token(token=token)
    oldEntry = MatchScoutingCollection.find_one(
        {'event_code': data.event_code, 'match_number': data.match_number, 'team_number': data.team_number, 'scout_info.user_id': data.scout_info.user_id})
    data.time = datetime.utcnow().timestamp()
    data.data.miscellaneous.comments = profanity.censor(
        data.data.miscellaneous.comments)
    if oldEntry is None:
        raise HTTPException(
            404, "No such match scouting entry found to update")
    eventCode = data.event_code
    matchNumber = data.match_number
    teamNumber = data.team_number
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
        if (match["alliances"][allianceStr]["team_keys"].__contains__("frc"+str(teamNumber))):
            exists = True
    if not exists:
        eventTeams = getEventTeams(eventCode)
        if str(teamNumber) in [team[3:] for team in eventTeams]:
            raise HTTPException(400, "Check Your Match And Team Number")
        else:
            raise HTTPException(400, "Check Your Team Number")
    MatchScoutingCollection.find_one_and_replace(
        {"event_code": data.event_code, "team_number": data.team_number, "scout_info.user_id": data.scout_info.user_id}, data.dict())
    groups = [Group(**group)
              for group in get_user_groups_detailed(token=token)]
    groupsNeedingUpdate = [Group(**group) for group in GroupCollection.find(
        {"events": {"$elemMatch": {"event_code": data.event_code, "alliance_groups.group_id": {"$in": [group.group_id for group in groups]}}}})] + groups
    if (data.data.miscellaneous.died):
        for group in groupsNeedingUpdate:
            try:
                updateGroupStatus(group, data.event_code)
            except:
                pass
    for group in groupsNeedingUpdate:
        primeGroupForAnalysis(group=group, event_code=data.event_code)
    return data


@app.get("/Pictures/PutURL", tags=["scouting"])
def get_picture_post_url(token: str = Depends(check_token_active)):
    # Generate a unique image ID
    image_id_string = str(uuid.uuid4())
    while len(list(PictureCollection.find({"image_id": image_id_string}))) != 0:
        image_id_string = str(uuid.uuid4())
    image_id_string += ".jpg"
    sas = generate_blob_sas(
        account_name=RobotPicturesClient.account_name,
        container_name=RobotPicturesClient.container_name,
        blob_name=image_id_string,
        account_key=RobotPicturesClient.credential.account_key,
        permission=BlobSasPermissions(write=True),
        expiry=datetime.utcnow()+timedelta(minutes=5),
    )
    blob_url = f"{RobotPicturesClient.primary_endpoint}/{image_id_string}"
    presigned_url = f"{blob_url}?{sas}&Cache-Control=max-age=86400"
    return {"presigned_url": presigned_url, "image_id": image_id_string}


@app.post("/Pictures/ConfirmUpload", tags=["scouting"])
def confirm_picture_upload(data: PictureData, token: str = Depends(check_token_active)):
    pictureClient = RobotPicturesClient.get_blob_client(data.image_id)
    if not pictureClient.exists():
        raise HTTPException(
            404, "Picture not found. Please make sure the upload completed")
    data.time = datetime.utcnow().timestamp()
    data.link = f"{RobotPicturesClient.primary_endpoint}/{data.image_id}"
    data.scout_info = scout_info_from_token(token=token)
    try:
        PictureCollection.insert_one(data.dict())
    except Exception as e:
        PictureCollection.find_one_and_update(data.dict())
    groups = [Group(**group) for group in get_user_groups_detailed(token)]
    for group in groups:
        for event in group.events:
            if event.event_code == data.event_code:
                updateGroupStatus(group=group, event_code=event.event_code)
    return {"message": "Upload Confirmed"}


@app.get("/{year}/{event}/{team}/getPictures", response_class=JSONResponse, tags=["scouting"])
async def get_pit_scouting_pictures(team: str, event: str, year: int, token: str = Depends(check_token_active)):
    eventCode = str(year) + event
    try:
        team_number = int(team[3:])
    except:
        raise HTTPException(400, "Invalid Team")
    groups = [Group(**group) for group in get_user_groups_detailed(token)]
    if (len(groups) != 0):
        users = get_group_members(groups[0].name, token)
        members = users["members"] + users["admins"] + users["owners"]
        member_ids = [member["id"] for member in members]
        # Query the collection using the key
        pictures = [PictureData(**data) for data in list(PictureCollection.find(
            {"event_code": eventCode, "scout_info.user_id": {"$in": member_ids}, "team_number": team_number}))]
        event: GroupEvent = None
        retval = []
        for _event in groups[0].events:
            if _event.event_code == eventCode:
                event = _event
        if event is not None:
            alliancePictures = []
            for allianceGroup in event.alliance_groups:
                owners, admins, allianceMembers = _getGroupMembers(
                    allianceGroup.group_id)
                allianceMemberIds = [[member["id"]
                                      for member in people]for people in [owners, admins, allianceMembers]]
                ids = []
                for alliance in allianceMemberIds:
                    ids.extend(alliance)
                alliancePictures = [PictureData(**data) for data in list(PictureCollection.find(
                    {"event_code": eventCode, "scout_info.user_id": {"$in": ids}, "team_number": team_number}))]
                for picture in alliancePictures:
                    data = picture.dict(exclude={'scout_info'})
                    data['scout_info'] = picture.scout_info.dict(
                        exclude={'username', 'first_name'})
                    retval.append(data)
        for group in get_user_groups(token):
            if group["id"] == groups[0].admin_group_id:
                for picture in pictures:
                    picture.permissions = ["delete"]
                break
        user_id = get_user_info(token)["sub"]
        for picture in pictures:
            if picture.scout_info.user_id == user_id:
                picture.permissions = ["delete"]
        retval.extend([picture.dict() for picture in pictures])
        return retval
    user_data = get_user_info(token)
    user_id = user_data["sub"]
    pictures = [PictureData(**data) for data in list(PictureCollection.find(
        {"event_code": eventCode, "scout_info.user_id": user_id, "team_number": team_number}))]
    for picture in pictures:
        picture.permissions = ["delete"]
    return [PictureData(**data).dict() for data in pictures]


@app.get("/{year}/{event}/getPictures", tags=["scouting"])
async def get_event_pictures(year: str, event: str, token: str = Depends(check_token_active)):
    eventCode = str(year) + event
    groups = [Group(**group) for group in get_user_groups_detailed(token)]
    user_id = get_user_info(token)["sub"]
    if (len(groups) != 0):
        users = get_group_members(groups[0].name, token)
        members = users["members"] + users["admins"] + users["owners"]
        member_ids = [member["id"] for member in members]
        # Query the collection using the key
        pictures = list(PictureCollection.find(
            {"event_code": eventCode, "scout_info.user_id": {"$in": member_ids}}))
        pictures = [PictureData(**data) for data in list(PictureCollection.find(
            {"event_code": eventCode, "scout_info.user_id": {"$in": member_ids}}))]
        event: GroupEvent = None
        retval = []
        for _event in groups[0].events:
            if _event.event_code == eventCode:
                event = _event
        if event is not None:
            alliancePictures = []
            for allianceGroup in event.alliance_groups:
                owners, admins, allianceMembers = _getGroupMembers(
                    allianceGroup.group_id)
                allianceMemberIds = [[member["id"]
                                      for member in people]for people in [owners, admins, allianceMembers]]
                ids = []
                for alliance in allianceMemberIds:
                    ids.extend(alliance)
                alliancePictures = [PictureData(**data) for data in list(PictureCollection.find(
                    {"event_code": eventCode, "scout_info.user_id": {"$in": ids}}))]
                for picture in alliancePictures:
                    data = picture.dict(exclude={'scout_info'})
                    data['scout_info'] = picture.scout_info.dict(
                        exclude={'username', 'first_name'})
                    retval.append(data)
        for group in get_user_groups(token):
            if group["id"] == groups[0].admin_group_id:
                for picture in pictures:
                    picture.permissions = ["delete"]
                break
        for picture in pictures:
            if picture.scout_info.user_id == user_id:
                picture.permissions = ["delete"]
        retval.extend([picture.dict() for picture in pictures])
        return retval
    pictures = [PictureData(**data) for data in list(PictureCollection.find(
        {"event_code": eventCode, "scout_info.user_id": user_id}))]
    for picture in pictures:
        picture.permissions = ["delete"]
    return [PictureData(**data).dict() for data in pictures]


@app.delete("/Pictures/Delete", tags=["scouting"])
def delete_pit_scouting_pictures(pictureData: PictureData, token: str = Depends(check_token_active)):
    DBEntry = PictureCollection.find_one({'image_id': pictureData.image_id})
    if DBEntry is None:
        raise HTTPException(404, "Picture Not Found")
    if (pictureData.scout_info.user_id == get_user_info(token)["sub"]):
        delete_result = PictureCollection.delete_one(
            {'image_id': pictureData.image_id})
        deleteBlob(pictureData.image_id)
        deleted = False
    else:
        kc_groups = get_user_groups(token)
        detailed_groups = [Group(**group)
                           for group in get_user_groups_detailed(token)]
        deleted = False
        for group in detailed_groups:
            for kc_group in kc_groups:
                if group.admin_group_id == kc_group["id"] or group.owner_group_id == kc_group["id"]:
                    members = get_group_members(group.name, token)
                    memberIds = [member["id"] for member in (
                        members["members"] + members["admins"] + members["owners"])]
                    if pictureData.scout_info.user_id in memberIds:
                        delete_result = PictureCollection.delete_one(
                            {'image_id': pictureData.image_id})
                        deleteBlob(pictureData.image_id)
                        deleted = True
                    break
            if deleted:
                break
        if not deleted:
            raise HTTPException(
                403, "You do not have permission to delete this picture")
    groups = [Group(**group) for group in get_user_groups_detailed(token)]
    for group in groups:
        for event in group.events:
            if event.event_code == pictureData.event_code:
                updateGroupStatus(group=group, event_code=event.event_code)
    return {"message": delete_result.raw_result}


def deleteBlob(blob_name: str):
    blob_client = RobotPicturesClient.get_blob_client(blob_name)
    blob_client.delete_blob()


@app.get("/{year}/{event}/{team}/ScoutEntries", tags=["scouting"])
def get_scout_team_entries(team: str, event: str, year: int, token: str = Depends(check_token_active)):
    event_code = str(year)+event
    groups = [Group(**group) for group in get_user_groups_detailed(token)]
    if (len(groups) != 0):
        members = []
        team_number = int(team[3:])
        for group in groups:
            members.extend(fetch_group_members(group.group_id))
        member_ids = [member['id'] for member in members]
        alliance_members = []
        for group in groups:
            for groupEvent in group.events:
                if groupEvent.event_code == event_code:
                    for alliance in groupEvent.alliance_groups:
                        alliance_members.extend(
                            fetch_group_members(alliance.group_id))
        alliance_member_ids = [member['id'] for member in alliance_members]
        member_entries = [MatchScouting2026(
            **entry) for entry in MatchScoutingCollection.find({'event_code': event_code, 'team_number': team_number, 'scout_info.user_id': {'$in': member_ids}})]
        alliance_entries = [MatchScouting2026(**entry) for entry in MatchScoutingCollection.find(
            {'event_code': event_code, 'team_number': team_number, 'scout_info.user_id': {'$in': alliance_member_ids}})]
        retval = []
        retval.extend([entry.dict() for entry in member_entries])
        for entry in alliance_entries:
            entry_dict = entry.dict()
            entry_dict['scout_info'].pop('first_name', None)
            entry_dict['scout_info'].pop('username', None)
            retval.append(entry_dict)
    else:
        user_id = get_user_info(token)['sub']
        retval = [MatchScouting2026(**entry).dict() for entry in MatchScoutingCollection.find(
            {'event_code': event_code, 'scout_info.user_id': user_id})]
    return retval


@app.get("/{year}/{event}/ScoutEntries", tags=["scouting"])
def get_scout_event_entries(event: str, year: int, token: str = Depends(check_token_active)):
    event_code = str(year)+event
    groups = [Group(**group) for group in get_user_groups_detailed(token)]
    if (len(groups) != 0):
        members = []
        for group in groups:
            members.extend(fetch_group_members(group.group_id))
        member_ids = [member['id'] for member in members]
        alliance_members = []
        for group in groups:
            for groupEvent in group.events:
                if groupEvent.event_code == event_code:
                    for alliance in groupEvent.alliance_groups:
                        alliance_members.extend(
                            fetch_group_members(alliance.group_id))
        alliance_member_ids = [member['id'] for member in alliance_members]
        member_entries = [MatchScouting2026(
            **entry) for entry in MatchScoutingCollection.find({'event_code': event_code, 'scout_info.user_id': {'$in': member_ids}})]
        alliance_entries = [MatchScouting2026(**entry) for entry in MatchScoutingCollection.find(
            {'event_code': event_code, 'scout_info.user_id': {'$in': alliance_member_ids}})]
        retval = []
        retval.extend([entry.dict() for entry in member_entries])
        for entry in alliance_entries:
            entry_dict = entry.dict()
            entry_dict['scout_info'].pop('first_name', None)
            entry_dict['scout_info'].pop('username', None)
            retval.append(entry_dict)
    else:
        user_id = get_user_info(token)['sub']
        retval = [MatchScouting2026(**entry).dict() for entry in MatchScoutingCollection.find(
            {'event_code': event_code, 'scout_info.user_id': user_id})]
    return retval


@app.post("/FollowUp", tags=["scouting"])
def post_team_follow_up(data: DeathScoutingForm, token: str = Depends(check_token_active)):
    data.time = datetime.utcnow().timestamp()
    data.scout_info = scout_info_from_token(token=token)
    event_code = data.event_code
    year = event_code[:4]
    event = event_code[4:]
    team = data.team_key
    for death in data.deaths:
        death.death_reason = profanity.censor(death.death_reason)
    if not len(data.deaths) == 0:
        for idx, death in enumerate(data.deaths):
            match_number = int(death.match_number)
            teamInMatch = False
            matchScoutingEntries = [MatchScouting2026(
                **entry) for entry in get_scout_team_entries(team, event, year, token)]
            for entry in matchScoutingEntries:
                if entry.match_number == match_number:
                    teamInMatch = True
                    break
            if not teamInMatch:
                raise HTTPException(
                    400, "Check Match Number for Death #"+str(idx+1))
        sum = 0
        for death in data.deaths:
            if type(death.severity) == int:
                sum += death.severity
        average = sum/len(data.deaths)
        data.average = average
        data.total = sum
        DBEntry = data.dict()
        try:
            FollowUpCollection.insert_one(DBEntry)
        except:
            FollowUpCollection.find_one_and_delete(
                {"event_code": str(year)+event, "team_key": team, "scout_info.user_id": data.scout_info.user_id})
            FollowUpCollection.insert_one(DBEntry)
        groups = [Group(**group)
                  for group in get_user_groups_detailed(token=token)]
        groupsNeedingUpdate = [Group(**group) for group in GroupCollection.find(
            {"events": {"$elemMatch": {"event_code": data.event_code, "alliance_groups.group_id": {"$in": [group.group_id for group in groups]}}}})] + groups
        for group in groupsNeedingUpdate:
            try:
                updateGroupStatus(group, event_code)
            except Exception as e:
                print(e)
        return data.dict()
    else:
        raise HTTPException(400, "No Deaths Reported")


@app.get("/{year}/{event}/{team}/FollowUp", tags=["scouting"])
def get_team_follow_up(team: str, event: str, year: int, token: str = Depends(check_token_active)):
    groups = [Group(**group) for group in get_user_groups_detailed(token)]
    members = []
    for group in groups:
        members.extend(fetch_group_members(group.group_id))
    member_ids = [member['id'] for member in members]
    alliance_members = []
    for group in groups:
        for groupEvent in group.events:
            if groupEvent.event_code == str(year)+event:
                for alliance in groupEvent.alliance_groups:
                    alliance_members.extend(
                        fetch_group_members(alliance.group_id))
    alliance_member_ids = [member['id'] for member in alliance_members]
    member_entries = [DeathScoutingForm(**form) for form in FollowUpCollection.find(
        {"event_code": str(year)+event, "team_key": team, "scout_info.user_id": {"$in": member_ids}})]
    alliance_entries = [DeathScoutingForm(**form) for form in FollowUpCollection.find(
        {"event_code": str(year)+event, "team_key": team, "scout_info.user_id": {"$in": alliance_member_ids}})]
    if len(member_entries) != 0 or len(alliance_entries) != 0:
        if len(member_entries) != 0:
            latestEntry = member_entries[0]
            alliance = False
        else:
            alliance = True
            latestEntry = alliance_entries[0]
        for entry in member_entries:
            if entry.time > latestEntry.time:
                alliance = False
                latestEntry = entry
        for entry in alliance_entries:
            if entry.time > latestEntry.time:
                alliance = True
                latestEntry = entry
        formData = latestEntry
        scoutEntries = [x for x in [MatchScouting2026(
            **entry) for entry in get_scout_team_entries(team, event, year, token)]]
        deathEntries = [x for x in scoutEntries if x.data.miscellaneous.died]
        for entry in deathEntries:
            notRecorded = True
            for death in formData.deaths:
                if death.match_number == entry.match_number:
                    notRecorded = False
            if notRecorded:
                formData.deaths.append(Death(match_number=entry.match_number))
        if not alliance:
            return formData.dict()
        else:
            retVal = formData.dict()
            retVal['scout_info'] = formData.scout_info.dict(
                exclude={'first_name', 'username'})
            return retVal
    else:
        scoutEntries = [x for x in [MatchScouting2026(
            **entry) for entry in get_scout_team_entries(team, event, year, token)]]
        deathEntries = [x for x in scoutEntries if x.data.miscellaneous.died]
        if len(deathEntries) == 0:
            return DeathScoutingForm(scout_info=scout_info_from_token(token), event_code=str(year)+event, team_key=team, total=0, average=0, time=datetime.utcnow().timestamp())
        else:
            formData = DeathScoutingForm(scout_info=scout_info_from_token(token), event_code=str(
                year)+event, team_key=team, total=0, average=0, time=int(datetime.utcnow().timestamp()))
            notRecorded = True
            for entry in deathEntries:
                for death in formData.deaths:
                    if death.match_number == entry.match_number:
                        notRecorded = False
                        break
                if notRecorded:
                    formData.deaths.append(
                        Death(match_number=entry.match_number))
            return formData.dict()


@app.get('/User/Groups', tags=["users"])
def get_user_groups(token: str = Depends(check_token_active)):
    user_data = get_user_info(token)
    userID = user_data["sub"]
    return find_user_groups(user_id=userID)


@app.get('/User/Groups/Detailed', tags=["users"], response_model=list[Group])
def get_user_groups_detailed(token: str = Depends(check_token_active)) -> list[dict]:
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


@app.get("/{year}/GlobalRankings", tags=["miscellaneous"])
@cacheValue(30 * 60)  # Cache for 30 minutes
def get_global_rankings(
    year: int,
    limit: int = 100,
    offset: int = 0,
    sort_by: str = "data.OPR",
    sort_order: str = "desc",
    filter_teams: None | list[str] = None
):
    sort_order = pymongo.DESCENDING if sort_order == "desc" else pymongo.ASCENDING
    query = {}
    if filter_teams:
        query["team"] = {"$in": filter_teams}
    rankings = list(GlobalRankingsCollection.find(query).sort(
        sort_by, sort_order).skip(offset).limit(limit))
    for rank in rankings:
        rank.pop('_id')
    return {'data': [rank for rank in rankings], 'max_data_query': GlobalRankingsCollection.count_documents(query)}


@app.get('/{year}/{team}/GlobalRanking')
@cacheValue(30*60)
def get_team_global_rank(team: str) -> dict:
    data = GlobalRankingsCollection.find_one({})
    returnData = None
    for x in data:
        if x['key'] == team:
            returnData = x
    if returnData is None:
        raise HTTPException(404, "Team Not Found In Global Rankings")
    return returnData


def convertData(calculatedData, year, event_code):
    keyStr = f"/year/{year}/event/{event_code}/teams/"
    keyList = [keyStr+"index"]
    try:
        rankings = getEventRankings(event_code)
    except:
        rankings = [{"team_key": "frc"+str(team), "rank": 0}
                    for team in calculatedData["team_number"]]
    for team in calculatedData["team_number"]:
        keyList.append(keyStr+str(team))
    retval0 = {"data": {"keys": keyList}}
    retvallist = [retval0]
    for team in calculatedData["team_number"]:
        data = {"historical": False, "key": "frc"+str(team), "rank": 0}
        for item in rankings:
            if item["team_key"] == data["key"]:
                data["rank"] = item["rank"]
                break
        idx = calculatedData["team_number"].index(f"{team}")
        for key in calculatedData:
            data[key] = calculatedData[key][idx]
        retvallist.append(data)
    return retvallist


def _getGroupMembers(group_id: str) -> tuple[list, list, list]:
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
    return owners, admins, members


def updateData(event_code: str, event_type: int):
    TBAData = [TBAMatch2026(**match) for match in TBACollection.find({'event_key': event_code})]
    ScoutingData = []
    scouts = []
    numEntries = []

    try:
        for entry in ScoutingData:
            if entry.scout_info.user_id not in scouts:
                scouts.append(entry.scout_info.user_id)
                numEntries.append(0)
            numEntries[scouts.index(entry.scout_info.user_id)] += 1
    except Exception as e:
        logging.error(e)

    try:
        calculatedData, ratings = analyzeData(TBAData, ScoutingData)
        data = calculatedData.to_dict("list")
        data = convertData(data, 2026, event_code)
    except Exception as e:
        logging.error(e)
        ratings = {"scouts": [], "trustRatings": []}

        keyStr = f"/year/2026/event/{event_code}/teams/"
        keyList = [keyStr + "index"]

        etagData = ETagCollection.find_one({"key": event_code})
        teams = etagData["teams"]
        for team in teams:
            keyList.append(keyStr + team[3:])

        retval0 = {"data": {"keys": keyList}}
        data = [retval0]

        # Default team data without 2025-specific fields
        data.extend([{
            "historical": False,
            "key": team,
            "rank": 0,
            "team_number": team[3:],
            "match_count": 0,
            "OPR": 0,
            "endgame_points": 0,
            "teleop_points": 0,
            "auto_points": 0,
            "climbing_points": 0,
            "total_pieces": 0,
            "auto_scoring": {},
            "teleop_scoring": {},
            "mobility": 0,
            "foul_points": 0,
            "death_rate": 0,
            "parking": 0,
            "coopertition": 0,
            "simulated_rp": 0,
            "simulated_rank": 0
        } for team in teams])

    try:
        data, predictions = updatePredictions(TBAData, data, eventType=event_type)
        try:
            PredictionCollection.insert_one({"event_code": event_code, "data": predictions})
        except Exception:
            PredictionCollection.find_one_and_replace(
                {"event_code": event_code},
                {"event_code": event_code, "data": predictions}
            )
    except Exception as e:
        logging.error(e)

    metadata = {"last_modified": datetime.utcnow().timestamp(), "etag": None, "tba": False}

    try:
        # Build scout ratings
        ratings = {
            "scouts": ratings["scouts"],
            "trustRatings": ratings["trustRatings"],
            "entries": list(numpy.zeros(len(ratings["scouts"])))
        }
        for idx, scout in enumerate(ratings["scouts"]):
            ratings["entries"][idx] = numEntries[scouts.index(scout["name"])]
    except Exception as e:
        logging.error(e)

    try:
        prevData = CalculatedDataCollection.find_one({"event_code": event_code})["data"][1:]
        for idx, team in enumerate(prevData):
            for newTeam in data[1:]:
                if team["key"] == newTeam["key"]:
                    for key in team:
                        if key not in newTeam:
                            newTeam[key] = team[key]
                    break
    except Exception as e:
        logging.error(e)

    try:
        CalculatedDataCollection.insert_one({
            "event_code": event_code,
            "data": data,
            "metadata": metadata,
            "scout_ratings": ratings
        })
    except Exception as e:
        try:
            CalculatedDataCollection.update_one(
                {"event_code": event_code},
                {'$set': {"data": data, "metadata": metadata, "scout_ratings": ratings}}
            )
        except Exception as ex:
            print(ex)



def updateData(event_code: str, event_type: int):
    # ---- Load TBA matches for this event ----
    TBAData = [
        TBAMatch2026(**match) 
        for match in TBACollection.find({'event_key': event_code})
    ]

    # ---- Load scouting data (MatchScouting2026 only) ----
    ScoutingData = [
        MatchScouting2026(**entry)
        for entry in MatchScoutingCollection.find({'event_code': event_code})
    ]

    # ---- Count scout submissions ----
    scouts = []
    numEntries = []
    for entry in ScoutingData:
        uid = entry.scout_info.user_id
        if uid not in scouts:
            scouts.append(uid)
            numEntries.append(0)
        numEntries[scouts.index(uid)] += 1

    # ---- Analyze data and convert ----
    try:
        calculatedData, ratings = analyzeData(TBAData, ScoutingData)
        data = calculatedData.to_dict("list")
        data = convertData(data, YEAR, event_code)  # adapt convertData for 2026
    except Exception as e:
        logging.exception("Failed to analyze data, using fallback zeroed values")
        ratings = {"scouts": [], "trustRatings": []}

        keyStr = f"/year/{YEAR}/event/{event_code}/teams/"
        keyList = [keyStr + "index"]

        etagData = ETagCollection.find_one({"key": event_code})
        teams = etagData["teams"] if etagData else []

        for team in teams:
            keyList.append(keyStr + team[3:])

        fallback_entry = {
            "historical": False,
            "key": None,
            "team_number": None,
            "match_count": 0,
            "shoot_amount": 0,
            "cycles_completed": 0,
            "auto": {},  # empty Auto2026 object
            "miscellaneous": {"died": False, "comments": ""}
        }

        data = [{"data": {"keys": keyList}}]
        for team in teams:
            entry = fallback_entry.copy()
            entry["key"] = team
            entry["team_number"] = int(team[3:])
            data.append(entry)

    # ---- Update predictions ----
    try:
        data, predictions = updatePredictions(TBAData, data, eventType=event_type)
        # Upsert predictions
        PredictionCollection.update_one(
            {"event_code": event_code},
            {"$set": {"data": predictions}},
            upsert=True
        )
    except Exception as e:
        logging.exception("Failed to update predictions")

    # ---- Prepare metadata ----
    metadata = {
        "last_modified": datetime.utcnow().timestamp(),
        "etag": None,
        "tba": False
    }

    # ---- Compile scout ratings ----
    try:
        ratings_output = {
            "scouts": ratings.get("scouts", []),
            "trustRatings": ratings.get("trustRatings", []),
            "entries": []
        }
        ratings_output["entries"] = [numEntries[scouts.index(s["name"])] for s in ratings_output["scouts"]]
    except Exception as e:
        logging.exception("Failed to compute scout ratings")
        ratings_output = {"scouts": [], "trustRatings": [], "entries": []}

    # ---- Merge previous data (keep missing keys) ----
    try:
        prevDataDoc = CalculatedDataCollection.find_one({"event_code": event_code})
        prevData = prevDataDoc["data"][1:] if prevDataDoc else []

        for old_team in prevData:
            for new_team in data[1:]:
                if old_team["key"] == new_team["key"]:
                    for key, value in old_team.items():
                        if key not in new_team:
                            new_team[key] = value
                    break
    except Exception as e:
        logging.exception("Failed to merge previous calculated data")

    # ---- Write final data to CalculatedDataCollection ----
    try:
        CalculatedDataCollection.update_one(
            {"event_code": event_code},
            {"$set": {
                "data": data,
                "metadata": metadata,
                "scout_ratings": ratings_output
            }},
            upsert=True
        )
    except Exception as e:
        logging.exception("Failed to insert/update calculated data")

def updatePredictions(TBAData: list[TBAMatch2026], calculatedData, eventType: int):
    matchPredictions = []

    for match in TBAData:
        matchPrediction = {
            "comp_level": match.comp_level,
            "key": match.key,
            "match_number": match.match_number,
            "set_number": match.set_number,
            "blue_teams": match.alliances['blue'].team_keys,
            "blue_human_player": 0,
            "blue_dq_team_keys": match.alliances['blue'].dq_team_keys,
            "blue_surrogate_team_keys": match.alliances['blue'].surrogate_team_keys,
            "blue_score": 0,
            "blue_climbing": 0,
            "blue_auto_points": 0,
            "blue_teleop_points": 0,
            "blue_endgame_points": 0,
            "blue_coopertition": 0,
            "blue_actual_score": match.score_breakdown["blue"].shoot_amount if match.score_breakdown else 0,
            
            "red_teams": match.alliances['red'].team_keys,
            "red_human_player": 0,
            "red_dq_team_keys": match.alliances['red'].dq_team_keys,
            "red_surrogate_team_keys": match.alliances['red'].surrogate_team_keys,
            "red_score": 0,
            "red_climbing": 0,
            "red_auto_points": 0,
            "red_teleop_points": 0,
            "red_endgame_points": 0,
            "red_coopertition": 0,
            "red_actual_score": match.score_breakdown["red"].shoot_amount if match.score_breakdown else 0,

            "predicted": not bool(match.score_breakdown)
        }

        # Aggregate calculatedData for each alliance
        for alliance in match.alliances:
            for team in match.alliances[alliance].team_keys:
                for i in range(1, len(calculatedData)):
                    if calculatedData[i]["key"] == team:
                        teamData = calculatedData[i]
                        matchPrediction[f"{alliance}_score"] += teamData.get("OPR", 0)
                        matchPrediction[f"{alliance}_climbing"] += teamData.get("climbing_points", 0)
                        matchPrediction[f"{alliance}_auto_points"] += teamData.get("auto_points", 0)
                        matchPrediction[f"{alliance}_teleop_points"] += teamData.get("teleop_points", 0)
                        matchPrediction[f"{alliance}_endgame_points"] += teamData.get("endgame_points", 0)
                        matchPrediction[f"{alliance}_coopertition"] += teamData.get("coopertition", 0)
                        matchPrediction[f"{alliance}_human_player"] += 0  # adjust if 2026 rule applies

        # Placeholder RP calculation (replace with official 2026 rules)
        for alliance in ["blue", "red"]:
            opponent = "red" if alliance == "blue" else "blue"
            matchPrediction[f"{alliance}_total_rp"] = 0  # TODO: calculate based on 2026 RP rules
            matchPrediction[f"{alliance}_win_rp"] = 0
            matchPrediction[f"{alliance}_auto_rp"] = 0
            matchPrediction[f"{alliance}_barge_rp"] = 0
            matchPrediction[f"{alliance}_display_rp"] = matchPrediction[f"{alliance}_total_rp"] if matchPrediction["predicted"] else 0

        matchPredictions.append(matchPrediction)

    # Reset simulated RP / rank
    for i in range(1, len(calculatedData)):
        calculatedData[i]["simulated_rp"] = 0
        calculatedData[i]["simulated_rank"] = 0

    # Update simulated RP for teams
    for matchPrediction in matchPredictions:
        for alliance in ["blue", "red"]:
            for team in [x for x in matchPrediction[f"{alliance}_teams"]
                         if x not in matchPrediction[f"{alliance}_dq_team_keys"] 
                         and x not in matchPrediction[f"{alliance}_surrogate_team_keys"]]:
                for i in range(1, len(calculatedData)):
                    if calculatedData[i]["key"] == team:
                        if matchPrediction["predicted"] and matchPrediction["comp_level"] == "qm":
                            calculatedData[i]["simulated_rp"] += matchPrediction[f"{alliance}_total_rp"]
                        else:
                            for match in TBAData:
                                if match.key == matchPrediction["key"] and matchPrediction["comp_level"] == "qm":
                                    # placeholder: use actual RP if available in 2026
                                    calculatedData[i]["simulated_rp"] += 0
                        break

    # Sort simulated rank
    sorted_list = sorted(calculatedData[1:], key=lambda x: x["simulated_rp"], reverse=True)
    for i, item in enumerate(sorted_list):
        sorted_list[i]["simulated_rank"] = i + 1
    sorted_list.insert(0, calculatedData[0])

    return sorted_list, matchPredictions

def primeGroupForAnalysis(group: Group, event_code: str):
    for event in group.events:
        if event.event_code == event_code and event.up_to_date:
            event.up_to_date = False
            GroupCollection.update_one(
                {"group_id": group.group_id, "events.event_code": event_code},
                {"$set": {"events.$.up_to_date": False}}
            )


@app.delete("/MatchScouting/Delete", tags=["scouting"])
def delete_match_scouting_2026(data: MatchScouting2026, token: str = Depends(check_token_active)):
    # Fetch the DB entry
    DBEntry = MatchScoutingCollection.find_one({
        'scout_info.user_id': data.scout_info.user_id,
        'match_number': data.match_number,
        'team_number': data.team_number,
        'event_code': data.event_code
    })

    if DBEntry is None:
        raise HTTPException(404, "Entry Not Found")

    # Check if user is owner of the entry
    deleted = False
    current_user_id = get_user_info(token)["sub"]

    if data.scout_info.user_id == current_user_id:
        delete_result = MatchScoutingCollection.delete_one({
            'scout_info.user_id': data.scout_info.user_id,
            'match_number': data.match_number,
            'team_number': data.team_number,
            'event_code': data.event_code
        })
        deleted = True
    else:
        # Check if user is admin/owner of any relevant group
        kc_groups = get_user_groups(token)
        detailed_groups = [Group(**group) for group in get_user_groups_detailed(token)]
        for group in detailed_groups:
            for kc_group in kc_groups:
                if group.admin_group_id == kc_group["id"] or group.owner_group_id == kc_group["id"]:
                    members = get_group_members(group.name, token)
                    member_ids = [member["id"] for member in (members["members"] + members["admins"] + members["owners"])]
                    if data.scout_info.user_id in member_ids:
                        delete_result = MatchScoutingCollection.delete_one({
                            'scout_info.user_id': data.scout_info.user_id,
                            'match_number': data.match_number,
                            'team_number': data.team_number,
                            'event_code': data.event_code
                        })
                        deleted = True
                        break
            if deleted:
                break

    if not deleted:
        raise HTTPException(403, "You do not have permission to delete this entry")

    # Update related group statuses if the robot died in the match
    groups = [Group(**group) for group in get_user_groups_detailed(token=token)]
    groups_needing_update = [Group(**group) for group in GroupCollection.find({
        "events": {"$elemMatch": {
            "event_code": data.event_code,
            "alliance_groups.group_id": {"$in": [group.group_id for group in groups]}
        }}
    })] + groups

    if data.data.miscellaneous.died:
        for group in groups_needing_update:
            try:
                updateGroupStatus(group, data.event_code)
            except:
                pass

    # Update group analysis
    for group in groups_needing_update:
        primeGroupForAnalysis(group=group, event_code=data.event_code)

    return {"message": delete_result.raw_result}



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
    try:
        global numRuns
        etags = list(ETagCollection.find({}))
        globalTeamsWithLatestFinishedEvent: list[dict] = []
        for event in etags:
            print('global teams size', len(globalTeamsWithLatestFinishedEvent))
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
                    if req.status_code != 304:
                        continue
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
                groups = GroupCollection.find(
                    {"events.event_code": event["key"]})
                # Add Teams to Global Rankings, with Event Timing
                endDate = datetime.strptime(
                    event['event']['end_date'], "%Y-%m-%d")
                if datetime.now() >= endDate and (event['event']['event_type'] not in [2, 4] or (event['event']['event_type'] == 2 and event["event"]["division_keys"] == [])):
                    for team in event['teams']:
                        teamData = None
                        for x in globalTeamsWithLatestFinishedEvent:
                            if x['team'] == team:
                                teamData = x
                                break
                        if teamData == None:
                            teamData = {
                                'team': team, 'eventDate': endDate, 'event': event['key'], 'all_events': []}
                            globalTeamsWithLatestFinishedEvent.append(teamData)
                        teamData['all_events'].append(event['key'])
                        if teamData['eventDate'] < endDate:
                            teamData['event'] = event['key']
                            teamData['eventDate'] = endDate
                for group in groups:
                    try:
                        groupExistingTeams = GroupPitStatusCollection.find_one(
                            {"event_code": event["key"], "group_id": group["group_id"]})["data"]
                    except:
                        groupExistingTeams = []
                    returnTeams = []
                    for team in teams:
                        for existingTeam in groupExistingTeams:
                            if existingTeam["key"] == team["key"]:
                                team = existingTeam
                                break
                        returnTeams.append(team)
                    try:
                        GroupPitStatusCollection.insert_one(
                            {"event_code": event["key"], "group_id": group["group_id"], "data": returnTeams})
                    except Exception as e:
                        GroupPitStatusCollection.find_one_and_replace({"event_code": event["key"], "group_id": group["group_id"]}, {
                            "event_code": event["key"], "group_id": group["group_id"], "data": returnTeams})
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
                try:
                    responseJson = json.loads(r.text)
                except:
                    responseJson = []
                for x in responseJson:
                    # print(event)
                    x['time'] = int(x['time']) if 'time' in x and isinstance(x['time'], float) else x.get('time')
                    x['actual_time'] = int(x['actual_time']) if 'actual_time' in x and isinstance(x['actual_time'], float) else x.get('actual_time')
                    x['post_result_time'] = int(x['post_result_time']) if 'post_result_time' in x and isinstance(x['post_result_time'], float) else x.get('post_result_time')
                    tbaEntry = TBAMatch2026(**x)
                    try:
                        TBACollection.insert_one(tbaEntry.dict())
                    except:
                        TBACollection.find_one_and_update({"key": tbaEntry.key}, {"$set": {"time": tbaEntry.time, "actual_time": tbaEntry.actual_time,
                                                                                           "post_result_time": tbaEntry.post_result_time, "score_breakdown": {'red': tbaEntry.score_breakdown['red'].dict(), 'blue': tbaEntry.score_breakdown['blue'].dict()} if tbaEntry.score_breakdown is not None else None, "alliances": {'red': tbaEntry.alliances['red'].dict(), 'blue': tbaEntry.alliances['blue'].dict()}}})
                event["etag"] = r.headers["ETag"]
                ETagCollection.find_one_and_replace(
                    {"key": event["key"]}, event)
                # logging.error(e)
                try:
                    updateData(event["key"], event["event"]["event_type"])
                    event["up_to_date"] = True
                    ETagCollection.find_one_and_replace(
                        {"key": event["key"]}, event)
                except Exception as e:
                    print(e, event["key"])
                    pass
        calculatedData = list(CalculatedDataCollection.find({}))
        print('numEvents:', len(calculatedData))
        for team in globalTeamsWithLatestFinishedEvent:
            for x in calculatedData:
                if x['event_code'] == team['event']:
                    for i in range(1, len(x['data'])):
                        y = x['data'][i]
                        if y['key'] == team['team']:
                            team['data'] = y
                            break
                    break
        globalTeamsWithLatestFinishedEvent = [
            x for x in globalTeamsWithLatestFinishedEvent if 'data' in x]
        globalTeamsWithLatestFinishedEvent.sort(
            key=lambda x: x['data']['OPR'], reverse=True)
        for rank, team in enumerate(globalTeamsWithLatestFinishedEvent, start=1):
            team['data']['OPRRank'] = rank
        GlobalRankingsCollection.delete_many({})
        for x in globalTeamsWithLatestFinishedEvent:
            try:
                GlobalRankingsCollection.insert_one(x)
            except:
                pass
        # print("trying to find groups")
        groupsToUpdate = [
            Group(**group) for group in list(GroupCollection.find({"events.up_to_date": False}))]
        # print("found groups")
        for group in groupsToUpdate:
            # print(group.name)
            for event in group.events:
                # print(event)
                if not event.up_to_date:
                    try:
                        for eventData in etags:
                            if eventData["key"] == event.event_code:
                                eventData = eventData
                                break
                        updateGroupData(group, event.event_code,
                                        eventData["event"]["event_type"])
                        # print('updated calculated data')
                        updateGroupGridPitData(group, event.event_code)
                        GroupCollection.update_one(
                            {'group_id': group.group_id}, {"$set": {"events.$[elem].up_to_date": True}}, array_filters=[{"elem.event_code": event.event_code}])
                    except Exception as e:
                        logging.error(str(e))
        numRuns += 1
    except Exception as e:
        logging.error(e)
        pass
    logging.info("Done with data update #" + str(numRuns))