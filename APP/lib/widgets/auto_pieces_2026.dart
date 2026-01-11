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

  @override
  Widget build(BuildContext context) {
    String imagePath;
    double imageRotation = 0;

    switch (widget.auto.field_side.length) {
      case 1:
        if (widget.auto.field_side[0] == 'red') {
          imagePath = 'assets/2026GameField_Red.png';
          imageRotation = -1.5708;
        } else {
          imagePath = 'assets/2026GameField_Blue.png';
          imageRotation = 1.5708;
        }
        break;

      case 2:
        imagePath = 'assets/2026GameField_Blue.png';
        imageRotation = 1.5708;
        break;

      default:
        imagePath = 'assets/2026GameField_Blue.png';
        imageRotation = 1.5708;
        break;
    }

    return Center(
      child: Transform.rotate(
        angle: imageRotation,
        child: Image.asset(imagePath),
      ),
    );
  }
}
