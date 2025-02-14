from pydantic import BaseModel, Field
from typing import List, Optional, Union

from models.scout_info import ScoutInfo
from models.pit_scouting_2025 import Auto2025


class Scoring2025(BaseModel):
    l_1: int
    l_2: int
    l_3: int
    l_4: int
    net: int
    processor: int


class Miscellaneous2025(BaseModel):
    died: bool
    comments: str


class Data2025(BaseModel):
    auto: Auto2025
    auto_scoring: Scoring2025
    teleop_scoring: Scoring2025
    miscellaneous: Miscellaneous2025


class MatchScouting2025(BaseModel):
    event_code: str
    team_number: int
    match_number: int
    scout_info: ScoutInfo
    data: Data2025
    time: int
