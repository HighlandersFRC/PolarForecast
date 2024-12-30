import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BracketPage extends StatefulWidget {
  @override
  _BracketPageState createState() => _BracketPageState();
}

class _BracketPageState extends State<BracketPage> {
  final List<String> _qualifications = ['Quals', 'Elims'];
  final List<String> _redAllianceTeams = List.generate(3, (index) => '');
  final List<String> _blueAllianceTeams = List.generate(3, (index) => '');
  String _matchNumber = '1';
  String _selectedQualification = 'Quals';
  String _winningAlliance = 'None';
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _matchNumber = prefs.getString('matchNumber') ?? '1';
      _selectedQualification = prefs.getString('qualification') ?? 'Quals';
      _redAllianceTeams[0] = prefs.getString('redTeam1') ?? '';
      _redAllianceTeams[1] = prefs.getString('redTeam2') ?? '';
      _redAllianceTeams[2] = prefs.getString('redTeam3') ?? '';
      _blueAllianceTeams[0] = prefs.getString('blueTeam1') ?? '';
      _blueAllianceTeams[1] = prefs.getString('blueTeam2') ?? '';
      _blueAllianceTeams[2] = prefs.getString('blueTeam3') ?? '';
      _winningAlliance = prefs.getString('winningAlliance') ?? 'None';
      _score = prefs.getInt('score') ?? 0;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('matchNumber', _matchNumber);
    await prefs.setString('qualification', _selectedQualification);
    await prefs.setString('redTeam1', _redAllianceTeams[0]);
    await prefs.setString('redTeam2', _redAllianceTeams[1]);
    await prefs.setString('redTeam3', _redAllianceTeams[2]);
    await prefs.setString('blueTeam1', _blueAllianceTeams[0]);
    await prefs.setString('blueTeam2', _blueAllianceTeams[1]);
    await prefs.setString('blueTeam3', _blueAllianceTeams[2]);
    await prefs.setString('winningAlliance', _winningAlliance);
    await prefs.setInt('score', _score);
  }

  void _setWinningAlliance(String alliance) {
    setState(() {
      _winningAlliance = alliance;
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Match Number',
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                value: _matchNumber,
                onChanged: (String? newValue) {
                  setState(() {
                    _matchNumber = newValue!;
                  });
                  _saveData();
                },
                items: List.generate(150, (index) => (index + 1).toString()).map((match) {
                  return DropdownMenuItem(value: match, child: Text(match));
                }).toList(),
                style: TextStyle(color: Colors.white),
                dropdownColor: Colors.grey[850],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Qualification/Elimination',
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                value: _selectedQualification,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedQualification = newValue!;
                  });
                  _saveData();
                },
                items: _qualifications.map((qual) {
                  return DropdownMenuItem(value: qual, child: Text(qual));
                }).toList(),
                style: TextStyle(color: Colors.white),
                dropdownColor: Colors.grey[850],
              ),
              SizedBox(height: 16),
              _buildTeamInputs(
                label: 'Red Alliance Teams',
                teams: _redAllianceTeams,
                onChanged: (index, value) {
                  setState(() {
                    _redAllianceTeams[index] = value;
                  });
                  _saveData();
                },
                color: Colors.red,
              ),
              SizedBox(height: 16),
              _buildTeamInputs(
                label: 'Blue Alliance Teams',
                teams: _blueAllianceTeams,
                onChanged: (index, value) {
                  setState(() {
                    _blueAllianceTeams[index] = value;
                  });
                  _saveData();
                },
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.check),
                    label: Text('Red'),
                    onPressed: () => _setWinningAlliance('Red'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      elevation: 10,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.check),
                    label: Text('Blue'),
                    onPressed: () => _setWinningAlliance('Blue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      elevation: 10,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.close),
                    label: Text('None'),
                    onPressed: () => _setWinningAlliance('None'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      elevation: 10,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text('Score: $_score', style: TextStyle(fontSize: 24, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInputs({
    required String label,
    required List<String> teams,
    required void Function(int, String) onChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 16.0)),
        SizedBox(height: 8),
        ...List.generate(teams.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: TextFormField(
              initialValue: teams[index],
              onChanged: (value) => onChanged(index, value),
              decoration: InputDecoration(
                filled: true,
                fillColor: color.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                hintText: 'Team ${index + 1}',
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
          );
        }),
      ],
    );
  }
}
