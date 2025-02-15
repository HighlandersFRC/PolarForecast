import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/pit_scouting_2025.dart';
import 'package:scouting_app/utils.dart';
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
  bool formSubmitted = false;
  bool loading = true;
  late PitScouting2025 pitScoutingData = PitScouting2025(
    scout_info: ScoutInfo(team_number: 0, first_name: '', user_id: '', username: ''),
    team_number: widget.teamNumber,
    event_code: widget.tournament.page.split('/')[4],
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
              }))
          .onError((e, _) {
        loading = false;
      });
      if (token != null) {
        pitScoutingData = pitScoutingData.copyWith(scout_info: get_scout_info(token));
        if (mounted) {
          setState(() {
            pitScoutingData = pitScoutingData.copyWith(scout_info: get_scout_info(token));
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

    // Show a SnackBar notification
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


 List<double> autoPositions = [];

Widget buildAutoImage(int index) {
  double fieldWidthMeters = 8.052;
  while (autoPositions.length <= index) {
    autoPositions.add(0.0);
  }
  double sliderValue = autoPositions[index];

  return Center(
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = constraints.maxWidth;
            double originalImageHeight = 250.0;
            double originalImageWidth = originalImageHeight * 1.09417040359;
            double scaleFactor = cardWidth / originalImageHeight;
            double displayedImageWidth = cardWidth;
            double displayedImageHeight = originalImageWidth * scaleFactor;
            double pixelsPerMeter = displayedImageWidth / fieldWidthMeters;
            double squareSize = displayedImageWidth * 0.1;
            double squareLeft = sliderValue * pixelsPerMeter - squareSize / 2;
            if (squareLeft < 0) squareLeft = 0;
            if (squareLeft > displayedImageWidth - squareSize)
              squareLeft = displayedImageWidth - squareSize;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Transform.rotate(
                      angle: 1.5708,
                      child: Image.asset(
                        'assets/2025 REEFSCAPE Gray Background blue.png',
                        width: displayedImageWidth,
                        height: displayedImageHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      bottom: displayedImageHeight * 0.1,
                      left: squareLeft,
                      child: Container(
                        width: squareSize,
                        height: squareSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 8.0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: displayedImageWidth,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 22,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 16),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: sliderValue,
                      min: 0,
                      max: fieldWidthMeters,
                      onChanged: (value) {
                        setState(() {
                          autoPositions[index] = value;
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  "${sliderValue.toStringAsFixed(2)} m",
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      pitScoutingData = pitScoutingData.copyWith(
                        data: pitScoutingData.data.copyWith(
                          autos: List.from(pitScoutingData.data.autos)
                            ..removeAt(index),
                        ),
                      );
                      autoPositions.removeAt(index);
                    });
                  },
                ),
              ],
            );
          },
        ),
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
                    Text('Drive Train'),
                    TextField(
                      onChanged: (value) => handleChange('drive_train', value),
                      controller: TextEditingController(text: pitScoutingData.data.drive_train),
                    ),
                    SwitchListTile(
                      title: Text('Can Score Coral'),
                      value: pitScoutingData.data.can_score_coral,
                      onChanged: (value) => handleChange('can_score_coral', value),
                    ),
                    SwitchListTile(
                      title: Text('Can Score Processor'),
                      value: pitScoutingData.data.can_score_processor,
                      onChanged: (value) => handleChange('can_score_processor', value),
                    ),
                    SwitchListTile(
                      title: Text('Can Score Net'),
                      value: pitScoutingData.data.can_score_net,
                      onChanged: (value) => handleChange('can_score_net', value),
                    ),
                    SwitchListTile(
                      title: Text('Ground Coral Pickup'),
                      value: pitScoutingData.data.ground_coral_pickup,
                      onChanged: (value) => handleChange('ground_coral_pickup', value),
                    ),
                    SwitchListTile(
                      title: Text('Feeder Coral Pickup'),
                      value: pitScoutingData.data.feeder_coral_pickup,
                      onChanged: (value) => handleChange('feeder_coral_pickup', value),
                    ),
                    SwitchListTile(
                      title: Text('Ground Algae Pickup'),
                      value: pitScoutingData.data.ground_algae_pickup,
                      onChanged: (value) => handleChange('ground_algae_pickup', value),
                    ),
                    SwitchListTile(
                      title: Text('Reef Algae Pickup'),
                      value: pitScoutingData.data.reef_algae_pickup,
                      onChanged: (value) => handleChange('reef_algae_pickup', value),
                    ),
                    Text('Spare Parts'),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          handleChange('spare_parts', int.tryParse(value) ?? 0),
                      controller: TextEditingController(
                        text: pitScoutingData.data.spare_parts.toString(),
                      ),
                    ),
                    Text('Favorite Color'),
                    TextField(
                      onChanged: (value) => handleChange('favorite_color', value),
                      controller: TextEditingController(text: pitScoutingData.data.favorite_color),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Autos',
                            style: TextStyle(fontSize: 30),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: const Color(0xFFD8D0D0),
                      thickness: 2.0,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: handleAddAuto,
                      child: Text('Add Auto'),
                    ),
                    SizedBox(height: 20),
                    // Build a list of auto images with delete buttons:
                    Column(
                      children: List.generate(
                        pitScoutingData.data.autos.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: buildAutoImage(index),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: handleSubmit,
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
