import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/models/pit_scouting_2025.dart';
import '../api_service.dart';

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
  List<Widget> autoImages = [];
  bool formSubmitted = false;
  bool loading = true;
  late PitScouting2025 pitScoutingData = PitScouting2025(
      user_id: '',
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
          autos: []),
      time: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);

  @override
  void initState() {
    super.initState();
    fetchPitScoutingData();
  }

  void fetchPitScoutingData() async {
    final api = Provider.of<ApiService>(context, listen: false);
    api.token.then((token) => api
            .fetchTeamPitScouting(
              widget.tournament.page.split('/')[3],
              widget.tournament.page.split('/')[4],
              'frc${widget.teamNumber}',
            )
            .then((fetchedData) => setState(() {
                  pitScoutingData = fetchedData['pit_scouting'] ?? [];
                  loading = false;
                }))
            .onError((e, _) {
          loading = false;
        }));
  }

  void handleChange(String field, dynamic value) {
    setState(() {
      switch (field) {
        case 'drive_train':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(drive_train: value));
          break;
        case 'can_score_coral':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(can_score_coral: value));
          break;
        case 'can_score_processor':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(can_score_processor: value));
          break;
        case 'can_score_net':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(can_score_net: value));
          break;
        case 'ground_coral_pickup':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(ground_coral_pickup: value));
          break;
        case 'feeder_coral_pickup':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(feeder_coral_pickup: value));
          break;
        case 'ground_algae_pickup':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(ground_algae_pickup: value));
          break;
        case 'reef_algae_pickup':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(reef_algae_pickup: value));
          break;
        case 'spare_parts':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(spare_parts: value));
          break;
        case 'favorite_color':
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(favorite_color: value));
          break;
      }
    });
  }

  void handleAddAuto() {
    setState(() {
      pitScoutingData = pitScoutingData.copyWith(
        data: pitScoutingData.data.copyWith(
          autos: List.from(pitScoutingData.data.autos)
            ..add(PitAuto2025(
              starting_position_meters_from_processor: 0,
              steps: [],
              field_side: [],
              exit: false,
              preload: false,
            )),
        ),
      );
      print('Auto added');

      double height = 250; // Set the desired height
      double containerWidth = height * 5;
      double containerHeight = height * 1.3;

      Image image = Image.asset(
        'assets/2025 REEFSCAPE Gray Background blue.png',
        width: height * 1.09417040359, // Set the desired width
        height: height, // Set the desired height
        fit: BoxFit.contain,
      );

      // Add a listener to get the image dimensions
      image.image.resolve(ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          print('Image width: ${info.image.width}');
          print('Image height: ${info.image.height}');
        }),
      );

      autoImages.add(
        Center(
          child: Container(
            width: containerWidth, // Make the container wider than the image
            height: containerHeight, // Make the container taller than the image
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(
                color: const Color(0xFFD8D0D0), // Set the border color
                width: 2.0, // Set the border width
              ),
              borderRadius:
                  BorderRadius.circular(15.0), // Set the border radius
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(20.0), // Add padding around the image
              child: image,
            ),
          ),
        ),
      );
    });

    // Show a customized SnackBar notification with animation
    final snackBar = SnackBar(
      content: Center(child: Text('Auto added')),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(left: 1420, right: 5, bottom: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Add a delay to create an exit animation effect
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
                        onChanged: (value) =>
                            handleChange('drive_train', value),
                        controller: TextEditingController(
                            text: pitScoutingData.data.drive_train),
                      ),
                      SwitchListTile(
                        title: Text('Can Score Coral'),
                        value: pitScoutingData.data.can_score_coral,
                        onChanged: (value) =>
                            handleChange('can_score_coral', value),
                      ),
                      SwitchListTile(
                        title: Text('Can Score Processor'),
                        value: pitScoutingData.data.can_score_processor,
                        onChanged: (value) =>
                            handleChange('can_score_processor', value),
                      ),
                      SwitchListTile(
                        title: Text('Can Score Net'),
                        value: pitScoutingData.data.can_score_net,
                        onChanged: (value) =>
                            handleChange('can_score_net', value),
                      ),
                      SwitchListTile(
                        title: Text('Ground Coral Pickup'),
                        value: pitScoutingData.data.ground_coral_pickup,
                        onChanged: (value) =>
                            handleChange('ground_coral_pickup', value),
                      ),
                      SwitchListTile(
                        title: Text('Feeder Coral Pickup'),
                        value: pitScoutingData.data.feeder_coral_pickup,
                        onChanged: (value) =>
                            handleChange('feeder_coral_pickup', value),
                      ),
                      SwitchListTile(
                        title: Text('Ground Algae Pickup'),
                        value: pitScoutingData.data.ground_algae_pickup,
                        onChanged: (value) =>
                            handleChange('ground_algae_pickup', value),
                      ),
                      SwitchListTile(
                        title: Text('Reef Algae Pickup'),
                        value: pitScoutingData.data.reef_algae_pickup,
                        onChanged: (value) =>
                            handleChange('reef_algae_pickup', value),
                      ),
                      Text('Spare Parts'),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) => handleChange(
                            'spare_parts', int.tryParse(value) ?? 0),
                        controller: TextEditingController(
                            text: pitScoutingData.data.spare_parts.toString()),
                      ),
                      Text('Favorite Color'),
                      TextField(
                        onChanged: (value) =>
                            handleChange('favorite_color', value),
                        controller: TextEditingController(
                            text: pitScoutingData.data.favorite_color),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.all(8.0), // Adjust the padding as needed
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
                        color: const Color(
                            0xFFD8D0D0), // Set the color of the line
                        thickness: 2.0, // Set the thickness of the line
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: handleAddAuto,
                        child: Text('Add Auto'),
                      ),
                      SizedBox(height: 20),
                      // Display the list of images
                      Column(
                        children: autoImages,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ));
  }
}
