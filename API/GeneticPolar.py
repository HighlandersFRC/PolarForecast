import copy
import math
from types import TracebackType
import pandas as pd
import numpy as np
import warnings
from models.match_scouting_2025 import MatchScouting2025
from models.tba_match_2025 import ReefLevel, TBAMatch2025
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


def getLevelScoringCount(level: ReefLevel, autoLevel: ReefLevel = ReefLevel(nodeA=False, nodeB=False, nodeC=False, nodeD=False, nodeE=False, nodeF=False, nodeG=False, nodeH=False, nodeI=False, nodeJ=False, nodeK=False, nodeL=False)):
    count = 0
    if level.nodeA and not autoLevel.nodeA:
        count += 1
    if level.nodeB and not autoLevel.nodeB:
        count += 1
    if level.nodeC and not autoLevel.nodeC:
        count += 1
    if level.nodeD and not autoLevel.nodeD:
        count += 1
    if level.nodeE and not autoLevel.nodeE:
        count += 1
    if level.nodeF and not autoLevel.nodeF:
        count += 1
    if level.nodeG and not autoLevel.nodeG:
        count += 1
    if level.nodeH and not autoLevel.nodeH:
        count += 1
    if level.nodeI and not autoLevel.nodeI:
        count += 1
    if level.nodeJ and not autoLevel.nodeJ:
        count += 1
    if level.nodeK and not autoLevel.nodeK:
        count += 1
    if level.nodeL and not autoLevel.nodeL:
        count += 1
    return count


def analyzeData(TBAdata: list[TBAMatch2025], scoutingData: list[MatchScouting2025]):
    data = copy.deepcopy(TBAdata)
    scoutingBaseData = scoutingData
    oprMatchList = []
    # Isolating Data Related to OPR
    blankOprEntry = {
        "auto_scoring_l_1": 0,
        "auto_scoring_l_2": 0,
        "auto_scoring_l_3": 0,
        "auto_scoring_l_4": 0,
        "net": 0,
        "processor": 0,
        "teleop_scoring_l_1": 0,
        "teleop_scoring_l_2": 0,
        "teleop_scoring_l_3": 0,
        "teleop_scoring_l_4": 0,
        "foul_points": 0,
        "station1": 0,
        "station2": 0,
        "station3": 0,
        "endGameRobot1": False,
        "endGameRobot2": False,
        "endGameRobot3": False,
        "match_number": 0,
        "allianceStr": "",
    }
    for row in data:
        if not row.score_breakdown == None:
            for allianceStr in row.alliances:
                oprMatchEntry = copy.deepcopy(blankOprEntry)
                oprMatchEntry["allianceStr"] = allianceStr
                oprMatchEntry["match_number"] = row.match_number
                for k in range(3):
                    oprMatchEntry["station" +
                                  str(k + 1)] = row.alliances[allianceStr].team_keys[k][3:]
                oprMatchEntry["endGameRobot1"] = row.score_breakdown[allianceStr].endGameRobot1
                oprMatchEntry["endGameRobot2"] = row.score_breakdown[allianceStr].endGameRobot2
                oprMatchEntry["endGameRobot3"] = row.score_breakdown[allianceStr].endGameRobot3
                oprMatchEntry["station1_mobility"] = row.score_breakdown[allianceStr].autoLineRobot1
                oprMatchEntry["station2_mobility"] = row.score_breakdown[allianceStr].autoLineRobot2
                oprMatchEntry["station3_mobility"] = row.score_breakdown[allianceStr].autoLineRobot3
                oprMatchEntry["auto_scoring_l_1"] = row.score_breakdown[allianceStr].autoReef.trough
                oprMatchEntry["auto_scoring_l_2"] = getLevelScoringCount(
                    row.score_breakdown[allianceStr].autoReef.botRow)
                oprMatchEntry["auto_scoring_l_3"] = getLevelScoringCount(
                    row.score_breakdown[allianceStr].autoReef.midRow)
                oprMatchEntry["auto_scoring_l_4"] = getLevelScoringCount(
                    row.score_breakdown[allianceStr].autoReef.topRow)
                oprMatchEntry["teleop_scoring_l_1"] = row.score_breakdown[allianceStr].teleopReef.trough
                oprMatchEntry["teleop_scoring_l_2"] = getLevelScoringCount(
                    row.score_breakdown[allianceStr].teleopReef.botRow, autoLevel=row.score_breakdown[allianceStr].autoReef.botRow)
                oprMatchEntry["teleop_scoring_l_3"] = getLevelScoringCount(
                    row.score_breakdown[allianceStr].teleopReef.midRow, autoLevel=row.score_breakdown[allianceStr].autoReef.midRow)
                oprMatchEntry["teleop_scoring_l_4"] = getLevelScoringCount(
                    row.score_breakdown[allianceStr].teleopReef.topRow, autoLevel=row.score_breakdown[allianceStr].autoReef.topRow)
                oprMatchEntry["processor"] = row.score_breakdown[allianceStr].wallAlgaeCount
                oprMatchEntry["net"] = row.score_breakdown[allianceStr].netAlgaeCount
                oprMatchEntry["coopertition"] = 1 if row.score_breakdown[allianceStr].coopertitionCriteriaMet else 0
                oprMatchEntry['foul_points'] = row.score_breakdown[allianceStr].foulPoints
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
    teamShallow = np.zeros(len(teams))
    teamDeep = np.zeros(len(teams))
    teamMobility = np.zeros(len(teams))
    piecesScored = np.zeros(len(teams))
    autoCoral = np.zeros(len(teams))
    teleopCoral = np.zeros(len(teams))
    autoPoints = np.zeros(len(teams))
    teleopPoints = np.zeros(len(teams))
    teamDeaths = np.zeros(len(teams))
    teamCoopertition = np.zeros(len(teams))
    matchScoutingCount = np.zeros(len(teams))

    # Counting the number of matches that each team has
    stations = ['station1', 'station2', 'station3']
    team_match_counts = oprMatchDataFrame[stations].apply(
        pd.Series.value_counts).reindex(teams, fill_value=0).sum(axis=1)
    teamMatchCount[:] = team_match_counts.values
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
                if row["endGameRobot" + str(k+1)] == "DeepCage":
                    teamDeep[idx] += 1
                else:
                    teamShallow[idx] += 1
            if row["station" + str(k + 1)+"_mobility"] == "Yes":
                teamMobility[idx] += 1
    # print("found TBA only stats")

    # Analyzing data coming directly from scouting data
    for entry in scoutingBaseData:
        matchScoutingCount[teams.index(entry.team_number)] += 1
        teamDeaths[teams.index(entry.team_number)
                   ] += 1 if entry.data.miscellaneous.died else 0

    # All of the keys, maxs, and mins
    ScoutingDataKeys = [
        "auto_scoring_l_1",
        "auto_scoring_l_2",
        "auto_scoring_l_3",
        "auto_scoring_l_4",
        "teleop_scoring_l_1",
        "teleop_scoring_l_2",
        "teleop_scoring_l_3",
        "teleop_scoring_l_4",
        "net",
        "processor"
    ]
    ScoutingDataMins = [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
    ]
    ScoutingDataMaxs = [
        60,
        12,
        12,
        12,
        60,
        12,
        12,
        12,
        18,
        60,
    ]
    TBAOnlyKeys = [
        "foul_points",
        "coopertition",
    ]
    TBAOnlyMins = [
        0,
        0,
    ]
    TBAOnlyMaxs = [
        100,
        1,
    ]
    OPRWeights = [
        3,
        4,
        6,
        7,
        2,
        3,
        4,
        5,
        4,
        6,
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
            if entry.team_number == team:
                if not teamMatches.__contains__(
                    entry.match_number
                ):
                    teamMatches.append(entry.match_number)
        teamMatchesList[team] = teamMatches
    teamIdx = -1
    for team in teams:
        teamIdx += 1
        teamYEntry = np.zeros(len(unpack_nested_list(ScoutingDataKeys)))
        for teamMatch in teamMatchesList[team]:
            numEntries = 0
            for entry in scoutingData:
                if (
                    entry.team_number == team
                    and entry.match_number == teamMatch
                ):
                    numEntries += 1
            for entry in scoutingData:
                if (
                    entry.team_number == team
                    and entry.match_number == teamMatch
                ):
                    newY = [
                        entry.data.auto_scoring.l_1,
                        entry.data.auto_scoring.l_2,
                        entry.data.auto_scoring.l_3,
                        entry.data.auto_scoring.l_4,
                        entry.data.teleop_scoring.l_1,
                        entry.data.teleop_scoring.l_2,
                        entry.data.teleop_scoring.l_3,
                        entry.data.teleop_scoring.l_4,
                        entry.data.auto_scoring.net + entry.data.teleop_scoring.net,
                        entry.data.auto_scoring.processor + entry.data.teleop_scoring.processor,
                    ]
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

    def create_fitness_func(min: float, max: float):
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
    results = []

    def perform_genetic_algorithm(i):
        ga = geneticAlg(
            create_fitness_func(ScoutingDataMins[i], ScoutingDataMaxs[i]),
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
            create_fitness_func(TBAOnlyMins[i], TBAOnlyMaxs[i]),
            [pd.DataFrame(TBAOnlyAList, columns=teams),
             pd.DataFrame(TBAOnlyYMatrix[TBAOnlyKeys[i]])],
            pd.DataFrame(TBAOnlyXMatrix[TBAOnlyKeys[i]]),
            mutation_percent_genes,
        )
        result = ga.run()
        # print(result[0].columns)
        for key in result[0].columns:
            if result[0][key] is not None:
                results.append(result[0][key].tolist())
        # results.append((result[0], len(ScoutingDataKeys)+i))
    dataKeys = copy.deepcopy(unpack_nested_list(ScoutingDataKeys))
    dataKeys.extend(unpack_nested_list(TBAOnlyKeys))
    # print("compiling data to json")
    # print(results)
    for i, result in enumerate(results):
        # try:
        # print(dataKeys[i], i)
        # print(result)
        array = np.array(result).ravel()
        XMatrix[dataKeys[i]] = result
        if i < 4:
            autoPoints += array*OPRWeights[i]
            autoCoral += array
        elif i < 10:
            teleopPoints += array*OPRWeights[i]
            teleopCoral += array
        # except Exception as e:
        #     print(i, e)
    # print("looped through results")
    teamCoopertition = XMatrix["coopertition"]
    teamParking /= teamMatchCount
    teamMobility /= teamMatchCount
    teamDeep /= teamMatchCount
    teamShallow /= teamMatchCount
    teamDeaths /= matchScoutingCount
    for i in range(len(teamDeaths)):
        if math.isnan(teamDeaths[i]):
            teamDeaths[i] = 0
    autoPoints += teamMobility * 3
    algaeTotal = XMatrix["net"] + XMatrix["processor"]
    algaePoints = XMatrix["net"] * 4 + XMatrix["processor"]*6
    coralTotal = autoCoral + teleopCoral
    teleopCoralPoints = np.zeros(len(teams))
    for i, x in enumerate([XMatrix[f'teleop_scoring_l_{i}'] for i in range(1, 5)]):
        teleopCoralPoints += (x * OPRWeights[3+i])
    autoCoralPoints = np.zeros(len(teams))
    for i, x in enumerate([XMatrix[f'auto_scoring_l_{i}'] for i in range(1, 5)]):
        autoCoralPoints += (x * OPRWeights[i])
    coralPoints = autoCoralPoints+teleopCoralPoints
    l_1 = XMatrix['auto_scoring_l_1'] + XMatrix['teleop_scoring_l_1']
    l_2 = XMatrix['auto_scoring_l_2'] + XMatrix['teleop_scoring_l_2']
    l_3 = XMatrix['auto_scoring_l_3'] + XMatrix['teleop_scoring_l_3']
    l_4 = XMatrix['auto_scoring_l_4'] + XMatrix['teleop_scoring_l_4']
    piecesScored = coralTotal + algaeTotal
    endgamePoints = teamDeep * 12 + teamParking * 2 + teamShallow*6
    teamClimbingPoints = teamDeep * 12 + teamShallow * 6
    # teleopPoints += teamFeeding
    teamOPR = endgamePoints + autoPoints + teleopPoints

    XMatrix.insert(0, 'parking', pd.Series(teamParking))
    XMatrix.insert(0, 'death_rate', pd.Series(teamDeaths))
    XMatrix.insert(0, 'mobility', pd.Series(teamMobility))
    XMatrix.insert(0, 'climbing_points', pd.Series(teamClimbingPoints))
    XMatrix.insert(0, 'deep_climb_rate', pd.Series(teamDeep))
    XMatrix.insert(0, 'shallow_climb_rate', pd.Series(teamShallow))
    XMatrix.insert(0, 'auto_coral', pd.Series(autoCoral))
    XMatrix.insert(0, 'auto_coral_points', pd.Series(autoCoralPoints))
    XMatrix.insert(0, 'teleop_coral', pd.Series(teleopCoral))
    XMatrix.insert(0, 'teleop_coral_points', pd.Series(teleopCoralPoints))
    XMatrix.insert(0, 'coral_total', pd.Series(coralTotal))
    XMatrix.insert(0, 'coral_points', pd.Series(coralPoints))
    XMatrix.insert(0, 'algae_total', pd.Series(algaeTotal))
    XMatrix.insert(0, 'algae_points', pd.Series(algaePoints))
    XMatrix.insert(0, 'total_pieces', pd.Series(piecesScored))
    XMatrix.insert(0, 'l_1_total', pd.Series(l_1))
    XMatrix.insert(0, 'l_2_total', pd.Series(l_2))
    XMatrix.insert(0, 'l_3_total', pd.Series(l_3))
    XMatrix.insert(0, 'l_4_total', pd.Series(l_4))
    XMatrix.insert(0, 'auto_points', pd.Series(autoPoints))
    XMatrix.insert(0, 'teleop_points', pd.Series(teleopPoints))
    XMatrix.insert(0, 'endgame_points', pd.Series(endgamePoints))
    XMatrix.insert(0, 'OPR', pd.Series(teamOPR))
    XMatrix.insert(0, 'match_count', pd.Series(teamMatchCount))
    XMatrix.insert(0, 'team_number', pd.Series(teams))
    # print(XMatrix)
    return XMatrix, ratings
