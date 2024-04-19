import copy
import math
from types import TracebackType
import pandas as pd
import numpy as np
import warnings
from GeneticAlg import geneticAlg

from RemoveBadData import (
    TeamBasedData,
)

warnings.filterwarnings("ignore")


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


def unpack_nested_list(nested_list):
    flat_list = []
    for item in nested_list:
        if isinstance(item, list):
            flat_list.extend(unpack_nested_list(item))
        else:
            flat_list.append(item)
    return flat_list


def getPieceScored(
    match: dict,
    communityStr: str,
    allianceStr: str,
    row: str,
    piece: str,
) -> int:
    retval = 0
    for spot in match["score_breakdown"][allianceStr][communityStr][row]:
        if spot[:4] == piece:
            retval += 1
    return retval


def analyzeData(m_data: list):
    data = m_data[0]
    scoutingBaseData = m_data[1]
    for entry in scoutingBaseData:
        if not entry["data"]["teleop"].__contains__("pass"):
            entry["data"]["teleop"]["pass"] = 0
    oprMatchList = []
    # Isolating Data Related to OPR
    blankOprEntry = {
        "auto_speaker": 0,
        "auto_amp": 0,
        "mic": 0,
        "teleop_speaker": 0,
        "teleop_amped_speaker": 0,
        "teleop_amp": 0,
        "harmony": 0,
        "station1": 0,
        "station2": 0,
        "station3": 0,
        "match_number": 0,
        "allianceStr": "",
    }
    for row in data:
        if not row["score_breakdown"] == None:
            for allianceStr in row["alliances"]:
                oprMatchEntry = copy.deepcopy(blankOprEntry)
                oprMatchEntry["allianceStr"] = allianceStr
                oprMatchEntry["match_number"] = row["match_number"]
                for k in range(3):
                    oprMatchEntry["station" + str(k + 1)] = row["alliances"][allianceStr][
                        "team_keys"
                    ][k][3:]
                    oprMatchEntry["endGameRobot" + str(
                        k + 1)] = row["score_breakdown"][allianceStr]["endGameRobot" + str(k + 1)]
                    oprMatchEntry["station" + str(
                        k + 1)+"_mobility"] = row["score_breakdown"][allianceStr]["autoLineRobot" + str(k+1)]
                oprMatchEntry["auto_speaker"] = row["score_breakdown"][allianceStr]["autoSpeakerNoteCount"]
                oprMatchEntry["auto_amp"] = row["score_breakdown"][allianceStr]["autoAmpNoteCount"]
                oprMatchEntry["teleop_speaker"] = row["score_breakdown"][allianceStr]["teleopSpeakerNoteCount"]
                oprMatchEntry["teleop_amped_speaker"] = row["score_breakdown"][allianceStr]["teleopSpeakerNoteAmplifiedCount"]
                oprMatchEntry["teleop_amp"] = row["score_breakdown"][allianceStr]["teleopAmpNoteCount"]
                oprMatchEntry["coopertition"] = 1 if row["score_breakdown"][allianceStr]["coopertitionCriteriaMet"] else 0
                oprMatchEntry["harmony"] = row["score_breakdown"][allianceStr]["endGameHarmonyPoints"]
                for stage in ["CenterStage", "StageLeft", "StageRight"]:
                    oprMatchEntry["trap" +
                                  stage] = row["score_breakdown"][allianceStr]["trap" + stage]
                    if row["score_breakdown"][allianceStr]["mic" + stage]:
                        oprMatchEntry["mic"] += 1
                oprMatchList.append(copy.deepcopy(oprMatchEntry))
    oprMatchDataFrame = pd.DataFrame(oprMatchList)
    # print(oprMatchDataFrame)
    teams = []
    for k in range(3):
        for matchTeam in oprMatchDataFrame["station" + str(k + 1)]:
            exists = False
            exists = teams.__contains__(matchTeam)
            if not exists:
                teams.append(matchTeam)
    teams.sort()
    # print("made list of teams")
    # Initializing sets of Data
    teamMatchCount = np.zeros(len(teams))
    teamParking = np.zeros(len(teams))
    teamClimbing = np.zeros(len(teams))
    teamTrap = np.zeros(len(teams))
    teamMobility = np.zeros(len(teams))
    piecesScored = np.zeros(len(teams))
    autoPieces = np.zeros(len(teams))
    teleopPieces = np.zeros(len(teams))
    autoPoints = np.zeros(len(teams))
    teleopPoints = np.zeros(len(teams))
    harmonyPoints = np.zeros(len(teams))
    teamDeaths = np.zeros(len(teams))
    teamFeeding = np.zeros(len(teams))
    teamCoopertition = np.zeros(len(teams))
    matchScoutingCount = np.zeros(len(teams))

    # Counting the number of matches that each team has
    for k in range(3):
        for matchTeam in oprMatchDataFrame["station" + str(k + 1)]:
            teamMatchCount[teams.index(matchTeam)] += 1
    # print("Counted Matches per team")

    # Analyzing data that is directly extracted from
    for index, row in oprMatchDataFrame.iterrows():
        for k in range(3):
            matchTeam = row["station" + str(k + 1)]
            idx = teams.index(matchTeam)
            teamCoopertition[idx] += row["coopertition"]
            if row["endGameRobot" + str(k + 1)] == "Parked":
                teamParking[idx] += 1
            elif not row["endGameRobot" + str(k + 1)] == "None":
                teamClimbing[idx] += 1
                if row["trap"+row["endGameRobot" + str(k + 1)]]:
                    teamTrap[idx] += 1
            if row["station" + str(k + 1)+"_mobility"] == "Yes":
                teamMobility[idx] += 1
    # print("found TBA only stats")

    # Analyzing data coming directly from scouting data
    for entry in scoutingBaseData:
        matchScoutingCount[teams.index(entry["team_number"])] += 1
        if entry["data"]["teleop"].__contains__("pass"):
            try:
                teamFeeding[teams.index(entry["team_number"])
                            ] += entry["data"]["teleop"]["pass"]
            except:
                pass
            # print(entry["data"]["teleop"]["pass"])
        teamDeaths[teams.index(entry["team_number"])
                   ] += entry["data"]["miscellaneous"]["died"]
    # print("found Scouting only stats")

    # All of the keys, maxs, and mins
    ScoutingDataKeys = [
        "auto_speaker",
        "auto_amp",
        ["teleop_speaker",
         "teleop_amped_speaker",
         "teleop_amp"],
    ]
    ScoutingDataMins = [
        0,
        0,
        [0,
         0,
         0],
    ]
    ScoutingDataMaxs = [
        9,
        9,
        [56,
         54,
         56],
    ]
    TBAOnlyKeys = [
        "harmony",
        "mic",
        "coopertition",
    ]
    TBAOnlyMins = [
        0,
        0,
        0,
    ]
    TBAOnlyMaxs = [
        2,
        3,
        1,
    ]
    OPRWeights = [
        5,
        2,
        2,
        5,
        1,
        1,
    ]

    numEntries = len(scoutingBaseData)
    j = numEntries  # set j to the max number of scout entries to analyze
    # print("setup hardcoded stuff")
    # TBA Data
    YMatrix = pd.DataFrame(None, columns=unpack_nested_list(ScoutingDataKeys))
    TBAOnlyYMatrix = pd.DataFrame(None, columns=TBAOnlyKeys)
    YMatrix = oprMatchDataFrame[unpack_nested_list(ScoutingDataKeys)]
    # print("ymatrix set up")
    TBAOnlyYMatrix = pd.DataFrame(oprMatchDataFrame[TBAOnlyKeys])
    # print("tba only ymatrix set up")
    matchTeamMatrix = oprMatchDataFrame[["station1", "station2", "station3"]]
    blankAEntry = {}
    for team in teams:
        blankAEntry[team] = 0
    Alist = []
    for game in matchTeamMatrix.values.tolist():
        AEntry = copy.deepcopy(blankAEntry)
        for team in game:
            AEntry[team] = 1
        Alist.append(AEntry)
    TBAOnlyAList = copy.deepcopy(Alist)

    # Throw out bad scouting data
    scoutingData = copy.deepcopy(scoutingBaseData[:j])
    teamMatchesList = copy.deepcopy(blankAEntry)
    scoutingDataFunction = TeamBasedData
    # print("throwing scouting data")
    try:
        scoutingData, ratings = scoutingDataFunction(
            oprMatchDataFrame, scoutingData)
    except Exception as e:
        print(e)
    # print("threw away scouting data")

    # Make A and Y lists with scouting data
    for team in teams:
        teamMatches = []
        for entry in scoutingData:
            for k in range(2):
                if k == 0:
                    allianceStr = "blue"
                else:
                    allianceStr = "red"
                if type(entry) == dict:
                    if entry["team_number"] == team:
                        if not teamMatches.__contains__(
                            entry["match_number"]
                        ):
                            teamMatches.append(entry["match_number"])
        teamMatchesList[team] = teamMatches
    teamIdx = -1
    for team in teams:
        teamIdx += 1
        teamYEntry = np.zeros(len(unpack_nested_list(ScoutingDataKeys)))
        for teamMatch in teamMatchesList[team]:
            numEntries = 0
            for entry in scoutingData:
                if type(entry) == dict:
                    if (
                        entry["team_number"] == team
                        and entry["match_number"] == teamMatch
                    ):
                        numEntries += 1
            for entry in scoutingData:
                if type(entry) == dict:
                    if (
                        entry["team_number"] == team
                        and entry["match_number"] == teamMatch
                    ):
                        data = flatten_dict(entry["data"])
                        newY = [data[key]
                                for key in unpack_nested_list(ScoutingDataKeys)]
                        teamYEntry = [
                            teamYEntry[i]
                            + (newY[i] / len(teamMatchesList[team]) / numEntries)
                            for i in range(len(teamYEntry))
                        ]
        YMatrix.loc[len(YMatrix)] = teamYEntry
        teamAEntry = copy.deepcopy(blankAEntry)
        teamAEntry[team] = 1
        Alist.append(teamAEntry)

    # Compiling data into matrices
    AMatrix = pd.DataFrame(Alist, columns=teams)
    APseudoInverse = np.linalg.pinv(AMatrix[teams])
    TBAOnlyAPseudoInverse = np.linalg.pinv(pd.DataFrame(TBAOnlyAList)[teams])
    # print("ready for regression")
    # Multivariate Regression
    XMatrix = pd.DataFrame(APseudoInverse @ YMatrix)
    TBAOnlyXMatrix = pd.DataFrame(TBAOnlyAPseudoInverse @ TBAOnlyYMatrix)
    # Run Genetic Algorithm

    def createfitness_func(min: float, max: float):
        def func(solution, functionInputs):
            solutionMatrix = np.array(solution)
            a = np.array(functionInputs[0])
            y = np.array(functionInputs[1])

            calculatedY = a @ solutionMatrix
            difference = np.abs(calculatedY - y)
            error = np.sum(difference)

            # Check constraints using NumPy functions
            exceeding_min = solutionMatrix < min
            exceeding_max = solutionMatrix > max
            error += 1000 * (np.sum(exceeding_min) + np.sum(exceeding_max))

            return error
        return func

    mutation_percent_genes = 0.01

    # Define a function to perform the genetic algorithm operation
    # print("doing genetic algorithm")
    results = []

    def perform_genetic_algorithm(i):
        ga = geneticAlg(
            createfitness_func(ScoutingDataMins[i], ScoutingDataMaxs[i]),
            [pd.DataFrame(AMatrix[teams]), pd.DataFrame(
                YMatrix[ScoutingDataKeys[i]])],
            pd.DataFrame(XMatrix[ScoutingDataKeys[i]]),
            mutation_percent_genes,
        )
        result = ga.run()
        for key in result[0].columns:
            if type(result[0][key].tolist()) is not None:
                results.append(result[0][key].tolist())
    # Number of processes to run simultaneously
    num_processes = 10  # Adjust this value based on your system's capabilities
    for i in range(len(ScoutingDataKeys)):
        perform_genetic_algorithm(i)
    # results = joblib.Parallel(num_processes)(joblib.delayed(perform_genetic_algorithm)(i) for i in range(10))
    # print("Doing TBA only genetic alg")
    for i in range(len(TBAOnlyKeys)):
        ga = geneticAlg(
            createfitness_func(TBAOnlyMins[i], TBAOnlyMaxs[i]),
            [pd.DataFrame(TBAOnlyAList, columns=teams),
             pd.DataFrame(TBAOnlyYMatrix[TBAOnlyKeys[i]])],
            pd.DataFrame(TBAOnlyXMatrix[TBAOnlyKeys[i]]),
            mutation_percent_genes,
        )
        result = ga.run()
        # print(result[0].columns)
        for key in result[0].columns:
            if result[0][key].tolist() is not None:
                results.append(result[0][key].tolist())
        # results.append((result[0], len(ScoutingDataKeys)+i))
    dataKeys = copy.deepcopy(unpack_nested_list(ScoutingDataKeys))
    dataKeys.extend(unpack_nested_list(TBAOnlyKeys))
    # print("compiling data to json")
    # print(results)
    for i, result in enumerate(results):
        # try:
        # print(dataKeys[i])
        array = np.array(result).ravel()
        XMatrix[dataKeys[i]] = result
        if i < 2:
            autoPoints += array*OPRWeights[i]
            autoPieces += array
        elif i < 6:
            teleopPoints += array*OPRWeights[i]
            teleopPieces += array
        # except Exception as e:
        #     print(i, e)
    # print("looped through results")
    teamCoopertition = XMatrix["coopertition"]
    teamParking /= teamMatchCount
    teamMobility /= teamMatchCount
    teamClimbing /= teamMatchCount
    teamTrap /= teamMatchCount
    teamDeaths /= matchScoutingCount
    teamFeeding /= matchScoutingCount
    for i in range(len(teamDeaths)):
        if math.isnan(teamDeaths[i]):
            teamDeaths[i] = 0
        if math.isnan(teamFeeding[i]):
            teamFeeding[i] = 0
    teleopPieces += (teamFeeding/2)
    harmonyPoints = XMatrix["harmony"]*2
    autoPoints += teamMobility * 2
    totalAmp = XMatrix["auto_amp"] + XMatrix["teleop_amp"]
    totalSpeaker = XMatrix["auto_speaker"] + \
        XMatrix["teleop_amped_speaker"] + XMatrix["teleop_speaker"]
    # print(teamTrap)
    endgamePoints = teamClimbing * 3 + teamParking + harmonyPoints + teamTrap * 5
    # teleopPoints += teamFeeding
    teamOPR = endgamePoints + autoPoints + teleopPoints
    piecesScored = autoPieces + teleopPieces

    XMatrix.insert(0, 'parking', pd.Series(teamParking))
    XMatrix.insert(0, 'death_rate', pd.Series(teamDeaths))
    XMatrix.insert(0, 'mobility', pd.Series(teamMobility))
    XMatrix.insert(0, 'climbing', pd.Series(teamClimbing))
    XMatrix.insert(0, 'climbing_points', pd.Series(teamClimbing * 3))
    XMatrix.insert(0, 'auto_notes', pd.Series(autoPieces))
    XMatrix.insert(0, 'trap', pd.Series(teamTrap))
    XMatrix.insert(0, 'trap_points', pd.Series(teamTrap*5))
    XMatrix.insert(0, 'amp_total', pd.Series(totalAmp))
    XMatrix.insert(0, 'speaker_total', pd.Series(totalSpeaker))
    XMatrix["harmony"] = pd.Series(harmonyPoints/2)
    XMatrix.insert(0, 'harmony_points', pd.Series(harmonyPoints))
    XMatrix.insert(0, 'teleop_notes', pd.Series(teleopPieces))
    XMatrix.insert(0, 'pass', pd.Series(teamFeeding))
    XMatrix.insert(0, 'notes', pd.Series(piecesScored))
    XMatrix.insert(0, 'auto_points', pd.Series(autoPoints))
    XMatrix.insert(0, 'teleop_points', pd.Series(teleopPoints))
    XMatrix.insert(0, 'endgame_points', pd.Series(endgamePoints))
    XMatrix.insert(0, 'OPR', pd.Series(teamOPR))
    XMatrix.insert(0, 'match_count', pd.Series(teamMatchCount))
    XMatrix.insert(0, 'team_number', pd.Series(teams))
    # print(XMatrix)
    return XMatrix, ratings
