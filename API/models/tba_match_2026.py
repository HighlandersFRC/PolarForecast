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
    
    # ===== ACTUAL TBA API FIELDS (2026 Reefscape) =====
    adjustPoints: Optional[int] = 0
    algaeNetCount: Optional[int] = 0
    algaeProcessorCount: Optional[int] = 0
    autoAlgaeNet: Optional[int] = 0
    autoAlgaeProcessor: Optional[int] = 0
    autoCoralL1: Optional[int] = 0
    autoCoralL2: Optional[int] = 0
    autoCoralL3: Optional[int] = 0
    autoCoralL4: Optional[int] = 0
    autoPoints: Optional[int] = 0
    barge: Optional[str] = None
    cageStatus: Optional[str] = None
    coopertitionBonusAchieved: Optional[bool] = False
    coopertitionCriteriaMet: Optional[bool] = False
    coralL1Count: Optional[int] = 0
    coralL2Count: Optional[int] = 0
    coralL3Count: Optional[int] = 0
    coralL4Count: Optional[int] = 0
    endGamePoints: Optional[int] = 0
    foulCount: Optional[int] = 0
    foulPoints: Optional[int] = 0
    netPoints: Optional[int] = 0
    processorPoints: Optional[int] = 0
    rp: Optional[int] = 0
    techFoulCount: Optional[int] = 0
    teleopAlgaeNet: Optional[int] = 0
    teleopAlgaeProcessor: Optional[int] = 0
    teleopCoralL1: Optional[int] = 0
    teleopCoralL2: Optional[int] = 0
    teleopCoralL3: Optional[int] = 0
    teleopCoralL4: Optional[int] = 0
    teleopPoints: Optional[int] = 0
    totalPoints: Optional[int] = 0
    wallAlgaeCount: Optional[int] = 0
    
    # ===== CUSTOM SCOUTING FIELDS (not from TBA) =====
    climb: Optional[bool] = False
    feed_amount: Optional[int] = 0
    intake_amount: Optional[int] = 0
    shoot_amount: Optional[int] = 0
    goes_under_trench: Optional[bool] = False
    goes_over_bump: Optional[bool] = False
    climb_side: Optional[int] = 0
    cycles_completed: Optional[int] = 0
    shoots_from_X: Optional[int] = 0
    shoot_from_Y: Optional[int] = 0
    
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