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
        keycloak_openid = None


keycloak_admin = None
while (keycloak_admin == None):
    try:
        connection = KeycloakOpenIDConnection(
            server_url=os.getenv("KEYCLOAK_ENDPOINT"),
            realm_name=os.getenv("KEYCLOAK_REALM"),
            client_id=os.getenv("KEYCLOAK_API_CLIENT_ID"),
            client_secret_key=os.getenv("KEYCLOAK_API_CLIENT_SECRET_KEY"),
        )
        keycloak_admin = KeycloakAdmin(connection=connection)
    except Exception as e:
        logging.error(str(e))
        keycloak_openid = None


def _refresh_admin_token():
    """Ensure the service account token is fresh before admin calls."""
    try:
        keycloak_admin.connection.refresh_token()
    except Exception:
        keycloak_admin.connection.get_token()


def create_join_code() -> str:
    chars = list((string.ascii_uppercase + string.digits) * 6)
    random.shuffle(chars)
    return "".join(chars[:6])


def get_token_active(token: str) -> bool:
    try:
        introspect = keycloak_openid.introspect(token)
    except Exception as e:
        raise HTTPException(200, str(e))
    return introspect["active"]


def check_token_active(token: str = Header(None)) -> str:
    if token is None:
        raise HTTPException(401, "Login token is required")
    if get_token_active(token):
        return token
    raise HTTPException(401, "Token is bad or expired")


def get_user_info(token: str) -> dict:
    return keycloak_openid.userinfo(token)


def make_group(token: str, group_name: str, event: str | None) -> dict:
    user_info = get_user_info(token)
    event_attr = [event] if event is not None else []

    subgroups = [
        {"name": "Owner",  "attributes": {"event": event_attr}},
        {"name": "Admin",  "attributes": {"event": event_attr}},
        {"name": "Member", "attributes": {"event": event_attr}},
    ]
    payload = {
        "name": group_name,
        "attributes": {"event": event_attr},
        "subGroups": subgroups,
    }

    _refresh_admin_token()
    try:
        group_id = keycloak_admin.create_group(payload=payload)
    except Exception:
        raise HTTPException(400, "This group name is already taken.")

    sub_ids = [group_id]
    for subgroup in subgroups:
        sub_ids.append(keycloak_admin.create_group(payload=subgroup, parent=group_id))

    for sub_id in sub_ids:
        keycloak_admin.group_user_add(user_id=user_info["sub"], group_id=sub_id)

    return {
        "group": payload,
        "code": create_join_code(),
        "group_id": group_id,
        "owner_subgroup_id":  sub_ids[1],
        "admin_subgroup_id":  sub_ids[2],
        "member_subgroup_id": sub_ids[3],
    }


def find_user_groups(user_id: str) -> list:
    _refresh_admin_token()
    return keycloak_admin.get_user_groups(
        user_id, query={}, brief_representation=False
    )


def fetch_group_members(group_id: str) -> list:
    _refresh_admin_token()
    return keycloak_admin.get_group_members(group_id=group_id, query={"max": 1000})


def add_user_to_group(user_id: str, group_id: str) -> None:
    _refresh_admin_token()
    keycloak_admin.group_user_add(user_id=user_id, group_id=group_id)


def remove_user_from_group(user_id: str, group_id: str) -> None:
    _refresh_admin_token()
    keycloak_admin.group_user_remove(user_id=user_id, group_id=group_id)


def delete_group_kc(group_id: str) -> None:
    _refresh_admin_token()
    keycloak_admin.delete_group(group_id)


def scout_info_from_token(token: str) -> ScoutInfo:
    user_info = get_user_info(token)
    return ScoutInfo(
        user_id=user_info["sub"],
        first_name=user_info["name"],
        username=user_info["preferred_username"],
        team_number=user_info["team_number"],
    )


def scout_info_from_id(user_id: str) -> ScoutInfo:
    _refresh_admin_token()
    user_info = keycloak_admin.get_user(user_id)
    return ScoutInfo(
        user_id=user_info["id"],
        first_name=user_info["firstName"],
        username=user_info["username"],
        team_number=int(user_info["attributes"]["team_number"][0]),
    )