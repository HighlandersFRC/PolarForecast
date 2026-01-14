from pydantic import BaseModel, Field
from typing import List, Optional, Union

from models.scout_info import ScoutInfo
from models.pit_scouting_2026 import Auto2026


class Scoring2026(BaseModel):
    shoot_amount: int = 0
    cycles_completed: int = 0
    shoots_from_X: float = 0
    shoots_from_Y: float = 0
    # Optional fields with defaults for backward compatibility
    feed_amount: Optional[int] = 0
    intake_amount: Optional[int] = 0
    goes_under_trench: Optional[int] = 0
    goes_over_bump: Optional[int] = 0
    climb_side: Optional[int] = 0
    # Location-specific scoring fields (for charts)
    l_1: Optional[int] = 0
    l_2: Optional[int] = 0
    l_3: Optional[int] = 0
    l_4: Optional[int] = 0
    net: Optional[int] = 0
    processor: Optional[int] = 0


class Miscellaneous2026(BaseModel):
    died: bool = False
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