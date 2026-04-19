import 'dart:math';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api_service.dart';
import '../models/global_rank.dart';
import '../widgets/polar_forecast_app_bar.dart';
import '../widgets/events_visited.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GlobalRank> suggestions = [];
  bool showSuggestions = false;
  final Map<String, String> _nicknameCache = {};
  final TextEditingController _searchController = TextEditingController();

  void safeSetState(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(callback);
      }
    });
  }

  int numTeams = 0;
  final int _limit = 100;
  int pageNum = 0;
  String _sortBy = 'data.OPR';
  String _sortOrder = 'desc';
  List<GlobalRank> rankings = [];
  List<SortColumnDetails> sortColumns = [];
  final columns = [
    GridColumn(
      allowFiltering: false,
      columnName: 'team',
      label: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text('Team'),
      ),
    ),
    GridColumn(
      allowFiltering: false,
      columnName: 'OPR',
      label: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text('OPR'),
      ),
    ),
    GridColumn(
      allowFiltering: false,
      columnName: 'OPRRank',
      label: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text('OPR Rank'),
      ),
    ),
    GridColumn(
      allowFiltering: false,
      columnName: 'auto',
      label: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text('Auto Points'),
      ),
    ),
    GridColumn(
      allowFiltering: false,
      columnName: 'teleop',
      label: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text('Teleop Points'),
      ),
    ),
    GridColumn(
      allowFiltering: false,
      columnName: 'endgame',
      label: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text('Endgame Points'),
      ),
    ),
  ];

  final Map<String, String> sortMap = {
    'team': 'data.team_number',
    'OPR': 'data.OPR',
    'OPRRank': 'data.OPRRank',
    'auto': 'data.auto_points',
    'teleop': 'data.teleop_points',
    'endgame': 'data.endgame_points',
  };
  @override
  void initState() {
    super.initState();
    _fetchRankings();
  }

  Future<void> _fetchRankings() async {
    final _rankingsFuture = Provider.of<ApiService>(context, listen: false)
        .fetch_global_rankings(
            limit: _limit,
            offset: _limit * pageNum,
            sortBy: _sortBy,
            sortOrder: _sortOrder);
    final (_rankings, _numTeams) = await _rankingsFuture;
    safeSetState(() {
      rankings = _rankings;
      numTeams = _numTeams;
    });
  }

  Future<void> _showTeamEventsDialog(String teamNumber) async {
    try {
      List<String> events = [];
      for (var rank in rankings) {
        if (rank.data.team_number == teamNumber) {
          events = rank.all_events;
          break;
        }
      }

      showDialog(
        context: context,
        builder: (context) => EventsVisited(
          teamNumber: teamNumber,
          events: events,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching events: $e')),
      );
    }
  }

  Future<void> _sort(List<SortColumnDetails> sortColumns) async {
    if (sortColumns.isEmpty) {
      return;
    }
    for (final column in sortColumns)
      safeSetState(() {
        if (_sortBy == sortMap[column.name]) {
          _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
        } else {
          _sortBy = sortMap[column.name] ?? 'data.OPR';
          _sortOrder = 'desc';
        }
        this.sortColumns = sortColumns;
      });
    _fetchRankings();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final displayRankings = query.isEmpty
        ? rankings
        : rankings.where((r) {
            final team = r.data.team_number.toString();
            final nickname = (_nicknameCache[team] ?? "").toLowerCase();

            return team.contains(query) || nickname.contains(query);
          }).toList();

    const columnMinWidth = 95.0;
    final bool isWide =
        MediaQuery.of(context).size.width >= columns.length * columnMinWidth;

    return Scaffold(
      appBar: PolarForecastAppBar(backButton: false),
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: SnowField(
                particleCount: 60,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                const Text(
                  'Global Rankings',
                  style: TextStyle(color: Colors.blue, fontSize: 24),
                ),
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse('https://www.thebluealliance.com'));
                  },
                  child: const Text(
                    'Powered by The Blue Alliance',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _searchController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) async {
                                final query = value.trim().toLowerCase();

                                if (query.isEmpty) {
                                  setState(() {
                                    suggestions = [];
                                    showSuggestions = false;
                                  });
                                  return;
                                }

                                final matches = rankings
                                    .where((r) => r.data.team_number
                                        .toString()
                                        .contains(query))
                                    .toList();

                                final limited = matches.take(8).toList();

                                final api = Provider.of<ApiService>(
                                  context,
                                  listen: false,
                                );

                                for (final r in limited) {
                                  final team = r.data.team_number.toString();

                                  if (!_nicknameCache.containsKey(team)) {
                                    try {
                                      _nicknameCache[team] =
                                          await api.fetchTeamNicknames(team);
                                    } catch (_) {
                                      _nicknameCache[team] = "";
                                    }
                                  }
                                }

                                setState(() {
                                  suggestions = limited;
                                  showSuggestions = true;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search Teams",
                                hintStyle:
                                    TextStyle(color: Colors.blueGrey.shade200),

                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.lightBlueAccent,
                                ),

                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.lightBlueAccent),
                                  onPressed: () {
                                    // clear controller
                                  },
                                ),

                                filled: true,
                                fillColor: const Color(0xFF0D1B2A), // deep navy

                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade900, width: 1.2),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Colors.lightBlueAccent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: displayRankings.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : SfDataGrid(
                          source: GlobalRankDataSource(
                            displayRankings,
                            displayRankings
                                .map((r) => r.data.OPR)
                                .reduce((a, b) => a > b ? a : b),
                            displayRankings
                                .map((r) => r.data.OPR)
                                .reduce((a, b) => a < b ? a : b),
                            _sort,
                            sortColumns,
                            (team) => _showTeamEventsDialog(team),
                          ),
                          showSortNumbers: true,
                          allowFiltering: true,
                          columnWidthMode: isWide
                              ? ColumnWidthMode.fill
                              : ColumnWidthMode.none,
                          columns: columns,
                          allowSorting: true,
                        ),
                ),
                if ((numTeams / _limit).ceil() != 0)
                  NumberPaginator(
                    numberPages: (numTeams / _limit).ceil(),
                    initialPage: min((numTeams / _limit).ceil() - 1, pageNum),
                    onPageChange: (newPage) {
                      setState(() {
                        pageNum = newPage;
                        _fetchRankings();
                      });
                    },
                    config: const NumberPaginatorUIConfig(
                      buttonSelectedBackgroundColor: Colors.blue,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GlobalRankDataSource extends DataGridSource {
  final Future<void> Function(List<SortColumnDetails>) onSort;
  final void Function(String team) onTeamTap;
  final List<SortColumnDetails> sortColumns;
  GlobalRankDataSource(
    this.globalRanks,
    this.maxOpr,
    this.minOpr,
    this.onSort,
    this.sortColumns,
    this.onTeamTap,
  ) {
    dataGridRows = globalRanks
        .map<DataGridRow>((rank) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'team', value: rank.data.team_number),
              DataGridCell<double>(columnName: 'OPR', value: rank.data.OPR),
              DataGridCell<int>(
                  columnName: 'OPRRank', value: rank.data.OPRRank),
              DataGridCell<double>(
                  columnName: 'auto', value: rank.data.auto_points),
              DataGridCell<double>(
                  columnName: 'teleop', value: rank.data.teleop_points),
              DataGridCell<double>(
                  columnName: 'endgame', value: rank.data.endgame_points),
            ]))
        .toList();
    super.sortedColumns.clear();
    super.sortedColumns.addAll(sortColumns);
  }

  Color? getHeatmapColor(String columnName, double value) {
    double maxValue, minValue;

    switch (columnName) {
      case 'OPR':
        maxValue = maxOpr;
        minValue = minOpr;
        break;
      case 'auto':
        maxValue = globalRanks
            .map((rank) => rank.data.auto_points)
            .reduce((a, b) => a > b ? a : b);
        minValue = globalRanks
            .map((rank) => rank.data.auto_points)
            .reduce((a, b) => a < b ? a : b);
        break;
      case 'teleop':
        maxValue = globalRanks
            .map((rank) => rank.data.teleop_points)
            .reduce((a, b) => a > b ? a : b);
        minValue = globalRanks
            .map((rank) => rank.data.teleop_points)
            .reduce((a, b) => a < b ? a : b);
        break;
      case 'endgame':
        maxValue = globalRanks
            .map((rank) => rank.data.endgame_points)
            .reduce((a, b) => a > b ? a : b);
        minValue = globalRanks
            .map((rank) => rank.data.endgame_points)
            .reduce((a, b) => a < b ? a : b);
        break;
      default:
        return null;
    }

    return _getGradientColor(value, minValue, maxValue, false);
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

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      ...row.getCells().asMap().entries.map((entry) {
        final index = entry.key;
        final cell = entry.value;

        if (index == 0) {
          final isEvenRow = dataGridRows.indexOf(row) % 2 == 0;
          final backgroundColor = isEvenRow
              ? Colors.blue.withOpacity(0.3)
              : Colors.black.withOpacity(0.1);

          return GestureDetector(
            onTap: () => onTeamTap(cell.value.toString()),
            child: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              color: backgroundColor,
              child: Text(
                cell.value.toString(),
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
        }

        final isDoubleColumn =
            ['OPR', 'auto', 'teleop', 'endgame'].contains(cell.columnName);
        final color = isDoubleColumn && !(cell.value as double).isNaN
            ? getHeatmapColor(cell.columnName, cell.value as double)
            : (dataGridRows.indexOf(row) % 2 == 0
                ? Colors.blue.withOpacity(0.3)
                : Colors.transparent);

        return Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          color: color,
          child: Text(cell.value.runtimeType == double
              ? (cell.value as double).toStringAsFixed(1)
              : cell.value.toString()),
        );
      })
    ]);
  }

  @override
  Future<void> performSorting(List<DataGridRow> rows) async {
    await this.onSort(sortedColumns);
  }

  List<GlobalRank> globalRanks = [];
  List<DataGridRow> dataGridRows = [];
  final double maxOpr;
  final double minOpr;

  @override
  List<DataGridRow> get rows => dataGridRows;
}

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
