import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/widgets/pit_scouting_form.dart';
import '../api_service.dart';
import '../widgets/polar_forecast_app_bar.dart';
import '../models/tournament.dart';
import 'not_found_page.dart';

class PitScoutingPage extends StatefulWidget {
  final Tournament tournament;
  final int number;

  const PitScoutingPage(this.number, this.tournament);

  static Widget fromKeys(
      BuildContext context, String eventKey, String teamKey) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final tournaments = apiService.fetchTournaments();
    return FutureBuilder(
        future: tournaments,
        builder: (context, tournaments) {
          Tournament? tournament = null;
          try {
            for (final _tournament in tournaments.requireData) {
              if (_tournament.key == eventKey) {
                tournament = _tournament;
                break;
              }
            }
            if (tournament == null) {
              return NotFoundPage();
            }
            return PitScoutingPage(
              int.parse(teamKey.substring(3)),
              tournament,
            );
          } catch (error) {
            return NotFoundPage();
          }
        });
  }

  @override
  _PitScoutingPageState createState() => _PitScoutingPageState();
}

class _PitScoutingPageState extends State<PitScoutingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          PolarForecastSliverBar(
            extraText:
                '- Team ${widget.number} Pit Scouting - ${widget.tournament.key}',
          ),
        ];
      },
      body: PitScoutingForm(widget.tournament, widget.number, false),
    ));
  }
}
