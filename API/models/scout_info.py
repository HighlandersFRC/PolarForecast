from pydantic import BaseModel


class ScoutInfo(BaseModel):
    user_id: str
    first_name: str | None
    username: str | None
    team_number: int
