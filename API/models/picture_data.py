from pydantic import BaseModel, HttpUrl

from models.scout_info import ScoutInfo


class PictureData(BaseModel):
    scout_info: ScoutInfo
    team_number: int
    time: int
    event_code: str
    image_id: str
    link: str
    permissions: list[str] = []
