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


def getPiecesScored(match: dict, communityStr: str, allianceStr: str) -> list:
    hco = getPieceScored(match, communityStr, allianceStr, "T", "Cone")
    hcu = getPieceScored(match, communityStr, allianceStr, "T", "Cube")
    mco = getPieceScored(match, communityStr, allianceStr, "M", "Cone")
    mcu = getPieceScored(match, communityStr, allianceStr, "M", "Cube")
    lco = getPieceScored(match, communityStr, allianceStr, "B", "Cone")
    lcu = getPieceScored(match, communityStr, allianceStr, "B", "Cube")
    lp = lcu + lco
    return [hco, hcu, mco, mcu, lp]


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
    oprMatchList = []
    # Isolating Data Related to OPR
    blankOprEntry = {
        "auto_hco": 0,
        "auto_hcu": 0,
        "auto_mco": 0,
        "auto_mcu": 0,
        "auto_lp": 0,
        "teleop_hco": 0,
        "teleop_hcu": 0,
        "teleop_mco": 0,
        "teleop_mcu": 0,
        "teleop_lp": 0,
        "station1": 0,
        "station2": 0,
        "station3": 0,
        "links": 0,
        "match_number": 0,
        "allianceStr": "",
    }
    print(len(data), "matches")
    for row in data:
        for j in range(2):
            if j == 1:
                allianceStr = "red"
            else:
                allianceStr = "blue"
            oprMatchEntry = copy.deepcopy(blankOprEntry)
            oprMatchEntry["allianceStr"] = allianceStr
            oprMatchEntry["match_number"] = row["match_number"]
            for k in range(3):
                oprMatchEntry["station" + str(k + 1)] = row["alliances"][allianceStr][
                    "team_keys"
                ][k][3:]
                oprMatchEntry["station" + str(k + 1)+"_autodocking"] = row["score_breakdown"][allianceStr]["autoChargeStationRobot" + str(k+1)]
                oprMatchEntry["station" + str(k + 1)+"_mobility"] = row["score_breakdown"][allianceStr]["mobilityRobot" + str(k+1)]
                oprMatchEntry["station" + str(k + 1)+"_teledocking"] = row["score_breakdown"][allianceStr]["endGameChargeStationRobot" + str(k+1)]
            oprMatchEntry["autoCS"] = row["score_breakdown"][allianceStr]["autoBridgeState"]
            oprMatchEntry["teleCS"] = row["score_breakdown"][allianceStr]["endGameBridgeState"]
            piecesScored = getPiecesScored(row, "autoCommunity", allianceStr)
            oprMatchEntry["auto_hco"] = piecesScored[0]
            oprMatchEntry["auto_hcu"] = piecesScored[1]
            oprMatchEntry["auto_mco"] = piecesScored[2]
            oprMatchEntry["auto_mcu"] = piecesScored[3]
            oprMatchEntry["auto_lp"] = piecesScored[4]
            piecesScored = getPiecesScored(row, "teleopCommunity", allianceStr)
            oprMatchEntry["teleop_hco"] = piecesScored[0]
            oprMatchEntry["teleop_hcu"] = piecesScored[1]
            oprMatchEntry["teleop_mco"] = piecesScored[2]
            oprMatchEntry["teleop_mcu"] = piecesScored[3]
            oprMatchEntry["teleop_lp"] = piecesScored[4]
            oprMatchEntry["links"] = len(row["score_breakdown"][allianceStr]["links"])
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
    teamMatchCount = np.zeros(len(teams))
    teamTeleDocking = np.zeros(len(teams))
    teamAutoDocking = np.zeros(len(teams))
    teamParking = np.zeros(len(teams))
    teamMobility = np.zeros(len(teams))
    gridPoints = np.zeros(len(teams))
    piecesScored = np.zeros(len(teams))
    autoPieces = np.zeros(len(teams))
    teleopPieces = np.zeros(len(teams))
    linkpoints = np.zeros(len(teams))
    autoPoints = np.zeros(len(teams))
    teleopPoints = np.zeros(len(teams))
    for k in range(3):
        for matchTeam in oprMatchDataFrame["station" + str(k + 1)]:
            teamMatchCount[teams.index(matchTeam)] += 1
    for index, row in oprMatchDataFrame.iterrows():
        for k in range(3):
            matchTeam = row["station" + str(k + 1)]
            idx = teams.index(matchTeam)
            if row["station" + str(k + 1) + "_autodocking"] == "Docked":
                if row["autoCS"] == "Level":
                    teamAutoDocking[idx] += 12
                else:
                    teamAutoDocking[idx] += 8
            if row["station" + str(k + 1) + "_teledocking"] == "Docked":
                if row["teleCS"] == "Level":
                    teamTeleDocking[idx] += 10
                else:
                    teamTeleDocking[idx] += 6
            elif row["station" + str(k + 1) + "_teledocking"] == "Park":
                teamParking[idx] += 2
            if row["station" + str(k + 1)+"_mobility"] == "Yes":
                teamMobility[idx] += 3
    # print("made Docking data")
    # TBA Data for Y Matrix
    YKeys = [
        "auto_hco",
        "auto_hcu",
        "auto_mco",
        "auto_mcu",
        "auto_lp",
        "teleop_hco",
        "teleop_hcu",
        "teleop_mco",
        "teleop_mcu",
        "teleop_lp",
    ]
    OPRWeights = [
        6,
        6,
        4,
        4,
        3,
        5,
        5,
        3,
        3,
        2,
        5,
    ]

    scoutingBaseData = m_data[1]
    numEntries = len(scoutingBaseData)
    j = numEntries
    # TBA Data
    YMatrix = pd.DataFrame(None, columns=YKeys)
    linksY = pd.DataFrame(None, columns=["links"])
    YMatrix = oprMatchDataFrame[YKeys]
    linksY = pd.DataFrame(oprMatchDataFrame["links"])
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
    linksAlist = copy.deepcopy(Alist)
    # Fitting Scouting Data to Matrices A and Y
    scoutingData = copy.deepcopy(scoutingBaseData[:j])
    teamMatchesList = copy.deepcopy(blankAEntry)
    # Throw out bad scouting data
    scoutingDataFunction = TeamBasedData
    scoutingData = scoutingDataFunction(oprMatchDataFrame, scoutingData)
    # print("threw away scouting data")
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
        teamYEntry = [0 for k in range(len(YKeys))]
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
                        newY = [data[key] for key in YKeys]
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
    linksAPseudoInverse = np.linalg.pinv(pd.DataFrame(linksAlist)[teams])
    # print("ready for regression")
    # Multivariate Regression
    XMatrix = pd.DataFrame(APseudoInverse @ YMatrix)
    linksX = linksAPseudoInverse @ linksY
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

    maxGamePieces = [6, 3, 6, 3, 9, 6, 3, 6, 3, 9, 9]
    minGamePieces = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    mutation_percent_genes = 0.02

    # Define a function to perform the genetic algorithm operation
    # print("doing genetic algorithm")
    def perform_genetic_algorithm(i):
        ga = geneticAlg(
            createfitness_func(minGamePieces[i], maxGamePieces[i]),
            [pd.DataFrame(AMatrix[teams]), pd.DataFrame(YMatrix[YKeys[i]])],
            pd.DataFrame(XMatrix[YKeys[i]]),
            mutation_percent_genes,
        )
        result = ga.run()
        return result[0], i
    # Number of processes to run simultaneously
    num_processes = 10  # Adjust this value based on your system's capabilities
    results = []
    for i in range (len(YKeys)):
        results.append(perform_genetic_algorithm(i))
    ga = geneticAlg(
        createfitness_func(minGamePieces[10], maxGamePieces[10]),
        [pd.DataFrame(linksAlist), pd.DataFrame(linksY)],
        pd.DataFrame(linksX),
        mutation_percent_genes
    )
    results.append((ga.run()[0], 10))
    # results = joblib.Parallel(num_processes)(joblib.delayed(perform_genetic_algorithm)(i) for i in range(10))
    YKeys = [
        "auto_hco",
        "auto_hcu",
        "auto_mco",
        "auto_mcu",
        "auto_lp",
        "teleop_hco",
        "teleop_hcu",
        "teleop_mco",
        "teleop_mcu",
        "teleop_lp",
        "links",
    ]
    for result, i in results:
        array = np.array(result).ravel()
        XMatrix[YKeys[i]] = result
        if i < 5:
            autoPoints += array*OPRWeights[i]
            autoPieces += array
        elif i < 10:
            teleopPoints += array*OPRWeights[i]
            teleopPieces += array
        else:
            linkpoints += array * 5
        
    
    teamParking/=teamMatchCount
    teamAutoDocking/=teamMatchCount
    teamTeleDocking/=teamMatchCount
    teamMobility/=teamMatchCount
    gridPoints = autoPoints+teleopPoints
    autoPoints += teamAutoDocking + teamMobility
    endgamePoints = teamTeleDocking + teamParking
    teamOPR = gridPoints + linkpoints + endgamePoints + teamAutoDocking + teamMobility
    piecesScored=autoPieces+teleopPieces
    
    
    XMatrix.insert(0, 'auto_docking', pd.Series(teamAutoDocking))
    XMatrix.insert(0, 'teleop_docking', pd.Series(teamTeleDocking))
    XMatrix.insert(0, 'parking', pd.Series(teamParking))
    XMatrix.insert(0, 'mobility', pd.Series(teamMobility))
    XMatrix.insert(0, 'auto_pieces', pd.Series(autoPieces))
    XMatrix.insert(0, 'teleop_pieces', pd.Series(teleopPieces))
    XMatrix.insert(0, 'pieces_scored', pd.Series(piecesScored))
    XMatrix.insert(0, 'grid_points', pd.Series(gridPoints))
    XMatrix.insert(0, 'link_points', pd.Series(linkpoints))
    XMatrix.insert(0, 'auto_points', pd.Series(autoPoints))
    XMatrix.insert(0, 'teleop_points', pd.Series(teleopPoints))
    XMatrix.insert(0, 'endgame_points', pd.Series(endgamePoints))
    XMatrix.insert(0, 'opr', pd.Series(teamOPR))
    XMatrix.insert(0, 'match_count', pd.Series(teamMatchCount))
    XMatrix.insert(0, 'team_number', pd.Series(teams))
    print(sum(teamMatchCount))
    return XMatrix
