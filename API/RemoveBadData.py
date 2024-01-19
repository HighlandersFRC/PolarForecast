import copy
import pandas as pd


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


def getRatingBasedError(
    combination: dict, TBAMatch: pd.Series, scoutRatings: dict
) -> float:
    error = 0
    total = 0
    errorPercent = 1.0
    totalTrust = 0
    data = []
    for team in combination:
        totalTrust += scoutRatings["trustRatings"][
            scoutRatings["scouts"].index(combination[team]["scout_info"])
        ]
        data.append(
            {
                field: flatten_dict(combination[team]["data"])[field]
                * scoutRatings["trustRatings"][
                    scoutRatings["scouts"].index(
                        combination[team]["scout_info"]
                    )
                ]
                for field in flatten_dict(combination[team]["data"])
            }
        )
    addedData = data[0]
    for field in addedData:
        addedData[field] = data[0][field] + data[1][field] + data[2][field]
        total += abs(TBAMatch[field])
        error += abs(TBAMatch[field] - addedData[field])
    if total > 0:
        errorPercent = error / total
        errorPercent *= 1-(totalTrust/3)
    return errorPercent


def getBestData(TBAData: pd.DataFrame, scoutingData: list) -> list:
    retval = []
    TBADict = TBAData.to_dict("records")
    j = 0
    for game in TBADict:
        j += 1
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
            returnCombination = combinations[
                combinationError.index(min(combinationError))
            ]
            # combinationTrust = [1-combinationError[i] for i in range(len(combinationError))]
            # for i in range(len(combinations)):
            #     for entry in combinations[i]:
            #         for field in combinations[i][entry]:
            #             returnCombination[entry][field] = 0
            # for i in range(len(combinations)):
            #     for entry in combinations[i]:
            #         for field in combinations[i][entry]:
            #             if not type(combinations[i][entry][field]) == dict:
            #                 returnCombination[entry][field] += combinationTrust[i]*combinations[i][entry][field]
            # for entry in returnCombination:
            #     for field in returnCombination[entry]:
            #         if not(sum(combinationTrust) == 0):
            #             returnCombination[entry][field] /= sum(combinationTrust)
            for entry in returnCombination:
                if not retval.__contains__(returnCombination[entry]):
                    retval.append(returnCombination[entry])
        else:
            for entry in entries:
                if not retval.__contains__(entry):
                    retval.append(entry)
    return retval


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


def getTrustAdjustedData(TBAData: pd.DataFrame, scoutingData: list) -> list:
    retval = []
    scoutRatings = getScoutRatings(TBAData, scoutingData)
    TBADict = TBAData.to_dict("records")
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
                            if not teams.__contains__(entry["team_number"]):
                                teams.append(entry["team_number"])
                            break
        for entry in entries:
            teamEntries[entry["team_number"]] = []
        for entry in entries:
            teamEntries[entry["team_number"]].append(entry)
        returnEntries = {}
        for team in teamEntries:
            returnEntries[team] = {}
            returnEntries[team]["data"] = {}
            for entry in teamEntries[team]:
                for i in range(2):
                    if i == 1:
                        community = "teleop"
                    elif i == 0:
                        community = "auto"
                    returnEntries[team]["data"][community] = {}
                    for field in entry["data"][community]:
                        returnEntries[team]["data"][community][field] = 0
        for team in teamEntries:
            totalTrust = 0
            for entry in teamEntries[team]:
                if "metadata" in entry.keys():
                    totalTrust += scoutRatings["trustRatings"][
                        scoutRatings["scouts"].index(entry["scout_info"])
                    ]
                    returnEntries[team] = entry
                    for i in range(2):
                        if i == 1:
                            community = "teleop"
                        elif i == 0:
                            community = "auto"
                        for field in entry["data"][community]:
                            returnEntries[team]["data"][community][field] += (
                                entry["data"][community][field]
                                * scoutRatings["trustRatings"][
                                    scoutRatings["scouts"].index(
                                        entry["scout_info"]
                                    )
                                ]
                            )
            for i in range(2):
                if i == 1:
                    community = "teleop"
                elif i == 0:
                    community = "auto"
                for field in returnEntries[team]["data"][community]:
                    if not totalTrust == 0:
                        returnEntries[team]["data"][community][field] /= totalTrust
        for entry in returnEntries:
            if not retval.__contains__(returnEntries[entry]):
                retval.append(returnEntries[entry])
    return retval


def BestTrustAdjustedData(TBAData: pd.DataFrame, scoutingData: list) -> list:
    retval = []
    scoutRatings = getMarkovianRatings(TBAData, scoutingData)
    TBADict = TBAData.to_dict("records")
    j = 0
    for game in TBADict:
        j += 1
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
                combinationError.append(getRatingBasedError(combinations[i], game, scoutRatings))
            indices = [
                i for i, x in enumerate(combinationError) if x == min(combinationError)
            ]
            combinationScoutError = []
            for index in indices:
                combinationScoutError.append(0)
            for index in indices:
                for team in combinations[index]:
                    combinationScoutError[indices.index(index)] += scoutRatings[
                        "trustRatings"
                    ][
                        scoutRatings["scouts"].index(
                            combinations[indices.index(index)][team][
                                "scout_info"
                            ]
                        )
                    ]
            returnCombination = combinations[
                indices[combinationScoutError.index(min(combinationScoutError))]
            ]
            # combinationTrust = [1-combinationError[i] for i in range(len(combinationError))]
            # for i in range(len(combinations)):
            #     for entry in combinations[i]:
            #         for field in flatten_dict(combinations[i][entry]["data"]):
            #             returnCombination[entry][field] = 0
            # for i in range(len(combinations)):
            #     for entry in combinations[i]:
            #         for field in flatten_dict(combinations[i][entry]["data"]):
            #             returnCombination[entry][field] += combinationTrust[i]*flatten_dict(combinations[i][entry]["data"])[field]
            # for entry in returnCombination:
            #     for field in returnCombination[entry]:
            #         if not type(returnCombination[entry][field]) == dict:
            #             if not(sum(combinationTrust) == 0):
            #                 returnCombination[entry][field] /= sum(combinationTrust)
            for entry in returnCombination:
                if not retval.__contains__(returnCombination[entry]):
                    retval.append(returnCombination[entry])
        else:
            for entry in entries:
                if not retval.__contains__(entry):
                    retval.append(entry)
    return retval


def getMarkovianRatings(TBAData: pd.DataFrame, scoutingData: list):
    scoutRatings = getScoutRatings(TBAData, scoutingData)
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
    teams = []
    retval =[]
    scoutRatings = getMarkovianRatings(TBAData, scoutingData)
    for entry in scoutingData:
        if not teams.__contains__(entry["team_number"]):
            teams.append(entry["team_number"])
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
    return retval