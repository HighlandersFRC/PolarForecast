import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'team_detail_page.dart';

class EventDetailPage extends StatefulWidget {
  final String year;
  final String eventCode;

  EventDetailPage({required this.year, required this.eventCode});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Future<List<Map<String, dynamic>>> _eventDetails;

  @override
  void initState() {
    super.initState();
    _eventDetails = _fetchEventDetails();
  }

  Future<List<Map<String, dynamic>>> _fetchEventDetails() async {
    final url =
        'https://highlanderscouting.azurewebsites.net/${widget.year}/${widget.eventCode}/stats';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data'])
          .where((team) =>
              (team['OPR'] as double? ?? 0.0) > 0 ||
              (team['auto_points'] as double? ?? 0.0) > 0 ||
              (team['teleop_points'] as double? ?? 0.0) > 0 ||
              (team['endgame_points'] as double? ?? 0.0) > 0)
          .toList();
    } else {
      throw Exception('Failed to load event details');
    }
  }

  Color _getHeatMapColor(double value, double maxValue) {
    final fraction = maxValue > 0 ? value / maxValue : 0.0;
    return Color.lerp(Colors.red, Colors.green, fraction)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _eventDetails = _fetchEventDetails();
              });
            },
          ),
        ],
      ),
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
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _eventDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: Colors.blue));
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('No details available',
                        style: TextStyle(color: Colors.white)));
              } else {
                final List<Map<String, dynamic>> data = snapshot.data!;
                final double maxOPR = data
                    .map((e) => (e['OPR'] as double?) ?? 0.0)
                    .reduce((a, b) => a > b ? a : b);

                return SfDataGrid(
                  columnWidthMode: ColumnWidthMode.fill,
                  source: TeamDataSource(
                      data, maxOPR, context, widget.year, widget.eventCode),
                  columns: [
                    GridColumn(
                      columnName: 'team_number',
                      label: _buildColumnHeader('Team'),
                      allowSorting: true,
                    ),
                    GridColumn(
                      columnName: 'OPR',
                      label: _buildColumnHeader('OPR'),
                      allowSorting: true,
                    ),
                    GridColumn(
                      columnName: 'rank',
                      label: _buildColumnHeader('Rank'),
                      allowSorting: true,
                    ),
                    GridColumn(
                      columnName: 'simulated_rank',
                      label: _buildColumnHeader('Sim Rank'),
                      allowSorting: true,
                    ),
                    GridColumn(
                      columnName: 'auto_notes',
                      label: _buildColumnHeader('Auto Notes'),
                      allowSorting: true,
                    ),
                    GridColumn(
                      columnName: 'teleop_notes',
                      label: _buildColumnHeader('Teleop Notes'),
                      allowSorting: true,
                    ),
                    GridColumn(
                      columnName: 'notes',
                      label: _buildColumnHeader('Notes'),
                      allowSorting: true,
                    ),
                    GridColumn(
                      columnName: 'auto_points',
                      label: _buildColumnHeader('Auto Points'),
                      allowSorting: true,
                    ),
                    GridColumn(
                      columnName: 'teleop_points',
                      label: _buildColumnHeader('Teleop Points'),
                      allowSorting: true,
                    ),
                    GridColumn(
                      columnName: 'endgame_points',
                      label: _buildColumnHeader('Endgame Points'),
                      allowSorting: true,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.center,
      color: Colors.grey[800],
      child: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class TeamDataSource extends DataGridSource {
  TeamDataSource(
      this.data, this.maxOPR, this.context, this.year, this.eventCode) {
    _dataGridRows = data.map<DataGridRow>((map) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(
              columnName: 'team_number',
              value: map['team_number']?.toString() ?? ''),
          DataGridCell<double>(
              columnName: 'OPR',
              value: _roundToTenths(map['OPR'] as double? ?? 0.0)),
          DataGridCell<int>(
              columnName: 'rank', value: (map['rank'] as int?) ?? 0),
          DataGridCell<int>(
              columnName: 'simulated_rank',
              value: (map['simulated_rank'] as int?) ?? 0),
          DataGridCell<String>(
              columnName: 'auto_notes',
              value: _roundToString(map['auto_notes']?.toString() ?? '')),
          DataGridCell<String>(
              columnName: 'teleop_notes',
              value: _roundToString(map['teleop_notes']?.toString() ?? '')),
          DataGridCell<String>(
              columnName: 'notes',
              value: _roundToString(map['notes']?.toString() ?? '')),
          DataGridCell<double>(
              columnName: 'auto_points',
              value: _roundToTenths(map['auto_points'] as double? ?? 0.0)),
          DataGridCell<double>(
              columnName: 'teleop_points',
              value: _roundToTenths(map['teleop_points'] as double? ?? 0.0)),
          DataGridCell<double>(
              columnName: 'endgame_points',
              value: _roundToTenths(map['endgame_points'] as double? ?? 0.0)),
        ],
      );
    }).toList();
  }

  final List<Map<String, dynamic>> data;
  final double maxOPR;
  final BuildContext context;
  final String year;
  final String eventCode;
  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        final color =
            e.columnName.contains('points') || e.columnName.contains('OPR')
                ? _getHeatMapColor(e.value as double)
                : Colors.black;
        return GestureDetector(
          onTap: e.columnName == 'team_number'
              ? () {
                  final teamNumber = e.value.toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamDetailPage(
                        year: year,
                        eventCode: eventCode,
                        teamNumber: teamNumber,
                      ),
                    ),
                  );
                }
              : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.center,
            color: color,
            child: Text(_formatValue(e.value),
                style: TextStyle(color: Colors.white)),
          ),
        );
      }).toList(),
    );
  }

  Color _getHeatMapColor(double value) {
    final fraction = maxOPR > 0 ? value / maxOPR : 0.0;
    return Color.lerp(Colors.red, Colors.green, fraction)!;
  }

  double _roundToTenths(double value) {
    return (value * 10).roundToDouble() / 10;
  }

  String _roundToString(String value) {
    if (double.tryParse(value) != null) {
      return _roundToTenths(double.parse(value)).toStringAsFixed(1);
    }
    return value;
  }

  String _formatValue(dynamic value) {
    if (value is double) {
      return _roundToTenths(value).toStringAsFixed(1);
    }
    return value.toString();
  }
}
