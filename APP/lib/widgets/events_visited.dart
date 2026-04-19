import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_service.dart';
import '../models/tournament.dart';

class EventsVisited extends StatefulWidget {
  final String teamNumber;
  final List<String> events;

  const EventsVisited({
    Key? key,
    required this.teamNumber,
    required this.events,
  }) : super(key: key);

  @override
  State<EventsVisited> createState() => _EventsVisitedState();
}

class _EventsVisitedState extends State<EventsVisited> {
  late Future<_EventsVisitedData> eventsVisitedFuture;

  @override
  void initState() {
    super.initState();
    final api = Provider.of<ApiService>(context, listen: false);
    eventsVisitedFuture = _loadData(api);
  }

  Future<_EventsVisitedData> _loadData(ApiService api) async {
    final tournaments = await api.fetchTournaments();
    String nickname = '';
    try {
      nickname = await api.fetchTeamNicknames('frc${widget.teamNumber}');
    } catch (_) {
      nickname = '';
    }
    return _EventsVisitedData(tournaments, nickname);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: FutureBuilder<_EventsVisitedData>(
        future: eventsVisitedFuture,
        builder: (context, snapshot) {
          final nickname = snapshot.data?.nickname ?? '';
          final titleText = nickname.isNotEmpty
              ? 'Team ${widget.teamNumber} • $nickname visited'
              : 'Team ${widget.teamNumber} visited';
          return Text(titleText, style: TextStyle(fontFamily: 'Font'));
        },
      ),
      content: FutureBuilder<_EventsVisitedData>(
        future: eventsVisitedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}',
                style: TextStyle(fontFamily: 'Font'));
          } else {
            final tournaments = snapshot.data?.tournaments ?? [];
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.events.map((code) {
                  final tournament = tournaments.firstWhere(
                    (t) => t.key == code,
                    orElse: () => Tournament(
                      key: code,
                      display: 'Unknown',
                      page: '',
                      start: '',
                      end: '',
                    ),
                  );
                  return ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(tournament.display,
                        style: TextStyle(fontFamily: 'Font')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/event/$code');
                    },
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(fontFamily: 'Font')),
        ),
      ],
    );
  }
}

class _EventsVisitedData {
  final List<Tournament> tournaments;
  final String nickname;

  _EventsVisitedData(this.tournaments, this.nickname);
}
