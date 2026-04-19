from pydantic import BaseModel, Field
from typing import List, Optional, Union


from models.scout_info import ScoutInfo



class ExtraData2026(BaseModel):
    position: Union[str, int, None] = None
    shots_from_x: Optional[float] = None
    shots_from_y: Optional[float] = None


class PitAutoStep2026(BaseModel):
    name: str
    extra_data: ExtraData2026
    
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
    climb_side: Optional[str] = "Does not climb"
    # Location-specific scoring fields (for charts)
    # l_1: Optional[int] = 0
    # l_2: Optional[int] = 0
    # l_3: Optional[int] = 0
    # l_4: Optional[int] = 0
    # net: Optional[int] = 0
    # processor: Optional[int] = 0

class Auto2026(BaseModel):
    starting_position_meters_from_hub_center: float
    field_side: List[str]
    preload: bool
    both_sides: bool = False
    contacts_robot: bool = False
    auto_pieces: int = 0
    climb: bool
    steps: List[PitAutoStep2026]

class PitData2026(BaseModel):
    driver_experience_events: int
    drive_train: str
    type_of_shooter: str
    fixedShooting: bool
    nearTower: bool
    nearHub: bool
    go_under_trench: bool
    can_climb: bool
    climbing: list[int]
    can_climb_in_autonomous: bool
    main_strategy: str
    spare_parts: int
    auto_scoring: Scoring2026 = Field(default_factory=Scoring2026)
    favorite_color: str
    autos: list
    hopper_capacity: int

    bps: Optional[float] = None

    robot_height: float

    comments: Optional[str] = None



    straddling_pole_climb_right: bool
    straddling_pole_climb_left: bool
    left_pole_climb: bool
    right_pole_climb: bool
    center_pole_climb: bool



class PitScouting2026(BaseModel):
    user_id: Optional[str] = None
    scout_info: Optional[ScoutInfo] = None
    team_number: Optional[int] = None
    time: Optional[Union[int, float]] = None
    event_code: Optional[str] = None
    data: Optional[PitData2026] = None
