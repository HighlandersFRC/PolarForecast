import 'package:flutter/material.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';

class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(),
      body: Center(
          child: Text(
              'Oh No! Something Broke! The robot or at least this page does not exist! 404 Not Found')),
    );
  }
}
