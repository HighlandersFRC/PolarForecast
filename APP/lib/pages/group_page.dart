import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/models/group_join_request.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import 'package:scouting_app/widgets/login_widget.dart';

import '../models/alliance_request.dart';
import '../models/group.dart';
import '../models/tournament.dart';
import '../widgets/polar_forecast_app_bar.dart';
import 'package:intl/intl.dart';

class GroupPage extends StatefulWidget {
  final String group;
  final String? joinCode;
  const GroupPage(this.group, this.joinCode);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int _currentTab = 0;
  String? token;
  String? membershipData;
  Group? groupData;
  String? join_link;
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGroupData();
  }

  set group(Group? _group) {
    this.groupData = _group;
    if (mounted) {
      setState(() {
        groupData = _group;
      });
    }
  }

  set membership(String? _membership) {
    this.membershipData = _membership;
    if (mounted) {
      setState(() {
        membershipData = _membership;
      });
    }
  }

  Future<void> _fetchGroupData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      token = await apiService.token;

      if (token == null) {
        setState(() {
          loading = false;
          errorMessage = 'Please log in to access the group page.';
        });
        return;
      }

      if (widget.joinCode == null) {
        final (fetchedGroup, fetchedMembership) =
            await apiService.get_group(widget.group);
        setState(() {
          groupData = fetchedGroup;
          membershipData = fetchedMembership;
          join_link =
              '${apiService.APPURL}/group/${groupData?.name}/join/${groupData!.join_code}';
          loading = false;
        });
      } else {
        final joinResults =
            await apiService.join_group(widget.group, widget.joinCode!);

        if (joinResults.any((element) =>
            (element.group_name == widget.group) && !element.accepted)) {
          setState(() {
            errorMessage = 'Join Request Sent';
          });
        }

        final (fetchedGroup, fetchedMembership) =
            await apiService.get_group(widget.group);
        setState(() {
          groupData = fetchedGroup;
          membershipData = fetchedMembership;
          join_link =
              '${apiService.APPURL}/group/${groupData?.name}/join/${groupData!.join_code}';
          loading = false;
          errorMessage = null;
        });
      }
    } catch (error) {
      setState(() {
        loading = false;
        errorMessage = error.toString();
      });
    }
    await Future.delayed(Durations.medium1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> tabs = [
      _EventsTab(
        this,
        group: groupData,
        membership: membershipData,
      ),
      _MembersTab(
        this,
        group: groupData,
        membership: membershipData,
      ),
      _OfflineScoutingTab(),
      if (membershipData == 'owner')
        _SettingsTab(
          this,
          group: groupData,
          membership: membershipData,
        )
    ];

    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: '${widget.group}',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (newTabIdx) => setState(() => _currentTab = newTabIdx),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined,
                  color: theme.primaryColor),
              activeIcon: Icon(Icons.calendar_month, color: theme.primaryColor),
              label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.person, color: theme.primaryColor),
              label: 'Members'),
          BottomNavigationBarItem(
              icon: Icon(Icons.wifi_off_outlined, color: theme.primaryColor),
              activeIcon: Icon(Icons.wifi_off, color: theme.primaryColor),
              label: 'Offline'),
          if (membershipData == 'owner')
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined, color: theme.primaryColor),
                activeIcon: Icon(Icons.settings, color: theme.primaryColor),
                label: 'Settings'),
        ],
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(color: Colors.white, fontFamily: 'Font'),
        unselectedLabelStyle:
            TextStyle(color: Colors.white, fontFamily: 'Font'),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: _fetchGroupData, // Calls the new fetch function
          color: Colors.blue,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: loading
                ? Center(child: CircularProgressIndicator(color: Colors.blue))
                : token == null
                    ? Center(
                        child: LoginWidget(
                        redirect_path: widget.joinCode == null
                            ? 'group/${widget.group}/'
                            : 'group/${widget.group}/join/${widget.joinCode}',
                      ))
                    : errorMessage != null
                        ? Center(
                            child: Text(errorMessage!,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20.0,
                                    fontFamily: 'Font')))
                        : SizedBox(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            child: tabs[_currentTab]),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (groupData != null)
            Tooltip(
              message: 'Leave Group',
              child: FloatingActionButton.small(
                backgroundColor: Colors.red,
                shape: CircleBorder(
                  side: BorderSide(color: Colors.red),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Leave Group'),
                        content: Text(
                            'Are you sure you want to leave this group?',
                            style: TextStyle(fontFamily: 'Font')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel',
                                style: TextStyle(fontFamily: 'Font')),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/');
                              final apiService = Provider.of<ApiService>(
                                  context,
                                  listen: false);
                              apiService
                                  .leave_group(groupData?.name ?? '')
                                  .then((value) {})
                                  .onError((e, _) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              });
                            },
                            child: Text('Leave',
                                style: TextStyle(fontFamily: 'Font')),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.red),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(Icons.logout),
              ),
            ),
          if (groupData?.join_code != null) SizedBox(height: 5),
          if (groupData?.join_code != null)
            Tooltip(
              message: 'Invite Scouts',
              child: FloatingActionButton.small(
                backgroundColor: Colors.blue,
                shape: CircleBorder(
                  side: BorderSide(color: Colors.blue),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: join_link!));
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: LayoutBuilder(
                          builder: (context, constraints) => Column(
                            children: [
                              Text('Join Link Copied to Clipboard',
                                  style: TextStyle(fontFamily: 'Font')),
                              SizedBox(height: 10),
                              QrImageView(
                                size: min(constraints.maxWidth,
                                    (constraints.maxHeight - 30)),
                                data: join_link!,
                                eyeStyle: QrEyeStyle(
                                    color: Colors.blue,
                                    eyeShape: QrEyeShape.square),
                                dataModuleStyle: QrDataModuleStyle(
                                  color: Colors.blue,
                                  dataModuleShape: QrDataModuleShape.square,
                                ),
                                embeddedImage:
                                    AssetImage('assets/PolarBearHead.png'),
                                embeddedImageStyle: QrEmbeddedImageStyle(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Icon(Icons.group_add),
              ),
            )
        ],
      ),
    );
  }
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

class _EventsTab extends StatefulWidget {
  final _GroupPageState widget;
  final Group? group;
  final String? membership;
  _EventsTab(
    this.widget, {
    Key? key,
    this.group,
    this.membership,
  }) : super(key: key);
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab> {
  List<AllianceRequest> requests = [];
  List<Tournament> tournaments = [];
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.token.then((_token) {
      if (_token != null && widget.group != null) {
        apiService.get_alliance_requests(widget.group!.name).then(
          (value) {
            var filtered = value.where((val) {
              return !val.accepted;
            }).toList();
            requests = filtered;
            if (mounted) {
              setState(() => requests = value);
            }
          },
        );
        apiService.fetchTournaments().then((_tournaments) {
          if (mounted) {
            setState(() {
              tournaments = _tournaments;
            });
          }
          tournaments = _tournaments;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    var filtered = requests.where((val) {
      return !val.accepted;
    }).toList();
    requests = filtered;

    return Stack(children: [
      const Positioned.fill(
        child: SnowField(
          particleCount: 50, // you can adjust how dense the snow is
          color: Colors.white,
        ),
      ),
      SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          height: 10,
        ),
        if (widget.group != null)
          if (widget.membership != 'member')
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Font',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon:
                        const Icon(Icons.event, size: 28, color: Colors.white),
                    label: const Text('Join An Event'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return FutureBuilder<List<Tournament>>(
                            future: apiService.fetchTournaments(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return AlertDialog(
                                  title: const Text('Error',
                                      style: TextStyle(fontFamily: 'Font')),
                                  content: const Text(
                                    'Failed to load events. Please try again later.',
                                    style: TextStyle(fontFamily: 'Font'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('OK',
                                          style: TextStyle(fontFamily: 'Font')),
                                    ),
                                  ],
                                );
                              }

                              final tournaments = snapshot.data ?? [];
                              String? selectedEvent;

                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text(
                                      'Choose an Event',
                                      style: TextStyle(
                                          fontFamily: 'Font',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SearchAnchor.bar(
                                            barHintText: 'Search events',
                                            suggestionsBuilder:
                                                (context, controller) {
                                              final filteredTournaments =
                                                  tournaments
                                                      .where((tournament) =>
                                                          tournament.display
                                                              .toLowerCase()
                                                              .contains(controller
                                                                  .text
                                                                  .toLowerCase()))
                                                      .toList();
                                              return [
                                                ListTile(
                                                  title: const Text('None',
                                                      style: TextStyle(
                                                          fontFamily: 'Font')),
                                                  onTap: () {
                                                    setState(() {
                                                      selectedEvent = null;
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ...filteredTournaments
                                                    .map((tournament) {
                                                  return ListTile(
                                                    title: Text(
                                                        tournament.display,
                                                        style: const TextStyle(
                                                            fontFamily:
                                                                'Font')),
                                                    onTap: () {
                                                      setState(() {
                                                        selectedEvent =
                                                            tournament.key;
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  );
                                                }),
                                              ];
                                            },
                                          ),
                                          if (selectedEvent != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.check_circle,
                                                      color: Colors.blue,
                                                      size: 28),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Selected Event: $selectedEvent',
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Font',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Cancel',
                                            style:
                                                TextStyle(fontFamily: 'Font')),
                                      ),
                                      ElevatedButton(
                                        onPressed: selectedEvent != null
                                            ? () {
                                                apiService
                                                    .add_group_to_event(
                                                        widget.group?.name ??
                                                            '',
                                                        selectedEvent!)
                                                    .then((val) {
                                                  var (group, membership) = val;
                                                  widget.widget.group = group;
                                                  widget.widget.membership =
                                                      membership;
                                                });
                                                Navigator.of(context)
                                                    .pop(selectedEvent);
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          textStyle: const TextStyle(
                                              fontFamily: 'Font',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        child: const Text('Confirm'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
        if (widget.group != null)
          if (widget.group!.events.length == 0)
            Center(
              child: Text(
                'Not Currently Part of Any Events',
                style: TextStyle(
                    color: Colors.white, fontSize: 30.0, fontFamily: 'Font'),
              ),
            ),
        ExpansionPanelList.radio(
          dividerColor: Colors.transparent,
          children: (widget.group?.events.length ?? 0) == 0
              ? []
              : List.generate(widget.group!.events.length, (int event_index) {
                  final event_requests = requests.where((request) {
                    return request.event ==
                        widget.group!.events[event_index].event_code;
                  }).toList();
                  return ExpansionPanelRadio(
                      canTapOnHeader: false,
                      value: event_index,
                      headerBuilder: (context, isExpanded) => Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Card(
                              elevation:
                                  0, // Modern floating cards often use borders instead of heavy shadows
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: Colors.grey
                                        .withOpacity(0.2)), // Subtle border
                              ),
                              clipBehavior: Clip
                                  .antiAlias, // Ensures the InkWell ripple respects the border radius
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      '/event/${widget.group!.events[event_index].event_code}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Row(
                                    children: [
                                      // Improved Status Indicator (Uses Icon instead of just color for accessibility)
                                      Tooltip(
                                        message: widget.group!
                                                .events[event_index].up_to_date
                                            ? 'Event Data Up To Date'
                                            : 'Event Data Updating',
                                        triggerMode: TooltipTriggerMode.tap,
                                        child: Icon(
                                          widget.group!.events[event_index]
                                                  .up_to_date
                                              ? Icons.check_circle_rounded
                                              : Icons.sync_rounded,
                                          color: widget
                                                  .group!
                                                  .events[event_index]
                                                  .up_to_date
                                              ? Colors.green
                                              : Colors.orange,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Modernized Text
                                      Expanded(
                                        child: Text(
                                          tournaments
                                                  .where((t) =>
                                                      t.key ==
                                                      widget
                                                          .group!
                                                          .events[event_index]
                                                          .event_code)
                                                  .firstOrNull
                                                  ?.display ??
                                              widget.group!.events[event_index]
                                                  .event_code,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily:
                                                'Font', // Keep your custom font if you have one
                                            fontSize: 16,
                                            fontWeight: FontWeight
                                                .w600, // Semi-bold looks great for titles
                                            color: Colors
                                                .white70, // Standard dark text instead of blue hyperlink
                                          ),
                                        ),
                                      ),

                                      // Slightly softer arrow icon
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 24,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      body: Padding(
                          padding: EdgeInsets.all(10),
                          child: LayoutBuilder(
                              builder:
                                  (contexts, constraints) =>
                                      SingleChildScrollView(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                            Wrap(
                                                spacing: 12,
                                                runSpacing: 12,
                                                children: [
                                                  SizedBox(
                                                    width: constraints.maxWidth >=
                                                            860
                                                        ? (constraints
                                                                    .maxWidth -
                                                                12) /
                                                            2
                                                        : constraints.maxWidth,
                                                    child: Card(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        side: BorderSide(
                                                            color: Colors.blue),
                                                      ),
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  20),
                                                          child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .groups_2_outlined,
                                                                        color: Colors
                                                                            .white),
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                        'Alliances',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Font',
                                                                            fontSize:
                                                                                20,
                                                                            color:
                                                                                Colors.white)),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Text('Manage partnerships for this event',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Font',
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white70)),
                                                                SizedBox(
                                                                    height: 10),
                                                                if (widget
                                                                        .membership !=
                                                                    'member')
                                                                  ElevatedButton.icon(
                                                                      style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(42)),
                                                                      onPressed: () {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            final apiService =
                                                                                Provider.of<ApiService>(context, listen: false);
                                                                            final year =
                                                                                int.parse(widget.group!.events[event_index].event_code.substring(0, 4));
                                                                            final code =
                                                                                widget.group!.events[event_index].event_code.substring(4);
                                                                            final event_groups =
                                                                                apiService.get_event_groups(code, year);
                                                                            return FutureBuilder<List>(
                                                                                future: event_groups,
                                                                                builder: (context, snapshot) {
                                                                                  List groups = [];
                                                                                  try {
                                                                                    groups = snapshot.requireData;
                                                                                  } catch (e) {
                                                                                    return AlertDialog(
                                                                                      title: Text('Groups at ${widget.group!.events[event_index].event_code}', style: TextStyle(fontFamily: 'Font')),
                                                                                      content: CircularProgressIndicator(
                                                                                        color: Colors.blue,
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                  for (int i = 0; i < groups.length; i++) {
                                                                                    final group = groups[i];
                                                                                    if (group['name'] == widget.group!.name) {
                                                                                      groups.removeAt(i);
                                                                                      break;
                                                                                    }
                                                                                  }
                                                                                  return AlertDialog(
                                                                                    title: Text('Groups at ${widget.group!.events[event_index].event_code}', style: TextStyle(fontFamily: 'Font')),
                                                                                    content: SingleChildScrollView(
                                                                                      child: Column(
                                                                                        children: [
                                                                                          if (groups.length == 0) Text('There are no other groups at ${widget.group!.events[event_index].event_code}', style: TextStyle(fontFamily: 'Font')),
                                                                                          ...List.generate(groups.length, (int group_index) {
                                                                                            return ListTile(
                                                                                                title: Text('${groups[group_index]['name']} - ${groups[group_index]['affiliation'].substring(3)}', style: TextStyle(fontFamily: 'Font')),
                                                                                                onTap: () {
                                                                                                  apiService.request_alliance(widget.group!.name, widget.group!.events[event_index].event_code, groups[group_index]['name']).then((_requests) {
                                                                                                    setState(() {
                                                                                                      this.requests = _requests;
                                                                                                    });
                                                                                                  }).onError((e, _) {
                                                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: TextStyle(fontFamily: 'Font'))));
                                                                                                  });
                                                                                                  Navigator.of(context).pop();
                                                                                                });
                                                                                          })
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    actions: [],
                                                                                  );
                                                                                });
                                                                          },
                                                                        );
                                                                      },
                                                                      icon: Icon(Icons.add_circle_outline),
                                                                      label: Text('Create an Alliance', style: TextStyle(fontFamily: 'Font'))),
                                                                SizedBox(
                                                                    height: 10),
                                                                if (widget
                                                                        .group!
                                                                        .events[
                                                                            event_index]
                                                                        .alliance_groups
                                                                        .length ==
                                                                    0)
                                                                  Text(
                                                                      'No Alliances',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Font')),
                                                                if (widget
                                                                        .group!
                                                                        .events[
                                                                            event_index]
                                                                        .alliance_groups
                                                                        .length !=
                                                                    0)
                                                                  ExpansionPanelList
                                                                      .radio(
                                                                          children: List.generate(
                                                                              widget.group!.events[event_index].alliance_groups.length,
                                                                              (int alliance_index) {
                                                                    return ExpansionPanelRadio(
                                                                        canTapOnHeader:
                                                                            true,
                                                                        value:
                                                                            alliance_index,
                                                                        headerBuilder: (context, expanded) => ListTile(
                                                                            leading:
                                                                                Icon(Icons.handshake_outlined, color: Colors.blue),
                                                                            title: Text('${widget.group!.events[event_index].alliance_groups[alliance_index].name} - ${widget.group!.events[event_index].alliance_groups[alliance_index].affiliation.substring(3)}', style: TextStyle(fontFamily: 'Font'), overflow: TextOverflow.ellipsis)),
                                                                        body: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            if (widget.membership !=
                                                                                'member')
                                                                              ElevatedButton(
                                                                                  style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white), backgroundColor: WidgetStatePropertyAll(Colors.red)),
                                                                                  onPressed: () {
                                                                                    apiService.leave_alliance(widget.group!.name, widget.group!.events[event_index].event_code, widget.group!.events[event_index].alliance_groups[alliance_index].name).then((val) {
                                                                                      var (
                                                                                        group,
                                                                                        membership
                                                                                      ) = val;
                                                                                      setState(() {
                                                                                        widget.widget.membership = membership;
                                                                                        widget.widget.group = group;
                                                                                      });
                                                                                    }).onError((e, _) {
                                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: TextStyle(fontFamily: 'Font'))));
                                                                                    });
                                                                                  },
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Icon(Icons.logout_rounded, size: 18),
                                                                                      SizedBox(width: 6),
                                                                                      Text('Leave', style: TextStyle(fontFamily: 'Font')),
                                                                                    ],
                                                                                  )),
                                                                          ],
                                                                        ));
                                                                  }))
                                                              ])),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: constraints.maxWidth >=
                                                            860
                                                        ? (constraints
                                                                    .maxWidth -
                                                                12) /
                                                            2
                                                        : constraints.maxWidth,
                                                    child: Card(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        side: BorderSide(
                                                            color: Colors.blue),
                                                      ),
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  20),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .mail_outline_rounded,
                                                                      color: Colors
                                                                          .white),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    'Alliance Requests',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            20,
                                                                        fontFamily:
                                                                            'Font'),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                  'Review and respond to incoming requests',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Font',
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .white70)),
                                                              SizedBox(
                                                                  height: 10),
                                                              if (widget.membership !=
                                                                      'owner' &&
                                                                  widget.membership !=
                                                                      'admin')
                                                                Text(
                                                                    'You must be an owner or admin to view alliance requests',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Font')),
                                                              if (event_requests
                                                                          .length ==
                                                                      0 &&
                                                                  widget.membership !=
                                                                      'member')
                                                                Text(
                                                                    'No Pending Requests',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Font')),
                                                              if (event_requests
                                                                      .length !=
                                                                  0)
                                                                ExpansionPanelList
                                                                    .radio(
                                                                        children: List.generate(
                                                                            event_requests.length,
                                                                            (request_index) {
                                                                  final request =
                                                                      event_requests[
                                                                          request_index];
                                                                  if (request
                                                                          .group_1 ==
                                                                      widget
                                                                          .group!
                                                                          .name)
                                                                    return ExpansionPanelRadio(
                                                                        canTapOnHeader:
                                                                            true,
                                                                        value:
                                                                            request_index,
                                                                        headerBuilder: (context,
                                                                                open) =>
                                                                            ListTile(
                                                                              leading: Icon(Icons.outgoing_mail, color: Colors.orangeAccent),
                                                                              title: Text('${request.group_2} - ${request.group_2_affiliation.substring(3)}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontFamily: 'Font')),
                                                                            ),
                                                                        body:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            IconButton.filledTonal(
                                                                                onPressed: () {
                                                                                  apiService.delete_alliance_request(widget.group!.name, widget.group!.events[event_index].event_code, request).then((_requests) {
                                                                                    setState(() {
                                                                                      this.requests = _requests;
                                                                                    });
                                                                                  }).onError((e, _) {
                                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: TextStyle(fontFamily: 'Font'))));
                                                                                  });
                                                                                },
                                                                                icon: Icon(Icons.delete, color: Colors.red)),
                                                                          ],
                                                                        ));
                                                                  return ExpansionPanelRadio(
                                                                      canTapOnHeader:
                                                                          true,
                                                                      value:
                                                                          request_index,
                                                                      headerBuilder:
                                                                          (context, open) =>
                                                                              ListTile(
                                                                                leading: Icon(Icons.inbox_outlined, color: Colors.blue),
                                                                                title: Text('${request.group_1} - ${request.group_1_affiliation}', overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Font')),
                                                                              ),
                                                                      body: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          IconButton.filledTonal(
                                                                              onPressed: () {
                                                                                apiService.accept_alliance(widget.group!.name, widget.group!.events[event_index].event_code, request).then((_requests) {
                                                                                  setState(() {
                                                                                    this.requests = _requests;
                                                                                  });
                                                                                  apiService.get_group(widget.group!.name).then((val) {
                                                                                    setState(() {
                                                                                      var (
                                                                                        group,
                                                                                        membership
                                                                                      ) = val;
                                                                                      widget.widget.group = group;
                                                                                      widget.widget.membership = membership;
                                                                                    });
                                                                                  });
                                                                                });
                                                                              },
                                                                              icon: Icon(Icons.check_rounded, color: Colors.green)),
                                                                          IconButton.filledTonal(
                                                                              onPressed: () {
                                                                                apiService.decline_alliance(widget.group!.name, widget.group!.events[event_index].event_code, request).then((_requests) {
                                                                                  setState(() {
                                                                                    this.requests = _requests;
                                                                                  });
                                                                                });
                                                                              },
                                                                              icon: Icon(Icons.close_rounded, color: Colors.red)),
                                                                        ],
                                                                      ));
                                                                })),
                                                            ],
                                                          )),
                                                    ),
                                                  ),
                                                ]),
                                            // Grab the theme at the top of your build method if you haven't already:

// Your new, upgraded Card:
                                            Card(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                side: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    // 1. Polished Header Section
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .dashboard_customize_rounded,
                                                            color: Colors.white,
                                                            size: 22,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 16),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Event Actions',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              Text(
                                                                'Quick links for this event',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 24),

                                                    // 2. Side-by-Side Action Boxes
                                                    Row(
                                                      children: [
                                                        // Left Box: Picklists
                                                        Expanded(
                                                          child: FilledButton(
                                                            style: ButtonStyle(
                                                              padding:
                                                                  MaterialStatePropertyAll(
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            20),
                                                              ),
                                                              foregroundColor:
                                                                  const WidgetStatePropertyAll(
                                                                      Colors
                                                                          .white),
                                                              backgroundColor:
                                                                  const WidgetStatePropertyAll(
                                                                      Colors
                                                                          .blue),
                                                              // Add the shape property here
                                                              shape:
                                                                  WidgetStatePropertyAll(
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8), // Lower this number for sharper corners
                                                                ),
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      '/picklist?group=${widget.group?.name}&event=${widget.group!.events[event_index].event_code}');
                                                            },
                                                            child: const Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .format_list_numbered_rounded,
                                                                    size: 28),
                                                                SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                  'Picklists',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width:
                                                                12), // Spacing between the boxes

                                                        // Right Box: Scouting Report
                                                        Expanded(
                                                          child: FilledButton
                                                              .tonal(
                                                            style: ButtonStyle(
                                                              padding:
                                                                  MaterialStatePropertyAll(
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            20),
                                                              ),
                                                              foregroundColor:
                                                                  const WidgetStatePropertyAll(
                                                                      Colors
                                                                          .white),
                                                              backgroundColor:
                                                                  const WidgetStatePropertyAll(
                                                                      Colors
                                                                          .blueGrey),
                                                              // Add the shape property here
                                                              shape:
                                                                  WidgetStatePropertyAll(
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8), // Lower this number for sharper corners
                                                                ),
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      '/group/${widget.group?.name}/events/${widget.group!.events[event_index].event_code}/scouting_report');
                                                            },
                                                            child: const Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .description_outlined,
                                                                    size: 28),
                                                                SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                  'Scouting\nReport', // Line break keeps it neat
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      height:
                                                                          1.1),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 20),
                                                    Divider(
                                                        color: Colors.blue,
                                                        height: 1),
                                                    const SizedBox(height: 20),

                                                    // 3. Destructive Action (Kept at the bottom as requested)
                                                    OutlinedButton.icon(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        foregroundColor:
                                                            Colors.red,
                                                        minimumSize: const Size
                                                            .fromHeight(48),
                                                        side: BorderSide(
                                                            color: Colors.red
                                                                .withOpacity(
                                                                    0.5)),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                      ),
                                                      onPressed: () {
                                                        apiService
                                                            .remove_event_from_group(
                                                                widget.group
                                                                        ?.name ??
                                                                    '',
                                                                widget
                                                                        .group
                                                                        ?.events[
                                                                            event_index]
                                                                        .event_code ??
                                                                    '')
                                                            .then((data) {
                                                          var (_group, role) =
                                                              data;
                                                          widget.widget.group =
                                                              _group;
                                                          widget.widget
                                                                  .membership =
                                                              role;
                                                        }).onError((e, _) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  e.toString()),
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                            ),
                                                          );
                                                        });
                                                      },
                                                      icon: const Icon(
                                                          Icons.logout_rounded),
                                                      label: const Text(
                                                          'Leave Event'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ])))));
                }),
        )
      ]))
    ]);
  }
}

class _MembersTab extends StatefulWidget {
  final _GroupPageState widget;
  final Group? group;
  final String? membership;
  _MembersTab(
    this.widget, {
    Key? key,
    this.group,
    this.membership,
  }) : super(key: key);
  @override
  _MembersTabState createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  Map? members;
  List<GroupJoinRequest>? requests = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.get_group_members(widget.group?.name ?? '').then((value) {
      members = value;
      if (mounted) {
        setState(() {
          members = value;
        });
      }
      apiService
          .get_group_join_requests(widget.group?.name ?? '')
          .then((value) {
        requests = value;
        loading = false;
        if (mounted) {
          setState(() {
            requests = value;
            loading = false;
          });
        }
      }).onError((e, _) {
        loading = false;
        if (mounted)
          setState(() {
            loading = false;
          });
      });
    });
  }

  // Add drag-to-refresh functionality
  Future<void> _refreshData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      loading = true;
    });
    await apiService.get_group_members(widget.group?.name ?? '').then((value) {
      members = value;
      if (mounted) {
        setState(() {
          members = value;
        });
      }
    });
    await apiService
        .get_group_join_requests(widget.group?.name ?? '')
        .then((value) {
      requests = value;
      if (mounted) {
        setState(() {
          requests = value;
          loading = false;
        });
      }
    }).onError((e, _) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(
      context,
    );
    final filteredRequests =
        requests?.where((request) => !request.accepted).toList();
    return loading
        ? Center(child: CircularProgressIndicator(color: Colors.blue))
        : RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  height: 10,
                ),
                if (widget.membership != 'member')
                  Card(
                      child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('Join Requests',
                            style:
                                TextStyle(color: Colors.white, fontSize: 30)),
                        if ((filteredRequests?.length ?? 0) == 0)
                          Text('No Pending Join Requests'),
                        ExpansionPanelList.radio(elevation: 0, children: [
                          ...List.generate(
                            filteredRequests?.length ?? 0,
                            (requestIndex) => ExpansionPanelRadio(
                                canTapOnHeader: true,
                                backgroundColor: Color.fromARGB(0, 0, 0, 0),
                                value: filteredRequests![requestIndex],
                                headerBuilder: (context, isExpanded) {
                                  return ListTile(
                                    title: Text(
                                        'Username: ${filteredRequests[requestIndex].username}\nTime of Request: ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(filteredRequests[requestIndex].request_time * 1000).toLocal())}'),
                                  );
                                },
                                body: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        apiService
                                            .accept_join_request(
                                                filteredRequests[requestIndex])
                                            .then((value) {
                                          setState(() {
                                            requests = value;
                                          });
                                          apiService
                                              .get_group_members(
                                                  widget.group!.name)
                                              .then(
                                                (Map _members) => setState(() {
                                                  members = _members;
                                                }),
                                              );
                                        });
                                      },
                                      style: ButtonStyle(
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.green)),
                                      icon: Icon(Icons.check_rounded),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        apiService
                                            .decline_join_request(
                                                filteredRequests[requestIndex])
                                            .then((value) {
                                          setState(() {
                                            requests = value;
                                          });
                                        });
                                      },
                                      style: ButtonStyle(
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.red)),
                                      icon: Icon(Icons.close_rounded),
                                    )
                                  ],
                                )),
                          )
                        ]),
                      ],
                    ),
                  )),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(children: [
                      Text(
                        'Owners',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      ExpansionPanelList.radio(
                        dividerColor: Colors.blue,
                        elevation: 0,
                        children: List.generate(
                            members?['owners'].length,
                            (index) => ExpansionPanelRadio(
                                  canTapOnHeader: true,
                                  backgroundColor: Color.fromARGB(0, 0, 0, 0),
                                  value: members?['owners'][index],
                                  headerBuilder: (context, isExpanded) {
                                    return Padding(
                                      child: Text(
                                          'Owner: ${members?['owners'][index]['firstName']}'),
                                      padding: EdgeInsets.all(20),
                                    );
                                  },
                                  body: Text(
                                      members?['owners'][index]['username']),
                                )),
                      ),
                    ]),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(children: [
                      Text(
                        'Admins',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      ExpansionPanelList.radio(
                        dividerColor: Colors.blue,
                        elevation: 0,
                        children: List.generate(
                          members?['admins'].length,
                          (index) => ExpansionPanelRadio(
                              canTapOnHeader: true,
                              backgroundColor: Color.fromARGB(0, 0, 0, 0),
                              value: members?['admins'][index],
                              headerBuilder: (context, isExpanded) {
                                return Padding(
                                  child: Text(
                                      'Admin ${index + 1}: ${members?['admins'][index]['firstName']}'),
                                  padding: EdgeInsets.all(20),
                                );
                              },
                              body: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(members?['admins'][index]['username']),
                                    if (widget.membership == 'owner')
                                      SizedBox(width: 8),
                                    if (widget.membership == 'owner')
                                      ElevatedButton(
                                          onPressed: () {
                                            apiService
                                                .demote_group_member(
                                                    widget.group?.name ?? '',
                                                    members?['admins'][index]
                                                        ['id'])
                                                .then((value) {
                                              setState(() {
                                                members = value;
                                              });
                                            });
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.red),
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.white)),
                                          child: Text('Demote to Member')),
                                    if (widget.membership == 'owner')
                                      SizedBox(width: 8),
                                    if (widget.membership == 'owner')
                                      ElevatedButton(
                                        onPressed: () {
                                          apiService
                                              .promote_group_admin(
                                                  widget.group?.name ?? '',
                                                  members?['admins'][index]
                                                      ['id'])
                                              .then((value) {
                                            setState(() {
                                              members = value;
                                            });
                                          });
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.yellow),
                                            foregroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.black)),
                                        child: Text('Promote to Owner'),
                                      )
                                  ],
                                ),
                              )),
                        ),
                      ),
                      if (members?['admins'].length == 0)
                        Text('There are no admins in your group')
                    ]),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(children: [
                      Text(
                        'Members',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      ExpansionPanelList.radio(
                        dividerColor: Colors.blue,
                        elevation: 0,
                        children: List.generate(
                          members?['members'].length,
                          (index) => ExpansionPanelRadio(
                              canTapOnHeader: true,
                              backgroundColor: Color.fromARGB(0, 0, 0, 0),
                              value: members?['members'][index],
                              headerBuilder: (context, isExpanded) {
                                return Padding(
                                  child: Text(
                                      'Member ${index + 1}: ${members?['members'][index]['firstName']}'),
                                  padding: EdgeInsets.all(20),
                                );
                              },
                              body: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!(widget.membership == 'owner' ||
                                          widget.membership == 'admin'))
                                        Text(
                                            'username: ${members?['members'][index]['username']}'),
                                      if (widget.membership == 'owner' ||
                                          widget.membership == 'admin')
                                        SizedBox(
                                          width: 10,
                                        ),
                                      if (widget.membership == 'owner' ||
                                          widget.membership == 'admin')
                                        ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        Colors.red),
                                                foregroundColor:
                                                    WidgetStatePropertyAll(
                                                        Colors.white)),
                                            onPressed: () {
                                              apiService
                                                  .kick_group_member(
                                                      widget.group?.name ?? '',
                                                      members?['members'][index]
                                                          ['id'])
                                                  .then((value) {
                                                setState(() {
                                                  members = value;
                                                });
                                              });
                                            },
                                            child: Text('Kick')),
                                      if (widget.membership == 'owner')
                                        SizedBox(
                                          width: 10,
                                        ),
                                      if (widget.membership == 'owner')
                                        ElevatedButton(
                                            onPressed: () {
                                              apiService
                                                  .promote_group_member(
                                                      widget.group?.name ?? '',
                                                      members?['members'][index]
                                                          ['id'])
                                                  .then((value) {
                                                setState(() {
                                                  members = value;
                                                });
                                              });
                                            },
                                            child: Text('Promote to Admin')),
                                    ]),
                              )),
                        ),
                      ),
                      if (members?['members'].length == 0)
                        Text('There are no members in your group')
                    ]),
                  ),
                ),
              ]),
            ));
  }
}

class _SettingsTab extends StatefulWidget {
  final _GroupPageState widget;
  final Group? group;
  final String? membership;
  _SettingsTab(
    this.widget, {
    Key? key,
    this.group,
    this.membership,
  }) : super(key: key);
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 10,
      ),
      Card(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: ElevatedButton(
            onPressed: _openConfirmDelete,
            child: Text('Delete Group', style: TextStyle(fontFamily: 'Font')),
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.red),
                foregroundColor: WidgetStatePropertyAll(Colors.white))),
      )),
      Card(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'More Settings Coming Soon...',
          style:
              TextStyle(color: Colors.blue, fontSize: 30.0, fontFamily: 'Font'),
        ),
      ))
    ]);
  }

  _openConfirmDelete() {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Group', style: TextStyle(fontFamily: 'Font')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to delete this group?',
                  style: TextStyle(fontFamily: 'Font')),
              Text('Please type "${widget.group!.name}" to confirm:',
                  style: TextStyle(fontFamily: 'Font')),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                    hintText: 'Group Name',
                    labelStyle:
                        TextStyle(fontFamily: 'Font', color: Colors.blue),
                    floatingLabelStyle:
                        TextStyle(fontFamily: 'Font', color: Colors.blue)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(fontFamily: 'Font')),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text == widget.group!.name) {
                  Navigator.of(context).pushNamed('/');
                  final apiService =
                      Provider.of<ApiService>(context, listen: false);
                  apiService
                      .delete_group(widget.group!.name)
                      .then((value) {})
                      .onError((e, _) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString(),
                            style: TextStyle(fontFamily: 'Font'))));
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Group name does not match',
                            style: TextStyle(fontFamily: 'Font'))),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(fontFamily: 'Font')),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.red),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OfflineScoutingTab extends StatefulWidget {
  @override
  _OfflineScoutingTabState createState() => _OfflineScoutingTabState();
}

class _OfflineScoutingTabState extends State<_OfflineScoutingTab> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  TextEditingController _textController = TextEditingController();
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    this.controller = controller;
    try {
      final jsonData = jsonDecode(_textController.text);
      final matchData = MatchScouting2026.fromJson(jsonData);

      // Submit the scanned data
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.post_offline_match_scouting(matchData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Match data submitted successfully!',
                style: TextStyle(fontFamily: 'Font'))),
      );
      setState(() {
        _textController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${e.toString()}',
                style: TextStyle(fontFamily: 'Font'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => Column(
              children: [
                Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight - 96,
                    child: Card(
                        child: Padding(
                      padding: EdgeInsets.all(20),
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: (QRViewController controller) {
                          this.controller = controller;
                          controller.scannedDataStream.listen((scanData) {
                            try {
                              final jsonData = jsonDecode(scanData.code!);
                              final matchData =
                                  MatchScouting2026.fromJson(jsonData);

                              // Update the text field with the scanned data
                              final prevText = _textController.text;
                              setState(() {
                                setState(() {
                                  _textController.text =
                                      jsonEncode(matchData.toJson());
                                });
                              });
                              if (prevText != _textController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Scan Successful',
                                          style:
                                              TextStyle(fontFamily: 'Font'))),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error: ${e.toString()}',
                                        style: TextStyle(fontFamily: 'Font'))),
                              );
                            }
                          });
                        },
                      ),
                    ))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                            labelText: 'Enter Data Manually',
                            border: OutlineInputBorder(),
                            floatingLabelStyle: TextStyle(
                                fontFamily: 'Font', color: Colors.blue),
                            labelStyle: TextStyle(
                                fontFamily: 'Font', color: Colors.blue)),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      // SizedBox(height: 10),
                      ElevatedButton(
                          onPressed:
                              _textController.text.isEmpty ? null : _onSubmit,
                          child: Text('Submit',
                              style: TextStyle(fontFamily: 'Font')))
                    ],
                  ),
                ),
              ],
            ));
  }
}
