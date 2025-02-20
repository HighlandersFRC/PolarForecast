from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Literal


class AllianceDetails(BaseModel):
    dq_team_keys: List[str]
    score: int
    surrogate_team_keys: List[str]
    team_keys: List[str]


class ReefLevel(BaseModel):
    nodeA: bool
    nodeB: bool
    nodeC: bool
    nodeD: bool
    nodeE: bool
    nodeF: bool
    nodeG: bool
    nodeH: bool
    nodeI: bool
    nodeJ: bool
    nodeK: bool
    nodeL: bool


class ReefData(BaseModel):
    botRow: ReefLevel
    midRow: ReefLevel
    topRow: ReefLevel
    trough: int


class ScoreBreakdown2025(BaseModel):
    adjustPoints: int
    algaePoints: int
    autoBonusAchieved: bool
    autoCoralCount: int
    autoCoralPoints: int
    autoLineRobot1: str
    autoLineRobot2: str
    autoLineRobot3: str
    autoMobilityPoints: int
    autoPoints: int
    autoReef: ReefData
    bargeBonusAchieved: bool
    coopertitionCriteriaMet: bool
    coralBonusAchieved: bool
    endGameBargePoints: int
    endGameRobot1: str
    endGameRobot2: str
    endGameRobot3: str
    foulCount: int
    foulPoints: int
    g206Penalty: bool
    g408Penalty: bool
    g424Penalty: bool
    netAlgaeCount: int
    rp: int
    techFoulCount: int
    teleopCoralCount: int
    teleopCoralPoints: int
    teleopPoints: int
    teleopReef: ReefData
    totalPoints: int
    wallAlgaeCount: int


class TBAMatch2025(BaseModel):
    actual_time: int | None
    alliances: Dict[Literal["blue", "red"], AllianceDetails]
    comp_level: str
    event_key: str
    key: str
    match_number: int
    post_result_time: int | None
    predicted_time: int | None
    score_breakdown: Dict[Literal["blue", "red"], ScoreBreakdown2025] | None
    set_number: int
    time: int | None
    videos: List[dict] | None
    winning_alliance: Literal["red", "blue", ""]
