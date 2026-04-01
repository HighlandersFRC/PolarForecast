import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scouting_app/models/team_stats_2026.dart';
import 'package:scouting_app/utils/download_stub.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:csv/csv.dart';

import '../utils.dart';

class BarChartWithWeights extends StatefulWidget {
  final List<TeamStats2026> data;
  final int number;
  final List<Field> startingFields;
  final String title;
  const BarChartWithWeights({
    Key? key,
    required this.data,
    required this.number,
    required this.startingFields,
    required this.title,
  }) : super(key: key);

  @override
  State<BarChartWithWeights> createState() => _BarChartWithWeightsState();
}

class Field {
  final String key;
  final String name;
  bool enabled;
  double weight;

  Field({
    required this.key,
    required this.name,
    this.enabled = true,
    this.weight = 1.0,
  });
}

class _BarChartWithWeightsState extends State<BarChartWithWeights> {
  late List<Field> fields;
  late List<TeamStats2026> originalData;
  late List<Map<String, dynamic>> chartData;

  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> _updateData(
      List<Field> fields, List<TeamStats2026> originalData) {
    List<Map<String, dynamic>> adjustedData = originalData.map((item) {
      final newItem = {...item.toJson()};
      for (var field in fields) {
        if (field.enabled) {
          newItem[field.key] =
              (double.tryParse(item.toJson()[field.key].toString()) ?? 0) *
                  field.weight;
        }
      }
      return newItem;
    }).toList();
    // Sort the adjusted data by total values.
    adjustedData.sort((a, b) {
      double aTotal = 0;
      double bTotal = 0;

      for (var field in fields) {
        if (field.enabled) {
          aTotal += double.parse(a[field.key].toString());
          bTotal += double.parse(b[field.key].toString());
        }
      }
      return bTotal.compareTo(aTotal);
    });

    return adjustedData;
  }

  void _handleWeightChange(String value, String key) {
    setState(() {
      for (var field in fields) {
        if (field.key == key) {
          field.weight = double.tryParse(value) ?? 1.0;
        }
      }
      chartData = _updateData(fields, originalData);
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      fields = widget.startingFields;
      originalData = widget.data;
      chartData = _updateData(fields, originalData);
    });
    final palette = [
      Colors.blue,
      Colors.red,
      Colors.purple,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
      Colors.indigo,
      Colors.lime,
      Colors.amber,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.pinkAccent,
      Colors.blueGrey,
      Colors.greenAccent,
    ];

    void _exportToCSV() {
      List<List<dynamic>> rows = [];

      List<dynamic> header = ['team_number'];
      for (var field in fields) {
        if (field.enabled) {
          header.add('${field.name} (x${field.weight})');
        }
      }
      header.add('Total');
      rows.add(header);

      for (var data in chartData) {
        List<dynamic> row = [data['team_number']];
        double total = 0;

        for (var field in fields) {
          if (field.enabled) {
            double value = data[field.key] is num
                ? (data[field.key] as num).toDouble()
                : 0.0;

            row.add(value);
            total += value;
          }
        }

        row.add(total);
        rows.add(row);
      }

      String csv = ListToCsvConverter().convert(rows);
      final bytes = utf8.encode(csv);

      // ✅ FIX
      downloadFile(bytes, '${widget.title}.csv');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style:
              TextStyle(color: Colors.blue, fontSize: 20, fontFamily: 'Font'),
        ),
        SfCartesianChart(
          tooltipBehavior: TooltipBehavior(
            enable: true,
            shared: false,
          ),
          primaryXAxis: CategoryAxis(
            labelRotation: isMobile() ? 90 : 0,
            labelIntersectAction: AxisLabelIntersectAction.multipleRows,
          ),
          legend: Legend(),
          series: fields.where((field) => field.enabled).map((field) {
            final index = fields.indexOf(field);
            return StackedColumnSeries<Map<String, dynamic>, String>(
              animationDuration: 500,
              dataSource: chartData.take(widget.number).toList(),
              xValueMapper: (data, _) => data['team_number']?.toString() ?? '',
              yValueMapper: (data, _) => (data[field.key] is num)
                  ? (data[field.key] as num).toDouble()
                  : 0.0,
              name: field.name,
              color: palette[index % palette.length],
            );
          }).toList(),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: fields.where((field) => field.enabled).map((field) {
            final index = fields.indexOf(field);
            return SizedBox(
              width: 80,
              child: TextField(
                decoration: InputDecoration(
                    labelText: field.name,
                    labelStyle: TextStyle(
                        color: palette[index % palette.length],
                        fontFamily: 'Font'),
                    floatingLabelStyle: TextStyle(
                        color: palette[index % palette.length],
                        fontFamily: 'Font')),
                controller:
                    new TextEditingController(text: field.weight.toString()),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?\d*\.?\d*$'),
                  ),
                ],
                onSubmitted: (value) => _handleWeightChange(value, field.key),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _exportToCSV,
          child: Text('Export to CSV', style: TextStyle(fontFamily: 'Font')),
        ),
      ],
    );
  }
}
