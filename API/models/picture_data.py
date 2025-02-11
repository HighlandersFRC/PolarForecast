from pydantic import BaseModel, HttpUrl


class PictureData(BaseModel):
    user_id: str
    team_number: int
    time: int
    event_code: str
    image_id: str
    link: str
    permissions: list[str]
