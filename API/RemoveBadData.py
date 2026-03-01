import copy
import numpy as np
import pandas as pd
from typing import List, Dict, Tuple

from models.match_scouting_2026 import (
    MatchScouting2026,
    Data2026,
    Scoring2026,
    Miscellaneous2026
)
from models.pit_scouting_2026 import Auto2026
from models.scout_info import ScoutInfo


# ============================================================
# Utility Functions
# ============================================================

def flatten_dict(dd, separator="_", prefix=""):
    if isinstance(dd, dict):
        return {
            f"{prefix}{separator}{k}" if prefix else k: v
            for kk, vv in dd.items()
            for k, v in flatten_dict(vv, separator, kk).items()
        }
    else:
        return {prefix: dd}


def numeric_average(values: List[float]) -> float:
    nums = [v for v in values if isinstance(v, (int, float))]
    return sum(nums) / len(nums) if nums else 0


# ============================================================
# OPR Approximation (Cycle-Based)
# ============================================================

def dataOPR(entry: MatchScouting2026) -> float:
    auto = entry.data.auto_scoring
    teleop = entry.data.teleop_scoring

    # Tunable weights
    return (
        auto.fuel_cycles * 1
        + teleop.fuel_cycles * 1    
    )


# ============================================================
# Outlier Removal (IQR per Team)
# ============================================================

def remove_outliers_iqr(entries: List[MatchScouting2026]) -> List[MatchScouting2026]:
    if len(entries) < 4:
        return entries

    opr_values = np.array([dataOPR(e) for e in entries])

    q1 = np.percentile(opr_values, 25)
    q3 = np.percentile(opr_values, 75)
    iqr = q3 - q1

    lower = q1 - 1.5 * iqr
    upper = q3 + 1.5 * iqr

    return [
        entry for entry in entries
        if lower <= dataOPR(entry) <= upper
    ]


def removeOutliers(data: List[MatchScouting2026]) -> List[MatchScouting2026]:
    teams: Dict[int, List[MatchScouting2026]] = {}

    for entry in data:
        teams.setdefault(entry.team_number, []).append(entry)

    cleaned = []
    for team_entries in teams.values():
        cleaned.extend(remove_outliers_iqr(team_entries))

    return cleaned


# ============================================================
# Error Calculation (Dynamic Field-Based)
# ============================================================

def getError(
    combination: Dict[int, MatchScouting2026],
    TBAMatch: pd.Series
) -> float:

    error = 0
    total = 0

    flattened = [
        flatten_dict(
            combination[team].data.dict(
                exclude={"auto", "miscellaneous", "selectedPieces"}
            )
        )
        for team in combination
    ]

    combined = {}
    for entry in flattened:
        for field, value in entry.items():
            if isinstance(value, (int, float)):
                combined[field] = combined.get(field, 0) + value

    for field in combined:
        if field in TBAMatch:
            error += abs(TBAMatch[field] - combined[field])
            total += abs(TBAMatch[field])

    if total == 0:
        return 1.0

    return error / total


# ============================================================
# Scout Trust Ratings
# ============================================================

def getScoutRatings(
    TBAData: pd.DataFrame,
    scoutingData: List[MatchScouting2026]
) -> Dict:

    scouts = list({entry.scout_info.user_id for entry in scoutingData})
    scoutTrusts = {scout: [] for scout in scouts}

    TBADict = TBAData.to_dict("records")

    for game in TBADict:

        entries = [
            entry for entry in scoutingData
            if entry.match_number == game["match_number"]
        ]

        teamEntries: Dict[int, List[MatchScouting2026]] = {}
        for entry in entries:
            teamEntries.setdefault(entry.team_number, []).append(entry)

        teams = list(teamEntries.keys())

        if len(teams) == 3:

            combinations = []
            for e0 in teamEntries[teams[0]]:
                for e1 in teamEntries[teams[1]]:
                    for e2 in teamEntries[teams[2]]:
                        combinations.append({
                            teams[0]: e0,
                            teams[1]: e1,
                            teams[2]: e2
                        })

            for combo in combinations:
                trust = 1 - getError(combo, game)
                for entry in combo.values():
                    scoutTrusts[entry.scout_info.user_id].append(trust)

        # Relative trust within same team
        for team, team_entries in teamEntries.items():

            if len(team_entries) <= 1:
                continue

            flattened = [
                flatten_dict(
                    e.data.dict(
                        exclude={"auto", "miscellaneous", "selectedPieces"}
                    )
                )
                for e in team_entries
            ]

            teamAverage = {}
            for entry in flattened:
                for field, value in entry.items():
                    if isinstance(value, (int, float)):
                        teamAverage[field] = teamAverage.get(field, 0) + value

            for field in teamAverage:
                teamAverage[field] /= len(team_entries)

            for entry, flat in zip(team_entries, flattened):
                entryTrust = []
                for field in flat:
                    if teamAverage[field] == 0:
                        entryTrust.append(1)
                    else:
                        entryTrust.append(
                            1 - abs(flat[field] - teamAverage[field]) / teamAverage[field]
                        )
                scoutTrusts[entry.scout_info.user_id].append(
                    numeric_average(entryTrust)
                )

    scoutRatings = {
        "scouts": scouts,
        "trustRatings": [
            numeric_average(scoutTrusts[scout])
            for scout in scouts
        ]
    }

    return scoutRatings


# ============================================================
# Markov Iterative Trust Refinement
# ============================================================

def getMarkovianRatings(
    TBAData: pd.DataFrame,
    scoutingData: List[MatchScouting2026],
    iterations: int = 8
):

    scoutRatings = getScoutRatings(TBAData, scoutingData)

    for _ in range(iterations):
        scouts = scoutRatings["scouts"]
        oldRatings = scoutRatings["trustRatings"]

        scoutTrusts = {scout: [] for scout in scouts}

        for entry in scoutingData:
            scoutTrusts[entry.scout_info.user_id].append(
                oldRatings[scouts.index(entry.scout_info.user_id)]
            )

        scoutRatings = {
            "scouts": scouts,
            "trustRatings": [
                min(1, numeric_average(scoutTrusts[scout]))
                for scout in scouts
            ]
        }

    return scoutRatings


# ============================================================
# Final Team-Based Aggregation
# ============================================================

def weighted_merge_scoring(target: Scoring2026, source: Scoring2026, weight: float):
    for field in source.model_fields:
        setattr(
            target,
            field,
            getattr(target, field) + getattr(source, field) * weight
        )


def TeamBasedData(
    TBAData: pd.DataFrame,
    scoutingData: List[MatchScouting2026]
) -> Tuple[List[MatchScouting2026], Dict]:

    scoutingData = removeOutliers(scoutingData)
    scoutRatings = getMarkovianRatings(TBAData, scoutingData)

    teams = list({entry.team_number for entry in scoutingData})
    results = []

    for team in teams:

        matches = list({
            entry.match_number
            for entry in scoutingData
            if entry.team_number == team
        })

        for match in matches:

            entries = [
                e for e in scoutingData
                if e.team_number == team and e.match_number == match
            ]

            merged = MatchScouting2026(
                event_code="",
                team_number=team,
                match_number=match,
                scout_info=ScoutInfo(
                    user_id="",
                    first_name="",
                    username="",
                    team_number=0
                ),
                data=Data2026(
                    auto=Auto2026(),
                    auto_scoring=Scoring2026(),
                    teleop_scoring=Scoring2026(),
                    miscellaneous=Miscellaneous2026()
                ),
                time=0
            )

            totalTrust = 0

            for entry in entries:
                trust = scoutRatings["trustRatings"][
                    scoutRatings["scouts"].index(entry.scout_info.user_id)
                ]

                totalTrust += trust

                weighted_merge_scoring(
                    merged.data.auto_scoring,
                    entry.data.auto_scoring,
                    trust
                )

                weighted_merge_scoring(
                    merged.data.teleop_scoring,
                    entry.data.teleop_scoring,
                    trust
                )

            if totalTrust > 0:
                for scoring in [
                    merged.data.auto_scoring,
                    merged.data.teleop_scoring
                ]:
                    for field in scoring.model_fields:
                        setattr(
                            scoring,
                            field,
                            getattr(scoring, field) / totalTrust
                        )

            results.append(merged)

    return results, scoutRatings