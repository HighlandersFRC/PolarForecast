import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api_service.dart';
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
          onLongPress: () => _openInNewTab(context),
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

  void _openInNewTab(BuildContext context) {
    final api = Provider.of<ApiService>(context, listen: false);
    launchUrl(
        Uri.parse(api.APPURL + '/event/${tournament.key}/team/frc$number'),
        mode: LaunchMode.externalApplication);
  }
}
