import 'package:flutter/material.dart';
import 'event_codes.dart';

class EventsVisited extends StatelessWidget {
  final String teamNumber;
  final List<String> events;

  const EventsVisited({
    Key? key,
    required this.teamNumber,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Team ${teamNumber} visited'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: events.map((code) {
            final name = eventNames[code] ?? code;
            return ListTile(
              leading: const Icon(Icons.event),
              title: Text(name),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/event/$code');
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
