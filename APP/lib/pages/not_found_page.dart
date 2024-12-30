import 'package:flutter/material.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(),
      body: Center(child: Text('404 Page not found')),
    );
  }
}
