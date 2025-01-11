import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';

import '../models/tournament.dart';

class NeedGroup extends StatelessWidget {
  final Tournament tournament;
  final void Function() onClick;
  const NeedGroup({super.key, required this.tournament, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(children: [
                const Text('You must be part of a group to use this feature'),
                ListBody(
                  children: [],
                ),
                ElevatedButton(
                  onPressed: onClick,
                  child: const Text('Create a New Group'),
                )
              ]),
            )));
  }
}
