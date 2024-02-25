import copy
import numpy as np
import pandas as pd

def dataOPR(scoutData: dict) -> int:
    auto = scoutData["data"]["auto"]
    teleop = scoutData["data"]["teleop"]
    opr = 0
    opr += auto["amp"] * 2
    opr += auto["speaker"] * 5
    opr += teleop["amp"] * 5
    opr += teleop["speaker"] * 5
    opr += teleop["amped_speaker"] * 3
    return opr

def removeOutliers(data: list) -> list:
    teams = []
    teamEntryList = []
    for entry in data:
        if not teams.__contains__(entry["team_number"]):
            teams.append(entry["team_number"])
            teamEntryList.append([])
    for entry in data:
        teamEntryList[teams.index(entry["team_number"])].append((dataOPR(entry), entry))
    noOutliers = []
    for teamEntries in teamEntryList:
        noOutliers.append(remove_outliers_iqr(teamEntries))
    retval = []
    for teamEntries in noOutliers:
        for entry in teamEntries:
            retval.append(entry)
    return retval

def remove_outliers_iqr(data: list) -> list:
    opr_values = np.array([opr for opr, entry in data])
    q1 = np.percentile(opr_values, 25)
    q3 = np.percentile(opr_values, 75)
    iqr = q3 - q1
    threshold = 1.5
    outlier_indices = np.where((opr_values < q1 - threshold * iqr) | (opr_values > q3 + threshold * iqr))[0]
    filtered_entries = [entry for index, (opr, entry) in enumerate(data) if index not in outlier_indices]
    return filtered_entries

def remove_outliers(data: list) -> list:
    opr_values = np.array([opr for opr, entry in data])
    z_scores = (opr_values - np.mean(opr_values)) / np.std(opr_values)
    threshold = 3
    outlier_indices = np.where(np.abs(z_scores) > threshold)[0]
    filtered_entries = [entry for index, (opr, entry) in enumerate(data) if index not in outlier_indices]
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

def average(lst):
    numeric_values = [x for x in lst if isinstance(x, (int, float))]
    if len(numeric_values) == 0:
        return 0
    else:
        return sum(numeric_values) / len(numeric_values)

def getError(combination: dict, TBAMatch: pd.Series) -> float:
    error = 0
    total = 0
    errorPercent = 1.0
    data = []
    for team in combination:
        data.append(flatten_dict(combination[team]["data"]))
    addedData = data[0]
    for field in addedData:
        addedData[field] = data[0][field] + data[1][field] + data[2][field]
        total += abs(TBAMatch[field])
        error += abs(TBAMatch[field] - addedData[field])
    if total > 0:
        errorPercent = error / total
    return errorPercent

def getScoutRatings(TBAData: pd.DataFrame, scoutingData: list) -> dict:
    scouts = []
    scoutTrusts = []
    scoutTrustRatings = []
    TBADict = TBAData.to_dict("records")
    for entry in scoutingData:
        if not (scouts.__contains__(entry["scout_info"])):
            scouts.append(entry["scout_info"])
    for i in range(len(scouts)):
        scoutTrusts.append([])
        scoutTrustRatings.append(0)
    # print("made list of all scouts")
    for game in TBADict:
        entries = []
        teamEntries = {}
        teams = []
        # get combination-based error
        for entry in scoutingData:
            if type(entry) == dict:
                if entry["match_number"] == game["match_number"]:
                    for i in range(3):
                        if (
                            game["station" + str(i + 1)]
                            == entry["team_number"]
                        ):
                            entries.append(entry)
                            if not teams.__contains__(entry["team_number"]):
                                teams.append(entry["team_number"])
                            break
        for entry in entries:
            teamEntries[entry["team_number"]] = []
        for entry in entries:
            teamEntries[entry["team_number"]].append(entry)
        combinations = []
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
                        scouts.index(combinations[i][entry]["scout_info"])
                    ].append(combinationTrust[i])
        # get comparative scout error
        for i in range(len(teams)):
            if not len(teamEntries[teams[i]]) == 1:
                teamAverage = {}
                for entry in teamEntries[teams[i]]:
                    flattenedEntry = flatten_dict(entry["data"])
                    for field in flattenedEntry:
                        teamAverage[field] = 0
                for entry in teamEntries[teams[i]]:
                    flattenedEntry = flatten_dict(entry["data"])
                    for field in flattenedEntry:
                        teamAverage[field] += flattenedEntry[field]
                for field in teamAverage:
                    teamAverage[field] /= len(teamEntries[teams[i]])
                for entry in teamEntries[teams[i]]:
                    flattenedEntry = flatten_dict(entry["data"])
                    entryTrust = []
                    for field in flattenedEntry:
                        if teamAverage[field] == 0:
                            entryTrust.append(1)
                        else:
                            entryTrust.append(
                                1
                                - (
                                    abs(flattenedEntry[field] - teamAverage[field])
                                    / teamAverage[field]
                                )
                            )
                    scoutTrusts[scouts.index(entry["scout_info"])].append(
                        average(entryTrust)
                    )
    for i in range(len(scouts)):
        scoutTrustRatings[i] = average(scoutTrusts[i])
    retval = {"scouts": scouts, "trustRatings": scoutTrustRatings}
    return retval

def getMarkovianRatings(TBAData: pd.DataFrame, scoutingData: list):
    scoutRatings = getScoutRatings(TBAData, scoutingData)
    # print("got one time ratings")
    for j in range(10):
        scouts = scoutRatings["scouts"]
        oldTrustRatings = scoutRatings["trustRatings"]
        scoutTrusts = []
        scoutTrustRatings = []
        TBADict = TBAData.to_dict("records")
        for entry in scoutingData:
            if not (scouts.__contains__(entry["scout_info"])):
                scouts.append(entry["scout_info"])
        for i in range(len(scouts)):
            scoutTrusts.append([])
            scoutTrustRatings.append(0)
        for game in TBADict:
            entries = []
            teamEntries = {}
            teams = []
            for entry in scoutingData:
                if type(entry) == dict:
                    if entry["match_number"] == game["match_number"]:
                        for i in range(3):
                            if (
                                game["station" + str(i + 1)]
                                == entry["team_number"]
                            ):
                                entries.append(entry)
                                if not teams.__contains__(
                                    entry["team_number"]
                                ):
                                    teams.append(entry["team_number"])
                                break
            for entry in entries:
                teamEntries[entry["team_number"]] = []
            for entry in entries:
                teamEntries[entry["team_number"]].append(entry)
            # get combination-based error
            combinations = []
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
                                combinations[i][entry]["scout_info"]
                            )
                        ].append(combinationTrust[i])
            # get comparative scout error
            for i in range(len(teams)):
                if not len(teamEntries[teams[i]]) == 1:
                    teamAverage = {}
                    for entry in teamEntries[teams[i]]:
                        flattenedEntry = flatten_dict(entry["data"])
                        for field in flattenedEntry:
                            teamAverage[field] = 0
                    totalTrust = 0
                    for entry in teamEntries[teams[i]]:
                        flattenedEntry = flatten_dict(entry["data"])
                        totalTrust += oldTrustRatings[scoutRatings["scouts"].index(entry["scout_info"])]
                        for field in flattenedEntry:
                            teamAverage[field] += flattenedEntry[field]*oldTrustRatings[scoutRatings["scouts"].index(entry["scout_info"])]
                    for field in teamAverage:
                        if totalTrust == 0:
                            teamAverage[field] = 0
                        else:
                            teamAverage[field] /= totalTrust
                    for entry in teamEntries[teams[i]]:
                        flattenedEntry = flatten_dict(entry["data"])
                        entryTrust = []
                        for field in flattenedEntry:
                            if teamAverage[field] == 0:
                                entryTrust.append(1)
                            else:
                                entryTrust.append(
                                    1
                                    - (
                                        abs(flattenedEntry[field] - teamAverage[field])
                                        / teamAverage[field]
                                    )
                                )
                        scoutTrusts[
                            scouts.index(entry["scout_info"])
                        ].append(average(entryTrust))
        for i in range(len(scouts)):
            rating = average(scoutTrusts[i])
            if rating > 1:
                rating = 1
            scoutTrustRatings[i] = rating
        scoutRatings = {"scouts": scouts, "trustRatings": scoutTrustRatings}
    return scoutRatings

def TeamBasedData(TBAData: pd.DataFrame, scoutingData: list) -> list:
    for entry in scoutingData:
        entry["data"].pop("selectedPieces")
        entry["data"].pop("miscellaneous")
    # print("Removed selected Pieces")
    teams = []
    retval =[]
    scoutingData = removeOutliers(scoutingData)
    # print("removed outliers")
    scoutRatings = getMarkovianRatings(TBAData, scoutingData)
    # print("got markovian ratings")
    for entry in scoutingData:
        if not teams.__contains__(entry["team_number"]):
            teams.append(entry["team_number"])
    # print("made list of teams")
    for team in teams:
        teamEntries = []
        returnEntry = {}
        for entry in scoutingData:
            if entry["team_number"] == team:
                if not teamEntries.__contains__(entry):
                    teamEntries.append(entry)
                    returnEntry = copy.deepcopy(entry)
                    for i in range(2):
                        if i == 0:
                            communityStr = "auto"
                        else:
                            communityStr = "teleop"
                        for field in entry["data"][communityStr]:
                            returnEntry["data"][communityStr][field] = 0
        totalTrust = 0
        for entry in teamEntries:
            entryTrust = scoutRatings["trustRatings"][scoutRatings["scouts"].index(entry["scout_info"])]
            for i in range(2):
                if i == 0:
                    communityStr = "auto"
                else:
                    communityStr = "teleop"
                for field in entry["data"][communityStr]:
                    returnEntry["data"][communityStr][field] += entry["data"][communityStr][field]*entryTrust
            totalTrust += entryTrust
        for i in range(2):
            if i == 0:
                communityStr = "auto"
            else:
                communityStr = "teleop"
            for field in entry["data"][communityStr]:
                if not totalTrust == 0:
                    returnEntry["data"][communityStr][field] /= totalTrust
        retval.append(returnEntry)
    # print("adjusted data")
    retval = removeOutliers(retval)
    # print("removed more outliers")
    return retval