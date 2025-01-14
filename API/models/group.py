from pydantic import BaseModel
from typing import List, Optional


class GroupEventSettings(BaseModel):
    crowd_sourced_match_scouting: bool
    crowd_sourced_pit_scouting: bool


class GroupEvent(BaseModel):
    event_code: str
    settings: GroupEventSettings


class GroupSettings(BaseModel):
    approve_new_members: bool


class Group(BaseModel):
    group_id: str
    owner_group_id: str
    admin_group_id: str
    member_group_id: str
    name: str
    join_code: str
    events: List[GroupEvent]
    settings: GroupSettings
