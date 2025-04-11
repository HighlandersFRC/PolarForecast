import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api_service.dart';
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
          onLongPress: () => _openInNewTab(context),
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

  void _openInNewTab(BuildContext context) {
    final api = Provider.of<ApiService>(context, listen: false);
    launchUrl(
        Uri.parse(api.APPURL + '/event/${tournament.key}/match/${match_key}'),
        mode: LaunchMode.externalApplication);
  }
}
