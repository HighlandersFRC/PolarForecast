import copy
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
                for stage in ["CenterStage", "StageLeft", "StageRight"]:
                    oprMatchEntry["trap" +
                                stage] = row["score_breakdown"][allianceStr]["trap" + stage]
                    if row["score_breakdown"][allianceStr]["mic" + stage]:
                        oprMatchEntry["mic"] += 1
                oprMatchList.append(copy.deepcopy(oprMatchEntry))
    oprMatchDataFrame = pd.DataFrame(oprMatchList)
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
    
    # Counting the number of matches that each team has
    for k in range(3):
        for matchTeam in oprMatchDataFrame["station" + str(k + 1)]:
            teamMatchCount[teams.index(matchTeam)] += 1
            
    # Analyzing data that is directly extracted from 
    for index, row in oprMatchDataFrame.iterrows():
        for k in range(3):
            matchTeam = row["station" + str(k + 1)]
            idx = teams.index(matchTeam)
            if row["endGameRobot" + str(k + 1)] == "Parked":
                teamParking[idx] += 1
            elif not row["endGameRobot" + str(k + 1)] == "None":
                teamClimbing[idx] += 1
                if row["trap"+row["endGameRobot" + str(k + 1)]]:
                    teamTrap[idx] += 1
            if row["station" + str(k + 1)+"_mobility"] == "Yes":
                teamMobility[idx] += 1
                
    # Analyzing data coming directly from scouting data
    for entry in scoutingBaseData:
        teamDeaths += entry["data"]["miscellaneous"]["died"]
    
    # All of the keys, maxs, and mins
    ScoutingDataKeys = [
        "auto_speaker",
        "auto_amp",
        "teleop_speaker",
        "teleop_amped_speaker",
        "teleop_amp",
    ]
    ScoutingDataMins = [
        0,
        0,
        0,
        0,
        0,
    ]
    ScoutingDataMaxs = [
        9,
        9,
        56,
        54,
        56,
    ] 
    TBAOnlyKeys = [
        "harmony",
        "mic",
    ]
    TBAOnlyMins = [
        0,
        0,
    ]
    TBAOnlyMaxs = [
        2,
        3,
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
    j = numEntries # set j to the max number of scout entries to analyze
    
    # TBA Data
    YMatrix = pd.DataFrame(None, columns=ScoutingDataKeys)
    TBAOnlyYMatrix = pd.DataFrame(None, columns=TBAOnlyKeys)
    YMatrix = oprMatchDataFrame[ScoutingDataKeys]
    TBAOnlyYMatrix = pd.DataFrame(oprMatchDataFrame[TBAOnlyKeys])
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
    scoutingData = scoutingDataFunction(oprMatchDataFrame, scoutingData)
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
        teamYEntry = np.zeros(len(ScoutingDataKeys))
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
                        newY = [data[key] for key in ScoutingDataKeys]
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

    mutation_percent_genes = 0.02

    # Define a function to perform the genetic algorithm operation
    # print("doing genetic algorithm")
    def perform_genetic_algorithm(i):
        ga = geneticAlg(
            createfitness_func(ScoutingDataMins[i], ScoutingDataMaxs[i]),
            [pd.DataFrame(AMatrix[teams]), pd.DataFrame(YMatrix[ScoutingDataKeys[i]])],
            pd.DataFrame(XMatrix[ScoutingDataKeys[i]]),
            mutation_percent_genes,
        )
        result = ga.run()
        return result[0], i
    # Number of processes to run simultaneously
    num_processes = 10  # Adjust this value based on your system's capabilities
    results = []
    for i in range(len(ScoutingDataKeys)):
        results.append(perform_genetic_algorithm(i))
    # results = joblib.Parallel(num_processes)(joblib.delayed(perform_genetic_algorithm)(i) for i in range(10))
    for i in range(len(TBAOnlyKeys)):
        ga = geneticAlg(
            createfitness_func(TBAOnlyMins[i], TBAOnlyMaxs[i]),
            [pd.DataFrame(TBAOnlyAList, columns=teams), pd.DataFrame(TBAOnlyYMatrix[TBAOnlyKeys[i]])],
            pd.DataFrame(TBAOnlyXMatrix[TBAOnlyKeys[i]]),
            mutation_percent_genes,
        )
        result = ga.run()
        results.append((result[0], len(ScoutingDataKeys)+i))
    
    dataKeys = copy.deepcopy(ScoutingDataKeys)
    dataKeys.extend(TBAOnlyKeys)
    
    for result, i in results:
        array = np.array(result).ravel()
        XMatrix[dataKeys[i]] = result
        if i < 2:
            autoPoints += array*OPRWeights[i]
            autoPieces += array
        elif i < 5:
            teleopPoints += array*OPRWeights[i]
            teleopPieces += array

    teamParking /= teamMatchCount
    teamMobility /= teamMatchCount
    teamClimbing /= teamMatchCount
    teamTrap /= teamMatchCount
    teamDeaths /= teamMatchCount
    autoPoints += teamMobility * 2
    totalAmp = XMatrix["auto_amp"] + XMatrix["teleop_amp"]
    totalSpeaker = XMatrix["auto_speaker"] + XMatrix["teleop_amped_speaker"] + XMatrix["teleop_speaker"]
    endgamePoints = teamClimbing * 3 + teamParking
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
    XMatrix.insert(0, 'notes', pd.Series(piecesScored))
    XMatrix.insert(0, 'auto_points', pd.Series(autoPoints))
    XMatrix.insert(0, 'teleop_points', pd.Series(teleopPoints))
    XMatrix.insert(0, 'endgame_points', pd.Series(endgamePoints))
    XMatrix.insert(0, 'OPR', pd.Series(teamOPR))
    XMatrix.insert(0, 'match_count', pd.Series(teamMatchCount))
    XMatrix.insert(0, 'team_number', pd.Series(teams))
    # print(XMatrix)
    return XMatrix
