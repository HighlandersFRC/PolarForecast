import 'package:flutter/material.dart';

import '../models/tournament.dart';
import '../pages/death_page.dart';

class DeathLink extends StatelessWidget {
  final int number;
  final Tournament tournament;
  final String value;
  DeathLink(this.number, this.tournament, this.value);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DeathPage(number, tournament))),
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
