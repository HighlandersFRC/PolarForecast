import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/models/scouting_report.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ScoutingReportPage extends StatefulWidget {
  final String group;
  final String event;

  const ScoutingReportPage({
    super.key,
    required this.group,
    required this.event,
  });

  @override
  State<ScoutingReportPage> createState() => _ScoutingReportPageState();
}

class _ScoutingReportPageState extends State<ScoutingReportPage> {
  late Future<ScoutingReport> futureReport;
  late ScoutingReportDataSource dataSource;

  @override
  void initState() {
    super.initState();
    final service = Provider.of<ApiService>(context, listen: false);
    futureReport = service.fetchReport(
      group: widget.group,
      event: widget.event,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scouting Report')),
      body: FutureBuilder<ScoutingReport>(
        future: futureReport,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.report.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final reportList = snapshot.data!.report;
          dataSource = ScoutingReportDataSource(reportList);

          return SfDataGrid(
            source: dataSource,
            allowSorting: true,
            columns: [
              GridColumn(
                columnName: 'username',
                allowSorting: false,
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text('Username'),
                ),
              ),
              GridColumn(
                columnName: 'first_name',
                allowSorting: false,
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text('First Name'),
                ),
              ),
              GridColumn(
                columnName: 'trustRatings',
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text('Trust Ratings'),
                ),
              ),
              GridColumn(
                columnName: 'entries',
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text('Entries'),
                ),
              ),
              GridColumn(
                columnName: 'contribution',
                label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text('Contribution'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ScoutingReportDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];
  late double maxEntries;
  late double minEntries;
  late double maxContribution;
  late double minContribution;
  late double maxTrust;
  late double minTrust;

  ScoutingReportDataSource(List<ScoutingReportEntry> entries) {
    maxEntries = entries.map((e) => e.entries).reduce((a, b) => a > b ? a : b);
    minEntries = entries.map((e) => e.entries).reduce((a, b) => a < b ? a : b);

    maxContribution =
        entries.map((e) => e.contribution).reduce((a, b) => a > b ? a : b);
    minContribution =
        entries.map((e) => e.contribution).reduce((a, b) => a < b ? a : b);

    maxTrust =
        entries.map((e) => e.trustRatings).reduce((a, b) => a > b ? a : b);
    minTrust =
        entries.map((e) => e.trustRatings).reduce((a, b) => a < b ? a : b);

    _rows = entries.map<DataGridRow>((entry) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'username',
            value: entry.scout.username ?? 'Scout from'),
        DataGridCell<String>(
            columnName: 'first_name',
            value: entry.scout.first_name ?? '${entry.scout.team_number}'),
        DataGridCell<double>(
            columnName: 'trustRatings', value: entry.trustRatings),
        DataGridCell<double>(columnName: 'entries', value: entry.entries),
        DataGridCell<double>(
            columnName: 'contribution', value: entry.contribution),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  Color getCellColor(num value, num minValue, num maxValue, bool flip) {
    double normalizedValue = (value - minValue) / (maxValue - minValue);
    normalizedValue = normalizedValue.clamp(0.0, 1.0);
    if (flip) normalizedValue = 1 - normalizedValue;
    if (normalizedValue > 0.5) {
      return Color.lerp(Colors.yellow[700], Colors.green.shade800,
              (normalizedValue - 0.5) * 2) ??
          Colors.green.shade700;
    } else {
      return Color.lerp(
              Colors.red.shade700, Colors.yellow[700], normalizedValue * 2) ??
          Colors.red.shade700;
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final trust = row.getCells()[2].value as double;
    final entries = row.getCells()[3].value as double;
    final contribution = row.getCells()[4].value as double;

    final Color usernameColor = Colors.black;
    final Color firstNameColor = const Color.fromARGB(255, 10, 93, 161);

    return DataGridRowAdapter(cells: [
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: usernameColor,
        child: Text(row.getCells()[0].value.toString(),
            style: const TextStyle(color: Colors.white, fontFamily: 'Font')),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: firstNameColor,
        child: Text(row.getCells()[1].value.toString(),
            style: const TextStyle(color: Colors.white, fontFamily: 'Font')),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: getCellColor(trust, minTrust, maxTrust, false),
        child: Text(
          trust.toStringAsFixed(2),
          style: TextStyle(fontFamily: 'Font'),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: getCellColor(entries, minEntries, maxEntries, false),
        child: Text(entries.toStringAsFixed(1),
            style: TextStyle(fontFamily: 'Font')),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color:
            getCellColor(contribution, minContribution, maxContribution, false),
        child: Text(contribution.toStringAsFixed(2),
            style: TextStyle(fontFamily: 'Font')),
      ),
    ]);
  }
}
