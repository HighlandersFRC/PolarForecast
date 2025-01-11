import logging
import os
import random
import string
from fastapi import HTTPException, Header
from keycloak import KeycloakAdmin, KeycloakOpenID, KeycloakOpenIDConnection
import requests

keycloak_openid = KeycloakOpenID(
    server_url=os.getenv("KEYCLOAK_ENDPOINT"),
    realm_name=os.getenv("KEYCLOAK_REALM"),
    client_id=os.getenv("KEYCLOAK_API_CLIENT_ID"),
    client_secret_key=os.getenv("KEYCLOAK_API_CLIENT_SECRET_KEY"),
)
keycloak_admin = KeycloakAdmin(
    server_url=os.getenv("KEYCLOAK_ENDPOINT"),
    realm_name=os.getenv("KEYCLOAK_REALM"),
    client_id='polarforecast-api',
    client_secret_key=os.getenv("KEYCLOAK_API_CLIENT_SECRET_KEY"),
    username=os.getenv("KEYCLOAK_ADMIN"),
    password=os.getenv("KEYCLOAK_ADMIN_PASSWORD"),
)


def get_token_active(token: str):
    logging.debug(f"Middleware get_token_active introspect token {token}")
    introspect = keycloak_openid.introspect(token)
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
    current_groups = fetch_event_groups(event)
    for group in current_groups:
        if group["name"] == group_name:
            raise HTTPException(400, "Group Name Already Exists")
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
    group_id = keycloak_admin.create_group(
        payload=payload
    )
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
    chars = list((string.ascii_uppercase + string.digits)*6)
    random.shuffle(chars)
    code = chars[:6]
    codeStr = ''
    for char in code:
        codeStr += char
    return {
        "group": payload,
        "code": codeStr,
    }


def find_user_groups(user_id: str):
    print(user_id)
    groups = keycloak_admin.get_user_groups(
        user_id, query={
        }, brief_representation=False)
    print(groups)
    return groups


def fetch_event_groups(eventCode: str):
    groups = keycloak_admin.get_groups(
    )
    returnGroups = []
    for group in groups:
        if group.__contains__("attributes") and group["attributes"]["event"][0] == eventCode:
            returnGroups.append(group)
    return returnGroups
