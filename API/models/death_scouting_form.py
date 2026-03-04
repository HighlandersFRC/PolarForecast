from pydantic import BaseModel, field_validator

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
    average: int
    time: int
    @field_validator("time", mode="before")
    def cast_time_to_int(cls, v):
        if isinstance(v, float):
            return int(v)
        return v
