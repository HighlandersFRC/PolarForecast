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
  late double maxContribution;
  late double maxTrust;

  ScoutingReportDataSource(List<ScoutingReportEntry> entries) {
    maxEntries = entries.map((e) => e.entries).fold(0, (a, b) => a > b ? a : b);
    maxContribution =
        entries.map((e) => e.contribution).fold(0, (a, b) => a > b ? a : b);
    maxTrust =
        entries.map((e) => e.trustRatings).fold(0, (a, b) => a > b ? a : b);

    _rows = entries.map<DataGridRow>((entry) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'username', value: entry.scout.username ?? ''),
        DataGridCell<String>(
            columnName: 'first_name', value: entry.scout.first_name ?? ''),
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

  Color getCellColor(double value, double max) {
    final t = (max == 0) ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Color.lerp(Colors.white, Colors.green, t)!;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final trust = row.getCells()[2].value as double;
    final entries = row.getCells()[3].value as double;
    final contribution = row.getCells()[4].value as double;

    final trustColor = getCellColor(trust, maxTrust);
    final entriesColor = getCellColor(entries, maxEntries);
    final contributionColor = getCellColor(contribution, maxContribution);

    final trustSame = maxTrust == trust;
    final entriesSame = maxEntries == entries;
    final contributionSame = maxContribution == contribution;

    return DataGridRowAdapter(cells: [
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Text(row.getCells()[0].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Text(row.getCells()[1].value.toString()),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: trustColor,
        child: Text(
          trust.toStringAsFixed(2),
          style: TextStyle(
            color:
                maxTrust == 0 || _allEqualTrust() ? Colors.black : Colors.white,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: entriesColor,
        child: Text(
          entries.toStringAsFixed(1),
          style: TextStyle(
            color: maxEntries == 0 || _allEqualEntries()
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: contributionColor,
        child: Text(
          contribution.toStringAsFixed(2),
          style: TextStyle(
            color: maxContribution == 0 || _allEqualContribution()
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    ]);
  }

  bool _allEqualTrust() {
    final values = _rows
        .map((r) => r
            .getCells()
            .firstWhere((c) => c.columnName == 'trustRatings')
            .value)
        .toSet();
    return values.length == 1;
  }

  bool _allEqualEntries() {
    final values = _rows
        .map((r) =>
            r.getCells().firstWhere((c) => c.columnName == 'entries').value)
        .toSet();
    return values.length == 1;
  }

  bool _allEqualContribution() {
    final values = _rows
        .map((r) => r
            .getCells()
            .firstWhere((c) => c.columnName == 'contribution')
            .value)
        .toSet();
    return values.length == 1;
  }

  @override
  Future<void> handleSort() async {
    _rows.sort((a, b) {
      for (final sortColumn in sortedColumns) {
        final sortName = sortColumn.name;
        final ascending =
            sortColumn.sortDirection == DataGridSortDirection.ascending;
        final aValue = a
            .getCells()
            .firstWhere((cell) => cell.columnName == sortName)
            .value;
        final bValue = b
            .getCells()
            .firstWhere((cell) => cell.columnName == sortName)
            .value;

        int compare;
        if (aValue is Comparable && bValue is Comparable) {
          compare = aValue.compareTo(bValue);
          if (compare != 0) {
            return ascending ? compare : -compare;
          }
        }
      }
      return 0;
    });
    notifyListeners();
  }
}
