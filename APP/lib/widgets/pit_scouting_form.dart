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
  // Define the list of options for the dropdown menu
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

  List<List<String>> autoSteps = [];
  List<bool> isAnimatingProcessorList = [];
  List<bool> isAnimatingNetList = [];

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
    String letter1 = String.fromCharCode(65 + (2 * triangleIndex));
    String letter2 = String.fromCharCode(65 + (2 * triangleIndex) + 1);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Place Level for $letter1-$letter2'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$letter1:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (level) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          autoSteps[autoIndex].add(
                              'Triangle $letter1-$letter2: Placed on $letter1 level ${level + 1}');
                        });
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text('${level + 1}',
                            style: TextStyle(color: Colors.white)),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 10),
                Text('$letter2:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (level) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          autoSteps[autoIndex].add(
                              'Triangle $letter1-$letter2: Placed on $letter2 level ${level + 1}');
                        });
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Text('${level + 1}',
                            style: TextStyle(color: Colors.white)),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget buildStepsUI(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Steps:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white)),
        ...autoSteps[index].asMap().entries.map((entry) {
          int stepIndex = entry.key;
          String stepLabel = entry.value;
          return Card(
            color: Colors.grey[800],
            child: ListTile(
              leading: Text("Step ${stepIndex + 1}",
                  style: TextStyle(color: Colors.white)),
              title: Text(stepLabel, style: TextStyle(color: Colors.white)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_upward,
                        color: stepIndex > 0 ? Colors.white : Colors.grey),
                    onPressed: stepIndex > 0
                        ? () {
                            setState(() {
                              var temp = autoSteps[index][stepIndex - 1];
                              autoSteps[index][stepIndex - 1] =
                                  autoSteps[index][stepIndex];
                              autoSteps[index][stepIndex] = temp;
                            });
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward,
                        color: stepIndex < autoSteps[index].length - 1
                            ? Colors.white
                            : Colors.grey),
                    onPressed: stepIndex < autoSteps[index].length - 1
                        ? () {
                            setState(() {
                              var temp = autoSteps[index][stepIndex + 1];
                              autoSteps[index][stepIndex + 1] =
                                  autoSteps[index][stepIndex];
                              autoSteps[index][stepIndex] = temp;
                            });
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        autoSteps[index].removeAt(stepIndex);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget buildAutoImage(int index) {
    double fieldWidthMeters = 8.052;
    while (autoPositions.length <= index)
      autoPositions.add(fieldWidthMeters / 2);
    while (autoSteps.length <= index) autoSteps.add([]);
    while (isAnimatingProcessorList.length <= index)
      isAnimatingProcessorList.add(false);
    while (isAnimatingNetList.length <= index) isAnimatingNetList.add(false);

    double sliderValue = autoPositions[index];
    while (autoPositions.length <= index) {
      autoPositions.add(0.0);
    }
    while (selectedDropdownValues.length <= index) {
      selectedDropdownValues.add(null);
    }

    // Ensure there's an independent switch value for each auto image
    while (exitSwitchValues.length <= index) {
      exitSwitchValues.add(false);
    }

    while (preloadSwitchValues.length <= index) {
      preloadSwitchValues.add(false);
    }

    // Determine the image to display based on the selected dropdown value
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
        rotation = 1.5708; // Default to blue if no selection or 'Both'
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
                int shiftedIndex =
                    (i + 4) % 6; // Clockwise shift by 2 positions
                double angle = (2 * pi / triangleCount) * shiftedIndex;
                Color triangleColor =
                    (i % 2 == 0) ? Colors.green : Colors.purple;

                // Add triangle
                triangleWidgets.add(
                  Positioned(
                    left: centerX,
                    top: centerY,
                    child: buildTriangle(
                      size: triangleSize,
                      color: triangleColor.withOpacity(0.5),
                      rotation: angle,
                    ),
                  ),
                );

                // Calculate label position
                double centroidDist = (2 * triangleSize * sqrt(3)) / 3;
                double offsetX = -centroidDist * sin(angle);
                double offsetY = centroidDist * cos(angle);
                String letter1 = String.fromCharCode(65 + (2 * i));
                String letter2 = String.fromCharCode(65 + (2 * i) + 1);

                // Add label
                triangleLabels.add(
                  Positioned(
                    left: centerX + offsetX - (triangleSize * 0.5),
                    top: centerY + offsetY - (triangleSize * 0.25),
                    child: Text(
                      "$letter1-$letter2",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: triangleSize * 0.5,
                        shadows: [
                          Shadow(
                              blurRadius: 2,
                              color: Colors.black54,
                              offset: Offset(1, 1))
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (TapDownDetails details) {
                      RenderBox box = context.findRenderObject() as RenderBox;
                      Offset localPos =
                          box.globalToLocal(details.globalPosition);
                      double dx = localPos.dx - centerX;
                      double dy = localPos.dy - centerY;
                      double tapAngle = (atan2(dy, dx) + 2 * pi) % (2 * pi);
                      double adjustedAngle =
                          (tapAngle - (pi / 2) + 2 * pi) % (2 * pi);
                      int tappedTriangle =
                          (adjustedAngle / (2 * pi / triangleCount)).floor();

                      // Convert to original index
                      int originalIndex = (tappedTriangle - 4) % 6;
                      if (originalIndex < 0) originalIndex += 6;

                      _showTriangleMenu(context, index, originalIndex);
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
                              color: Colors.black87.withOpacity(0.45),
                            ),
                            child:
                                Icon(Icons.smart_toy, size: 15 * scaleFactor),
                          ),
                        ),
                        Positioned(
                          left: overlayLeft,
                          bottom: overlayBottom,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                autoSteps[index].add(
                                    'Processor ${autoSteps[index].length + 1}');
                                isAnimatingProcessorList[index] = true;
                              });
                              Future.delayed(Duration(milliseconds: 50), () {
                                setState(() =>
                                    isAnimatingProcessorList[index] = false);
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
                                          fontSize: 11 * (scaleFactor - 0.4))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: overlayLeft,
                          bottom: overlayBottom,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                autoSteps[index]
                                    .add('Net ${autoSteps[index].length + 1}');
                                isAnimatingNetList[index] = true;
                              });
                              Future.delayed(Duration(milliseconds: 50), () {
                                setState(
                                    () => isAnimatingNetList[index] = false);
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
                                          fontSize: 11 * (scaleFactor - 0.4))),
                                ],
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
                  Text('${sliderValue.toStringAsFixed(2)} m',
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
                                    .copyWith(exit: value)),
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
                                    .copyWith(preload: value)),
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
                    Text('Drive Train'),
                    TextField(
                      onChanged: (value) => handleChange('drive_train', value),
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
                      onChanged: (value) =>
                          handleChange('spare_parts', int.tryParse(value) ?? 0),
                      controller: sparePartsController,
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
