import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api_service.dart';
import '../models/tournament.dart';

class DeathLink extends StatelessWidget {
  final int number;
  final Tournament tournament;
  final String value;
  DeathLink(this.number, this.tournament, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(),
        child: TextButton(
          onPressed: () => Navigator.pushNamed(
              context, '/event/${tournament.key}/deaths/frc$number'),
          onLongPress: () => _openInNewTab(context),
          child: Text(
            '${value}',
            textScaler: TextScaler.linear(1.25),
            style: TextStyle(
              fontFamily: 'Font',
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

  void _openInNewTab(BuildContext context) {
    final api = Provider.of<ApiService>(context, listen: false);
    launchUrl(
        Uri.parse(api.APPURL + '/event/${tournament.key}/deaths/frc$number'),
        mode: LaunchMode.externalApplication);
  }
}
