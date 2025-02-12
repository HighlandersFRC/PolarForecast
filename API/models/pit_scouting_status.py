from pydantic import BaseModel


class PitScoutingStatus (BaseModel):
    key: str
    pit_status: str
    picture_status: str
    follow_up_status: str
