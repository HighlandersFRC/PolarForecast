import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/models/scouting_report.dart';
import 'package:scouting_app/widgets/polar_forecast_app_bar.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart'; // Needed for SfDataGridTheme

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

  // Helper method to keep column definitions clean
  Widget _buildHeaderCell(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(
        extraText: 'Scouting Report for ${widget.event}',
      ),
      body: FutureBuilder<ScoutingReport>(
        future: futureReport,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading report',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.report.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined,
                      color: Colors.grey[400], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final reportList = snapshot.data!.report;
          dataSource = ScoutingReportDataSource(reportList);

          // Wrap the grid in a theme to make it look like a cohesive table
          return SfDataGridTheme(
            data: SfDataGridThemeData(
              headerColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              gridLineColor: Colors.grey.withOpacity(0.3),
              gridLineStrokeWidth: 1.0,
            ),
            child: SfDataGrid(
              source: dataSource,
              allowSorting: true,
              columnWidthMode:
                  ColumnWidthMode.fill, // Makes columns stretch to fit screen
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columns: [
                GridColumn(
                  columnName: 'username',
                  allowSorting: false,
                  label: _buildHeaderCell('Username'),
                ),
                GridColumn(
                  columnName: 'first_name',
                  allowSorting: false,
                  label: _buildHeaderCell('First Name'),
                ),
                GridColumn(
                  columnName: 'trustRatings',
                  label: _buildHeaderCell('Trust Ratings'),
                ),
                GridColumn(
                  columnName: 'entries',
                  label: _buildHeaderCell('Entries'),
                ),
                GridColumn(
                  columnName: 'contribution',
                  label: _buildHeaderCell('Contribution'),
                ),
              ],
            ),
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
    if (entries.isEmpty) return;

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
    // Safety check to prevent division by zero if all values are exactly the same
    if (maxValue == minValue) return Colors.yellow[700]!;

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

  // Helper for text readability against heatmap backgrounds
  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final trust = row.getCells()[2].value as double;
    final entries = row.getCells()[3].value as double;
    final contribution = row.getCells()[4].value as double;

    // Slightly softened the hardcoded colors to look better in a grid
    final Color usernameColor = const Color(0xFF1E1E1E);
    final Color firstNameColor = const Color(0xFF1565C0);

    final trustColor = getCellColor(trust, minTrust, maxTrust, false);
    final entriesColor = getCellColor(entries, minEntries, maxEntries, false);
    final contributionColor =
        getCellColor(contribution, minContribution, maxContribution, false);

    return DataGridRowAdapter(cells: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.centerLeft, // Left aligned looks better for names
        color: usernameColor,
        child: Text(row.getCells()[0].value.toString(),
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Font', fontSize: 13)),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.centerLeft, // Left aligned looks better for names
        color: firstNameColor,
        child: Text(row.getCells()[1].value.toString(),
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Font', fontSize: 13)),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: trustColor,
        child: Text(
          trust.toStringAsFixed(2),
          style: TextStyle(
              fontFamily: 'Font',
              fontWeight: FontWeight.bold,
              color: _getTextColorForBackground(trustColor)),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: entriesColor,
        child: Text(entries.toStringAsFixed(1),
            style: TextStyle(
                fontFamily: 'Font',
                fontWeight: FontWeight.bold,
                color: _getTextColorForBackground(entriesColor))),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        color: contributionColor,
        child: Text(contribution.toStringAsFixed(2),
            style: TextStyle(
                fontFamily: 'Font',
                fontWeight: FontWeight.bold,
                color: _getTextColorForBackground(contributionColor))),
      ),
    ]);
  }
}
