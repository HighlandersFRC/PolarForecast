import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/polar_forecast_app_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(
        backButton: false,
      ),
      body: Stack(
        children: [
          Center(
              child: Column(children: [
            Text(
              'Welcome to Polar Forecast. Begin by Searching a Tournament',
              style: TextStyle(color: Colors.blue, fontSize: 24),
            ),
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse('https://www.thebluealliance.com'));
              },
              child: Text(
                'Powered by The Blue Alliance',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ])),
        ],
      ),
    );
  }
}
