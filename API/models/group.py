from pydantic import BaseModel
from typing import List, Optional


class AllianceGroup(BaseModel):
    group_id: str
    name: str
    affiliation: str


class GroupEventSettings(BaseModel):
    crowd_sourced_match_scouting: bool
    crowd_sourced_pit_scouting: bool


class GroupEvent(BaseModel):
    event_code: str
    settings: GroupEventSettings
    alliance_groups: List[AllianceGroup]


class GroupSettings(BaseModel):
    approve_new_members: bool


class Group(BaseModel):
    group_id: str
    owner_group_id: str
    admin_group_id: str
    member_group_id: str
    name: str
    affiliation: str
    join_code: Optional[str]
    events: List[GroupEvent]
    settings: GroupSettings
