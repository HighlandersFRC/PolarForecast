import copy


def blank_group_data(team: str) -> dict:
    return {
        "historical": False,
        "key": team,
        "rank": 0,
        "team_number": team[3:],
        "match_count": 0,
        "OPR": 0.0,
        "total_pass": 0.0,
        "auto_pass": 0.0,
        "teleop_pass": 0.0,
        "endgame_points": 0.0,
        "teleop_points": 0.0,
        "auto_points": 0.0,
        "climbing_points": 0.0,
        "death_rate": 0.0,
        "defense_rate": 0.0,
        "auto_fuel_cycles": 0.0,
        "teleop_fuel_cycles": 0.0,
        "foul_points": 0.0,
        "simulated_rp": 0,
        "simulated_rank": 0
    }

BLANK_OPR_ENTRY = {
    "endgame_scoring": 0,
    "total_points": 0,
    "total_tower_points": 0,

    "auto_fuel_cycles": 0,
    "teleop_fuel_cycles": 0,
    "total_fuel_cycles": 0,

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

def create_blank_opr_entry():
    return copy.deepcopy(BLANK_OPR_ENTRY)


def create_blank_match_prediction(match):
    return {
        "comp_level": match.comp_level,
        "key": match.key,
        "match_number": match.match_number,
        "set_number": match.set_number,

        "blue_teams": match.alliances['blue'].team_keys,
        "blue_dq_team_keys": match.alliances['blue'].dq_team_keys,
        "blue_surrogate_team_keys": match.alliances['blue'].surrogate_team_keys,

        "blue_score": 0,
        "blue_climbing": 0,
        "blue_auto_points": 0,
        "blue_teleop_points": 0,
        "blue_endgame_points": 0,
        "blue_auto_fuel_cycles": 0,
        "blue_teleop_fuel_cycles": 0,
        "blue_auto_passing_cycles": 0,
        "blue_teleop_passing_cycles": 0,

        "blue_actual_score": match.score_breakdown["blue"].totalPoints,

        "red_teams": match.alliances['red'].team_keys,
        "red_dq_team_keys": match.alliances['red'].dq_team_keys,
        "red_surrogate_team_keys": match.alliances['red'].surrogate_team_keys,

        "red_score": 0,
        "red_climbing": 0,
        "red_auto_points": 0,
        "red_teleop_points": 0,
        "red_endgame_points": 0,
        "red_auto_fuel_cycles": 0,
        "red_teleop_fuel_cycles": 0,
        "red_auto_passing_cycles": 0,
        "red_teleop_passing_cycles": 0,

        "red_actual_score": match.score_breakdown["red"].totalPoints,

        "predicted": False,
    }
