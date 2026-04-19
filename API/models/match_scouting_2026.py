from pydantic import BaseModel, Field, root_validator
from typing import List, Optional, Union

from models.scout_info import ScoutInfo
from models.pit_scouting_2026 import Auto2026
from models.pit_scouting_2026 import PitData2026


class Scoring2026(BaseModel):
    fuel_scored: int = 0
    fuel_scored_hopper: int = 0
    hopper_capacity: int = 32

    @root_validator
    def calculate_fuel_scored(cls, values):
        hopper = values.get('fuel_scored_hopper', 0)
        capacity = values.get('hopper_capacity', 32)
        values['fuel_scored'] = int((hopper / 100) * capacity)
        return values

class Miscellaneous2026(BaseModel):
    died: bool = False
    defense: bool = False
    comments: str = ""


class Data2026(BaseModel):
    auto: Auto2026
    auto_scoring: Scoring2026 = Field(default_factory=Scoring2026)
    teleop_scoring: Scoring2026 = Field(default_factory=Scoring2026)
    miscellaneous: Miscellaneous2026 = Field(default_factory=Miscellaneous2026)


class MatchScouting2026(BaseModel):
    event_code: str
    team_number: int
    match_number: int
    scout_info: ScoutInfo
    data: Data2026
    time: float = 0