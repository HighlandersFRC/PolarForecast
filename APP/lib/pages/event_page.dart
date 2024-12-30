import 'dart:io';
import 'dart:math';
import 'package:flat/flat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/pages/not_found_page.dart';
import '../widgets/auto_pieces_2024.dart';
import '../models/match_scouting_2024.dart';
import '../widgets/auto_display_2024.dart';
import '../widgets/bar_chart_with_weights.dart';
import '../widgets/counter.dart';
import '../widgets/death_link.dart';
import '../widgets/match_link.dart';
import '../widgets/team_link.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../widgets/polar_forecast_app_bar.dart';
import '../api_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/match_details_2024.dart';
import '../models/team_stats_2024.dart';
import '../models/tournament.dart';
import 'home_page.dart';

class EventPage extends StatefulWidget {
  final Tournament tournament;
  static Widget fromEventKey(BuildContext context, String eventKey) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final tournaments = apiService.fetchTournaments();
    print(eventKey);
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
            return EventPage(
              tournament: tournament,
            );
          } catch (error) {
            return HomePage();
          }
        });
  }

  const EventPage({super.key, required this.tournament});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
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
      _RankingsTab(widget),
      _ChartsTab(widget),
      _MatchScoutingTab(widget),
      _PitScoutingTab(widget),
      _QualsTab(widget),
      _ElimsTab(widget),
      _AutosTab(widget),
    ];
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (newTabIdx) => setState(() => _currentTab = newTabIdx),
          items: [
            BottomNavigationBarItem(
                icon:
                    Icon(Icons.trending_up_outlined, color: theme.primaryColor),
                activeIcon: Icon(Icons.trending_up, color: theme.primaryColor),
                label: 'Rankings'),
            BottomNavigationBarItem(
                icon: Icon(Icons.stacked_bar_chart_outlined,
                    color: theme.primaryColor),
                activeIcon:
                    Icon(Icons.stacked_bar_chart, color: theme.primaryColor),
                label: 'Charts'),
            BottomNavigationBarItem(
                icon: Icon(Icons.remove_red_eye_outlined,
                    color: theme.primaryColor),
                activeIcon:
                    Icon(Icons.remove_red_eye, color: theme.primaryColor),
                label: 'Match Scouting'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group_add_outlined, color: theme.primaryColor),
                activeIcon: Icon(Icons.group_add, color: theme.primaryColor),
                label: 'Pit Scouting'),
            BottomNavigationBarItem(
                icon: Icon(Icons.sports_score_outlined,
                    color: theme.primaryColor),
                activeIcon: Icon(Icons.sports_score, color: theme.primaryColor),
                label: 'Quals'),
            BottomNavigationBarItem(
                icon: Icon(Icons.workspace_premium_outlined,
                    color: theme.primaryColor),
                activeIcon:
                    Icon(Icons.workspace_premium, color: theme.primaryColor),
                label: 'Elims'),
            BottomNavigationBarItem(
                icon: Icon(Icons.precision_manufacturing_outlined,
                    color: theme.primaryColor),
                activeIcon: Icon(Icons.precision_manufacturing,
                    color: theme.primaryColor),
                label: 'Autos')
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
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              PolarForecastSliverBar(
                context: context,
                extraText: widget.tournament.display,
              ),
            ];
          },
          // list of images for scrolling
          body: tabs[_currentTab],
        ));
  }
}

class _RankingsTab extends StatefulWidget {
  final EventPage widget;
  const _RankingsTab(this.widget);

  Tournament get tournament => widget.tournament;

  @override
  State<_RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<_RankingsTab> {
  List<TeamStats2024> rankings = [];
  Map<String, dynamic> statDescription = {'data': []};
  bool isLoading = true;
  List<GridColumn> dataColumns = [];
  Map<String, bool> heatMapFromKey = {};
  Map<String, num> minValues = {};
  Map<String, num> maxValues = {};
  List<DataGridRow> dataRows = [];
  @override
  void initState() {
    super.initState();
    updateGrid();
    fetchData().then((_) {
      updateGrid();
    });
  }

  void updateGrid() {
    dataColumns = [
      GridColumn(
          allowSorting: true,
          label: Text('#'),
          columnName: 'team_number',
          filterPopupMenuOptions: FilterPopupMenuOptions()),
      GridColumn(allowSorting: true, label: Text('OPR'), columnName: 'OPR'),
    ];
    heatMapFromKey = {
      'team_number': false,
      'OPR': true,
    };
    for (var stat in statDescription['data']) {
      if (stat['report_stat'] && stat['stat_key'] != 'OPR') {
        heatMapFromKey[stat['stat_key']] = stat['stat_type'] == 'num';
        dataColumns.add(GridColumn(
          label: Text(stat['display_name']),
          columnName: stat['stat_key'],
        ));
      }
    }
    minValues = {};
    maxValues = {};
    for (var column in dataColumns) {
      if (heatMapFromKey[column.columnName]!) {
        var columnKey = column.columnName;
        minValues[columnKey] = double.infinity;
        maxValues[columnKey] = double.negativeInfinity;

        for (var rank in rankings) {
          var value = rank.toJson()[columnKey];
          if (value < minValues[columnKey]!) minValues[columnKey] = value;
          if (value > maxValues[columnKey]!) maxValues[columnKey] = value;
        }
      }
    }

    dataRows = [];
    for (var rank in rankings) {
      List<DataGridCell> cells = [];
      for (var column in dataColumns) {
        try {
          if (heatMapFromKey[column.columnName] != null &&
              !(heatMapFromKey[column.columnName]!)) {
            // print(column.columnName);
            cells.add(DataGridCell(
                columnName: column.columnName,
                value: heatMapFromKey[column.columnName]!
                    ? int.parse((rank.toJson()[column.columnName] as num)
                        .toStringAsFixed(2))
                    : int.parse(rank.toJson()[column.columnName].toString())));
          } else {
            cells.add(DataGridCell(
              columnName: column.columnName,
              value: rank.toJson()[column.columnName],
            ));
          }
        } catch (e) {
          print(e);
          cells.add(DataGridCell(columnName: column.columnName, value: ''));
        }
      }
      dataRows.add(DataGridRow(
        cells: cells,
      ));
    }
  }

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    // try {
    final fetchedRankings = await apiService.fetchEventRankings(
        int.parse(widget.tournament.page.split('/')[3]),
        widget.tournament.page.split('/')[4]);
    final fetchedStatDescription = await apiService.fetchStatDescription(
        int.parse(widget.tournament.page.split('/')[3]),
        widget.tournament.page.split('/')[4]);

    if (mounted) {
      setState(() {
        rankings = fetchedRankings;
        statDescription = fetchedStatDescription;
        isLoading = false;
      });
    }
    // } catch (e) {
    //   print('Error fetching data: $e');
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    const columnMinWidth = 95.0;
    bool isWide = MediaQuery.of(context).size.width >=
        dataColumns.length * columnMinWidth;
    return Center(
        child: LayoutBuilder(
            builder: (context, constraints) => Container(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: SfDataGrid(
                    allowFiltering: true,
                    defaultColumnWidth: columnMinWidth,
                    columnWidthMode:
                        isWide ? ColumnWidthMode.fill : ColumnWidthMode.none,
                    allowSorting: true,
                    columns: dataColumns,
                    frozenColumnsCount: 2,
                    source: _TeamDataSource(dataRows, minValues, maxValues,
                        heatMapFromKey, context, widget.tournament),
                  ),
                )));
  }
}

class _TeamDataSource extends DataGridSource {
  _TeamDataSource(this.rows, this.minValues, this.maxValues, this.heatMap,
      this.context, this.tournament);
  final Map<String, dynamic> minValues, maxValues, heatMap;
  final List<DataGridRow> rows;
  final BuildContext context;
  final Tournament tournament;
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        int rowNumber = rows.indexOf(row);
        bool even = rowNumber % 2 == 0;
        final color = heatMap[e.columnName] != null && heatMap[e.columnName]!
            ? _getGradientColor(
                e.value,
                minValues[e.columnName],
                maxValues[e.columnName],
                e.columnName == 'rank' ||
                    e.columnName == 'simulated_rank' ||
                    e.columnName == 'death_rate')
            : even
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0);
        if (e.columnName == 'team_number') {
          // print(e.columnName.runtimeType);
          return Container(
              color: color,
              child: TeamLink(int.parse(e.value.toString()), tournament));
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: color,
          child: Text('${_formatValue(e.value)}',
              style: TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }

  Color _getGradientColor(num value, num minValue, num maxValue, bool flip) {
    double normalizedValue = (value - minValue) / (maxValue - minValue);
    normalizedValue = normalizedValue.clamp(0.0, 1.0);
    if (flip) normalizedValue = 1 - normalizedValue;
    if (normalizedValue > 0.5) {
      return Color.lerp(Colors.yellow[700], Colors.green.shade800,
              (normalizedValue - 0.5) * 2) ??
          Colors.green.shade700;
    } else {
      return Color.lerp(
              Colors.red.shade700, Colors.yellow[700], normalizedValue * 2) ??
          Colors.red.shade700;
    }
  }

  double _roundToTenths(double value) {
    return (value * 10).roundToDouble() / 10;
  }

  dynamic _formatValue(dynamic value) {
    if (value is double) {
      return _roundToTenths(value).toStringAsFixed(1);
    }
    return value;
  }
}

class _ChartsTab extends StatefulWidget {
  final EventPage widget;
  const _ChartsTab(this.widget);

  @override
  State<StatefulWidget> createState() {
    return new _ChartsTabState();
  }
}

class _ChartsTabState extends State<_ChartsTab> {
  List<TeamStats2024> rankings = [];
  Map<String, dynamic> statDescription = {'data': []};
  bool isLoading = true;
  List<dynamic> scouting = [];
  List<int> teams = [];
  int selectedTeam = 0;
  int secondTeam = 0;
  int lastMatch = 1;
  int firstMatch = 0;
  bool comparing = false;
  bool _hasAdjustedForLandscape = false;

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final fetchedRankings = await apiService.fetchEventRankings(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4]);
      final fetchedStatDescription = await apiService.fetchStatDescription(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4]);
      final fetchedScouting = await apiService.fetchEventScouting(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4]);
      if (mounted) {
        setState(() {
          rankings = fetchedRankings;
          statDescription = fetchedStatDescription;
          isLoading = false;
          scouting = fetchedScouting;
          scouting.forEach((entry) {
            if (!teams.contains(int.parse(entry['team_number'])))
              teams.add(int.parse(entry['team_number']));
            if (int.parse(entry['match_number'].toString()) > lastMatch)
              lastMatch = int.parse(entry['match_number'].toString());
          });
          teams.sort((a, b) => a - b);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    return Center(
        child: SingleChildScrollView(
      child: Column(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            bool landscape =
                MediaQuery.of(context).orientation == Orientation.landscape;

            if (!landscape && !_hasAdjustedForLandscape) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    comparing = false;
                  });
                  _hasAdjustedForLandscape = true;
                }
              });
            } else if (landscape) {
              // Reset flag if needed for landscape changes
              _hasAdjustedForLandscape = false;
            }
            List<dynamic> teamScoutingData = [];
            if (selectedTeam != 0)
              for (var entry in scouting) {
                if (entry['active'] &&
                    int.parse(entry['team_number']) ==
                        teams[selectedTeam - 1]) {
                  teamScoutingData.add(entry);
                }
              }
            teamScoutingData
                .sort((a, b) => a['match_number'] - b['match_number']);
            Map<String, List> seriesData = {
              'matches': [],
              'entries': [],
            };
            List<String> seriesLabels = [
              'auto_amp',
              'auto_speaker',
              'teleop_amp',
              'teleop_speaker',
              'teleop_amped_speaker',
              'teleop_pass',
            ];
            for (var series in seriesLabels) {
              seriesData[series] = [];
            }
            for (var entry in teamScoutingData) {
              entry['data'].remove('miscellaneous');
              entry['data'].remove('selectedPieces');
              var flattened = flatten(
                entry['data'],
                delimiter: '_',
              );
              if (!seriesData['matches']!.contains(entry['match_number'])) {
                seriesData['matches']?.add(entry['match_number']);
                seriesData['entries']?.add(1);
                for (var label in seriesLabels) {
                  try {
                    seriesData[label]?.add(flattened[label] ?? 0);
                  } catch (e) {
                    seriesData[label]?.add(0);
                  }
                }
              } else {
                seriesData['entries']?[
                    seriesData['matches']!.indexOf(entry['match_number'])] += 1;
                for (var label in seriesLabels) {
                  try {
                    seriesData[label]?[seriesData['matches']!
                        .indexOf(entry['match_number'])] += flattened[label];
                  } catch (e) {}
                }
              }
            }
            List<int> entries = [...?seriesData.remove('entries')];
            List<int> matches = [...?seriesData.remove('matches')];
            for (var object in seriesData.entries) {
              seriesData[object.key] = [
                ...seriesData[object.key]!
                    .indexed
                    .map((val) => val.$2 / entries[val.$1])
              ];
            }
            List<dynamic> secondTeamScoutingData = [];
            if (secondTeam != 0)
              for (var entry in scouting) {
                if (entry['active'] &&
                    int.parse(entry['team_number']) == teams[secondTeam - 1]) {
                  secondTeamScoutingData.add(entry);
                }
              }
            secondTeamScoutingData
                .sort((a, b) => a['match_number'] - b['match_number']);
            Map<String, List> secondSeriesData = {
              'matches': [],
              'entries': [],
            };
            for (var series in seriesLabels) {
              secondSeriesData[series] = [];
            }
            for (var entry in secondTeamScoutingData) {
              entry['data'].remove('miscellaneous');
              entry['data'].remove('selectedPieces');
              var flattened = flatten(
                entry['data'],
                delimiter: '_',
              );
              if (!secondSeriesData['matches']!
                  .contains(entry['match_number'])) {
                secondSeriesData['matches']?.add(entry['match_number']);
                secondSeriesData['entries']?.add(1);
                for (var label in seriesLabels) {
                  try {
                    secondSeriesData[label]?.add(flattened[label] ?? 0);
                  } catch (e) {
                    secondSeriesData[label]?.add(0);
                  }
                }
              } else {
                secondSeriesData['entries']?[secondSeriesData['matches']!
                    .indexOf(entry['match_number'])] += 1;
                for (var label in seriesLabels) {
                  try {
                    secondSeriesData[label]?[secondSeriesData['matches']!
                        .indexOf(entry['match_number'])] += flattened[label];
                  } catch (e) {}
                }
              }
            }
            List<int> secondEntries = [...?secondSeriesData.remove('entries')];
            List<int> secondMatches = [...?secondSeriesData.remove('matches')];
            for (var object in secondSeriesData.entries) {
              secondSeriesData[object.key] = [
                ...secondSeriesData[object.key]!
                    .indexed
                    .map((val) => val.$2 / secondEntries[val.$1])
              ];
            }
            double maxY = 1;
            if (comparing && secondTeam != 0)
              for (var match in secondMatches) {
                double sum = 0;
                for (String label in seriesLabels) {
                  sum += secondSeriesData[label]?[secondMatches.indexOf(match)];
                }
                maxY = max(maxY, sum + 1);
              }
            if (selectedTeam != 0)
              for (var match in matches) {
                double sum = 0;
                for (String label in seriesLabels) {
                  sum += seriesData[label]?[matches.indexOf(match)];
                }
                maxY = max(maxY, sum + 1);
              }
            var firstChart = SfCartesianChart(
                primaryXAxis: NumericAxis(
                  minimum: firstMatch.toDouble(),
                  maximum: lastMatch.toDouble(),
                ),
                primaryYAxis: NumericAxis(
                  maximum: maxY,
                  minimum: 0,
                ),
                legend:
                    Legend(isVisible: true, position: LegendPosition.bottom),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  shared: true,
                ),
                series: [
                  ...seriesData.entries.toList().map((entry) {
                    return StackedAreaSeries<double, int>(
                        enableTooltip: true,
                        animationDuration: 500,
                        name: entry.key,
                        dataSource: [
                          ...entry.value.map((val) {
                            return double.parse(val.toString());
                          }),
                        ],
                        borderDrawMode: BorderDrawMode.excludeBottom,
                        borderWidth: 2,
                        xValueMapper: (data, _) => matches[_],
                        yValueMapper: (data, _) => data);
                  })
                ]);
            var secondChart = SfCartesianChart(
                primaryXAxis: NumericAxis(
                  minimum: firstMatch.toDouble(),
                  maximum: lastMatch.toDouble(),
                ),
                primaryYAxis: NumericAxis(
                  maximum: maxY,
                  minimum: 0,
                ),
                legend:
                    Legend(isVisible: true, position: LegendPosition.bottom),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  shared: true,
                ),
                series: [
                  ...secondSeriesData.entries.toList().map((entry) {
                    return StackedAreaSeries<double, int>(
                        enableTooltip: true,
                        animationDuration: 500,
                        name: entry.key,
                        dataSource: [
                          ...entry.value.map((val) {
                            return double.parse(val.toString());
                          }),
                        ],
                        borderDrawMode: BorderDrawMode.excludeBottom,
                        borderWidth: 2,
                        xValueMapper: (data, _) => secondMatches[_],
                        yValueMapper: (data, _) => data);
                  })
                ]);
            return Row(children: [
              Column(children: [
                Padding(
                  padding: EdgeInsets.all(
                    30,
                  ),
                  child: Row(children: [
                    DropdownButton<int>(
                      items: [
                        DropdownMenuItem(
                          child: Text('Select a Team'),
                          value: 0,
                        ),
                        ...teams.map((team) => DropdownMenuItem(
                              child: Text('Team $team'),
                              value: teams.indexOf(team) + 1,
                            ))
                      ],
                      onChanged: (team) => setState(() {
                        selectedTeam = team ?? 0;
                      }),
                      value: selectedTeam,
                    ),
                    if (landscape)
                      Tooltip(
                          message: 'Compare',
                          child: IconButton(
                              icon: comparing
                                  ? Icon(Icons.compare_arrows)
                                  : Icon(Icons.compare_arrows,
                                      color: Colors.blue),
                              onPressed: () => setState(() {
                                    comparing = !comparing;
                                  })))
                  ]),
                ),
                Row(children: [
                  AnimatedSize(
                      curve: Curves.decelerate,
                      alignment: Alignment(0, 0),
                      duration: Duration(milliseconds: 500),
                      child: Container(
                          width: comparing
                              ? constraints.maxWidth / 2
                              : constraints.maxWidth,
                          child: firstChart))
                ]),
              ]),
              if (comparing)
                Column(children: [
                  Padding(
                    padding: EdgeInsets.all(
                      30,
                    ),
                    child: Row(children: [
                      DropdownButton<int>(
                        items: [
                          DropdownMenuItem(
                            child: Text('Select a Team'),
                            value: 0,
                          ),
                          ...teams.map((team) => DropdownMenuItem(
                                child: Text('Team $team'),
                                value: teams.indexOf(team) + 1,
                              )),
                        ],
                        onChanged: (team) => setState(() {
                          secondTeam = team ?? 0;
                        }),
                        value: secondTeam,
                      ),
                    ]),
                  ),
                  Row(children: [
                    AnimatedSize(
                        curve: Curves.decelerate,
                        alignment: Alignment(0, 0),
                        duration: Duration(milliseconds: 500),
                        child: Container(
                            width: comparing ? constraints.maxWidth / 2 : 0,
                            child: secondChart))
                  ]),
                ])
            ]);
          }),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: BarChartWithWeights(
                  title: 'OPR By Game Period',
                  data: rankings,
                  number: 24,
                  startingFields: [
                    Field(
                        name: 'Auto',
                        key: 'auto_points',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Teleop',
                        key: 'teleop_points',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'End Game',
                        key: 'endgame_points',
                        enabled: true,
                        weight: 1),
                  ])),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: BarChartWithWeights(
                  title: 'Notes By Game Period',
                  data: rankings,
                  number: 24,
                  startingFields: [
                    Field(
                        name: 'Teleop Notes',
                        key: 'teleop_notes',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Auto Notes',
                        key: 'auto_notes',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Endgame Notes',
                        key: 'trap',
                        enabled: true,
                        weight: 1),
                  ])),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: BarChartWithWeights(
                  title: 'Notes By Placement',
                  data: rankings,
                  number: 24,
                  startingFields: [
                    Field(
                        name: 'Speaker',
                        key: 'speaker_total',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Amp',
                        key: 'amp_total',
                        enabled: true,
                        weight: 1),
                    Field(name: 'Trap', key: 'trap', enabled: true, weight: 1),
                    Field(
                        name: 'Pass',
                        key: 'teleop_pass',
                        enabled: true,
                        weight: 0.5),
                  ])),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: BarChartWithWeights(
                  title: 'Full OPR Breakdown',
                  data: rankings,
                  number: 24,
                  startingFields: [
                    new Field(
                        name: 'AS',
                        key: 'auto_speaker',
                        enabled: true,
                        weight: 5),
                    Field(
                        name: 'AA', key: 'auto_amp', enabled: true, weight: 2),
                    Field(
                        name: 'TS',
                        key: 'teleop_speaker',
                        enabled: true,
                        weight: 2),
                    Field(
                        name: 'TAS',
                        key: 'teleop_amped_speaker',
                        enabled: true,
                        weight: 5),
                    Field(
                        name: 'TA',
                        key: 'teleop_amp',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Pass',
                        key: 'teleop_pass',
                        enabled: true,
                        weight: 1),
                    Field(name: 'Trap', key: 'trap', enabled: true, weight: 5),
                    Field(
                        name: 'Taxi',
                        key: 'mobility',
                        enabled: true,
                        weight: 2),
                    Field(
                        name: 'Park', key: 'parking', enabled: true, weight: 1),
                    Field(
                        name: 'Climb',
                        key: 'climbing',
                        enabled: true,
                        weight: 3),
                    Field(
                        name: 'Deathrate',
                        key: 'death_rate',
                        enabled: true,
                        weight: -10),
                  ])),
        ],
      ),
    ));
  }
}

class _MatchScoutingTab extends StatefulWidget {
  final EventPage widget;
  const _MatchScoutingTab(this.widget);
  @override
  State<StatefulWidget> createState() {
    return _MatchScoutingTabState();
  }
}

class _MatchScoutingTabState extends State<_MatchScoutingTab> {
  late final TextEditingController eventCodeController,
      teamNumberController,
      matchNumberController,
      scoutNameController;
  int driverStationIndex = -1;
  List<String> selectedPieces = [];
  MatchDetails2024? matchDetails = null;
  @override
  initState() {
    super.initState();
    eventCodeController =
        TextEditingController(text: widget.widget.tournament.key);
    teamNumberController = TextEditingController();
    matchNumberController = TextEditingController();
    scoutNameController = TextEditingController();
  }

  getNewMatchDetails(int matchNumber) {
    if (matchNumber <= 0) {
      return;
    }
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService
        .fetchMatchDetails(
            int.parse(widget.widget.tournament.key.substring(0, 4)),
            widget.widget.tournament.key.substring(4),
            '${widget.widget.tournament.key}_qm$matchNumber')
        .then((value) {
      if (matchNumber == int.parse(matchNumberController.text)) {
        setState(() {
          matchDetails = value;
        });
        updateTeamNumber();
      }
    });
  }

  updateTeamNumber() {
    if (matchDetails == null) {
      return;
    }
    List<String> teams = [
      ...matchDetails!.match.alliances.red.team_keys,
      ...matchDetails!.match.alliances.blue.team_keys,
    ];
    String team = '';
    if (driverStationIndex != -1) {
      team = teams[driverStationIndex];
    } else {
      int index = Random().nextInt(6);
      team = teams[index];
    }
    teamNumberController.text = team.substring(3);
  }

  @override
  Widget build(BuildContext context) {
    const List<String> DRIVER_STATIONS = [
      'Red 1',
      'Red 2',
      'Red 3',
      'Blue 1',
      'Blue 2',
      'Blue 3'
    ];
    final theme = Theme.of(context);
    return SingleChildScrollView(
        child: Card(
            child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            widget.widget.tournament.display,
            style: TextStyle(color: Colors.blue, fontSize: 24),
          ),
          Divider(),
          SizedBox(height: 4),
          TextField(
            readOnly: true,
            style: TextStyle(color: Colors.grey),
            controller: eventCodeController,
            decoration: InputDecoration(
                label: Text(
              'Event Code',
            )).applyDefaults(theme.inputDecorationTheme),
          ),
          SizedBox(height: 8),
          TextField(
            controller: matchNumberController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allows only digits
            ],
            maxLength: 3,
            onChanged: (value) {
              getNewMatchDetails(int.tryParse(value) ?? -1);
            },
            decoration: InputDecoration(
              label: Text('Match Number'),
              counterText: '',
            ).applyDefaults(theme.inputDecorationTheme),
          ),
          SizedBox(height: 8),
          TextField(
            controller: scoutNameController,
            decoration: InputDecoration(
              label: Text('Scout Name'),
            ).applyDefaults(theme.inputDecorationTheme),
          ),
          SizedBox(height: 8),
          TextField(
            controller: teamNumberController,
            maxLength: 5,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allows only digits
            ],
            decoration: InputDecoration(
              label: Text('Team Number'),
              counterText: '',
            ).applyDefaults(theme.inputDecorationTheme),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<int>(
            isExpanded: true,
            value: driverStationIndex,
            decoration: InputDecoration(
              labelText: 'Driver Station',
            ).applyDefaults(theme.inputDecorationTheme),
            items: [
              DropdownMenuItem<int>(
                child:
                    Text('None', style: TextStyle(fontStyle: FontStyle.italic)),
                value: -1,
              ),
              ...DRIVER_STATIONS.indexed.map(
                (value) => DropdownMenuItem<int>(
                  child: Text(
                    value.$2,
                    style: TextStyle(
                        color: value.$2.contains('Red')
                            ? Colors.red
                            : Colors.blue),
                  ),
                  value: value.$1,
                ),
              )
            ],
            onChanged: (int? value) {
              setState(() => driverStationIndex = value ?? -1);
              updateTeamNumber();
            },
          ),
          SizedBox(height: 8),
          AutoPieces2024(
              selectedPieces: selectedPieces,
              onChanged: (newPieces) {
                setState(() => selectedPieces = newPieces);
              })
        ],
      ),
    )));
  }
}

class _PitScoutingTab extends StatefulWidget {
  final EventPage widget;
  const _PitScoutingTab(this.widget);

  @override
  State<StatefulWidget> createState() {
    return new _PitScoutingTabState();
  }
}

class _PitScoutingTabState extends State<_PitScoutingTab> {
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
      final fetchedStatus = await apiService.fetchPitStatus(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4]);
      if (mounted) {
        setState(() {
          statuses = fetchedStatus;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void updateGrid() {
    dataColumns = [
      GridColumn(
          columnName: 'key',
          allowSorting: true,
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Team',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'pit_status',
          allowSorting: true,
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Pit Scouting',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'picture_status',
          allowSorting: true,
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Pictures',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'follow_up_status',
          allowSorting: true,
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Follow Up',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
    ];

    statuses.sort((a, b) {
      return int.parse(a['key']) - int.parse(b['key']);
    });

    // statuses.sort((a, b) {
    //   return a['key'] - b['key'];
    // });

    dataRows = [
      for (Map<String, dynamic> status in statuses)
        DataGridRow(cells: [
          DataGridCell(columnName: 'key', value: int.parse(status['key'])),
          DataGridCell(columnName: 'pit_status', value: status['pit_status']),
          DataGridCell(
              columnName: 'picture_status', value: status['picture_status']),
          DataGridCell(
              columnName: 'follow_up_status',
              value: status['follow_up_status']),
        ])
    ];
  }

  @override
  Widget build(BuildContext context) {
    const columnMinWidth = 110.0;
    bool isWide = MediaQuery.of(context).size.width >=
        dataColumns.length * columnMinWidth;
    return Center(
        child: LayoutBuilder(
            builder: (context, constraints) => Container(
                alignment: Alignment.center,
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: InteractiveViewer(
                  scaleEnabled: false,
                  clipBehavior: Clip.hardEdge,
                  child: SfDataGrid(
                    allowSorting: true,
                    columns: dataColumns,
                    defaultColumnWidth: columnMinWidth,
                    columnWidthMode:
                        isWide ? ColumnWidthMode.fill : ColumnWidthMode.none,
                    frozenColumnsCount: 0,
                    source: _StatusSource(
                        context, dataRows, widget.widget.tournament),
                  ),
                ))));
  }
}

class _StatusSource extends DataGridSource {
  final BuildContext context;
  final List<DataGridRow> rows;
  final Tournament tournament;
  _StatusSource(BuildContext this.context, this.rows, this.tournament);
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    List<DataGridCell> cells = row.getCells();
    List<Widget> returnCells = [];
    for (DataGridCell cell in cells) {
      int rowNumber = rows.indexOf(row);
      bool even = rowNumber % 2 == 0;
      final color = even
          ? Theme.of(context).primaryColor.withOpacity(0.3)
          : Colors.black.withOpacity(0);
      cell.columnName == 'key'
          ? returnCells.add(Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.center,
              color: color,
              child: TeamLink(
                cell.value,
                tournament,
              )))
          : cell.columnName == 'follow_up_status'
              ? returnCells.add(Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  color: color,
                  child: DeathLink(
                      row.getCells()[0].value, tournament, cell.value)))
              : returnCells.add(Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  color: color,
                  child: Text(cell.value.toString(),
                      textScaleFactor: 1.25,
                      style: TextStyle(
                          color: cell.value == 'Incomplete'
                              ? Colors.yellow
                              : cell.value == 'Done'
                                  ? Colors.green
                                  : Colors.red)),
                ));
    }
    return DataGridRowAdapter(
      cells: returnCells,
    );
  }
}

class _MatchStatusSource extends DataGridSource {
  final BuildContext context;
  final List<DataGridRow> rows;
  final Tournament tournament;
  final List<dynamic> statuses;
  _MatchStatusSource(
      BuildContext this.context, this.rows, this.tournament, this.statuses);
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    List<DataGridCell> cells = row.getCells();
    List<Widget> returnCells = [];
    Map<String, dynamic> matchStatus = {};
    for (Map<String, dynamic> status in statuses) {
      if (status['key'].contains('qm')) {
        if (status['key'].split('qm')[1] == cells[0].value.split(' ')[1]) {
          matchStatus = status;
          break;
        }
      }
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
                : 'f1m';
        String match_key = '${tournament.key}_$type$matchNumber';
        if (type == 'sf') match_key = '${tournament.key}_$type${matchNumber}m1';
        returnCells.add(Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.center,
            color: color,
            child: MatchLink(cell.value, match_key, tournament)));
      } else if (cell.columnName == 'blue_rp')
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: matchStatus['predicted'] && matchStatus['blue_win_rp'] == 2
              ? const Color.fromARGB(255, 0, 100, 150)
              : matchStatus['predicted'] && matchStatus['blue_win_rp'] == 0
                  ? color
                  : matchStatus['predicted'] && matchStatus['blue_win_rp'] == 1
                      ? const Color.fromARGB(255, 125, 0, 150)
                      : matchStatus['blue_actual_score'] >
                              matchStatus['red_actual_score']
                          ? const Color.fromARGB(255, 0, 100, 150)
                          : matchStatus['blue_actual_score'] <
                                  matchStatus['red_actual_score']
                              ? color
                              : const Color.fromARGB(255, 125, 0, 150),
          child: Text(
            textScaleFactor: 1.25,
            cell.value.toString(),
          ),
        ));
      else if (cell.columnName == 'red_rp')
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: matchStatus['predicted'] && matchStatus['red_win_rp'] == 2
              ? const Color.fromARGB(255, 140, 10, 0)
              : matchStatus['predicted'] && matchStatus['red_win_rp'] == 0
                  ? color
                  : matchStatus['predicted'] && matchStatus['red_win_rp'] == 1
                      ? const Color.fromARGB(255, 125, 0, 150)
                      : matchStatus['red_actual_score'] >
                              matchStatus['blue_actual_score']
                          ? const Color.fromARGB(255, 140, 10, 0)
                          : matchStatus['red_actual_score'] <
                                  matchStatus['blue_actual_score']
                              ? color
                              : const Color.fromARGB(255, 125, 0, 150),
          child: Text(
            textScaleFactor: 1.25,
            cell.value.toString(),
          ),
        ));
      else if (cell.columnName == 'winner')
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

class _QualsTab extends StatefulWidget {
  final EventPage widget;
  const _QualsTab(this.widget);

  @override
  State<StatefulWidget> createState() {
    return new _QualsTabState();
  }
}

class _QualsTabState extends State<_QualsTab> {
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
          columnName: 'blue_score',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Blue Score',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'red_score',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Red Score',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'blue_rp',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Blue RP',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
      GridColumn(
          columnName: 'red_rp',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Red RP',
                textAlign: TextAlign.center,
                textScaleFactor: 1.25,
              ))),
    ];

    statuses.sort((a, b) {
      return a['match_number'] - b['match_number'];
    });

    dataRows = [
      for (Map<String, dynamic> status in statuses)
        if (status['comp_level'] == 'qm')
          DataGridRow(cells: [
            DataGridCell(
                columnName: 'key',
                value: 'Quals ' + status['match_number'].toString()),
            DataGridCell(
                columnName: 'result_type',
                value: status['predicted'] ? 'Predicted' : 'Result'),
            DataGridCell(
                columnName: 'blue_score',
                value: status['predicted']
                    ? status['blue_score'].toStringAsFixed(0)
                    : status['blue_actual_score']),
            DataGridCell(
                columnName: 'red_score',
                value: status['predicted']
                    ? status['red_score'].toStringAsFixed(0)
                    : status['red_actual_score']),
            DataGridCell(
                columnName: 'blue_rp', value: status['blue_display_rp']),
            DataGridCell(columnName: 'red_rp', value: status['red_display_rp']),
          ])
    ];
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    const columnMinWidth = 110.0;
    bool isWide = MediaQuery.of(context).size.width >=
        dataColumns.length * columnMinWidth;
    return Center(
        child: LayoutBuilder(
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
                    columnWidthMode:
                        isWide ? ColumnWidthMode.fill : ColumnWidthMode.none,
                    frozenColumnsCount: 0,
                    source: _MatchStatusSource(
                        context, dataRows, widget.widget.tournament, statuses),
                  ),
                ))));
  }
}

class _ElimsTab extends StatefulWidget {
  final EventPage widget;
  const _ElimsTab(this.widget);

  @override
  State<StatefulWidget> createState() {
    return new _ElimsTabState();
  }
}

class _ElimsTabState extends State<_ElimsTab> {
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
          columnName: 'winner',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Winner',
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
        if (a['set_number'] - b['set_number'] == 0) {
          return a['match_number'] - b['match_number'];
        } else {
          return a['set_number'] - b['set_number'];
        }
      }
    });

    dataRows = [
      for (Map<String, dynamic> status in statuses)
        if (status['comp_level'] != 'qm')
          DataGridRow(cells: [
            DataGridCell(
                columnName: 'key',
                value: status['comp_level'] == 'sf'
                    ? ('Semi-Finals ' + status['set_number'].toString())
                    : ('Finals ' + status['match_number'].toString())),
            DataGridCell(
                columnName: 'result_type',
                value: status['predicted'] ? 'Predicted' : 'Result'),
            DataGridCell(
                columnName: 'winner',
                value: status['predicted'] && status['blue_win_rp'] == 2
                    ? 'Blue'
                    : status['predicted'] && status['blue_win_rp'] == 0
                        ? 'Red'
                        : status['predicted'] && status['blue_win_rp'] == 1
                            ? 'Tie'
                            : status['blue_actual_score'] >
                                    status['red_actual_score']
                                ? 'Blue'
                                : status['blue_actual_score'] <
                                        status['red_actual_score']
                                    ? 'Red'
                                    : 'Tie'),
          ])
    ];
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    const columnMinWidth = 110.0;
    bool isWide = MediaQuery.of(context).size.width >=
        dataColumns.length * columnMinWidth;
    return Center(
        child: LayoutBuilder(
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
                    columnWidthMode:
                        isWide ? ColumnWidthMode.fill : ColumnWidthMode.none,
                    frozenColumnsCount: 0,
                    source: _MatchStatusSource(
                        context, dataRows, widget.widget.tournament, statuses),
                  ),
                ))));
  }
}

class _AutosTab extends StatefulWidget {
  final EventPage widget;
  const _AutosTab(this.widget);

  @override
  State<StatefulWidget> createState() {
    return _AutosTabState();
  }
}

class _AutosTabState extends State<_AutosTab> {
  List<MatchScouting2024> scoutingData = [];
  bool isLoading = true, farSide = false, closeSide = false;
  int currentPage = 0, scores = 0, pickups = 0;
  static const AUTOS_PER_PAGE = 15;

  @override
  void initState() {
    super.initState();
    fetchData().then((_) => setState(() => {}));
  }

  fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final fetchedData = await apiService.fetchEventScouting(
        int.parse(widget.widget.tournament.page.split('/')[3]),
        widget.widget.tournament.page.split('/')[4],
      );
      if (mounted) {
        setState(() {
          List<MatchScouting2024> newScoutingData = [];
          for (var matchData in fetchedData) {
            dynamic died = matchData['data']['miscellaneous']['died'];
            if (died == 1 || died == true) {
              died = true;
            } else {
              died = false;
            }
            matchData['data']['miscellaneous']['died'] = died;
            newScoutingData.add(MatchScouting2024.fromJson(matchData));
          }
          scoutingData = newScoutingData;
          isLoading = false;
        });
      }
    } catch (e) {
      throw (e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out all of the Data which doesn't follow the form's filters
    List<MatchScouting2024> filteredData = scoutingData.where((entry) {
      if ((entry.data.selectedPieces?.length ?? 0) == 0 &&
          (farSide || closeSide || pickups > 0)) {
        return false;
      }
      if (closeSide) {
        const closeNotes = [
          'spike_left',
          'spike_middle',
          'spike_right',
          'halfway_far_left',
          'halfway_middle_left',
          'halfway_middle',
        ];
        if (!(entry.data.selectedPieces
                ?.any((element) => closeNotes.any((note) => note == element)) ??
            false)) return false;
      }
      if (farSide) {
        const farNotes = [
          'halfway_middle_right',
          'halfway_far_right',
        ];
        if (!(entry.data.selectedPieces
                ?.any((element) => farNotes.any((note) => note == element)) ??
            false)) return false;
      }
      if (entry.data.selectedPieces!.length < pickups) {
        return false;
      }
      int numScores = entry.data.auto.amp + entry.data.auto.speaker;
      if (numScores < scores) {
        return false;
      }
      return true;
    }).toList();
    int numPages = (filteredData.length / AUTOS_PER_PAGE).ceil();
    // make sure we don't map it to a non-existent page
    if (currentPage >= numPages) {
      setState(() => currentPage = numPages - 1);
    }
    if (currentPage < 0) {
      currentPage = 0;
    }
    List<MatchScouting2024> pageData = filteredData.sublist(
      currentPage * AUTOS_PER_PAGE,
      min(filteredData.length, currentPage * AUTOS_PER_PAGE + AUTOS_PER_PAGE),
    );
    int numColumns = 3;
    int numRows = (pageData.length / 3).ceil();
    return Center(
      child: isLoading
          ? CircularProgressIndicator(color: Colors.blue)
          : Column(
              children: [
                if (filteredData.length == 0 && scoutingData.length != 0)
                  Text(
                    'No data with selected filters',
                    style: TextStyle(fontSize: 30),
                  ),
                if (scoutingData.length == 0)
                  Text(
                    'No data for this event',
                    style: TextStyle(fontSize: 30),
                  ),
                Expanded(child: LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                      child: Column(children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Close Autos'),
                            Checkbox(
                              value: closeSide,
                              onChanged: (value) =>
                                  setState(() => closeSide = value ?? false),
                            ),
                            Text('Far Autos'),
                            Checkbox(
                              value: farSide,
                              onChanged: (value) =>
                                  setState(() => farSide = value ?? false),
                            ),
                            SizedBox(height: 16),
                            Counter(
                              label: 'Scores',
                              value: scores,
                              max: 9,
                              onChanged: (value) =>
                                  setState(() => scores = value),
                            ),
                            SizedBox(height: 16),
                            Counter(
                              label: 'Pickups',
                              value: pickups,
                              max: 8,
                              onChanged: (value) =>
                                  setState(() => pickups = value),
                            ),
                          ],
                        ),
                      ),
                    ),
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
