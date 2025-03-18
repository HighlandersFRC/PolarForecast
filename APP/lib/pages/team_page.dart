import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flat/flat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/picture_data.dart';
import 'package:scouting_app/widgets/auto_display_2025.dart';
import 'package:scouting_app/widgets/pit_scouting_form.dart';
import '../models/match_scouting_2025.dart';
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
      _StatsTab(widget),
      _ScheduleTab(widget),
      _PicturesTab(widget),
      _MatchScoutingTab(widget),
      _PitScoutingTab(widget),
      _AutosTab(widget),
      _DeathsTab(widget),
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
              label: 'Deaths')
        ],
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black),
        selectedItemColor:
            theme.brightness == Brightness.dark ? Colors.white : Colors.black,
        showUnselectedLabels: false,
      ),
      body: tabs[_currentTab],
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
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ...stats.entries.map((entry) {
                          return Card(
                            elevation: 5,
                            shadowColor: theme.primaryColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    formatValue(entry.value),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
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
        String matchNumber = cell.value.toString().split(' ')[1];
        String type = cell.value.toString().contains('Quals')
            ? 'qm'
            : cell.value.toString().contains('Semi')
                ? 'sf'
                : 'f';
        String match_key = '${tournament.key}_$type$matchNumber';
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
          ),
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
          ),
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
          ),
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
          ),
        ));
      else
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: color,
          child: Text(
            textScaler: TextScaler.linear(1.25),
            cell.value.toString(),
          ),
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
              child: Text(
                'Match',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'result_type',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Type',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'color',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Alliance',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'team_score',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Team Points',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'opponent_score',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Opponent Points',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'team_rp',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Ranking Points',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
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
  void fetchPictures() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    this.token = await apiService.token;
    if (token != null) {
      try {
        final fetchedStats = await apiService.fetchTeamImages(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4],
          'frc${widget.widget.teamNumber}',
        );
        if (mounted) {
          setState(() {
            images = fetchedStats;
            isLoading = false;
          });
        } else {
          images = fetchedStats;
          isLoading = false;
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPictures();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator(color: Colors.blue)
          : token == null
              ? LoginWidget(
                  redirect_path:
                      '/event/${widget.widget.tournament.key}/team/frc${widget.widget.teamNumber}')
              : images.isEmpty
                  ? Text('No Images')
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          padding: EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: AlertDialog(
                                          content: Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                    images[index].link)),
                                          ),
                                          actions: [
                                            Text(
                                                'Uploaded by: ${images[index].scout_info.first_name ?? 'scout on ${images[index].scout_info.team_number}'}'),
                                            if (images[index]
                                                .permissions
                                                .contains('delete'))
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          foregroundColor:
                                                              Colors.white),
                                                  onPressed: () {
                                                    final api =
                                                        Provider.of<ApiService>(
                                                            context,
                                                            listen: false);
                                                    Navigator.of(context).pop();
                                                    api
                                                        .delete_image(
                                                            images[index])
                                                        .then((_) {
                                                      setState(() {
                                                        images.removeAt(index);
                                                      });
                                                    });
                                                  },
                                                  child: Text('Delete')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Close'))
                                          ],
                                        ));
                                  },
                                );
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      images[index].link,
                                      fit: BoxFit.fill,
                                      loadingBuilder: (context, child, event) {
                                        if (event == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator
                                                .adaptive(
                                              value:
                                                  event.cumulativeBytesLoaded /
                                                      event.expectedTotalBytes!,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.blue),
                                            ),
                                          );
                                        }
                                      },
                                    )),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

class _MatchScoutingTab extends StatefulWidget {
  final TeamPage widget;

  const _MatchScoutingTab(this.widget);

  @override
  _MatchScoutingTabState createState() => _MatchScoutingTabState();
}

class _MatchScoutingTabState extends State<_MatchScoutingTab> {
  List<MatchScouting2025> scouting = [];
  List<DataGridRow> rows = [];
  List<GridColumn> columns = [];
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
    // try {
    this.token = await apiService.token;
    if (token != null) {
      final fetchedStats = (await apiService.fetchTeamMatchScouting(
        int.parse(widget.widget.tournament.page.split('/')[3]),
        widget.widget.tournament.page.split('/')[4],
        'frc${widget.widget.teamNumber}',
      ));
      final groups = (await apiService.get_user_groups_detailed());
      if (groups.isNotEmpty) {
        final (_group, _role) = (await apiService.get_group(groups[0].name));
        if (mounted)
          setState(() {
            role = _role;
            scouting = [...fetchedStats];
          });
        role = _role;
        scouting = [...fetchedStats];
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    isLoading = false;
    // } catch (e) {
    //   print('Error fetching data: $e');
    // }
  }

  void updateGrid() {
    setState(() {
      columns = [
        GridColumn(columnName: 'scout_name', label: Text('Scout Name')),
        GridColumn(columnName: 'match_number', label: Text('Match')),
        GridColumn(columnName: 'auto_scoring_l_1', label: Text('Auto L1')),
        GridColumn(columnName: 'auto_scoring_l_2', label: Text('Auto L2')),
        GridColumn(columnName: 'auto_scoring_l_3', label: Text('Auto L3')),
        GridColumn(columnName: 'auto_scoring_l_4', label: Text('Auto L4')),
        GridColumn(columnName: 'auto_scoring_net', label: Text('Auto Net')),
        GridColumn(
            columnName: 'auto_scoring_processor',
            label: Text('Auto Processor')),
        GridColumn(columnName: 'teleop_scoring_l_1', label: Text('Teleop L1')),
        GridColumn(columnName: 'teleop_scoring_l_2', label: Text('Teleop L2')),
        GridColumn(columnName: 'teleop_scoring_l_3', label: Text('Teleop L3')),
        GridColumn(columnName: 'teleop_scoring_l_4', label: Text('Teleop L4')),
        GridColumn(columnName: 'teleop_scoring_net', label: Text('Teleop Net')),
        GridColumn(
            columnName: 'teleop_scoring_processor',
            label: Text('Teleop Processor')),
        GridColumn(columnName: 'died', label: Text('Died')),
        GridColumn(columnName: 'comments', label: Text('Comments')),
        GridColumn(columnName: 'delete', label: Text('Delete'))
      ];
      rows = [];
      for (var entry in scouting) {
        var flattened = flatten(entry.toJson()['data'], delimiter: '_');
        flattened = {
          ...flattened,
          ...entry.data.miscellaneous.toJson(),
          'scout_name': entry.scout_info.first_name ??
              'From Team ${entry.scout_info.team_number}',
        };
        rows.add(DataGridRow(cells: [
          DataGridCell(
              columnName: 'scout_name',
              value: entry.scout_info.first_name ??
                  'Scout from ${entry.scout_info.team_number}'),
          DataGridCell(columnName: 'match_number', value: entry.match_number),
          DataGridCell(
              columnName: 'auto_scoring_l_1',
              value: entry.data.auto_scoring.l_1),
          DataGridCell(
              columnName: 'auto_scoring_l_2',
              value: entry.data.auto_scoring.l_2),
          DataGridCell(
              columnName: 'auto_scoring_l_3',
              value: entry.data.auto_scoring.l_3),
          DataGridCell(
              columnName: 'auto_scoring_l_4',
              value: entry.data.auto_scoring.l_4),
          DataGridCell(
              columnName: 'auto_scoring_net',
              value: entry.data.auto_scoring.net),
          DataGridCell(
              columnName: 'auto_scoring_processor',
              value: entry.data.auto_scoring.processor),
          DataGridCell(
              columnName: 'teleop_scoring_l_1',
              value: entry.data.teleop_scoring.l_1),
          DataGridCell(
              columnName: 'teleop_scoring_l_2',
              value: entry.data.teleop_scoring.l_2),
          DataGridCell(
              columnName: 'teleop_scoring_l_3',
              value: entry.data.teleop_scoring.l_3),
          DataGridCell(
              columnName: 'teleop_scoring_l_4',
              value: entry.data.teleop_scoring.l_4),
          DataGridCell(
              columnName: 'teleop_scoring_net',
              value: entry.data.teleop_scoring.net),
          DataGridCell(
              columnName: 'teleop_scoring_processor',
              value: entry.data.teleop_scoring.processor),
          DataGridCell(
              columnName: 'died', value: entry.data.miscellaneous.died),
          DataGridCell(
              columnName: 'comments', value: entry.data.miscellaneous.comments),
          DataGridCell(
            columnName: 'delete',
            value: entry.scout_info.first_name != null &&
                (role == 'admin' || role == 'owner'),
          ),
        ]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.blue)
            : token == null
                ? LoginWidget(
                    redirect_path:
                        '/event/${widget.widget.tournament.key}/team/frc${widget.widget.teamNumber}',
                  )
                : scouting.isEmpty
                    ? Text('No Entries')
                    : LayoutBuilder(
                        builder: (context, constraints) => Container(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            child: InteractiveViewer(
                              child: SfDataGrid(
                                allowFiltering: true,
                                allowSorting: true,
                                columns: columns,
                                frozenColumnsCount: 0,
                                columnWidthMode: ColumnWidthMode.auto,
                                source: _MatchScoutingSource(rows, scouting,
                                    (delete_index) {
                                  setState(() {
                                    scouting.removeAt(delete_index);
                                    updateGrid();
                                  });
                                }),
                              ),
                            ))));
  }
}

class _MatchScoutingSource extends DataGridSource {
  final List<DataGridRow> rows;
  final List<MatchScouting2025> scoutingData;
  final void Function(int) onDelete;
  _MatchScoutingSource(
      List<DataGridRow> this.rows, this.scoutingData, this.onDelete);
  @override
  DataGridRowAdapter? buildRow(
    DataGridRow row,
  ) {
    int index = rows.indexOf(row);
    List<Widget> cells = [];
    for (var cell in row.getCells()) {
      if (cell.columnName == 'delete') {
        if (cell.value)
          cells.add(DeleteButton(
            data: scoutingData[index],
            onDelete: () {
              onDelete(index);
            },
          ));
        else
          cells.add(SizedBox.shrink());
      } else
        cells.add(Text(
          cell.value.toString(),
        ));
    }
    return DataGridRowAdapter(cells: cells);
  }
}

class DeleteButton extends StatefulWidget {
  final MatchScouting2025 data;
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
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Successfully Deleted')));
            widget.onDelete();
          },
        ).onError((e, trace) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: PitScoutingForm(
          widget.widget.tournament, widget.widget.teamNumber, true),
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
  List<MatchScouting2025> scouting = [];
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
    List<MatchScouting2025> pageData = scouting.sublist(
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
                        style: TextStyle(fontSize: 30),
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
                                        return AutoDisplay2025(
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
