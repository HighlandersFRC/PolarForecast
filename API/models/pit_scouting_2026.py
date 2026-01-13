from pydantic import BaseModel
from typing import List, Optional, Union

from models.scout_info import ScoutInfo


class ExtraData2026(BaseModel):
    position: Union[str, int, None] = None
    climb_side: Optional[int] = None


class PitAutoStep2026(BaseModel):
    name: str
    extra_data: ExtraData2026


class Auto2026(BaseModel):
    starting_position_meters_from_processor: float
    starting_position_meters_from_processor: Optional[float] = 0 
    steps: List[PitAutoStep2026]
    field_side: List[str]
    exit: bool
    preload: bool
    both_sides: bool = False
    exit: Optional[bool] = False 


class PitData2026(BaseModel):
    driver_experience_events: int
    drive_train: str
    holding_capacity: int
    shooting_speed: int
    cycles_25_seconds: int
    main_stratage: str
    fit_under_trench: bool
    goes_over_bump: bool
    cycle_time: int
    climbing: List[str]
    spare_parts: int
    favorite_color: str
    autos: List[Auto2026]


class PitScouting2026(BaseModel):
    scout_info: ScoutInfo
    team_number: int
    time: int
    event_code: str
    data: PitData2026
