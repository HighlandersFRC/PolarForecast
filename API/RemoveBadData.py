import copy
from datetime import datetime
import numpy as np
import pandas as pd

from models.pit_scouting_2025 import Auto2025
from models.scout_info import ScoutInfo
from models.match_scouting_2025 import Data2025, MatchScouting2025, Miscellaneous2025, Scoring2025


def dataOPR(scoutData: MatchScouting2025) -> int:
    auto = scoutData.data.auto_scoring
    teleop = scoutData.data.teleop_scoring
    opr = 0
    opr += auto.l_1 * 3
    opr += auto.l_2 * 4
    opr += auto.l_3 * 6
    opr += auto.l_4 * 7
    opr += teleop.l_1 * 2
    opr += teleop.l_2 * 3
    opr += teleop.l_3 * 4
    opr += teleop.l_4 * 5
    opr += auto.processor * 6
    opr += teleop.net * 4
    return opr


def removeOutliers(data: list[MatchScouting2025]) -> list[MatchScouting2025]:
    teams = []
    teamEntryList: list[list[tuple[int, MatchScouting2025]]] = []
    for entry in data:
        if not teams.__contains__(entry.team_number):
            teams.append(entry.team_number)
            teamEntryList.append([])
    for entry in data:
        teamEntryList[teams.index(entry.team_number)].append(
            (dataOPR(entry), entry))
    noOutliers: list[list[MatchScouting2025]] = []
    for teamEntries in teamEntryList:
        noOutliers.append(remove_outliers_iqr(teamEntries))
    retval: list[MatchScouting2025] = []
    for teamEntries in noOutliers:
        for entry in teamEntries:
            retval.append(entry)
    return retval


def remove_outliers_iqr(data: list[tuple[int, MatchScouting2025]]) -> list[MatchScouting2025]:
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


def remove_outliers(data: list[tuple[int, MatchScouting2025]]) -> list[MatchScouting2025]:
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


def getError(combination: dict[str, MatchScouting2025], TBAMatch: pd.Series) -> float:
    error = 0
    total = 0
    errorPercent = 1.0
    data = []
    for team in combination:
        data.append(flatten_dict(combination[team].data.dict(
            exclude={'auto', 'miscellaneous'})))
    addedData = data[0]
    processor = 0
    for i in range(3):
        processor += data[i]['auto_scoring_processor']
        processor += data[i]['teleop_scoring_processor']
    error += abs(TBAMatch['processor']-processor)
    total += abs(TBAMatch["processor"])
    for field in addedData:
        if not field == "auto_scoring_net" and not field == "teleop_scoring_net":
            if not field == 'auto_scoring_processor' and not field == 'teleop_scoring_processor':
                addedData[field] = data[0][field] + \
                    data[1][field] + data[2][field]
                total += abs(TBAMatch[field])
                error += abs(TBAMatch[field] - addedData[field])
    if total > 0:
        errorPercent = error / total
    return errorPercent


def getScoutRatings(TBAData: pd.DataFrame, scoutingData: list[MatchScouting2025]) -> dict:
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
    # print("made list of all scouts")
    for game in TBADict:
        entries: list[MatchScouting2025] = []
        teamEntries: dict[int, list[MatchScouting2025]] = {}
        teams: list[int] = []
        # get combination-based error
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
        combinations: list[dict[int, MatchScouting2025]] = []
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
        # get relative scout error
        for i in range(len(teams)):
            if not len(teamEntries[teams[i]]) == 1:
                teamAverage = {}
                for entry in teamEntries[teams[i]]:
                    flattenedEntry = flatten_dict(
                        entry.data.dict(exclude={'auto', 'miscellaneous'}))
                    for field in flattenedEntry:
                        teamAverage[field] = 0
                for entry in teamEntries[teams[i]]:
                    flattenedEntry = flatten_dict(
                        entry.data.dict(exclude={'auto', 'miscellaneous'}))
                    for field in flattenedEntry:
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


def getMarkovianRatings(TBAData: pd.DataFrame, scoutingData: list[MatchScouting2025]):
    scoutingData = copy.deepcopy(scoutingData)
    scoutRatings = getScoutRatings(TBAData, scoutingData)
    # print("got one time ratings")
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
            entries: list[MatchScouting2025] = []
            teamEntries: dict[int, list[MatchScouting2025]] = {}
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
            # get combination-based error
            combinations: list[dict[int, MatchScouting2025]] = []
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
            # get comparative scout error
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


def TeamBasedData(TBAData: pd.DataFrame, scoutingData: list[MatchScouting2025]) -> tuple[list[MatchScouting2025], list]:
    teams = []
    retval = []
    # print("removed outliers")
    scoutRatings = getMarkovianRatings(TBAData, scoutingData)
    scoutingData = removeOutliers(scoutingData)
    # print("got markovian ratings")
    for entry in scoutingData:
        if not teams.__contains__(entry.team_number):
            teams.append(entry.team_number)
    # print("made list of teams")
    # print(teamMatches)
    for team in teams:
        teamEntries: dict[int, list[MatchScouting2025]] = {}
        for entry in scoutingData:
            if entry.team_number == team:
                teamEntries[entry.match_number] = []
        for entry in scoutingData:
            if entry.team_number == team:
                teamEntries[entry.match_number].append(entry)
        for match in teamEntries:
            returnEntry = MatchScouting2025(event_code='', team_number=team, match_number=match, scout_info=ScoutInfo(user_id="", first_name="", username="", team_number=0), data=Data2025(auto=Auto2025(starting_position_meters_from_processor=0.0, steps=[], field_side=[], exit=False, preload=False, both_sides=False,), auto_scoring=Scoring2025(
                l_1=0, l_2=0, l_3=0, l_4=0, net=0, processor=0), teleop_scoring=Scoring2025(l_1=0, l_2=0, l_3=0, l_4=0, net=0, processor=0), miscellaneous=Miscellaneous2025(died=False, comments="")), time=0)
            totalTrust = 0
            for entry in teamEntries[match]:
                entryTrust = scoutRatings["trustRatings"][scoutRatings["scouts"].index(
                    entry.scout_info.user_id)]
                totalTrust += entryTrust
                returnEntry.data.teleop_scoring.l_1 += entry.data.teleop_scoring.l_1*entryTrust
                returnEntry.data.teleop_scoring.l_2 += entry.data.teleop_scoring.l_2*entryTrust
                returnEntry.data.teleop_scoring.l_3 += entry.data.teleop_scoring.l_3*entryTrust
                returnEntry.data.teleop_scoring.l_4 += entry.data.teleop_scoring.l_4*entryTrust
                returnEntry.data.teleop_scoring.net += entry.data.teleop_scoring.net*entryTrust
                returnEntry.data.teleop_scoring.processor += entry.data.teleop_scoring.processor*entryTrust
                returnEntry.data.auto_scoring.l_1 += entry.data.auto_scoring.l_1*entryTrust
                returnEntry.data.auto_scoring.l_2 += entry.data.auto_scoring.l_2*entryTrust
                returnEntry.data.auto_scoring.l_3 += entry.data.auto_scoring.l_3*entryTrust
                returnEntry.data.auto_scoring.l_4 += entry.data.auto_scoring.l_4*entryTrust
                returnEntry.data.auto_scoring.net += entry.data.auto_scoring.net*entryTrust
                returnEntry.data.auto_scoring.processor += entry.data.auto_scoring.processor*entryTrust
            if not totalTrust == 0:
                returnEntry.data.teleop_scoring.l_1 /= totalTrust
                returnEntry.data.teleop_scoring.l_2 /= totalTrust
                returnEntry.data.teleop_scoring.l_3 /= totalTrust
                returnEntry.data.teleop_scoring.l_4 /= totalTrust
                returnEntry.data.teleop_scoring.net /= totalTrust
                returnEntry.data.teleop_scoring.processor /= totalTrust
                returnEntry.data.auto_scoring.l_1 /= totalTrust
                returnEntry.data.auto_scoring.l_2 /= totalTrust
                returnEntry.data.auto_scoring.l_3 /= totalTrust
                returnEntry.data.auto_scoring.l_4 /= totalTrust
                returnEntry.data.auto_scoring.net /= totalTrust
                returnEntry.data.auto_scoring.processor /= totalTrust
            retval.append(returnEntry)
    # print("removed more outliers")
    return retval, scoutRatings
