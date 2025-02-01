from pydantic import BaseModel


class GroupJoinRequest(BaseModel):
    group_name: str
    group_id: str
    user_id: str
    username: str
    accepted: bool
    request_time: int
