import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

class ScoutingPage extends StatefulWidget {
  @override
  _ScoutingPageState createState() => _ScoutingPageState();
}

class _ScoutingPageState extends State<ScoutingPage> {
  final TextEditingController _eventCodeController = TextEditingController();
  final TextEditingController _teamNumberController = TextEditingController();
  final TextEditingController _matchNumberController = TextEditingController();
  final TextEditingController _scoutNameController = TextEditingController();

  String? _selectedDriverStation;
  bool _isDied = false;
  int _autoAmp = 0;
  int _autoSpeaker = 0;
  int _teleopPass = 0;
  int _teleopAmp = 0;
  int _teleopSpeaker = 0;
  int _teleopAmplifiedSpeaker = 0;
  String _comments = '';
  List<int> _clickedNotes = [];

  @override
  void initState() {
    super.initState();
    _matchNumberController.addListener(_validateMatchNumber);
  }

  void _validateMatchNumber() {
    if (_matchNumberController.text.isNotEmpty) {
      int? currentMatchNumber = int.tryParse(_matchNumberController.text);
      if (currentMatchNumber == null) {
        _matchNumberController.text = '';
      }
    }
  }

  void _reset() {
    setState(() {
      _eventCodeController.clear();
      _teamNumberController.clear();
      _matchNumberController.clear();
      _scoutNameController.clear();
      _isDied = false;
      _autoAmp = 0;
      _autoSpeaker = 0;
      _teleopPass = 0;
      _teleopAmp = 0;
      _teleopSpeaker = 0;
      _teleopAmplifiedSpeaker = 0;
      _comments = '';
      _clickedNotes.clear();  // Clear notes after reset
    });
  }

  void _handleImageClick(int index) {
    if (!_clickedNotes.contains(index)) {
      setState(() {
        _clickedNotes.add(index);
      });
    }
  }

  String _generateQRCodeData() {
    try {
      return jsonEncode({
        'event_code': _eventCodeController.text,
        'team_number': int.tryParse(_teamNumberController.text) ?? 0,
        'match_number': int.tryParse(_matchNumberController.text) ?? 0,
        'scout_info': {
          'name': _scoutNameController.text,
        },
        'data': {
          'miscellaneous': {
            'died': _isDied,
            'comments': _comments,
          },
        },
      });
    } catch (e) {
      print('Error generating QR code data: $e');
      return ''; // Return an empty string in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: Duration(seconds: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Event Code'),
                _buildTextField(
                  controller: _eventCodeController,
                  hintText: 'Enter Event Code',
                ),
                SizedBox(height: 16.0),
                _buildSectionTitle('Team Number'),
                _buildTextField(
                  controller: _teamNumberController,
                  hintText: 'Enter Team Number',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                _buildSectionTitle('Driver Station'),
                _buildDropdownField(),
                SizedBox(height: 16.0),
                _buildSectionTitle('Match Number'),
                _buildTextField(
                  controller: _matchNumberController,
                  hintText: 'Enter Match Number',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                _buildSectionTitle('Scout Name'),
                _buildTextField(
                  controller: _scoutNameController,
                  hintText: 'Enter Scout Name',
                ),
                SizedBox(height: 16.0),
                _buildSectionTitle('Field Image'),
                Container(
                  height: 300,  // Adjusted height to fit UI
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FieldImage(
                    pieces: _clickedNotes.map((index) => Piece('note', 0, 0, index)).toList(),  // Example placeholder data
                    onPieceClick: _handleImageClick,
                  ),
                ),
                SizedBox(height: 16.0),
                _buildSectionTitle('Auto Fields'),
                _buildCounter('Auto Amp', _autoAmp, (value) => setState(() => _autoAmp = value)),
                SizedBox(height: 16.0),
                _buildCounter('Auto Speaker', _autoSpeaker, (value) => setState(() => _autoSpeaker = value)),
                SizedBox(height: 16.0),
                _buildSectionTitle('Teleop Fields'),
                _buildCounter('Pass', _teleopPass, (value) => setState(() => _teleopPass = value)),
                SizedBox(height: 16.0),
                _buildCounter('Teleop Amp', _teleopAmp, (value) => setState(() => _teleopAmp = value)),
                SizedBox(height: 16.0),
                _buildCounter('Teleop Speaker', _teleopSpeaker, (value) => setState(() => _teleopSpeaker = value)),
                SizedBox(height: 16.0),
                _buildCounter('Teleop Amplified Speaker', _teleopAmplifiedSpeaker, (value) => setState(() => _teleopAmplifiedSpeaker = value)),
                SizedBox(height: 16.0),
                _buildSectionTitle('Miscellaneous'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SwitchListTile(
                    title: Text('Died?', style: TextStyle(color: Colors.white)),
                    value: _isDied,
                    onChanged: (bool value) {
                      setState(() {
                        _isDied = value;
                      });
                    },
                    tileColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Comments/Notes',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                    style: TextStyle(color: Colors.white),
                    maxLines: 3,
                    onChanged: (text) {
                      setState(() {
                        _comments = text;
                      });
                    },
                  ),
                ),
                SizedBox(height: 32.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _reset,
                    child: Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      elevation: 10,
                    ),
                  ),
                ),
                SizedBox(height: 32.0),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _generateQRCodeData(),
                      size: 200.0,  // Adjusted size for QR code
                      backgroundColor: Colors.white,
                      gapless: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(16.0),
        ),
        style: TextStyle(color: Colors.white),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _selectedDriverStation,
        hint: Text('Select Driver Station', style: TextStyle(color: Colors.white54)),
        dropdownColor: Colors.black,
        style: TextStyle(color: Colors.white),
        onChanged: (String? newValue) {
          setState(() {
            _selectedDriverStation = newValue;
          });
        },
        items: ['R1', 'R2', 'R3', 'B1', 'B2', 'B3'].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                color: _getDriverStationColor(value),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getDriverStationColor(String value) {
    return value.startsWith('R') ? Colors.red : Colors.blue;
  }

  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                label,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove, color: Colors.white),
            onPressed: () {
              setState(() {
                if (value > 0) onChanged(value - 1);
              });
            },
          ),
          Text(
            '$value',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              setState(() {
                onChanged(value + 1);
              });
            },
          ),
        ],
      ),
    );
  }
}

class FieldImage extends StatelessWidget {
  final List<Piece> pieces;
  final void Function(int) onPieceClick;

  FieldImage({required this.pieces, required this.onPieceClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Image.asset('assets/AutosGameField.png'),
      ),
    );
  }
}

class Piece {
  final String type;
  final double x;
  final double y;
  final int index;

  Piece(this.type, this.x, this.y, this.index);
}
