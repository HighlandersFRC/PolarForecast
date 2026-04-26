import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/pit_scouting_2026.dart';

import 'package:scouting_app/widgets/auto_pieces_2026.dart';
import 'package:scouting_app/utils.dart';
import 'package:scouting_app/widgets/counter.dart';
import 'package:scouting_app/widgets/floatyCounter.dart';
import 'package:scouting_app/widgets/integer_counter.dart';
import '../api_service.dart';
import '../models/scout_info.dart';
import '../models/tournament.dart';

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

class PitScoutingForm extends StatefulWidget {
  const PitScoutingForm(
    this.tournament,
    this.teamNumber,
    this.locked,
  );
  final bool locked;
  final int teamNumber;
  final Tournament tournament;
  @override
  _PitScoutingFormState createState() => _PitScoutingFormState();
}

class _PitScoutingFormState extends State<PitScoutingForm> {
  final TextEditingController driveTrainController = TextEditingController();
  final TextEditingController typeOfShooterController = TextEditingController();
  final List<String> dropdownOptions = ['Blue Side', 'Red Side', 'Both'];
  final List<String> dropdownOptionsShooter = [
    'Single',
    'Single with Hood',
    'Double',
    'Double with Hood',
    'Multi',
    'Multi with Hood',
    'Turret',
    'Turret with Hood',
    'Multi Turret',
    'Multi Turret with Hood',
    'Other'
  ];

  final TextEditingController favoriteColorController = TextEditingController();
  final TextEditingController mainStrategyController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  bool formSubmitted = false;
  bool loading = true;
  late PitScouting2026 pitScoutingData = PitScouting2026(
      scout_info:
          ScoutInfo(team_number: 0, first_name: '', user_id: '', username: ''),
      team_number: widget.teamNumber,
      event_code: widget.tournament.key,
      data: PitData2026(
          comments: '',
          driver_experience_events: 0,
          type_of_shooter: '',
          drive_train: '',
          climbing: [],
          spare_parts: 0,
          favorite_color: '',
          autos: [],
          fixedShooting: false,
          nearTower: false,
          nearHub: false,
          go_under_trench: false,
          can_climb: false,
          can_climb_in_autonomous: false,
          auto: Auto2026(
              starting_position_meters_from_hub_center: 0,
              steps: [],
              field_side: [],
              preload: false,
              climb: false,
              contacts_robot: false),
          main_strategy: '',
          hopper_capacity: 0,
          bps: 0,
          robot_height: 0,
          straddling_pole_climb_right: false,
          straddling_pole_climb_left: false,
          left_pole_climb: false,
          right_pole_climb: false,
          center_pole_climb: false),
      time: (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000).toDouble(),
      user_id: '',
      auto: Auto2026(
          starting_position_meters_from_hub_center: 0,
          steps: [],
          field_side: [],
          preload: false,
          climb: false,
          contacts_robot: false));
  final TextEditingController sparePartsController = TextEditingController();

  @override
  void dispose() {
    driveTrainController.dispose();
    sparePartsController.dispose();
    favoriteColorController.dispose();
    typeOfShooterController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchPitScoutingData();
  }

  void fetchPitScoutingData() async {
    final api = Provider.of<ApiService>(context, listen: false);

    api.token.then((token) {
      api
          .fetchTeamPitScouting(
            widget.tournament.page.split('/')[3],
            widget.tournament.page.split('/')[4],
            'frc${widget.teamNumber}',
          )
          .then((fetchedData) => setState(() {
                pitScoutingData = fetchedData;
                loading = false;
                driveTrainController.text = pitScoutingData.data.drive_train;
                typeOfShooterController.text =
                    pitScoutingData.data.type_of_shooter;
                sparePartsController.text =
                    pitScoutingData.data.spare_parts.toString();
                favoriteColorController.text =
                    pitScoutingData.data.favorite_color;
                mainStrategyController.text =
                    pitScoutingData.data.main_strategy;
                commentsController.text = pitScoutingData.data.comments;
              }))
          .onError((e, _) {
        loading = false;
      });
      if (token != null && !widget.locked) {
        pitScoutingData =
            pitScoutingData.copyWith(scout_info: get_scout_info(token));
        if (mounted) {
          setState(() {
            pitScoutingData =
                pitScoutingData.copyWith(scout_info: get_scout_info(token));
          });
        }
      }
    });
  }

  void handleChange(String field, dynamic value) {
    HapticFeedback.lightImpact();
    setState(() {
      switch (field) {
        case 'drive_train':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(drive_train: value),
          );
          break;
        case 'type_of_shooter':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(type_of_shooter: value),
          );
          break;
        case 'spare_parts':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(spare_parts: value),
          );
          break;
        case 'main_strategy':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(main_strategy: value),
          );
          break;
        case 'comments':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(comments: value),
          );
          break;
        case 'fixedShooting':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(fixedShooting: value),
          );
          break;
        case 'nearTower':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(nearTower: value),
          );
          break;
        case 'nearHub':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(nearHub: value),
          );
          break;
        case 'robot_height':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(robot_height: value),
          );
          break;
        case 'hopper_capacity':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(hopper_capacity: value),
          );
          break;
        case 'bps':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(bps: value));
          break;
        case 'go_under_trench':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(go_under_trench: value),
          );
          break;
        case 'straddling_pole_climb_right':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data
                  .copyWith(straddling_pole_climb_right: value));
          break;
        case 'straddling_pole_climb_left':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data
                  .copyWith(straddling_pole_climb_left: value));
          break;
        case 'left_pole_climb':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(left_pole_climb: value));
          break;
        case 'right_pole_climb':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(right_pole_climb: value));
          break;
        case 'center_pole_climb':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(center_pole_climb: value));
          break;
        case 'can_climb':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(can_climb: value),
          );
          break;
        case 'climbing':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(climbing: value),
          );
          break;
        case 'can_climb_in_autonomous':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(can_climb_in_autonomous: value),
          );
          break;
        case 'favorite_color':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(favorite_color: value),
          );
          break;
      }
    });
  }

  void handleAddAuto() {
    HapticFeedback.lightImpact();
    setState(() {
      pitScoutingData = pitScoutingData.copyWith(
        data: pitScoutingData.data.copyWith(
          autos: List.from(pitScoutingData.data.autos as Iterable<dynamic>)
            ..add(
              Auto2026(
                  starting_position_meters_from_hub_center: 0,
                  steps: [],
                  field_side: ['red', 'blue'],
                  preload: false,
                  climb: false,
                  contacts_robot: false),
            ),
        ),
      );
    });
  }

  void handleSubmit() async {
    // Collect missing fields
    final missingFields = [
      if (pitScoutingData.data.favorite_color.isEmpty) 'Favorite Color',
      if (pitScoutingData.data.drive_train.isEmpty) 'Drive Train',
      if (pitScoutingData.data.type_of_shooter.isEmpty) 'Type of Shooter',
      if (pitScoutingData.data.main_strategy.isEmpty) 'Main Strategy',
      if (pitScoutingData.data.autos?.isEmpty ?? true) 'Autos',
    ];

    if (missingFields.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Missing Fields',
                    style: const TextStyle(
                      fontFamily: 'Font',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You are missing the following fields:',
                    style: const TextStyle(
                      fontFamily: 'Font',
                      fontSize: 16,
                      color: Color.fromARGB(221, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // List of missing fields with icon
                  ...missingFields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            field,
                            style: const TextStyle(
                              fontFamily: 'Font',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(221, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Do you want to submit anyway?',
                    style: const TextStyle(
                      fontFamily: 'Font',
                      fontSize: 16,
                      color: Color.fromARGB(137, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Font',
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(107, 255, 255, 0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Submit Incomplete',
                          style: TextStyle(
                            fontFamily: 'Font',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );

      if (confirm != true) return; // Stop submission if user cancels
    }

    // Proceed with submission
    final api = Provider.of<ApiService>(context, listen: false);
    final status = await api.postPitScouting(
      pitScoutingData,
      widget.tournament.page.split('/')[3],
      widget.tournament.page.split('/')[4],
      'frc${widget.teamNumber}',
    );

    if (status == 200) {
      HapticFeedback.mediumImpact();
      setState(() => formSubmitted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    } else {
      HapticFeedback.heavyImpact();
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Submission Error',
                  style: const TextStyle(
                    fontFamily: 'Font',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Submission failed. Please try again.',
                  style: const TextStyle(
                    fontFamily: 'Font',
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Font',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  void handleEditForm() {
    setState(() {
      formSubmitted = false;
    });
  }

  void handleGoBack(BuildContext context) {
    Navigator.pushNamed(context, '/event/${widget.tournament.key}');
  }

  Widget _buildSectionCard({
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(16.0),
        child: formSubmitted
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Submission Successful',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                          fontFamily: 'Font'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: handleEditForm,
                      child: Text('Edit Form',
                          style: TextStyle(fontFamily: 'Font')),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => handleGoBack(context),
                      child:
                          Text('Go Back', style: TextStyle(fontFamily: 'Font')),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final isMobile = maxWidth < 600;

                // On desktop, limit width
                final cardWidth = isMobile ? maxWidth : min(maxWidth, 900.0);

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
                  Center(
                      child: SizedBox(
                    width: cardWidth,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 20 : 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scout: ${pitScoutingData.scout_info.first_name ?? 'Scout From ${pitScoutingData.scout_info.team_number}'}',
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.blue,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Questions',
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.blue,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.blue),
                              _buildSectionCard(
                                  child: Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: [
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8,
                                            children: [
                                              Icon(Icons.check,
                                                  color: Colors.blue),
                                              SizedBox(width: 4),
                                              Text(' / ',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 20)),
                                              SizedBox(width: 4),
                                              Icon(Icons.close,
                                                  color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text('True / False Questions',
                                                  style: TextStyle(
                                                      fontFamily: 'Font',
                                                      fontSize:
                                                          isMobile ? 14 : 30,
                                                      color: Colors.blue))
                                            ],
                                          )
                                        ],
                                      )),
                                  Card(
                                    color: Color.fromARGB(24, 68, 137,
                                        255), // light blue background
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Column(
                                        children: [
                                          SwitchListTile(
                                            activeThumbColor: Colors.blue,
                                            inactiveThumbColor: Colors.blue,
                                            title: Text('Can Go Under Trench',
                                                style: TextStyle(
                                                    fontFamily: 'Font')),
                                            value: pitScoutingData
                                                .data.go_under_trench,
                                            onChanged: widget.locked
                                                ? null
                                                : (value) => handleChange(
                                                    'go_under_trench', value),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.blue,
                                    thickness: 5,
                                    radius: BorderRadius.circular(10),
                                  ),
                                  // Climbing Abilities
                                  Card(
                                    color: Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Column(
                                        children: [
                                          SwitchListTile(
                                            activeThumbColor: Colors.blue,
                                            inactiveThumbColor: Colors.blue,
                                            title: Text(
                                                'Fixed Shooting Distance',
                                                style: TextStyle(
                                                    fontFamily: 'Font')),
                                            value: pitScoutingData
                                                .data.fixedShooting,
                                            onChanged: widget.locked
                                                ? null
                                                : (value) => handleChange(
                                                    'fixedShooting', value),
                                          ),
                                          AnimatedSwitcher(
                                            key: ValueKey(pitScoutingData
                                                .data.fixedShooting),
                                            duration: const Duration(
                                                milliseconds: 250),
                                            child: !pitScoutingData
                                                    .data.fixedShooting
                                                ? SizedBox.shrink()
                                                : Column(
                                                    key: const ValueKey(
                                                        'fixedShooting_options'),
                                                    children: [
                                                      Divider(
                                                          color: Colors.blue,
                                                          thickness: 4,
                                                          radius: BorderRadius
                                                              .circular(10)),
                                                      SwitchListTile(
                                                        activeThumbColor:
                                                            Colors.blue,
                                                        inactiveThumbColor:
                                                            Colors.blue,
                                                        title: Text(
                                                            'Shoots near the Tower',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font')),
                                                        value: pitScoutingData
                                                            .data.nearTower,
                                                        onChanged: widget.locked
                                                            ? null
                                                            : (value) =>
                                                                handleChange(
                                                                    'nearTower',
                                                                    value),
                                                      ),
                                                      SwitchListTile(
                                                        activeThumbColor:
                                                            Colors.blue,
                                                        inactiveThumbColor:
                                                            Colors.blue,
                                                        title: Text(
                                                            'Shoot near the Hub',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font')),
                                                        value: pitScoutingData
                                                            .data.nearHub,
                                                        onChanged: widget.locked
                                                            ? null
                                                            : (value) =>
                                                                handleChange(
                                                                    'nearHub',
                                                                    value),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.blue,
                                    thickness: 5,
                                    radius: BorderRadius.circular(10),
                                  ),
                                  // Climbing Abilities
                                  Card(
                                    color: Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Column(
                                        children: [
                                          SwitchListTile(
                                            activeThumbColor: Colors.blue,
                                            inactiveThumbColor: Colors.blue,
                                            title: Text('Can Climb',
                                                style: TextStyle(
                                                    fontFamily: 'Font')),
                                            value:
                                                pitScoutingData.data.can_climb,
                                            onChanged: widget.locked
                                                ? null
                                                : (value) => handleChange(
                                                    'can_climb', value),
                                          ),
                                          AnimatedSwitcher(
                                            key: ValueKey(
                                                pitScoutingData.data.can_climb),
                                            duration: const Duration(
                                                milliseconds: 250),
                                            child: !pitScoutingData
                                                    .data.can_climb
                                                ? SizedBox.shrink()
                                                : Column(
                                                    key: const ValueKey(
                                                        'climb_options'),
                                                    children: [
                                                      Divider(
                                                          color: Colors.blue,
                                                          thickness: 4,
                                                          radius: BorderRadius
                                                              .circular(10)),
                                                      SwitchListTile(
                                                        activeThumbColor:
                                                            Colors.blue,
                                                        inactiveThumbColor:
                                                            Colors.blue,
                                                        title: Text(
                                                            'Can Climb in Autonomous',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font')),
                                                        value: pitScoutingData
                                                            .data
                                                            .can_climb_in_autonomous,
                                                        onChanged: widget.locked
                                                            ? null
                                                            : (value) =>
                                                                handleChange(
                                                                    'can_climb_in_autonomous',
                                                                    value),
                                                      ),
                                                      SwitchListTile(
                                                        activeThumbColor:
                                                            Colors.blue,
                                                        inactiveThumbColor:
                                                            Colors.blue,
                                                        title: Text(
                                                            'Straddles the Pole Right',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font')),
                                                        value: pitScoutingData
                                                            .data
                                                            .straddling_pole_climb_right,
                                                        onChanged: widget.locked
                                                            ? null
                                                            : (value) =>
                                                                handleChange(
                                                                    'straddling_pole_climb_right',
                                                                    value),
                                                      ),
                                                      SwitchListTile(
                                                        activeThumbColor:
                                                            Colors.blue,
                                                        inactiveThumbColor:
                                                            Colors.blue,
                                                        title: Text(
                                                            'Straddles the Pole Left',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font')),
                                                        value: pitScoutingData
                                                            .data
                                                            .straddling_pole_climb_left,
                                                        onChanged: widget.locked
                                                            ? null
                                                            : (value) =>
                                                                handleChange(
                                                                    'straddling_pole_climb_left',
                                                                    value),
                                                      ),
                                                      SwitchListTile(
                                                        activeThumbColor:
                                                            Colors.blue,
                                                        inactiveThumbColor:
                                                            Colors.blue,
                                                        title: Text(
                                                            'Climbs from Pole Left',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font')),
                                                        value: pitScoutingData
                                                            .data
                                                            .left_pole_climb,
                                                        onChanged: widget.locked
                                                            ? null
                                                            : (value) =>
                                                                handleChange(
                                                                    'left_pole_climb',
                                                                    value),
                                                      ),
                                                      SwitchListTile(
                                                        activeThumbColor:
                                                            Colors.blue,
                                                        inactiveThumbColor:
                                                            Colors.blue,
                                                        title: Text(
                                                            'Climbs from Pole Right',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font')),
                                                        value: pitScoutingData
                                                            .data
                                                            .right_pole_climb,
                                                        onChanged: widget.locked
                                                            ? null
                                                            : (value) =>
                                                                handleChange(
                                                                    'right_pole_climb',
                                                                    value),
                                                      ),
                                                      SwitchListTile(
                                                        activeThumbColor:
                                                            Colors.blue,
                                                        inactiveThumbColor:
                                                            Colors.blue,
                                                        title: Text(
                                                            'Climbs from the Center',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font')),
                                                        value: pitScoutingData
                                                            .data
                                                            .center_pole_climb,
                                                        onChanged: widget.locked
                                                            ? null
                                                            : (value) =>
                                                                handleChange(
                                                                    'center_pole_climb',
                                                                    value),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              Divider(color: Colors.blue),
                              _buildSectionCard(
                                  child: Column(
                                children: [
                                  // Section Title
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Icon(Icons.tune,
                                                color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text('Quantitative Questions',
                                                style: TextStyle(
                                                    fontSize:
                                                        isMobile ? 22 : 30,
                                                    color: Colors.blue,
                                                    fontFamily: 'Font')),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  // Distance to Shoot
                                  Card(
                                    color: Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),

                                  // Robot Height
                                  Card(
                                    color: Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: FloatyCounter(
                                        locked: widget.locked,
                                        label: 'Robot Height (Inches)',
                                        value:
                                            pitScoutingData.data.robot_height,
                                        max: 30,
                                        onChanged: (height) {
                                          setState(() {
                                            pitScoutingData =
                                                pitScoutingData.copyWith(
                                                    data: pitScoutingData.data
                                                        .copyWith(
                                                            robot_height:
                                                                height));
                                          });
                                        },
                                      ),
                                    ),
                                  ),

                                  Card(
                                    color: Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: FloatyCounter(
                                        locked: widget.locked,
                                        label: 'Fuel Per Second',
                                        value: pitScoutingData.data.bps,
                                        max: 30,
                                        onChanged: (speed) {
                                          setState(() {
                                            pitScoutingData =
                                                pitScoutingData.copyWith(
                                                    data: pitScoutingData.data
                                                        .copyWith(bps: speed));
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  // Hopper Capacity
                                  Card(
                                    color: Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: IntegerCounter(
                                        locked: widget.locked,
                                        label: 'Hopper Capacity',
                                        value: pitScoutingData
                                            .data.hopper_capacity,
                                        max: 1000,
                                        onChanged: (capacity) {
                                          setState(() {
                                            pitScoutingData =
                                                pitScoutingData.copyWith(
                                                    data: pitScoutingData.data
                                                        .copyWith(
                                                            hopper_capacity:
                                                                capacity));
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              Divider(
                                color: Colors.blue,
                              ),
                              _buildSectionCard(
                                  child: Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Icon(Icons.star_border_outlined,
                                              color: Colors.blue),
                                          Text(
                                            'Qualitative Questions',
                                            style: TextStyle(
                                              fontSize: isMobile ? 22 : 30,
                                              color: Colors.blue,
                                              fontFamily: 'Font',
                                            ),
                                          ),
                                        ],
                                      )),
                                  // Favorite Color
                                  Card(
                                    color:
                                        const Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Favorite Color',
                                              style: TextStyle(
                                                  fontFamily: 'Font',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: favoriteColorController,
                                            enabled: !widget.locked,
                                            style:
                                                TextStyle(fontFamily: 'Font'),
                                            onChanged: widget.locked
                                                ? null
                                                : (val) => handleChange(
                                                    'favorite_color', val),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    color:
                                        const Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Type of Shooter',
                                                style: TextStyle(
                                                  fontFamily: 'Font',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Builder(
                                                builder: (context) =>
                                                    GestureDetector(
                                                  onTapDown: (details) async {
                                                    await showMenu(
                                                      context: context,
                                                      position:
                                                          RelativeRect.fromLTRB(
                                                        details
                                                            .globalPosition.dx,
                                                        details
                                                            .globalPosition.dy,
                                                        details
                                                            .globalPosition.dx,
                                                        details
                                                            .globalPosition.dy,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      items: [
                                                        PopupMenuItem(
                                                          enabled: false,
                                                          child: SizedBox(
                                                            width: 220,
                                                            child: Text(
                                                              'Single: One shooter\n\n'
                                                              'Double: Two shooters\n\n'
                                                              'Multi: Multiple shooters\n\n'
                                                              'Turret: Rotates to aim\n\n'
                                                              'Hood: Adjustable angle',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Font'),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.info_outline,
                                                    size: 18,
                                                    color: Colors.blueAccent
                                                        .withOpacity(0.8),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButton<String>(
                                            isExpanded: true,
                                            value: pitScoutingData
                                                .data.type_of_shooter,
                                            items: [
                                              DropdownMenuItem(
                                                value: '',
                                                child: Text('Choose...',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Single',
                                                child: Text('Single',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Single with Hood',
                                                child: Text('Single with Hood',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Double',
                                                child: Text('Double',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Double with Hood',
                                                child: Text('Double with Hood',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Multi',
                                                child: Text('Multi',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Multi with Hood',
                                                child: Text('Multi with Hood',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Turret',
                                                child: Text('Turret',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Turret with Hood',
                                                child: Text('Turret with Hood',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Multi Turret',
                                                child: Text('Multi Turret',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Multi Turret with Hood',
                                                child: Text(
                                                    'Multi Turret with Hood',
                                                    style: TextStyle(
                                                        fontFamily: 'Font')),
                                              ),
                                            ],
                                            onChanged: widget.locked
                                                ? null
                                                : (val) {
                                                    if (val != null) {
                                                      handleChange(
                                                          'type_of_shooter',
                                                          val);
                                                    }
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Drive Train
                                  Card(
                                    color:
                                        const Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Drive Train',
                                              style: TextStyle(
                                                  fontFamily: 'Font',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(height: 8),
                                          DropdownButton<String>(
                                            isExpanded: true,
                                            value: pitScoutingData
                                                .data.drive_train,
                                            items: [
                                              DropdownMenuItem(
                                                  value: '',
                                                  child: Text('Choose...',
                                                      style: TextStyle(
                                                          fontFamily: 'Font'))),
                                              DropdownMenuItem(
                                                  value: 'Tank',
                                                  child: Text('Tank',
                                                      style: TextStyle(
                                                          fontFamily: 'Font'))),
                                              DropdownMenuItem(
                                                  value: 'Swerve',
                                                  child: Text('Swerve',
                                                      style: TextStyle(
                                                          fontFamily: 'Font'))),
                                              DropdownMenuItem(
                                                  value: 'Mecanum',
                                                  child: Text('Mecanum',
                                                      style: TextStyle(
                                                          fontFamily: 'Font'))),
                                            ],
                                            onChanged: widget.locked
                                                ? null
                                                : (val) {
                                                    if (val != null)
                                                      handleChange(
                                                          'drive_train', val);
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // # of Events Driver has Driven
                                  Card(
                                    color:
                                        const Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('# of Events Driver has Driven',
                                              style: TextStyle(
                                                  fontFamily: 'Font',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(height: 8),
                                          Counter(
                                            label: '',
                                            value: pitScoutingData
                                                .data.driver_experience_events,
                                            max: 500,
                                            locked: widget.locked,
                                            onChanged: (val) {
                                              setState(() {
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                  data: pitScoutingData.data
                                                      .copyWith(
                                                          driver_experience_events:
                                                              val),
                                                );
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Main Strategy
                                  Card(
                                    color:
                                        const Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Main Strategy',
                                              style: TextStyle(
                                                  fontFamily: 'Font',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: mainStrategyController,
                                            enabled: !widget.locked,
                                            style:
                                                TextStyle(fontFamily: 'Font'),
                                            onChanged: widget.locked
                                                ? null
                                                : (val) => handleChange(
                                                    'main_strategy', val),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Card(
                                    color:
                                        const Color.fromARGB(24, 68, 137, 255),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Comments',
                                              style: TextStyle(
                                                  fontFamily: 'Font',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller: commentsController,
                                            enabled: !widget.locked,
                                            style:
                                                TextStyle(fontFamily: 'Font'),
                                            onChanged: widget.locked
                                                ? null
                                                : (val) => handleChange(
                                                    'comments', val),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              Divider(color: Colors.blue),
                              _buildSectionCard(
                                  child: Column(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.smart_toy_outlined,
                                              color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text(
                                            'Autonomous',
                                            style: TextStyle(
                                                fontSize: isMobile ? 22 : 30,
                                                color: Colors.blue,
                                                fontFamily: 'Font'),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: pitScoutingData.data.autos!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Card(
                                            child: Column(children: [
                                          AutoPieces2026(
                                            auto: pitScoutingData
                                                .data.autos![index],
                                            locked: widget.locked,
                                            onChanged: (newAuto) {
                                              setState(() {
                                                List<Auto2026> newAutos =
                                                    pitScoutingData.data.autos!
                                                        .toList();
                                                newAutos[index] = newAuto;

                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                  data: pitScoutingData.data
                                                      .copyWith(
                                                    autos: newAutos,
                                                  ),
                                                );
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          if (!widget.locked)
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  pitScoutingData =
                                                      pitScoutingData.copyWith(
                                                    data: pitScoutingData.data
                                                        .copyWith(
                                                      autos: List.from(
                                                          pitScoutingData
                                                                  .data.autos
                                                              as Iterable<
                                                                  dynamic>)
                                                        ..removeAt(index),
                                                    ),
                                                  );
                                                });
                                              },
                                            ),
                                        ])));
                                  },
                                )
                              ])),
                              if (!widget.locked)
                                ElevatedButton(
                                  onPressed:
                                      widget.locked ? () {} : handleAddAuto,
                                  child: Text('Add Auto',
                                      style: TextStyle(fontFamily: 'Font')),
                                ),
                              SizedBox(height: 20),
                              if (!widget.locked)
                                ElevatedButton(
                                  onPressed:
                                      widget.locked ? () {} : handleSubmit,
                                  child: Text('Submit',
                                      style: TextStyle(fontFamily: 'Font')),
                                ),
                            ]),
                      ),
                    ),
                  ))
                ]));
              }));
  }
}
