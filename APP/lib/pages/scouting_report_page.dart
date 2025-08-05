import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/models/scouting_report.dart';

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
          if (snapshot.hasData) {
            final reportList = snapshot.data!.report;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('First Name')),
                  DataColumn(label: Text('Trust Ratings')),
                  DataColumn(label: Text('Entries')),
                  DataColumn(label: Text('Contribution')),
                ],
                rows: reportList.map((entry) {
                  final scout = entry.scout;
                  return DataRow(cells: [
                    DataCell(Text(scout.username ?? '')),
                    DataCell(Text(scout.first_name ?? '')),
                    DataCell(Text(entry.trustRatings.toStringAsFixed(2))),
                    DataCell(Text(entry.entries.toStringAsFixed(1))),
                    DataCell(Text(entry.contribution.toStringAsFixed(2))),
                  ]);
                }).toList(),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
