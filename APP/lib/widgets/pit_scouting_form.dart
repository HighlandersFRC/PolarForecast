import 'dart:math';

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
  List<double> autoPositions = [];
  final TextEditingController driveTrainController = TextEditingController();
  final List<String> dropdownOptions = ['Blue Side', 'Red Side', 'Both'];

  List<bool> exitSwitchValues = [];
  final TextEditingController favoriteColorController = TextEditingController();
  bool formSubmitted = false;
  bool loading = true;
  late PitScouting2025 pitScoutingData = PitScouting2025(
    scout_info:
        ScoutInfo(team_number: 0, first_name: '', user_id: '', username: ''),
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

  List<bool> preloadSwitchValues = [];
  List<String?> selectedDropdownValues = [];
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
      autoPositions.add(0.0);
      selectedDropdownValues.add('Blue Side');
      exitSwitchValues.add(false);
      preloadSwitchValues.add(false);
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

  List<bool> isAnimatingProcessorList = [];
  List<bool> isAnimatingNetList = [];
  List<List<double>> pickupBallScales = [];

  Widget buildTriangle({
    required double size,
    required Color color,
    double rotation = 0.0,
  }) {
    return Transform.rotate(
      angle: rotation,
      alignment: Alignment.topCenter,
      child: Container(
        width: 0,
        height: 0,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: size, color: Colors.transparent),
            right: BorderSide(width: size, color: Colors.transparent),
            bottom: BorderSide(width: size * sqrt(3), color: color),
          ),
        ),
      ),
    );
  }

  void _showTriangleMenu(
      BuildContext context, int autoIndex, int triangleIndex) {
    int letterIndex = (triangleIndex + 1 + 6) % 6;
    String letter1 = String.fromCharCode(65 + (2 * letterIndex));
    String letter2 = String.fromCharCode(65 + (2 * letterIndex) + 1);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.all(12),
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Place $letter1-$letter2',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: List.generate(4, (level) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  List<AutoStep2025> newList = pitScoutingData
                                      .data.autos[autoIndex].steps
                                      .toList();
                                  newList.add(AutoStep2025(
                                      name: 'place_coral',
                                      extra_data: {
                                        'position': '$letter1${4 - level}'
                                      }));
                                  List<Auto2025> newAutos =
                                      pitScoutingData.data.autos.toList();
                                  newAutos[autoIndex] = newAutos[autoIndex]
                                      .copyWith(steps: newList);
                                  pitScoutingData = pitScoutingData.copyWith(
                                      data: pitScoutingData.data
                                          .copyWith(autos: newAutos));
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                '$letter1${4 - level}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            'Removed Algae?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12),
                          Container(
                            height: 150,
                            width: 60,
                            child: Align(
                              alignment: (letter1 == 'A' ||
                                      letter1 == 'E' ||
                                      letter1 == 'I')
                                  ? Alignment.topCenter
                                  : Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    List<AutoStep2025> newList = pitScoutingData
                                        .data.autos[autoIndex].steps
                                        .toList();
                                    newList.add(AutoStep2025(
                                        name: 'reef_algae',
                                        extra_data: {
                                          'position': '$letter1-$letter2'
                                        }));
                                    List<Auto2025> newAutos =
                                        pitScoutingData.data.autos.toList();
                                    newAutos[autoIndex] = newAutos[autoIndex]
                                        .copyWith(steps: newList);
                                    pitScoutingData = pitScoutingData.copyWith(
                                        data: pitScoutingData.data
                                            .copyWith(autos: newAutos));
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 58, 185, 164),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      Column(
                        children: List.generate(4, (level) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  List<AutoStep2025> newList = pitScoutingData
                                      .data.autos[autoIndex].steps
                                      .toList();
                                  newList.add(AutoStep2025(
                                      name: 'place_coral',
                                      extra_data: {
                                        'position': '$letter2${4 - level}'
                                      }));
                                  List<Auto2025> newAutos =
                                      pitScoutingData.data.autos.toList();
                                  newAutos[autoIndex] = newAutos[autoIndex]
                                      .copyWith(steps: newList);
                                  pitScoutingData = pitScoutingData.copyWith(
                                      data: pitScoutingData.data
                                          .copyWith(autos: newAutos));
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                '$letter2${4 - level}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(),
                  child: Text('Cancel'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildStepsUI(int index) {
    List<Widget> items =
        pitScoutingData.data.autos[index].steps.asMap().entries.map((entry) {
      int stepIndex = entry.key;
      String stepLabel = entry.value.name;
      return Card(
        key: ValueKey(stepIndex),
        color: Colors.grey[800],
        child: ListTile(
          title: Text('Step ${stepIndex + 1}: $stepLabel',
              style: TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                List<AutoStep2025> newSteps =
                    pitScoutingData.data.autos[index].steps.toList();
                newSteps.removeAt(stepIndex);
                List<Auto2025> newAutos = pitScoutingData.data.autos.toList();
                newAutos[index] = newAutos[index].copyWith(steps: newSteps);
                pitScoutingData = pitScoutingData.copyWith(
                    data: pitScoutingData.data.copyWith(autos: newAutos));
              });
            },
          ),
        ),
      );
    }).toList();
    return ReorderableListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final autoSteps = pitScoutingData.data.autos[index].steps.toList();
          final item = autoSteps.removeAt(oldIndex);
          autoSteps.insert(newIndex, item);
          List<Auto2025> newAutos = pitScoutingData.data.autos.toList();
          newAutos[index] = newAutos[index].copyWith(steps: autoSteps);
          pitScoutingData = pitScoutingData.copyWith(
              data: pitScoutingData.data.copyWith(autos: newAutos));
        });
      },
      children: items,
    );
  }

  Widget buildAutoImage(int index) {
    double fieldWidthMeters = 8.052;
    final autoSteps = pitScoutingData.data.autos[index].steps.toList();
    while (autoPositions.length <= index)
      autoPositions.add(fieldWidthMeters / 2);
    while (isAnimatingProcessorList.length <= index)
      isAnimatingProcessorList.add(false);
    while (isAnimatingNetList.length <= index) isAnimatingNetList.add(false);
    while (selectedDropdownValues.length <= index)
      selectedDropdownValues.add(null);
    while (exitSwitchValues.length <= index) exitSwitchValues.add(false);
    while (preloadSwitchValues.length <= index) preloadSwitchValues.add(false);
    while (pickupBallScales.length <= index)
      pickupBallScales.add([1.0, 1.0, 1.0]);

    double sliderValue = autoPositions[index];

    String imagePath;
    double rotation = 0;
    switch (selectedDropdownValues[index]) {
      case 'Red Side':
        imagePath = 'assets/2025 REEFSCAPE Gray Background red.png';
        rotation = -1.5708;
        break;
      case 'Blue Side':
        imagePath = 'assets/2025 REEFSCAPE Gray Background blue.png';
        rotation = 1.5708;
        break;
      default:
        imagePath = 'assets/2025 REEFSCAPE Gray Background blue.png';
        rotation = 1.5708;
        break;
    }
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
              double overlayLeft = displayedImageWidth * 0.05;
              double overlayBottom = displayedImageHeight * 0.2;
              double overlayWidth = displayedImageWidth * 0.2;
              double overlayHeight = displayedImageHeight * 0.3;
              double squareSize = displayedImageWidth * 0.1;
              double squareLeft = sliderValue * pixelsPerMeter - squareSize / 2;
              if (squareLeft < 0) squareLeft = 0;
              if (squareLeft > displayedImageWidth - squareSize)
                squareLeft = displayedImageWidth - squareSize;

              List<Widget> triangleWidgets = [];
              List<Widget> triangleLabels = [];
              int triangleCount = 6;
              double triangleSize = displayedImageWidth * 0.075;
              double centerX = displayedImageWidth / 2;
              double centerY = (displayedImageHeight + (5.5 * scaleFactor)) / 2;

              for (int i = 0; i < triangleCount; i++) {
                int shiftedIndex = (i + 4) % triangleCount;
                double angle = (-2 * pi / triangleCount) * shiftedIndex;
                Color triangleColor =
                    (i % 2 == 0) ? Colors.green : Colors.purple;

                triangleWidgets.add(Positioned(
                  left: centerX,
                  top: centerY,
                  child: buildTriangle(
                    size: triangleSize,
                    color: triangleColor.withOpacity(0.5),
                    rotation: angle,
                  ),
                ));

                int labelIndex = (i + 1 + triangleCount) % triangleCount;
                double centroidDist = (2 * triangleSize * sqrt(3)) / 3;
                double offsetX = -centroidDist * sin(angle);
                double offsetY = centroidDist * cos(angle);
                String letter1 = String.fromCharCode(65 + (2 * labelIndex));
                String letter2 = String.fromCharCode(65 + (2 * labelIndex) + 1);

                triangleLabels.add(Positioned(
                  left: centerX + offsetX - (triangleSize * 0.5),
                  top: centerY + offsetY - (triangleSize * 0.25),
                  child: Text(
                    '$letter1-$letter2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: triangleSize * 0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black54,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                ));
              }

              bool isRedSide = selectedDropdownValues[index] == 'Red Side';
              double feederButtonSize = displayedImageWidth * 0.1;
              double ballSize = displayedImageWidth * 0.08;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (TapDownDetails details) {
                      RenderBox box = context.findRenderObject() as RenderBox;
                      Offset localPos =
                          box.globalToLocal(details.globalPosition);
                      int selectedTriangle = -1;
                      double minDistance = double.infinity;
                      double triangleSizeLocal = displayedImageWidth * 0.075;
                      double centroidDist =
                          (2 * triangleSizeLocal * sqrt(3)) / 3;
                      for (int i = 0; i < triangleCount; i++) {
                        int shiftedIndex = (i + 4) % triangleCount;
                        double angle = (-2 * pi / triangleCount) * shiftedIndex;
                        double triCenterX = centerX - centroidDist * sin(angle);
                        double triCenterY = centerY + centroidDist * cos(angle);
                        double distance = sqrt(
                            pow(localPos.dx - triCenterX, 2) +
                                pow(localPos.dy - triCenterY, 2));
                        if (distance < minDistance) {
                          minDistance = distance;
                          selectedTriangle = i;
                        }
                      }
                      if (minDistance > triangleSizeLocal) return;
                      _showTriangleMenu(context, index, selectedTriangle);
                    },
                    child: Stack(
                      children: [
                        Transform.rotate(
                          angle: rotation,
                          child: Image.asset(
                            imagePath,
                            width: displayedImageWidth,
                            height: displayedImageHeight,
                            fit: BoxFit.contain,
                          ),
                        ),
                        ...triangleWidgets,
                        ...triangleLabels,
                        Positioned(
                          bottom: displayedImageHeight * 0.11,
                          left: squareLeft,
                          child: Container(
                            width: squareSize,
                            height: squareSize,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blue,
                                  width: displayedImageHeight * 0.005),
                              borderRadius: BorderRadius.circular(
                                  displayedImageHeight * 0.02),
                              color: Colors.black87.withOpacity(0.2),
                            ),
                            child: Icon(Icons.smart_toy,
                                size: 15 * scaleFactor, color: Colors.white),
                          ),
                        ),
                        ...() {
                          return [
                            Positioned(
                              left: isRedSide ? null : overlayLeft,
                              right: isRedSide ? overlayLeft : null,
                              bottom: overlayBottom,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    autoSteps.add(AutoStep2025(
                                        name: 'processor', extra_data: {}));
                                    isAnimatingProcessorList[index] = true;
                                    List<Auto2025> newAutos =
                                        pitScoutingData.data.autos.toList();
                                    newAutos[index] = newAutos[index]
                                        .copyWith(steps: autoSteps);
                                    pitScoutingData = pitScoutingData.copyWith(
                                        data: pitScoutingData.data
                                            .copyWith(autos: newAutos));
                                  });
                                  Future.delayed(Duration(milliseconds: 50),
                                      () {
                                    setState(() =>
                                        isAnimatingProcessorList[index] =
                                            false);
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInOutQuad,
                                  width: isAnimatingProcessorList[index]
                                      ? overlayWidth * 1.1
                                      : overlayWidth,
                                  height: isAnimatingProcessorList[index]
                                      ? overlayHeight * 1.1
                                      : overlayHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(
                                        isAnimatingProcessorList[index]
                                            ? 0.7
                                            : 0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.build,
                                          color: Colors.white,
                                          size: (isAnimatingProcessorList[index]
                                                  ? 32
                                                  : 28) *
                                              scaleFactor),
                                      SizedBox(height: 4),
                                      Text('Processor',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  11 * (scaleFactor - 0.4))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: isRedSide ? overlayLeft : null,
                              right: isRedSide ? null : overlayLeft,
                              bottom: overlayBottom,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    autoSteps.add(AutoStep2025(
                                        name: 'net_algae',
                                        extra_data: {'position': 'center'}));
                                    isAnimatingProcessorList[index] = true;
                                    List<Auto2025> newAutos =
                                        pitScoutingData.data.autos.toList();
                                    newAutos[index] = newAutos[index]
                                        .copyWith(steps: autoSteps);
                                    pitScoutingData = pitScoutingData.copyWith(
                                        data: pitScoutingData.data
                                            .copyWith(autos: newAutos));
                                    isAnimatingNetList[index] = true;
                                  });
                                  Future.delayed(Duration(milliseconds: 50),
                                      () {
                                    setState(() =>
                                        isAnimatingNetList[index] = false);
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInOutQuad,
                                  width: isAnimatingNetList[index]
                                      ? overlayHeight * 1.1
                                      : overlayHeight,
                                  height: isAnimatingNetList[index]
                                      ? overlayWidth * 1.1
                                      : overlayWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(
                                        isAnimatingNetList[index] ? 0.7 : 0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.grid_4x4,
                                          color: Colors.white,
                                          size: (isAnimatingNetList[index]
                                                  ? 32
                                                  : 28) *
                                              scaleFactor),
                                      SizedBox(height: 4),
                                      Text('Net',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  11 * (scaleFactor - 0.4))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ];
                        }(),
                        Positioned(
                          top: displayedImageHeight * 0.05,
                          left: displayedImageWidth * 0.05,
                          child: FeederButton(
                            size: feederButtonSize,
                            scaleFactor: scaleFactor,
                            onTap: () {
                              bool feederNear = isRedSide ? false : true;
                              setState(() {
                                autoSteps.add(AutoStep2025(
                                    name: 'feeder_pickup',
                                    extra_data: {
                                      'processor_side': feederNear,
                                      'position': 'left'
                                    }));
                                isAnimatingProcessorList[index] = true;
                                List<Auto2025> newAutos =
                                    pitScoutingData.data.autos.toList();
                                newAutos[index] =
                                    newAutos[index].copyWith(steps: autoSteps);
                                pitScoutingData = pitScoutingData.copyWith(
                                    data: pitScoutingData.data
                                        .copyWith(autos: newAutos));
                              });
                            },
                          ),
                        ),
                        Positioned(
                          top: displayedImageHeight * 0.05,
                          right: displayedImageWidth * 0.05,
                          child: FeederButton(
                            size: feederButtonSize,
                            scaleFactor: scaleFactor,
                            onTap: () {
                              bool feederNear = isRedSide ? true : false;
                              setState(() {
                                autoSteps.add(AutoStep2025(
                                    name: 'feeder_pickup',
                                    extra_data: {
                                      'processor_side': feederNear,
                                      'position': 'left'
                                    }));
                                isAnimatingProcessorList[index] = true;
                                List<Auto2025> newAutos =
                                    pitScoutingData.data.autos.toList();
                                newAutos[index] =
                                    newAutos[index].copyWith(steps: autoSteps);
                                pitScoutingData = pitScoutingData.copyWith(
                                    data: pitScoutingData.data
                                        .copyWith(autos: newAutos));
                              });
                            },
                          ),
                        ),
                        Positioned(
                          left: displayedImageWidth * 0.285 - ballSize / 2,
                          top: displayedImageHeight * 0.125,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                pickupBallScales[index][0] = 1.2;
                              });
                              Future.delayed(Duration(milliseconds: 100), () {
                                setState(() {
                                  pickupBallScales[index][0] = 1.0;
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      title:
                                          Text('Select Option for processor'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: algaeButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                autoSteps.add(AutoStep2025(
                                                    name: 'coral_mark_pickup',
                                                    extra_data: {
                                                      'position': 'processor',
                                                      'algae': true,
                                                      'coral': false
                                                    }));
                                                isAnimatingProcessorList[
                                                    index] = true;
                                                List<Auto2025> newAutos =
                                                    pitScoutingData.data.autos
                                                        .toList();
                                                newAutos[index] =
                                                    newAutos[index].copyWith(
                                                        steps: autoSteps);
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                        data: pitScoutingData
                                                            .data
                                                            .copyWith(
                                                                autos:
                                                                    newAutos));
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Algae',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: coralButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                autoSteps.add(AutoStep2025(
                                                    name: 'coral_mark_pickup',
                                                    extra_data: {
                                                      'position': 'processor',
                                                      'algae': false,
                                                      'coral': true
                                                    }));
                                                isAnimatingProcessorList[
                                                    index] = true;
                                                List<Auto2025> newAutos =
                                                    pitScoutingData.data.autos
                                                        .toList();
                                                newAutos[index] =
                                                    newAutos[index].copyWith(
                                                        steps: autoSteps);
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                        data: pitScoutingData
                                                            .data
                                                            .copyWith(
                                                                autos:
                                                                    newAutos));
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Coral',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: bothButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                autoSteps.add(AutoStep2025(
                                                    name: 'coral_mark_pickup',
                                                    extra_data: {
                                                      'position': 'processor',
                                                      'algae': true,
                                                      'coral': true
                                                    }));
                                                isAnimatingProcessorList[
                                                    index] = true;
                                                List<Auto2025> newAutos =
                                                    pitScoutingData.data.autos
                                                        .toList();
                                                newAutos[index] =
                                                    newAutos[index].copyWith(
                                                        steps: autoSteps);
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                        data: pitScoutingData
                                                            .data
                                                            .copyWith(
                                                                autos:
                                                                    newAutos));
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Both',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              });
                            },
                            child: AnimatedScale(
                              scale: pickupBallScales[index][0],
                              duration: Duration(milliseconds: 100),
                              child: Container(
                                width: ballSize,
                                height: ballSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 58, 185, 164),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: displayedImageWidth * 0.5 - ballSize / 2,
                          top: displayedImageHeight * 0.125,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                pickupBallScales[index][1] = 1.2;
                              });
                              Future.delayed(Duration(milliseconds: 100), () {
                                setState(() {
                                  pickupBallScales[index][1] = 1.0;
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      title: Text('Select Option for middle'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: algaeButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                autoSteps.add(AutoStep2025(
                                                    name: 'coral_mark_pickup',
                                                    extra_data: {
                                                      'position': 'processor',
                                                      'algae': true,
                                                      'coral': false
                                                    }));
                                                isAnimatingProcessorList[
                                                    index] = true;
                                                List<Auto2025> newAutos =
                                                    pitScoutingData.data.autos
                                                        .toList();
                                                newAutos[index] =
                                                    newAutos[index].copyWith(
                                                        steps: autoSteps);
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                        data: pitScoutingData
                                                            .data
                                                            .copyWith(
                                                                autos:
                                                                    newAutos));
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Algae',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: coralButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                autoSteps.add(AutoStep2025(
                                                    name: 'coral_mark_pickup',
                                                    extra_data: {
                                                      'position': 'processor',
                                                      'algae': false,
                                                      'coral': true
                                                    }));
                                                isAnimatingProcessorList[
                                                    index] = true;
                                                List<Auto2025> newAutos =
                                                    pitScoutingData.data.autos
                                                        .toList();
                                                newAutos[index] =
                                                    newAutos[index].copyWith(
                                                        steps: autoSteps);
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                        data: pitScoutingData
                                                            .data
                                                            .copyWith(
                                                                autos:
                                                                    newAutos));
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Coral',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: bothButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                autoSteps.add(AutoStep2025(
                                                    name: 'coral_mark_pickup',
                                                    extra_data: {
                                                      'position': 'processor',
                                                      'algae': true,
                                                      'coral': true
                                                    }));
                                                isAnimatingProcessorList[
                                                    index] = true;
                                                List<Auto2025> newAutos =
                                                    pitScoutingData.data.autos
                                                        .toList();
                                                newAutos[index] =
                                                    newAutos[index].copyWith(
                                                        steps: autoSteps);
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                        data: pitScoutingData
                                                            .data
                                                            .copyWith(
                                                                autos:
                                                                    newAutos));
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Both',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              });
                            },
                            child: AnimatedScale(
                              scale: pickupBallScales[index][1],
                              duration: Duration(milliseconds: 100),
                              child: Container(
                                width: ballSize,
                                height: ballSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 58, 185, 164),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: displayedImageWidth * 0.715 - ballSize / 2,
                          top: displayedImageHeight * 0.125,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                pickupBallScales[index][2] = 1.2;
                              });
                              Future.delayed(Duration(milliseconds: 100), () {
                                setState(() {
                                  pickupBallScales[index][2] = 1.0;
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      title: Text('Select Option for other'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: algaeButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                autoSteps.add(AutoStep2025(
                                                    name: 'coral_mark_pickup',
                                                    extra_data: {
                                                      'position': 'processor',
                                                      'algae': true,
                                                      'coral': false
                                                    }));
                                                isAnimatingProcessorList[
                                                    index] = true;
                                                List<Auto2025> newAutos =
                                                    pitScoutingData.data.autos
                                                        .toList();
                                                newAutos[index] =
                                                    newAutos[index].copyWith(
                                                        steps: autoSteps);
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                        data: pitScoutingData
                                                            .data
                                                            .copyWith(
                                                                autos:
                                                                    newAutos));
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Algae',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: coralButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                autoSteps.add(AutoStep2025(
                                                    name: 'coral_mark_pickup',
                                                    extra_data: {
                                                      'position': 'processor',
                                                      'algae': false,
                                                      'coral': true
                                                    }));
                                                isAnimatingProcessorList[
                                                    index] = true;
                                                List<Auto2025> newAutos =
                                                    pitScoutingData.data.autos
                                                        .toList();
                                                newAutos[index] =
                                                    newAutos[index].copyWith(
                                                        steps: autoSteps);
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                        data: pitScoutingData
                                                            .data
                                                            .copyWith(
                                                                autos:
                                                                    newAutos));
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Coral',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: bothButtonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                autoSteps.add(AutoStep2025(
                                                    name: 'coral_mark_pickup',
                                                    extra_data: {
                                                      'position': 'processor',
                                                      'algae': true,
                                                      'coral': true
                                                    }));
                                                isAnimatingProcessorList[
                                                    index] = true;
                                                List<Auto2025> newAutos =
                                                    pitScoutingData.data.autos
                                                        .toList();
                                                newAutos[index] =
                                                    newAutos[index].copyWith(
                                                        steps: autoSteps);
                                                pitScoutingData =
                                                    pitScoutingData.copyWith(
                                                        data: pitScoutingData
                                                            .data
                                                            .copyWith(
                                                                autos:
                                                                    newAutos));
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Both',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              });
                            },
                            child: AnimatedScale(
                              scale: pickupBallScales[index][2],
                              duration: Duration(milliseconds: 100),
                              child: Container(
                                width: ballSize,
                                height: ballSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 58, 185, 164),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: displayedImageWidth,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 8,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 10.0),
                      ),
                      child: Slider(
                        value: sliderValue,
                        inactiveColor: Colors.lightBlue,
                        activeColor: Colors.lightBlue,
                        thumbColor: Colors.white,
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
                  Text('${sliderValue.toStringAsFixed(2)} meters',
                      style: TextStyle(color: Colors.white)),
                  buildStepsUI(index),
                  DropdownButton<String>(
                    value: selectedDropdownValues[index],
                    hint: Text('Select Option'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDropdownValues[index] = newValue;
                      });
                    },
                    items: dropdownOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SwitchListTile(
                    title: Text('Exit'),
                    value: exitSwitchValues[index],
                    onChanged: (bool value) {
                      setState(() {
                        exitSwitchValues[index] = value;
                        pitScoutingData = pitScoutingData.copyWith(
                          data: pitScoutingData.data.copyWith(
                            autos: List.from(pitScoutingData.data.autos)
                              ..[index] = pitScoutingData.data.autos[index]
                                  .copyWith(exit: value),
                          ),
                        );
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text('Preload'),
                    value: preloadSwitchValues[index],
                    onChanged: (bool value) {
                      setState(() {
                        preloadSwitchValues[index] = value;
                        pitScoutingData = pitScoutingData.copyWith(
                          data: pitScoutingData.data.copyWith(
                            autos: List.from(pitScoutingData.data.autos)
                              ..[index] = pitScoutingData.data.autos[index]
                                  .copyWith(preload: value),
                          ),
                        );
                      });
                    },
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
                        autoSteps.removeAt(index);
                        isAnimatingProcessorList.removeAt(index);
                        isAnimatingNetList.removeAt(index);
                        selectedDropdownValues.removeAt(index);
                        exitSwitchValues.removeAt(index);
                        preloadSwitchValues.removeAt(index);
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
                      onChanged: (value) {
                        if (value != null) handleChange('drive_train', value);
                      },
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Can Score Coral'),
                      value: pitScoutingData.data.can_score_coral,
                      onChanged: (value) =>
                          handleChange('can_score_coral', value),
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
                                    onChanged: (value) {
                                      setState(() {
                                        List<int> updatedCoralLevels =
                                            List.from(pitScoutingData
                                                .data.coral_levels);
                                        if (updatedCoralLevels.contains(1)) {
                                          updatedCoralLevels.remove(1);
                                        } else {
                                          updatedCoralLevels.add(1);
                                        }
                                        pitScoutingData =
                                            pitScoutingData.copyWith(
                                          data: pitScoutingData.data.copyWith(
                                            coral_levels: updatedCoralLevels,
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
                                    onChanged: (value) {
                                      setState(() {
                                        List<int> updatedCoralLevels =
                                            List.from(pitScoutingData
                                                .data.coral_levels);
                                        if (updatedCoralLevels.contains(2)) {
                                          updatedCoralLevels.remove(2);
                                        } else {
                                          updatedCoralLevels.add(2);
                                        }
                                        pitScoutingData =
                                            pitScoutingData.copyWith(
                                          data: pitScoutingData.data.copyWith(
                                            coral_levels: updatedCoralLevels,
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
                                    onChanged: (value) {
                                      setState(() {
                                        List<int> updatedCoralLevels =
                                            List.from(pitScoutingData
                                                .data.coral_levels);
                                        if (updatedCoralLevels.contains(3)) {
                                          updatedCoralLevels.remove(3);
                                        } else {
                                          updatedCoralLevels.add(3);
                                        }
                                        pitScoutingData =
                                            pitScoutingData.copyWith(
                                          data: pitScoutingData.data.copyWith(
                                            coral_levels: updatedCoralLevels,
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
                                    onChanged: (value) {
                                      setState(() {
                                        List<int> updatedCoralLevels =
                                            List.from(pitScoutingData
                                                .data.coral_levels);
                                        if (updatedCoralLevels.contains(4)) {
                                          updatedCoralLevels.remove(4);
                                        } else {
                                          updatedCoralLevels.add(4);
                                        }
                                        pitScoutingData =
                                            pitScoutingData.copyWith(
                                          data: pitScoutingData.data.copyWith(
                                            coral_levels: updatedCoralLevels,
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
                      onChanged: (value) =>
                          handleChange('can_score_processor', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Can Score Net'),
                      value: pitScoutingData.data.can_score_net,
                      onChanged: (value) =>
                          handleChange('can_score_net', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Ground Coral Pickup'),
                      value: pitScoutingData.data.ground_coral_pickup,
                      onChanged: (value) =>
                          handleChange('ground_coral_pickup', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Feeder Coral Pickup'),
                      value: pitScoutingData.data.feeder_coral_pickup,
                      onChanged: (value) =>
                          handleChange('feeder_coral_pickup', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Ground Algae Pickup'),
                      value: pitScoutingData.data.ground_algae_pickup,
                      onChanged: (value) =>
                          handleChange('ground_algae_pickup', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Reef Algae Pickup'),
                      value: pitScoutingData.data.reef_algae_pickup,
                      onChanged: (value) =>
                          handleChange('reef_algae_pickup', value),
                    ),
                    SwitchListTile(
                      activeColor: Colors.blue,
                      title: Text('Can Shallow Climb'),
                      value: pitScoutingData.data.climbing.contains('shallow'),
                      onChanged: (value) {
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
                      onChanged: (value) {
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
                      onChanged: (value) =>
                          handleChange('spare_parts', value ?? 0),
                    ),
                    Text('Favorite Color'),
                    TextField(
                      onChanged: (value) =>
                          handleChange('favorite_color', value),
                      controller: TextEditingController(
                          text: pitScoutingData.data.favorite_color),
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
                    ElevatedButton(
                      onPressed: handleAddAuto,
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
                          child: buildAutoImage(index),
                        );
                      },
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

class FeederButton extends StatelessWidget {
  final double size;
  final double scaleFactor;
  final VoidCallback onTap;

  const FeederButton({
    Key? key,
    required this.size,
    required this.onTap,
    this.scaleFactor = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: RoundedRectangleClipper(cornerRadius: 3.0, scaleFactor: 8),
        child: Container(
          width: size,
          height: size,
          color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.ac_unit,
                  color: Colors.white,
                  size: size * 0.3,
                ),
                SizedBox(height: size * 0.05),
                Text(
                  'Feeder',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: size * 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoundedTriangleClipper extends CustomClipper<Path> {
  final double cornerRadius;
  RoundedTriangleClipper({this.cornerRadius = 3.0});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    double width = size.width;
    double height = size.height;

    // Create the triangle with rounded corners
    path.moveTo(width / 2, 0); // Top point
    path.arcToPoint(Offset(0, height),
        radius: Radius.circular(cornerRadius)); // Left corner
    path.arcToPoint(Offset(width, height),
        radius: Radius.circular(cornerRadius)); // Right corner
    path.arcToPoint(Offset(width / 2, 0),
        radius: Radius.circular(cornerRadius)); // Closing the loop back to top

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper is RoundedRectangleClipper &&
        oldClipper.cornerRadius != cornerRadius;
  }
}

class RoundedRectangleClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double scaleFactor;

  RoundedRectangleClipper({this.cornerRadius = 1.0, this.scaleFactor = 4.0});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    double width = size.width;
    double height = size.height;

    double scaledRadius = cornerRadius * scaleFactor;

    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height), Radius.circular(scaledRadius)));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper is RoundedRectangleClipper &&
        (oldClipper.cornerRadius != cornerRadius ||
            oldClipper.scaleFactor != scaleFactor);
  }
}
