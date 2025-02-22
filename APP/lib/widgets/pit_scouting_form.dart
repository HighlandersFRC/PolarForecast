import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/pit_scouting_2025.dart';
import 'package:scouting_app/utils.dart';
import 'package:scouting_app/widgets/auto_pieces_2025.dart';
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
  bool formSubmitted = false;
  bool loading = true;
  late PitScouting2025 pitScoutingData = PitScouting2025(
    scout_info:
        ScoutInfo(team_number: 0, first_name: '', user_id: '', username: ''),
    team_number: widget.teamNumber,
    event_code: widget.tournament.key,
    data: PitData2025(
      driver_experience_events: 0,
      drive_train: '',
      can_score_coral: false,
      coral_levels: [],
      can_score_processor: false,
      can_score_net: false,
      ground_coral_pickup: false,
      feeder_coral_pickup: false,
      ground_algae_pickup: false,
      reef_algae_pickup: false,
      climbing: [],
      spare_parts: 0,
      favorite_color: '',
      autos: [],
    ),
    time: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
  );
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
                pitScoutingData = PitScouting2025.fromJson(fetchedData);
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
      if (token != null) {
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
    setState(() {
      switch (field) {
        case 'drive_train':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(drive_train: value),
          );
          break;
        case 'can_score_coral':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(can_score_coral: value),
          );
          if (value == false)
            pitScoutingData = pitScoutingData.copyWith(
                data: pitScoutingData.data.copyWith(coral_levels: []));
          break;
        case 'can_score_processor':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(can_score_processor: value),
          );
          break;
        case 'can_score_net':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(can_score_net: value),
          );
          break;
        case 'ground_coral_pickup':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(ground_coral_pickup: value),
          );
          break;
        case 'feeder_coral_pickup':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(feeder_coral_pickup: value),
          );
          break;
        case 'ground_algae_pickup':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(ground_algae_pickup: value),
          );
          break;
        case 'reef_algae_pickup':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(reef_algae_pickup: value),
          );
          break;
        case 'spare_parts':
          pitScoutingData = pitScoutingData.copyWith(
            data: pitScoutingData.data.copyWith(spare_parts: value),
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
    setState(() {
      pitScoutingData = pitScoutingData.copyWith(
        data: pitScoutingData.data.copyWith(
          autos: List.from(pitScoutingData.data.autos)
            ..add(
              Auto2025(
                starting_position_meters_from_processor: 0,
                steps: [],
                field_side: [],
                exit: false,
                preload: false,
              ),
            ),
        ),
      );
    });

    print('Auto added');

    final snackBar = SnackBar(
      content: Center(child: Text('Auto added')),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(left: 1420, right: 5, bottom: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Future.delayed(Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
    Navigator.pop(context);
  }

  final Color algaeButtonColor = Color.fromARGB(255, 58, 185, 164);
  final Color coralButtonColor = Colors.white;
  final Color bothButtonColor = const Color.fromARGB(255, 139, 61, 175);

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
                            'Questions',
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.blue,
                      thickness: 2.0,
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
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Can Score Coral'),
                      value: pitScoutingData.data.can_score_coral,
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) => handleChange('can_score_coral', value),
                    ),
                    AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: !pitScoutingData.data.can_score_coral
                            ? SizedBox.shrink()
                            : Row(key: ValueKey('coral_levels_row'), children: [
                                Column(children: [
                                  Text('L1'),
                                  Switch(
                                    activeColor: Colors.blue,
                                    value: pitScoutingData.data.coral_levels
                                        .contains(1),
                                    onChanged: widget.locked
                                        ? (_) {}
                                        : (value) {
                                            setState(() {
                                              List<int> updatedCoralLevels =
                                                  List.from(pitScoutingData
                                                      .data.coral_levels);
                                              if (updatedCoralLevels
                                                  .contains(1)) {
                                                updatedCoralLevels.remove(1);
                                              } else {
                                                updatedCoralLevels.add(1);
                                              }
                                              pitScoutingData =
                                                  pitScoutingData.copyWith(
                                                data: pitScoutingData.data
                                                    .copyWith(
                                                  coral_levels:
                                                      updatedCoralLevels,
                                                ),
                                              );
                                            });
                                          },
                                  ),
                                ]),
                                Column(children: [
                                  Text('L2'),
                                  Switch(
                                    activeColor: Colors.blue,
                                    value: pitScoutingData.data.coral_levels
                                        .contains(2),
                                    onChanged: widget.locked
                                        ? (_) {}
                                        : (value) {
                                            setState(() {
                                              List<int> updatedCoralLevels =
                                                  List.from(pitScoutingData
                                                      .data.coral_levels);
                                              if (updatedCoralLevels
                                                  .contains(2)) {
                                                updatedCoralLevels.remove(2);
                                              } else {
                                                updatedCoralLevels.add(2);
                                              }
                                              pitScoutingData =
                                                  pitScoutingData.copyWith(
                                                data: pitScoutingData.data
                                                    .copyWith(
                                                  coral_levels:
                                                      updatedCoralLevels,
                                                ),
                                              );
                                            });
                                          },
                                  ),
                                ]),
                                Column(children: [
                                  Text('L3'),
                                  Switch(
                                    activeColor: Colors.blue,
                                    value: pitScoutingData.data.coral_levels
                                        .contains(3),
                                    onChanged: widget.locked
                                        ? (_) {}
                                        : (value) {
                                            setState(() {
                                              List<int> updatedCoralLevels =
                                                  List.from(pitScoutingData
                                                      .data.coral_levels);
                                              if (updatedCoralLevels
                                                  .contains(3)) {
                                                updatedCoralLevels.remove(3);
                                              } else {
                                                updatedCoralLevels.add(3);
                                              }
                                              pitScoutingData =
                                                  pitScoutingData.copyWith(
                                                data: pitScoutingData.data
                                                    .copyWith(
                                                  coral_levels:
                                                      updatedCoralLevels,
                                                ),
                                              );
                                            });
                                          },
                                  ),
                                ]),
                                Column(children: [
                                  Text('L4'),
                                  Switch(
                                    activeColor: Colors.blue,
                                    value: pitScoutingData.data.coral_levels
                                        .contains(4),
                                    onChanged: widget.locked
                                        ? (_) {}
                                        : (value) {
                                            setState(() {
                                              List<int> updatedCoralLevels =
                                                  List.from(pitScoutingData
                                                      .data.coral_levels);
                                              if (updatedCoralLevels
                                                  .contains(4)) {
                                                updatedCoralLevels.remove(4);
                                              } else {
                                                updatedCoralLevels.add(4);
                                              }
                                              pitScoutingData =
                                                  pitScoutingData.copyWith(
                                                data: pitScoutingData.data
                                                    .copyWith(
                                                  coral_levels:
                                                      updatedCoralLevels,
                                                ),
                                              );
                                            });
                                          },
                                  )
                                ]),
                              ])),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Can Score Processor'),
                      value: pitScoutingData.data.can_score_processor,
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) =>
                              handleChange('can_score_processor', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Can Score Net'),
                      value: pitScoutingData.data.can_score_net,
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) => handleChange('can_score_net', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Ground Coral Pickup'),
                      value: pitScoutingData.data.ground_coral_pickup,
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) =>
                              handleChange('ground_coral_pickup', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Feeder Coral Pickup'),
                      value: pitScoutingData.data.feeder_coral_pickup,
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) =>
                              handleChange('feeder_coral_pickup', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Ground Algae Pickup'),
                      value: pitScoutingData.data.ground_algae_pickup,
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) =>
                              handleChange('ground_algae_pickup', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Reef Algae Pickup'),
                      value: pitScoutingData.data.reef_algae_pickup,
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) => handleChange('reef_algae_pickup', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Can Shallow Climb'),
                      value: pitScoutingData.data.climbing.contains('shallow'),
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) {
                              setState(() {
                                List<String> updatedClimbing =
                                    List.from(pitScoutingData.data.climbing);
                                if (value) {
                                  updatedClimbing.add('shallow');
                                } else {
                                  updatedClimbing.remove('shallow');
                                }
                                pitScoutingData = pitScoutingData.copyWith(
                                  data: pitScoutingData.data.copyWith(
                                    climbing: updatedClimbing,
                                  ),
                                );
                              });
                            },
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Can Deep Climb'),
                      value: pitScoutingData.data.climbing.contains('deep'),
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) {
                              setState(() {
                                List<String> updatedClimbing =
                                    List.from(pitScoutingData.data.climbing);
                                if (value) {
                                  updatedClimbing.add('deep');
                                } else {
                                  updatedClimbing.remove('deep');
                                }
                                pitScoutingData = pitScoutingData.copyWith(
                                  data: pitScoutingData.data.copyWith(
                                    climbing: updatedClimbing,
                                  ),
                                );
                              });
                            },
                    ),
                    Text('Spare Parts'),
                    DropdownButton<int>(
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'No Spare Parts',
                              style: TextStyle(color: Colors.red),
                            )),
                        DropdownMenuItem(
                            value: 1,
                            child: Text('Some Spare Parts',
                                style: TextStyle(color: Colors.orange))),
                        DropdownMenuItem(
                            value: 2,
                            child: Text('Some Spare Mechanisms',
                                style: TextStyle(color: Colors.yellow))),
                        DropdownMenuItem(
                            value: 3,
                            child: Text('Spare Everything',
                                style: TextStyle(color: Colors.green))),
                      ],
                      value: pitScoutingData.data.spare_parts,
                      onChanged: widget.locked
                          ? null
                          : (value) => handleChange('spare_parts', value ?? 0),
                    ),
                    Text('Favorite Color'),
                    TextField(
                      enabled: !widget.locked,
                      onChanged: widget.locked
                          ? (_) {}
                          : (value) => handleChange('favorite_color', value),
                      controller: favoriteColorController,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Autos',
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.blue,
                      thickness: 2.0,
                    ),
                    SizedBox(height: 20),
                    if (!widget.locked)
                      ElevatedButton(
                        onPressed: widget.locked ? () {} : handleAddAuto,
                        child: Text('Add Auto'),
                      ),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: pitScoutingData.data.autos.length,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                                child: Column(children: [
                              AutoPieces2025(
                                  auto: pitScoutingData.data.autos[index],
                                  onChanged: (newAuto) {
                                    setState(() {
                                      List<Auto2025> newAutos =
                                          pitScoutingData.data.autos.toList();
                                      newAutos[index] = newAuto;
                                      pitScoutingData =
                                          pitScoutingData.copyWith(
                                              data: pitScoutingData.data
                                                  .copyWith(autos: newAutos));
                                    });
                                  }),
                              SizedBox(
                                height: 8,
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    pitScoutingData = pitScoutingData.copyWith(
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
                    SizedBox(height: 20),
                    if (!widget.locked)
                      ElevatedButton(
                        onPressed: widget.locked ? () {} : handleSubmit,
                        child: Text('Submit'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
