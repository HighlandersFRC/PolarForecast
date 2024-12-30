class EventData {
  final String eventCode;
  final List<TeamData> teams;

  EventData({required this.eventCode, required this.teams});

  factory EventData.fromJson(Map<String, dynamic> json) {
    var teamsList = json['data'] as List;
    List<TeamData> teams = teamsList
        .where((item) => item['historical'] == false)
        .map((item) => TeamData.fromJson(item))
        .toList();

    return EventData(
      eventCode: json['event_code'],
      teams: teams,
    );
  }
}

class TeamData {
  final int rank;
  final String teamNumber;
  final double opr;
  final double endgamePoints;
  final double teleopPoints;
  final double autoPoints;
  final double notes;

  TeamData({
    required this.rank,
    required this.teamNumber,
    required this.opr,
    required this.endgamePoints,
    required this.teleopPoints,
    required this.autoPoints,
    required this.notes,
  });

  factory TeamData.fromJson(Map<String, dynamic> json) {
    return TeamData(
      rank: json['rank'],
      teamNumber: json['team_number'],
      opr: json['OPR'],
      endgamePoints: json['endgame_points'],
      teleopPoints: json['teleop_points'],
      autoPoints: json['auto_points'],
      notes: json['notes'],
    );
  } 
}
class Event {
  final List<Team> teams;

  Event({required this.teams});

  // Add fromJson or other methods as needed
}

class Team {
  final int teamNumber;
  final int rank;
  final double opr;

  Team({
    required this.teamNumber,
    required this.rank,
    required this.opr,
  });

}
class Match {
  final String compLevel;
  final String key;
  final int matchNumber;
  final int setNumber;
  final List<String> blueTeams;
  final double blueScore;
  final double blueClimbing;
  final double blueAutoPoints;
  final double blueTeleopPoints;
  final double blueEndgamePoints;
  final double blueCoopertition;
  final double blueActualScore;
  final double blueNotes;
  final List<String> redTeams;
  final double redScore;
  final double redClimbing;
  final double redAutoPoints;
  final double redTeleopPoints;
  final double redEndgamePoints;
  final double redCoopertition;
  final double redNotes;
  final double redActualScore;
  final bool predicted;
  final int blueWinRp;
  final int blueEnsembleRp;
  final int blueMelodyRp;
  final int blueTotalRp;
  final int blueDisplayRp;
  final int redWinRp;
  final int redEnsembleRp;
  final int redMelodyRp;
  final int redTotalRp;
  final int redDisplayRp;

  Match({
    required this.compLevel,
    required this.key,
    required this.matchNumber,
    required this.setNumber,
    required this.blueTeams,
    required this.blueScore,
    required this.blueClimbing,
    required this.blueAutoPoints,
    required this.blueTeleopPoints,
    required this.blueEndgamePoints,
    required this.blueCoopertition,
    required this.blueActualScore,
    required this.blueNotes,
    required this.redTeams,
    required this.redScore,
    required this.redClimbing,
    required this.redAutoPoints,
    required this.redTeleopPoints,
    required this.redEndgamePoints,
    required this.redCoopertition,
    required this.redNotes,
    required this.redActualScore,
    required this.predicted,
    required this.blueWinRp,
    required this.blueEnsembleRp,
    required this.blueMelodyRp,
    required this.blueTotalRp,
    required this.blueDisplayRp,
    required this.redWinRp,
    required this.redEnsembleRp,
    required this.redMelodyRp,
    required this.redTotalRp,
    required this.redDisplayRp,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      compLevel: json['comp_level'],
      key: json['key'],
      matchNumber: json['match_number'],
      setNumber: json['set_number'],
      blueTeams: List<String>.from(json['blue_teams']),
      blueScore: json['blue_score'].toDouble(),
      blueClimbing: json['blue_climbing'].toDouble(),
      blueAutoPoints: json['blue_auto_points'].toDouble(),
      blueTeleopPoints: json['blue_teleop_points'].toDouble(),
      blueEndgamePoints: json['blue_endgame_points'].toDouble(),
      blueCoopertition: json['blue_coopertition'].toDouble(),
      blueActualScore: json['blue_actual_score'].toDouble(),
      blueNotes: json['blue_notes'].toDouble(),
      redTeams: List<String>.from(json['red_teams']),
      redScore: json['red_score'].toDouble(),
      redClimbing: json['red_climbing'].toDouble(),
      redAutoPoints: json['red_auto_points'].toDouble(),
      redTeleopPoints: json['red_teleop_points'].toDouble(),
      redEndgamePoints: json['red_endgame_points'].toDouble(),
      redCoopertition: json['red_coopertition'].toDouble(),
      redNotes: json['red_notes'].toDouble(),
      redActualScore: json['red_actual_score'].toDouble(),
      predicted: json['predicted'],
      blueWinRp: json['blue_win_rp'],
      blueEnsembleRp: json['blue_ensemble_rp'],
      blueMelodyRp: json['blue_melody_rp'],
      blueTotalRp: json['blue_total_rp'],
      blueDisplayRp: json['blue_display_rp'],
      redWinRp: json['red_win_rp'],
      redEnsembleRp: json['red_ensemble_rp'],
      redMelodyRp: json['red_melody_rp'],
      redTotalRp: json['red_total_rp'],
      redDisplayRp: json['red_display_rp'],
    );
  }
}
