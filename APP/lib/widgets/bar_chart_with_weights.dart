import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/team_stats_2024.dart';

class BarChartWithWeights extends StatefulWidget {
  final List<TeamStats2024> data;
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
  late List<TeamStats2024> originalData;
  late List<Map<String, dynamic>> chartData;

  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> _updateData(
      List<Field> fields, List<TeamStats2024> originalData) {
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
    bool isMobile() {
      try {
        return (Platform.isAndroid || Platform.isIOS);
      } catch (e) {
        return false;
      }
    }

    return Column(
      children: [
        Text(
          widget.title,
          style: TextStyle(color: Colors.blue, fontSize: 20),
        ),
        SfCartesianChart(
          tooltipBehavior: TooltipBehavior(
            enable: true,
            shared: true,
          ),
          primaryXAxis: CategoryAxis(
            labelRotation: isMobile() ? 90 : 0,
            labelIntersectAction: AxisLabelIntersectAction.multipleRows,
          ),
          legend: Legend(),
          series: fields.where((field) => field.enabled).map((field) {
            final index = fields.indexOf(field);
            return StackedColumnSeries<Map<String, dynamic>, String>(
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
                  labelStyle: TextStyle(color: palette[index % palette.length]),
                ),
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
      ],
    );
  }
}
