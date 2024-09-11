from functools import wraps
import logging
import os
from typing import Annotated
from fastapi import HTTPException, Header
from keycloak import KeycloakOpenID
def get_token_active(token):
    keycloak_openid = KeycloakOpenID(
        server_url=os.getenv("KEYCLOAK_ENDPOINT"),
        realm_name=os.getenv("KEYCLOAK_REALM"),
        client_id=os.getenv("KEYCLOAK_API_CLIENT_ID"),
        client_secret_key=os.getenv("KEYCLOAK_API_CLIENT_SECRET_KEY"),
    )
    logging.debug(f"Middleware get_token_active introspect token {token}")
    introspect = keycloak_openid.introspect(token)
    return introspect["active"]

def check_token_active(func):
    @wraps(func)
    def wrapper(*args, token: Annotated[str | None, Header()] = None,**kwargs):
        if token is None:
            raise HTTPException(401, "Login token is required")
        if not get_token_active(token):
            raise HTTPException(401, "Get a new login token")
        return func(*args, **kwargs)
    return wrapper