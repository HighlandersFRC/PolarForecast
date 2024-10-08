stat_description = {
  "scoutingData": [
    {
      "stat_key": "match_number",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Match Number",
      "stat_type": "int",
      "stat": {}
    },
    {
      "stat_key": "scout_name",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Scout Name",
      "stat_type": "str",
      "stat": {}
    },
    {
      "stat_key": "auto_amp",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Auto Amp",
      "stat_type": "int",
      "stat": {}
    },
    {
      "stat_key": "auto_speaker",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Auto Speaker",
      "stat_type": "int",
      "stat": {}
    },
    {
      "stat_key": "teleop_amp",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Teleop Amp",
      "stat_type": "int",
      "stat": {}
    },
    {
      "stat_key": "teleop_speaker",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Teleop Speaker",
      "stat_type": "int",
      "stat": {}
    },
    {
      "stat_key": "teleop_amped_speaker",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Amplified Speaker",
      "stat_type": "int",
      "stat": {}
    },
    {
      "stat_key": "died",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Died?",
      "stat_type": "int",
      "stat": {}
    },
    {
      "stat_key": "comments",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Comments",
      "stat_type": "str",
      "stat": {}
    }
  ],
  "pitData": [
    {
      "stat_key": "drive_train",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Drive Train",
      "stat_type": "str",
      "stat": {}
    },
    {
      "stat_key": "amp_scoring",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Amp Scoring",
      "stat_type": "bool",
      "stat": {}
    },
    {
      "stat_key": "speaker_scoring",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Speaker Scoring",
      "stat_type": "bool",
      "stat": {}
    },
    {
      "stat_key": "trap_scoring",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Trap Scoring",
      "stat_type": "bool",
      "stat": {}
    },
    {
      "stat_key": "can_climb",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Climbing?",
      "stat_type": "bool",
      "stat": {}
    },
    {
      "stat_key": "can_harmonize",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Harmony?",
      "stat_type": "bool",
      "stat": {}
    },
    {
      "stat_key": "go_under_stage",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Go Under Stage",
      "stat_type": "bool",
      "stat": {}
    },
    {
      "stat_key": "ground_pick_up",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Ground Pickup?",
      "stat_type": "bool",
      "stat": {}
    },
    {
      "stat_key": "feeder_pick_up",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Feeder Pickup?",
      "stat_type": "bool",
      "stat": {}
    },
    {
      "stat_key": "spares",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Spare Parts?",
      "stat_type": "num",
      "stat": {}
    },
    {
      "stat_key": "favorite_color",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Favorite Color",
      "stat_type": "str",
      "stat": {}
    }
  ],
  "data": [
    {
      "stat_key": "rank",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Rank",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "simulated_rank",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Simulated Rank",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "climbing_points",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Climb Points",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "climbing",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Climb Rate",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "mobility",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Mobility",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "parking",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Parking",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "auto_notes",
      "solve_strategy": "sum",
      "report_stat": True,
      "display_name": "Auto Notes",
      "stat": {
        "component_stats": [
          "auto_speaker",
          "auto_amp"
        ]
      },
      "stat_type": "num",
      "chart": True
    },
    {
      "stat_key": "teleop_notes",
      "solve_strategy": "sum",
      "report_stat": True,
      "display_name": "Teleop Notes",
      "stat": {
        "component_stats": [
          "teleop_speaker",
          "teleop_amped_speaker",
          "teleop_amp",
          "teleop_pass"
        ]
      },
      "stat_type": "num",
      "chart": True
    },
    {
      "stat_key": "notes",
      "solve_strategy": "sum",
      "report_stat": True,
      "display_name": "Notes",
      "stat": {
        "component_stats": [
          "auto_speaker",
          "auto_amp",
          "teleop_speaker",
          "teleop_amped_speaker",
          "teleop_amp",
          "teleop_pass"
        ]
      },
      "stat_type": "num",
      "chart": True
    },
    {
      "stat_key": "auto_points",
      "solve_strategy": "sum",
      "report_stat": True,
      "display_name": "Auto",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "teleop_points",
      "solve_strategy": "sum",
      "report_stat": True,
      "display_name": "Teleop",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "endgame_points",
      "solve_strategy": "sum",
      "report_stat": True,
      "display_name": "End Game",
      "stat": {
        "component_stats": [
          "endGameChargeStation"
        ]
      },
      "stat_type": "num"
    },
    {
      "stat_key": "auto_speaker",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "AS",
      "stat": {},
      "stat_type": "num",
      "chart": True
    },
    {
      "stat_key": "auto_amp",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "AA",
      "stat": {},
      "stat_type": "num",
      "chart": True
    },
    {
      "stat_key": "teleop_pass",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "Pass",
      "stat": {},
      "stat_type": "num",
      "chart": True
    },
    {
      "stat_key": "teleop_speaker",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "TS",
      "stat": {},
      "stat_type": "num",
      "chart": True
    },
    {
      "stat_key": "teleop_amped_speaker",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "TAS",
      "stat": {},
      "stat_type": "num",
      "chart": True
    },
    {
      "stat_key": "teleop_amp",
      "solve_strategy": "custom",
      "report_stat": True,
      "display_name": "TA",
      "stat": {},
      "stat_type": "num",
      "chart": True
    },
    {
      "stat_key": "mic",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Mic",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "harmony_points",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Harmony",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "match_count",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Match Count",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "harmony",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Harmony",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "trap_points",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Trap Points",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "trap",
      "solve_strategy": "custom",
      "report_stat": False,
      "display_name": "Trap Rate",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "OPR",
      "solve_strategy": "sum",
      "report_stat": True,
      "display_name": "OPR",
      "stat": {
        "component_stats": [
          "teleopPoints",
          "autoPoints",
          "endgamePoints"
        ]
      },
      "stat_type": "num"
    },
    {
      "stat_key": "death_rate",
      "solve_strategy": "sum",
      "report_stat": True,
      "display_name": "Death Rate",
      "stat": {},
      "stat_type": "num"
    },
    {
      "stat_key": "expectedRanking",
      "solve_strategy": "sum",
      "report_stat": False,
      "display_name": "Expected Ranking",
      "stat": {
        "component_stats": []
      },
      "stat_type": "num"
    },
    {
      "stat_key": "schedule",
      "solve_strategy": "post",
      "report_stat": False,
      "display_name": "Schedule",
      "stat": {},
      "stat_type": "num"
    }
  ]
}