import 'package:flutter/material.dart';

import '../models/tournament.dart';

class TeamLink extends StatelessWidget {
  final int number;
  final Tournament tournament;
  TeamLink(this.number, this.tournament);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        constraints: BoxConstraints.expand(),
        child: TextButton(
          onPressed: () => Navigator.pushNamed(
              context, '/event/${tournament.key}/team/frc$number'),
          child: Text(
            '${number}',
            textScaler: TextScaler.linear(1.25),
            style: TextStyle(
                color: theme.primaryColor,
                decoration: TextDecoration.underline,
                decorationColor: theme.primaryColor),
          ),
        ));
  }
}
