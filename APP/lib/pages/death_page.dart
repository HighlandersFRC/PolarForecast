import 'package:flutter/material.dart';
import '../widgets/deaths_form.dart';
import '../widgets/polar_forecast_app_bar.dart';
import '../models/tournament.dart';

class DeathPage extends StatefulWidget {
  final Tournament tournament;
  final int number;

  const DeathPage(this.number, this.tournament);

  @override
  _DeathPageState createState() => _DeathPageState();
}

class _DeathPageState extends State<DeathPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          PolarForecastSliverBar(
            context: context,
            extraText:
                '- Team ${widget.number} Deaths - ${widget.tournament.key}',
          ),
        ];
      },
      body: DeathsForm(widget.tournament, widget.number, false),
    ));
  }
}
