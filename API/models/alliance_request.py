from pydantic import BaseModel


class AllianceRequest(BaseModel):
    group_1: str
    group_2: str
    group_1_affiliation: str
    group_2_affiliation: str
    event: str
    request_time: int
    accepted: bool
