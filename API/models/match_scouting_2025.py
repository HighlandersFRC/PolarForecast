from pydantic import BaseModel, Field
from typing import List, Optional, Union


class ExtraData(BaseModel):
    position: Union[str, int, None] = None
    processor_side: Optional[bool] = None
    algae: Optional[bool] = None
    coral: Optional[bool] = None


class Step(BaseModel):
    name: str
    extra_data: ExtraData


class Auto(BaseModel):
    starting_position_meters_from_processor: float
    steps: List[Step]
    field_side: List[str]
    exit: bool
    preload: bool


class Scoring(BaseModel):
    l_1: int
    l_2: int
    l_3: int
    l_4: int
    net: int
    processor: int


class Miscellaneous(BaseModel):
    died: bool
    comments: str


class Data(BaseModel):
    auto: Auto
    auto_scoring: Scoring
    teleop_scoring: Scoring
    miscellaneous: Miscellaneous


class ScoutInfo(BaseModel):
    user_id: str
    first_name: str
    username: str
    team_number: int


class MatchScouting2025(BaseModel):
    event_code: str
    team_number: int
    match_number: int
    scout_info: ScoutInfo
    data: Data
    time: int
    active: bool
