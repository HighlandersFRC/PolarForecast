import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouting_app/models/scouting_report.dart';

class ScoutingReportService {
  final String apiUrl;

  ScoutingReportService({required this.apiUrl});

  Future<ScoutingReport> fetchReport({
    required String group,
    required String event,
  }) async {
    final url = Uri.parse('$apiUrl/group/$group/$event/ScoutingReport');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return ScoutingReport.fromJson(decoded);
    } else {
      throw Exception('Failed to load scouting report: ${response.statusCode}');
    }
  }
}
