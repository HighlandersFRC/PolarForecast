// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/picture_data.dart';
import 'package:scouting_app/widgets/auto_display_2026.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/match_scouting_2026.dart';
import '../models/pit_scouting_2026.dart';
import '../widgets/deaths_form.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../widgets/login_widget.dart';
import '../widgets/match_link.dart';
import '../widgets/polar_forecast_app_bar.dart';
import '../api_service.dart';
import '../models/tournament.dart';
import 'not_found_page.dart';

class TeamPage extends StatefulWidget {
  final Tournament tournament;
  final int teamNumber;
  const TeamPage(this.teamNumber, this.tournament);

  static Widget fromKeys(
      BuildContext context, String eventKey, String teamCode) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final tournaments = apiService.fetchTournaments();
    // print(eventKey);
    return FutureBuilder(
        future: tournaments,
        builder: (context, tournaments) {
          Tournament? tournament = null;
          try {
            for (final _tournament in tournaments.requireData) {
              if (_tournament.key == eventKey) {
                tournament = _tournament;
                break;
              }
            }
            if (tournament == null) {
              return NotFoundPage();
            }
            return TeamPage(int.parse(teamCode.substring(3)), tournament);
          } catch (error) {
            return NotFoundPage();
          }
        });
  }

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  int _currentTab = 0;
  bool isMobile() {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> tabs = [
      _OverviewTab(widget),
      _StatsTab(widget),
      _ScheduleTab(widget),
      _PicturesTab(widget),
      _MatchScoutingTab(widget),
      _PitScoutingTab(widget),
      _AutosTab(widget),
      _DeathsTab(widget),
      _TBATab(widget)
    ];
    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: '${widget.teamNumber} - ${widget.tournament.display}',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (newTabIdx) => setState(() => _currentTab = newTabIdx),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.group, color: theme.primaryColor),
              label: 'Overview'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storage_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.storage, color: theme.primaryColor),
              label: 'Stats'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.event_note, color: theme.primaryColor),
              label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.photo, color: theme.primaryColor),
              label: 'Pictures'),
          BottomNavigationBarItem(
              icon: Icon(Icons.visibility_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.visibility, color: theme.primaryColor),
              label: 'Match Scouting'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.assignment, color: theme.primaryColor),
              label: 'Pit Scouting'),
          BottomNavigationBarItem(
              icon: Icon(Icons.precision_manufacturing_outlined,
                  color: theme.primaryColor),
              activeIcon: Icon(Icons.precision_manufacturing,
                  color: theme.primaryColor),
              label: 'Autos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.privacy_tip_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.privacy_tip, color: theme.primaryColor),
              label: 'Deaths'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.shield, color: theme.primaryColor),
              label: 'TBA')
        ],
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(color: Colors.white, fontFamily: 'Font'),
        unselectedLabelStyle:
            TextStyle(color: Colors.white, fontFamily: 'Font'),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
      ),
      body: tabs[_currentTab],
    );
  }
}

class _TBATab extends StatefulWidget {
  final TeamPage widget;
  const _TBATab(this.widget);

  @override
  _TBATabState createState() => _TBATabState();
}

class _TBATabState extends State<_TBATab> {
  late final String tbaUrl;

  @override
  void initState() {
    super.initState();
    tbaUrl = 'https://www.thebluealliance.com/team/${widget.widget.teamNumber}';
  }

  Future<void> _openTBA() async {
    final uri = Uri.parse(tbaUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $tbaUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.open_in_new_rounded,
                  size: 48,
                  color: Colors.blue,
                ),

                const SizedBox(height: 16),

                Text(
                  "View Team on The Blue Alliance",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Font',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'frc${widget.widget.teamNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Font',
                  ),
                ),

                const SizedBox(height: 24),

                // 🔥 Clean CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openTBA,
                    icon: const Icon(Icons.link),
                    label: const Text("Open Team"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Font',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // subtle link text
                TextButton(
                  onPressed: _openTBA,
                  child: Text(
                    tbaUrl,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: 'Font',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatefulWidget {
  final TeamPage widget;

  const _OverviewTab(this.widget);

  @override
  _OverviewTabState createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  Map<String, dynamic> stats = {};
  String nickname = '';
  List<PictureData> pictures = [];
  PitScouting2026? pitScouting;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    // Fetch stats
    try {
      final fetchedStats = await apiService.fetchTeamStats(
        int.parse(widget.widget.tournament.page.split('/')[3]),
        widget.widget.tournament.page.split('/')[4],
        'frc${widget.widget.teamNumber}',
      );
      stats = fetchedStats;
    } catch (e) {
      print('Error fetching stats: $e');
    }

    // Fetch nickname
    try {
      nickname =
          await apiService.fetchTeamNicknames('frc${widget.widget.teamNumber}');
    } catch (e) {
      print('Error fetching nickname: $e');
    }

    // Fetch pictures
    try {
      pictures = await apiService.fetchTeamImages(
        int.parse(widget.widget.tournament.page.split('/')[3]),
        widget.widget.tournament.page.split('/')[4],
        'frc${widget.widget.teamNumber}',
      );
    } catch (e) {
      print('Error fetching pictures: $e');
    }

    // Fetch pit scouting
    try {
      pitScouting = await apiService.fetchTeamPitScouting(
        widget.widget.tournament.page.split('/')[3],
        widget.widget.tournament.page.split('/')[4],
        'frc${widget.widget.teamNumber}',
      );
    } catch (e) {
      print('Error fetching pit scouting: $e');
      pitScouting = null;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final fullRobotPics =
        pictures.where((pic) => pic.image_type == 'full_robot');
    final fullRobotPic = fullRobotPics.isNotEmpty
        ? fullRobotPics.first
        : (pictures.isNotEmpty ? pictures[0] : null);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            /// ---------------- TEAM NAME ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Team ${widget.widget.teamNumber} | ${nickname}",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (fullRobotPic != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.network(
                  fullRobotPic.link, // better for phones
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            /// ---------------- STATS ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildQuickStat(
                    "Rank",
                    stats['rank']?.toString() ?? "-",
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildQuickStat(
                    "OPR",
                    (stats['OPR'] is num)
                        ? (stats['OPR'] as num).toStringAsFixed(1)
                        : "-",
                    Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ---------------- PIT SCOUTING ----------------
            if (pitScouting != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      "Pit Scouting Info",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLargeDataCard(
                  title: "Physical Capabilities",
                  context: context,
                  children: [
                    _buildLargeDetailRow(
                      "Can Go Under Trench",
                      pitScouting!.data.go_under_trench ? "YES" : "NO",
                      pitScouting!.data.go_under_trench
                          ? Colors.green
                          : Colors.red,
                    ),
                    _buildLargeDetailRow(
                      "Can Climb",
                      pitScouting!.data.can_climb ? "YES" : "NO",
                      pitScouting!.data.can_climb ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLargeDataCard(
                  title: "Mechanism Specs",
                  context: context,
                  children: [
                    _buildLargeDetailRow(
                      "Hopper Capacity",
                      "${pitScouting!.data.hopper_capacity}",
                      Colors.blueGrey,
                    ),
                    _buildLargeDetailRow(
                      "Fuel Per Second",
                      pitScouting!.data.bps.toStringAsFixed(2),
                      Colors.blueGrey,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

// --- NEW SCALED HELPERS ---
  Widget _buildQuickStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeDataCard({
    required String title,
    required List<Widget> children,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLargeDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatefulWidget {
  final TeamPage widget;

  const _StatsTab(this.widget);

  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  Map<String, dynamic> stats = {};

  bool isLoading = true;

  // Only show these fields in the UI
  final Map<String, String> fieldLabels = {
    'rank': 'Rank',
    'match_count': 'Match Count',
    'OPR': 'OPR',
    'OPRRank': 'OPR Rank',
    'endgame_points': 'Endgame Points',
    'teleop_points': 'Teleop Points',
    'auto_points': 'Auto Points',
    'climbing_points': 'Climbing Points',
    'auto_fuel_cycles': 'Auto Fuel Scored',
    'teleop_fuel_cycles': 'Teleop Fuel Scored',
    'total_fuel_cycles': 'Total Fuel Scored',
    'foul_points': 'Foul Points',
    'simulated_rp': 'Simulated RP',
    'simulated_rank': 'Simulated Rank',
  };

  final Map<String, List<String>> groupedFields = {
    'Rankings': [
      'rank',
      'simulated_rank',
      'match_count',
      'OPR',
      'OPRRank',
      'simulated_rp',
    ],
    'Scoring Breakdown': [
      'auto_points',
      'teleop_points',
      'endgame_points',
      'climbing_points',
      'foul_points',
    ],
    'Fuel Scored': [
      'auto_fuel_cycles',
      'teleop_fuel_cycles',
      'total_fuel_cycles',
    ],
  };

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  void fetchStats() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final fetchedStats = await apiService.fetchTeamStats(
        int.parse(widget.widget.tournament.page.split('/')[3]),
        widget.widget.tournament.page.split('/')[4],
        'frc${widget.widget.teamNumber}',
      );
      if (mounted) {
        setState(() {
          stats = fetchedStats;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String formatValue(dynamic value) {
    if (value is int || value is double) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: isLoading
          ? CircularProgressIndicator(color: Colors.blue)
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.widget.tournament.display} - Team ${widget.widget.teamNumber} Stats',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: groupedFields.entries.map((group) {
                        final groupTitle = group.key;
                        final keys = group.value
                            .where((key) => stats.containsKey(key))
                            .toList();

                        if (keys.isEmpty) return SizedBox();

                        return Card(
                          elevation: 6,
                          margin: const EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  groupTitle,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...keys.map((key) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          fieldLabels[key] ?? key,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          formatValue(stats[key]),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ScheduleTab extends StatefulWidget {
  final TeamPage widget;

  const _ScheduleTab(this.widget);

  @override
  _ScheduleTabState createState() => _ScheduleTabState();
}

class _ScheduleStatusSource extends DataGridSource {
  final BuildContext context;
  final List<DataGridRow> rows;
  final Tournament tournament;
  final List<dynamic> statuses;
  final int teamNumber;
  _ScheduleStatusSource(BuildContext this.context, this.rows, this.tournament,
      this.statuses, int this.teamNumber);

  String getColor(Map<String, dynamic> status, int teamNumber) {
    List blueTeams = status['blue_teams'];
    List redTeams = status['red_teams'];

    int blueTeam1 = int.parse(blueTeams[0].split('c')[1]);
    int blueTeam2 = int.parse(blueTeams[1].split('c')[1]);
    int blueTeam3 = int.parse(blueTeams[2].split('c')[1]);
    int redTeam1 = int.parse(redTeams[0].split('c')[1]);
    int redTeam2 = int.parse(redTeams[1].split('c')[1]);
    int redTeam3 = int.parse(redTeams[2].split('c')[1]);

    if (teamNumber == blueTeam1 ||
        teamNumber == blueTeam2 ||
        teamNumber == blueTeam3) {
      return 'Blue';
    } else if (teamNumber == redTeam1 ||
        teamNumber == redTeam2 ||
        teamNumber == redTeam3) {
      return 'Red';
    } else {
      // print('Team Not In Match');
      return 'N/A';
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    List<DataGridCell> cells = row.getCells();
    List<Widget> returnCells = [];
    Map<String, dynamic> matchStatus = {};

    for (Map<String, dynamic> status in statuses) {
      if (status['comp_level'] == 'qm') {
        if ('Quals ' + status['match_number'].toString() == cells[0].value) {
          matchStatus = status;
          break;
        }
      } /**/ else if (status['comp_level'] == 'sf') {
        if ('Semi-Finals ' + status['set_number'].toString() ==
            cells[0].value) {
          matchStatus = status;
          break;
        }
      } /**/ else if (status['comp_level'] == 'f') {
        if ('Finals ' + status['match_number'].toString() == cells[0].value) {
          matchStatus = status;
          break;
        }
      } /**/
    }
    for (DataGridCell cell in cells) {
      int rowNumber = rows.indexOf(row);

      bool even = rowNumber % 2 == 0;
      final color = even
          ? Theme.of(context).primaryColor.withOpacity(0.3)
          : Colors.black.withOpacity(0);
      if (cell.columnName == 'key') {
        String match_key = '';

        if (matchStatus.isNotEmpty) {
          if (matchStatus['comp_level'] == 'qm') {
            match_key = '${tournament.key}_qm${matchStatus['match_number']}';
          } else if (matchStatus['comp_level'] == 'sf') {
            match_key =
                '${tournament.key}_sf${matchStatus['set_number']}m${matchStatus['match_number']}';
          } else if (matchStatus['comp_level'] == 'f') {
            match_key = '${tournament.key}_f1m${matchStatus['match_number']}';
          }
        }
        returnCells.add(Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.center,
            color: color,
            child: MatchLink(cell.value, match_key, tournament)));
      } else if (cell.columnName == 'team_rp')
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: getColor(matchStatus, teamNumber) == 'Red' &&
                  matchStatus['comp_level'] == 'qm'
              ? Color.lerp(Colors.red, Colors.green,
                      matchStatus['red_display_rp'] / 4)!
                  .withOpacity(0.6)
              : getColor(matchStatus, teamNumber) == 'Blue' &&
                      matchStatus['comp_level'] == 'qm'
                  ? Color.lerp(Colors.red, Colors.green,
                          matchStatus['blue_display_rp'] / 4)!
                      .withOpacity(0.6)
                  : Colors.grey.withOpacity(0.6),
          child: Text(
              textScaler: TextScaler.linear(1.25),
              cell.value.toString(),
              style: TextStyle(fontFamily: 'Font')),
        ));
      else if (cell.columnName == 'color')
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: cell.value == 'Red'
              ? const Color.fromARGB(255, 140, 10, 0)
              : cell.value == 'Blue'
                  ? const Color.fromARGB(255, 0, 100, 150)
                  : const Color.fromARGB(255, 125, 0, 150),
          child: Text(
              textScaler: TextScaler.linear(1.25),
              cell.value.toString(),
              style: TextStyle(fontFamily: 'Font')),
        ));
      else if (cell.columnName == 'team_score')
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color:
              // getColor(matchStatus, teamNumber) == 'Blue' &&
              //         !matchStatus['predicted'] &&
              //         matchStatus['blue_actual_score'] -
              //                 matchStatus['red_actual_score'] <=
              //             0
              //     ? Color.lerp(
              //             Colors.red,
              //             Colors.green,
              //             exp((matchStatus['blue_actual_score'] -
              //                         matchStatus[
              //                             'red_actual_score']) /
              //                     20 +
              //                 log(0.5) / log(e)))!
              //         .withOpacity(0.6)
              //     : color
              getColor(matchStatus, teamNumber) == 'Blue' &&
                      matchStatus['predicted']
                  ? matchStatus['blue_score'] > matchStatus['red_score']
                      ? Color.lerp(Colors.green, Colors.red, exp((matchStatus['blue_score'] - matchStatus['red_score']) / (-20) + log(0.5) / log(e)))!
                          .withOpacity(0.6)
                      : Color.lerp(Colors.red, Colors.green, exp((matchStatus['blue_score'] - matchStatus['red_score']) / 20 + log(0.5) / log(e)))!
                          .withOpacity(0.6)
                  : getColor(matchStatus, teamNumber) == 'Blue' &&
                          !matchStatus['predicted']
                      ? matchStatus['blue_actual_score'] >
                              matchStatus['red_actual_score']
                          ? Colors.green.withOpacity(0.6)
                          : matchStatus['blue_actual_score'] <
                                  matchStatus['red_actual_score']
                              ? Colors.red.withOpacity(0.6)
                              : Color.lerp(Colors.red, Colors.green, 0.5)!
                                  .withOpacity(0.6)
                      : getColor(matchStatus, teamNumber) == 'Red' &&
                              matchStatus['predicted']
                          ? matchStatus['blue_score'] < matchStatus['red_score']
                              ? Color.lerp(Colors.green, Colors.red, exp((matchStatus['blue_score'] - matchStatus['red_score']) / 20 + log(0.5) / log(e)))!
                                  .withOpacity(0.6)
                              : Color.lerp(
                                      Colors.red,
                                      Colors.green,
                                      exp((matchStatus['blue_score'] -
                                                  matchStatus['red_score']) /
                                              (-20) +
                                          log(0.5) / log(e)))!
                                  .withOpacity(0.6)
                          : getColor(matchStatus, teamNumber) == 'Red' &&
                                  !matchStatus['predicted']
                              ? matchStatus['blue_actual_score'] < matchStatus['red_actual_score']
                                  ? Colors.green.withOpacity(0.6)
                                  : matchStatus['blue_actual_score'] > matchStatus['red_actual_score']
                                      ? Colors.red.withOpacity(0.6)
                                      : Color.lerp(Colors.red, Colors.green, 0.5)!.withOpacity(0.6)
                              : Color.lerp(Colors.red, Colors.green, 0.5)!.withOpacity(0.6),
          child: Text(
              textScaler: TextScaler.linear(1.25),
              cell.value.toString(),
              style: TextStyle(fontFamily: 'Font')),
        ));
      else if (cell.columnName == 'opponent_score')
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: getColor(matchStatus, teamNumber) == 'Blue' &&
                  matchStatus['predicted']
              ? matchStatus['blue_score'] < matchStatus['red_score']
                  ? Color.lerp(Colors.green, Colors.red, exp((matchStatus['blue_score'] - matchStatus['red_score']) / (20) + log(0.5) / log(e)))!
                      .withOpacity(0.6)
                  : Color.lerp(Colors.red, Colors.green, exp((matchStatus['blue_score'] - matchStatus['red_score']) / (-20) + log(0.5) / log(e)))!
                      .withOpacity(0.6)
              : getColor(matchStatus, teamNumber) == 'Blue' &&
                      !matchStatus['predicted']
                  ? matchStatus['blue_actual_score'] <
                          matchStatus['red_actual_score']
                      ? Colors.green.withOpacity(0.6)
                      : matchStatus['blue_actual_score'] >
                              matchStatus['red_actual_score']
                          ? Colors.red.withOpacity(0.6)
                          : Color.lerp(Colors.red, Colors.green, 0.5)!
                              .withOpacity(0.6)
                  : getColor(matchStatus, teamNumber) == 'Red' &&
                          matchStatus['predicted']
                      ? matchStatus['blue_score'] > matchStatus['red_score']
                          ? Color.lerp(Colors.green, Colors.red, exp((matchStatus['blue_score'] - matchStatus['red_score']) / (-20) + log(0.5) / log(e)))!
                              .withOpacity(0.6)
                          : Color.lerp(Colors.red, Colors.green, exp((matchStatus['blue_score'] - matchStatus['red_score']) / (20) + log(0.5) / log(e)))!
                              .withOpacity(0.6)
                      : getColor(matchStatus, teamNumber) == 'Red' &&
                              !matchStatus['predicted']
                          ? matchStatus['blue_actual_score'] >
                                  matchStatus['red_actual_score']
                              ? Colors.green.withOpacity(0.6)
                              : matchStatus['blue_actual_score'] <
                                      matchStatus['red_actual_score']
                                  ? Colors.red.withOpacity(0.6)
                                  : Color.lerp(Colors.red, Colors.green, 0.5)!
                                      .withOpacity(0.6)
                          : Color.lerp(Colors.red, Colors.green, 0.5)!
                              .withOpacity(0.6),
          child: Text(
              textScaler: TextScaler.linear(1.25),
              cell.value.toString(),
              style: TextStyle(fontFamily: 'Font')),
        ));
      else
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: color,
          child: Text(
              textScaler: TextScaler.linear(1.25),
              cell.value.toString(),
              style: TextStyle(fontFamily: 'Font')),
        ));
    }
    return DataGridRowAdapter(
      cells: returnCells,
    );
  }
}

class _ScheduleTabState extends State<_ScheduleTab> {
  List<GridColumn> dataColumns = [];
  List<DataGridRow> dataRows = [];
  List<dynamic> statuses = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    updateGrid();
    fetchData().then((_) => updateGrid());
  }

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final fetchedStatus = await apiService.fetchQualMatches(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4]);
      if (mounted) {
        setState(() {
          statuses = fetchedStatus;
          isLoading = false;
        });
      }
    } catch (e) {
      // print('Error fetching data: $e');
      throw (e);
    }
  }

  String getColor(Map<String, dynamic> status, int teamNumber) {
    List blueTeams = status['blue_teams'];
    List redTeams = status['red_teams'];

    int blueTeam1 = int.parse(blueTeams[0].split('c')[1]);
    int blueTeam2 = int.parse(blueTeams[1].split('c')[1]);
    int blueTeam3 = int.parse(blueTeams[2].split('c')[1]);
    int redTeam1 = int.parse(redTeams[0].split('c')[1]);
    int redTeam2 = int.parse(redTeams[1].split('c')[1]);
    int redTeam3 = int.parse(redTeams[2].split('c')[1]);

    if (teamNumber == blueTeam1 ||
        teamNumber == blueTeam2 ||
        teamNumber == blueTeam3) {
      return 'Blue';
    } else if (teamNumber == redTeam1 ||
        teamNumber == redTeam2 ||
        teamNumber == redTeam3) {
      return 'Red';
    } else {
      // print('Team Not In Match');
      return 'N/A';
    }
  }

  void updateGrid() {
    dataColumns = [
      GridColumn(
          columnName: 'key',
          label: Container(
              alignment: Alignment.center,
              child: Text('Match',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.25),
                  style: TextStyle(fontFamily: 'Font')))),
      GridColumn(
          columnName: 'result_type',
          label: Container(
              alignment: Alignment.center,
              child: Text('Type',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.25),
                  style: TextStyle(fontFamily: 'Font')))),
      GridColumn(
          columnName: 'color',
          label: Container(
              alignment: Alignment.center,
              child: Text('Alliance',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.25),
                  style: TextStyle(fontFamily: 'Font')))),
      GridColumn(
          columnName: 'team_score',
          label: Container(
              alignment: Alignment.center,
              child: Text('Team Points',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.25),
                  style: TextStyle(fontFamily: 'Font')))),
      GridColumn(
          columnName: 'opponent_score',
          label: Container(
              alignment: Alignment.center,
              child: Text('Opponent Points',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.25),
                  style: TextStyle(fontFamily: 'Font')))),
      GridColumn(
          columnName: 'team_rp',
          label: Container(
              alignment: Alignment.center,
              child: Text('Ranking Points',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.25),
                  style: TextStyle(fontFamily: 'Font')))),
    ];

    statuses.sort((a, b) {
      return a['match_number'] - b['match_number'];
    });

    statuses.sort((a, b) {
      if (a['set_number'] - b['set_number'] == 0) {
        return a['match_number'] - b['match_number'];
      } else {
        return a['set_number'] - b['set_number'];
      }
    });

    statuses.sort((a, b) {
      if (b['comp_level'].length - a['comp_level'].length != 0) {
        return b['comp_level'].length - a['comp_level'].length;
      } else {
        // print(a['comp_level'] + '    ' + b['comp_level']);

        if (a['comp_level'] != b['comp_level']) {
          // print('yo');
          return b['comp_level'] == 'sf' ? -1 : 1;
        }
        if (a['set_number'] - b['set_number'] == 0) {
          return a['match_number'] - b['match_number'];
        } else {
          return a['set_number'] - b['set_number'];
        }
      }
    });

    dataRows = [
      for (Map<String, dynamic> status in statuses)
        if (getColor(status, widget.widget.teamNumber) != 'N/A')
          DataGridRow(cells: [
            DataGridCell(
                columnName: 'key',
                value: status['comp_level'] == 'qm'
                    ? 'Quals ' + status['match_number'].toString()
                    : status['comp_level'] == 'sf'
                        ? 'Semi-Finals ' + status['set_number'].toString()
                        : status['comp_level'] == 'f'
                            ? 'Finals ' + status['match_number'].toString()
                            : 'idk'),
            DataGridCell(
                columnName: 'result_type',
                value: status['predicted'] ? 'Predicted' : 'Result'),
            DataGridCell(
                columnName: 'color',
                value: getColor(status, widget.widget.teamNumber)),
            DataGridCell(
                columnName: 'team_score',
                value: status['predicted'] &&
                        getColor(status, widget.widget.teamNumber) == 'Blue'
                    ? status['blue_score'].toStringAsFixed(0)
                    : status['predicted'] &&
                            getColor(status, widget.widget.teamNumber) == 'Red'
                        ? status['red_score'].toStringAsFixed(0)
                        : getColor(status, widget.widget.teamNumber) == 'Blue'
                            ? status['blue_actual_score']
                            : getColor(status, widget.widget.teamNumber) ==
                                    'Red'
                                ? status['red_actual_score']
                                : 'Error: team not in match (line 458)'),
            DataGridCell(
                columnName: 'opponent_score',
                value: status['predicted'] &&
                        getColor(status, widget.widget.teamNumber) == 'Red'
                    ? status['blue_score'].toStringAsFixed(0)
                    : status['predicted'] &&
                            getColor(status, widget.widget.teamNumber) == 'Blue'
                        ? status['red_score'].toStringAsFixed(0)
                        : getColor(status, widget.widget.teamNumber) == 'Red'
                            ? status['blue_actual_score']
                            : getColor(status, widget.widget.teamNumber) ==
                                    'Blue'
                                ? status['red_actual_score']
                                : 'Error: team not in match (line 458)'),
            DataGridCell(
                columnName: 'team_rp',
                value: getColor(status, widget.widget.teamNumber) == 'Blue' &&
                        status['comp_level'] == 'qm'
                    ? status['blue_display_rp']
                    : getColor(status, widget.widget.teamNumber) == 'Red' &&
                            status['comp_level'] == 'qm'
                        ? status['red_display_rp']
                        : 'N/A'),
          ])
    ];
  }

  @override
  Widget build(BuildContext context) {
    const columnMinWidth = 175.0;
    bool isWide = MediaQuery.of(context).size.width >=
        dataColumns.length * columnMinWidth;
    return Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.blue)
            : LayoutBuilder(
                builder: (context, constraints) => Container(
                    alignment: Alignment.center,
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: InteractiveViewer(
                      scaleEnabled: false,
                      clipBehavior: Clip.hardEdge,
                      child: SfDataGrid(
                        columns: dataColumns,
                        defaultColumnWidth: columnMinWidth,
                        columnWidthMode: isWide
                            ? ColumnWidthMode.fill
                            : ColumnWidthMode.none,
                        frozenColumnsCount: 1,
                        source: _ScheduleStatusSource(
                            context,
                            dataRows,
                            widget.widget.tournament,
                            statuses,
                            widget.widget.teamNumber),
                      ),
                    ))));
  }
}

class _PicturesTab extends StatefulWidget {
  final TeamPage widget;

  const _PicturesTab(this.widget);

  @override
  _PicturesTabState createState() => _PicturesTabState();
}

class _PicturesTabState extends State<_PicturesTab> {
  List<PictureData> images = [];
  bool isLoading = true;
  String? token;
  String selectedType = 'full_robot';

  final List<String> imageTypes = [
    'full_robot',
    'wires',
    'shooter',
    'intake',
    'feeder',
  ];

  String formatType(String type) {
    switch (type) {
      case 'full_robot':
        return 'Full Robot';
      case 'wires':
        return 'Wiring';
      case 'shooter':
        return 'Shooter';
      case 'intake':
        return 'Intake';
      case 'feeder':
        return 'Feeder';
      default:
        return type;
    }
  }

  List<PictureData> get filteredImages =>
      images.where((img) => img.image_type == selectedType).toList();

  void fetchPictures() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    token = await apiService.token;
    if (token != null) {
      try {
        final parts = widget.widget.tournament.page.split('/');
        final fetched = await apiService.fetchTeamImages(
          int.parse(parts[3]),
          parts[4],
          'frc${widget.widget.teamNumber}',
        );
        if (mounted)
          setState(() {
            images = fetched;
            isLoading = false;
          });
        else {
          images = fetched;
          isLoading = false;
        }
      } catch (e) {
        debugPrint('Error fetching pictures: $e');
      }
    } else {
      if (mounted)
        setState(() => isLoading = false);
      else
        isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPictures();
  }

  // ── Full-screen zoomable viewer ──────────────────────────────────────────
  void _openImageViewer(BuildContext context, PictureData image) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Zoomable image ───────────────────────────────────────────
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 5.0,
                    child: Image.network(image.link),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Footer card ──────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        image.scout_info.first_name != null
                            ? 'Uploaded by ${image.scout_info.first_name}'
                            : 'Scout from team ${image.scout_info.team_number}',
                        style:
                            const TextStyle(fontFamily: 'Font', fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (image.permissions.contains('delete'))
                      TextButton.icon(
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete',
                            style: TextStyle(fontFamily: 'Font')),
                        onPressed: () {
                          final api =
                              Provider.of<ApiService>(ctx, listen: false);
                          Navigator.of(ctx).pop();
                          api.delete_image(image).then((_) {
                            setState(() => images.remove(image));
                          });
                        },
                      ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close',
                          style: TextStyle(fontFamily: 'Font')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    if (token == null) {
      return LoginWidget(
        redirect_path:
            '/event/${widget.widget.tournament.key}/team/frc${widget.widget.teamNumber}',
      );
    }
    if (images.isEmpty) {
      return const Center(
        child: Text('No Images', style: TextStyle(fontFamily: 'Font')),
      );
    }

    return Column(
      children: [
        // ── Type selector ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: imageTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(formatType(type),
                    style: const TextStyle(fontFamily: 'Font')),
              );
            }).toList(),
            onChanged: (v) => setState(() => selectedType = v!),
          ),
        ),

        // ── Grid ─────────────────────────────────────────────────────────
        Expanded(
          child: filteredImages.isEmpty
              ? Center(
                  child: Text(
                    'No ${formatType(selectedType)} images',
                    style: const TextStyle(fontFamily: 'Font'),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth > 600 ? 4 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredImages.length,
                      itemBuilder: (context, index) {
                        final image = filteredImages[index];
                        return GestureDetector(
                          onTap: () => _openImageViewer(context, image),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                image.link,
                                fit: BoxFit.cover,
                                // Lightweight loading placeholder
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                        ? child
                                        : Container(
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image_outlined,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MatchScoutingTab extends StatefulWidget {
  final TeamPage widget;

  const _MatchScoutingTab(this.widget);

  @override
  _MatchScoutingTabState createState() => _MatchScoutingTabState();
}

// Assuming you have these imports based on your code
// import 'your_models.dart';
// import 'api_service.dart';

class _MatchScoutingTabState extends State<_MatchScoutingTab> {
  List<MatchScouting2026> scouting = [];
  late ScrollController scrollController;
  String? role, token;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    fetchData().then((_) => updateGrid());
  }

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    token = await apiService.token;
    if (token != null) {
      final fetchedStats = await apiService.fetchTeamMatchScouting(
        int.parse(widget.widget.tournament.page.split('/')[3]),
        widget.widget.tournament.page.split('/')[4],
        'frc${widget.widget.teamNumber}',
      );

      final groups = await apiService.get_user_groups_detailed();
      if (groups.isNotEmpty) {
        final (_, _role) = await apiService.get_group(groups[0].name);
        if (mounted) {
          setState(() {
            role = _role;
            scouting = fetchedStats;
          });
        }
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  // Kept for compatibility – triggers a rebuild (no longer builds grid rows)
  void updateGrid() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await fetchData();
    updateGrid();
  }

  void _deleteEntry(int index) {
    ApiService api = Provider.of<ApiService>(context, listen: false);

    api.delete_match_scouting(scouting[index]).then((_) {
      setState(() {
        scouting.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully Deleted')),
      );
    }).onError((e, trace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (token == null) {
      return LoginWidget(
        redirect_path:
            '/event/${widget.widget.tournament.key}/team/frc${widget.widget.teamNumber}',
      );
    }

    if (scouting.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Scouting Entries Yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: scouting.length,
        itemBuilder: (context, index) {
          final data = scouting[index];
          final backgroundColor = index % 2 == 0
              ? Colors.blueGrey.shade900
              : Colors.blueGrey.shade800;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ScoutingCard(
              data: data,
              backgroundColor: backgroundColor,
              role: role,
              onDelete: () => _confirmDelete(context, index),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content:
            const Text('Are you sure you want to delete this scouting entry?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteEntry(index);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Extracted card widget (identical to previous version)
class _ScoutingCard extends StatelessWidget {
  final MatchScouting2026 data;
  final Color backgroundColor;
  final String? role;
  final VoidCallback onDelete;

  const _ScoutingCard({
    required this.data,
    required this.backgroundColor,
    required this.role,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue[800],
                      child: Text(
                        data.scout_info.first_name?[0] ?? 'S',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.scout_info.first_name ??
                              'Scout ${data.scout_info.team_number}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Match ${data.match_number}',
                          style:
                              TextStyle(color: Colors.blue[200], fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                if (role == 'admin' || role == 'owner')
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats sections with icons
            _buildSection(
              title: 'Auto',
              icon: Icons.smart_toy_outlined,
              chips: [
                // _StatChip(
                //     label: 'Fuel',
                //     value: data.data.auto_scoring.fuel_cycles.toString()),
                _StatChip(
                    label: 'Fuel Scored in Auto',
                    value: data.data.auto_scoring.fuel_scored.toString()),
              ],
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: 'Teleop',
              icon: Icons.videogame_asset_outlined,
              chips: [
                // _StatChip(
                //     label: 'Fuel',
                //     value: data.data.teleop_scoring.fuel_cycles.toString()),
                _StatChip(
                    label: 'Fuel Scored in Teleop',
                    value: data.data.teleop_scoring.fuel_scored.toString()),
              ],
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: 'Misc',
              icon: Icons.widgets_outlined,
              chips: [
                _StatChip(
                  label: 'Died',
                  value: data.data.miscellaneous.died ? 'Yes' : 'No',
                  color: data.data.miscellaneous.died ? Colors.orange : null,
                ),
                _StatChip(
                  label: 'Defense',
                  value: data.data.miscellaneous.defense ? 'Yes' : 'No',
                  color: data.data.miscellaneous.defense ? Colors.purple : null,
                ),
              ],
            ),

            // Comments (if any)
            if (data.data.miscellaneous.comments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Comments: ${data.data.miscellaneous.comments}',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Updated _buildSection with an icon parameter
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> chips,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.blue[200]),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[200],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: chips,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatChip({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color ?? Colors.blueGrey[700],
      label: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 13, color: Colors.white),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class DeleteButton extends StatefulWidget {
  final MatchScouting2026 data;
  final void Function() onDelete;
  DeleteButton({Key? key, required this.data, required this.onDelete})
      : super(key: key);

  @override
  _DeleteButtonState createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  bool activated = false;
  String text = '';
  String password = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        ApiService api = Provider.of<ApiService>(context, listen: false);
        api.delete_match_scouting(widget.data).then(
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Successfully Deleted',
                    style: TextStyle(fontFamily: 'Font'))));
            widget.onDelete();
          },
        ).onError((e, trace) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(e.toString(), style: TextStyle(fontFamily: 'Font'))));
        });
      },
      icon: Icon(Icons.delete_forever),
      color: Colors.red,
    );
  }
}

class _PitScoutingTab extends StatefulWidget {
  final TeamPage widget;

  const _PitScoutingTab(this.widget);

  @override
  _PitScoutingTabState createState() => _PitScoutingTabState();
}

class _PitScoutingTabState extends State<_PitScoutingTab> {
  String nickname = '';
  bool loading = true;
  PitScouting2026? pitScouting;

  @override
  void initState() {
    super.initState();
    fetchPitScoutingData();
  }

  void fetchPitScoutingData() async {
    final api = Provider.of<ApiService>(context, listen: false);
    try {
      final data = await api.fetchTeamPitScouting(
        widget.widget.tournament.page.split('/')[3],
        widget.widget.tournament.page.split('/')[4],
        'frc${widget.widget.teamNumber}',
      );

      setState(() {
        pitScouting = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Pit scouting error: $e");
    }

    try {
      nickname = await api.fetchTeamNicknames('frc${widget.widget.teamNumber}');
    } catch (e) {
      print('Error fetching nickname: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pitScouting == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            const Text("No Pit Scouting Data Available",
                style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    final data = pitScouting!.data;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              _buildSection(
                title: "Drivetrain & Movement",
                icon: Icons.settings_input_component,
                theme: theme,
                children: [
                  _buildDetailRow("Drive Train", data.drive_train, Colors.blue),
                  _buildDetailRow("Robot Height", "${data.robot_height}\"",
                      Colors.blueGrey),
                  _buildBoolRow("Can Go Under Trench", data.go_under_trench),
                ],
              ),
              _buildSection(
                title: "Shooting System",
                icon: Icons.gps_fixed,
                theme: theme,
                children: [
                  _buildDetailRow("Type", data.type_of_shooter, Colors.orange),
                  _buildDetailRow(
                      "BPS", data.bps.toStringAsFixed(2), Colors.orange),
                  _buildBoolRow("Fixed Shooting", data.fixedShooting),
                ],
              ),
              _buildSection(
                title: "Intake & Handling",
                icon: Icons.download,
                theme: theme,
                children: [
                  _buildBoolRow("Near Tower", data.nearTower),
                  _buildBoolRow("Near Hub", data.nearHub),
                  _buildDetailRow("Hopper Capacity",
                      data.hopper_capacity.toString(), Colors.blueGrey),
                ],
              ),
              _buildSection(
                title: "Climbing",
                icon: Icons.upload,
                theme: theme,
                children: [
                  _buildBoolRow("Can Climb", data.can_climb),
                  _buildBoolRow("Auto Climb", data.can_climb_in_autonomous),
                  const Divider(height: 24),
                  const Text("Pole Availability",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip("Left", data.left_pole_climb),
                      _buildChip("Straddle L", data.straddling_pole_climb_left),
                      _buildChip("Center", data.center_pole_climb),
                      _buildChip(
                          "Straddle R", data.straddling_pole_climb_right),
                      _buildChip("Right", data.right_pole_climb),
                    ],
                  ),
                ],
              ),
              _buildSection(
                title: "Strategy & Info",
                icon: Icons.lightbulb,
                theme: theme,
                children: [
                  _buildDetailRow(
                      "Main Strategy", data.main_strategy, Colors.purple),
                  _buildDetailRow(
                      "Favorite Color", data.favorite_color, Colors.pink),
                  _buildDetailRow(
                      "Experience",
                      "${data.driver_experience_events} Events",
                      Colors.blueGrey),
                  _buildDetailRow("Comments", data.comments, Colors.grey)
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PIT SCOUTING",
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.primaryColor, letterSpacing: 1.2),
        ),
        Text(
          "Team ${widget.widget.teamNumber}",
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSection(
      {required String title,
      required IconData icon,
      required List<Widget> children,
      required ThemeData theme}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoolRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red.withOpacity(0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? Colors.green : Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.green : Colors.grey,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AutosTab extends StatefulWidget {
  final TeamPage widget;

  const _AutosTab(this.widget);

  @override
  _AutosTabState createState() => _AutosTabState();
}

class _AutosTabState extends State<_AutosTab> {
  List<MatchScouting2026> scouting = [];
  int AUTOS_PER_PAGE = 15;
  int currentPage = 0;
  bool isLoading = true;
  String? token;

  @override
  initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    this.token = await apiService.token;
    if (token == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      isLoading = false;
      return;
    }
    final fetchedStats = (await apiService.fetchTeamMatchScouting(
      int.parse(widget.widget.tournament.page.split('/')[3]),
      widget.widget.tournament.page.split('/')[4],
      'frc${widget.widget.teamNumber}',
    ));
    if (mounted) {
      setState(() {
        scouting = fetchedStats.where((data) {
          return data.team_number == widget.widget.teamNumber;
        }).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int numPages = (scouting.length / AUTOS_PER_PAGE).ceil();
    // make sure we don't map it to a non-existent page
    if (currentPage >= numPages) {
      setState(() => currentPage = numPages - 1);
    }
    if (currentPage < 0) {
      currentPage = 0;
    }
    List<MatchScouting2026> pageData = scouting.sublist(
      currentPage * AUTOS_PER_PAGE,
      min(scouting.length, currentPage * AUTOS_PER_PAGE + AUTOS_PER_PAGE),
    );
    return Center(
      child: isLoading
          ? CircularProgressIndicator(color: Colors.blue)
          : token == null
              ? LoginWidget(
                  redirect_path:
                      '/event/${widget.widget.tournament.key}/team/frc${widget.widget.teamNumber}',
                )
              : Column(
                  children: [
                    if (scouting.length == 0)
                      Text(
                        'No data for this event',
                        style: TextStyle(fontSize: 30, fontFamily: 'Font'),
                      ),
                    Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
                      int numColumns = constraints.maxWidth < 500 ? 1 : 2;
                      int numRows = (pageData.length / numColumns).ceil();
                      return SingleChildScrollView(
                          child: Column(children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(numColumns, (int colIndex) {
                              return ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          constraints.maxWidth / numColumns),
                                  child: Column(
                                    children:
                                        List.generate(numRows, (int rowIndex) {
                                      int index =
                                          rowIndex * numColumns + colIndex;
                                      if (index < pageData.length) {
                                        return AutoDisplay2026(
                                          scoutingData: pageData[index],
                                        );
                                      }
                                      return SizedBox.shrink();
                                    }),
                                  ));
                            }))
                      ]));
                    })),
                    if (numPages > 1)
                      NumberPaginator(
                        initialPage: currentPage,
                        numberPages: numPages,
                        onPageChange: (page) {
                          setState(() => currentPage = page);
                        },
                        config: NumberPaginatorUIConfig(
                          buttonSelectedBackgroundColor: Colors.blue,
                          buttonUnselectedForegroundColor: Colors.blue,
                        ),
                        prevButtonContent:
                            Icon(Icons.chevron_left, color: Colors.blue),
                        nextButtonContent:
                            Icon(Icons.chevron_right, color: Colors.blue),
                      ),
                  ],
                ),
    );
  }
}

class _DeathsTab extends StatefulWidget {
  final TeamPage widget;

  const _DeathsTab(this.widget);

  @override
  _DeathsTabState createState() => _DeathsTabState();
}

class _DeathsTabState extends State<_DeathsTab> {
  bool loading = true;
  String? token;
  @override
  initState() {
    super.initState();
    ApiService api = Provider.of<ApiService>(context, listen: false);
    api.token.then((_token) {
      setState(() {
        this.token = _token;
        loading = false;
      });
      this.token = _token;
      loading = false;
    }).onError((_, __) {
      loading = false;
      if (mounted)
        setState(() {
          loading = false;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: loading
          ? CircularProgressIndicator(color: Colors.blue)
          : token == null
              ? LoginWidget(
                  redirect_path:
                      '/event/${widget.widget.tournament.key}/team/frc${widget.widget.teamNumber}',
                )
              : DeathsForm(
                  widget.widget.tournament, widget.widget.teamNumber, true),
    );
  }
}
