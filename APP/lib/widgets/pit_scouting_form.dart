import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import 'package:scouting_app/models/pit_scouting_2026.dart';

import 'package:scouting_app/widgets/auto_pieces_2026.dart';
import 'package:scouting_app/utils.dart';
import 'package:scouting_app/widgets/counter.dart';
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
          cycles_in_25_seconds: 0,
          cycle_time: 0,
          go_over_bump: false,
          go_under_trench: false,
          can_climb: false,
          can_climb_in_autonomous: false,
          can_climb_with_others: false,
          automatically_shooting: false,
          shooting_while_moving: false,
          auto: Auto2026(
              starting_position_meters_from_hub_center: 0,
              steps: [],
              field_side: [],
              preload: false,
              climb: false,
              contacts_robot: false),
          auto_scoring: AutoScoring(
              feed_amount: 0,
              intake_amount: 0,
              shoot_amount: 0,
              cycles_completed: 0,
              climb_side: 'Did not Climb'),
          main_strategy: ''),
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
        case 'cycles_in_25_seconds':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(cycles_in_25_seconds: value),
          );
          break;
        case 'cycle_time':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(cycle_time: value),
          );
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
        case 'can_climb_with_others':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(can_climb_with_others: value),
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
          autos: List.from(pitScoutingData.data.autos)
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
    final api = Provider.of<ApiService>(context, listen: false);
    final status = await api.postPitScouting(
      pitScoutingData,
      widget.tournament.page.split('/')[3],
      widget.tournament.page.split('/')[4],
      'frc${widget.teamNumber}',
    );
    if (status == 200) {
      HapticFeedback.mediumImpact();
      setState(() {
        formSubmitted = true;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Submission failed. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
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
                    style: TextStyle(fontSize: 24, color: Colors.green),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: handleEditForm,
                    child: Text('Edit Form'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => handleGoBack(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                              style:
                                  TextStyle(fontSize: 30, color: Colors.blue),
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
                              style:
                                  TextStyle(fontSize: 30, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.blue,
                        thickness: 2.0,
                      ),
                      Counter(
                          label: '# of Events Driver has Driven',
                          value: pitScoutingData.data.driver_experience_events,
                          max: 500,
                          locked: widget.locked,
                          onChanged: (experience) {
                            setState(() {
                              pitScoutingData = pitScoutingData.copyWith(
                                  data: pitScoutingData.data.copyWith(
                                      driver_experience_events: experience));
                            });
                          }),
                      Text('Main Strategy'),
                      TextField(
                        enabled: !widget.locked,
                        onChanged: widget.locked
                            ? null
                            : (value) => handleChange('main_strategy', value),
                        controller: mainStrategyController,
                      ),
                      SwitchListTile(
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.blue,
                        title: Text('Can Feed Human Player'),
                        value: pitScoutingData.data.can_feed_human_player,
                        onChanged: widget.locked
                            ? null
                            : (value) =>
                                handleChange('can_feed_human_player', value),
                      ),
                      SwitchListTile(
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.blue,
                        title: Text('Can Pick Up From Ground'),
                        value: pitScoutingData.data.can_pick_up_from_ground,
                        onChanged: widget.locked
                            ? null
                            : (value) =>
                                handleChange('can_pick_up_from_ground', value),
                      ),
                      SwitchListTile(
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.blue,
                        title: Text('Can Go Under Trench'),
                        value: pitScoutingData.data.go_under_trench,
                        onChanged: widget.locked
                            ? null
                            : (value) => handleChange('go_under_trench', value),
                      ),
                      SwitchListTile(
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.blue,
                        title: Text('Can Go Over Bump'),
                        value: pitScoutingData.data.go_over_bump,
                        onChanged: widget.locked
                            ? null
                            : (value) => handleChange('go_over_bump', value),
                      ),
                      SwitchListTile(
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.blue,
                        title: Text('Automatically Shooting'),
                        value: pitScoutingData.data.automatically_shooting,
                        onChanged: widget.locked
                            ? null
                            : (value) =>
                                handleChange('automatically_shooting', value),
                      ),
                      SwitchListTile(
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.blue,
                        title: Text('Can shoot while moving'),
                        value: pitScoutingData.data.shooting_while_moving,
                        onChanged: widget.locked
                            ? null
                            : (value) =>
                                handleChange('shooting_while_moving', value),
                      ),
                      SwitchListTile(
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.blue,
                        title: const Text('Can Climb'),
                        value: pitScoutingData.data.can_climb,
                        onChanged: widget.locked
                            ? null
                            : (value) => handleChange('can_climb', value),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: !pitScoutingData.data.can_climb
                            ? const SizedBox.shrink()
                            : Column(
                                key: const ValueKey('climb_options'),
                                children: [
                                  SwitchListTile(
                                    activeColor: Colors.blue,
                                    inactiveThumbColor: Colors.blue,
                                    title: const Text(
                                        'Can Climb With Other Robots'),
                                    value: pitScoutingData
                                        .data.can_climb_with_others,
                                    onChanged: widget.locked
                                        ? null
                                        : (value) => handleChange(
                                            'can_climb_with_others', value),
                                  ),
                                  SwitchListTile(
                                    activeColor: Colors.blue,
                                    inactiveThumbColor: Colors.blue,
                                    title:
                                        const Text('Can Climb in Autonomous'),
                                    value: pitScoutingData
                                        .data.can_climb_in_autonomous,
                                    onChanged: widget.locked
                                        ? null
                                        : (value) => handleChange(
                                            'can_climb_in_autonomous', value),
                                  ),
                                ],
                              ),
                      ),
                      Counter(
                          label: 'Distance to Shoot (meters)',
                          value: pitScoutingData.data.distance_to_shoot,
                          max: 500,
                          locked: widget.locked,
                          onChanged: (distance) {
                            setState(() {
                              pitScoutingData = pitScoutingData.copyWith(
                                  data: pitScoutingData.data
                                      .copyWith(distance_to_shoot: distance));
                            });
                          }),
                      SizedBox(height: 8),
                      Counter(
                          label: 'Cycles in 25 Seconds',
                          value: pitScoutingData.data.cycles_in_25_seconds,
                          max: 500,
                          locked: widget.locked,
                          onChanged: (cycles) {
                            setState(() {
                              pitScoutingData = pitScoutingData.copyWith(
                                  data: pitScoutingData.data
                                      .copyWith(cycles_in_25_seconds: cycles));
                            });
                          }),
                      SizedBox(height: 8),
                      Counter(
                          label: 'Cycle Time (seconds)',
                          value: pitScoutingData.data.cycle_time,
                          max: 500,
                          locked: widget.locked,
                          onChanged: (cycleTime) {
                            setState(() {
                              pitScoutingData = pitScoutingData.copyWith(
                                  data: pitScoutingData.data
                                      .copyWith(cycle_time: cycleTime));
                            });
                          }),
                      Text('Favorite Color'),
                      TextField(
                        enabled: !widget.locked,
                        onChanged: widget.locked
                            ? null
                            : (value) => handleChange('favorite_color', value),
                        controller: favoriteColorController,
                      ),
                      Text('Drive Train'),
                      DropdownButton<String>(
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                              value: '',
                              child: Text(
                                'Choose...',
                              )),
                          DropdownMenuItem(
                              value: 'Tank',
                              child: Text(
                                'Tank',
                              )),
                          DropdownMenuItem(
                              value: 'Swerve',
                              child: Text(
                                'Swerve',
                              )),
                          DropdownMenuItem(
                              value: 'Mecanum',
                              child: Text(
                                'Mecanum',
                              )),
                        ],
                        value: pitScoutingData.data.drive_train,
                        onChanged: widget.locked
                            ? null
                            : (value) {
                                if (value != null)
                                  handleChange('drive_train', value);
                              },
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Autos',
                              style:
                                  TextStyle(fontSize: 30, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.blue,
                        thickness: 2.0,
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: pitScoutingData.data.autos.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Card(
                                  child: Column(children: [
                                AutoPieces2026(
                                  auto: pitScoutingData.data.autos[index],
                                  onChanged: (newAuto) {
                                    setState(() {
                                      List<dynamic> newAutos =
                                          pitScoutingData.data.autos.toList();
                                      newAutos[index] = newAuto;
                                      pitScoutingData =
                                          pitScoutingData.copyWith(
                                              data: pitScoutingData.data
                                                  .copyWith(autos: newAutos));
                                    });
                                  },
                                  locked: widget.locked,
                                  autoScoring:
                                      pitScoutingData.data.auto_scoring,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                if (!widget.locked)
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        pitScoutingData =
                                            pitScoutingData.copyWith(
                                          data: pitScoutingData.data.copyWith(
                                            autos: List.from(
                                                pitScoutingData.data.autos)
                                              ..removeAt(index),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                              ])));
                        },
                      ),
                      if (!widget.locked)
                        ElevatedButton(
                          onPressed: widget.locked ? () {} : handleAddAuto,
                          child: Text('Add Auto'),
                        ),
                      SizedBox(height: 20),
                      if (!widget.locked)
                        ElevatedButton(
                          onPressed: widget.locked ? () {} : handleSubmit,
                          child: Text('Submit'),
                        ),
                    ]),
              ),
            ),
    );
  }
}
