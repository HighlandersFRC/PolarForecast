import requests
import json
import os

# Keycloak configuration
KEYCLOAK_HOST = os.getenv("KEYCLOAK_HOST", "http://localhost:8080")
REALM_NAME = os.getenv("REALM_NAME", "myrealm")
ADMIN_NAME = os.getenv("ADMIN_NAME", "admin")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "admin")
CLIENT_ID = "admin-cli"


def get_access_token():
    """Obtain an access token from Keycloak."""
    url = f"{KEYCLOAK_HOST}/realms/master/protocol/openid-connect/token"
    data = {
        "client_id": CLIENT_ID,
        "username": ADMIN_NAME,
        "password": ADMIN_PASSWORD,
        "grant_type": "password"
    }
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    response = requests.post(url, data=data, headers=headers)
    response.raise_for_status()
    return response.json()["access_token"]


def fetch_data(endpoint, access_token):
    """Fetch data from a Keycloak endpoint."""
    url = f"{KEYCLOAK_HOST}/admin/realms/{REALM_NAME}/{endpoint}"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {access_token}"
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()


def save_json(filename, data):
    """Save JSON data to a file."""
    with open(filename, "w") as f:
        json.dump(data, f, indent=4)


def main():
    access_token = get_access_token()

    users = fetch_data("users", access_token)
    save_json("users.json", users)
    print("Saved users.json")

    roles = fetch_data("roles", access_token)
    save_json("roles.json", roles)
    print("Saved roles.json")


if __name__ == "__main__":
    main()
