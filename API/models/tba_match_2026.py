from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Literal


class AllianceDetails(BaseModel):
    dq_team_keys: List[str]
    score: int
    surrogate_team_keys: List[str]
    team_keys: List[str]



class ScoreBreakdown2026(BaseModel):
    climb: bool
    feed_amount: int
    intake_amount: int
    shoot_amount: int
    goes_under_trench: bool
    goes_over_bump: bool
    climb_side: int
    cycles_completed: int
    shoots_from_X: int
    shoot_from_Y: int

class TBAMatch2026(BaseModel):
    actual_time: int | None
    alliances: Dict[Literal["blue", "red"], AllianceDetails]
    comp_level: str
    event_key: str
    key: str
    match_number: int
    post_result_time: int | None
    predicted_time: int | None
    score_breakdown: Dict[Literal["blue", "red"], ScoreBreakdown2026] | None
    set_number: int
    time: int | None
    videos: List[dict] | None
    winning_alliance: Literal["red", "blue", ""]
