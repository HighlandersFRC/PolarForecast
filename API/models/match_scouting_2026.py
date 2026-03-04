from pydantic import BaseModel, Field
from typing import List, Optional, Union

from models.scout_info import ScoutInfo
from models.pit_scouting_2026 import Auto2026


class Scoring2026(BaseModel):
    fuel_cycles: int = 0
    passing_cycles: int = 0
    scoring_cycles: int = 0
    cycles_completed: int = 0
   

class Miscellaneous2026(BaseModel):
    died: bool = False
    defense: bool = False
    comments: str = ""


class Data2026(BaseModel):
    auto: Auto2026
    auto_scoring: Scoring2026 = Field(default_factory=Scoring2026)
    teleop_scoring: Scoring2026 = Field(default_factory=Scoring2026)
    miscellaneous: Miscellaneous2026 = Field(default_factory=Miscellaneous2026)
    # Add selectedPieces if your code references it
    selectedPieces: Optional[List] = []


class MatchScouting2026(BaseModel):
    event_code: str
    team_number: int
    match_number: int
    scout_info: ScoutInfo
    data: Data2026
    time: int = 0  # Will be set by server, so default is fine
    