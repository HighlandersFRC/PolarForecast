from pydantic import BaseModel
from typing import List, Optional, Union

from models.scout_info import ScoutInfo


class ExtraData2025(BaseModel):
    position: Union[str, int, None] = None
    processor_side: Optional[bool] = None
    algae: Optional[bool] = None
    coral: Optional[bool] = None


class PitAutoStep2025(BaseModel):
    name: str
    extra_data: ExtraData2025


class Auto2025(BaseModel):
    starting_position_meters_from_processor: float
    steps: List[PitAutoStep2025]
    field_side: List[str]
    exit: bool
    preload: bool
    both_sides: bool = False


class PitData2025(BaseModel):
    driver_experience_events: int
    drive_train: str
    can_score_coral: bool
    coral_levels: List[int]
    can_score_processor: bool
    can_score_net: bool
    ground_coral_pickup: bool
    feeder_coral_pickup: bool
    ground_algae_pickup: bool
    reef_algae_pickup: bool
    climbing: List[str]
    spare_parts: int
    favorite_color: str
    autos: List[Auto2025]


class PitScouting2025(BaseModel):
    scout_info: ScoutInfo
    team_number: int
    time: int
    event_code: str
    data: PitData2025
