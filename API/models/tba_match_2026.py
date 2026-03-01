from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Literal
from enum import Enum


class AllianceDetails(BaseModel):
    dq_team_keys: List[str] = []
    score: int 
    surrogate_team_keys: List[str] = []
    team_keys: List[str] = []


class HubScore(BaseModel):
    autoCount: int
    autoPoints: int
    endgameCount: int
    endgamePoints: int
    shift1Count: int
    shift1Points: int
    shift2Count: int
    shift2Points: int
    shift3Count: int
    shift3Points: int
    shift4Count: int
    shift4Points: int
    teleopCount: int
    totalCount: int
    totalPoints: int
    transitionCount: int
    transitionPoints: int
    uncounted: int




class ScoreBreakdown2026(BaseModel):
    """Score breakdown for 2026 FRC game - Rebuilt
    Includes TBA Feilds"""
    
    adjustPoints: int
    autoTowerPoints: int
    autoTowerRobot1: str
    autoTowerRobot2: str
    autoTowerRobot3: str
    endGameTowerPoints: int
    endGameTowerRobot1: str
    endGameTowerRobot2: str
    endGameTowerRobot3: str
    energizedAchieved: bool
    foulPoints: int
    g206Penalty: bool
    hubScore: HubScore
    majorFoulCount: int
    minorFoulCount: int
    penalties: str
    rp: int
    superchargedAchieved: bool
    totalAutoPoints: int
    totalPoints: int
    totalTeleopPoints: int
    totalTowerPoints: int
    traversalAchieved: bool
    
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