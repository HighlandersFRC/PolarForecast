from pydantic import BaseModel

from models.scout_info import ScoutInfo


class Death(BaseModel):
    match_number: int
    severity: int = -1
    death_reason: str = ''


class DeathScoutingForm (BaseModel):
    scout_info: ScoutInfo
    event_code: str
    team_key: str
    deaths: list[Death] = []
    total: int
    average: float
    time: float
