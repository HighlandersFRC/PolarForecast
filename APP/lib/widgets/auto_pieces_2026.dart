import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pit_scouting_2026.dart';

class AutoPieces2026 extends StatefulWidget {
  final Auto2026 auto;
  final Function(Auto2026)? onChanged;
  final bool matchScouting, locked;
  const AutoPieces2026(
      {Key? key,
      required this.auto,
      this.onChanged,
      this.matchScouting = false,
      this.locked = false})
      : super(key: key);

  @override
  _AutoPieces2026State createState() => _AutoPieces2026State();
}

class _AutoPieces2026State extends State<AutoPieces2026> {
  bool isFlipped = false;
  List<double> pickupBallScales = [1.0, 1.0, 1.0];
  int formRotation = 0;
  static const double fieldWidthMeters = 8.052;

  Widget buildStepsUI() {
    List<Widget> items = widget.auto.steps.asMap().entries.map((entry) {
      int stepIndex = entry.key;
      String stepLabel = entry.value.name;

      return Card(
        key: ValueKey(stepIndex),
        color: Colors.grey[800],
        child: ListTile(
          title: Text('Step ${stepIndex + 1}: $stepLabel',
              style: TextStyle(color: Colors.white)),
          trailing: widget.onChanged != null && !widget.locked
              ? IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    List<dynamic> newSteps = widget.auto.steps.toList();
                    newSteps.removeAt(stepIndex);
                    var newAuto = widget.auto.copyWith(steps: newSteps);
                    widget.onChanged!(newAuto);
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
                          bottom: displayedImageHeight * 0.11,
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
                        children: [Icon(Icons.rotate_right), Text('Rotate')]),
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
                          widget.auto.starting_position_meters_from_hub_center,
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
                    style: TextStyle(color: Colors.white)),
                buildStepsUI(),
                SizedBox(
                  height: 8,
                ),
                if (!widget.matchScouting)
                  Text('Field Side',
                      style: TextStyle(fontSize: 20, color: Colors.blue)),
                if (!widget.matchScouting)
                  DropdownButton<String>(
                      value: widget.auto.field_side.contains('blue')
                          ? widget.auto.field_side.contains('red')
                              ? 'both'
                              : 'blue'
                          : 'red',
                      hint: Text('Select Option'),
                      isExpanded: true,
                      onChanged: widget.onChanged == null || widget.locked
                          ? null
                          : (newValue) {
                              HapticFeedback.lightImpact();
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
                if (!widget.matchScouting)
                  SwitchListTile(
                    activeColor: Colors.blue,
                    inactiveThumbColor: Colors.blue,
                    title: Text('Preload'),
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
                    activeColor: Colors.blue,
                    inactiveThumbColor: Colors.blue,
                    title: Text('Works on Left and Right?'),
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
    );
  }
}
