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




def build_opr_match_list(data):
    blankOprEntry = {
        "endgame_scoring": 0,
        "total_points": 0,
        "total_tower_points": 0,
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

    oprMatchList = []

    for row in data:
        if row.score_breakdown is None:
            continue

        for allianceStr in row.alliances:
            breakdown = row.score_breakdown.get(allianceStr)
            if breakdown is None:
                continue

            oprMatchEntry = {}

            oprMatchEntry["allianceStr"] = allianceStr
            oprMatchEntry["match_number"] = row.match_number

            try:
                for k in range(3):
                    oprMatchEntry[f"station{k+1}"] = (
                        row.alliances[allianceStr].team_keys[k][3:]
                    )
            except (KeyError, IndexError, TypeError):
                continue

            oprMatchEntry["station1_auto_tower"] = breakdown.autoTowerRobot1
            oprMatchEntry["station2_auto_tower"] = breakdown.autoTowerRobot2
            oprMatchEntry["station3_auto_tower"] = breakdown.autoTowerRobot3

            oprMatchEntry["station1_endgame_tower"] = breakdown.endGameTowerRobot1
            oprMatchEntry["station2_endgame_tower"] = breakdown.endGameTowerRobot2
            oprMatchEntry["station3_endgame_tower"] = breakdown.endGameTowerRobot3

            oprMatchEntry["endgame_scoring"] = breakdown.endGameTowerPoints
            oprMatchEntry["total_tower_points"] = breakdown.totalTowerPoints
            oprMatchEntry["total_points"] = breakdown.totalPoints
            oprMatchEntry["auto_fuel_scored"] = breakdown.hubScore.autoCount
            oprMatchEntry["teleop_fuel_scored"] = breakdown.hubScore.teleopCount
            oprMatchEntry["total_fuel_scored"] = (
                breakdown.hubScore.autoCount
                + breakdown.hubScore.teleopCount
            )
            oprMatchEntry["foul_points"] = breakdown.foulPoints

            oprMatchList.append(oprMatchEntry)

    # IMPORTANT FIX
    oprMatchDataFrame = pd.DataFrame(
        oprMatchList,
        columns=blankOprEntry.keys()
    )

    return oprMatchList, oprMatchDataFrame


def build_team_index(oprMatchDataFrame):

    teams = []
    for k in range(3):
        for matchTeam in oprMatchDataFrame["station" + str(k + 1)]:
            if not teams.__contains__(matchTeam):
                teams.append(matchTeam)
    teams.sort()
    team_idx_map = {team: i for i, team in enumerate(teams)}
    return teams, team_idx_map


def compute_tba_stats(oprMatchDataFrame, teams):

    teamMatchCount = np.zeros(len(teams))
    autoClimb = np.zeros(len(teams))
    endgameClimbL1 = np.zeros(len(teams))
    endgameClimbL2 = np.zeros(len(teams))
    endgameClimbL3 = np.zeros(len(teams))

    stations = ['station1', 'station2', 'station3']
    team_match_counts = oprMatchDataFrame[stations].apply(
        pd.Series.value_counts).reindex(teams, fill_value=0).sum(axis=1)
    teamMatchCount[:] = team_match_counts.values

    for _, row in oprMatchDataFrame.iterrows():
        for k in range(3):
            matchTeam = row["station" + str(k + 1)]
            idx = teams.index(matchTeam)

            if not row["station" + str(k + 1) + "_endgame_tower"] == "None":
                if row["station" + str(k + 1) + "_endgame_tower"] == "Level1":
                    endgameClimbL1[idx] += 1
                elif row["station" + str(k + 1) + "_endgame_tower"] == "Level2":
                    endgameClimbL2[idx] += 1
                elif row["station" + str(k + 1) + "_endgame_tower"] == "Level3":
                    endgameClimbL3[idx] += 1

            if not row["station" + str(k + 1) + "_auto_tower"] == "None":
                if row["station" + str(k + 1) + "_auto_tower"] in ("Level1", "Level2", "Level3"):
                    autoClimb[idx] += 1

    return teamMatchCount, autoClimb, endgameClimbL1, endgameClimbL2, endgameClimbL3


def compute_scouting_stats(scoutingBaseData, teams, team_idx_map):
    teamDeaths = np.zeros(len(teams))
    teamDefenses = np.zeros(len(teams))
    matchScoutingCount = np.zeros(len(teams))

    for entry in scoutingBaseData:
        team_str = str(entry.team_number)
        idx = team_idx_map.get(team_str)
        if idx is not None:
            matchScoutingCount[idx] += 1
            if entry.data.miscellaneous.died:
                teamDeaths[idx] +=1
            if entry.data.miscellaneous.defense:
                teamDefenses[idx] +=1
        else:
            print(f"Skipping scouting entry for team {team_str} (not in TBA matches)")

    teamDeaths /= matchScoutingCount
    for i in range(len(teamDeaths)):
        if math.isnan(teamDeaths[i]):
            teamDeaths[i] = 0

    teamDefenses /= matchScoutingCount
    for i in range(len(teamDefenses)):
        if math.isnan(teamDefenses[i]):
            teamDefenses[i] = 0

    return matchScoutingCount, teamDeaths, teamDefenses


def run_opr_regression(
    oprMatchDataFrame,
    scoutingBaseData,
    teams,
    SCOUTING_DATA_KEYS,
    TBA_ONLY_KEYS,
):

    blankAEntry = {team: 0 for team in teams}

    YMatrix = oprMatchDataFrame[unpack_nested_list(SCOUTING_DATA_KEYS)]
    TBAOnlyYMatrix = pd.DataFrame(oprMatchDataFrame[TBA_ONLY_KEYS])

    matchTeamMatrix = oprMatchDataFrame[["station1", "station2", "station3"]]
    Alist = []
    for game in matchTeamMatrix.values.tolist():
        AEntry = copy.deepcopy(blankAEntry)
        for team in game:
            AEntry[team] = 1
        Alist.append(AEntry)
    TBAOnlyAList = copy.deepcopy(Alist)

    numEntries = len(scoutingBaseData)
    j = numEntries
    scoutingData = copy.deepcopy(scoutingBaseData[:j])
    teamMatchesList = {team: {} for team in blankAEntry}
    ratings = {'scouts': [], 'trustRatings': [], 'entries': []}
    try:
        scoutingData, ratings = TeamBasedData(oprMatchDataFrame, scoutingData)
    except Exception as e:
        print(e)

    for entry in scoutingData:
        if str(entry.team_number) not in teamMatchesList:
            teamMatchesList[str(entry.team_number)] = {}
        if entry.match_number not in teamMatchesList[str(entry.team_number)]:
            teamMatchesList[str(entry.team_number)][entry.match_number] = []
        teamMatchesList[str(entry.team_number)][entry.match_number].append(entry)

    hasEnoughEntriesPerTeam = all(
        len(teamMatchesList[team].keys()) >= 5 for team in teamMatchesList
    )
    if hasEnoughEntriesPerTeam:
        YMatrix = pd.DataFrame(None, columns=unpack_nested_list(SCOUTING_DATA_KEYS))
        Alist = []

    teamIdx = -1
    for team in teams:
        teamIdx += 1
        teamYEntry = np.zeros(len(unpack_nested_list(SCOUTING_DATA_KEYS)))

        for teamMatch in teamMatchesList[team]:
            numEntries = sum(
                1 for entry in scoutingData
                if str(entry.team_number) == team and entry.match_number == teamMatch
            )
            for entry in scoutingData:
                if str(entry.team_number) == team and entry.match_number == teamMatch:
                    newY = [
                        entry.data.auto_scoring.fuel_scored,
                        entry.data.teleop_scoring.fuel_scored,
                    ]
                    teamYEntry = [
                        teamYEntry[i] + (newY[i] / len(teamMatchesList[team]) / numEntries)
                        for i in range(len(teamYEntry))
                    ] if numEntries > 0 else teamYEntry
        YMatrix.loc[len(YMatrix)] = teamYEntry
        teamAEntry = blankAEntry.copy()
        teamAEntry[team] = 1
        Alist.append(teamAEntry)

    AMatrix = pd.DataFrame(Alist, columns=teams)
    APseudoInverse = np.linalg.pinv(AMatrix[teams])
    TBAOnlyAPseudoInverse = np.linalg.pinv(pd.DataFrame(TBAOnlyAList)[teams])

    XMatrix = pd.DataFrame(APseudoInverse @ YMatrix)
    TBAOnlyXMatrix = pd.DataFrame(TBAOnlyAPseudoInverse @ TBAOnlyYMatrix)

    return (
        AMatrix, YMatrix, TBAOnlyAList, TBAOnlyYMatrix,
        XMatrix, TBAOnlyXMatrix,
        teamMatchesList, scoutingData, ratings,
    )


def run_genetic_algorithms(
    AMatrix, YMatrix, TBA_ONLY_ALIST, TBA_ONLY_YMATRIX,
    XMatrix, TBA_ONLY_XMATRIX,
    teams,
    SCOUTING_DATA_KEYS, SCOUTING_DATA_MINS, SCOUTING_DATA_MAXS,
    TBA_ONLY_KEYS, TBA_ONLY_MINS, TBA_ONLY_MAXS,
    mutation_percent_genes=0.02,
):

    def create_fitness_func(min: float, max: float):
        def func(solution, functionInputs):
            solutionMatrix = np.array(solution)
            a = np.array(functionInputs[0])
            y = np.array(functionInputs[1])
            calculatedY = a @ solutionMatrix
            difference = np.abs(calculatedY - y)
            error = np.sum(difference)
            exceeding_min = solutionMatrix < min
            exceeding_max = solutionMatrix > max
            error += 1000 * (np.sum(exceeding_min) + np.sum(exceeding_max))
            return error
        return func

    results = []

    for i in range(len(SCOUTING_DATA_KEYS)):
        ga = geneticAlg(
            errorFunction=create_fitness_func(SCOUTING_DATA_MINS[i], SCOUTING_DATA_MAXS[i]),
            functionInputs=[
                pd.DataFrame(AMatrix[teams]),
                pd.DataFrame(YMatrix[SCOUTING_DATA_KEYS[i]]),
            ],
            maxs={SCOUTING_DATA_KEYS[j]: SCOUTING_DATA_MAXS[j] for j in range(len(SCOUTING_DATA_KEYS))},
            mins={SCOUTING_DATA_KEYS[j]: SCOUTING_DATA_MINS[j] for j in range(len(SCOUTING_DATA_KEYS))},
            startingValue=pd.DataFrame(XMatrix[SCOUTING_DATA_KEYS[i]]),
            mutationPercent=mutation_percent_genes,
        )
        result = ga.run()
        for key in result[0].columns:
            values = result[0][key].dropna().tolist()
            if values:
                results.append(values)

    for i in range(len(TBA_ONLY_KEYS)):
        ga = geneticAlg(
            errorFunction=create_fitness_func(TBA_ONLY_MINS[i], TBA_ONLY_MAXS[i]),
            functionInputs=[
                pd.DataFrame(TBA_ONLY_ALIST, columns=teams),
                pd.DataFrame(TBA_ONLY_YMATRIX[TBA_ONLY_KEYS[i]]),
            ],
            maxs={TBA_ONLY_KEYS[j]: TBA_ONLY_MAXS[j] for j in range(len(TBA_ONLY_KEYS))},
            mins={TBA_ONLY_KEYS[j]: TBA_ONLY_MINS[j] for j in range(len(TBA_ONLY_KEYS))},
            startingValue=pd.DataFrame(TBA_ONLY_XMATRIX[TBA_ONLY_KEYS[i]]),
            mutationPercent=mutation_percent_genes,
        )
        result = ga.run()
        for key in result[0].columns:
            if result[0][key] is not None:
                results.append(result[0][key].tolist())

    dataKeys = copy.deepcopy(unpack_nested_list(SCOUTING_DATA_KEYS))
    dataKeys.extend(unpack_nested_list(TBA_ONLY_KEYS))
    return results, dataKeys


def compile_xmatrix(
    XMatrix, results, dataKeys, OPRWeights,
    teams, teamMatchCount, matchScoutingCount,
    autoClimb, endgameClimbL1, endgameClimbL2, endgameClimbL3,
    teamDeaths, teamDefenses,
):

    autoPoints = np.zeros(len(teams))
    teleopPoints = np.zeros(len(teams))

    for i, result in enumerate(results):
        array = np.array(result).ravel()
        XMatrix[dataKeys[i]] = result

        if i < 1:
            autoPoints += array * OPRWeights[i]
        elif i < 2:
            teleopPoints += array * OPRWeights[i]

    autoClimb = autoClimb / teamMatchCount
    endgameClimbL1 = endgameClimbL1 / teamMatchCount
    endgameClimbL2 = endgameClimbL2 / teamMatchCount
    endgameClimbL3 = endgameClimbL3 / teamMatchCount

    endgamePoints = endgameClimbL1 * 10 + endgameClimbL2 * 20 + endgameClimbL3 * 30
    autoPoints += autoClimb * 15
    teamClimbingPoints = endgameClimbL1 * 10 + endgameClimbL2 * 20 + endgameClimbL3 * 30 + autoClimb * 15
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
    XMatrix.insert(0, 'OPR', pd.Series(teamOPR))
    XMatrix.insert(0, 'scouting_data_count', pd.Series(matchScoutingCount))
    XMatrix.insert(0, 'match_count', pd.Series(teamMatchCount))
    XMatrix.insert(0, 'team_number', pd.Series(teams))
    XMatrix.insert(0, 'total_fuel_scored',
                   XMatrix['auto_fuel_scored'] + XMatrix['teleop_fuel_scored'])

    return XMatrix


def compute_defense_dpr(data, XMatrix, teams, DefenseOnlyKeys):
    blankDefenseEntry = {
        "auto_fuel_denied": 0,
        "teleop_fuel_denied": 0,
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

    defenseMatchList = []

    def get_val(team_key, col):
        vals = XMatrix.loc[XMatrix["team_number"] == team_key, col].values
        return vals[0] if len(vals) > 0 else 0

    for row in data:
        if row.score_breakdown is None:
            continue

        for allianceStr in row.alliances:
            opponentStr = "blue" if allianceStr == "red" else "red"

            if opponentStr not in row.score_breakdown:
                continue

            defenseMatchEntry = copy.deepcopy(blankDefenseEntry)
            defenseMatchEntry["allianceStr"] = allianceStr
            defenseMatchEntry["match_number"] = row.match_number

            try:
                for k in range(3):
                    defenseMatchEntry[f"station{k + 1}"] = (
                        row.alliances[allianceStr].team_keys[k][3:]
                    )

                opp_keys = [
                    row.alliances[opponentStr].team_keys[i][3:]
                    for i in range(3)
                ]
            except (KeyError, IndexError, TypeError):
                continue

            predictedAutoPoints = sum(
                get_val(team, "auto_fuel_scored") for team in opp_keys
            )
            predictedTeleopPoints = sum(
                get_val(team, "teleop_fuel_scored") for team in opp_keys
            )

            actual_breakdown = row.score_breakdown[opponentStr]

            defenseMatchEntry["auto_fuel_denied"] = (
                predictedAutoPoints - actual_breakdown.hubScore.autoCount
            )
            defenseMatchEntry["teleop_fuel_denied"] = (
                predictedTeleopPoints - actual_breakdown.hubScore.teleopCount
            )

            defenseMatchList.append(defenseMatchEntry)

    if not defenseMatchList:
        return XMatrix

    defenseMatchDataFrame = pd.DataFrame(defenseMatchList)

    required_cols = {"station1", "station2", "station3"}
    if defenseMatchDataFrame.empty or not required_cols.issubset(defenseMatchDataFrame.columns):
        return XMatrix

    blankAEntry = {team: 0 for team in teams}
    TBAOnlyAList = []

    matchTeamMatrix = defenseMatchDataFrame[["station1", "station2", "station3"]]

    for game in matchTeamMatrix.values.tolist():
        AEntry = copy.deepcopy(blankAEntry)

        for team in game:
            if team in AEntry:
                AEntry[team] = 1

        TBAOnlyAList.append(AEntry)

    if not TBAOnlyAList:
        return XMatrix

    AMatrixDefense = pd.DataFrame(TBAOnlyAList, columns=teams)

    if AMatrixDefense.empty:
        return XMatrix

    APseudoInverseDefense = np.linalg.pinv(AMatrixDefense[teams])

    if not set(DefenseOnlyKeys).issubset(defenseMatchDataFrame.columns):
        return XMatrix

    YDefenseMatrix = pd.DataFrame(defenseMatchDataFrame[DefenseOnlyKeys])

    XMatrixDefense = pd.DataFrame(
        APseudoInverseDefense @ YDefenseMatrix,
        columns=DefenseOnlyKeys
    )

    for key in XMatrixDefense.columns:
        XMatrix[key] = XMatrixDefense[key]

    return XMatrix




def analyzeData(TBAdata: list[TBAMatch2026], scoutingData: list[MatchScouting2026]):
    data = copy.deepcopy(TBAdata)
    scoutingBaseData = scoutingData

  
    SCOUTING_DATA_KEYS = ["auto_fuel_scored", "teleop_fuel_scored"]
    SCOUTING_DATA_MINS = [0, 0]
    SCOUTING_DATA_MAXS = [1000, 1000]
    DEFENSE_ONLY_KEYS = ["auto_fuel_denied", "teleop_fuel_denied"]
    TBA_ONLY_KEYS = ["foul_points"]
    TBA_ONLY_MINS = [0]
    TBA_ONLY_MAXS = [1000]
    OPR_WEIGHTS = [1, 1]

    _, oprMatchDataFrame = build_opr_match_list(data)

    teams, team_idx_map = build_team_index(oprMatchDataFrame)

    teamMatchCount, autoClimb, endgameClimbL1, endgameClimbL2, endgameClimbL3 = \
        compute_tba_stats(oprMatchDataFrame, teams)

    matchScoutingCount, teamDeaths, teamDefenses = \
        compute_scouting_stats(scoutingBaseData, teams, team_idx_map)

    (AMatrix, YMatrix, TBAOnlyAList, TBAOnlyYMatrix,
     XMatrix, TBAOnlyXMatrix,
     teamMatchesList, scoutingData, ratings) = run_opr_regression(
        oprMatchDataFrame, scoutingBaseData, teams,
        SCOUTING_DATA_KEYS, TBA_ONLY_KEYS,
    )

    results, dataKeys = run_genetic_algorithms(
        AMatrix, YMatrix, TBAOnlyAList, TBAOnlyYMatrix,
        XMatrix, TBAOnlyXMatrix, teams,
        SCOUTING_DATA_KEYS, SCOUTING_DATA_MINS, SCOUTING_DATA_MAXS,
        TBA_ONLY_KEYS, TBA_ONLY_MINS, TBA_ONLY_MAXS,
    )

    XMatrix = compile_xmatrix(
        XMatrix, results, dataKeys, OPR_WEIGHTS,
        teams, teamMatchCount, matchScoutingCount,
        autoClimb, endgameClimbL1, endgameClimbL2, endgameClimbL3,
        teamDeaths, teamDefenses,
    )

    XMatrix = compute_defense_dpr(data, XMatrix, teams, DEFENSE_ONLY_KEYS)

    return XMatrix, ratings