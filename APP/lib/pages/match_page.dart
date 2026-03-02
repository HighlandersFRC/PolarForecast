import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/match_details_2026.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import '../utils.dart';
import '../widgets/auto_display_2026.dart';
import '../widgets/field_whiteboard.dart';
import 'package:scribble/scribble.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../widgets/login_widget.dart';
import '../widgets/polar_forecast_app_bar.dart';
import '../api_service.dart';
import '../models/tournament.dart';
import 'not_found_page.dart';

class MatchPage extends StatefulWidget {
  final Tournament tournament;
  final String match_key;
  final String? display;
  MatchPage(this.match_key, this.tournament, {this.display});

  static Widget fromKeys(
      BuildContext context, String eventKey, String matchKey) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final tournaments = apiService.fetchTournaments();
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
            return MatchPage(
              matchKey,
              tournament,
            );
          } catch (error) {
            return NotFoundPage();
          }
        });
  }

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  int _currentTab = 0;
  late FieldWhiteboard fieldWhiteboard;
  late ScribbleNotifier notifier;
  bool isMobile() {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  openPopup() {
    showModalBottomSheet(
      context: context,
      builder: (context) => fieldWhiteboard,
    );
  }

  @override
  void initState() {
    super.initState();
    notifier = ScribbleNotifier();
    fieldWhiteboard = FieldWhiteboard(
      notifier: notifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> tabs = [
      _StatsTab(widget),
      _RedTab(widget),
      _BlueTab(widget),
    ];
    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: widget.display != null
            ? '${widget.display} - ${widget.tournament.display}'
            : widget.match_key,
      ),
      floatingActionButton: Tooltip(
        message: 'Open Whiteboard',
        child: ElevatedButton(
            onPressed: openPopup,
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(), // Makes the button circular
              padding: EdgeInsets.all(20), // Adds padding to increase the size
            ),
            child: Icon(Icons.draw)),
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
              icon: Icon(Icons.precision_manufacturing_outlined,
                  color: Colors.red.shade900),
              activeIcon: Icon(Icons.precision_manufacturing,
                  color: Colors.red.shade900),
              label: 'Red Autos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.precision_manufacturing_outlined,
                  color: Colors.blue.shade900),
              activeIcon: Icon(Icons.precision_manufacturing,
                  color: Colors.blue.shade900),
              label: 'Blue Autos'),
        ],
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(color: Colors.white, fontFamily: 'Font'),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
      ),
      body: tabs[_currentTab],
    );
  }
}

class _StatsTab extends StatefulWidget {
  final MatchPage widget;
  const _StatsTab(this.widget);

  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  MatchDetails2026? stats;
  Map<String, dynamic> statDescription = {'scoutingData': {}};
  List<DataGridRow> redRows = [];
  List<DataGridRow> blueRows = [];
  List<GridColumn> columns = [
    GridColumn(
        columnName: 'team_number',
        label: Text(
          'Team Number',
          style: TextStyle(fontFamily: 'Font'),
        )),
    GridColumn(
        columnName: 'opr',
        label: Text(
          'OPR',
          style: TextStyle(fontFamily: 'Font'),
        )),
    GridColumn(
      columnName: 'auto_fuel',
      label: Text(
        'Auto Fuel',
        style: TextStyle(fontFamily: 'Font'),
      ),
    ),
    GridColumn(
      columnName: 'tele_fuel',
      label: Text(
        'Teleop Fuel',
        style: TextStyle(fontFamily: 'Font'),
      ),
    ),
    GridColumn(
      columnName: 'auto_pass',
      label: Text(
        'Auto Passing',
        style: TextStyle(fontFamily: 'Font'),
      ),
    ),
    GridColumn(
      columnName: 'tele_pass',
      label: Text(
        'Teleop Passing',
        style: TextStyle(fontFamily: 'Font'),
      ),
    )
  ];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchData().then((_) => updateGrid());
  }

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final fetchedStats = (await apiService.fetchMatchDetails(
      int.parse(widget.widget.tournament.page.split('/')[3]),
      widget.widget.tournament.page.split('/')[4],
      widget.widget.match_key,
    ));
    if (mounted) {
      setState(() {
        stats = fetchedStats;
        isLoading = false;
      });
    }
  }

  updateGrid() {
    if (stats != null) {
      setState(() {
        blueRows = [];
        double blueOPR = 0;
        double blueAutoFuel = 0;
        double blueTeleFuel = 0;
        double blueAutoPass = 0;
        double blueTelePass = 0;
        for (var blueTeam in stats?.blue_teams ?? []) {
          blueOPR += blueTeam.OPR;
          blueAutoFuel += blueTeam.auto_fuel_cycles;
          blueTeleFuel += blueTeam.teleop_fuel_cycles;
          blueAutoPass += blueTeam.auto_pass;
          blueTelePass += blueTeam.teleop_pass;
          blueRows.add(DataGridRow(cells: [
            DataGridCell(
                columnName: 'team_number', value: blueTeam.key.substring(3)),
            DataGridCell(columnName: 'opr', value: blueTeam.OPR),
            DataGridCell(
                columnName: 'auto_fuel', value: blueTeam.auto_fuel_cycles),
            DataGridCell(
                columnName: 'tele_fuel', value: blueTeam.teleop_fuel_cycles),
            DataGridCell(columnName: 'auto_pass', value: blueTeam.auto_pass),
            DataGridCell(columnName: 'tele_pass', value: blueTeam.teleop_pass),
          ]));
        }
        blueRows.add(DataGridRow(cells: [
          DataGridCell(columnName: 'team_number', value: 'Total'),
          DataGridCell(columnName: 'opr', value: blueOPR),
          DataGridCell(columnName: 'auto_fuel', value: blueAutoFuel),
          DataGridCell(columnName: 'tele_fuel', value: blueTeleFuel),
          DataGridCell(columnName: 'auto_pass', value: blueAutoPass),
          DataGridCell(columnName: 'tele_pass', value: blueTelePass),
        ]));
        redRows = [];
        double redOPR = 0;
        double redAutoFuel = 0;
        double redTeleFuel = 0;
        double redAutoPass = 0;
        double redTelePass = 0;
        for (var redTeam in stats?.red_teams ?? []) {
          redOPR += redTeam.OPR;
          redAutoFuel += redTeam.auto_fuel_cycles;
          redTeleFuel += redTeam.teleop_fuel_cycles;
          redAutoPass += redTeam.auto_pass;
          redTelePass += redTeam.teleop_pass;
          redRows.add(DataGridRow(cells: [
            DataGridCell(
                columnName: 'team_number', value: redTeam.key.substring(3)),
            DataGridCell(columnName: 'opr', value: redTeam.OPR),
            DataGridCell(
                columnName: 'auto_fuel', value: redTeam.auto_fuel_cycles),
            DataGridCell(
                columnName: 'tele_fuel', value: redTeam.teleop_fuel_cycles),
            DataGridCell(columnName: 'auto_pass', value: redTeam.auto_pass),
            DataGridCell(columnName: 'tele_pass', value: redTeam.teleop_pass),
          ]));
        }
        redRows.add(DataGridRow(cells: [
          DataGridCell(columnName: 'team_number', value: 'Total'),
          DataGridCell(columnName: 'opr', value: redOPR),
          DataGridCell(columnName: 'auto_fuel', value: redAutoFuel),
          DataGridCell(columnName: 'tele_fuel', value: redTeleFuel),
          DataGridCell(columnName: 'auto_pass', value: redAutoPass),
          DataGridCell(columnName: 'tele_pass', value: redTelePass),
        ]));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(fetchData);
    String formatNum(num? value) => value?.toStringAsFixed(2) ?? 'N/A';
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
            color: Colors.blue,
          ))
        : LayoutBuilder(builder: (context, constraints) {
            return Row(
              children: [
                SingleChildScrollView(
                    child: SizedBox(
                        width: constraints.maxWidth,
                        child: Column(
                          children: [
                            Text(
                              'Blue Alliance',
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.blue,
                                  fontFamily: 'Font'),
                            ),
                            Divider(
                              color: Colors.blue,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Blue Predicted Score: ${formatNum(stats?.prediction?.blue_score)}',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue,
                                  fontFamily: 'Font'),
                            ),
                            if (stats?.prediction?.blue_actual_score != null)
                              Text(
                                'Blue Actual Score: ${stats?.prediction?.blue_actual_score}',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    fontFamily: 'Font'),
                              ),
                            Text(
                              'Blue Predicted RP: ${stats?.prediction?.blue_total_rp}',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue,
                                  fontFamily: 'Font'),
                            ),
                            if (!(stats?.prediction?.predicted ?? true))
                              Text(
                                'Blue Actual RP: ${stats?.prediction?.blue_display_rp}',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    fontFamily: 'Font'),
                              ),
                            SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: 30 * 4 + 50,
                              child: SfDataGrid(
                                columnWidthMode: ColumnWidthMode.fill,
                                source: _StatsTableSource(
                                    blueRows, Colors.blue.shade900),
                                columns: columns,
                                rowHeight: 30,
                                headerRowHeight: 50,
                              ),
                            ),
                            Text(
                              'Red Alliance',
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.red,
                                  fontFamily: 'Font'),
                            ),
                            Divider(
                              color: Colors.red,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Red Predicted Score: ${formatNum(stats?.prediction?.red_score)}',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontFamily: 'Font'),
                            ),
                            if (stats?.prediction?.red_actual_score != null)
                              Text(
                                'Red Actual Score: ${stats?.prediction?.red_actual_score}',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.red,
                                    fontFamily: 'Font'),
                              ),
                            Text(
                              'Red Predicted RP: ${stats?.prediction?.red_total_rp}',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontFamily: 'Font'),
                            ),
                            if (!(stats?.prediction?.predicted ?? true))
                              Text(
                                'Red Actual RP: ${stats?.prediction?.red_display_rp}',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.red,
                                    fontFamily: 'Font'),
                              ),
                            SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: 30 * 4 + 50,
                              child: SfDataGrid(
                                  columnWidthMode: ColumnWidthMode.fill,
                                  source: _StatsTableSource(
                                      redRows, Colors.red.shade900),
                                  headerRowHeight: 50,
                                  rowHeight: 30,
                                  columns: columns),
                            )
                          ],
                        )))
              ],
            );
          });
  }
}

class _StatsTableSource extends DataGridSource {
  final List<DataGridRow> rows;
  final Color color;
  _StatsTableSource(this.rows, this.color);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    List<Widget> cells = [];
    for (var cell in row.getCells()) {
      if (cell.value is num)
        cells.add(Text((cell.value as num).toStringAsFixed(2),
            style: TextStyle(fontFamily: 'Font')));
      else
        cells.add(
            Text(cell.value.toString(), style: TextStyle(fontFamily: 'Font')));
    }
    return DataGridRowAdapter(cells: cells, color: color);
  }
}

class _RedTab extends StatefulWidget {
  final MatchPage widget;

  const _RedTab(this.widget);

  @override
  _RedTabState createState() => _RedTabState();
}

class _RedTabState extends State<_RedTab> {
  bool isLoading = true, r1Loading = true, r2Loading = true, r3Loading = true;
  MatchDetails2026? match;
  String? token;
  List<MatchScouting2026> r1scouting = [];
  List<MatchScouting2026> r2scouting = [];
  List<MatchScouting2026> r3scouting = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.token.then((_token) {
      if (_token != null) {
        if (mounted)
          setState(
            () => this.token = _token,
          );
        apiService
            .fetchMatchDetails(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4],
          widget.widget.match_key,
        )
            .then((_match) {
          if (mounted) {
            setState(() {
              match = _match;
              isLoading = false;
            });
          }
          apiService
              .fetchTeamMatchScouting(
                  int.parse(widget.widget.tournament.key.substring(0, 4)),
                  widget.widget.tournament.key.substring(4),
                  _match.match.alliances.red.team_keys[0])
              .then((_r1scouting) => setState(() {
                    r1scouting = _r1scouting;
                    r1Loading = false;
                  }));
          apiService
              .fetchTeamMatchScouting(
                  int.parse(widget.widget.tournament.key.substring(0, 4)),
                  widget.widget.tournament.key.substring(4),
                  _match.match.alliances.red.team_keys[1])
              .then((_r2scouting) {
            r2scouting = _r2scouting;
            r2Loading = false;
          });
          apiService
              .fetchTeamMatchScouting(
                  int.parse(widget.widget.tournament.key.substring(0, 4)),
                  widget.widget.tournament.key.substring(4),
                  _match.match.alliances.red.team_keys[2])
              .then((_r3scouting) {
            r3scouting = _r3scouting;
            r3Loading = false;
          });
        });
      } else {
        isLoading = false;
        setState(() {
          isLoading = false;
        });
      }
      ;
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
                        '/event/${widget.widget.tournament.key}/match/${widget.widget.match_key}',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) => Row(
                      children: List.generate(3, (i) {
                        List<MatchScouting2026> scouting = [];
                        bool _isLoading = true;
                        switch (i) {
                          case 0:
                            scouting = r1scouting;
                            _isLoading = r1Loading;
                            break;
                          case 1:
                            scouting = r2scouting;
                            _isLoading = r2Loading;
                            break;
                          case 2:
                            scouting = r3scouting;
                            _isLoading = r3Loading;
                            break;
                        }
                        int numColumns = isMobile() ? 1 : 2;
                        int numRows = (scouting.length / numColumns).ceil();
                        return ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth / 3),
                            child: Center(
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.blue)
                                    : Column(children: [
                                        Text(
                                            'Team ${match!.match.alliances.red.team_keys[i].substring(3)}',
                                            style: TextStyle(
                                                fontSize: kToolbarHeight - 20,
                                                color: Colors.red,
                                                fontFamily: 'Font')),
                                        if (scouting.length == 0)
                                          Text(
                                            'No data for this event',
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontFamily: 'Font'),
                                          ),
                                        Expanded(child: LayoutBuilder(
                                            builder: (context, constraints) {
                                          return SingleChildScrollView(
                                              child: Column(children: [
                                            Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: List.generate(
                                                    numColumns, (int colIndex) {
                                                  return ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          maxWidth: constraints
                                                                  .maxWidth /
                                                              numColumns),
                                                      child: Column(
                                                        children: List.generate(
                                                            numRows,
                                                            (int rowIndex) {
                                                          int index = rowIndex *
                                                                  numColumns +
                                                              colIndex;
                                                          if (index <
                                                              scouting.length) {
                                                            return AutoDisplay2026(
                                                              scoutingData:
                                                                  scouting[
                                                                      index],
                                                            );
                                                          }
                                                          return SizedBox
                                                              .shrink();
                                                        }),
                                                      ));
                                                }))
                                          ]));
                                        })),
                                      ])));
                      }),
                    ),
                  ));
  }
}

class _BlueTab extends StatefulWidget {
  final MatchPage widget;

  const _BlueTab(this.widget);

  @override
  _BlueTabState createState() => _BlueTabState();
}

class _BlueTabState extends State<_BlueTab> {
  bool isLoading = true, b1Loading = true, b2Loading = true, b3Loading = true;
  MatchDetails2026? match;
  String? token;
  List<MatchScouting2026> b1scouting = [];
  List<MatchScouting2026> b2scouting = [];
  List<MatchScouting2026> b3scouting = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.token.then((_token) {
      if (_token != null) {
        if (mounted)
          setState(
            () => this.token = _token,
          );

        apiService
            .fetchMatchDetails(
          int.parse(widget.widget.tournament.page.split('/')[3]),
          widget.widget.tournament.page.split('/')[4],
          widget.widget.match_key,
        )
            .then((_match) {
          if (mounted) {
            setState(() {
              match = _match;
              isLoading = false;
            });
          }
          apiService
              .fetchTeamMatchScouting(
                  int.parse(widget.widget.tournament.key.substring(0, 4)),
                  widget.widget.tournament.key.substring(4),
                  _match.match.alliances.blue.team_keys[0])
              .then((_r1scouting) => setState(() {
                    b1scouting = _r1scouting;
                    b1Loading = false;
                  }));
          apiService
              .fetchTeamMatchScouting(
                  int.parse(widget.widget.tournament.key.substring(0, 4)),
                  widget.widget.tournament.key.substring(4),
                  _match.match.alliances.blue.team_keys[1])
              .then((_r2scouting) {
            b2scouting = _r2scouting;
            b2Loading = false;
          });
          apiService
              .fetchTeamMatchScouting(
                  int.parse(widget.widget.tournament.key.substring(0, 4)),
                  widget.widget.tournament.key.substring(4),
                  _match.match.alliances.blue.team_keys[2])
              .then((_r3scouting) {
            b3scouting = _r3scouting;
            b3Loading = false;
          });
        });
      } else {
        isLoading = false;
        setState(() {
          isLoading = false;
        });
      }
      ;
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
                        '/event/${widget.widget.tournament.key}/match/${widget.widget.match_key}',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) => Row(
                      children: List.generate(3, (i) {
                        List<MatchScouting2026> scouting = [];
                        bool _isLoading = true;
                        switch (i) {
                          case 0:
                            scouting = b1scouting;
                            _isLoading = b1Loading;
                            break;
                          case 1:
                            scouting = b2scouting;
                            _isLoading = b2Loading;
                            break;
                          case 2:
                            scouting = b3scouting;
                            _isLoading = b3Loading;
                            break;
                        }
                        int numColumns = isMobile() ? 1 : 2;
                        int numRows = (scouting.length / numColumns).ceil();
                        return ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth / 3),
                            child: Center(
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.blue)
                                    : Column(children: [
                                        Text(
                                            'Team ${match!.match.alliances.blue.team_keys[i].substring(3)}',
                                            style: TextStyle(
                                                fontSize: kToolbarHeight - 20,
                                                color: Colors.blue,
                                                fontFamily: 'Font')),
                                        if (scouting.length == 0)
                                          Text(
                                            'No data for this event',
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontFamily: 'Font'),
                                          ),
                                        Expanded(child: LayoutBuilder(
                                            builder: (context, constraints) {
                                          return SingleChildScrollView(
                                              child: Column(children: [
                                            Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: List.generate(
                                                    numColumns, (int colIndex) {
                                                  return ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          maxWidth: constraints
                                                                  .maxWidth /
                                                              numColumns),
                                                      child: Column(
                                                        children: List.generate(
                                                            numRows,
                                                            (int rowIndex) {
                                                          int index = rowIndex *
                                                                  numColumns +
                                                              colIndex;
                                                          if (index <
                                                              scouting.length) {
                                                            return AutoDisplay2026(
                                                              scoutingData:
                                                                  scouting[
                                                                      index],
                                                            );
                                                          }
                                                          return SizedBox
                                                              .shrink();
                                                        }),
                                                      ));
                                                }))
                                          ]));
                                        })),
                                      ])));
                      }),
                    ),
                  ));
  }
}
