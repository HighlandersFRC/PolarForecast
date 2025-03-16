import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:flat/flat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/main.dart';
import 'package:scouting_app/models/group.dart';
import 'package:scouting_app/models/match_scouting_2025.dart';
import 'package:scouting_app/models/team_stats_2025.dart';
import 'package:scouting_app/pages/not_found_page.dart';
import 'package:scouting_app/utils.dart';
import 'package:scouting_app/widgets/auto_display_2025.dart';
import 'package:scouting_app/widgets/auto_pieces_2025.dart';
import 'package:scouting_app/widgets/pit_scouting_link.dart';
import '../models/match_details_2025.dart';
import '../models/pit_scouting_2025.dart';
import '../widgets/bar_chart_with_weights.dart';
import '../widgets/counter.dart';
import '../widgets/death_link.dart';
import '../widgets/login_widget.dart';
import '../widgets/match_link.dart';
import '../widgets/pictures_link.dart';
import '../widgets/team_link.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../widgets/polar_forecast_app_bar.dart';
import '../api_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/tournament.dart';
import 'home_page.dart';

class EventPage extends StatefulWidget {
  final Tournament tournament;
  static Widget fromEventKey(BuildContext context, String eventKey) {
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
        appBar: PolarForecastAppBar(
          extraText: '${widget.tournament.display}',
        ),
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
        body: tabs[_currentTab]);
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
  List<TeamStats2025> rankings = [];
  bool isLoading = true;
  List<int> teams = [];
  String? token;
  int lastMatch = 1;
  List<GridColumn> dataColumns = [
    GridColumn(
        allowSorting: true,
        label: Text('#'),
        columnName: 'team_number',
        filterPopupMenuOptions: FilterPopupMenuOptions()),
    GridColumn(allowSorting: true, label: Text('OPR'), columnName: 'OPR'),
    GridColumn(
      allowSorting: true,
      label: Text('Rank'),
      columnName: 'rank',
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Sim RPs'),
      columnName: 'simulated_rp',
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Auto Coral Points'),
      columnName: 'auto_coral_points',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Teleop Coral Points'),
      columnName: 'teleop_coral_points',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Net'),
      columnName: 'net',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Processor'),
      columnName: 'processor',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Climb Points'),
      columnName: 'climbing_points',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Deathrate'),
      columnName: 'death_rate',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('AC4'),
      columnName: 'auto_scoring_l_4',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('AC3'),
      columnName: 'auto_scoring_l_3',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('AC2'),
      columnName: 'auto_scoring_l_2',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('AC1'),
      columnName: 'auto_scoring_l_1',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('TC4'),
      columnName: 'teleop_scoring_l_4',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('TC3'),
      columnName: 'teleop_scoring_l_3',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('TC2'),
      columnName: 'teleop_scoring_l_2',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('TC1'),
      columnName: 'teleop_scoring_l_1',
      allowFiltering: false,
    ),
  ];
  Map<String, bool> heatMapFromKey = {
    'team_number': false,
    'OPR': true,
    'rank': true,
    'simulated_rp': true,
    'auto_coral_points': true,
    'teleop_coral_points': true,
    'net': true,
    'processor': true,
    'climbing_points': true,
    'death_rate': true,
    'auto_scoring_l_4': true,
    'auto_scoring_l_3': true,
    'auto_scoring_l_2': true,
    'auto_scoring_l_1': true,
    'teleop_scoring_l_4': true,
    'teleop_scoring_l_3': true,
    'teleop_scoring_l_2': true,
    'teleop_scoring_l_1': true,
  };
  List<MatchScouting2025> scouting = [];
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
                    ? ((rank.toJson()[column.columnName] as num) * 10)
                            .roundToDouble() /
                        10
                    : double.parse(
                        rank.toJson()[column.columnName].toString())));
          } else {
            cells.add(DataGridCell(
              columnName: column.columnName,
              value: (rank.toJson()[column.columnName] is num)
                  ? ((rank.toJson()[column.columnName] as num) * 10)
                          .roundToDouble() /
                      10
                  : rank.toJson()[column.columnName],
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
    try {
      final token = await apiService.token;
      final fetchedRankings = await apiService.fetchEventRankings(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4]);
      if (token != null) {
        final fetchedScouting = await apiService.fetchEventScouting(
            int.parse(widget.widget.tournament.page.split('/')[3]),
            widget.widget.tournament.page.split('/')[4]);
        if (mounted) {
          setState(() {
            rankings = fetchedRankings;
            isLoading = false;
            scouting = fetchedScouting;
            scouting.forEach((entry) {
              if (!teams.contains(entry.team_number))
                teams.add(entry.team_number);
              if (entry.match_number > lastMatch)
                lastMatch = entry.match_number;
            });
            teams.sort((a, b) => a - b);
            this.token = token;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            rankings = fetchedRankings;
            isLoading = false;
            this.token = token;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    const columnMinWidth = 95.0;
    bool isWide = MediaQuery.of(context).size.width >=
        dataColumns.length * columnMinWidth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            List<List<dynamic>> csvData = [
              dataColumns.map((e) => e.columnName).toList()
            ];
            for (var row in dataRows) {
              csvData.add(row.getCells().map((e) => e.value).toList());
            }
            String csv = const ListToCsvConverter().convert(csvData);
            final bytes = utf8.encode(csv);
            final blob = html.Blob([bytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            html.AnchorElement(href: url)
              ..setAttribute('download', '${widget.tournament.display}.csv')
              ..click();
            html.Url.revokeObjectUrl(url);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.blue.shade900, width: 2),
          ),
          child: Text('Export as CSV'),
        ),
        Expanded(
          child: Center(
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
                      heatMapFromKey, context, widget.tournament, scouting),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamDataSource extends DataGridSource {
  _TeamDataSource(this.rows, this.minValues, this.maxValues, this.heatMap,
      this.context, this.tournament, this.scouting);
  final Map<String, dynamic> minValues, maxValues, heatMap;
  final List<DataGridRow> rows;
  final BuildContext context;
  final Tournament tournament;
  final List<MatchScouting2025> scouting;
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
        if (e.columnName == 'OPR') {
          return _OvertimeChartOnClick(
              teamNumber: int.parse(row.getCells()[0].value.toString()),
              color: color,
              opr: e.value,
              scouting: scouting);
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

class _OvertimeChartOnClick extends StatelessWidget {
  final int teamNumber;
  final double opr;
  final Color color;
  final GlobalKey key = GlobalKey();
  final List<MatchScouting2025> scouting;
  _OvertimeChartOnClick(
      {required this.teamNumber,
      required this.color,
      required this.opr,
      required this.scouting});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: color,
          child: Text('${(opr * 10).roundToDouble() / 10}',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ))),
      onTap: () {
        int firstMatch = 0, lastMatch = 1;
        scouting.forEach((entry) {
          if (entry.match_number > lastMatch) lastMatch = entry.match_number;
        });
        double maxY = 1;
        Map<String, List> seriesData = {
          'matches': [],
          'entries': [],
        };
        List<String> seriesLabels = [
          'auto_scoring_l_1',
          'auto_scoring_l_2',
          'auto_scoring_l_3',
          'auto_scoring_l_4',
          'auto_scoring_net',
          'auto_scoring_processor',
          'teleop_scoring_l_1',
          'teleop_scoring_l_2',
          'teleop_scoring_l_3',
          'teleop_scoring_l_4',
          'teleop_scoring_net',
          'teleop_scoring_processor',
        ];
        for (var series in seriesLabels) {
          seriesData[series] = [];
        }
        List<MatchScouting2025> teamScoutingData = [];
        for (var entry in scouting) {
          if (entry.team_number == teamNumber) {
            teamScoutingData.add(entry);
          }
        }
        teamScoutingData.sort((a, b) => a.match_number - b.match_number);
        for (var x in teamScoutingData) {
          var entry = x.toJson();
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
            seriesData['entries']
                ?[seriesData['matches']!.indexOf(entry['match_number'])] += 1;
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
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              shared: true,
            ),
            series: [
              ...seriesData.entries.toList().map((entry) {
                return StackedAreaSeries<double, int>(
                    markerSettings: MarkerSettings(
                        shape: DataMarkerType.circle, isVisible: true),
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
        if (teamScoutingData.length > 0)
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Team $teamNumber Scouting Data'),
                    content: Container(
                      height: 400,
                      width: 800,
                      child: firstChart,
                    ),
                  ));
      },
    );
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
  List<TeamStats2025> rankings = [];
  bool isLoading = true;
  List<MatchScouting2025> scouting = [];
  List<int> teams = [];
  String? token;
  int selectedTeam = 0;
  int secondTeam = 0;
  int lastMatch = 1;
  int firstMatch = 0;
  bool comparing = false;
  bool _hasAdjustedForLandscape = false;

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final token = await apiService.token;
      final fetchedRankings = await apiService.fetchEventRankings(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4]);
      if (token != null) {
        final fetchedScouting = await apiService.fetchEventScouting(
            int.parse(widget.widget.tournament.page.split('/')[3]),
            widget.widget.tournament.page.split('/')[4]);
        if (mounted) {
          setState(() {
            rankings = fetchedRankings;
            isLoading = false;
            scouting = fetchedScouting;
            scouting.forEach((entry) {
              if (!teams.contains(entry.team_number))
                teams.add(entry.team_number);
              if (entry.match_number > lastMatch)
                lastMatch = entry.match_number;
            });
            teams.sort((a, b) => a - b);
            this.token = token;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            rankings = fetchedRankings;
            isLoading = false;
            this.token = token;
          });
        }
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
          Text('Scouting Data By Match',
              style: TextStyle(fontSize: 20, color: Colors.blue)),
          if (token != null && teams.isNotEmpty)
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
              List<MatchScouting2025> teamScoutingData = [];
              if (selectedTeam != 0)
                for (var entry in scouting) {
                  if (entry.team_number == teams[selectedTeam - 1]) {
                    teamScoutingData.add(entry);
                  }
                }
              teamScoutingData.sort((a, b) => a.match_number - b.match_number);
              Map<String, List> seriesData = {
                'matches': [],
                'entries': [],
              };
              List<String> seriesLabels = [
                'auto_scoring_l_1',
                'auto_scoring_l_2',
                'auto_scoring_l_3',
                'auto_scoring_l_4',
                'auto_scoring_net',
                'auto_scoring_processor',
                'teleop_scoring_l_1',
                'teleop_scoring_l_2',
                'teleop_scoring_l_3',
                'teleop_scoring_l_4',
                'teleop_scoring_net',
                'teleop_scoring_processor',
              ];
              for (var series in seriesLabels) {
                seriesData[series] = [];
              }
              for (var x in teamScoutingData) {
                var entry = x.toJson();
                entry['data'].remove('miscellaneous');
                entry['data'].remove('auto');
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
                  seriesData['entries']?[seriesData['matches']!
                      .indexOf(entry['match_number'])] += 1;
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
              List<MatchScouting2025> secondTeamScoutingData = [];
              if (secondTeam != 0)
                for (var entry in scouting) {
                  if (entry.team_number == teams[secondTeam - 1]) {
                    secondTeamScoutingData.add(entry);
                  }
                }
              secondTeamScoutingData
                  .sort((a, b) => a.match_number - b.match_number);
              Map<String, List> secondSeriesData = {
                'matches': [],
                'entries': [],
              };
              for (var series in seriesLabels) {
                secondSeriesData[series] = [];
              }
              for (var x in secondTeamScoutingData) {
                var entry = x.toJson();
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
              List<int> secondEntries = [
                ...?secondSeriesData.remove('entries')
              ];
              List<int> secondMatches = [
                ...?secondSeriesData.remove('matches')
              ];
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
                    sum +=
                        secondSeriesData[label]?[secondMatches.indexOf(match)];
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
                          markerSettings: MarkerSettings(
                              shape: DataMarkerType.circle, isVisible: true),
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
                          markerSettings: MarkerSettings(
                              shape: DataMarkerType.circle, isVisible: true),
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
          if (token == null)
            LoginWidget(redirect_path: 'event/${widget.widget.tournament.key}'),
          if (token != null && teams.isEmpty)
            Padding(
                padding: EdgeInsets.all(20),
                child: Text('No scouting data available for this event')),
          Divider(color: Colors.blue),
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
          Divider(color: Colors.blue),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: BarChartWithWeights(
                  title: 'Coral By Game Period',
                  data: rankings,
                  number: 24,
                  startingFields: [
                    Field(
                        name: 'Teleop Coral',
                        key: 'teleop_coral',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Auto Coral',
                        key: 'auto_coral',
                        enabled: true,
                        weight: 1),
                  ])),
          Divider(color: Colors.blue),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: BarChartWithWeights(
                  title: 'OPR by Game Piece',
                  data: rankings,
                  number: 24,
                  startingFields: [
                    Field(
                        name: 'Coral',
                        key: 'coral_points',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Algae',
                        key: 'algae_points',
                        enabled: true,
                        weight: 1),
                  ])),
          Divider(color: Colors.blue),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: BarChartWithWeights(
                  title: 'Full OPR Breakdown',
                  data: rankings,
                  number: 24,
                  startingFields: [
                    new Field(
                        name: 'AC1',
                        key: 'auto_scoring_l_1',
                        enabled: true,
                        weight: 3),
                    new Field(
                        name: 'AC2',
                        key: 'auto_scoring_l_2',
                        enabled: true,
                        weight: 4),
                    new Field(
                        name: 'AC3',
                        key: 'auto_scoring_l_3',
                        enabled: true,
                        weight: 6),
                    new Field(
                        name: 'AC4',
                        key: 'auto_scoring_l_4',
                        enabled: true,
                        weight: 7),
                    new Field(
                        name: 'TC1',
                        key: 'teleop_scoring_l_1',
                        enabled: true,
                        weight: 2),
                    new Field(
                        name: 'TC2',
                        key: 'teleop_scoring_l_2',
                        enabled: true,
                        weight: 3),
                    new Field(
                        name: 'TC3',
                        key: 'teleop_scoring_l_3',
                        enabled: true,
                        weight: 4),
                    new Field(
                        name: 'TC4',
                        key: 'teleop_scoring_l_4',
                        enabled: true,
                        weight: 5),
                    new Field(
                        name: 'Net', key: 'net', enabled: true, weight: 4),
                    new Field(
                        name: 'Processor',
                        key: 'processor',
                        enabled: true,
                        weight: 2),
                    new Field(
                        name: 'Mobility',
                        key: 'mobility',
                        enabled: true,
                        weight: 3),
                    new Field(
                        name: 'Park', key: 'parking', enabled: true, weight: 2),
                    new Field(
                        name: 'Shallow Climb',
                        key: 'shallow_climb_rate',
                        enabled: true,
                        weight: 6),
                    new Field(
                        name: 'Deep Climb',
                        key: 'deep_climb_rate',
                        enabled: true,
                        weight: 12),
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
  State<StatefulWidget> createState() => _MatchScoutingTabState();
}

class _MatchScoutingTabState extends State<_MatchScoutingTab> {
  late final TextEditingController eventCodeController,
      teamNumberController,
      matchNumberController,
      scoutNameController,
      commentsController;
  late final ScrollController scrollController;
  int driverStationIndex = -1;
  String? token;
  List<String> selectedPieces = [];
  MatchDetails2025? matchDetails = null;
  List<Group>? groups;
  bool loading = true, submitted = false;
  late MatchScouting2025 data = MatchScouting2025(
      event_code: widget.widget.tournament.key,
      team_number: 0,
      match_number: 0,
      scout_info: get_scout_info(token ?? ''),
      data: Data(
          auto: Auto2025(
            starting_position_meters_from_processor: 0,
            steps: [],
            field_side: ['red', 'blue'],
            exit: false,
            preload: false,
            both_sides: false,
          ),
          auto_scoring:
              AutoScoring(l_1: 0, l_2: 0, l_3: 0, l_4: 0, net: 0, processor: 0),
          teleop_scoring: TeleopScoring(
              l_1: 0, l_2: 0, l_3: 0, l_4: 0, net: 0, processor: 0),
          miscellaneous: Miscellaneous(died: false, comments: '')),
      time: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);

  @override
  initState() {
    super.initState();
    eventCodeController =
        TextEditingController(text: widget.widget.tournament.key);
    teamNumberController =
        TextEditingController(text: data.team_number.toString());
    matchNumberController =
        TextEditingController(text: data.match_number.toString());
    scoutNameController =
        TextEditingController(text: data.scout_info.first_name.toString());
    commentsController = TextEditingController(
        text: data.data.miscellaneous.comments.toString());
    scrollController = ScrollController();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.token.then((_token) {
      if (_token == null) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        loading = false;
      } else {
        if (mounted) {
          setState(() {
            data = data.copyWith(scout_info: get_scout_info(_token));
            scoutNameController.text = data.scout_info.first_name ?? '';
          });
        }
        data = data.copyWith(scout_info: get_scout_info(_token));
        scoutNameController.text = data.scout_info.first_name ?? '';
        apiService.get_user_groups_detailed().then((_groups) {
          if (mounted) {
            setState(() {
              groups = _groups;
              loading = false;
            });
          }
          groups = _groups;
          // print(groups);
          loading = false;
        }).onError((e, stackTrace) {
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
          loading = false;
        });
      }
      if (mounted) {
        setState(() {
          token = _token;
        });
      }
      token = _token;
    }).onError((e, stackTrace) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      loading = false;
    });
  }

  getNewMatchDetails(int matchNumber) {
    if (matchNumber <= 0) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService
        .fetchMatchDetails(
      int.parse(widget.widget.tournament.key.substring(0, 4)),
      widget.widget.tournament.key.substring(4),
      '${widget.widget.tournament.key}_qm$matchNumber',
    )
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
    if (matchDetails == null) return;
    List<String> teams = [
      ...matchDetails!.match.alliances.red.team_keys,
      ...matchDetails!.match.alliances.blue.team_keys,
    ];
    String team = '';
    int index = driverStationIndex - 1;
    if (driverStationIndex - 1 > -1) {
      team = teams[driverStationIndex - 1];
    } else {
      index = Random().nextInt(6);
      team = teams[index];
    }
    teamNumberController.text = team.substring(3);
    data = data.copyWith(
        team_number: int.parse(team.substring(3)),
        data: data.data.copyWith(
            auto: data.data.auto
                .copyWith(field_side: [index < 3 ? 'red' : 'blue'])));
  }
  // TODO: When adding offline use this for qr generation
  // String _generateQRCodeData() {
  //   try {
  //     return jsonEncode(data.toJson());
  //   } catch (e) {
  //     print('Error generating QR code data: $e');
  //     return '';
  //   }
  // }

  void _submit() {
    HapticFeedback.heavyImpact();
    ApiService api = Provider.of<ApiService>(context, listen: false);
    api.post_match_scouting(data).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Submitted Successfully')));
      setState(() {
        submitted = true;
      });
    }).onError((error, trace) {
      if (error.toString() == 'Exception: update') {
        setState(() {
          submitted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'You have already submitted this match. Do you want to update?')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });
  }

  void _update() {
    HapticFeedback.heavyImpact();
    ApiService api = Provider.of<ApiService>(context, listen: false);
    api.update_match_scouting(data).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Submitted Successfully')));
      setState(() {
        submitted = true;
      });
    }).onError((error, trace) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    MatchScouting2025 reset = data.copyWith(
        match_number: data.match_number + 1,
        data: Data(
            auto: Auto2025(
              starting_position_meters_from_processor: 0,
              steps: [],
              field_side: ['red', 'blue'],
              exit: false,
              preload: false,
              both_sides: false,
            ),
            auto_scoring: AutoScoring(
                l_1: 0, l_2: 0, l_3: 0, l_4: 0, net: 0, processor: 0),
            teleop_scoring: TeleopScoring(
                l_1: 0, l_2: 0, l_3: 0, l_4: 0, net: 0, processor: 0),
            miscellaneous: Miscellaneous(died: false, comments: '')),
        time: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
    setState(() {
      data = reset;
      submitted = false;
    });
    commentsController.text = data.data.miscellaneous.comments;
    matchNumberController.text = data.match_number.toString();
    getNewMatchDetails(data.match_number);
    scrollController.animateTo(-scrollController.offset,
        duration: Duration(seconds: 3), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const List<String> DRIVER_STATIONS = [
      'None',
      'Red 1',
      'Red 2',
      'Red 3',
      'Blue 1',
      'Blue 2',
      'Blue 3'
    ];
    scoutNameController.text = data.scout_info.first_name ?? '';
    return loading
        ? Center(
            child: CircularProgressIndicator(
            color: theme.primaryColor,
          ))
        : token == null
            ? Center(
                child: LoginWidget(
                    redirect_path: 'event/${widget.widget.tournament.key}'))
            : SingleChildScrollView(
                controller: scrollController,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.widget.tournament.display,
                          style: TextStyle(color: Colors.blue, fontSize: 24),
                        ),
                        Divider(color: Colors.blue),
                        SizedBox(height: 8),
                        TextField(
                          controller: eventCodeController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Event Code',
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: scoutNameController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Scout Name',
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: matchNumberController,
                          enabled: true,
                          decoration: InputDecoration(
                            labelText: 'Match Number',
                          ),
                          onChanged: (value) {
                            int matchNumber = int.tryParse(value) ?? -1;
                            if (matchNumber >= 0 && matchNumber < 500) {
                              setState(() => data =
                                  data.copyWith(match_number: matchNumber));
                              getNewMatchDetails(matchNumber);
                            } else {
                              if (matchNumber < 0) {
                                teamNumberController.text = '0';
                              } else {
                                teamNumberController.text = '499';
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: teamNumberController,
                          enabled: true,
                          decoration: InputDecoration(
                            labelText: 'Team Number',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            int teamNumber = int.tryParse(value) ?? -1;
                            if (teamNumber >= 0 && teamNumber < 20000) {
                              setState(() => data =
                                  data.copyWith(team_number: teamNumber));
                            } else {
                              if (teamNumber < 0) {
                                teamNumberController.text = '0';
                              } else {
                                teamNumberController.text = '19999';
                              }
                            }
                          },
                        ),
                        SizedBox(height: 8),
                        DropdownButton<int>(
                          value: driverStationIndex == -1
                              ? null
                              : driverStationIndex,
                          hint: Text('Select Driver Station',
                              style: TextStyle(color: Colors.white)),
                          onChanged: (int? value) {
                            setState(() {
                              driverStationIndex = value!;
                              if (value == 0) {
                                data = data.copyWith(
                                    data: data.data.copyWith(
                                        auto: data.data.auto.copyWith(
                                            field_side: ['red', 'blue'])));
                              } else if (value < 4) {
                                data = data.copyWith(
                                    data: data.data.copyWith(
                                        auto: data.data.auto
                                            .copyWith(field_side: ['red'])));
                              } else if (value > 3) {
                                data = data.copyWith(
                                    data: data.data.copyWith(
                                        auto: data.data.auto
                                            .copyWith(field_side: ['blue'])));
                              }
                            });
                            getNewMatchDetails(data.match_number);
                          },
                          items: List.generate(
                            DRIVER_STATIONS.length,
                            (index) => DropdownMenuItem<int>(
                              value: index,
                              child: Text(DRIVER_STATIONS[index],
                                  style: TextStyle(
                                      color: index == 0
                                          ? Colors.white
                                          : index < 4
                                              ? Colors.red
                                              : Colors.blue)),
                            ),
                          ),
                          isExpanded: true,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Auto',
                          style: TextStyle(color: Colors.blue, fontSize: 24),
                        ),
                        Divider(color: Colors.blue),
                        AutoPieces2025(
                          auto: data.data.auto,
                          onChanged: (newAuto) {
                            setState(() {
                              int l1 = newAuto.steps.where((item) {
                                return item.name == 'place_coral' &&
                                    item.extra_data['position']
                                        .toString()
                                        .contains('1');
                              }).length;
                              int l2 = newAuto.steps.where((item) {
                                return item.name == 'place_coral' &&
                                    item.extra_data['position']
                                        .toString()
                                        .contains('2');
                              }).length;
                              int l3 = newAuto.steps.where((item) {
                                return item.name == 'place_coral' &&
                                    item.extra_data['position']
                                        .toString()
                                        .contains('3');
                              }).length;
                              int l4 = newAuto.steps.where((item) {
                                return item.name == 'place_coral' &&
                                    item.extra_data['position']
                                        .toString()
                                        .contains('4');
                              }).length;
                              int net = newAuto.steps.where((item) {
                                return item.name == 'net_algae';
                              }).length;
                              int processor = newAuto.steps.where((item) {
                                return item.name == 'processor';
                              }).length;
                              data = data.copyWith(
                                  data: data.data.copyWith(
                                      auto: newAuto,
                                      auto_scoring: AutoScoring(
                                          l_1: l1,
                                          l_2: l2,
                                          l_3: l3,
                                          l_4: l4,
                                          net: net,
                                          processor: processor)));
                            });
                          },
                          matchScouting: true,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Teleop',
                          style: TextStyle(color: Colors.blue, fontSize: 24),
                        ),
                        Divider(color: Colors.blue),
                        SizedBox(height: 8),
                        Counter(
                          label: 'L4',
                          value: data.data.teleop_scoring.l_4,
                          max: 12,
                          onChanged: (value) => setState(() {
                            data = data.copyWith(
                                data: data.data.copyWith(
                                    teleop_scoring: data.data.teleop_scoring
                                        .copyWith(l_4: value)));
                          }),
                        ),
                        SizedBox(height: 8),
                        Counter(
                          label: 'L3',
                          value: data.data.teleop_scoring.l_3,
                          max: 12,
                          onChanged: (value) => setState(() {
                            data = data.copyWith(
                                data: data.data.copyWith(
                                    teleop_scoring: data.data.teleop_scoring
                                        .copyWith(l_3: value)));
                          }),
                        ),
                        SizedBox(height: 8),
                        Counter(
                          label: 'L2',
                          value: data.data.teleop_scoring.l_2,
                          max: 12,
                          onChanged: (value) => setState(() {
                            data = data.copyWith(
                                data: data.data.copyWith(
                                    teleop_scoring: data.data.teleop_scoring
                                        .copyWith(l_2: value)));
                          }),
                        ),
                        SizedBox(height: 8),
                        Counter(
                          label: 'L1',
                          value: data.data.teleop_scoring.l_1,
                          max: 60,
                          onChanged: (value) => setState(() {
                            data = data.copyWith(
                                data: data.data.copyWith(
                                    teleop_scoring: data.data.teleop_scoring
                                        .copyWith(l_1: value)));
                          }),
                        ),
                        SizedBox(height: 8),
                        Counter(
                          label: 'Net',
                          value: data.data.teleop_scoring.net,
                          max: 18,
                          onChanged: (value) => setState(() {
                            data = data.copyWith(
                                data: data.data.copyWith(
                                    teleop_scoring: data.data.teleop_scoring
                                        .copyWith(net: value)));
                          }),
                        ),
                        SizedBox(height: 8),
                        Counter(
                          label: 'Processor',
                          value: data.data.teleop_scoring.processor,
                          max: 60,
                          onChanged: (value) => setState(() {
                            data = data.copyWith(
                                data: data.data.copyWith(
                                    teleop_scoring: data.data.teleop_scoring
                                        .copyWith(processor: value)));
                          }),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Miscellaneous',
                          style: TextStyle(color: Colors.blue, fontSize: 24),
                        ),
                        Divider(color: Colors.blue),
                        SizedBox(height: 8),
                        Text('Died?'),
                        Switch(
                          value: data.data.miscellaneous.died,
                          onChanged: (value) => setState(() {
                            HapticFeedback.lightImpact();
                            data = data.copyWith(
                                data: data.data.copyWith(
                                    miscellaneous: data.data.miscellaneous
                                        .copyWith(died: value)));
                          }),
                          activeColor: Colors.blue,
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: commentsController,
                          enabled: true,
                          decoration: InputDecoration(
                              labelText: 'Comments',
                              helperText:
                                  'Do not type anything which could upset someone.',
                              helperMaxLines: 2),
                          onChanged: (val) {
                            setState(() {
                              data = data.copyWith(
                                  data: data.data.copyWith(
                                      miscellaneous: data.data.miscellaneous
                                          .copyWith(comments: val)));
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: submitted ? _update : _submit,
                            child: Text(submitted ? 'Update' : 'Submit'),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        if (submitted)
                          Center(
                            child: ElevatedButton(
                              onPressed: _reset,
                              child: Text('Reset'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
  }
}

const List<String> DRIVER_STATIONS = [
  'Red 1',
  'Red 2',
  'Red 3',
  'Blue 1',
  'Blue 2',
  'Blue 3',
];

class _PitScoutingTab extends StatefulWidget {
  final EventPage widget;
  const _PitScoutingTab(this.widget);

  @override
  State<StatefulWidget> createState() {
    return new _PitScoutingTabState();
  }
}

class _PitScoutingTabState extends State<_PitScoutingTab> with RouteAware {
  List<GridColumn> dataColumns = [];
  List<DataGridRow> dataRows = [];
  List<dynamic> statuses = [];
  String? token;
  bool isLoading = true;
  bool hasGoodGroup = true;

  @override
  void initState() {
    super.initState();
    updateGrid();
    fetchData().then((_) => updateGrid());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MainApp.observer
        .subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void didPopNext() {
    fetchData().then((_) => updateGrid());
  }

  @override
  void dispose() {
    MainApp.observer.unsubscribe(this);
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      token = await apiService.token;
      if (token != null) {
        try {
          final fetchedStatus = await apiService.fetchPitStatus(
              int.parse(widget.widget.tournament.page.split('/')[3]),
              widget.widget.tournament.page.split('/')[4]);
          if (mounted) {
            setState(() {
              statuses = fetchedStatus;
              isLoading = false;
              updateGrid();
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false;
            hasGoodGroup = false;
          });
        }
      } else {
        setState(() {});
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
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'pit_status',
          allowSorting: true,
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Pit Scouting',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'picture_status',
          allowSorting: true,
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Pictures',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'follow_up_status',
          allowSorting: true,
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Follow Up',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
    ];

    statuses.sort((a, b) => int.parse(a['key']).compareTo(int.parse(b['key'])));

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
    const columnMinWidth = 175.0;
    bool isWide = MediaQuery.of(context).size.width >=
        dataColumns.length * columnMinWidth;

    return Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.blue)
            : token == null
                ? LoginWidget(
                    redirect_path: 'event/${widget.widget.tournament.key}')
                : !hasGoodGroup
                    ? Card(
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child:
                                Text('Your Group is not part of this event')))
                    : LayoutBuilder(
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
                                columnWidthMode: isWide
                                    ? ColumnWidthMode.fill
                                    : ColumnWidthMode.none,
                                frozenColumnsCount: 0,
                                source: _StatusSource(context, dataRows,
                                    widget.widget.tournament),
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
          : cell.columnName == 'pit_status'
              ? returnCells.add(Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  color: color,
                  child: PitScoutingLink(
                      row.getCells()[0].value, tournament, cell.value)))
              : cell.columnName == 'picture_status'
                  ? returnCells.add(Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.center,
                      color: color,
                      child: PicturesLink(
                          row.getCells()[0].value, tournament, cell.value)))
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
                              textScaler: TextScaler.linear(1.25),
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
          color: matchStatus['predicted'] && matchStatus['blue_win_rp'] == 3
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
            textScaler: TextScaler.linear(1.25),
            cell.value.toString(),
          ),
        ));
      else if (cell.columnName == 'red_rp')
        returnCells.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: matchStatus['predicted'] && matchStatus['red_win_rp'] == 3
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
            textScaler: TextScaler.linear(1.25),
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
          columnName: 'blue_score',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Blue Score',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'red_score',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Red Score',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'blue_rp',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Blue RP',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
              ))),
      GridColumn(
          columnName: 'red_rp',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Red RP',
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.25),
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
    const columnMinWidth = 150.0;
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
          columnName: 'winner',
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Winner',
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
    const columnMinWidth = 175.0;
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
  List<MatchScouting2025> scoutingData = [];
  bool isLoading = true, farSide = false, closeSide = false;
  int currentPage = 0, scores = 0, pickups = 0;
  static const AUTOS_PER_PAGE = 15;
  String? token;
  @override
  void initState() {
    super.initState();
    fetchData().then((_) => setState(() => {}));
  }

  fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      token = await apiService.token;
      if (token != null) {
        final fetchedData = await apiService.fetchEventScouting(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4],
        );
        if (mounted) {
          setState(() {
            scoutingData = fetchedData;
            isLoading = false;
            token = token;
          });
        }
      } else {
        if (mounted)
          setState(() {
            isLoading = false;
            token = token;
          });
      }
    } catch (e) {
      throw (e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out all of the Data which doesn't follow the form's filters
    List<MatchScouting2025> filteredData = scoutingData;
    // TODO add auto filtration
    // .where((entry) {
    //   if ((entry.data.selectedPieces?.length ?? 0) == 0 &&
    //       (farSide || closeSide || pickups > 0)) {
    //     return false;
    //   }
    //   if (closeSide) {
    //     const closeNotes = [
    //       'spike_left',
    //       'spike_middle',
    //       'spike_right',
    //       'halfway_far_left',
    //       'halfway_middle_left',
    //       'halfway_middle',
    //     ];
    //     if (!(entry.data.selectedPieces
    //             ?.any((element) => closeNotes.any((note) => note == element)) ??
    //         false)) return false;
    //   }
    //   if (farSide) {
    //     const farNotes = [
    //       'halfway_middle_right',
    //       'halfway_far_right',
    //     ];
    //     if (!(entry.data.selectedPieces
    //             ?.any((element) => farNotes.any((note) => note == element)) ??
    //         false)) return false;
    //   }
    //   if (entry.data.selectedPieces!.length < pickups) {
    //     return false;
    //   }
    //   int numScores = entry.data.auto.amp + entry.data.auto.speaker;
    //   if (numScores < scores) {
    //     return false;
    //   }
    //   return true;
    // }).toList();
    int numPages = (filteredData.length / AUTOS_PER_PAGE).ceil();
    // make sure we don't map it to a non-existent page
    if (currentPage >= numPages) {
      setState(() => currentPage = numPages - 1);
    }
    if (currentPage < 0) {
      currentPage = 0;
    }
    List<MatchScouting2025> pageData = filteredData.sublist(
      currentPage * AUTOS_PER_PAGE,
      min(filteredData.length, currentPage * AUTOS_PER_PAGE + AUTOS_PER_PAGE),
    );
    return Center(
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.blue,
            ))
          : token == null
              ? Center(
                  child: LoginWidget(
                      redirect_path: 'event/${widget.widget.tournament.key}'))
              : Column(
                  children: [
                    Text(
                      'Filtering Coming Soon...',
                      style: TextStyle(color: Colors.blue, fontSize: 30),
                    ),
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
                    Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
                      int numColumns = constraints.maxWidth < 500 ? 1 : 2;
                      int numRows = (pageData.length / numColumns).ceil();
                      return SingleChildScrollView(
                          child: Column(children: [
                        // Card(
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   elevation: 5,
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(16),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text('Close Autos'),
                        //         Checkbox(
                        //           value: closeSide,
                        //           onChanged: (value) =>
                        //               setState(() => closeSide = value ?? false),
                        //         ),
                        //         Text('Far Autos'),
                        //         Checkbox(
                        //           value: farSide,
                        //           onChanged: (value) =>
                        //               setState(() => farSide = value ?? false),
                        //         ),
                        //         SizedBox(height: 16),
                        //         Counter(
                        //           label: 'Scores',
                        //           value: scores,
                        //           max: 9,
                        //           onChanged: (value) =>
                        //               setState(() => scores = value),
                        //         ),
                        //         SizedBox(height: 16),
                        //         Counter(
                        //           label: 'Pickups',
                        //           value: pickups,
                        //           max: 8,
                        //           onChanged: (value) =>
                        //               setState(() => pickups = value),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
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
