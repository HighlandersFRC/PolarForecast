import 'package:flutter/material.dart';

import '../models/tournament.dart';

class PitScoutingLink extends StatelessWidget {
  final int number;
  final Tournament tournament;
  final String value;
  PitScoutingLink(this.number, this.tournament, this.value);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(
          context, '/event/${tournament.key}/pit_scouting/frc$number'),
      child: Text(
        '${value}',
        textScaleFactor: 1.25,
        style: TextStyle(
          color: value == 'Incomplete'
              ? Colors.yellow
              : value == 'Done'
                  ? Colors.green
                  : Colors.red,
          decoration: TextDecoration.underline,
          decorationColor: value == 'Incomplete'
              ? Colors.yellow
              : value == 'Done'
                  ? Colors.green
                  : Colors.red,
        ),
      ),
    );
  }
}
