import logging
import os
import random
import string
from fastapi import HTTPException, Header
from keycloak import KeycloakAdmin, KeycloakOpenID, KeycloakOpenIDConnection
import requests

from models.scout_info import ScoutInfo

keycloak_openid = None
while (keycloak_openid == None):
    try:
        keycloak_openid = KeycloakOpenID(
            server_url=os.getenv("KEYCLOAK_ENDPOINT"),
            realm_name=os.getenv("KEYCLOAK_REALM"),
            client_id=os.getenv("KEYCLOAK_API_CLIENT_ID"),
            client_secret_key=os.getenv("KEYCLOAK_API_CLIENT_SECRET_KEY"),
        )
    except Exception as e:
        logging.error(str(e))
        keycloak_admin = None

keycloak_admin = None
while (keycloak_admin == None):
    try:
        keycloak_admin = KeycloakAdmin(
            server_url=os.getenv("KEYCLOAK_ENDPOINT"),
            realm_name=os.getenv("KEYCLOAK_REALM"),
            client_id="admin-cli",
            username=os.getenv("KEYCLOAK_ADMIN"),
            password=os.getenv("KEYCLOAK_ADMIN_PASSWORD"),
            user_realm_name="master",  # admin user lives in master realm
        )
    except Exception as e:
        logging.error(str(e))   
        keycloak_admin = None


def create_join_code() -> str:
    chars = list((string.ascii_uppercase + string.digits)*6)
    random.shuffle(chars)
    code = chars[:6]
    codeStr = ''
    for char in code:
        codeStr += char
    return codeStr


def get_token_active(token: str):
    # logging.info(f"Middleware get_token_active introspect token {token}")
    try:
        introspect = keycloak_openid.introspect(token)
    except Exception as e:
        raise HTTPException(200, str(e))
    # logging.info(f"introspect: {introspect}")
    return introspect["active"]


def check_token_active(token: str = Header(None)):
    if token is None:
        raise HTTPException(401, "Login token is required")
    if get_token_active(token):
        return token
    else:
        raise HTTPException(401, "Token is bad or expired")


def get_user_info(token: str):
    info = keycloak_openid.userinfo(token)
    return info


def make_group(token: str, group_name: str, event: str | None):
    user_info = get_user_info(token)
    eventAttribute = [event] if event is not None else []
    payload = {
        "name": group_name,
        "attributes": {"event": eventAttribute},
    }
    subgroups = [
        {
            "name": "Owner",
            "attributes": {"event": eventAttribute},

        },
        {
            "name": "Admin",
            "attributes": {"event": eventAttribute},
        },
        {
            "name": "Member",
            "attributes": {"event": eventAttribute},
        }
    ]
    payload["subGroups"] = subgroups
    try:
        group_id = keycloak_admin.create_group(
            payload=payload
        )
    except:
        raise HTTPException(400, "This group name is already taken.")
    subIDs = [group_id]
    for subgroup in subgroups:
        subIDs.append(keycloak_admin.create_group(
            payload=subgroup,
            parent=group_id
        ))
    for subID in subIDs:
        keycloak_admin.group_user_add(
            user_id=user_info["sub"],
            group_id=subID
        )
    codeStr = create_join_code()
    return {
        "group": payload,
        "code": codeStr,
        "group_id": group_id,
        "owner_subgroup_id": subIDs[1],
        "admin_subgroup_id": subIDs[2],
        "member_subgroup_id": subIDs[3],
    }


def find_user_groups(user_id: str):
    try:
        keycloak_admin.connection.refresh_token()
    except Exception:
        keycloak_admin.get_token()  # fall back to full re-auth
    
    groups = keycloak_admin.get_user_groups(
        user_id,
        query={},
        brief_representation=False
    )
    return groups


def fetch_group_members(group_id: str):
    return keycloak_admin.get_group_members(group_id=group_id, query={'max': 1000})


def add_user_to_group(user_id: str, group_id: str,):
    keycloak_admin.group_user_add(
        user_id=user_id,
        group_id=group_id
    )


def remove_user_from_group(user_id: str, group_id: str):
    keycloak_admin.group_user_remove(
        user_id=user_id,
        group_id=group_id
    )


def delete_group_kc(group_id: str):
    keycloak_admin.delete_group(group_id)


def scout_info_from_token(token: str) -> ScoutInfo:
    user_info = get_user_info(token)
    return ScoutInfo(
        user_id=user_info['sub'],
        first_name=user_info['name'], username=user_info['preferred_username'], team_number=user_info['team_number'])


def scout_info_from_id(user_id: str) -> ScoutInfo:
    user_info = keycloak_admin.get_user(user_id)
    return ScoutInfo(
        user_id=user_info['id'],
        first_name=user_info['firstName'], username=user_info['username'], team_number=int(user_info['attributes']['team_number'][0]))