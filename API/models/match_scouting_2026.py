from pydantic import BaseModel, Field
from typing import List, Optional, Union

from models.scout_info import ScoutInfo
from models.pit_scouting_2026 import Auto2026


class Scoring2026(BaseModel):
    shoot_amount: int
    cycles_completed: int
    shoots_from_X: int
    shoot_from_Y: int


class Miscellaneous2026(BaseModel):
    died: bool
    comments: str


class Data2025(BaseModel):
    auto: Auto2026
    auto_scoring: Scoring2026
    teleop_scoring: Scoring2026
    miscellaneous: Miscellaneous2026


class MatchScouting2026(BaseModel):
    event_code: str
    team_number: int
    match_number: int
    scout_info: ScoutInfo
    data: Data2025
    time: int
