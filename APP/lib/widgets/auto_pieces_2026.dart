import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';

import '../models/pit_scouting_2026.dart';

class AutoPieces2026 extends StatefulWidget {
  final Auto2026 auto;
  final Function(Auto2026)? onChanged;
  final Function(AutoScoring)? onAutoScoringChanged;
  final bool matchScouting, locked;

  const AutoPieces2026(
      {Key? key,
      required this.auto,
      this.onChanged,
      this.matchScouting = false,
      this.locked = false,
      this.onAutoScoringChanged})
      : super(key: key);

  @override
  _AutoPieces2026State createState() => _AutoPieces2026State();
}

class _AutoPieces2026State extends State<AutoPieces2026> {
  bool isFlipped = false;
  List<double> pickupBallScales = [1.0, 1.0, 1.0];
  int formRotation = 0;
  bool isAnimatingDepot = false;
  bool isAnimatingTrenchR = false;
  bool isAnimatingTrenchL = false;
  bool isAnimatingBumpL = false;
  bool isAnimatingBumpR = false;
  bool isAnimatingDropdown = false;
  bool isAnimatingNeutralZone = false;
  bool isAnimatingHub = false;
  static const double fieldWidthMeters = 8.052;

  Offset? robotPosition;

  void _openShotLocationDialog(
    BuildContext context,
    double width,
    double height,
    String imagePath,
    double imageRotation,
    double pixelsPerMeter,
    double squareSize,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: const Text('Shoot Location',
                style: TextStyle(color: Colors.white, fontFamily: 'Font')),
            content: SizedBox(
              width: width,
              height: height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final local = details.localPosition;

                  // Restrict to lower half
                  if (local.dy < height * 0.5) return;

                  final centeredX = local.dx - squareSize / 2;
                  final centeredY = local.dy - squareSize / 2;

                  final position = Offset(
                    centeredX.clamp(0.0, width - squareSize),
                    centeredY.clamp(height * 0.5, height - squareSize),
                  );

                  final xMeters = position.dx / pixelsPerMeter;
                  final yMeters = position.dy / pixelsPerMeter;

                  HapticFeedback.lightImpact();

                  // --- Add AutoStep for shot ---
                  final autoSteps = widget.auto.steps.toList();
                  autoSteps.add(
                    AutoStep2026(
                      name:
                          'Shot at X: ${xMeters.toStringAsFixed(2)}m, Y: ${yMeters.toStringAsFixed(2)}m',
                      extra_data: {
                        'shots_from_x': xMeters,
                        'shots_from_y': yMeters,
                      },
                    ),
                  );

                  // --- Add "Scored in Hub" step ---
                  autoSteps.add(
                      AutoStep2026(name: 'Scored in the Hub', extra_data: {}));

                  // --- Update scoring ---

                  widget.onChanged!(widget.auto.copyWith(steps: autoSteps));

                  Navigator.pop(context); // close dialog
                },
                child: Stack(
                  children: [
                    Transform.rotate(
                      angle: imageRotation,
                      child: Image.asset(
                        imagePath,
                        width: width,
                        height: height,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  bool robotPlaced = false;
  final GlobalKey dropdownKey = GlobalKey();

  Widget buildStepsUI() {
    List<Widget> items = widget.auto.steps.asMap().entries.map((entry) {
      int stepIndex = entry.key;
      String stepLabel = entry.value.name;

      return Card(
        key: ValueKey(stepIndex),
        color: Colors.grey[800],
        child: ListTile(
          title: Text('Step ${stepIndex + 1}: $stepLabel',
              style: TextStyle(color: Colors.white, fontFamily: 'Font')),
          trailing: widget.onChanged != null && !widget.locked
              ? IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final newSteps =
                        widget.auto.steps.toList(); // makes mutable copy
                    newSteps.removeAt(stepIndex);

                    widget.onChanged!(
                      widget.auto.copyWith(steps: newSteps),
                    );
                  },
                )
              : null,
        ),
      );
    }).toList();

    return widget.onChanged == null || widget.locked
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
  Widget build(BuildContext context) {
    String imagePath;
    double imageRotation = 0;

    switch (widget.auto.field_side.length) {
      case 1:
        if (widget.auto.field_side[0] == 'red') {
          imagePath = '2026GameField_Red.png';
          imageRotation = -1.5708;
        } else {
          imagePath = '2026GameField_Blue.png';
          imageRotation = 1.5708;
        }
        break;

      case 2:
        imagePath = '2026GameField_Blue.png';
        imageRotation = 1.5708;
        break;

      default:
        imagePath = '2026GameField_Blue.png';
        imageRotation = 1.5708;
        break;
    }

    return Center(
      child: Card(
        elevation: 8,
        surfaceTintColor: const Color.fromARGB(255, 240, 238, 233),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth = min(constraints.maxWidth, 500);
              double originalImageHeight = 250;
              double originalImageWidth = 250 * 1457 / 1337;
              double scaleFactor = cardWidth / originalImageHeight;
              double displayedImageWidth = cardWidth;
              double displayedImageHeight = originalImageWidth * scaleFactor;

              if (formRotation % 2 == 1) {
                displayedImageHeight = cardWidth;
                displayedImageWidth = originalImageHeight * scaleFactor;
              }

              double pixelsPerMeter = displayedImageWidth / fieldWidthMeters;
              double squareSize = displayedImageWidth * 0.1;
              double squareLeft =
                  widget.auto.starting_position_meters_from_hub_center *
                      pixelsPerMeter *
                      7.25 /
                      fieldWidthMeters;
              if (squareLeft < 0) squareLeft = 0;
              if (squareLeft > displayedImageWidth - squareSize)
                squareLeft = displayedImageWidth - squareSize;

              double overlayWidth = displayedImageWidth * 0.12;
              double overlayHeight = displayedImageHeight * 0.07;

              double overlayWidthTrussR = displayedImageWidth * 0.16;
              double overlayHeightTrussR = displayedImageHeight * 0.15;

              double overlayWidthTrussL = displayedImageWidth * 0.16;
              double overlayHeightTrussL = displayedImageHeight * 0.15;

              double overlayWidthBumpL = displayedImageWidth * 0.16;
              double overlayHeightBumpL = displayedImageHeight * 0.15;

              double overlayWidthBumpR = displayedImageWidth * 0.16;
              double overlayHeightBumpR = displayedImageHeight * 0.15;

              double overlayWidthDropdown = displayedImageWidth * 0.15;
              double overlayHeightDropdown = displayedImageHeight * 0.1;

              double overlayWidthNeutralZone = displayedImageWidth * 0.55;
              double overlayHeightNeutralZone = displayedImageHeight * 0.12;

              double overlayWidthHub = displayedImageWidth * 0.35;
              double overlayHeightHub = displayedImageHeight * 0.1;

              double overlayWidthHuman = displayedImageWidth * 0.11;
              double overlayHeightHuman = displayedImageHeight * 0.1;

              robotPosition ??= Offset(
                displayedImageWidth * 0.45, // middle horizontally
                displayedImageHeight * 0.65, // middle of lower half vertically
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onChanged != null && !widget.locked)
                    RotatedBox(
                      quarterTurns: formRotation,
                      child: Stack(
                        children: [
                          Transform.rotate(
                            angle: imageRotation,
                            child: Image.asset(
                              imagePath,
                              width: displayedImageWidth,
                              height: displayedImageHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            bottom: displayedImageHeight * 0.45,
                            left: squareLeft,
                            child: Container(
                              width: squareSize,
                              height: squareSize,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.blue,
                                    width: displayedImageHeight * 0.005),
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.black87.withOpacity(0.2),
                              ),
                              child: Icon(Icons.smart_toy,
                                  size: 15 * scaleFactor, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            left: displayedImageWidth * 0.23,
                            bottom: displayedImageHeight * 0.12,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : widget.locked
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            var autoSteps =
                                                widget.auto.steps.toList();
                                            autoSteps.add(AutoStep2026(
                                                name: 'Intaked at Depot',
                                                extra_data: {}));
                                            isAnimatingDepot = true;
                                            var newAuto = widget.auto
                                                .copyWith(steps: autoSteps);
                                            widget.onChanged!(newAuto);
                                          });
                                          Future.delayed(Durations.medium1, () {
                                            setState(
                                                () => isAnimatingDepot = false);
                                          });
                                        },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingDepot
                                    ? overlayWidth * 1.1
                                    : overlayWidth,
                                height: isAnimatingDepot
                                    ? overlayHeight * 1.1
                                    : overlayHeight,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(145, 255, 238, 203),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Depot',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 11 * (scaleFactor - 0.4),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: displayedImageWidth * 0.82,
                            bottom: displayedImageHeight * 0.05,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : widget.locked
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            var autoSteps =
                                                widget.auto.steps.toList();
                                            autoSteps.add(AutoStep2026(
                                                name: 'Intaked at Human Player',
                                                extra_data: {}));
                                            isAnimatingDepot = true;
                                            var newAuto = widget.auto
                                                .copyWith(steps: autoSteps);
                                            widget.onChanged!(newAuto);
                                          });
                                          Future.delayed(Durations.medium1, () {
                                            setState(
                                                () => isAnimatingDepot = false);
                                          });
                                        },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingDepot
                                    ? overlayWidthHuman * 1.1
                                    : overlayWidthHuman,
                                height: isAnimatingDepot
                                    ? overlayHeightHuman * 1.1
                                    : overlayHeightHuman,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(145, 255, 238, 203),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Human Player',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 11 * (scaleFactor - 0.4),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: displayedImageWidth * 0.32,
                            bottom: displayedImageHeight * 0.3,
                            child: GestureDetector(
                              onTap: () {
                                if (widget.onChanged == null ||
                                    widget.onAutoScoringChanged == null ||
                                    widget.locked) return;
                                HapticFeedback.lightImpact();
                                _openShotLocationDialog(
                                  context,
                                  displayedImageWidth,
                                  displayedImageHeight,
                                  imagePath,
                                  imageRotation,
                                  pixelsPerMeter,
                                  squareSize,
                                );
                              },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: overlayWidthHub,
                                height: overlayHeightHub,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color.fromARGB(142, 1, 57, 126),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sports_score,
                                        color: Colors.white,
                                        size: 18 * scaleFactor),
                                    SizedBox(height: 4),
                                    Text(
                                      'Scored in Hub',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11 * (scaleFactor - 0.4),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: displayedImageWidth * 0.8,
                            bottom: displayedImageHeight * 0.52,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : widget.locked
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            var autoSteps =
                                                widget.auto.steps.toList();
                                            autoSteps.add(AutoStep2026(
                                                name: 'Went under Right Trench',
                                                extra_data: {}));
                                            isAnimatingTrenchR = true;
                                            var newAuto = widget.auto
                                                .copyWith(steps: autoSteps);
                                            widget.onChanged!(newAuto);
                                          });
                                          Future.delayed(Durations.medium1, () {
                                            setState(() =>
                                                isAnimatingTrenchR = false);
                                          });
                                        },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingTrenchR
                                    ? overlayWidthTrussR * 1.1
                                    : overlayWidthTrussR,
                                height: isAnimatingTrenchR
                                    ? overlayHeightTrussR * 1.1
                                    : overlayHeightTrussR,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(145, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_down, // depot-style icon
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      size: 18 * scaleFactor,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'R Trench',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 11 * (scaleFactor - 0.4),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: displayedImageWidth * 0.05,
                            bottom: displayedImageHeight * 0.52,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : widget.locked
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            var autoSteps =
                                                widget.auto.steps.toList();
                                            autoSteps.add(AutoStep2026(
                                                name: 'Went under Left Trench',
                                                extra_data: {}));
                                            isAnimatingTrenchL = true;
                                            var newAuto = widget.auto
                                                .copyWith(steps: autoSteps);
                                            widget.onChanged!(newAuto);
                                          });
                                          Future.delayed(Durations.medium1, () {
                                            setState(() =>
                                                isAnimatingTrenchL = false);
                                          });
                                        },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingTrenchL
                                    ? overlayWidthTrussL * 1.1
                                    : overlayWidthTrussL,
                                height: isAnimatingTrenchL
                                    ? overlayHeightTrussL * 1.1
                                    : overlayHeightTrussL,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(142, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_down, // depot-style icon
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      size: 18 * scaleFactor,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'L Trench',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 11 * (scaleFactor - 0.4),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: displayedImageWidth * 0.25,
                            bottom: displayedImageHeight * 0.52,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : widget.locked
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            var autoSteps =
                                                widget.auto.steps.toList();
                                            autoSteps.add(AutoStep2026(
                                                name: 'Went over Left Bump',
                                                extra_data: {}));
                                            isAnimatingBumpL = true;
                                            var newAuto = widget.auto
                                                .copyWith(steps: autoSteps);
                                            widget.onChanged!(newAuto);
                                          });
                                          Future.delayed(Durations.medium1, () {
                                            setState(
                                                () => isAnimatingBumpL = false);
                                          });
                                        },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingBumpL
                                    ? overlayWidthBumpL * 1.1
                                    : overlayWidthBumpL,
                                height: isAnimatingBumpL
                                    ? overlayHeightBumpL * 1.1
                                    : overlayHeightBumpL,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(142, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_up, // depot-style icon
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      size: 18 * scaleFactor,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'L Bump',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 11 * (scaleFactor - 0.4),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: displayedImageWidth * 0.61,
                            bottom: displayedImageHeight * 0.52,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : widget.locked
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            var autoSteps =
                                                widget.auto.steps.toList();
                                            autoSteps.add(AutoStep2026(
                                                name: 'Went over Right Bump',
                                                extra_data: {}));
                                            isAnimatingBumpR = true;
                                            var newAuto = widget.auto
                                                .copyWith(steps: autoSteps);
                                            widget.onChanged!(newAuto);
                                          });
                                          Future.delayed(Durations.medium1, () {
                                            setState(
                                                () => isAnimatingBumpR = false);
                                          });
                                        },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingBumpR
                                    ? overlayWidthBumpR * 1.1
                                    : overlayWidthBumpR,
                                height: isAnimatingBumpR
                                    ? overlayHeightBumpR * 1.1
                                    : overlayHeightBumpR,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(142, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_up, // depot-style icon
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      size: 18 * scaleFactor,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'R Bump',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 11 * (scaleFactor - 0.4),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: displayedImageWidth * 0.225,
                            bottom: displayedImageHeight * 0.85,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : widget.locked
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            var autoSteps =
                                                widget.auto.steps.toList();
                                            autoSteps.add(AutoStep2026(
                                                name: 'Intaked at Neutral Zone',
                                                extra_data: {}));
                                            isAnimatingNeutralZone = true;
                                            var newAuto = widget.auto
                                                .copyWith(steps: autoSteps);
                                            widget.onChanged!(newAuto);
                                          });
                                          Future.delayed(Durations.medium1, () {
                                            setState(() =>
                                                isAnimatingNeutralZone = false);
                                          });
                                        },
                              child: AnimatedContainer(
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingNeutralZone
                                    ? overlayWidthNeutralZone * 1.1
                                    : overlayWidthNeutralZone,
                                height: isAnimatingNeutralZone
                                    ? overlayHeightNeutralZone * 1.1
                                    : overlayHeightNeutralZone,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(145, 255, 238, 203),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.gas_meter, // depot-style icon
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      size: 18 * scaleFactor,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Neutral Zone',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 11 * (scaleFactor - 0.4),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Font'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: displayedImageWidth * 0.46,
                            bottom: displayedImageHeight * 0.12,
                            child: GestureDetector(
                              onTap: widget.onChanged == null
                                  ? null
                                  : widget.locked
                                      ? null
                                      : !widget.matchScouting
                                          ? () {
                                              HapticFeedback.lightImpact();
                                              setState(() {
                                                var autoSteps =
                                                    widget.auto.steps.toList();
                                                autoSteps.add(AutoStep2026(
                                                    name:
                                                        'Can Climb in Autonomous',
                                                    extra_data: {}));
                                                isAnimatingDropdown = true;
                                                var newAuto = widget.auto
                                                    .copyWith(steps: autoSteps);
                                                widget.onChanged!(newAuto);
                                              });
                                              Future.delayed(Durations.medium1,
                                                  () {
                                                setState(() =>
                                                    isAnimatingDropdown =
                                                        false);
                                              });
                                            }
                                          : () {
                                              setState(() {
                                                isAnimatingDropdown = true;
                                              });
                                              Future.delayed(Durations.medium1,
                                                  () {
                                                setState(() =>
                                                    isAnimatingDropdown =
                                                        false);
                                              });
                                              showMenu(
                                                context: context,
                                                position: RelativeRect.fromRect(
                                                  (dropdownKey.currentContext!
                                                                  .findRenderObject()
                                                              as RenderBox)
                                                          .localToGlobal(
                                                              Offset.zero) &
                                                      (dropdownKey.currentContext!
                                                                  .findRenderObject()
                                                              as RenderBox)
                                                          .size,
                                                  Offset.zero &
                                                      (Overlay.of(context)
                                                                  .context
                                                                  .findRenderObject()
                                                              as RenderBox)
                                                          .size,
                                                ),
                                                items: const [
                                                  PopupMenuItem(
                                                    value: 'left',
                                                    child: Text(
                                                        'Left Side Rung Climb',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'Font')),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'center',
                                                    child: Text(
                                                        'Center Rung Climb',
                                                        style: TextStyle(
                                                            color: Colors.blue,
                                                            fontFamily:
                                                                'Font')),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'right',
                                                    child: Text(
                                                        'Right Side Rung Climb',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .deepPurple,
                                                            fontFamily:
                                                                'Font')),
                                                  ),
                                                ],
                                              ).then((value) {
                                                if (value == null) return;

                                                HapticFeedback.lightImpact();

                                                // 1️⃣ Update AUTO STEPS
                                                final autoSteps =
                                                    widget.auto.steps.toList();
                                                autoSteps.add(
                                                  AutoStep2026(
                                                    name:
                                                        '${value[0].toUpperCase()}${value.substring(1)} Side Rung Climb',
                                                    extra_data: {},
                                                  ),
                                                );

                                                widget.onChanged?.call(
                                                  widget.auto.copyWith(
                                                      steps: autoSteps),
                                                );
                                              });
                                            },
                              child: AnimatedContainer(
                                key: dropdownKey,
                                duration: Durations.medium1,
                                curve: Curves.easeInOutQuad,
                                width: isAnimatingDropdown
                                    ? overlayWidthDropdown * 1.1
                                    : overlayWidthDropdown,
                                height: isAnimatingDropdown
                                    ? overlayHeightDropdown * 1.1
                                    : overlayHeightDropdown,
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 4),
                                    Text('Climb',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11 * (scaleFactor - 0.4),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Font')),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.onChanged == null || widget.locked)
                    Transform.rotate(
                      angle: imageRotation,
                      child: Image.asset(
                        imagePath,
                        width: displayedImageWidth,
                        height: displayedImageHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (widget.onChanged != null && !widget.locked)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => formRotation += 1);
                      },
                      label: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rotate_right),
                            Text('Rotate', style: TextStyle(fontFamily: 'Font'))
                          ]),
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
                        value: widget
                            .auto.starting_position_meters_from_hub_center
                            .toDouble(),
                        inactiveColor: Colors.lightBlue,
                        activeColor: Colors.lightBlue,
                        thumbColor: Colors.white,
                        min: 0,
                        max: fieldWidthMeters,
                        onChanged: widget.onChanged == null || widget.locked
                            ? null
                            : (value) {
                                HapticFeedback.lightImpact();
                                widget.onChanged!(widget.auto.copyWith(
                                    starting_position_meters_from_hub_center:
                                        value));
                              },
                      ),
                    ),
                  ),
                  Text(
                      '${widget.auto.starting_position_meters_from_hub_center.toStringAsFixed(2)} meters',
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Font')),
                  buildStepsUI(),
                  if (!widget.matchScouting)
                    Text('Field Side',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontFamily: 'Font')),
                  if (!widget.matchScouting)
                    DropdownButton<String>(
                        value: widget.auto.field_side.contains('blue')
                            ? widget.auto.field_side.contains('red')
                                ? 'both'
                                : 'blue'
                            : 'red',
                        hint: Text('Select Option',
                            style: TextStyle(fontFamily: 'Font')),
                        isExpanded: true,
                        onChanged: widget.onChanged == null || widget.locked
                            ? null
                            : (newValue) {
                                HapticFeedback.lightImpact();
                                if (newValue != null)
                                  setState(() {
                                    List<String> newFieldSide =
                                        newValue == 'both'
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
                                style: TextStyle(
                                    color: Colors.red, fontFamily: 'Font'),
                              )),
                          DropdownMenuItem(
                              value: 'blue',
                              child: Text(
                                'Blue Side',
                                style: TextStyle(
                                    color: Colors.blue, fontFamily: 'Font'),
                              )),
                          DropdownMenuItem(
                              value: 'both',
                              child: Text(
                                'Both',
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Font'),
                              )),
                        ]),
                  if (!widget.matchScouting)
                    SwitchListTile(
                      activeThumbColor: Colors.blue,
                      inactiveThumbColor: Colors.blue,
                      title:
                          Text('Preload', style: TextStyle(fontFamily: 'Font')),
                      value: widget.auto.preload,
                      onChanged: widget.onChanged == null || widget.locked
                          ? null
                          : (bool value) {
                              HapticFeedback.lightImpact();
                              widget.onChanged!(
                                  widget.auto.copyWith(preload: value));
                            },
                    ),
                  if (!widget.matchScouting)
                    SwitchListTile(
                      activeThumbColor: Colors.blue,
                      inactiveThumbColor: Colors.blue,
                      title: Text('Works on Left and Right?',
                          style: TextStyle(fontFamily: 'Font')),
                      value: widget.auto.both_sides,
                      onChanged: widget.onChanged == null || widget.locked
                          ? null
                          : (bool value) {
                              HapticFeedback.lightImpact();
                              widget.onChanged!(
                                  widget.auto.copyWith(both_sides: value));
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
}
