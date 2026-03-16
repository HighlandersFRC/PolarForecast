from pydantic import BaseModel, Field
from typing import List, Optional


class AllianceGroup(BaseModel):
    group_id: str
    name: str
    affiliation: str



class Picks(BaseModel):
    number: str
    comments: str


class PickList2026(BaseModel):
    picklist_id: str 
    name: str
    picks: List[Picks]

    class Config:
        allow_population_by_field_name = True


class GroupEventSettings(BaseModel):
    crowd_sourced_match_scouting: bool
    crowd_sourced_pit_scouting: bool


class GroupEvent(BaseModel):
    event_code: str
    up_to_date: bool
    settings: GroupEventSettings
    alliance_groups: List[AllianceGroup]

    picklists: Optional[List[PickList2026]] = []



class GroupSettings(BaseModel):
    approve_new_members: bool


class Group(BaseModel):
    group_id: str
    owner_group_id: str
    admin_group_id: str
    member_group_id: str
    name: str
    affiliation: str
    join_code: Optional[str] = None
    events: List[GroupEvent]
    settings: GroupSettings
    last_update: int = 0
    join_code_expiration: int = 0