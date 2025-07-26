from typing import List, Optional
from pydantic import BaseModel


class AllianceData2025(BaseModel):
    teams: List[str]
    human_player: int
    dq_team_keys: List[str]
    surrogate_team_keys: List[str]
    mobility: int
    score: int
    actual_score: Optional[int] = None
    climbing: int
    auto_points: int
    teleop_points: int
    endgame_points: int
    coopertition: int
    coral_l_1: int
    coral_l_2: int
    coral_l_3: int
    coral_l_4: int
    processor: int
    net: int
    auto_coral: int
    win_rp: int
    auto_rp: int
    coral_rp: int
    barge_rp: int
    total_rp: int
    display_rp: int


class MatchPrediction2025(BaseModel):
    comp_level: str
    key: str
    match_number: int
    set_number: int
    blue: AllianceData2025
    red: AllianceData2025
    predicted: bool
