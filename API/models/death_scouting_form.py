from pydantic import BaseModel


class Death(BaseModel):
    match_number: int
    severity: int
    death_reason: str


class DeathScoutingForm (BaseModel):
    user_id: str
    event_code: str
    team_key: str
    team_number: str
    deaths: list[Death]
    total: int
    time: int
