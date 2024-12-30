import 'package:flutter/material.dart';

import '../models/tournament.dart';
import '../pages/match_page.dart';

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
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MatchPage(match_key, tournament, display: display))),
          child: Text(
            '${display}',
            textScaleFactor: 1.25,
            style: TextStyle(
                color: theme.primaryColor,
                decoration: TextDecoration.underline,
                decorationColor: theme.primaryColor),
          ),
        ));
  }
}
