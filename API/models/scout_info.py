from pydantic import BaseModel


class ScoutInfo(BaseModel):
    user_id: str
    first_name: str
    username: str
    team_number: int
