import copy
import math
from types import TracebackType
import pandas as pd
import numpy as np
import warnings
from models.match_scouting_2026 import MatchScouting2026
from models.tba_match_2026 import HubScore, TBAMatch2026
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





def analyzeData(TBAdata: list[TBAMatch2026], scoutingData: list[MatchScouting2026]):
    data = copy.deepcopy(TBAdata)
    scoutingBaseData = scoutingData
    oprMatchList = []
    # Isolating Data Related to OPR
    blankOprEntry = {
        "auto_fuel_scored": 0,
        "teleop_fuel_scored": 0,
        "total_fuel_scored": 0,
        "foul_points": 0,

        "station1": 0,
        "station2": 0,
        "station3": 0,

        "station1_auto_tower": "",
        "station2_auto_tower": "",
        "station3_auto_tower": "",

        "station1_endgame_tower": "",
        "station2_endgame_tower": "",
        "station3_endgame_tower": "",

        "match_number": 0,
        "allianceStr": "",
    }
    for row in data:
        if not row.score_breakdown == None:
            for allianceStr in row.alliances:
                if allianceStr == 'red':
                    opponentStr = 'blue'
                else:
                    opponentStr = 'red'
                oprMatchEntry = copy.deepcopy(blankOprEntry)
                oprMatchEntry["allianceStr"] = allianceStr
                oprMatchEntry["match_number"] = row.match_number
                for k in range(3):
                    oprMatchEntry["station" +
                                  str(k + 1)] = row.alliances[allianceStr].team_keys[k][3:]

                oprMatchEntry["auto_fuel_scored"] = row.score_breakdown[allianceStr].hubScore.autoCount
                oprMatchEntry["teleop_fuel_scored"] = row.score_breakdown[allianceStr].hubScore.teleopCount
                oprMatchEntry["total_fuel_scored"] = row.score_breakdown[allianceStr].hubScore.teleopCount + row.score_breakdown[allianceStr].hubScore.autoCount
                
                oprMatchEntry["foul_points"] = row.score_breakdown[allianceStr].foulPoints

                oprMatchEntry["station1_auto_tower"] = row.score_breakdown[allianceStr].autoTowerRobot1
                oprMatchEntry["station2_auto_tower"] = row.score_breakdown[allianceStr].autoTowerRobot2
                oprMatchEntry["station3_auto_tower"] = row.score_breakdown[allianceStr].autoTowerRobot3
 
                oprMatchEntry["station1_endgame_tower"] = row.score_breakdown[allianceStr].endGameTowerRobot1
                oprMatchEntry["station2_endgame_tower"] = row.score_breakdown[allianceStr].endGameTowerRobot2
                oprMatchEntry["station3_endgame_tower"] = row.score_breakdown[allianceStr].endGameTowerRobot3
 
                oprMatchEntry["endgame_scoring"] = row.score_breakdown[allianceStr].endGameTowerPoints
                oprMatchEntry["total_points"] = row.score_breakdown[allianceStr].totalPoints
                oprMatchEntry["total_tower_points"] = row.score_breakdown[allianceStr].totalTowerPoints

            
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
    autoPoints = np.zeros(len(teams))
    teleopPoints = np.zeros(len(teams))
    teamDeaths = np.zeros(len(teams))
    teamDefenses = np.zeros(len(teams))
    matchScoutingCount = np.zeros(len(teams))

    autoClimb = np.zeros(len(teams))
    endgameClimbL1 = np.zeros(len(teams))
    endgameClimbL2 = np.zeros(len(teams))
    endgameClimbL3 = np.zeros(len(teams))
    autoPassing = np.zeros(len(teams))
    teleopPassing = np.zeros(len(teams))

    # Counting the number of matches that each team has
    stations = ['station1', 'station2', 'station3']
    team_match_counts = oprMatchDataFrame[stations].apply(
        pd.Series.value_counts).reindex(teams, fill_value=0).sum(axis=1)
    teamMatchCount[:] = team_match_counts.values
    # print("Counted Matches per team")

    # Analyzing data that is directly extracted from
    for _, row in oprMatchDataFrame.iterrows():
        for k in range(3):
            # print(k)
            # print(row)
            matchTeam = row["station" + str(k + 1)]
            # print(matchTeam)
            idx = teams.index(matchTeam)
            # print("station" + str(k + 1) + "_endgame_tower")
            # print(row["station" + str(k + 1) + "_endgame_tower"])
            if not row["station" + str(k + 1) + "_endgame_tower"] == "None":
                if row["station" + str(k + 1) + "_endgame_tower"] == "Level1":
                    
                    endgameClimbL1[idx] += 1
                    
                elif row["station" + str(k + 1) + "_endgame_tower"] == "Level2":
                    endgameClimbL2[idx] += 1
                    
                elif row["station" + str(k + 1) + "_endgame_tower"] == "Level3":
                    endgameClimbL3[idx] += 1
                    
            # print("found endgame climb data")
            if not row["station" + str(k + 1) + "_auto_tower"] == "None":
                if row["station" + str(k + 1) + "_auto_tower"] == "Level1" or row["station" + str(k + 1) + "_auto_tower"] == "Level2" or row["station" + str(k + 1) + "_auto_tower"] == "Level3":
                    
                    autoClimb[idx] += 1

    # Analyzing data coming directly from scouting data
    for entry in scoutingBaseData:
        matchScoutingCount[teams.index(str(entry.team_number))] += 1 if entry else 0
        teamDefenses[teams.index(str(entry.team_number))] += 1 if entry.data.miscellaneous.defense else 0
        autoPassing[teams.index(str(entry.team_number))] += 1 if entry.data.auto_scoring.passing_cycles else 0
        teleopPassing[teams.index(str(entry.team_number))] += 1 if entry.data.teleop_scoring.passing_cycles else 0
        teamDeaths[teams.index(str(entry.team_number))
                   ] += 1 if entry.data.miscellaneous.died else 0

    # All of the keys, maxs, and mins
    # ScoutingDataKeys = [
       
    # ]
    # ScoutingDataMins = [
      
    # ]
    # ScoutingDataMaxs = [
        
    # ]
    TBAOnlyKeys = [
        "auto_fuel_scored",
        "teleop_fuel_scored",
        "foul_points",  
    ]
    TBAOnlyMins = [
        0,
        0,
        0,
    ]
    TBAOnlyMaxs = [
        1000000,
        1000000,
        1000000,
    ]
    OPRWeights = [
       1,
       1,
       -1,
    ]

    numEntries = len(scoutingBaseData)
    j = numEntries  # set j to the max number of scout entries to analyze
    # print("setup hardcoded stuff")
    # TBA Data
    # YMatrix = pd.DataFrame(None, columns=unpack_nested_list(ScoutingDataKeys))
    TBAOnlyYMatrix = pd.DataFrame(None, columns=TBAOnlyKeys)
    # YMatrix = oprMatchDataFrame[unpack_nested_list(ScoutingDataKeys)]
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
    teamMatchesList: dict[str, dict[int, list[MatchScouting2026]]] = {
        team: {} for team in blankAEntry}
    scoutingDataFunction = TeamBasedData
    # print("throwing scouting data")
    ratings = {'scouts': [], 'trustRatings': [], 'entries': []}
    try:
        scoutingData, ratings = scoutingDataFunction(
            oprMatchDataFrame, scoutingData)
    except Exception as e:
        print(e)
    # Make A and Y lists with scouting data
    for entry in scoutingData:
        if str(entry.team_number) not in teamMatchesList:
            teamMatchesList[str(entry.team_number)] = {}
        if entry.match_number not in teamMatchesList[str(entry.team_number)]:
            teamMatchesList[str(entry.team_number)][entry.match_number] = []
        teamMatchesList[str(entry.team_number)
                        ][entry.match_number].append(entry)
    # print('trying to find data for all teams.')
    hasEnoughEntriesPerTeam = True
    for team in teamMatchesList:
        if len(teamMatchesList[team].keys()) < 5:
            hasEnoughEntriesPerTeam = False
    if hasEnoughEntriesPerTeam:
        # YMatrix = pd.DataFrame(
        #     None, columns=unpack_nested_list(ScoutingDataKeys))
        Alist = []
    teamIdx = -1
    for team in teams:
        teamIdx += 1
        # teamYEntry = np.zeros(len(unpack_nested_list(ScoutingDataKeys)))
        teamYEntry = np.zeros(len(TBAOnlyKeys))
        for teamMatch in teamMatchesList[team]:
            numEntries = 0
            for entry in scoutingData:
                if (
                    str(entry.team_number) == team
                    and entry.match_number == teamMatch
                ):
                    numEntries += 1
            for entry in scoutingData:
                if (
                    str(entry.team_number) == team
                    and entry.match_number == teamMatch
                ):
                    newY = [
                        entry.data.auto_scoring.fuel_cycles,
                        entry.data.teleop_scoring.fuel_cycles,
                        0,
                    ]
                    teamYEntry = [
                        teamYEntry[i]
                        + (newY[i] / len(teamMatchesList[team]) / numEntries)
                        for i in range(len(teamYEntry))
                    ]
        # YMatrix.loc[len(YMatrix)] = teamYEntry
        teamAEntry = copy.deepcopy(blankAEntry)
        teamAEntry[team] = 1
        Alist.append(teamAEntry)

    # Compiling data into matrices
    AMatrix = pd.DataFrame(Alist, columns=teams)
    APseudoInverse = np.linalg.pinv(AMatrix[teams])
    TBAOnlyAPseudoInverse = np.linalg.pinv(pd.DataFrame(TBAOnlyAList)[teams])
    # print("ready for regression")
    # Multivariate Regression
    XMatrix = pd.DataFrame()

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

    # def perform_genetic_algorithm(i):
    #     ga = geneticAlg(
    #         errorFunction=create_fitness_func(
    #             ScoutingDataMins[i], ScoutingDataMaxs[i]),
    #         functionInputs=[pd.DataFrame(AMatrix[teams]), pd.DataFrame(
    #             YMatrix[ScoutingDataKeys[i]])],
    #         maxs={ScoutingDataKeys[j]: ScoutingDataMaxs[j]
    #               for j in range(len(ScoutingDataKeys))},
    #         mins={ScoutingDataKeys[j]: ScoutingDataMins[j]
    #               for j in range(len(ScoutingDataKeys))},
    #         startingValue=pd.DataFrame(XMatrix[ScoutingDataKeys[i]]),
    #         mutationPercent=mutation_percent_genes,
    #     )
    #     result = ga.run()
    #     for key in result[0].columns:
    #         if type(result[0][key].tolist()) is not None:
    #             results.append(result[0][key].tolist())

    # Number of processes to run simultaneously
    num_processes = 10  # Adjust this value based on your system's capabilities
    # for i in range(len(ScoutingDataKeys)):
    #     perform_genetic_algorithm(i)
    # results = joblib.Parallel(num_processes)(joblib.delayed(perform_genetic_algorithm)(i) for i in range(10))
    # print("Doing TBA only genetic alg")
    for i in range(len(TBAOnlyKeys)):
        ga = geneticAlg(
            errorFunction=create_fitness_func(TBAOnlyMins[i], TBAOnlyMaxs[i]),
            functionInputs=[pd.DataFrame(TBAOnlyAList, columns=teams),
                            pd.DataFrame(TBAOnlyYMatrix[TBAOnlyKeys[i]])],
            maxs={TBAOnlyKeys[j]: TBAOnlyMaxs[j]
                  for j in range(len(TBAOnlyKeys))},
            mins={TBAOnlyKeys[j]: TBAOnlyMins[j]
                  for j in range(len(TBAOnlyKeys))},
            startingValue=pd.DataFrame(TBAOnlyXMatrix[TBAOnlyKeys[i]]),
            mutationPercent=mutation_percent_genes,
        )
        result = ga.run()
        # print(result[0].columns)
        for key in result[0].columns:
            if result[0][key] is not None:
                results.append(result[0][key].tolist())
        # results.append((result[0], len(ScoutingDataKeys)+i))
    # dataKeys = copy.deepcopy(unpack_nested_list(ScoutingDataKeys))
    dataKeys = copy.deepcopy(unpack_nested_list(TBAOnlyKeys))
    dataKeys.extend(unpack_nested_list(TBAOnlyKeys))
    # print("compiling data to json")
    # print(results)
    for i, result in enumerate(results):
        # try:
        # print(dataKeys[i], i)
        # print(result)
        array = np.array(result).ravel()
        TBAOnlyXMatrix[dataKeys[i]] = result
        if i < 1:
            autoPoints += array*OPRWeights[i]
        elif i < 2:
            teleopPoints += array*OPRWeights[i]
        # except Exception as e:
        #     print(i, e)
    # print("looped through results")
    autoClimb = autoClimb / teamMatchCount
    endgameClimbL1 = endgameClimbL1 / teamMatchCount
    endgameClimbL2 = endgameClimbL2 / teamMatchCount
    endgameClimbL3 = endgameClimbL3 / teamMatchCount
    autoPassing = autoPassing / matchScoutingCount
    teleopPassing = teleopPassing / matchScoutingCount
    
    for i in range(len(teamDeaths)):
        if math.isnan(teamDeaths[i]):
            teamDeaths[i] = 0
    for i in range(len(teamDefenses)):
        if math.isnan(teamDefenses[i]):
            teamDefenses[i] = 0
    for i in range(len(autoPassing)):
        if math.isnan(autoPassing[i]):
            autoPassing[i] = 0
    for i in range(len(teleopPassing)):
        if math.isnan(teleopPassing[i]):
            teleopPassing[i] = 0
    L1Points = 10
    L2Points = 20
    L3Points = 30
    autoClimbPoints = 15
    endgameClimbingPoints = endgameClimbL1 * L1Points + endgameClimbL2 * L2Points + endgameClimbL3 * L3Points   
    autoClimbingPoints = autoClimb * autoClimbPoints   
    endgamePoints = endgameClimbingPoints       
    autoPoints += autoClimbingPoints 
    teamClimbingPoints = autoClimbingPoints + endgameClimbingPoints
    teamOPR = endgamePoints + autoPoints + teleopPoints

    XMatrix['auto_fuel_scored'] = autoPoints
    XMatrix['teleop_fuel_scored'] = teleopPoints
    XMatrix.insert(0, 'death_rate', pd.Series(teamDeaths))
    XMatrix.insert(0, 'defense_rate', pd.Series(teamDefenses))
    XMatrix.insert(0, 'climbing_points', pd.Series(teamClimbingPoints))
    XMatrix.insert(0, 'auto_points', pd.Series(autoPoints))
    XMatrix.insert(0, 'teleop_points', pd.Series(teleopPoints))
    XMatrix.insert(0, 'endgame_points', pd.Series(endgamePoints))
    XMatrix.insert(0, 'auto_climb_rate', pd.Series(autoClimb))
    XMatrix.insert(0, 'endgame_climb_L1_rate', pd.Series(endgameClimbL1))
    XMatrix.insert(0, 'endgame_climb_L2_rate', pd.Series(endgameClimbL2))
    XMatrix.insert(0, 'endgame_climb_L3_rate', pd.Series(endgameClimbL3))
    XMatrix.insert(0, 'teleop_pass', pd.Series(teleopPassing))
    XMatrix.insert(0, 'auto_pass', pd.Series(autoPassing))
    XMatrix.insert(0, 'total_pass', pd.Series(teleopPassing + autoPassing))
    XMatrix.insert(0, 'OPR', pd.Series(teamOPR))
    XMatrix.insert(0, 'scouting_data_count', pd.Series(matchScoutingCount))
    XMatrix.insert(0, 'match_count', pd.Series(teamMatchCount))
    XMatrix.insert(0, 'team_number', pd.Series(teams))
    XMatrix.insert(
    0,
    'total_fuel_scored',
    XMatrix['auto_fuel_scored'] + XMatrix['teleop_fuel_scored']
)
    return XMatrix, ratings