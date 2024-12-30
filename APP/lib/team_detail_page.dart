import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeamDetailPage extends StatefulWidget {
  final String year;
  final String eventCode;
  final String teamNumber;

  TeamDetailPage({
    required this.year,
    required this.eventCode,
    required this.teamNumber,
  });

  @override
  _TeamDetailPageState createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage>
    with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> _matchesFuture;
  late Future<List<String>> _imagesFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _fetchMatches();
    _imagesFuture = _fetchImages();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<List<dynamic>> _fetchMatches() async {
    final url =
        'https://highlanderscouting.azurewebsites.net/${widget.year}/${widget.eventCode}/frc${widget.teamNumber}/matches';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<dynamic>.from(data);
      } else if (data is Map) {
        return List<dynamic>.from(data['data'] ?? []);
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to load team matches');
    }
  }

  Future<List<String>> _fetchImages() async {
    final url =
        'https://highlanderscouting.azurewebsites.net/${widget.year}/${widget.eventCode}/frc${widget.teamNumber}/images';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<String>.from(data);
      } else if (data is Map) {
        return List<String>.from(data['data'] ?? []);
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to load team images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Team ${widget.teamNumber} Details'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Matches',
              icon: Icon(Icons.list),
            ),
            Tab(
              text: 'Images',
              icon: Icon(Icons.image),
            ),
          ],
        ),
      ),
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
          TabBarView(
            controller: _tabController,
            children: [
              _buildMatchesTab(),
              _buildImagesTab(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: FutureBuilder<List<dynamic>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No match data available',
                    style: TextStyle(color: Colors.white)));
          }

          final matches = snapshot.data!;
          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                      label: Text('Match #',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Red Score',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Blue Score',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Red RPS',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Blue RPS',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label:
                          Text('Team', style: TextStyle(color: Colors.white))),
                ],
                rows: matches.map((match) {
                  final redTeams = List<String>.from(match['red_teams'] ?? []);
                  final blueTeams =
                      List<String>.from(match['blue_teams'] ?? []);
                  final isRedTeam = redTeams.contains(widget.teamNumber);
                  final isBlueTeam = blueTeams.contains(widget.teamNumber);

                  String teamPresence;
                  if (isRedTeam) {
                    teamPresence = 'Red Team';
                  } else if (isBlueTeam) {
                    teamPresence = 'Blue Team';
                  } else {
                    teamPresence = 'N/A';
                  }

                  return DataRow(cells: [
                    DataCell(Text(match['match_number']?.toString() ?? 'N/A',
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(_toStringFixed(match['red_actual_score']),
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(_toStringFixed(match['blue_actual_score']),
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(_toStringFixed(match['red_total_rp']),
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(_toStringFixed(match['blue_total_rp']),
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(teamPresence,
                        style: TextStyle(color: Colors.white))),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagesTab() {
    return FutureBuilder<List<String>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.blue));
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text('No images available',
                  style: TextStyle(color: Colors.white)));
        }

        final images = snapshot.data!;
        return GridView.builder(
          padding: EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageUrl = images[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _toStringFixed(dynamic value) {
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    return value?.toString() ?? 'N/A';
  }
}
