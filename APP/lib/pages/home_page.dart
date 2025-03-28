import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api_service.dart';
import '../models/global_rank.dart';
import '../widgets/polar_forecast_app_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolarForecastAppBar(
        backButton: false,
      ),
      body: Stack(
        children: [
          Center(
              child: Column(children: [
            Text(
              'Global Rankings',
              style: TextStyle(color: Colors.blue, fontSize: 24),
            ),
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse('https://www.thebluealliance.com'));
              },
              child: Text(
                'Powered by The Blue Alliance',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            FutureBuilder(
              future: Provider.of<ApiService>(context, listen: false)
                  .fetch_global_rankings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final rankings = snapshot.data as List<GlobalRank>;
                  final maxOpr = rankings
                      .map((rank) => rank.data.OPR)
                      .reduce((a, b) => a > b ? a : b);
                  final minOpr = rankings
                      .map((rank) => rank.data.OPR)
                      .reduce((a, b) => a < b ? a : b);
                  return Expanded(
                    child: SfDataGrid(
                      source: GlobalRankDataSource(rankings, maxOpr, minOpr),
                      allowSorting: true,
                      columnWidthMode: ColumnWidthMode.fill,
                      columns: [
                        GridColumn(
                          columnName: 'team',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('Team'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'event',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('Event'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'OPR',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('OPR'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'OPRRank',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('OPR Rank'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'auto',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('Auto Points'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'teleop',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('Teleop Points'),
                          ),
                        ),
                        GridColumn(
                          columnName: 'endgame',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('Endgame Points'),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Text('No data available');
                }
              },
            ),
          ])),
        ],
      ),
    );
  }
}

class GlobalRankDataSource extends DataGridSource {
  GlobalRankDataSource(this.globalRanks, this.maxOpr, this.minOpr) {
    dataGridRows = globalRanks
        .map<DataGridRow>((rank) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'team', value: rank.data.team_number),
              DataGridCell<String>(columnName: 'event', value: rank.event),
              DataGridCell<double>(columnName: 'OPR', value: rank.data.OPR),
              DataGridCell<int>(
                  columnName: 'OPRRank', value: rank.data.OPRRank),
              DataGridCell<double>(
                  columnName: 'auto', value: rank.data.auto_points),
              DataGridCell<double>(
                  columnName: 'teleop', value: rank.data.teleop_points),
              DataGridCell<double>(
                  columnName: 'endgame', value: rank.data.endgame_points),
            ]))
        .toList();
  }

  Color? getHeatmapColor(String columnName, double value) {
    double maxValue, minValue;

    switch (columnName) {
      case 'OPR':
        maxValue = maxOpr;
        minValue = minOpr;
        break;
      case 'auto':
        maxValue = globalRanks
            .map((rank) => rank.data.auto_points)
            .reduce((a, b) => a > b ? a : b);
        minValue = globalRanks
            .map((rank) => rank.data.auto_points)
            .reduce((a, b) => a < b ? a : b);
        break;
      case 'teleop':
        maxValue = globalRanks
            .map((rank) => rank.data.teleop_points)
            .reduce((a, b) => a > b ? a : b);
        minValue = globalRanks
            .map((rank) => rank.data.teleop_points)
            .reduce((a, b) => a < b ? a : b);
        break;
      case 'endgame':
        maxValue = globalRanks
            .map((rank) => rank.data.endgame_points)
            .reduce((a, b) => a > b ? a : b);
        minValue = globalRanks
            .map((rank) => rank.data.endgame_points)
            .reduce((a, b) => a < b ? a : b);
        break;
      default:
        return null;
    }

    return Color.lerp(
        Colors.red, Colors.green, (value - minValue) / (maxValue - minValue));
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      ...row.getCells().map(
        (cell) {
          final isDoubleColumn =
              ['OPR', 'auto', 'teleop', 'endgame'].contains(cell.columnName);
          final color = isDoubleColumn
              ? getHeatmapColor(cell.columnName, cell.value as double)
              : (dataGridRows.indexOf(row) % 2 == 0
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.transparent);

          return Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.center,
            color: color,
            child: Text(cell.value.runtimeType == double
                ? (cell.value as double).toStringAsFixed(1)
                : cell.value.toString()),
          );
        },
      )
    ]);
  }

  List<GlobalRank> globalRanks = [];
  List<DataGridRow> dataGridRows = [];
  final double maxOpr;
  final double minOpr;

  @override
  List<DataGridRow> get rows => dataGridRows;
}
