import 'dart:math';
import 'dart:ui';
// ignore: deprecated_member_use
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/models/group.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import 'package:scouting_app/models/picture_data.dart';
import 'package:scouting_app/models/pit_scouting_2026.dart';
import 'package:scouting_app/models/team_stats_2026.dart';
import 'package:scouting_app/models/tournament.dart';
import 'package:scouting_app/widgets/auto_display_2026.dart';
import 'package:scouting_app/widgets/auto_pieces_2026.dart';
import 'package:scouting_app/widgets/deaths_form.dart';
import 'package:scouting_app/widgets/login_widget.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

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

class DeathsComparisonPage extends StatelessWidget {
  final String eventCode;
  final String leftTeamNumber;
  final String rightTeamNumber;
  final Map<String, String> teamNames;

  const DeathsComparisonPage({
    super.key,
    required this.eventCode,
    required this.leftTeamNumber,
    required this.rightTeamNumber,
    required this.teamNames,
  });

  String _teamLabel(String teamNumber) {
    final nickname = teamNames[teamNumber];
    if (nickname != null && nickname.isNotEmpty) {
      return '$teamNumber | $nickname';
    }
    return teamNumber;
  }

  int _teamNumberAsInt(String teamNumber) {
    return int.tryParse(teamNumber) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PolarForecastAppBar(extraText: 'Deaths Comparison - $eventCode'),
      body: FutureBuilder<List<Tournament>>(
        future: apiService.fetchTournaments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Unable to load tournament data.'));
          }

          final tournament =
              snapshot.data!.where((t) => t.key == eventCode).firstOrNull;

          if (tournament == null) {
            return Center(
              child: Text(
                'Could not find event $eventCode.',
                style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 900;
              final leftPane = _DeathsTeamPanel(
                title: _teamLabel(leftTeamNumber),
                tournament: tournament,
                teamNumber: _teamNumberAsInt(leftTeamNumber),
              );
              final rightPane = _DeathsTeamPanel(
                title: _teamLabel(rightTeamNumber),
                tournament: tournament,
                teamNumber: _teamNumberAsInt(rightTeamNumber),
              );

              if (sideBySide) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(child: leftPane),
                      const SizedBox(width: 10),
                      Expanded(child: rightPane),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(child: leftPane),
                    const SizedBox(height: 10),
                    Expanded(child: rightPane),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeathsTeamPanel extends StatelessWidget {
  final String title;
  final Tournament tournament;
  final int teamNumber;

  const _DeathsTeamPanel({
    required this.title,
    required this.tournament,
    required this.teamNumber,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: cs.surfaceVariant.withOpacity(0.35),
            child: Text(
              'Team $title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
          Expanded(
            child: DeathsForm(tournament, teamNumber, true),
          ),
        ],
      ),
    );
  }
}

class AutoComparisonContainerPage extends StatefulWidget {
  final String eventCode;
  final String leftTeamNumber;
  final String rightTeamNumber;
  final Map<String, String> teamNames;

  const AutoComparisonContainerPage({
    super.key,
    required this.eventCode,
    required this.leftTeamNumber,
    required this.rightTeamNumber,
    required this.teamNames,
  });

  @override
  State<AutoComparisonContainerPage> createState() =>
      _AutoComparisonContainerPageState();
}

class _AutoComparisonContainerPageState
    extends State<AutoComparisonContainerPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tabs = [
      AutoFuelComparisonPagePitScouting(
        eventCode: widget.eventCode,
        leftTeamNumber: widget.leftTeamNumber,
        rightTeamNumber: widget.rightTeamNumber,
        teamNames: widget.teamNames,
      ),
      AutoFuelComparisonPageMatchScouting(
        eventCode: widget.eventCode,
        leftTeamNumber: widget.leftTeamNumber,
        rightTeamNumber: widget.rightTeamNumber,
        teamNames: widget.teamNames,
      ),
    ];

    return Scaffold(
      body: tabs[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined, color: theme.primaryColor),
            activeIcon: Icon(Icons.assignment, color: theme.primaryColor),
            label: 'Auto from Pit Scouting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility_outlined, color: theme.primaryColor),
            activeIcon: Icon(Icons.visibility, color: theme.primaryColor),
            label: 'Auto from Match Scouting',
          ),
        ],
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.primaryColor,
      ),
    );
  }
}

class AutoFuelComparisonPagePitScouting extends StatefulWidget {
  final String eventCode;
  final String leftTeamNumber;
  final String rightTeamNumber;
  final Map<String, String> teamNames;

  const AutoFuelComparisonPagePitScouting({
    super.key,
    required this.eventCode,
    required this.leftTeamNumber,
    required this.rightTeamNumber,
    required this.teamNames,
  });

  @override
  State<AutoFuelComparisonPagePitScouting> createState() =>
      _AutoFuelComparisonPageStatePitScouting();
}

class _AutoFuelComparisonPageStatePitScouting
    extends State<AutoFuelComparisonPagePitScouting> {
  bool isLoading = true;
  String? token;

  PitScouting2026? pitScouting;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    final apiService = Provider.of<ApiService>(context, listen: false);

    apiService.token.then((_token) {
      if (!mounted) return;

      if (_token == null) {
        setState(() {
          token = null;
          isLoading = false;
        });
        return;
      }

      setState(() => token = _token);

      final year = widget.eventCode.substring(0, 4);
      final event = widget.eventCode.substring(4);

      apiService
          .fetchTeamPitScouting(
        year,
        event,
        "frc${widget.leftTeamNumber}",
      )
          .then((data) {
        if (!mounted) return;

        setState(() {
          pitScouting = data;
          isLoading = false;
        });
      }).catchError((e) {
        print("Pit scouting error: $e");
        setState(() => isLoading = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'Auto Pit Scouting - ${widget.eventCode}',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token == null
              ? LoginWidget(
                  redirect_path: '/event/${widget.eventCode}',
                )
              : pitScouting == null
                  ? const Center(
                      child: Text("No pit scouting data available"),
                    )
                  : _buildAutos(),
    );
  }

  Widget _buildAutos() {
    final autos = pitScouting!.data.autos;

    if (autos!.isEmpty) {
      return const Center(child: Text("No autos recorded"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: autos.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoPieces2026(
                auto: autos[index],
                locked: true,
                onChanged: (_) {},
              ),
            ),
          ),
        );
      },
    );
  }
}

class AutoFuelComparisonPageMatchScouting extends StatefulWidget {
  final String eventCode;
  final String leftTeamNumber;
  final String rightTeamNumber;
  final Map<String, String> teamNames;

  const AutoFuelComparisonPageMatchScouting({
    super.key,
    required this.eventCode,
    required this.leftTeamNumber,
    required this.rightTeamNumber,
    required this.teamNames,
  });

  @override
  State<AutoFuelComparisonPageMatchScouting> createState() =>
      _AutoFuelComparisonPageStateMatchScouting();
}

class _AutoFuelComparisonPageStateMatchScouting
    extends State<AutoFuelComparisonPageMatchScouting> {
  List<MatchScouting2026> scouting = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    final apiService = Provider.of<ApiService>(context, listen: false);

    apiService.token.then((_token) {
      if (_token != null) {
        if (mounted) {
          setState(() => token = _token);
        }

        apiService
            .fetchTeamMatchScouting(
          int.parse(widget.eventCode.substring(0, 4)),
          widget.eventCode.substring(4),
          "frc${widget.leftTeamNumber}",
        )
            .then((_scouting) {
          if (mounted) {
            setState(() {
              scouting = _scouting;
              isLoading = false;
            });
          }
        });
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'Auto Match Scouting - ${widget.eventCode}',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token == null
              ? LoginWidget(
                  redirect_path: '/event/${widget.eventCode}',
                )
              : scouting.isEmpty
                  ? const Center(child: Text("No scouting data available"))
                  : ListView.builder(
                      itemCount: (scouting.length / 2).ceil(),
                      itemBuilder: (context, rowIndex) {
                        final leftIndex = rowIndex * 2;
                        final rightIndex = leftIndex + 1;

                        final left = scouting[leftIndex];
                        final right = rightIndex < scouting.length
                            ? scouting[rightIndex]
                            : null;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(child: _buildCard(left)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: right != null
                                    ? _buildCard(right)
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildCard(MatchScouting2026 data) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: AutoDisplay2026(
        scoutingData: data,
      ),
    );
  }
}

class GlassActionButton extends StatelessWidget {
  final Widget icon;
  final Widget label;
  final Color color;
  final VoidCallback onPressed;

  const GlassActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: color.withOpacity(0.14),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.16), color.withOpacity(0.08)],
                ),
                border: Border.all(color: color.withOpacity(0.28)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: color),
                    child: icon,
                  ),
                  const SizedBox(width: 8),
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                    child: label,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BubbleSort extends StatefulWidget {
  final List<Picks> picks;
  final List<TeamStats2026> rankings;
  final int eventYear;
  final String eventCode;
  final Map<String, String> teamNames;
  final String? name;
  final void Function(int index1, int index2) onSwap; // Add this
  final void Function() onAutoSave; // Add this

  const BubbleSort({
    super.key,
    required this.picks,
    required this.rankings,
    required this.eventYear,
    required this.eventCode,
    required this.teamNames,
    this.name,
    required this.onSwap, // Add this
    required this.onAutoSave, // Add this
  });

  @override
  State<BubbleSort> createState() => _BubbleSortState();
}

class _BubbleSortState extends State<BubbleSort> {
  Set<String> knownSwaps = {};
  Map<String, bool> decisionMemory = {};
  final Map<String, String> names = {};
  List<List<String>> orderHistory = [];
  int i = 0;
  int j = 0;
  int get leftIndex => j;
  int get rightIndex => (j + 1 < widget.picks.length) ? j + 1 : j;

  Map<String, List<int>> positionHistory = {};
  int stepCount = 0;
  bool isSorting = true;
  bool _showPhoneImages = false;

  List<PictureData> teamAImages = [];
  List<PictureData> teamBImages = [];
  bool isLoading = false;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    names.addAll(widget.teamNames);
    if (widget.picks.length > 1) {
      i = 0;
      j = 0;
      _loadPair();
    }
    for (int i = 0; i < widget.picks.length; i++) {
      positionHistory[widget.picks[i].number] = [i];
    }
  }

  String _swapKey(String a, String b) {
    final sorted = [a, b]..sort();
    return "${sorted[0]}-${sorted[1]}";
  }

  String _pairKey(String a, String b) {
    final sorted = [a, b]..sort();
    return "${sorted[0]}-${sorted[1]}";
  }

  void step(bool shouldSwap, List<Picks> arr, int n) {
    if (isDone) return;

    final a = widget.picks[j].number;
    final b = widget.picks[j + 1].number;
    final key = _swapKey(a, b);

    if (!knownSwaps.contains(key)) {
      knownSwaps.add(key);

      if (shouldSwap) {
        widget.onSwap(j, j + 1);
      }

      // Always persist after a comparison decision, even when no swap occurs.
      widget.onAutoSave();

      if (shouldSwap) {
        if (j > 0) {
          j--;
        } else {
          j++;
        }
      } else {
        j++;
      }
    } else {
      j++;
    }

    if (j >= n - 1) {
      setState(() => isDone = true);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Picklist Finished"),
            duration: Duration(seconds: 2),
          ),
        );
      });

      return;
    }

    final currentOrder = widget.picks.map((e) => e.number).toList();
    orderHistory.add(currentOrder);

    positionHistory.clear();
    for (int idx = 0; idx < currentOrder.length; idx++) {
      positionHistory[currentOrder[idx]] = [
        ...(positionHistory[currentOrder[idx]] ?? []),
        idx
      ];
    }

    stepCount++;

    setState(() {});
  }

  Widget _debugBarChart() {
    final current = orderHistory.isEmpty
        ? widget.picks.map((e) => e.number).toList()
        : orderHistory.last;

    return SizedBox(
      height: 250,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          isInversed: true,
          minimum: 1,
        ),
        series: <ColumnSeries<_BarData, String>>[
          ColumnSeries<_BarData, String>(
            dataSource: current.asMap().entries.map((e) {
              return _BarData(
                team: e.value,
                position: e.key + 1,
              );
            }).toList(),
            xValueMapper: (d, _) => d.team,
            yValueMapper: (d, _) => d.position,
            pointColorMapper: (d, index) {
              final isActive = index == j || index == j + 1;
              if (isActive) return Colors.orange;
              return Colors.blue;
            },
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
            ),
          )
        ],
      ),
    );
  }

  Future<void> _loadPair() async {
    if (isDone) return;
    if (widget.picks.length < 2) return;

    setState(() => isLoading = true);

    final a = widget.picks[leftIndex].number;
    final b = widget.picks[rightIndex].number;

    final key = _pairKey(a, b);

    if (decisionMemory.containsKey(key)) {
      final shouldSwap = decisionMemory[key]!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || isDone) return;

        step(shouldSwap, widget.picks, widget.picks.length);
        _loadPair();
      });

      setState(() => isLoading = false);
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      String eventCode = widget.eventCode;
      if (eventCode.length > 4) {
        eventCode = eventCode.substring(4);
      }

      final futures = await Future.wait([
        apiService.fetchTeamImages(widget.eventYear, eventCode, 'frc$a'),
        apiService.fetchTeamImages(widget.eventYear, eventCode, 'frc$b'),
        apiService.fetchTeamNicknames('frc$a'),
        apiService.fetchTeamNicknames('frc$b'),
      ]);

      if (!mounted) return;

      setState(() {
        teamAImages = futures[0] as List<PictureData>;
        teamBImages = futures[1] as List<PictureData>;

        final nA = futures[2] as String?;
        final nB = futures[3] as String?;

        if (nA != null && nA.isNotEmpty) names[a] = nA;
        if (nB != null && nB.isNotEmpty) names[b] = nB;
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _glassContainer({required Widget child, double radius = 12}) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.18),
            border: Border.all(color: cs.outline.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: child,
        ),
      ),
    );
  }

  String _teamLabel(String teamNumber) {
    final nickname = names[teamNumber];
    if (nickname != null && nickname.isNotEmpty) {
      return '$teamNumber | $nickname';
    }
    return teamNumber;
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.34)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  Color trophyColorForRank(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return const Color(0xFFcd7f32);
    return Theme.of(context).colorScheme.primary;
  }

  Widget _teamPanel({
    required String teamNumber,
    required int pickIndex,
    required TeamStats2026 stats,
    required TeamStats2026 opsStats,
    required String avatar,
    required String fallback,
    required List<PictureData> images,
    required String side,
    required Picks pick,
    bool showImages = true,
    bool compactImages = false,
  }) {
    final rankColor = trophyColorForRank(stats.rank);

    return _glassContainer(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      8), // change this for more/less rounding
                  child: Image.network(
                    avatar,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _teamLabel(teamNumber),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _pill('Pick #$pickIndex', Colors.blue),
                          _pill(side, Colors.purple),
                          _pill('Rank #${stats.rank}', rankColor),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (showImages)
              SizedBox(
                height: compactImages ? 84 : 112,
                width: double.infinity,
                child: images.isEmpty
                    ? const Center(child: Text('No images'))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _showImagePreview(image.link),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ExtendedImage.network(
                                image.link,
                                width: compactImages ? 96 : 128,
                                height: compactImages ? 84 : 112,
                                fit: BoxFit.cover,
                                loadStateChanged: (ExtendedImageState state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        alignment: Alignment.center,
                                        child: const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      );
                                    case LoadState.failed:
                                      return Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                            Icons.broken_image_outlined),
                                      );
                                    default:
                                      return null;
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              )
            else
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Tap show images to show images.'),
              ),
            const SizedBox(height: 8),
            Text(
              pick.comments.isEmpty ? "No notes" : pick.comments,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Stats",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow("Comp Rank", stats.rank.toDouble(),
                      opsStats.rank.toDouble(), side,
                      lowerIsBetter: true, integerLike: true),
                  _buildStatRow("Sim Rank", stats.simulated_rank.toDouble(),
                      opsStats.simulated_rank.toDouble(), side,
                      lowerIsBetter: true, integerLike: true),
                  _buildStatRow("OPR", stats.OPR, opsStats.OPR, side),
                  _buildStatRow(
                      "DPR",
                      stats.auto_fuel_denied + stats.teleop_fuel_denied,
                      opsStats.auto_fuel_denied + opsStats.teleop_fuel_denied,
                      side),

                  // Auto Points - Clickable
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AutoComparisonContainerPage(
                            eventCode: widget.eventCode,
                            leftTeamNumber: teamNumber,
                            rightTeamNumber: opsStats.team_number,
                            teamNames: names,
                          ),
                        ),
                      );
                    },
                    child: _buildStatRow("Auto Points", stats.auto_points,
                        opsStats.auto_points, side),
                  ),

                  _buildStatRow("Teleop Points", stats.teleop_points,
                      opsStats.teleop_points, side),
                  _buildStatRow("Endgame Points", stats.endgame_points,
                      opsStats.endgame_points, side),
                  _buildStatRow("Climbing Points", stats.climbing_points,
                      opsStats.climbing_points, side),
                  _buildStatRow("Total Pass", stats.total_pass,
                      opsStats.total_pass, side),

                  // Auto Pass - Clickable
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AutoComparisonContainerPage(
                            eventCode: widget.eventCode,
                            leftTeamNumber: teamNumber,
                            rightTeamNumber: opsStats.team_number,
                            teamNames: names,
                          ),
                        ),
                      );
                    },
                    child: _buildStatRow(
                        "Auto Pass", stats.auto_pass, opsStats.auto_pass, side),
                  ),

                  _buildStatRow("Teleop Pass", stats.teleop_pass,
                      opsStats.teleop_pass, side),

                  // Auto Fuel - Clickable
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AutoComparisonContainerPage(
                            eventCode: widget.eventCode,
                            leftTeamNumber: teamNumber,
                            rightTeamNumber: opsStats.team_number,
                            teamNames: names,
                          ),
                        ),
                      );
                    },
                    child: _buildStatRow("Auto Fuel", stats.auto_fuel_scored,
                        opsStats.auto_fuel_scored, side),
                  ),

                  _buildStatRow("Teleop Fuel", stats.teleop_fuel_scored,
                      opsStats.teleop_fuel_scored, side),
                  _buildStatRow("Total Fuel", stats.total_fuel_scored,
                      opsStats.total_fuel_scored, side),
                  _buildStatRow("Foul Points", stats.foul_points,
                      opsStats.foul_points, side,
                      lowerIsBetter: true),

                  // Death Rate - Clickable
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeathsComparisonPage(
                            eventCode: widget.eventCode,
                            leftTeamNumber: teamNumber,
                            rightTeamNumber: opsStats.team_number,
                            teamNames: names,
                          ),
                        ),
                      );
                    },
                    child: _buildStatRow("Death Rate", stats.death_rate,
                        opsStats.death_rate, side,
                        lowerIsBetter: true, asPercent: true),
                  ),

                  GestureDetector(
                    onTap: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        final api =
                            Provider.of<ApiService>(context, listen: false);

                        final scouting = await api.fetchTeamMatchScouting(
                          2026,
                          widget.eventCode.substring(4),
                          "frc${teamNumber}",
                        );

                        final defenseMatches = scouting
                            .where((m) =>
                                m.team_number.toString() ==
                                    teamNumber.toString() &&
                                m.data.miscellaneous.defense)
                            .toList()
                          ..sort((a, b) =>
                              a.match_number.compareTo(b.match_number));
                        Navigator.pop(context); // close loading

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: Text(
                              'Defense Matches - $teamNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Font',
                              ),
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
                                                mode: LaunchMode
                                                    .externalApplication);
                                          },
                                          title: Text(
                                            '${match.event_code}_qm${match.match_number}',
                                            style: const TextStyle(
                                              color: Colors.blueAccent,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontFamily: 'Font',
                                            ),
                                          ),
                                          subtitle: Text(
                                            match.data.miscellaneous.comments
                                                    .isNotEmpty
                                                ? match
                                                    .data.miscellaneous.comments
                                                : 'No comments',
                                            style: const TextStyle(
                                                color: Colors.white70),
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
                      } catch (e) {
                        Navigator.pop(context);

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Error"),
                            content: Text(e.toString()),
                          ),
                        );
                      }
                    },
                    child: _buildStatRow(
                      "Defense Rate",
                      stats.defense_rate,
                      opsStats.defense_rate,
                      side,
                      asPercent: true,
                    ),
                  ),
                  _buildStatRow("Sim RP", stats.simulated_rp.toDouble(),
                      opsStats.simulated_rp.toDouble(), side,
                      integerLike: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
      String label, double currentValue, double compareValue, String side,
      {bool lowerIsBetter = false,
      bool asPercent = false,
      bool integerLike = false}) {
    String format(double v) {
      if (asPercent) return "${(v * 100).toStringAsFixed(1)}%";
      if (integerLike) return v.toStringAsFixed(0);
      return v.toStringAsFixed(2);
    }

    // Determine if current value is better than compare value
    bool isBetter;
    bool isTie = currentValue == compareValue;

    if (isTie) {
      isBetter = false;
    } else if (lowerIsBetter) {
      isBetter = currentValue < compareValue;
    } else {
      isBetter = currentValue > compareValue;
    }

    Color getStatColor() {
      if (isTie) return Colors.grey;
      return isBetter ? Colors.green : Colors.red;
    }

    final color = getStatColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withOpacity(0.3),
                ),
              ),
              child: Text(
                format(currentValue),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImagePreview(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          backgroundColor: Colors.black87,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Center(
                    child: ExtendedImage.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadStateChanged: (ExtendedImageState state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2));
                          case LoadState.failed:
                            return const Icon(Icons.broken_image_outlined,
                                color: Colors.white70, size: 36);
                          default:
                            return null;
                        }
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TeamStats2026 _getStats(String teamNumber) {
    try {
      return widget.rankings.firstWhere(
        (t) => t.team_number == teamNumber,
      );
    } catch (e) {
      return TeamStats2026(
        team_number: teamNumber,
        OPR: 0,
        auto_points: 0,
        teleop_points: 0,
        endgame_points: 0,
        climbing_points: 0,
        total_pass: 0,
        auto_pass: 0,
        teleop_pass: 0,
        total_fuel_scored: 0,
        foul_points: 0,
        death_rate: 0,
        defense_rate: 0,
        simulated_rank: 0,
        rank: 0,
        simulated_rp: 0,
        historical: false,
        key: '',
        auto_fuel_denied: 0,
        teleop_fuel_denied: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.picks.length < 2) {
      return Scaffold(
        appBar: PolarForecastAppBar(extraText: 'Generate Picklist'),
        body: const Center(child: Text("Not enough picks")),
      );
    }

    if (isDone) {
      return Scaffold(
        appBar: PolarForecastAppBar(
          extraText: 'Generate Picklist ${widget.name}',
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Picklist Complete",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "All comparisons are finished and your picklist is ready.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                        ),
                  ),
                  const SizedBox(height: 24),
                  GlassActionButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final left = widget.picks[leftIndex];
    final right = widget.picks[rightIndex];
    final aNum = left.number;
    final bNum = right.number;
    final aStats = _getStats(aNum);
    final bStats = _getStats(bNum);

    final aAvatar =
        'https://images.weserv.nl/?url=www.thebluealliance.com/avatar/${widget.eventYear}/frc$aNum.png&w=256&h=256&fit=contain';
    final bAvatar =
        'https://images.weserv.nl/?url=www.thebluealliance.com/avatar/${widget.eventYear}/frc$bNum.png&w=256&h=256&fit=contain';

    return Scaffold(
      appBar:
          PolarForecastAppBar(extraText: 'Generate Picklist ${widget.name}'),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: SnowField(
                particleCount: 50,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _glassContainer(
                radius: 16,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 900;
                    final phone = constraints.maxWidth < 700;

                    return Column(
                      children: [
                        // 📌 HEADER
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.compare_arrows_rounded,
                                      color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Auto Generate Picklist | ${widget.name}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Font',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _debugBarChart(),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // 📊 SCROLLABLE STATS ONLY
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      // 📱 PHONE TOGGLE
                                      if (compact && phone)
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _showPhoneImages =
                                                    !_showPhoneImages;
                                              });
                                            },
                                            icon: Icon(
                                              _showPhoneImages
                                                  ? Icons
                                                      .image_not_supported_outlined
                                                  : Icons.image_outlined,
                                            ),
                                            label: Text(
                                              _showPhoneImages
                                                  ? 'Hide images'
                                                  : 'Show images',
                                            ),
                                          ),
                                        ),

                                      // 📱 COMPACT LAYOUT
                                      if (compact)
                                        Column(
                                          children: [
                                            _teamPanel(
                                              teamNumber: aNum,
                                              pickIndex: leftIndex + 1,
                                              stats: aStats,
                                              opsStats: bStats,
                                              avatar: aAvatar,
                                              fallback: '',
                                              images: teamAImages,
                                              side: "LEFT",
                                              pick: left,
                                              showImages:
                                                  !phone || _showPhoneImages,
                                              compactImages: phone,
                                            ),
                                            const SizedBox(height: 10),
                                            _teamPanel(
                                              teamNumber: bNum,
                                              pickIndex: rightIndex + 1,
                                              stats: bStats,
                                              opsStats: aStats,
                                              avatar: bAvatar,
                                              fallback: '',
                                              images: teamBImages,
                                              side: "RIGHT",
                                              pick: right,
                                              showImages:
                                                  !phone || _showPhoneImages,
                                              compactImages: phone,
                                            ),
                                          ],
                                        )

                                      // 🖥 DESKTOP LAYOUT
                                      else
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _teamPanel(
                                                teamNumber: aNum,
                                                pickIndex: leftIndex + 1,
                                                stats: aStats,
                                                opsStats: bStats,
                                                avatar: aAvatar,
                                                fallback: '',
                                                images: teamAImages,
                                                side: "LEFT",
                                                pick: left,
                                                showImages: true,
                                                compactImages: false,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _teamPanel(
                                                teamNumber: bNum,
                                                pickIndex: rightIndex + 1,
                                                stats: bStats,
                                                opsStats: aStats,
                                                avatar: bAvatar,
                                                fallback: '',
                                                images: teamBImages,
                                                side: "RIGHT",
                                                pick: right,
                                                showImages: true,
                                                compactImages: false,
                                              ),
                                            ),
                                          ],
                                        ),

                                      const SizedBox(height: 100),
                                    ],
                                  ),
                                ),
                        ),

                        // 🔘 FIXED BOTTOM BUTTON CARD
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: _glassContainer(
                            radius: 16,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: phone
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: GlassActionButton(
                                            icon: const Icon(Icons.thumb_up),
                                            label:
                                                Text('${left.number} better'),
                                            color: Colors.blue,
                                            onPressed: () {
                                              final a = left.number;
                                              final b = right.number;
                                              decisionMemory[_pairKey(a, b)] =
                                                  false;
                                              step(false, widget.picks,
                                                  widget.picks.length);
                                              _loadPair();
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: GlassActionButton(
                                            icon: const Icon(Icons.thumb_up),
                                            label:
                                                Text('${right.number} better'),
                                            color: Colors.blue,
                                            onPressed: () {
                                              final a = left.number;
                                              final b = right.number;
                                              decisionMemory[_pairKey(a, b)] =
                                                  true;
                                              step(true, widget.picks,
                                                  widget.picks.length);
                                              _loadPair();
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  : Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        GlassActionButton(
                                          icon: const Icon(Icons.thumb_up),
                                          label: Text('${left.number} better'),
                                          color: Colors.blue,
                                          onPressed: () {
                                            final a = left.number;
                                            final b = right.number;
                                            decisionMemory[_pairKey(a, b)] =
                                                false;
                                            step(false, widget.picks,
                                                widget.picks.length);
                                            _loadPair();
                                          },
                                        ),
                                        GlassActionButton(
                                          icon: const Icon(Icons.thumb_up),
                                          label: Text('${right.number} better'),
                                          color: Colors.blue,
                                          onPressed: () {
                                            final a = left.number;
                                            final b = right.number;
                                            decisionMemory[_pairKey(a, b)] =
                                                true;
                                            step(true, widget.picks,
                                                widget.picks.length);
                                            _loadPair();
                                          },
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final String team;
  final int position;
  _BarData({required this.team, required this.position});
}
