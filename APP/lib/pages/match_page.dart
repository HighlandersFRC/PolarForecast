import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/field_whiteboard.dart';
import 'package:scribble/scribble.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../widgets/auto_display_2024.dart';
import '../widgets/polar_forecast_app_bar.dart';
import '../api_service.dart';
import '../models/match_details_2024.dart';
import '../models/match_scouting_2024.dart';
import '../models/tournament.dart';

class MatchPage extends StatefulWidget {
  final Tournament tournament;
  final String match_key;
  final String? display;
  MatchPage(this.match_key, this.tournament, {this.display});

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
                  color: Colors.red),
              activeIcon:
                  Icon(Icons.precision_manufacturing, color: Colors.red),
              label: 'Red Autos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.precision_manufacturing_outlined,
                  color: Colors.blue),
              activeIcon:
                  Icon(Icons.precision_manufacturing, color: Colors.blue),
              label: 'Blue Autos'),
        ],
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black),
        selectedItemColor:
            theme.brightness == Brightness.dark ? Colors.white : Colors.black,
        unselectedItemColor:
            theme.brightness == Brightness.dark ? Colors.white : Colors.black,
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
  MatchDetails2024? stats;
  Map<String, dynamic> statDescription = {'scoutingData': {}};
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchData().then((_) => updateGrid());
  }

  Future<void> fetchData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
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
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  updateGrid() {}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: []),
    );
  }
}

class _StatsTableSource extends DataGridSource {
  final List<DataGridRow> rows;
  _StatsTableSource(this.rows);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    // TODO: implement buildRow
    throw UnimplementedError();
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
  MatchDetails2024? match;
  List<MatchScouting2024> r1scouting = [];
  List<MatchScouting2024> r2scouting = [];
  List<MatchScouting2024> r3scouting = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() {
    final apiService = Provider.of<ApiService>(context, listen: false);
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
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.blue)
            : LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: List.generate(3, (i) {
                    List<MatchScouting2024> scouting = [];
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
                        constraints:
                            BoxConstraints(maxWidth: constraints.maxWidth / 3),
                        child: Center(
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.blue)
                                : Column(children: [
                                    Text(
                                        'Team ${match!.match.alliances.red.team_keys[i].substring(3)}',
                                        style: TextStyle(
                                            fontSize: kToolbarHeight - 20,
                                            color: Colors.red)),
                                    if (scouting.length == 0)
                                      Text(
                                        'No data for this event',
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    Expanded(child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SingleChildScrollView(
                                          child: Column(children: [
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: List.generate(numColumns,
                                                (int colIndex) {
                                              return ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          constraints.maxWidth /
                                                              numColumns),
                                                  child: Column(
                                                    children:
                                                        List.generate(numRows,
                                                            (int rowIndex) {
                                                      int index = rowIndex *
                                                              numColumns +
                                                          colIndex;
                                                      if (index <
                                                          scouting.length) {
                                                        return AutoDisplay2024(
                                                          scoutingData:
                                                              scouting[index],
                                                        );
                                                      }
                                                      return SizedBox.shrink();
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
  MatchDetails2024? match;
  List<MatchScouting2024> b1scouting = [];
  List<MatchScouting2024> b2scouting = [];
  List<MatchScouting2024> b3scouting = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() {
    final apiService = Provider.of<ApiService>(context, listen: false);
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
                b1scouting = _r1scouting;
                b1Loading = false;
              }));
      apiService
          .fetchTeamMatchScouting(
              int.parse(widget.widget.tournament.key.substring(0, 4)),
              widget.widget.tournament.key.substring(4),
              _match.match.alliances.red.team_keys[1])
          .then((_r2scouting) {
        b2scouting = _r2scouting;
        b2Loading = false;
      });
      apiService
          .fetchTeamMatchScouting(
              int.parse(widget.widget.tournament.key.substring(0, 4)),
              widget.widget.tournament.key.substring(4),
              _match.match.alliances.red.team_keys[2])
          .then((_r3scouting) {
        b3scouting = _r3scouting;
        b3Loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.blue)
            : LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: List.generate(3, (i) {
                    List<MatchScouting2024> scouting = [];
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
                        constraints:
                            BoxConstraints(maxWidth: constraints.maxWidth / 3),
                        child: Center(
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.blue)
                                : Column(children: [
                                    Text(
                                        'Team ${match!.match.alliances.red.team_keys[i].substring(3)}',
                                        style: TextStyle(
                                            fontSize: kToolbarHeight - 20,
                                            color: Colors.blue)),
                                    if (scouting.length == 0)
                                      Text(
                                        'No data for this event',
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    Expanded(child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SingleChildScrollView(
                                          child: Column(children: [
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: List.generate(numColumns,
                                                (int colIndex) {
                                              return ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          constraints.maxWidth /
                                                              numColumns),
                                                  child: Column(
                                                    children:
                                                        List.generate(numRows,
                                                            (int rowIndex) {
                                                      int index = rowIndex *
                                                              numColumns +
                                                          colIndex;
                                                      if (index <
                                                          scouting.length) {
                                                        return AutoDisplay2024(
                                                          scoutingData:
                                                              scouting[index],
                                                        );
                                                      }
                                                      return SizedBox.shrink();
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
