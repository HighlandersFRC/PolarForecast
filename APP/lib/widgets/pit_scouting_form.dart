import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/pit_scouting_2026.dart';

import 'package:scouting_app/widgets/auto_pieces_2026.dart';
import 'package:scouting_app/utils.dart';
import 'package:scouting_app/widgets/counter.dart';
import 'package:scouting_app/widgets/floatyCounter.dart';
import 'package:scouting_app/widgets/height_counter.dart';
import '../api_service.dart';
import '../models/scout_info.dart';
import '../models/tournament.dart';

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
  final List<String> dropdownOptions = ['Blue Side', 'Red Side', 'Both'];

  final TextEditingController favoriteColorController = TextEditingController();
  final TextEditingController mainStrategyController = TextEditingController();
  bool formSubmitted = false;
  bool loading = true;
  late PitScouting2026 pitScoutingData = PitScouting2026(
      scout_info:
          ScoutInfo(team_number: 0, first_name: '', user_id: '', username: ''),
      team_number: widget.teamNumber,
      event_code: widget.tournament.key,
      data: PitData2026(
          driver_experience_events: 0,
          drive_train: '',
          climbing: [],
          spare_parts: 0,
          favorite_color: '',
          autos: [],
          can_feed_human_player: false,
          can_pick_up_from_ground: false,
          distance_to_shoot: 0,
          go_over_bump: false,
          go_under_trench: false,
          can_climb: false,
          can_climb_in_autonomous: false,
          automatically_shooting: false,
          shooting_while_moving: false,
          auto: Auto2026(
              starting_position_meters_from_hub_center: 0,
              steps: [],
              field_side: [],
              preload: false,
              climb: false,
              contacts_robot: false),
          main_strategy: '',
          hopper_capacity: 0,
          mag_unload_speed: 0,
          robot_height: 0,
          straddling_pole_climb_right: false,
          straddling_pole_climb_left: false,
          left_pole_climb: false,
          right_pole_climb: false,
          center_pole_climb: false),
      time: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
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
                sparePartsController.text =
                    pitScoutingData.data.spare_parts.toString();
                favoriteColorController.text =
                    pitScoutingData.data.favorite_color;
                mainStrategyController.text =
                    pitScoutingData.data.main_strategy;
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
        case 'can_feed_human_player':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(can_feed_human_player: value),
          );
          break;
        case 'can_pick_up_from_ground':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(can_pick_up_from_ground: value),
          );
          break;
        case 'distance_to_shoot':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(distance_to_shoot: value),
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
        case 'mag_unload_speed':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(mag_unload_speed: value));
          break;
        case 'go_over_bump':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(go_over_bump: value),
          );
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
        case 'automatically_shooting':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(automatically_shooting: value),
          );
          break;
        case 'shooting_while_moving':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(shooting_while_moving: value),
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
                double maxWidth = constraints.maxWidth;

                // Limit max width for large screens
                double cardWidth = min(maxWidth, 900);

                // Base design width (what you designed UI for)
                double baseWidth = 900;

                double scaleFactor = (cardWidth / baseWidth);

                return Center(
                    child: SizedBox(
                        width: cardWidth,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(16.0 * scaleFactor),
                            child: Transform.scale(
                              scale: scaleFactor,
                              alignment: Alignment.topCenter,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Scout: ${pitScoutingData.scout_info.first_name ?? 'Scout From ${pitScoutingData.scout_info.team_number}'}',
                                            style: TextStyle(
                                                fontSize: 30 * scaleFactor,
                                                color: Colors.blue,
                                                fontFamily: 'Font'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Questions',
                                            style: TextStyle(
                                                fontSize: 30 * scaleFactor,
                                                color: Colors.blue,
                                                fontFamily: 'Font'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Divider(
                                      color: Colors.blue,
                                    ),
                                    SizedBox(
                                      height: 20,
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
                                                    fontSize: 30 * scaleFactor,
                                                    color: Colors.blue,
                                                    fontFamily: 'Font',
                                                  ),
                                                ),
                                              ],
                                            )),
                                        // Favorite Color
                                        Card(
                                          color: const Color.fromARGB(
                                              24, 68, 137, 255),
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
                                                        fontSize:
                                                            16 * scaleFactor,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      favoriteColorController,
                                                  enabled: !widget.locked,
                                                  style: TextStyle(
                                                      fontFamily: 'Font'),
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (val) => handleChange(
                                                          'favorite_color',
                                                          val),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Drive Train
                                        Card(
                                          color: const Color.fromARGB(
                                              24, 68, 137, 255),
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
                                                        fontSize:
                                                            16 * scaleFactor,
                                                        fontWeight:
                                                            FontWeight.w500)),
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
                                                                fontFamily:
                                                                    'Font'))),
                                                    DropdownMenuItem(
                                                        value: 'Tank',
                                                        child: Text('Tank',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font'))),
                                                    DropdownMenuItem(
                                                        value: 'Swerve',
                                                        child: Text('Swerve',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font'))),
                                                    DropdownMenuItem(
                                                        value: 'Mecanum',
                                                        child: Text('Mecanum',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Font'))),
                                                  ],
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (val) {
                                                          if (val != null)
                                                            handleChange(
                                                                'drive_train',
                                                                val);
                                                        },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // # of Events Driver has Driven
                                        Card(
                                          color: const Color.fromARGB(
                                              24, 68, 137, 255),
                                          elevation: 2,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '# of Events Driver has Driven',
                                                    style: TextStyle(
                                                        fontFamily: 'Font',
                                                        fontSize:
                                                            16 * scaleFactor,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                SizedBox(height: 8),
                                                Counter(
                                                  label: '',
                                                  value: pitScoutingData.data
                                                      .driver_experience_events,
                                                  max: 500,
                                                  locked: widget.locked,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      pitScoutingData =
                                                          pitScoutingData
                                                              .copyWith(
                                                        data: pitScoutingData
                                                            .data
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
                                          color: const Color.fromARGB(
                                              24, 68, 137, 255),
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
                                                        fontSize:
                                                            16 * scaleFactor,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                SizedBox(height: 8),
                                                TextField(
                                                  controller:
                                                      mainStrategyController,
                                                  enabled: !widget.locked,
                                                  style: TextStyle(
                                                      fontFamily: 'Font'),
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (val) => handleChange(
                                                          'main_strategy', val),
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
                                                            fontSize: 20 *
                                                                scaleFactor)),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.close,
                                                        color: Colors.blue),
                                                    SizedBox(width: 8),
                                                    Text(
                                                        'True / False Questions',
                                                        style: TextStyle(
                                                            fontFamily: 'Font',
                                                            fontSize: 30 *
                                                                scaleFactor,
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
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              children: [
                                                SwitchListTile(
                                                  activeThumbColor: Colors.blue,
                                                  inactiveThumbColor:
                                                      Colors.blue,
                                                  title: Text(
                                                      'Human Player Feed',
                                                      style: TextStyle(
                                                          fontFamily: 'Font')),
                                                  value: pitScoutingData.data
                                                      .can_feed_human_player,
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (value) => handleChange(
                                                          'can_feed_human_player',
                                                          value),
                                                ),
                                                SwitchListTile(
                                                  activeThumbColor: Colors.blue,
                                                  inactiveThumbColor:
                                                      Colors.blue,
                                                  title: Text('Ground Pickup',
                                                      style: TextStyle(
                                                          fontFamily: 'Font')),
                                                  value: pitScoutingData.data
                                                      .can_pick_up_from_ground,
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (value) => handleChange(
                                                          'can_pick_up_from_ground',
                                                          value),
                                                ),
                                                SwitchListTile(
                                                  activeThumbColor: Colors.blue,
                                                  inactiveThumbColor:
                                                      Colors.blue,
                                                  title: Text(
                                                      'Can Go Under Trench',
                                                      style: TextStyle(
                                                          fontFamily: 'Font')),
                                                  value: pitScoutingData
                                                      .data.go_under_trench,
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (value) => handleChange(
                                                          'go_under_trench',
                                                          value),
                                                ),
                                                SwitchListTile(
                                                  activeThumbColor: Colors.blue,
                                                  inactiveThumbColor:
                                                      Colors.blue,
                                                  title: Text(
                                                      'Can Go Over Bump',
                                                      style: TextStyle(
                                                          fontFamily: 'Font')),
                                                  value: pitScoutingData
                                                      .data.go_over_bump,
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (value) => handleChange(
                                                          'go_over_bump',
                                                          value),
                                                ),
                                                SwitchListTile(
                                                  activeThumbColor: Colors.blue,
                                                  inactiveThumbColor:
                                                      Colors.blue,
                                                  title: Text(
                                                      'Automatically Shooting',
                                                      style: TextStyle(
                                                          fontFamily: 'Font')),
                                                  value: pitScoutingData.data
                                                      .automatically_shooting,
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (value) => handleChange(
                                                          'automatically_shooting',
                                                          value),
                                                ),
                                                SwitchListTile(
                                                  activeThumbColor: Colors.blue,
                                                  inactiveThumbColor:
                                                      Colors.blue,
                                                  title: Text(
                                                      'Can Shoot While Moving',
                                                      style: TextStyle(
                                                          fontFamily: 'Font')),
                                                  value: pitScoutingData.data
                                                      .shooting_while_moving,
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (value) => handleChange(
                                                          'shooting_while_moving',
                                                          value),
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
                                          color:
                                              Color.fromARGB(24, 68, 137, 255),
                                          elevation: 2,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              children: [
                                                SwitchListTile(
                                                  activeThumbColor: Colors.blue,
                                                  inactiveThumbColor:
                                                      Colors.blue,
                                                  title: Text('Can Climb',
                                                      style: TextStyle(
                                                          fontFamily: 'Font')),
                                                  value: pitScoutingData
                                                      .data.can_climb,
                                                  onChanged: widget.locked
                                                      ? null
                                                      : (value) => handleChange(
                                                          'can_climb', value),
                                                ),
                                                AnimatedSwitcher(
                                                  key: ValueKey(pitScoutingData
                                                      .data.can_climb),
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
                                                                color: Colors
                                                                    .blue,
                                                                thickness: 4,
                                                                radius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
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
                                                              onChanged: widget
                                                                      .locked
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
                                                              onChanged: widget
                                                                      .locked
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
                                                              onChanged: widget
                                                                      .locked
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
                                                              onChanged: widget
                                                                      .locked
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
                                                              onChanged: widget
                                                                      .locked
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
                                                              onChanged: widget
                                                                      .locked
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
                                                              30 * scaleFactor,
                                                          color: Colors.blue,
                                                          fontFamily: 'Font')),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),

                                        // Distance to Shoot
                                        Card(
                                          color:
                                              Color.fromARGB(24, 68, 137, 255),
                                          elevation: 2,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Counter(
                                              label:
                                                  'Distance to Shoot (meters)',
                                              value: pitScoutingData
                                                  .data.distance_to_shoot,
                                              max: 500,
                                              locked: widget.locked,
                                              onChanged: (distance) {
                                                setState(() {
                                                  pitScoutingData =
                                                      pitScoutingData.copyWith(
                                                          data: pitScoutingData
                                                              .data
                                                              .copyWith(
                                                                  distance_to_shoot:
                                                                      distance));
                                                });
                                              },
                                            ),
                                          ),
                                        ),

                                        // Robot Height
                                        Card(
                                          color:
                                              Color.fromARGB(24, 68, 137, 255),
                                          elevation: 2,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: TapeMeasurePicker(
                                              label: 'Robot Height (Inches)',
                                              value: pitScoutingData
                                                  .data.robot_height,
                                              max: 30,
                                              onChanged: (height) {
                                                setState(() {
                                                  pitScoutingData =
                                                      pitScoutingData.copyWith(
                                                          data: pitScoutingData
                                                              .data
                                                              .copyWith(
                                                                  robot_height:
                                                                      height));
                                                });
                                              },
                                            ),
                                          ),
                                        ),

                                        // Mag Unload Speed
                                        Card(
                                          color:
                                              Color.fromARGB(24, 68, 137, 255),
                                          elevation: 2,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: FloatyCounter(
                                              label:
                                                  'Mag Unload Speed (seconds)',
                                              value: pitScoutingData
                                                  .data.mag_unload_speed,
                                              max: 10,
                                              onChanged: (speed) {
                                                setState(() {
                                                  pitScoutingData =
                                                      pitScoutingData.copyWith(
                                                          data: pitScoutingData
                                                              .data
                                                              .copyWith(
                                                                  mag_unload_speed:
                                                                      speed));
                                                });
                                              },
                                            ),
                                          ),
                                        ),

                                        // Hopper Capacity
                                        Card(
                                          color:
                                              Color.fromARGB(24, 68, 137, 255),
                                          elevation: 2,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Counter(
                                              label: 'Hopper Capacity',
                                              value: pitScoutingData
                                                  .data.hopper_capacity,
                                              max: 100000,
                                              locked: widget.locked,
                                              onChanged: (capacity) {
                                                setState(() {
                                                  pitScoutingData =
                                                      pitScoutingData.copyWith(
                                                          data: pitScoutingData
                                                              .data
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
                                                      fontSize:
                                                          30 * scaleFactor,
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
                                        itemCount:
                                            pitScoutingData.data.autos!.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                          pitScoutingData
                                                              .data.autos!
                                                              .toList();
                                                      newAutos[index] = newAuto;

                                                      pitScoutingData =
                                                          pitScoutingData
                                                              .copyWith(
                                                        data: pitScoutingData
                                                            .data
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
                                                            pitScoutingData
                                                                .copyWith(
                                                          data: pitScoutingData
                                                              .data
                                                              .copyWith(
                                                            autos: List.from(
                                                                pitScoutingData
                                                                        .data
                                                                        .autos
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
                                        onPressed: widget.locked
                                            ? () {}
                                            : handleAddAuto,
                                        child: Text('Add Auto',
                                            style:
                                                TextStyle(fontFamily: 'Font')),
                                      ),
                                    SizedBox(height: 20),
                                    if (!widget.locked)
                                      ElevatedButton(
                                        onPressed: widget.locked
                                            ? () {}
                                            : handleSubmit,
                                        child: Text('Submit',
                                            style:
                                                TextStyle(fontFamily: 'Font')),
                                      ),
                                  ]),
                            ),
                          ),
                        )));
              }));
  }
}
