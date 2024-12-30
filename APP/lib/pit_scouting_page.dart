import 'package:flutter/material.dart';

class PitScoutingPage extends StatefulWidget {
  @override
  _PitScoutingPageState createState() => _PitScoutingPageState();
}

class _PitScoutingPageState extends State<PitScoutingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pit Scouting Page'),
      ),
      body: Center(
        child: Text('not started'),
      ),
    );
  }
}
