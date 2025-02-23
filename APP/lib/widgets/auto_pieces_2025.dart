import 'dart:math';

import 'package:flutter/material.dart';

import '../models/pit_scouting_2025.dart';

class AutoPieces2025 extends StatefulWidget {
  final Auto2025 auto;
  final Function(Auto2025)? onChanged;
  final bool matchScouting;
  const AutoPieces2025(
      {Key? key,
      required this.auto,
      this.onChanged,
      this.matchScouting = false})
      : super(key: key);

  @override
  _AutoPieces2025State createState() => _AutoPieces2025State();
}

class _AutoPieces2025State extends State<AutoPieces2025> {
  bool isFlipped = false, isAnimatingNet = false, isAnimatingProcessor = false;
  List<double> pickupBallScales = [1.0, 1.0, 1.0];
  static const double fieldWidthMeters = 8.052;
  static const Color algaeButtonColor = Color.fromARGB(255, 58, 185, 164);
  static const Color coralButtonColor = Colors.white;
  static const Color bothButtonColor = const Color.fromARGB(255, 139, 61, 175);
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

  void _showTriangleMenu(BuildContext context, int triangleIndex) {
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
                                List<AutoStep2025> newList =
                                    widget.auto.steps.toList();
                                newList.add(AutoStep2025(
                                    name: 'place_coral',
                                    extra_data: {
                                      'position': '$letter1${4 - level}'
                                    }));
                                Auto2025 newAuto =
                                    widget.auto.copyWith(steps: newList);
                                widget.onChanged!(newAuto);
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
                                  List<AutoStep2025> newList =
                                      widget.auto.steps.toList();
                                  newList.add(AutoStep2025(
                                      name: 'reef_algae',
                                      extra_data: {
                                        'position': '$letter1-$letter2'
                                      }));
                                  Auto2025 newAuto =
                                      widget.auto.copyWith(steps: newList);
                                  widget.onChanged!(newAuto);
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
                                List<AutoStep2025> newList =
                                    widget.auto.steps.toList();
                                newList.add(AutoStep2025(
                                    name: 'place_coral',
                                    extra_data: {
                                      'position': '$letter2${4 - level}'
                                    }));
                                Auto2025 newAuto =
                                    widget.auto.copyWith(steps: newList);
                                widget.onChanged!(newAuto);
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

  Widget buildStepsUI() {
    List<Widget> items = widget.auto.steps.asMap().entries.map((entry) {
      int stepIndex = entry.key;
      String stepLabel = entry.value.name == 'place_coral'
          ? '${entry.value.extra_data['position']} Coral'
          : entry.value.name == 'net_algae'
              ? 'Net'
              : entry.value.name == 'processor'
                  ? 'Processor'
                  : entry.value.name == 'feeder_pickup'
                      ? entry.value.extra_data['processor_side']
                          ? 'Processor Feeder Pickup'
                          : 'Net Feeder Pickup'
                      : entry.value.name == 'reef_algae'
                          ? 'Removed Algae'
                          : entry.value.name == 'coral_mark_pickup'
                              ? entry.value.extra_data['algae']
                                  ? entry.value.extra_data['coral']
                                      ? 'Coral Mark Pickup - Both'
                                      : 'Coral Mark Pickup - Algae'
                                  : 'Coral Mark Pickup - Coral'
                              : '';
      return Card(
        key: ValueKey(stepIndex),
        color: Colors.grey[800],
        child: ListTile(
          title: Text('Step ${stepIndex + 1}: $stepLabel',
              style: TextStyle(color: Colors.white)),
          trailing: widget.onChanged != null
              ? IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    List<AutoStep2025> newSteps = widget.auto.steps.toList();
                    newSteps.removeAt(stepIndex);
                    var newAuto = widget.auto.copyWith(steps: newSteps);
                    widget.onChanged!(newAuto);
                  },
                )
              : null,
        ),
      );
    }).toList();
    return widget.onChanged == null
        ? ListView(
            children: items,
            shrinkWrap: true,
          )
        : ReorderableListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final autoSteps = widget.auto.steps.toList();
                final item = autoSteps.removeAt(oldIndex);
                autoSteps.insert(newIndex, item);
                var newAuto = widget.auto.copyWith(steps: autoSteps);
                widget.onChanged!(newAuto);
              });
            },
            children: items,
          );
  }

  @override
  Widget build(context) {
    String imagePath;
    double rotation = 0;
    switch (widget.auto.field_side.length) {
      case 1:
        if (widget.auto.field_side[0] == 'red') {
          imagePath = 'assets/2025 REEFSCAPE Gray Background red.png';
          rotation = -1.5708;
          break;
        } else {
          imagePath = 'assets/2025 REEFSCAPE Gray Background blue.png';
          rotation = 1.5708;
          break;
        }
      case 2:
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = constraints.maxWidth;
            double originalImageHeight = 250;
            double originalImageWidth = 250 * 1457 / 1337;
            double scaleFactor = cardWidth / originalImageHeight;
            double displayedImageWidth = cardWidth;
            double displayedImageHeight = originalImageWidth * scaleFactor;
            double pixelsPerMeter = displayedImageWidth / fieldWidthMeters;
            double overlayLeft = displayedImageWidth * 0.05;
            double overlayBottom = displayedImageHeight * 0.2;
            double overlayWidth = displayedImageWidth * 0.2;
            double overlayHeight = displayedImageHeight * 0.3;
            double squareSize = displayedImageWidth * 0.1;
            double squareLeft =
                widget.auto.starting_position_meters_from_processor *
                    pixelsPerMeter *
                    7.25 /
                    fieldWidthMeters;
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
              Color triangleColor = (i % 2 == 0) ? Colors.green : Colors.purple;

              triangleWidgets.add(Positioned(
                left: centerX,
                top: centerY,
                child: buildTriangle(
                  size: triangleSize,
                  color: triangleColor.withOpacity(0.75),
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

            double feederButtonSize = displayedImageWidth * 0.175;
            double ballSize = displayedImageWidth * 0.08;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (TapDownDetails details) {
                    RenderBox box = context.findRenderObject() as RenderBox;
                    Offset localPos = box.globalToLocal(details.globalPosition);
                    int selectedTriangle = -1;
                    double minDistance = double.infinity;
                    double triangleSizeLocal = displayedImageWidth * 0.075;
                    double centroidDist = (2 * triangleSizeLocal * sqrt(3)) / 3;
                    for (int i = 0; i < triangleCount; i++) {
                      int shiftedIndex = (i + 4) % triangleCount;
                      double angle = (-2 * pi / triangleCount) * shiftedIndex;
                      double triCenterX = centerX - centroidDist * sin(angle);
                      double triCenterY = centerY + centroidDist * cos(angle);
                      double distance = sqrt(pow(localPos.dx - triCenterX, 2) +
                          pow(localPos.dy - triCenterY, 2));
                      if (distance < minDistance) {
                        minDistance = distance;
                        selectedTriangle = i;
                      }
                    }
                    if (minDistance > triangleSizeLocal) return;
                    if (widget.onChanged != null)
                      _showTriangleMenu(context, selectedTriangle);
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
                            left: overlayLeft,
                            right: null,
                            bottom: overlayBottom,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : () {
                                      setState(() {
                                        var autoSteps =
                                            widget.auto.steps.toList();
                                        autoSteps.add(AutoStep2025(
                                            name: 'processor', extra_data: {}));
                                        isAnimatingProcessor = true;
                                        var newAuto = widget.auto
                                            .copyWith(steps: autoSteps);
                                        widget.onChanged!(newAuto);
                                      });
                                      Future.delayed(Durations.medium1, () {
                                        setState(
                                            () => isAnimatingProcessor = false);
                                      });
                                    },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingProcessor
                                    ? overlayWidth * 1.1
                                    : overlayWidth,
                                height: isAnimatingProcessor
                                    ? overlayHeight * 1.1
                                    : overlayHeight,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.build,
                                        color: Colors.white,
                                        size: (28) * scaleFactor),
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
                            left: null,
                            right: overlayLeft,
                            bottom: overlayBottom,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : () {
                                      setState(() {
                                        var autoSteps =
                                            widget.auto.steps.toList();
                                        autoSteps.add(AutoStep2025(
                                            name: 'net_algae',
                                            extra_data: {
                                              'position': 'center'
                                            }));
                                        var newAuto = widget.auto
                                            .copyWith(steps: autoSteps);
                                        isAnimatingNet = true;
                                        widget.onChanged!(newAuto);
                                      });
                                      Future.delayed(Durations.medium1, () {
                                        setState(() => isAnimatingNet = false);
                                      });
                                    },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingNet
                                    ? overlayHeight * 1.1
                                    : overlayHeight,
                                height: isAnimatingNet
                                    ? overlayWidth * 1.1
                                    : overlayWidth,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.grid_4x4,
                                        color: Colors.white,
                                        size: (28) * scaleFactor),
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
                          onTap: widget.onChanged == null
                              ? () {}
                              : () {
                                  bool feederNear = true;
                                  setState(() {
                                    var autoSteps = widget.auto.steps.toList();
                                    autoSteps.add(AutoStep2025(
                                        name: 'feeder_pickup',
                                        extra_data: {
                                          'processor_side': feederNear,
                                          'position': 'left'
                                        }));
                                    var newAuto =
                                        widget.auto.copyWith(steps: autoSteps);
                                    widget.onChanged!(newAuto);
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
                          onTap: widget.onChanged == null
                              ? () {}
                              : () {
                                  bool feederNear = false;
                                  setState(() {
                                    var autoSteps = widget.auto.steps.toList();
                                    autoSteps.add(AutoStep2025(
                                        name: 'feeder_pickup',
                                        extra_data: {
                                          'processor_side': feederNear,
                                          'position': 'left'
                                        }));
                                    var newAuto =
                                        widget.auto.copyWith(steps: autoSteps);
                                    widget.onChanged!(newAuto);
                                  });
                                },
                        ),
                      ),
                      Positioned(
                        left: displayedImageWidth * 0.285 - ballSize / 2,
                        top: displayedImageHeight * 0.125,
                        child: GestureDetector(
                          onTap: widget.onChanged == null
                              ? null
                              : () {
                                  setState(() {
                                    pickupBallScales[0] = 1.2;
                                  });
                                  Future.delayed(Durations.medium1, () {
                                    setState(() {
                                      pickupBallScales[0] = 1.0;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          title: Text(
                                              'Select Option for processor'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      algaeButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: widget.onChanged ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var autoSteps = widget
                                                              .auto.steps
                                                              .toList();
                                                          autoSteps.add(
                                                              AutoStep2025(
                                                                  name:
                                                                      'coral_mark_pickup',
                                                                  extra_data: {
                                                                'position':
                                                                    'processor',
                                                                'algae': true,
                                                                'coral': false
                                                              }));
                                                          var newAuto = widget
                                                              .auto
                                                              .copyWith(
                                                                  steps:
                                                                      autoSteps);
                                                          widget.onChanged!(
                                                              newAuto);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                child: Text('Algae',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              SizedBox(height: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      coralButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: widget.onChanged ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var autoSteps = widget
                                                              .auto.steps
                                                              .toList();
                                                          autoSteps.add(
                                                              AutoStep2025(
                                                                  name:
                                                                      'coral_mark_pickup',
                                                                  extra_data: {
                                                                'position':
                                                                    'processor',
                                                                'algae': false,
                                                                'coral': true
                                                              }));
                                                          var newAuto = widget
                                                              .auto
                                                              .copyWith(
                                                                  steps:
                                                                      autoSteps);
                                                          widget.onChanged!(
                                                              newAuto);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                child: Text('Coral',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                              ),
                                              SizedBox(height: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      bothButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: widget.onChanged ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var autoSteps = widget
                                                              .auto.steps
                                                              .toList();
                                                          autoSteps.add(
                                                              AutoStep2025(
                                                                  name:
                                                                      'coral_mark_pickup',
                                                                  extra_data: {
                                                                'position':
                                                                    'processor',
                                                                'algae': true,
                                                                'coral': true
                                                              }));
                                                          var newAuto = widget
                                                              .auto
                                                              .copyWith(
                                                                  steps:
                                                                      autoSteps);
                                                          widget.onChanged!(
                                                              newAuto);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
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
                            scale: pickupBallScales[0],
                            duration: Durations.medium1,
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
                          onTap: widget.onChanged == null
                              ? null
                              : () {
                                  setState(() {
                                    pickupBallScales[1] = 1.2;
                                  });
                                  Future.delayed(Durations.medium1, () {
                                    setState(() {
                                      pickupBallScales[1] = 1.0;
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
                                              Text('Select Option for middle'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      algaeButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: widget.onChanged ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var autoSteps = widget
                                                              .auto.steps
                                                              .toList();
                                                          autoSteps.add(
                                                              AutoStep2025(
                                                                  name:
                                                                      'coral_mark_pickup',
                                                                  extra_data: {
                                                                'position':
                                                                    'middle',
                                                                'algae': true,
                                                                'coral': false
                                                              }));
                                                          var newAuto = widget
                                                              .auto
                                                              .copyWith(
                                                                  steps:
                                                                      autoSteps);
                                                          widget.onChanged!(
                                                              newAuto);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                child: Text('Algae',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              SizedBox(height: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      coralButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: widget.onChanged ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var autoSteps = widget
                                                              .auto.steps
                                                              .toList();
                                                          autoSteps.add(
                                                              AutoStep2025(
                                                                  name:
                                                                      'coral_mark_pickup',
                                                                  extra_data: {
                                                                'position':
                                                                    'middle',
                                                                'algae': false,
                                                                'coral': true
                                                              }));
                                                          var newAuto = widget
                                                              .auto
                                                              .copyWith(
                                                                  steps:
                                                                      autoSteps);
                                                          widget.onChanged!(
                                                              newAuto);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                child: Text('Coral',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                              ),
                                              SizedBox(height: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      bothButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: widget.onChanged ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var autoSteps = widget
                                                              .auto.steps
                                                              .toList();
                                                          autoSteps.add(
                                                              AutoStep2025(
                                                                  name:
                                                                      'coral_mark_pickup',
                                                                  extra_data: {
                                                                'position':
                                                                    'middle',
                                                                'algae': true,
                                                                'coral': true
                                                              }));
                                                          var newAuto = widget
                                                              .auto
                                                              .copyWith(
                                                                  steps:
                                                                      autoSteps);
                                                          widget.onChanged!(
                                                              newAuto);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
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
                            scale: pickupBallScales[1],
                            duration: Durations.medium1,
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
                          onTap: widget.onChanged == null
                              ? null
                              : () {
                                  setState(() {
                                    pickupBallScales[2] = 1.2;
                                  });
                                  Future.delayed(Durations.medium1, () {
                                    setState(() {
                                      pickupBallScales[2] = 1.0;
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
                                              Text('Select Option for other'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      algaeButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: widget.onChanged ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var autoSteps = widget
                                                              .auto.steps
                                                              .toList();
                                                          autoSteps.add(
                                                              AutoStep2025(
                                                                  name:
                                                                      'coral_mark_pickup',
                                                                  extra_data: {
                                                                'position':
                                                                    'other',
                                                                'algae': true,
                                                                'coral': false
                                                              }));
                                                          var newAuto = widget
                                                              .auto
                                                              .copyWith(
                                                                  steps:
                                                                      autoSteps);
                                                          widget.onChanged!(
                                                              newAuto);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                child: Text('Algae',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              SizedBox(height: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      coralButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: widget.onChanged ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var autoSteps = widget
                                                              .auto.steps
                                                              .toList();
                                                          autoSteps.add(
                                                              AutoStep2025(
                                                                  name:
                                                                      'coral_mark_pickup',
                                                                  extra_data: {
                                                                'position':
                                                                    'other',
                                                                'algae': false,
                                                                'coral': true
                                                              }));
                                                          var newAuto = widget
                                                              .auto
                                                              .copyWith(
                                                                  steps:
                                                                      autoSteps);
                                                          widget.onChanged!(
                                                              newAuto);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                child: Text('Coral',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                              ),
                                              SizedBox(height: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      bothButtonColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                onPressed: widget.onChanged ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          var autoSteps = widget
                                                              .auto.steps
                                                              .toList();
                                                          autoSteps.add(
                                                              AutoStep2025(
                                                                  name:
                                                                      'coral_mark_pickup',
                                                                  extra_data: {
                                                                'position':
                                                                    'other',
                                                                'algae': true,
                                                                'coral': true
                                                              }));
                                                          var newAuto = widget
                                                              .auto
                                                              .copyWith(
                                                                  steps:
                                                                      autoSteps);
                                                          widget.onChanged!(
                                                              newAuto);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
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
                            scale: pickupBallScales[2],
                            duration: Durations.medium1,
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
                      value:
                          widget.auto.starting_position_meters_from_processor,
                      inactiveColor: Colors.lightBlue,
                      activeColor: Colors.lightBlue,
                      thumbColor: Colors.white,
                      min: 0,
                      max: fieldWidthMeters,
                      onChanged: widget.onChanged == null
                          ? null
                          : (value) {
                              widget.onChanged!(widget.auto.copyWith(
                                  starting_position_meters_from_processor:
                                      value));
                            },
                    ),
                  ),
                ),
                Text(
                    '${widget.auto.starting_position_meters_from_processor.toStringAsFixed(2)} meters',
                    style: TextStyle(color: Colors.white)),
                buildStepsUI(),
                SizedBox(
                  height: 8,
                ),
                Text('Field Side',
                    style: TextStyle(fontSize: 20, color: Colors.blue)),
                DropdownButton<String>(
                    value: widget.auto.field_side.contains('blue')
                        ? widget.auto.field_side.contains('red')
                            ? 'both'
                            : 'blue'
                        : 'red',
                    hint: Text('Select Option'),
                    isExpanded: true,
                    onChanged: widget.onChanged == null
                        ? null
                        : (newValue) {
                            if (newValue != null)
                              setState(() {
                                List<String> newFieldSide = newValue == 'both'
                                    ? ['red', 'blue']
                                    : [newValue];
                                widget.onChanged!(widget.auto
                                    .copyWith(field_side: newFieldSide));
                              });
                          },
                    items: [
                      DropdownMenuItem(
                          value: 'red',
                          child: Text(
                            'Red Side',
                            style: TextStyle(color: Colors.red),
                          )),
                      DropdownMenuItem(
                          value: 'blue',
                          child: Text(
                            'Blue Side',
                            style: TextStyle(color: Colors.blue),
                          )),
                      DropdownMenuItem(
                          value: 'both',
                          child: Text(
                            'Both',
                            style: TextStyle(color: Colors.white),
                          )),
                    ]),
                SwitchListTile(
                  activeColor: Colors.blue,
                  title: Text('Exit'),
                  value: widget.auto.exit,
                  onChanged: widget.onChanged == null
                      ? null
                      : (bool value) {
                          widget.onChanged!(widget.auto.copyWith(exit: value));
                        },
                ),
                SwitchListTile(
                  activeColor: Colors.blue,
                  title: Text('Preload'),
                  value: widget.auto.preload,
                  onChanged: widget.onChanged == null
                      ? null
                      : (bool value) {
                          widget
                              .onChanged!(widget.auto.copyWith(preload: value));
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FeederButton extends StatefulWidget {
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
  _FeederButtonState createState() => _FeederButtonState();
}

class _FeederButtonState extends State<FeederButton> {
  bool isAnimating = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isAnimating = true;
        });
        widget.onTap();
        Future.delayed(Durations.medium1, () {
          setState(() {
            isAnimating = false;
          });
        });
      },
      child: ClipPath(
        clipper: RoundedRectangleClipper(cornerRadius: 3.0, scaleFactor: 8),
        child: AnimatedContainer(
          duration: Durations.medium1,
          width: isAnimating ? widget.size * 1.1 : widget.size,
          height: isAnimating ? widget.size * 1.1 : widget.size,
          color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.75),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_box_rounded,
                  color: Colors.white,
                  size: widget.size * 0.3,
                ),
                SizedBox(height: widget.size * 0.05),
                Text(
                  'Feeder',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontSize: widget.size * 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
