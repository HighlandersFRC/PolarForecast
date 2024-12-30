import 'package:flutter/material.dart';
import '../widgets/polar_forecast_app_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(),
      body: Stack(
        children: [
          Center(
            child: Text(
              'Global Stats Go Here',
              style: TextStyle(color: Colors.blue, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}
