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
            client_id=os.getenv("KEYCLOAK_API_CLIENT_ID"),
            client_secret_key=os.getenv("KEYCLOAK_API_CLIENT_SECRET_KEY"),
            username=os.getenv("KEYCLOAK_ADMIN"),
            password=os.getenv("KEYCLOAK_ADMIN_PASSWORD"),
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
    if token is None or token.strip() == "":
        return False

    # Preferred path: token introspection.
    try:
        introspect = keycloak_openid.introspect(token)
        return bool(introspect.get("active", False))
    except Exception as e:
        logging.warning(f"Token introspection failed, falling back to userinfo: {e}")

    # Fallback path: validate token by fetching userinfo.
    try:
        info = keycloak_openid.userinfo(token)
        return isinstance(info, dict) and bool(info.get("sub"))
    except Exception as e:
        logging.warning(f"Token userinfo fallback failed: {e}")
        return False


def extract_token_from_headers(token: str | None = None, authorization: str | None = None):
    if authorization is not None:
        prefix = "bearer "
        normalized = authorization.strip()
        if normalized.lower().startswith(prefix):
            bearer_token = normalized[len(prefix):].strip()
            if bearer_token:
                return bearer_token
        if token is None and normalized:
            return normalized
    return token


def check_token_active(token: str = Header(None), authorization: str | None = Header(None)):
    resolved_token = extract_token_from_headers(
        token=token, authorization=authorization)
    if resolved_token is None:
        raise HTTPException(401, "Login token is required")
    if get_token_active(resolved_token):
        return resolved_token
    else:
        raise HTTPException(401, "Token is bad or expired")


def get_user_info(token: str):
    try:
        info = keycloak_openid.userinfo(token)
    except Exception as e:
        logging.warning(f"Failed to fetch user info from token: {e}")
        raise HTTPException(401, "Token is bad or expired")

    if not isinstance(info, dict) or not info.get("sub"):
        raise HTTPException(401, "Token is bad or expired")

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
    except Exception as e:
        error_text = str(e).lower()
        if (
            "409" in error_text
            or "already exists" in error_text
            or "group exists" in error_text
            or "conflict" in error_text
            or "duplicate" in error_text
        ):
            raise HTTPException(400, "This group name is already taken.")
        logging.warning(f"Identity provider failed while creating group '{group_name}': {e}")
        raise HTTPException(
            502, "Unable to create group in identity provider")
    subIDs = [group_id]
    try:
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
    except Exception as e:
        logging.warning(
            f"Identity provider failed while finalizing group '{group_name}': {e}")
        try:
            keycloak_admin.delete_group(group_id)
        except Exception as cleanup_error:
            logging.warning(
                f"Failed to roll back partially-created group '{group_name}' ({group_id}): {cleanup_error}")
        raise HTTPException(
            502, "Unable to create group in identity provider")
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
    # Be tolerant of python-keycloak signature differences across versions.
    attempts = [
        lambda: keycloak_admin.get_user_groups(user_id),
        lambda: keycloak_admin.get_user_groups(user_id=user_id),
        lambda: keycloak_admin.get_user_groups(user_id, query={}),
        lambda: keycloak_admin.get_user_groups(
            user_id, query={}, brief_representation=False),
    ]

    last_type_error = None
    for attempt in attempts:
        try:
            groups = attempt()
            return groups if isinstance(groups, list) else []
        except TypeError as e:
            last_type_error = e
            continue
        except HTTPException:
            raise
        except Exception as e:
            logging.warning(f"Failed to fetch groups for user {user_id}: {e}")
            raise HTTPException(
                502, f"Unable to fetch user groups from identity provider ({type(e).__name__})")

    if last_type_error is not None:
        logging.warning(
            f"No compatible keycloak get_user_groups signature for current library: {last_type_error}")
    raise HTTPException(
        502, "Unable to fetch user groups from identity provider (incompatible keycloak client signature)")


def fetch_group_members(group_id: str):
    attempts = [
        lambda: keycloak_admin.get_group_members(group_id=group_id),
        lambda: keycloak_admin.get_group_members(group_id=group_id, query={'max': 1000}),
    ]

    last_type_error = None
    for attempt in attempts:
        try:
            members = attempt()
            return members if isinstance(members, list) else []
        except TypeError as e:
            last_type_error = e
            continue
        except Exception as e:
            logging.warning(f"Failed to fetch members for group {group_id}: {e}")
            raise HTTPException(
                502, f"Unable to fetch group members from identity provider ({type(e).__name__})")

    if last_type_error is not None:
        logging.warning(
            f"No compatible keycloak get_group_members signature for current library: {last_type_error}")
    raise HTTPException(
        502, "Unable to fetch group members from identity provider (incompatible keycloak client signature)")


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
