import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'event_detail_page.dart'; // Import the EventDetailPage class

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<dynamic> _events = [];
  List<dynamic> _filteredEvents = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final response = await http.get(Uri.parse('https://highlanderscouting.azurewebsites.net/search_keys'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _events = data['data'];
        _filteredEvents = _events;
      });
    } else {
      throw Exception('Failed to load events');
    }
  }

  void _filterEvents(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredEvents = _events.where((event) {
        final display = event['display'].toLowerCase();
        return display.contains(_searchQuery);
      }).toList();
    });
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
                _buildSectionTitle('Search Events'),
                _buildSearchBar(),
                SizedBox(height: 16.0),
                _buildEventList(),
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

  Widget _buildSearchBar() {
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
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(16.0),
        ),
        style: TextStyle(color: Colors.white),
        onChanged: _filterEvents,
      ),
    );
  }

  Widget _buildEventList() {
    return _filteredEvents.isEmpty
        ? Center(child: Text('No events found', style: TextStyle(color: Colors.white)))
        : ListView.builder(
            itemCount: _filteredEvents.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final event = _filteredEvents[index];
              final year = '2024'; // Assuming the year is fixed; adjust as needed
              final eventCode = event['key'].toString().replaceAll('2024', '').toLowerCase(); // Adjust extraction as needed
              return Container(
                margin: EdgeInsets.only(bottom: 16.0),
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
                child: ListTile(
                  title: Text(
                    event['display'],
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${event['start']} - ${event['end']}',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(
                          year: year,
                          eventCode: eventCode,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}
