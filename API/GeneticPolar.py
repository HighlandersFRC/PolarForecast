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
NET_ALGAE_COMPLETION_RATE = 0.9


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




def analyzeData(TBAdata: list[TBAMatch2026], scoutingData: list[MatchScouting2026]):
    data = copy.deepcopy(TBAdata)
    # print(data)
    scoutingBaseData = scoutingData
    oprMatchList = []
    blankOprEntry = {
        "endgame_scoring": 0,
        "total_points": 0,
        "total_tower_points": 0,
        
        # "auto_fuel_cycles": 0,
        # "teleop_fuel_cycles": 0,
        # "total_fuel_cycles": 0,

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
        if row.score_breakdown is None:
            continue

        for allianceStr in row.alliances:
            breakdown = row.score_breakdown[allianceStr]

            oprMatchEntry = copy.deepcopy(blankOprEntry)


            oprMatchEntry["allianceStr"] = allianceStr
            oprMatchEntry["match_number"] = row.match_number

            for k in range(3):
                oprMatchEntry[f"station{k+1}"] = row.alliances[allianceStr].team_keys[k][3:]

           
            oprMatchEntry["station1_auto_tower"] = breakdown.autoTowerRobot1
            oprMatchEntry["station2_auto_tower"] = breakdown.autoTowerRobot2
            oprMatchEntry["station3_auto_tower"] = breakdown.autoTowerRobot3

            
            oprMatchEntry["station1_endgame_tower"] = breakdown.endGameTowerRobot1
            oprMatchEntry["station2_endgame_tower"] = breakdown.endGameTowerRobot2
            oprMatchEntry["station3_endgame_tower"] = breakdown.endGameTowerRobot3

            
            oprMatchEntry["endgame_scoring"] = breakdown.endGameTowerPoints
            oprMatchEntry["total_tower_points"] = breakdown.totalTowerPoints
            oprMatchEntry["total_points"] = breakdown.totalPoints
            oprMatchEntry["auto_fuel_cycles"] = breakdown.hubScore.autoCount
            oprMatchEntry["teleop_fuel_cycles"] = breakdown.hubScore.teleopCount
            oprMatchEntry["total_fuel_cycles"] = breakdown.hubScore.autoCount + breakdown.hubScore.teleopCount
           
            oprMatchEntry["foul_points"] = breakdown.foulPoints
            # print(oprMatchEntry)



            
          
            oprMatchList.append(copy.deepcopy(oprMatchEntry))
    oprMatchDataFrame = pd.DataFrame(oprMatchList)
    # print(oprMatchDataFrame)
    teams = [] 
    for k in range(3): 
        # print(k)
        for matchTeam in oprMatchDataFrame["station" + str(k + 1)]: 
            exists = False 
            exists = teams.__contains__(matchTeam) 
            # print(exists)
            if not exists: 
                teams.append(matchTeam)
    teams.sort()
    # print("made list of team")
    # Initializing sets of Data
    teamMatchCount = np.zeros(len(teams))
    autoClimb = np.zeros(len(teams))
    endgameClimbL1 = np.zeros(len(teams))
    endgameClimbL2 = np.zeros(len(teams))
    endgameClimbL3 = np.zeros(len(teams))
    autoPoints = np.zeros(len(teams))
    teleopPoints = np.zeros(len(teams))
    teamDeaths = np.zeros(len(teams))
    teamDefenses = np.zeros(len(teams))
    matchScoutingCount = np.zeros(len(teams))
    autoPass = np.zeros(len(teams))
    telePass = np.zeros(len(teams))
    

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
    # print("found TBA only stats")

    # Analyzing data coming directly from scouting data
    # print("Scouting data length:", len(scoutingBaseData))
    # print("First few entries:", scoutingBaseData[:3])

    team_idx_map = {team: i for i, team in enumerate(teams)}
    # print("Team index map:", team_idx_map)

    for entry in scoutingBaseData:
        # print("Processing entry:", entry)
        # print(type(entry))
        team_str = str(entry.team_number)
        
        idx = team_idx_map.get(team_str)
        
        # print("Starting idx potential error")
        if idx is not None:
            # print("started match")
            matchScoutingCount[idx] += 1
            # print("started died")
            teamDeaths[idx] += 1 if entry.data.miscellaneous.died else 0
            # print("started defense")
            teamDefenses[idx] += entry.data.miscellaneous.defense or 0
            # print("started autoPass")
            autoPass[idx] += entry.data.auto_scoring.passing_cycles or 0
            # print("started teleopPass")
            telePass[idx] += entry.data.teleop_scoring.passing_cycles or 0
        else:
            print(f"Skipping scouting entry for team {team_str} (not in TBA matches)")
        # print("Finished the idx")

    # print("Match scouting counts:", matchScoutingCount)
    # print("Team deaths:", teamDeaths)
    # print("Auto passing cycles:", autoPass)
    # print("Teleop passing cycles:", telePass)
        

    # All of the keys, maxs, and mins

    # ScoutingDataKeys = [
    #     "auto_fuel_cycles",
    #     "teleop_fuel_cycles",
    # ]
    # ScoutingDataMins = [
    #     0,
    #     0,
    # ]
    # ScoutingDataMaxs = [
    #     10000,
    #     10000,
    # ]

    TBAOnlyKeys = [
        "auto_fuel_cycles",
        "teleop_fuel_cycles",
        "foul_points",
    ]

    TBAOnlyMins = [
        0,
        0,
        0,
    ]
    TBAOnlyMaxs = [
        10000,
        10000,
        10000,
    ]
    OPRWeights = [
        1,
        1,
        -1,
    ]

    numEntries = len(scoutingBaseData)
    j = numEntries  # set j to the max number of scouting entries to analyze
    # print("setup hardcoded stuff")
    # TBA Data
    # YMatrix = pd.DataFrame(None, columns=unpack_nested_list(ScoutingDataKeys))
    TBAOnlyYMatrix = pd.DataFrame(None, columns=TBAOnlyKeys)
    # print(ScoutingDataKeys)
    # YMatrix = oprMatchDataFrame[unpack_nested_list(ScoutingDataKeys)]
    # print("ymatrix set up")
    # print(YMatrix)
    TBAOnlyYMatrix = pd.DataFrame(oprMatchDataFrame[TBAOnlyKeys])
    print("tba only ymatrix set up")
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
        for teamMatch in teamMatchesList[team]:
            numEntries = 0
            for entry in scoutingData:
                if (
                    str(entry.team_number) == team
                    and entry.match_number == teamMatch
                ):
                    # print("numentries")
                    numEntries += 1
                    # print("finished numentires")
            for entry in scoutingData:
                if (
                    str(entry.team_number) == team
                    and entry.match_number == teamMatch
                ):
                    newY = [
                        entry.data.auto_scoring.fuel_cycles,
                        entry.data.teleop_scoring.fuel_cycles,
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
    # num_processes = 10  # Adjust this value based on your system's capabilities
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
    #     # results.append((result[0], len(ScoutingDataKeys)+i))
    # dataKeys = copy.deepcopy(unpack_nested_list(ScoutingDataKeys))
    dataKeys = copy.deepcopy(unpack_nested_list(TBAOnlyKeys))
    # print("compiling data to json")
    # print(results)
    for i, result in enumerate(results):
        # try:
        # print(dataKeys[i], i)
        # print(result)
        array = np.array(result).ravel()
        XMatrix[dataKeys[i]] = result
        
        if i < 1:
            # print("auto points")
            autoPoints += array*OPRWeights[i]
            # print("finished auto points")
        elif i < 2:
            # print("teleop points")
            teleopPoints += array*OPRWeights[i]
            # print("finished teleop points")
        # except Exception as e:
        #     print(i, e)
    # print("looped through results")
    autoClimb = autoClimb / teamMatchCount
    endgameClimbL1 = endgameClimbL1 / teamMatchCount
    endgameClimbL2 = endgameClimbL2 / teamMatchCount
    endgameClimbL3 = endgameClimbL3 / teamMatchCount
    autoPass = autoPass / matchScoutingCount
    telePass = telePass / matchScoutingCount
    
    for i in range(len(telePass)):
        if math.isnan(telePass[i]):
            telePass[i] = 0
    for i in range(len(autoPass)):
        if math.isnan(autoPass[i]):
            autoPass[i] = 0
    teamDeaths /= matchScoutingCount
    for i in range(len(teamDeaths)):
        if math.isnan(teamDeaths[i]):
            teamDeaths[i] = 0
    teamDefenses /= matchScoutingCount
    for i in range(len(teamDefenses)):
        if math.isnan(teamDefenses[i]):
            teamDefenses[i] = 0
    endgamePoints = endgameClimbL1 * 10 + endgameClimbL2 * 20 + endgameClimbL3 * 30
    # print("auto climb += auto points")
    autoPoints += autoClimb * 15
    # print("finished auot climb += auto points")
    teamClimbingPoints = endgameClimbL1 * 10 + endgameClimbL2 * 20 + endgameClimbL3 * 30 + autoClimb * 15
    # teleopPoints += teamFeeding
    teamOPR = endgamePoints + autoPoints + teleopPoints

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
    XMatrix.insert(0, 'teleop_pass', pd.Series(telePass))
    XMatrix.insert(0, 'auto_pass', pd.Series(autoPass))
    XMatrix.insert(0, 'total_pass', pd.Series(telePass + autoPass))
    XMatrix.insert(0, 'OPR', pd.Series(teamOPR))
    XMatrix.insert(0, 'scouting_data_count', pd.Series(matchScoutingCount))
    XMatrix.insert(0, 'match_count', pd.Series(teamMatchCount))
    XMatrix.insert(0, 'team_number', pd.Series(teams))
#     XMatrix.insert(
#     0,
#     'total_fuel_cycles',
#     XMatrix['auto_fuel_cycles'] + XMatrix['teleop_fuel_cycles']
# )

    
    # print(XMatrix)
    return XMatrix, ratings