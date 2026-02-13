from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Literal


class AllianceDetails(BaseModel):
    dq_team_keys: List[str] = []
    score: int = -1
    surrogate_team_keys: List[str] = []
    team_keys: List[str] = []


class ScoreBreakdown2026(BaseModel):
    """Score breakdown for 2026 FRC game - Reefscape
    Includes both actual TBA fields and custom scouting fields"""
    
    
    # ===== CUSTOM SCOUTING FIELDS (not from TBA) =====
    climb: Optional[bool] = False
    feed_amount: Optional[int] = 0
    intake_amount: Optional[int] = 0
    shoot_amount: Optional[int] = 0
    goes_under_trench: Optional[bool] = False
    goes_over_bump: Optional[bool] = False
    climb_side: Optional[int] = 0
    cycles_completed: Optional[int] = 0
    shoots_from_X: Optional[float] = 0
    shoot_from_Y: Optional[float] = 0
    
    class Config:
        extra = "allow"  # Allow TBA to send additional fields


class TBAMatch2026(BaseModel):
    actual_time: Optional[int] = None
    alliances: Dict[Literal["blue", "red"], AllianceDetails]
    comp_level: str
    event_key: str
    key: str
    match_number: int
    post_result_time: Optional[int] = None
    predicted_time: Optional[int] = None
    score_breakdown: Optional[Dict[Literal["blue", "red"], ScoreBreakdown2026]] = None
    set_number: int
    time: Optional[int] = None
    videos: Optional[List[dict]] = []
    winning_alliance: Literal["red", "blue", ""] = ""
    
    class Config:
        extra = "allow"  # Allow TBA to send additional fields