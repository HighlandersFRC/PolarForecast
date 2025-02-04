import 'package:flutter/material.dart';

import '../models/tournament.dart';

class MatchLink extends StatelessWidget {
  final String match_key;
  final String display;
  final Tournament tournament;
  MatchLink(this.display, this.match_key, this.tournament);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        constraints: BoxConstraints.expand(),
        child: TextButton(
          onPressed: () => Navigator.pushNamed(
              context, '/event/${tournament.key}/match/${match_key}'),
          child: Text(
            '${display}',
            textScaler: TextScaler.linear(1.25),
            style: TextStyle(
                color: theme.primaryColor,
                decoration: TextDecoration.underline,
                decorationColor: theme.primaryColor),
          ),
        ));
  }
}
