import copy
from datetime import datetime
import numpy as np
import pandas as pd

from models.pit_scouting_2026 import Auto2026
from models.scout_info import ScoutInfo
from models.match_scouting_2026 import Data2026, MatchScouting2026, Miscellaneous2026, Scoring2026


def dataOPR(scoutData: MatchScouting2026) -> int:
    auto = scoutData.data.auto_scoring
    teleop = scoutData.data.teleop_scoring
    opr = auto.fuel_scored + teleop.fuel_scored
    return opr


def removeOutliers(data: list[MatchScouting2026]) -> list[MatchScouting2026]:
    teams = []
    teamEntryList: list[list[tuple[int, MatchScouting2026]]] = []
    for entry in data:
        if not teams.__contains__(entry.team_number):
            teams.append(entry.team_number)
            teamEntryList.append([])
    for entry in data:
        teamEntryList[teams.index(entry.team_number)].append(
            (dataOPR(entry), entry))
    noOutliers: list[list[MatchScouting2026]] = []
    for teamEntries in teamEntryList:
        noOutliers.append(remove_outliers_iqr(teamEntries))
    retval: list[MatchScouting2026] = []
    for teamEntries in noOutliers:
        for entry in teamEntries:
            retval.append(entry)
    return retval


def remove_outliers_iqr(data: list[tuple[int, MatchScouting2026]]) -> list[MatchScouting2026]:
    opr_values = np.array([opr for opr, entry in data])
    q1 = np.percentile(opr_values, 25)
    q3 = np.percentile(opr_values, 75)
    iqr = q3 - q1
    threshold = 1.5
    outlier_indices = np.where(
        (opr_values < q1 - threshold * iqr) | (opr_values > q3 + threshold * iqr))[0]
    filtered_entries = [entry for index, (opr, entry) in enumerate(
        data) if not index in outlier_indices]
    return filtered_entries


def remove_outliers(data: list[tuple[int, MatchScouting2026]]) -> list[MatchScouting2026]:
    opr_values = np.array([opr for opr, entry in data])
    z_scores = (opr_values - np.mean(opr_values)) / np.std(opr_values)
    threshold = 3
    outlier_indices = np.where(np.abs(z_scores) > threshold)[0]
    filtered_entries = [entry for index, (opr, entry) in enumerate(
        data) if not index in outlier_indices]
    return filtered_entries


def flatten_dict(dd, separator="_", prefix=""):
    return (
        {
            prefix + separator + k if prefix else k: v
            for kk, vv in dd.items()
            for k, v in flatten_dict(vv, separator, kk).items()
        }
        if isinstance(dd, dict)
        else {prefix: dd}
    )


def average(lst: list):
    numeric_values = [x for x in lst if isinstance(x, (int, float))]
    if len(numeric_values) == 0:
        return 0
    else:
        return sum(numeric_values) / len(numeric_values)

def tower_to_points(tower_str):
            return {"Level1": 15, "Level2": 15, "Level3": 15}.get(tower_str, 0)

def getError(combination: dict[str, MatchScouting2026], tba_match: pd.Series) -> float:
    error = 0
    total = 0
    errorPercent = 1.0
    data = []
    for team in combination:
        data.append(flatten_dict(combination[team].data.dict(
            exclude={'auto', 'miscellaneous'})))

    fuel_scored = 0
    for i in range(3):
        fuel_scored += data[i]['auto_scoring_fuel_scored']
        fuel_scored += data[i]['teleop_scoring_fuel_scored']

    auto_climb_points = tower_to_points(tba_match['station1_auto_tower']) +  tower_to_points(tba_match['station2_auto_tower']) + tower_to_points(tba_match['station3_auto_tower'])
    

    tba_total = auto_climb_points + tba_match['auto_fuel_scored'] + tba_match['teleop_fuel_scored'] + tba_match['endgame_scoring']

    error += abs(tba_total - fuel_scored)
    total += abs(tba_total)

    if total > 0:
        errorPercent = error / total
    return errorPercent

def getScoutRatings(TBAData: pd.DataFrame, scoutingData: list[MatchScouting2026]) -> dict:
    scouts = []
    scoutTrusts: list[list[float]] = []
    scoutTrustRatings = []
    TBADict = TBAData.to_dict("records")
    for entry in scoutingData:
        if not (scouts.__contains__(entry.scout_info.user_id)):
            scouts.append(entry.scout_info.user_id)
    for i in range(len(scouts)):
        scoutTrusts.append([])
        scoutTrustRatings.append(0)
    for game in TBADict:
        entries: list[MatchScouting2026] = []
        teamEntries: dict[int, list[MatchScouting2026]] = {}
        teams: list[int] = []
        for entry in scoutingData:
            if entry.match_number == game["match_number"]:
                for i in range(3):
                    if (
                        game["station" + str(i + 1)]
                        == str(entry.team_number)
                    ):
                        entries.append(entry)
                        if not teams.__contains__(entry.team_number):
                            teams.append(entry.team_number)
                        break
        for entry in entries:
            teamEntries[entry.team_number] = []
        for entry in entries:
            teamEntries[entry.team_number].append(entry)
        combinations: list[dict[int, MatchScouting2026]] = []
        if len(teams) == 3:
            for team0 in teamEntries[teams[0]]:
                for team1 in teamEntries[teams[1]]:
                    for team2 in teamEntries[teams[2]]:
                        combinations.append(
                            {teams[0]: team0, teams[1]: team1, teams[2]: team2}
                        )
            combinationError = []
            for i in range(len(combinations)):
                combinationError.append(getError(combinations[i], game))
            combinationTrust = [
                1 - combinationError[i] for i in range(len(combinationError))
            ]
            for i in range(len(combinations)):
                for entry in combinations[i]:
                    scoutTrusts[
                        scouts.index(combinations[i][entry].scout_info.user_id)
                    ].append(combinationTrust[i])
        for i in range(len(teams)):
            if not len(teamEntries[teams[i]]) == 1:
                teamAverage = {}
                for entry in teamEntries[teams[i]]:
                    flattenedEntry = flatten_dict(
                        entry.data.dict(exclude={'auto', 'miscellaneous'}))

                    for field in flattenedEntry:
                        if isinstance(flattenedEntry[field], (int, float)):
                            teamAverage[field] = 0

                for entry in teamEntries[teams[i]]:
                    flattenedEntry = flatten_dict(
                        entry.data.dict(exclude={'auto', 'miscellaneous'}))

                    for field in flattenedEntry:
                        if isinstance(flattenedEntry[field], (int, float)):
                            teamAverage[field] += flattenedEntry[field]

                for field in teamAverage:
                    teamAverage[field] /= len(teamEntries[teams[i]])
                for entry in teamEntries[teams[i]]:
                    flattenedEntry = flatten_dict(
                        entry.data.dict(exclude={'auto', 'miscellaneous'}))
                    entryTrust = []
                    for field in flattenedEntry:
                        if teamAverage[field] == 0:
                            entryTrust.append(1)
                        else:
                            entryTrust.append(
                                1
                                - (
                                    abs(flattenedEntry[field] -
                                        teamAverage[field])
                                    / teamAverage[field]
                                )
                            )
                    scoutTrusts[scouts.index(entry.scout_info.user_id)].append(
                        average(entryTrust)
                    )
    for i in range(len(scouts)):
        scoutTrustRatings[i] = average(scoutTrusts[i])
    retval = {"scouts": scouts, "trustRatings": scoutTrustRatings}
    return retval


def getMarkovianRatings(TBAData: pd.DataFrame, scoutingData: list[MatchScouting2026]):
    scoutingData = copy.deepcopy(scoutingData)
    scoutRatings = getScoutRatings(TBAData, scoutingData)
    for j in range(10):
        scouts = scoutRatings["scouts"]
        oldTrustRatings = scoutRatings["trustRatings"]
        scoutTrusts = []
        scoutTrustRatings = []
        TBADict = TBAData.to_dict("records")
        for entry in scoutingData:
            if not (scouts.__contains__(entry.scout_info.user_id)):
                scouts.append(entry.scout_info.user_id)
        for i in range(len(scouts)):
            scoutTrusts.append([])
            scoutTrustRatings.append(0)
        for game in TBADict:
            entries: list[MatchScouting2026] = []
            teamEntries: dict[int, list[MatchScouting2026]] = {}
            teams: list[int] = []
            for entry in scoutingData:
                if entry.match_number == game["match_number"]:
                    for i in range(3):
                        if (
                            game["station" + str(i + 1)]
                            == str(entry.team_number)
                        ):
                            entries.append(entry)
                            if not teams.__contains__(
                                entry.team_number
                            ):
                                teams.append(entry.team_number)
                            break
            for entry in entries:
                teamEntries[entry.team_number] = []
            for entry in entries:
                teamEntries[entry.team_number].append(entry)
            combinations: list[dict[int, MatchScouting2026]] = []
            if len(teams) == 3:
                for team0 in teamEntries[teams[0]]:
                    for team1 in teamEntries[teams[1]]:
                        for team2 in teamEntries[teams[2]]:
                            combinations.append(
                                {teams[0]: team0, teams[1]: team1, teams[2]: team2}
                            )
                combinationError = []
                for i in range(len(combinations)):
                    combinationError.append(getError(combinations[i], game))
                combinationTrust = [
                    1 - combinationError[i] for i in range(len(combinationError))
                ]
                for i in range(len(combinations)):
                    for entry in combinations[i]:
                        scoutTrusts[
                            scouts.index(
                                combinations[i][entry].scout_info.user_id
                            )
                        ].append(combinationTrust[i])
            for i in range(len(teams)):
                if not len(teamEntries[teams[i]]) == 1:
                    teamAverage = {}
                    for entry in teamEntries[teams[i]]:
                        flattenedEntry = flatten_dict(
                            entry.data.dict(exclude={'auto', 'miscellaneous'}))
                        for field in flattenedEntry:
                            teamAverage[field] = 0
                    totalTrust = 0
                    for entry in teamEntries[teams[i]]:
                        flattenedEntry = flatten_dict(
                            entry.data.dict(exclude={'auto', 'miscellaneous'}))
                        totalTrust += oldTrustRatings[scoutRatings["scouts"].index(
                            entry.scout_info.user_id)]
                        for field in flattenedEntry:
                            teamAverage[field] += flattenedEntry[field] * \
                                oldTrustRatings[scoutRatings["scouts"].index(
                                    entry.scout_info.user_id)]
                    for field in teamAverage:
                        if totalTrust == 0:
                            teamAverage[field] = 0
                        else:
                            teamAverage[field] /= totalTrust
                    for entry in teamEntries[teams[i]]:
                        flattenedEntry = flatten_dict(
                            entry.data.dict(exclude={'auto', 'miscellaneous'}))
                        entryTrust = []
                        for field in flattenedEntry:
                            if teamAverage[field] == 0:
                                entryTrust.append(1)
                            else:
                                entryTrust.append(
                                    1
                                    - (
                                        abs(flattenedEntry[field] -
                                            teamAverage[field])
                                        / teamAverage[field]
                                    )
                                )
                        scoutTrusts[scouts.index(entry.scout_info.user_id)].append(
                            average(entryTrust)
                        )
        for i in range(len(scouts)):
            rating = average(scoutTrusts[i])
            if rating > 1:
                rating = 1
            scoutTrustRatings[i] = rating
        scoutRatings = {"scouts": scouts, "trustRatings": scoutTrustRatings}
    return scoutRatings


def TeamBasedData(TBAData: pd.DataFrame, scoutingData: list[MatchScouting2026]) -> tuple[list[MatchScouting2026], list]:
    teams = []
    retval = []
    scoutRatings = getMarkovianRatings(TBAData, scoutingData)
    scoutingData = removeOutliers(scoutingData)
    for entry in scoutingData:
        if not teams.__contains__(entry.team_number):
            teams.append(entry.team_number)
    for team in teams:
        teamEntries: dict[int, list[MatchScouting2026]] = {}
        for entry in scoutingData:
            if entry.team_number == team:
                teamEntries[entry.match_number] = []
        for entry in scoutingData:
            if entry.team_number == team:
                teamEntries[entry.match_number].append(entry)
        for match in teamEntries:
            returnEntry = MatchScouting2026(event_code='', team_number=team, match_number=match, 
                                            scout_info=ScoutInfo(user_id="", first_name="", username="", team_number=0), 
                                            data=Data2026(
                                                auto=Auto2026(starting_position_meters_from_hub_center=0, field_side=[], preload=False, both_sides=False, contacts_robot=False, auto_pieces=0, climb=False, steps=[]), 
                                                auto_scoring=Scoring2026(fuel_scored=0, fuel_scored_hopper=0, hopper_capacity=0), 
                                            teleop_scoring=Scoring2026(fuel_scored=0, fuel_scored_hopper=0, hopper_capacity=0), 
                                            miscellaneous=Miscellaneous2026(died=False, defense=False, comments="")), time=0)
            totalTrust = 0
            for entry in teamEntries[match]:
                entryTrust = scoutRatings["trustRatings"][scoutRatings["scouts"].index(
                    entry.scout_info.user_id)]
                totalTrust += entryTrust
                returnEntry.data.auto_scoring.fuel_scored += entry.data.auto_scoring.fuel_scored*entryTrust
                returnEntry.data.teleop_scoring.fuel_scored += entry.data.teleop_scoring.fuel_scored*entryTrust
            retval.append(returnEntry)
    return retval, scoutRatings