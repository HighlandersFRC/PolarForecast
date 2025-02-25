import 'package:flutter/material.dart';
import '../models/tournament.dart';

class PicturesLink extends StatelessWidget {
  final int number;
  final Tournament tournament;
  final String value;

  PicturesLink(this.number, this.tournament, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(),
        child: TextButton(
          onPressed: () => Navigator.pushNamed(
              context, '/event/${tournament.key}/pictures/frc$number'),
          child: Text(
            '${value}',
            textScaler: TextScaler.linear(1.25),
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
        ));
  }
}
