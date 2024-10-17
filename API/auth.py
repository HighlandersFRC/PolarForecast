from functools import wraps
import logging
import os
from fastapi import HTTPException, Header
from keycloak import KeycloakOpenID

keycloak_openid = KeycloakOpenID(
        server_url=os.getenv("KEYCLOAK_ENDPOINT"),
        realm_name=os.getenv("KEYCLOAK_REALM"),
        client_id=os.getenv("KEYCLOAK_API_CLIENT_ID"),
        client_secret_key=os.getenv("KEYCLOAK_API_CLIENT_SECRET_KEY"),
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
    else: raise HTTPException("Token is not active")

def get_user_info(token:str):
    info = keycloak_openid.userinfo(token)
    return info