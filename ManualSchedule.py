import json
import numpy as np
import pandas as pd


schedule = pd.read_csv("ManualSchedule.csv")
event_key = "2024code"
jsonData = []
for idx in schedule.index:
    data = {
        "actual_time": None,
        "alliances": {
            "blue": {
                "score": -1,
                "team_keys": [
                    "frc"+str(schedule["B1"][idx]),
                    "frc"+str(schedule["B2"][idx]),
                    "frc"+str(schedule["B3"][idx]),
                ]
            },
            "red": {
                "score": -1,
                "team_keys": [
                    "frc"+str(schedule["R1"][idx]),
                    "frc"+str(schedule["R2"][idx]),
                    "frc"+str(schedule["R3"][idx]),
                ]
            }
        },
        "comp_level": "qm",
        "event_key": event_key,
        "key": f"{event_key}_qm"+str(schedule["Match Number"][idx]),
        "match_number": schedule["Match Number"][idx],
        "post_result_time": None,
        "predicted_time": 0,
        "score_breakdown": None,
        "set_number": 1,
        "time": 0,
        "vidoes": [],
        "winning_alliance": ""
    }
    jsonData.append(data)
class NpEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.integer):
            return int(obj)
        if isinstance(obj, np.floating):
            return float(obj)
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        return super(NpEncoder, self).default(obj)
fp = open("ManualSchedule.json", "w")
json.dump(jsonData, fp, cls=NpEncoder)
fp.close()