import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/match_details_2026.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:url_launcher/url_launcher.dart';
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
      _TBATab(widget)
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
          BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined, color: Colors.blue),
              activeIcon: Icon(Icons.shield, color: Colors.blue),
              label: 'TBAVideo')
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

class _TBATab extends StatefulWidget {
  final MatchPage widget;
  const _TBATab(this.widget);

  @override
  _TBATabState createState() => _TBATabState();
}

class _TBATabState extends State<_TBATab> {
  late final String tbaUrl;

  @override
  void initState() {
    super.initState();
    tbaUrl = 'https://www.thebluealliance.com/match/${widget.widget.match_key}';
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
                  "View Match on The Blue Alliance",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Font',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  widget.widget.match_key,
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
                    label: const Text("Open Match"),
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

class _StatsTab extends StatefulWidget {
  final MatchPage widget;
  const _StatsTab(this.widget);

  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  MatchDetails2026? stats;
  String? _hoveredAlliance;
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
        for (var blueTeam in stats?.blue_teams ?? []) {
          blueOPR += blueTeam.OPR;
          blueAutoFuel += blueTeam.auto_fuel_scored;
          blueTeleFuel += blueTeam.teleop_fuel_scored;
          blueRows.add(DataGridRow(cells: [
            DataGridCell(
                columnName: 'team_number', value: blueTeam.key.substring(3)),
            DataGridCell(columnName: 'opr', value: blueTeam.OPR),
            DataGridCell(
                columnName: 'auto_fuel', value: blueTeam.auto_fuel_scored),
            DataGridCell(
                columnName: 'tele_fuel', value: blueTeam.teleop_fuel_scored),
          ]));
        }
        blueRows.add(DataGridRow(cells: [
          DataGridCell(columnName: 'team_number', value: 'Total'),
          DataGridCell(columnName: 'opr', value: blueOPR),
          DataGridCell(columnName: 'auto_fuel', value: blueAutoFuel),
          DataGridCell(columnName: 'tele_fuel', value: blueTeleFuel),
        ]));
        redRows = [];
        double redOPR = 0;
        double redAutoFuel = 0;
        double redTeleFuel = 0;
        for (var redTeam in stats?.red_teams ?? []) {
          redOPR += redTeam.OPR;
          redAutoFuel += redTeam.auto_fuel_scored;
          redTeleFuel += redTeam.teleop_fuel_scored;
          redRows.add(DataGridRow(cells: [
            DataGridCell(
                columnName: 'team_number', value: redTeam.key.substring(3)),
            DataGridCell(columnName: 'opr', value: redTeam.OPR),
            DataGridCell(
                columnName: 'auto_fuel', value: redTeam.auto_fuel_scored),
            DataGridCell(
                columnName: 'tele_fuel', value: redTeam.teleop_fuel_scored),
          ]));
        }
        redRows.add(DataGridRow(cells: [
          DataGridCell(columnName: 'team_number', value: 'Total'),
          DataGridCell(columnName: 'opr', value: redOPR),
          DataGridCell(columnName: 'auto_fuel', value: redAutoFuel),
          DataGridCell(columnName: 'teleop_fuel', value: redTeleFuel),
        ]));
      });
    }
  }

  Widget _buildAllianceCard({
    required String title,
    required Color color,
    required String predictedScore,
    required String predictedRP,
    String? actualScore,
    String? actualRP,
    required List<DataGridRow> rows,
    required bool isWinner,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredAlliance = title),
      onExit: (_) => setState(() => _hoveredAlliance = null),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _hoveredAlliance == title ? 1.015 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: scheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
              if (isWinner)
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 50,
                  spreadRadius: 4,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───── HEADER ─────
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontFamily: 'Font',
                    ),
                  ),
                  const Spacer(),
                  if (actualScore != null) _resultBadge(isWinner, color),
                ],
              ),

              const SizedBox(height: 34),

              // ───── PREDICTIONS ─────
              _sectionLabel('Predictions'),
              const SizedBox(height: 14),
              _statsBlock(
                color,
                [
                  _animatedStat('Score', predictedScore.toString(), color),
                  _animatedStat('Ranking Points', predictedRP, color),
                ],
              ),

              if (actualScore != null) ...[
                const SizedBox(height: 32),

                // ───── ACTUAL RESULTS ─────
                _sectionLabel('Actual Results'),
                const SizedBox(height: 14),
                _statsBlock(
                  color,
                  [
                    _animatedStat('Score', actualScore, color),
                    if (actualRP != null)
                      _animatedStat('Ranking Points', actualRP, color),
                  ],
                ),
              ],

              const SizedBox(height: 36),

              // ───── RESPONSIVE DATA GRID ─────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobileScreen =
                      MediaQuery.of(context).size.width < 900;
                  final gridHeight = constraints.maxWidth < 700 ? 220.0 : 400.0;

                  Widget table = Container(
                    height: gridHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: scheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SfDataGridTheme(
                        data: SfDataGridThemeData(
                          headerColor: scheme.surfaceContainerHighest,
                          selectionColor: color.withOpacity(0.10),
                          rowHoverColor: scheme.primary.withOpacity(0.04),
                          gridLineColor: color,
                        ),
                        child: SfDataGrid(
                          source: _StatsTableSource(rows, color, scheme),
                          columns: columns,
                          columnWidthMode: isMobileScreen
                              ? ColumnWidthMode.auto
                              : ColumnWidthMode.fill, // fill on desktop
                          rowHeight: 64,
                          headerRowHeight: 64,
                          gridLinesVisibility: GridLinesVisibility.none,
                          headerGridLinesVisibility: GridLinesVisibility.none,
                          highlightRowOnHover: true,
                        ),
                      ),
                    ),
                  );

                  if (isMobileScreen) {
                    // Scroll horizontally only on mobile
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 400, // fixed width for mobile
                        child: table,
                      ),
                    );
                  } else {
                    // Full width for desktop
                    return SizedBox(
                      width: double.infinity, // full screen width
                      child: table,
                    );
                  }
                },
              )
              // 67
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsBlock(Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }

  Widget _animatedStat(String label, String value, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            value,
            key: ValueKey(value),
            style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: accent,
                fontFamily: 'Font'),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              fontFamily: 'Font'),
        ),
      ],
    );
  }

  Widget _resultBadge(bool isWinner, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            isWinner ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        isWinner ? 'WIN' : 'LOSS',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWinner ? color : Colors.grey,
            fontFamily: 'Font'),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
          fontFamily: 'Font'),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formatNum(num? value) => value?.toString() ?? 'N/A';

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final blueActual = stats?.prediction?.blue_actual_score ?? 0;
    final redActual = stats?.prediction?.red_actual_score ?? 0;

    final blueWinner = blueActual > redActual;
    final redWinner = redActual > blueActual;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAllianceCard(
            title: 'Blue Alliance',
            color: Colors.blue,
            predictedScore: formatNum(stats?.prediction?.blue_score?.round()),
            predictedRP: stats?.prediction?.blue_total_rp?.toString() ?? '-',
            actualScore: stats?.prediction?.blue_actual_score?.toString(),
            actualRP: stats?.prediction?.blue_display_rp?.toString(),
            rows: blueRows,
            isWinner: blueWinner,
          ),
          const SizedBox(height: 32),
          _buildAllianceCard(
            title: 'Red Alliance',
            color: Colors.red,
            predictedScore: formatNum(stats?.prediction?.red_score?.round()),
            predictedRP: stats?.prediction?.red_total_rp?.toString() ?? '-',
            actualScore: stats?.prediction?.red_actual_score?.toString(),
            actualRP: stats?.prediction?.red_display_rp?.toString(),
            rows: redRows,
            isWinner: redWinner,
          ),
        ],
      ),
    );
  }
}

class _StatsTableSource extends DataGridSource {
  final List<DataGridRow> rows;
  final Color accent;
  final ColorScheme scheme;

  _StatsTableSource(this.rows, this.accent, this.scheme);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final rowIndex = rows.indexOf(row);
    final isEven = rowIndex % 2 == 0;

    return DataGridRowAdapter(
      color: isEven
          ? scheme.surface
          : scheme.surfaceContainerLowest.withOpacity(0.4),
      cells: row.getCells().asMap().entries.map((entry) {
        final index = entry.key;
        final cell = entry.value;
        final isNumeric = cell.value is num;

        final text = isNumeric
            ? (cell.value as num).toStringAsFixed(2)
            : cell.value.toString();

        return Container(
          alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Font',
              fontSize: 14,
              fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w500,
              color: index == 0 ? accent : scheme.onSurface.withOpacity(0.85),
            ),
          ),
        );
      }).toList(),
    );
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
