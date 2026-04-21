import 'dart:convert';
import 'dart:math';
// ignore: deprecated_member_use
import 'package:csv/csv.dart';
import 'package:flat/flat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scouting_app/main.dart';
import 'package:scouting_app/models/group.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import 'package:scouting_app/models/picture_data.dart';
import 'package:scouting_app/models/scout_info.dart';
import 'package:scouting_app/models/team_stats_2026.dart';
import 'package:scouting_app/pages/not_found_page.dart';
import 'package:scouting_app/utils.dart';
import 'package:scouting_app/utils/download.dart';
import 'package:scouting_app/widgets/auto_pieces_2026.dart';
import 'package:scouting_app/widgets/modifedCounter.dart';
import 'package:scouting_app/widgets/percentage_counter.dart';
import 'package:scouting_app/widgets/pit_scouting_link.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/match_details_2026.dart';
import '../models/pit_scouting_2026.dart' hide Data;
import '../widgets/bar_chart_with_weights.dart';
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

class SnowField extends StatefulWidget {
  final int particleCount;
  final Color color;

  const SnowField({
    super.key,
    this.particleCount = 40,
    this.color = Colors.white,
  });

  @override
  State<SnowField> createState() => _SnowFieldState();
}

class _SnowFieldState extends State<SnowField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_SnowParticle> _particles;
  late DateTime _lastTick;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.particleCount, (i) => _createParticle());
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(_tick);
    _controller.repeat(
        min: 0, max: 1, period: const Duration(milliseconds: 16));
    _lastTick = DateTime.now();
  }

  _SnowParticle _createParticle() {
    return _SnowParticle(
      x: _rnd.nextDouble(),
      y: _rnd.nextDouble(),
      radius: 1.5 + _rnd.nextDouble() * 3,
      speed: 20 + _rnd.nextDouble() * 60,
      drift: -20 + _rnd.nextDouble() * 40,
      opacity: 0.25 + _rnd.nextDouble() * 0.75,
    );
  }

  void _tick() {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    for (final p in _particles) {
      p._logicalY += (p.speed * dt) / 300.0;
      p._logicalX += (p.drift * dt) / 300.0;
      if (p._logicalY > 1.25) {
        p._logicalY = -0.05 - _rnd.nextDouble() * 0.1;
        p._logicalX = _rnd.nextDouble();
      }
      if (p._logicalX < -0.2) p._logicalX = 1.05;
      if (p._logicalX > 1.2) p._logicalX = -0.05;
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SnowPainter(
          _particles, widget.color, MediaQuery.of(context).devicePixelRatio),
      size: Size.infinite,
    );
  }
}

class _SnowParticle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double drift;
  final double opacity;
  double _logicalX;
  double _logicalY;

  _SnowParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.opacity,
  })  : _logicalX = x,
        _logicalY = y;
}

class _SnowPainter extends CustomPainter {
  final List<_SnowParticle> particles;
  final Color baseColor;
  final double devicePixelRatio;

  _SnowPainter(this.particles, this.baseColor, this.devicePixelRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final Color dotColor = baseColor.withOpacity(0.7);

    for (final p in particles) {
      final dx = (p._logicalX.clamp(-0.5, 1.5)) * size.width;
      final dy = (p._logicalY.clamp(-0.5, 1.5)) * size.height;

      paint.color = dotColor.withOpacity(p.opacity * 0.9);
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter old) => true;
}

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
      _TBATab(widget, widget.tournament)
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
                icon: Icon(Icons.shield_outlined, color: theme.primaryColor),
                activeIcon: Icon(Icons.shield, color: theme.primaryColor),
                label: 'TBA')
          ],
          type: BottomNavigationBarType.shifting,
          selectedLabelStyle: TextStyle(
              fontFamily: 'Font',
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
          unselectedLabelStyle: TextStyle(
              fontFamily: 'Font',
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,
        ),
        body: tabs[_currentTab]);
  }
}

class _TBATab extends StatefulWidget {
  final EventPage widget;
  final Tournament tournament;
  const _TBATab(this.widget, this.tournament);

  @override
  _TBATabState createState() => _TBATabState();
}

class _TBATabState extends State<_TBATab> {
  late final String tbaUrl;

  @override
  void initState() {
    super.initState();
    tbaUrl =
        'https://www.thebluealliance.com/event/${widget.widget.tournament.page.split('/')[3]}${widget.widget.tournament.page.split('/')[4]}';
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
                  "View Event on The Blue Alliance",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Font',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  '${widget.tournament.display}',
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
                    label: const Text("Open Event"),
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

class _RankingsTab extends StatefulWidget {
  final EventPage widget;
  const _RankingsTab(this.widget);

  Tournament get tournament => widget.tournament;

  @override
  State<_RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<_RankingsTab> {
  List<TeamStats2026> rankings = [];
  bool isLoading = true;
  List<int> teams = [];
  String? token;
  int lastMatch = 1;
  List<GridColumn> dataColumns = [
    GridColumn(
        allowSorting: true,
        label: Text(
          '#',
          style: TextStyle(fontFamily: 'Font'),
        ),
        columnName: 'team_number',
        filterPopupMenuOptions: FilterPopupMenuOptions()),
    GridColumn(
        allowSorting: true,
        label: Text('OPR', style: TextStyle(fontFamily: 'Font')),
        columnName: 'OPR'),
    GridColumn(
      allowSorting: true,
      label: Text('Rank', style: TextStyle(fontFamily: 'Font')),
      columnName: 'rank',
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Sim RPs', style: TextStyle(fontFamily: 'Font')),
      columnName: 'simulated_rp',
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Auto Fuel Points', style: TextStyle(fontFamily: 'Font')),
      columnName: 'auto_fuel_scored',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Teleop Fuel Points', style: TextStyle(fontFamily: 'Font')),
      columnName: 'teleop_fuel_scored',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Climb Points', style: TextStyle(fontFamily: 'Font')),
      columnName: 'climbing_points',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Deathrate', style: TextStyle(fontFamily: 'Font')),
      columnName: 'death_rate',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Auto Defense Power Rating',
          style: TextStyle(fontFamily: 'Font')),
      columnName: 'auto_fuel_denied',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Teleop Defense Power Rating',
          style: TextStyle(fontFamily: 'Font')),
      columnName: 'teleop_fuel_denied',
      allowFiltering: false,
    ),
    GridColumn(
      allowSorting: true,
      label: Text('Defense Rate', style: TextStyle(fontFamily: 'Font')),
      columnName: 'defense_rate',
      allowFiltering: false,
    ),
  ];
  Map<String, bool> heatMapFromKey = {
    'team_number': false,
    'OPR': true,
    'rank': true,
    'simulated_rp': true,
    'auto_fuel_scored': true,
    'teleop_fuel_scored': true,
    'climbing_points': true,
    'auto_fuel_denied': true,
    'teleop_fuel_denied': true,
    'defense_rate': true,
    'death_rate': true,
  };
  List<MatchScouting2026> scouting = [];
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
    // Helper to safely convert any dynamic value to a number
    num _safeNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    minValues = {};
    maxValues = {};

    // Compute min/max for heatmap columns
    for (var column in dataColumns) {
      if (heatMapFromKey[column.columnName] == true) {
        final columnKey = column.columnName;
        minValues[columnKey] = double.infinity;
        maxValues[columnKey] = double.negativeInfinity;

        for (var rank in rankings) {
          var value = _safeNum(rank.toJson()[columnKey]);
          if (value < minValues[columnKey]!) minValues[columnKey] = value;
          if (value > maxValues[columnKey]!) maxValues[columnKey] = value;
        }
      }
    }

    // Build DataGrid rows
    dataRows = [];
    for (var rank in rankings) {
      List<DataGridCell> cells = [];

      for (var column in dataColumns) {
        try {
          final columnKey = column.columnName;
          final rawValue = rank.toJson()[columnKey];

          num value = _safeNum(rawValue);

          // Heatmap: round to 1 decimal for display
          if (heatMapFromKey[columnKey] == true) {
            cells.add(DataGridCell(
              columnName: columnKey,
              value: (value * 10).roundToDouble() / 10,
            ));
          } else {
            // Keep original value for non-heatmap columns
            cells.add(DataGridCell(
              columnName: columnKey,
              value: rawValue ?? 0,
            ));
          }
        } catch (e) {
          print('Error processing column ${column.columnName}: $e');
          cells.add(DataGridCell(columnName: column.columnName, value: 0));
        }
      }

      dataRows.add(DataGridRow(cells: cells));
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Loading rankings...',
              style: TextStyle(
                fontFamily: 'Font',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Check if rankings are empty or if Rank is 0
    bool noData = rankings.isEmpty || rankings.any((r) => r.rank == 0);
    if (noData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .folder_off_outlined, // Or Icons.search_off, Icons.folder_off
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .outline, // Subtle gray/themed color
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later or try refreshing.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }
    const columnMinWidth = 95.0;
    bool isWide = MediaQuery.of(context).size.width >=
        dataColumns.length * columnMinWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () async {
            List<List<dynamic>> csvData = [
              dataColumns.map((e) => e.columnName).toList()
            ];
            for (var row in dataRows) {
              csvData.add(row.getCells().map((e) => e.value).toList());
            }

            String csv = ListToCsvConverter().convert(csvData);
            final bytes = utf8.encode(csv);

            // ✅ CROSS-PLATFORM FIX
            await downloadFile(bytes, '${widget.tournament.display}.csv');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.blue.shade900, width: 2),
          ),
          child: Text('Export as CSV', style: TextStyle(fontFamily: 'Font')),
        ),
        Expanded(
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
                source: _TeamDataSource(
                    dataRows,
                    minValues,
                    maxValues,
                    heatMapFromKey,
                    context,
                    widget.tournament,
                    scouting,
                    rankings),
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
      this.context, this.tournament, this.scouting, this.rankings);
  final Map<String, dynamic> minValues, maxValues, heatMap;
  final List<DataGridRow> rows;
  final BuildContext context;
  final Tournament tournament;
  final List<MatchScouting2026> scouting;
  final List<TeamStats2026> rankings;
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
                    e.columnName == 'death_rate' ||
                    e.columnName == 'defense_rate')
            : even
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0);
        if (e.columnName == 'defense_rate') {
          return _DefenseMatchesOnClick(
            teamNumber: int.parse(row.getCells()[0].value.toString()),
            color: color,
            scouting: scouting,
          );
        }
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

        if (e.columnName == 'teleop_fuel_scored') {
          return _FuelMenuOnClick(
              teamNumber: int.parse(row.getCells()[0].value.toString()),
              color: color,
              auto: false,
              fuelOPR: e.value,
              rankings: rankings);
        }
        if (e.columnName == 'auto_fuel_scored') {
          return _FuelMenuOnClick(
              teamNumber: int.parse(row.getCells()[0].value.toString()),
              color: color,
              auto: true,
              fuelOPR: e.value,
              rankings: rankings);
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          color: color,
          child: Text('${_formatValue(e.value)}',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
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

class _DefenseMatchesOnClick extends StatelessWidget {
  final int teamNumber;
  final Color color;
  final List<MatchScouting2026> scouting;

  const _DefenseMatchesOnClick({
    required this.teamNumber,
    required this.color,
    required this.scouting,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final defenseMatches = scouting
            .where((match) =>
                match.team_number == teamNumber &&
                match.data.miscellaneous.defense)
            .toList()
          ..sort((a, b) => a.match_number.compareTo(b.match_number));

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Matches that $teamNumber played defense in - ',
              style: const TextStyle(color: Colors.white, fontFamily: 'Font'),
            ),
            content: SizedBox(
              width: 350,
              child: defenseMatches.isEmpty
                  ? const Text(
                      'No matches where defense was played.',
                      style: TextStyle(color: Colors.white70),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: defenseMatches.length,
                      itemBuilder: (_, index) {
                        final match = defenseMatches[index];

                        return ListTile(
                          onTap: () {
                            final matchKey =
                                '${match.event_code}_qm${match.match_number}';

                            final url = Uri.parse(
                              'https://www.thebluealliance.com/match/$matchKey',
                            );

                            launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          },
                          title: Text(
                            '${match.event_code}_qm${match.match_number}',
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontFamily: 'Font',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          subtitle: Text(
                            match.data.miscellaneous.comments.isNotEmpty
                                ? match.data.miscellaneous.comments
                                : 'No comments',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        color: color,
        child: Text(
          '${_formatValueForDisplay(teamNumber)}',
          style: const TextStyle(color: Colors.white, fontFamily: 'Font'),
        ),
      ),
    );
  }

  String _formatValueForDisplay(int team) {
    final teamMatches = scouting.where((m) => m.team_number == team).length;
    final defenseMatches = scouting
        .where((m) => m.team_number == team && m.data.miscellaneous.defense)
        .length;

    if (teamMatches == 0) return '0.0';

    final rate = defenseMatches / teamMatches;
    return rate.toStringAsFixed(1);
  }
}

class _OvertimeChartOnClick extends StatelessWidget {
  final int teamNumber;
  final double opr;
  final Color color;
  final GlobalKey key = GlobalKey();
  final List<MatchScouting2026> scouting;
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
                  decorationThickness: 2,
                  fontFamily: 'Font'))),
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
          'auto_scoring_fuel_scored',
          'teleop_scoring_fuel_scored',
        ];
        for (var series in seriesLabels) {
          seriesData[series] = [];
        }
        List<MatchScouting2026> teamScoutingData = [];
        for (var entry in scouting) {
          if (entry.team_number == teamNumber) {
            teamScoutingData.add(entry);
          }
        }
        teamScoutingData.sort((a, b) => a.match_number - b.match_number);
        for (var x in teamScoutingData) {
          var entry = x.toJson();
          entry['data'].remove('miscellaneous');
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
        if (teamScoutingData.length > 0) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Team $teamNumber Scouting Data',
                        style: TextStyle(fontFamily: 'Font')),
                    content: Container(
                      height: 400,
                      width: 800,
                      child: firstChart,
                    ),
                  ));
        } else if (teamScoutingData.length == 0) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Team $teamNumber Has No Scouting Data Yet',
                        style: TextStyle(fontFamily: 'Font')),
                  ));
        }
      },
    );
  }
}

class _FuelMenuOnClick extends StatelessWidget {
  final bool auto;
  final int teamNumber;
  final Color color;
  final double fuelOPR;
  final List<TeamStats2026> rankings;

  _FuelMenuOnClick({
    required this.auto,
    required this.teamNumber,
    required this.color,
    required this.fuelOPR,
    required this.rankings,
  });

  final GlobalKey containerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: containerKey,
      onTap: () {
        final ctx = containerKey.currentContext;
        if (ctx == null) return;

        final renderBox = ctx.findRenderObject() as RenderBox;

        final overlay = Overlay.of(context, rootOverlay: true)
            .context
            .findRenderObject() as RenderBox;

        final items = <PopupMenuEntry<void>>[
          PopupMenuItem<void>(
            child: Text(
              'Team $teamNumber',
              style: TextStyle(fontFamily: 'Font'),
            ),
          ),
          PopupMenuItem<void>(
            child: Text(
              'Fuel OPR: ${fuelOPR.toStringAsFixed(1)}',
              style: TextStyle(fontFamily: 'Font'),
            ),
          ),
          PopupMenuItem<void>(
            child: Text(
              auto ? 'Auto' : 'TeleOp',
              style: TextStyle(fontFamily: 'Font'),
            ),
          ),
        ];

        showMenu<void>(
          context: context,
          position: RelativeRect.fromRect(
            renderBox.localToGlobal(Offset.zero) & renderBox.size,
            Offset.zero & overlay.size,
          ),
          items: items,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        color: color,
        child: Text(
          '${(fuelOPR * 10).roundToDouble() / 10}',
          style: const TextStyle(
            fontFamily: 'Font',
            color: Colors.white,
            decoration: TextDecoration.underline,
            decorationThickness: 2,
          ),
        ),
      ),
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

class _TeamCard extends StatelessWidget {
  final int teamIndex;
  final List<int> teams;
  final Widget chart;
  final Tournament tournament;
  final List<MatchScouting2026> scouting;

  const _TeamCard({
    required this.teamIndex,
    required this.teams,
    required this.chart,
    required this.tournament,
    required this.scouting,
  });

  @override
  Widget build(BuildContext context) {
    if (teamIndex == 0) return const SizedBox.shrink();

    final teamNumber = teams[teamIndex - 1];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            chart,
            const SizedBox(height: 12),
            FutureBuilder<List<PictureData>>(
              future: Provider.of<ApiService>(context, listen: false)
                  .fetchTeamImages(
                int.parse(tournament.page.split('/')[3]),
                tournament.page.split('/')[4],
                'frc$teamNumber',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final allImages = snapshot.data!;
                List<PictureData> images = allImages
                    .where((img) => img.image_type == 'full_robot')
                    .toList();
                if (images.isEmpty)
                  images = allImages
                      .where((img) => img.image_type == 'wires')
                      .toList();
                if (images.isEmpty) images = allImages;

                final image = images.first;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    image.link,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 200,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartsTabState extends State<_ChartsTab> {
  List<TeamStats2026> rankings = [];
  bool isLoading = true;
  List<MatchScouting2026> scouting = [];
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Loading Charts...',
              style: TextStyle(
                fontFamily: 'Font',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Text('Scouting Data By Match',
              style: TextStyle(
                  fontFamily: 'Font', fontSize: 20, color: Colors.blue)),
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
              List<MatchScouting2026> teamScoutingData = [];
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
                'auto_scoring_fuel_scored',
                'teleop_scoring_fuel_scored',
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
              List<MatchScouting2026> secondTeamScoutingData = [];
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
                FutureBuilder<List<PictureData>>(
                  future: Provider.of<ApiService>(context, listen: false)
                      .fetchTeamImages(
                    int.parse(widget.widget.tournament.page.split('/')[3]),
                    widget.widget.tournament.page.split('/')[4],
                    'frc${teams[selectedTeam - 1]}',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading images'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink(); // no image
                    }

                    final allImages = snapshot.data!;

                    // Priority list: full_robot > wires > any
                    List<PictureData> images = allImages
                        .where((img) => img.image_type == 'full_robot')
                        .toList();
                    if (images.isEmpty) {
                      images = allImages
                          .where((img) => img.image_type == 'wires')
                          .toList();
                    }
                    if (images.isEmpty) images = allImages;

                    final image = images.first;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          image.link,
                          fit: BoxFit.contain,
                          width: 200,
                          height: 200,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    );
                  },
                );
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top controls: centered
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Team 1 dropdown
                        DropdownButton<int>(
                          items: [
                            DropdownMenuItem(
                              child: Text('Select a Team',
                                  style: TextStyle(fontFamily: 'Font')),
                              value: 0,
                            ),
                            ...teams.map((team) => DropdownMenuItem(
                                  child: Text('Team $team',
                                      style: TextStyle(fontFamily: 'Font')),
                                  value: teams.indexOf(team) + 1,
                                )),
                          ],
                          onChanged: (team) => setState(() {
                            selectedTeam = team ?? 0;
                          }),
                          value: selectedTeam,
                        ),

                        const SizedBox(width: 16),

                        // Compare toggle button
                        ElevatedButton.icon(
                          icon: Icon(
                              comparing ? Icons.toggle_on : Icons.toggle_off),
                          label: Text('Compare',
                              style: TextStyle(fontFamily: 'Font')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                comparing ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () => setState(() {
                            comparing = !comparing;
                            if (!comparing)
                              secondTeam =
                                  0; // reset second team when turning off
                          }),
                        ),

                        const SizedBox(width: 16),

                        // Team 2 dropdown (only visible if comparing)
                        if (comparing)
                          DropdownButton<int>(
                            items: [
                              DropdownMenuItem(
                                child: Text('Select a Team',
                                    style: TextStyle(fontFamily: 'Font')),
                                value: 0,
                              ),
                              ...teams.map((team) => DropdownMenuItem(
                                    child: Text('Team $team',
                                        style: TextStyle(fontFamily: 'Font')),
                                    value: teams.indexOf(team) + 1,
                                  )),
                            ],
                            onChanged: (team) => setState(() {
                              secondTeam = team ?? 0;
                            }),
                            value: secondTeam,
                          ),
                      ],
                    ),
                  ),

                  // Charts and images row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team 1 Card
                      Expanded(
                        child: _TeamCard(
                          teamIndex: selectedTeam,
                          teams: teams,
                          chart: firstChart,
                          tournament: widget.widget.tournament,
                          scouting: scouting,
                        ),
                      ),

                      // Team 2 Card (only if comparing)
                      if (comparing)
                        Expanded(
                          child: _TeamCard(
                            teamIndex: secondTeam,
                            teams: teams,
                            chart: secondChart,
                            tournament: widget.widget.tournament,
                            scouting: scouting,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),
          if (token == null)
            LoginWidget(redirect_path: 'event/${widget.widget.tournament.key}'),
          if (token != null && teams.isEmpty)
            Padding(
                padding: EdgeInsets.all(20),
                child: Text('No scouting data available for this event',
                    style: TextStyle(fontFamily: 'Font'))),
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
                  title: 'Fuel By Game Period',
                  data: rankings,
                  number: 24,
                  startingFields: [
                    Field(
                        name: 'Teleop Fuel',
                        key: 'teleop_fuel_scored',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Auto Fuel',
                        key: 'auto_fuel_scored',
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
                    Field(
                        name: 'Teleop Fuel',
                        key: 'teleop_fuel_scored',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Auto Fuel',
                        key: 'auto_fuel_scored',
                        enabled: true,
                        weight: 1),
                    Field(
                        name: 'Climb',
                        key: 'climbing_points',
                        enabled: true,
                        weight: 1)
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
  int get _hopperCapacity => (pitData?.data.hopper_capacity ?? 0) > 0
      ? pitData!.data.hopper_capacity
      : 32;
  PitScouting2026? pitData;

  late final TextEditingController eventCodeController,
      teamNumberController,
      matchNumberController,
      scoutNameController,
      commentsController;
  late final ScrollController scrollController;
  int driverStationIndex = -1;
  String? token;
  MatchDetails2026? matchDetails = null;
  List<Group>? groups;
  bool loading = true, submitted = false;
  late MatchScouting2026 data = MatchScouting2026(
      event_code: widget.widget.tournament.key,
      team_number: 0,
      match_number: 0,
      scout_info: get_scout_info(token ?? ''),
      data: Data(
          auto: Auto2026(
            starting_position_meters_from_hub_center: 0,
            steps: [],
            field_side: [],
            preload: false,
            climb: false,
            contacts_robot: false,
          ),
          auto_scoring:
              AutoScoring(fuel_scored: 0, hopper_capacity: _hopperCapacity),
          teleop_scoring:
              TeleopScoring(fuel_scored: 0, hopper_capacity: _hopperCapacity),
          miscellaneous:
              Miscellaneous(died: false, comments: '', defense: false)),
      time: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
  Future<void> _fetchPitData(int teamNumber) async {
    if (teamNumber <= 0) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final fetched = await apiService.fetchTeamPitScouting(
          int.parse(widget.widget.tournament.page.split('/')[3])
              .toString(), // year: 2026
          widget.widget.tournament.page.split('/')[4], // event: cancmp
          "frc${teamNumber}" // team: 254
          );
      if (mounted) {
        setState(() {
          pitData = fetched;
          data = data.copyWith(
            data: data.data.copyWith(
              auto_scoring: data.data.auto_scoring
                  .copyWith(hopper_capacity: _hopperCapacity),
              teleop_scoring: data.data.teleop_scoring
                  .copyWith(hopper_capacity: _hopperCapacity),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          pitData = PitScouting2026(
            // ... other required fields ...
            data: PitData2026(
              hopper_capacity: 32,
              driver_experience_events: 0,
              drive_train: '',
              type_of_shooter: '',
              fixedShooting: false,
              nearTower: false,
              nearHub: false,
              go_under_trench: false,
              can_climb: false,
              climbing: [],
              can_climb_in_autonomous: false,
              main_strategy: '',
              spare_parts: 0,
              favorite_color: '',
              bps: 0,
              comments: '',
              robot_height: 0,
              straddling_pole_climb_right: false,
              straddling_pole_climb_left: false,
              left_pole_climb: false,
              right_pole_climb: false,
              center_pole_climb: false,

              // ... other required fields with defaults ...
            ),
            user_id: '',
            scout_info: ScoutInfo(first_name: '', user_id: '', team_number: 0),
            team_number: 0,
            event_code: '',
            time: 0,
          );
        });
      }
    }
  }

  @override
  initState() {
    super.initState();
    eventCodeController =
        TextEditingController(text: widget.widget.tournament.key);

    // Add a listener to display a QR code if submission fails
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
    teamNumberController.text = team.substring(3);
    data = data.copyWith(team_number: int.parse(team.substring(3)));
    _fetchPitData(int.parse(team.substring(3)));
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

    print('pitData: $pitData');
    print('pitData?.data?.hopper_capacity: ${pitData?.data.hopper_capacity}');
    final int capacity = _hopperCapacity;
    print('capacity: $capacity');
    final submitData = data.copyWith(
      data: data.data.copyWith(
        auto_scoring:
            data.data.auto_scoring.copyWith(hopper_capacity: _hopperCapacity),
        teleop_scoring:
            data.data.teleop_scoring.copyWith(hopper_capacity: _hopperCapacity),
      ),
    );
    print(
        'submitData auto hopper_capacity: ${submitData.data.auto_scoring.hopper_capacity}');
    print(
        'submitData teleop hopper_capacity: ${submitData.data.teleop_scoring.hopper_capacity}');
    ApiService api = Provider.of<ApiService>(context, listen: false);
    api.post_match_scouting(submitData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Submitted Successfully',
              style: TextStyle(fontFamily: 'Font'))));
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
                'You have already submitted this match. Do you want to update?',
                style: TextStyle(fontFamily: 'Font'))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(error.toString(), style: TextStyle(fontFamily: 'Font'))));
        showQR(error.toString());
      }
    });
  }

  void _update() {
    HapticFeedback.heavyImpact();
    final int capacity = _hopperCapacity;
    final submitData = data.copyWith(
      data: data.data.copyWith(
        auto_scoring:
            data.data.auto_scoring.copyWith(hopper_capacity: capacity),
        teleop_scoring:
            data.data.teleop_scoring.copyWith(hopper_capacity: capacity),
      ),
    );
    ApiService api = Provider.of<ApiService>(context, listen: false);
    api.update_match_scouting(submitData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Submitted Successfully',
              style: TextStyle(fontFamily: 'Font'))));
      setState(() {
        submitted = true;
      });
    }).onError((error, trace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(error.toString(), style: TextStyle(fontFamily: 'Font'))));
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    MatchScouting2026 reset = data.copyWith(
        match_number: data.match_number + 1,
        data: Data(
            auto: Auto2026(
                starting_position_meters_from_hub_center: 0,
                steps: [],
                field_side: [],
                preload: false,
                climb: false,
                contacts_robot: false),
            auto_scoring: AutoScoring(
                fuel_scored: 0,
                hopper_capacity: pitData?.data.hopper_capacity ?? 32),
            teleop_scoring: TeleopScoring(
                fuel_scored: 0,
                hopper_capacity: pitData?.data.hopper_capacity ?? 32),
            miscellaneous:
                Miscellaneous(died: false, comments: '', defense: false)));
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

  void showQR(String errorText) {
    Clipboard.setData(ClipboardData(text: jsonEncode(data.toJson())));
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              children: [
                Text(
                  errorText,
                  style: TextStyle(color: Colors.red, fontFamily: 'Font'),
                ),
                SizedBox(height: 10),
                Text('Match Data Copied To Clipboard. Save to upload later.',
                    style: TextStyle(fontFamily: 'Font')),
                SizedBox(height: 10),
                QrImageView(
                  size: min(constraints.maxWidth, (constraints.maxHeight - 60)),
                  data: jsonEncode(data.toJson()),
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                      color: Colors.black, eyeShape: QrEyeShape.square),
                  dataModuleStyle: QrDataModuleStyle(
                    color: Colors.black,
                    dataModuleShape: QrDataModuleShape.square,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dark Mode Palette
    const Color backgroundDb = Color(0xFF0F111A);
    const Color cardDb = Color(0xFF1A1D29);
    const Color primaryBlue = Color(0xFF47A7FF);
    const Color textPrimary = Color(0xFFE1E1E1);
    const String customFont = 'Font';

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

    if (loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Loading Match Scouting...',
              style: TextStyle(
                fontFamily: 'Font',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (token == null) {
      return Container(
        color: backgroundDb,
        child: Center(
            child: LoginWidget(
                redirect_path: 'event/${widget.widget.tournament.key}')),
      );
    }

    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
        child: IgnorePointer(
          ignoring: true,
          child: SnowField(
            particleCount: 50,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
      SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              children: [
                // HEADER

                Text(
                  widget.widget.tournament.display,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: customFont,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. PRE-MATCH INFO
                _buildDarkCard(
                  title: 'Pre-Match Info',
                  icon: Icons.assignment_outlined,
                  cardColor: cardDb,
                  accentColor: primaryBlue,
                  children: [
                    _buildDarkField(eventCodeController, 'Event Code',
                        enabled: false,
                        accent: primaryBlue,
                        textCol: textPrimary),
                    const SizedBox(height: 16),
                    _buildDarkField(scoutNameController, 'Scout Name',
                        enabled: false,
                        accent: primaryBlue,
                        textCol: textPrimary),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDarkField(
                            matchNumberController,
                            'Match Number',
                            isNum: true,
                            prefixIcon: Icons.tag,
                            accent: primaryBlue,
                            textCol: textPrimary,
                            onChanged: (value) {
                              int matchNumber = int.tryParse(value) ?? -1;
                              if (matchNumber >= 0 && matchNumber < 500) {
                                setState(() => data =
                                    data.copyWith(match_number: matchNumber));
                                getNewMatchDetails(matchNumber);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDarkField(
                            teamNumberController,
                            'Team Number',
                            isNum: true,
                            prefixIcon: Icons.precision_manufacturing,
                            accent: primaryBlue,
                            textCol: textPrimary,
                            onChanged: (value) {
                              int teamNumber = int.tryParse(value) ?? -1;
                              if (teamNumber >= 0 && teamNumber < 20000) {
                                setState(() => data =
                                    data.copyWith(team_number: teamNumber));
                                _fetchPitData(teamNumber); // <-- add this
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDarkDropdown(
                        DRIVER_STATIONS, cardDb, primaryBlue, textPrimary),
                  ],
                ),

                // 2. AUTO PHASE
                _buildDarkCard(
                  title: 'Autonomous',
                  icon: Icons.smart_toy_outlined,
                  cardColor: const Color.fromARGB(16, 54, 244, 54),
                  accentColor: Colors.green,
                  children: [
                    AutoPieces2026(
                      auto: data.data.auto,
                      onChanged: (newAuto) {
                        setState(() {
                          data = data.copyWith(
                              data: data.data.copyWith(auto: newAuto));
                        });
                      },
                      onAutoScoringChanged: (newAutoScoring) {
                        setState(() {
                          data = data.copyWith(
                              data: data.data
                                  .copyWith(auto_scoring: newAutoScoring));
                        });
                      },
                      locked: false,
                      matchScouting: true,
                    ),
                    const SizedBox(height: 12),
                    // _buildCounterRow(
                    //     'Fuel Amount', data.data.auto_scoring.fuel_cycles,
                    //     (val) {
                    //   setState(() => data = data.copyWith(
                    //       data: data.data.copyWith(
                    //           auto_scoring: data.data.auto_scoring
                    //               .copyWith(fuel_cycles: val))));
                    // }),

                    _buildCounterRow('Fuel Scored in Auto',
                        data.data.auto_scoring.fuel_scored, (val) {
                      setState(() => data = data.copyWith(
                          data: data.data.copyWith(
                              auto_scoring: data.data.auto_scoring
                                  .copyWith(fuel_scored: val))));
                    }),
                    const Divider(
                      color: Colors.blue,
                      height: 32,
                      thickness: 10,
                    ),
                    _buildHopperCounterRow('Hoppers Scored in Auto',
                        data.data.auto_scoring.fuel_scored_hopper.clamp(0, 999),
                        (val) {
                      setState(() => data = data.copyWith(
                          data: data.data.copyWith(
                              auto_scoring: data.data.auto_scoring
                                  .copyWith(fuel_scored_hopper: val))));
                    }),
                  ],
                ),

                // 3. TELEOP PHASE
                _buildDarkCard(
                    title: 'Teleop Phase',
                    icon: Icons.videogame_asset_outlined,
                    cardColor: const Color.fromARGB(30, 155, 39, 176),
                    accentColor: Colors.purple,
                    children: [
                      // _buildCounterRow(
                      //     'Fuel Amount', data.data.teleop_scoring.fuel_cycles,
                      //     (val) {
                      //   setState(() => data = data.copyWith(
                      //       data: data.data.copyWith(
                      //           teleop_scoring: data.data.teleop_scoring
                      //               .copyWith(fuel_cycles: val))));
                      // }),

                      _buildCounterRow('Fuel Scored in Teleop',
                          data.data.teleop_scoring.fuel_scored, (val) {
                        setState(() => data = data.copyWith(
                            data: data.data.copyWith(
                                teleop_scoring: data.data.teleop_scoring
                                    .copyWith(fuel_scored: val))));
                      }),
                      const Divider(
                        color: Colors.blue,
                        height: 32,
                        thickness: 10,
                      ),
                      _buildHopperCounterRow(
                          'Hoppers Scored in Teleop',
                          data.data.teleop_scoring.fuel_scored_hopper
                              .clamp(0, 999), (val) {
                        setState(() => data = data.copyWith(
                            data: data.data.copyWith(
                                teleop_scoring: data.data.teleop_scoring
                                    .copyWith(fuel_scored_hopper: val))));
                      }),
                    ]),

                // 4. MISCELLANEOUS
                _buildDarkCard(
                  title: 'Post-Match & Misc',
                  icon: Icons.widgets_outlined,
                  cardColor: const Color.fromARGB(24, 255, 153, 0),
                  accentColor: Colors.orange,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSwitch('Died?', data.data.miscellaneous.died,
                            textPrimary, primaryBlue, (value) {
                          HapticFeedback.lightImpact();
                          setState(() => data = data.copyWith(
                              data: data.data.copyWith(
                                  miscellaneous: data.data.miscellaneous
                                      .copyWith(died: value))));
                        }),
                        _buildSwitch(
                            'Defense?',
                            data.data.miscellaneous.defense,
                            textPrimary,
                            primaryBlue, (value) {
                          HapticFeedback.lightImpact();
                          setState(() => data = data.copyWith(
                              data: data.data.copyWith(
                                  miscellaneous: data.data.miscellaneous
                                      .copyWith(defense: value))));
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDarkField(
                      commentsController,
                      'Comments',
                      maxLines: 3,
                      maxLength: 500,
                      accent: primaryBlue,
                      textCol: textPrimary,
                      onChanged: (val) {
                        setState(() {
                          data = data.copyWith(
                              data: data.data.copyWith(
                                  miscellaneous: data.data.miscellaneous
                                      .copyWith(comments: val)));
                        });
                      },
                    ),
                  ],
                ),

                // BUTTONS
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: submitted ? _update : _submit,
                    child: Row(
                      children: [
                        Icon(Icons.send, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(submitted ? 'Update' : 'Submit',
                            style: const TextStyle(
                                fontFamily: customFont,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
                if (submitted)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextButton(
                      onPressed: _reset,
                      child: const Text('Reset',
                          style: TextStyle(
                              color: primaryBlue,
                              fontFamily: customFont,
                              fontSize: 16)),
                    ),
                  ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    ]));
  }

// UI HELPERS (Dark Mode)

  Widget _buildDarkCard(
      {required String title,
      required IconData icon,
      required List<Widget> children,
      required Color cardColor,
      required Color accentColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 26),
              const SizedBox(width: 10),
              Text(title,
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Font')),
            ],
          ),
          Divider(color: accentColor.withOpacity(0.3), height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDarkField(TextEditingController controller, String label,
      {bool enabled = true,
      bool isNum = false,
      IconData? prefixIcon,
      int maxLines = 1,
      int? maxLength, // Add this
      required Color accent,
      required Color textCol,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength, // Add this
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      inputFormatters: isNum ? [FilteringTextInputFormatter.digitsOnly] : [],
      style: TextStyle(fontFamily: 'Font', color: textCol),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: accent) : null,
        labelStyle:
            TextStyle(color: accent.withOpacity(0.8), fontFamily: 'Font'),
        filled: true,
        fillColor: Colors.black26,
        counterStyle: TextStyle(
            color: accent.withOpacity(0.6), fontFamily: 'Font'), // Add this
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accent.withOpacity(0.3))),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: accent, width: 2)),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accent.withOpacity(0.1))),
      ),
    );
  }

  Widget _buildDarkDropdown(
      List<String> stations, Color bg, Color accent, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: accent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: driverStationIndex == -1 ? null : driverStationIndex,
          dropdownColor: bg,
          icon: Icon(Icons.arrow_drop_down),
          hint: Row(children: [
            Icon(Icons.sports_esports, color: accent),
            SizedBox(
              width: 8,
            ),
            Text('Select Driver Station', style: TextStyle(fontFamily: 'Font')),
          ]),
          isExpanded: true,
          onChanged: (int? value) {
            setState(() {
              driverStationIndex = value!;
              if (value == 0) {
                data = data.copyWith(
                    data: data.data.copyWith(
                        auto: data.data.auto
                            .copyWith(field_side: ['red', 'blue'])));
              } else if (value < 4) {
                data = data.copyWith(
                    data: data.data.copyWith(
                        auto: data.data.auto.copyWith(field_side: ['red'])));
              } else if (value > 3) {
                data = data.copyWith(
                    data: data.data.copyWith(
                        auto: data.data.auto.copyWith(field_side: ['blue'])));
              }
            });
            getNewMatchDetails(data.match_number);
          },
          items: List.generate(
              stations.length,
              (i) => DropdownMenuItem(
                    value: i,
                    child: Text(stations[i],
                        style: TextStyle(
                            fontFamily: 'Font',
                            color: i == 0
                                ? Colors.white54
                                : (i < 4 ? Colors.redAccent : accent))),
                  )),
        ),
      ),
    );
  }

  Widget _buildCounterRow(String label, int val, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: BiggerCounter(
        label: label,
        value: val,
        max: 1000,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildHopperCounterRow(
      String label, int val, Function(int) onChanged) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: PercentCounter(label: label, onChanged: onChanged, value: val));
  }

  Widget _buildSwitch(String label, bool val, Color textCol, Color accent,
      Function(bool) onChanged) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(fontFamily: 'Font', color: textCol, fontSize: 16)),
        Switch(value: val, onChanged: onChanged, activeThumbColor: accent),
      ],
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
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MainApp.observer
        .subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void didPopNext() {
    fetchData();
  }

  @override
  void dispose() {
    MainApp.observer.unsubscribe(this);
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      token = await apiService.token;
      if (token == null) {
        setState(() => isLoading = false);
        return;
      }

      final fetchedStatus = await apiService.fetchPitStatus(
        int.parse(widget.widget.tournament.page.split('/')[3]),
        widget.widget.tournament.page.split('/')[4],
      );

      if (!mounted) return;

      statuses = fetchedStatus;
      statuses
          .sort((a, b) => int.parse(a['key']).compareTo(int.parse(b['key'])));

      _calculateProgress();
      _buildGrid();

      setState(() => isLoading = false);
    } catch (_) {
      setState(() {
        isLoading = false;
        hasGoodGroup = false;
      });
    }
  }

  void _calculateProgress() {
    if (statuses.isEmpty) {
      _progress = 0.0;
      return;
    }

    int totalFields = statuses.length * 2; // pit + pictures
    int completedFields = statuses.fold(0, (sum, status) {
      int c = 0;

      // Count "Done" as completed
      if (status['pit_status'] == 'Done') c++;
      if (status['picture_status'] == 'Done') c++;

      return sum + c;
    });

    // Update state so UI refreshes
    setState(() {
      _progress = totalFields > 0 ? completedFields / totalFields : 0.0;
    });
  }

  void _buildGrid() {
    dataColumns = [
      _buildColumn('key', 'Team'),
      _buildColumn('pit_status', 'Pit'),
      _buildColumn('picture_status', 'Pictures'),
      _buildColumn('follow_up_status', 'Follow Up'),
    ];

    dataRows = statuses.map((status) {
      return DataGridRow(cells: [
        DataGridCell(columnName: 'key', value: int.parse(status['key'])),
        DataGridCell(columnName: 'pit_status', value: status['pit_status']),
        DataGridCell(
            columnName: 'picture_status', value: status['picture_status']),
        DataGridCell(
            columnName: 'follow_up_status', value: status['follow_up_status']),
      ]);
    }).toList();
  }

  GridColumn _buildColumn(String name, String label) {
    return GridColumn(
      columnName: name,
      allowSorting: true,
      label: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Font',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const columnMinWidth = 175.0;
    final isWide = MediaQuery.of(context).size.width >=
        dataColumns.length * columnMinWidth;

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Loading Pit Status...',
              style: TextStyle(
                fontFamily: 'Font',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (token == null) {
      return LoginWidget(
        redirect_path: 'event/${widget.widget.tournament.key}',
      );
    }

    if (!hasGoodGroup) {
      return Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Your team is not part of this event',
              style: TextStyle(
                fontFamily: 'Font',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress bar for pit + pictures
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Form Progress',
                    style: TextStyle(
                      fontFamily: 'Font', // clean modern font
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontFamily: 'Font',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  // Background container
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Animated progress fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 12,
                    width: MediaQuery.of(context).size.width * _progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.shade400,
                          Colors.blueAccent.shade700,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.shade200.withOpacity(0.4),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Data grid
          Expanded(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SfDataGrid(
                  source: _StatusSource(
                      context, dataRows, widget.widget.tournament),
                  columns: dataColumns,
                  allowSorting: true,
                  frozenColumnsCount: 1,
                  defaultColumnWidth: columnMinWidth,
                  columnWidthMode:
                      isWide ? ColumnWidthMode.fill : ColumnWidthMode.none,
                  rowHeight: 60,
                  headerRowHeight: 56,
                  gridLinesVisibility: GridLinesVisibility.none,
                  headerGridLinesVisibility: GridLinesVisibility.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSource extends DataGridSource {
  final BuildContext context;
  final List<DataGridRow> dataRows;
  final dynamic tournament;

  // Manual configuration for Dark Mode consistency
  Color rowColor = const Color(0xFF1A1D29);
  final Color _cardDb = const Color(0xFF1A1D29);
  final Color _cardDbAlt = const Color(0xFF222636);
  final String _customFont = 'Font';

  _StatusSource(this.context, this.dataRows, this.tournament);

  @override
  List<DataGridRow> get rows => dataRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final int index = dataRows.indexOf(row);
    // Manual zebra striping
    final Color backgroundColor = (index % 2 == 0) ? _cardDb : _cardDbAlt;

    return DataGridRowAdapter(
      color: backgroundColor,
      cells: row.getCells().map<Widget>((dataGridCell) {
        // Find the team key (first cell) for the specific links
        final dynamic teamKey = row.getCells()[0].value;
        final String colName = dataGridCell.columnName;
        final dynamic val = dataGridCell.value;

        Widget cellChild;

        // Routing logic for specialized columns
        switch (colName) {
          case 'key':
            cellChild = TeamLink(val, tournament);
            break;
          case 'pit_status':
            cellChild = PitScoutingLink(teamKey, tournament, val);
            break;
          case 'picture_status':
            cellChild = PicturesLink(teamKey, tournament, val);
            break;
          case 'follow_up_status':
            cellChild = DeathLink(teamKey, tournament, val);
            break;
          default:
            // Standard status text with color coding
            cellChild = Text(
              val.toString(),
              style: TextStyle(
                fontFamily: _customFont,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(val.toString()),
              ),
            );
        }

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: cellChild,
        );
      }).toList(),
    );
  }

  // Logic for coloring "Done", "Incomplete", etc.
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Done':
      case 'Complete':
        return Colors.greenAccent;
      case 'Incomplete':
      case 'Partial':
        return Colors.yellowAccent;
      case 'None':
      case 'Missing':
        return Colors.redAccent;
      default:
        return const Color(0xFFE1E1E1); // Off-white default
    }
  }
}

class _MatchStatusSource extends DataGridSource {
  final List<DataGridRow> rows;
  final Tournament tournament;
  final List<dynamic> statuses;
  final Color primaryColor;

  _MatchStatusSource(
      this.primaryColor, this.rows, this.tournament, this.statuses);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final cells = row.getCells();
    final int rowIndex = rows.indexOf(row);
    final bool isEven = rowIndex % 2 == 0;

    // Use a subtle zebra stripe for the background
    final baseColor =
        isEven ? primaryColor.withOpacity(0.05) : Colors.transparent;

    // 1. Extract match status once per row instead of inside the cell loop
    final matchNumberStr = cells[0].value.toString().split(' ').last;
    final matchStatus = statuses.firstWhere(
      (s) => s['key'].toString().endsWith('qm$matchNumberStr'),
      orElse: () => {},
    );

    return DataGridRowAdapter(
      cells: cells.map<Widget>((cell) {
        return _buildCellWidget(cell, matchStatus, baseColor);
      }).toList(),
    );
  }

  Widget _buildCellWidget(
      DataGridCell cell, Map<String, dynamic> status, Color baseColor) {
    Color cellColor = baseColor;
    TextStyle textStyle = const TextStyle(fontFamily: 'Font', fontSize: 14);
    Widget? customChild;

    final bool isPredicted = status['predicted'] ?? false;

    switch (cell.columnName) {
      case 'key':
        customChild =
            MatchLink(cell.value, _generateMatchKey(cell.value), tournament);
        break;

      // Added the winner case here
      case 'winner':
        // Reuse the color logic: if the cell value is 'Blue', use blueWin, etc.
        if (cell.value == 'Blue') {
          cellColor = const Color(0xFF006496);
        } else if (cell.value == 'Red') {
          cellColor = const Color(0xFF8C0A00);
        } else if (cell.value == 'Tie') {
          cellColor = const Color(0xFF7D0096);
        }

        // Apply Bold weight and White color for contrast
        textStyle = textStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
        break;

      case 'blue_rp':
      case 'blue_score':
        cellColor = _getAllianceColor('blue', status, baseColor);
        textStyle = textStyle.copyWith(
            color: Colors.white, fontWeight: FontWeight.bold);
        break;

      case 'red_rp':
      case 'red_score':
        cellColor = _getAllianceColor('red', status, baseColor);
        textStyle = textStyle.copyWith(
            color: Colors.white, fontWeight: FontWeight.bold);
        break;

      case 'result_type':
        customChild = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPredicted
                ? Colors.orange.withOpacity(0.2)
                : Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            cell.value.toString().toUpperCase(),
            style: textStyle.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color:
                  isPredicted ? Colors.orange.shade900 : Colors.green.shade900,
            ),
          ),
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      alignment: Alignment.center,
      color: cellColor,
      child: customChild ??
          Text(
            cell.value.toString(),
            style: textStyle,
            textAlign: TextAlign.center,
          ),
    );
  }

  // Helper to handle the messy alliance color logic
  Color _getAllianceColor(
      String alliance, Map<String, dynamic> status, Color fallback) {
    if (status.isEmpty) return fallback;

    final bool isPredicted = status['predicted'] ?? false;
    final int rp = status['${alliance}_win_rp'] ?? 0;

    // Define your brand colors here
    const blueWin = Color(0xFF006496);
    const redWin = Color(0xFF8C0A00);
    const tieColor = Color.fromARGB(255, 110, 0, 150);

    if (isPredicted) {
      if (rp == 3) return alliance == 'blue' ? blueWin : redWin;
      if (rp == 1) return tieColor;
      return fallback;
    } else {
      final blueScore = status['blue_actual_score'] ?? 0;
      final redScore = status['red_actual_score'] ?? 0;

      if (blueScore == redScore) return tieColor;
      if (alliance == 'blue' && blueScore > redScore) return blueWin;
      if (alliance == 'red' && redScore > blueScore) return redWin;
      return fallback;
    }
  }

  String _generateMatchKey(dynamic cellValue) {
    String val = cellValue.toString();
    String matchNumber = val.split(' ').last;
    String type = val.contains('Qual')
        ? 'qm'
        : val.contains('Semi')
            ? 'sf'
            : 'f1m';
    String key = '${tournament.key}_$type$matchNumber';
    if (type == 'sf') key += 'm1';
    return key;
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

  Widget _buildHeader(String label) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void updateGrid() {
    dataColumns = [
      GridColumn(columnName: 'key', label: _buildHeader('Match')),
      GridColumn(columnName: 'result_type', label: _buildHeader('Status')),
      GridColumn(columnName: 'blue_score', label: _buildHeader('Blue Score')),
      GridColumn(columnName: 'red_score', label: _buildHeader('Red Score')),
      GridColumn(columnName: 'blue_rp', label: _buildHeader('Blue RP')),
      GridColumn(columnName: 'red_rp', label: _buildHeader('Red RP')),
    ];

    statuses.sort((a, b) => a['match_number'].compareTo(b['match_number']));

    dataRows = statuses.where((s) => s['comp_level'] == 'qm').map((status) {
      final bool isPredicted = status['predicted'] ?? false;

      return DataGridRow(cells: [
        DataGridCell(
            columnName: 'key', value: 'Qual ${status['match_number']}'),
        // Store as boolean or string, logic happens in the DataGridSource
        DataGridCell(
            columnName: 'result_type',
            value: isPredicted ? 'PREDICTED' : 'RESULT'),
        DataGridCell(
            columnName: 'blue_score',
            value: isPredicted
                ? status['blue_score'].toStringAsFixed(0)
                : status['blue_actual_score']),
        DataGridCell(
            columnName: 'red_score',
            value: isPredicted
                ? status['red_score'].toStringAsFixed(0)
                : status['red_actual_score']),
        DataGridCell(columnName: 'blue_rp', value: status['blue_display_rp']),
        DataGridCell(columnName: 'red_rp', value: status['red_display_rp']),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 800;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SfDataGrid(
            source: _MatchStatusSource(Theme.of(context).primaryColor, dataRows,
                widget.widget.tournament, statuses),
            columns: dataColumns,
            gridLinesVisibility: GridLinesVisibility.horizontal,
            headerGridLinesVisibility: GridLinesVisibility.none,
            columnWidthMode:
                isWide ? ColumnWidthMode.fill : ColumnWidthMode.none,
            selectionMode: SelectionMode.single,
            navigationMode: GridNavigationMode.cell,
            headerRowHeight: 45,
          ),
        ),
      ),
    );
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
          columnName: 'winner',
          label: Container(
              alignment: Alignment.center,
              child: Text('Winner',
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
                    source: _MatchStatusSource(Theme.of(context).primaryColor,
                        dataRows, widget.widget.tournament, statuses),
                  ),
                ))));
  }
}
