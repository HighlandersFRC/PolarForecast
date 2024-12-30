import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flat/flat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import '../widgets/deaths_form.dart';
import '../models/match_scouting_2024.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../widgets/auto_display_2024.dart';
import '../widgets/match_link.dart';
import '../widgets/polar_forecast_app_bar.dart';
import '../api_service.dart';
import '../models/tournament.dart';

class TeamPage extends StatefulWidget {
  final Tournament tournament;
  final int teamNumber;

  const TeamPage(this.teamNumber, this.tournament);

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
  Map<String, dynamic> statDescription = {'data': []};
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
      final fetchedStatDescription = await apiService.fetchStatDescription(
        int.parse(widget.widget.tournament.page.split('/')[3]),
        widget.widget.tournament.page.split('/')[4],
      );
      if (mounted) {
        setState(() {
          stats = fetchedStats;
          statDescription = fetchedStatDescription;
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
            textScaleFactor: 1.25,
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
            textScaleFactor: 1.25,
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
            textScaleFactor: 1.25,
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
            textScaleFactor: 1.25,
            cell.value.toString(),
          ),
        ));
      else
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: color,
          child: Text(
            textScaleFactor: 1.25,
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
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'result_type',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Type',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'color',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Alliance',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'team_score',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Team Points',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'opponent_score',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Opponent Points',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'team_rp',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Ranking Points',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
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
  List<Image> images = [];
  bool isLoading = true;

  void fetchPictures() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
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
      }
    } catch (e) {
      print('Error fetching data: $e');
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
          : LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                            return Dialog(
                              insetPadding: EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image(
                                  image: images[index].image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
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
                          child: Image(
                            image: images[index].image,
                            fit: BoxFit.cover,
                          ),
                        ),
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
  List<MatchScouting2024> scouting = [];
  List<DataGridRow> rows = [];
  List<GridColumn> columns = [];
  Map<String, dynamic> statDescription = {'scoutingData': {}};
  late ScrollController scrollController;

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
    final fetchedStats = (await apiService.fetchTeamMatchScouting(
      int.parse(widget.widget.tournament.page.split('/')[3]),
      widget.widget.tournament.page.split('/')[4],
      'frc${widget.widget.teamNumber}',
    ));
    final fetchedDescriptions = await apiService.fetchStatDescription(
      int.parse(widget.widget.tournament.page.split('/')[3]),
      widget.widget.tournament.page.split('/')[4],
    );
    if (mounted) {
      setState(() {
        statDescription = fetchedDescriptions;
        scouting = [...fetchedStats];
        isLoading = false;
      });
    }
    // } catch (e) {
    //   print('Error fetching data: $e');
    // }
  }

  void updateGrid() {
    setState(() {
      columns = [];
      for (var description in statDescription['scoutingData']) {
        columns.add(GridColumn(
          columnName: description['stat_key'],
          label: Text(description['display_name']),
        ));
      }
      columns.add(GridColumn(
        columnName: 'active',
        label: Text('Active'),
      ));

      rows = [];
      for (var entry in scouting) {
        var flattened = flatten(entry.toJson()['data'], delimiter: '_');
        flattened = {
          ...flattened,
          ...entry.data.miscellaneous.toJson(),
          'scout_name': entry.scout_info.name,
        };
        rows.add(DataGridRow(cells: [
          ...statDescription['scoutingData'].map((stat) {
            if (stat['stat_key'] == 'died') {
              return DataGridCell(
                columnName: stat['stat_key'],
                value: flattened[stat['stat_key']] == 0
                    ? false
                    : flattened[stat['stat_key']] == 1
                        ? true
                        : flattened[stat['stat_key']] ?? stat['stat_key'],
              );
            }
            return DataGridCell(
              columnName: stat['stat_key'],
              value: flattened[stat['stat_key']] ??
                  entry.toJson()[stat['stat_key']],
            );
          }),
          DataGridCell(
            columnName: 'active',
            value: entry.toJson()['active'],
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
            : LayoutBuilder(
                builder: (context, constraints) => Container(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: InteractiveViewer(
                      child: SfDataGrid(
                        allowFiltering: true,
                        allowSorting: true,
                        columns: columns,
                        frozenColumnsCount: 2,
                        columnWidthMode: ColumnWidthMode.auto,
                        source: _MatchScoutingSource(rows, scouting),
                      ),
                    ))));
  }
}

class _MatchScoutingSource extends DataGridSource {
  final List<DataGridRow> rows;
  final List<dynamic> scoutingData;
  _MatchScoutingSource(List<DataGridRow> this.rows, this.scoutingData);
  @override
  DataGridRowAdapter? buildRow(
    DataGridRow row,
  ) {
    int index = rows.indexOf(row);
    List<Widget> cells = [];
    for (var cell in row.getCells()) {
      if (cell.columnName == 'active') {
        cells.add(ActivateButton(data: scoutingData[index]));
      } else
        cells.add(Text(
          cell.value.toString(),
        ));
    }
    return DataGridRowAdapter(cells: cells);
  }
}

class ActivateButton extends StatefulWidget {
  MatchScouting2024 data;

  ActivateButton({Key? key, required this.data}) : super(key: key);

  @override
  _ActivateButtonState createState() => _ActivateButtonState();
}

class _ActivateButtonState extends State<ActivateButton> {
  bool activated = false;
  String text = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    activated = widget.data.active;
    text = activated ? 'Deactivate' : 'Activate';
  }

  void handleActivate() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      text = activated ? 'Deactivating...' : 'Activating...';
    });

    if (activated) {
      await apiService.deactivateMatchData(
          widget.data.toJson(), password, deactivateCallback);
    } else {
      await apiService.activateMatchData(
          widget.data.toJson(), password, activateCallback);
    }
  }

  void deactivateCallback(int status) {
    if (status == 200) {
      setState(() {
        text = 'Activate';
        activated = false;
        widget.data = widget.data.copyWith(active: false);
      });
    } else {
      setState(() {
        text = 'Deactivate';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deactivation Failed')),
      );
    }
  }

  void activateCallback(int status) {
    if (status == 200) {
      setState(() {
        text = 'Deactivate';
        activated = true;
        widget.data = widget.data.copyWith(active: true);
      });
    } else {
      setState(() {
        text = 'Activate';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Activation Failed')),
      );
    }
  }

  void showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Password'),
          content: TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
            onChanged: (value) {
              setState(() {
                password = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                handleActivate();
              },
              child: Text(text),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showPasswordDialog(context);
      },
      child: Text(text),
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
      child: Column(
        children: [Text('PitScouting')],
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
  List<MatchScouting2024> scouting = [];
  int AUTOS_PER_PAGE = 15;
  int currentPage = 0;
  bool isLoading = true;
  @override
  initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final fetchedStats = (await apiService.fetchTeamMatchScouting(
      int.parse(widget.widget.tournament.page.split('/')[3]),
      widget.widget.tournament.page.split('/')[4],
      'frc${widget.widget.teamNumber}',
    ));
    if (mounted) {
      setState(() {
        scouting = [...fetchedStats];
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
    List<MatchScouting2024> pageData = scouting.sublist(
      currentPage * AUTOS_PER_PAGE,
      min(scouting.length, currentPage * AUTOS_PER_PAGE + AUTOS_PER_PAGE),
    );
    int numColumns = 3;
    int numRows = (pageData.length / 3).ceil();
    return Center(
      child: isLoading
          ? CircularProgressIndicator(color: Colors.blue)
          : Column(
              children: [
                if (scouting.length == 0)
                  Text(
                    'No data for this event',
                    style: TextStyle(fontSize: 30),
                  ),
                Expanded(child: LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                      child: Column(children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(numColumns, (int colIndex) {
                          return ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth / numColumns),
                              child: Column(
                                children:
                                    List.generate(numRows, (int rowIndex) {
                                  int index = rowIndex * numColumns + colIndex;
                                  if (index < pageData.length) {
                                    return AutoDisplay2024(
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          DeathsForm(widget.widget.tournament, widget.widget.teamNumber, true),
    );
  }
}
