import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/match_details_2024.dart';
import '../models/match_scouting_2024.dart';

import 'models/team_stats_2024.dart';
import 'models/tournament.dart';

class ApiService {
  final String APIURL;
  final Duration cacheDuration;

  ApiService(this.APIURL, {this.cacheDuration = const Duration(minutes: 5)});

  Map<String, dynamic> _cache = {};

  dynamic _setInCache(String key, dynamic value) {
    DateTime timestamp = DateTime.now();
    Map<String, dynamic> item = {
      'data': value,
      'timestamp': timestamp,
    };
    _cache[key] = item;
  }

  dynamic _getFromCache(String key, Function() ifExpired) {
    if (_cache.containsKey(key) &&
        DateTime.now().difference(_cache[key]['timestamp']) < cacheDuration) {
      return _cache[key]['data'];
    }
    return ifExpired();
  }

  Future<dynamic> _fetchFromAPI(String url, String cacheKey,
      {bool? useCache}) async {
    Function() getFromAPI = () async {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _setInCache(cacheKey, data);
        return data;
      } else {
        throw Exception('Failed to load data from ' + url);
      }
    };
    if (useCache ?? true)
      return _getFromCache(cacheKey, getFromAPI);
    else
      return getFromAPI();
  }

  Future<List<Tournament>> fetchTournaments() async {
    final cacheKey = 'tournaments';
    final url = '$APIURL/search_keys';
    final tournaments = [
      for (var x in ((await _fetchFromAPI(url, cacheKey)
          as Map<String, dynamic>)['data']))
        Tournament.fromJson(x)
    ];
    return tournaments;
  }

  Future<Map<String, dynamic>> fetchStatDescription(
      int year, String event) async {
    final cacheKey = '${year}_${event}_stat_description';
    final url = '$APIURL/$year/$event/stat_description';
    return await _fetchFromAPI(url, cacheKey) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchTeamStats(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_${team}_team_stats';
    final url = '$APIURL/$year/$event/$team/stats';
    return await _fetchFromAPI(url, cacheKey) as Map<String, dynamic>;
  }

  Future<List<TeamStats2024>> fetchEventRankings(int year, String event) async {
    final cacheKey = '${year}_${event}_rankings';
    final url = '${APIURL}/${year}/${event}/stats';
    var data = (await _fetchFromAPI(url, cacheKey))['data'];
    data = [...data];
    data.removeAt(0);
    data = data.where((x) => x != null);
    return [for (var x in data) TeamStats2024.fromJson(x)];
  }

  Future<List<dynamic>> fetchPitStatus(int year, String event) async {
    final cacheKey = '${year}_${event}_pit_status';
    final url = '${APIURL}/${year}/${event}/pitStatus';
    var data = (await _fetchFromAPI(url, cacheKey))['data'];
    data = [...data];
    return data;
  }

  Future<List<Image>> fetchTeamImages(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_${team}_pictures';
    final url = '${APIURL}/${year}/${event}/${team}/getPictures';
    var data = (await _fetchFromAPI(url, cacheKey));
    List<Image> returnImages = [];
    for (Map<String, dynamic> imageData in data) {
      returnImages.add(Image.memory(base64Decode(imageData['file'])));
    }
    return returnImages;
  }

  Future<List<dynamic>> fetchQualMatches(int year, String event) async {
    final cacheKey = '${year}_${event}_predictions';
    final url = '${APIURL}/${year}/${event}/predictions';
    var data = (await _fetchFromAPI(url, cacheKey))['data'];
    data = [...data];
    return data;
  }

  Future<List<dynamic>> fetchEventScouting(int year, String event) async {
    final cacheKey = '${year}_${event}_scout_entries';
    final url = '${APIURL}/${year}/${event}/ScoutEntries';
    var data = (await _fetchFromAPI(url, cacheKey));
    data = [...data];
    return data;
  }

  Future<List<MatchScouting2024>> fetchTeamMatchScouting(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_${team}_match_scout_entries';
    final url = '${APIURL}/${year}/${event}/${team}/ScoutEntries';
    var data = (await _fetchFromAPI(url, cacheKey));
    var returnValue = <MatchScouting2024>[];
    for (var matchData in data) {
      dynamic died = matchData['data']['miscellaneous']['died'];
      if (died == 1 || died == true) {
        died = true;
      } else {
        died = false;
      }
      matchData['data']['miscellaneous']['died'] = died;
      returnValue.add(MatchScouting2024.fromJson(matchData));
    }
    return returnValue;
  }

  Future<void> deactivateMatchData(Map<String, dynamic> data, String password,
      Function(int) callback) async {
    try {
      final String endpoint = '$APIURL/$password/Deactivate';
      final response = await http.put(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      callback(response.statusCode);
    } catch (e) {
      print('Error in deactivateMatchData: $e');
      callback(0); // Return 0 for failure
    }
  }

  Future<void> activateMatchData(Map<String, dynamic> data, String password,
      Function(int) callback) async {
    try {
      final String endpoint = '$APIURL/$password/Activate';
      final response = await http.put(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      callback(response.statusCode);
    } catch (e) {
      print('Error in activateMatchData: $e');
      callback(0); // Return 0 for failure
    }
  }

  Future<Map<String, dynamic>> fetchFollowUp(
      String year, String event, String team) async {
    try {
      final storageName = '${year}${event}_${team}_deaths';
      final endpoint = '$APIURL/$year/$event/$team/FollowUp';
      final data = await _fetchFromAPI(endpoint, storageName, useCache: false);
      return data;
    } catch (e) {
      print('Error fetching follow-up data: $e');
      return {'deaths': []};
    }
  }

  Future<int> postFollowUp(
      dynamic data, String year, String event, String team) async {
    try {
      final endpoint = '$APIURL/$year/$event/$team/FollowUp';
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      final status = response.statusCode;
      return status;
    } catch (e) {
      print('Error posting follow-up data: $e');
      return 0;
    }
  }

  Future<MatchDetails2024> fetchMatchDetails(
      int year, String event, String match_key) async {
    final cacheKey = '${year}_${event}_${match_key}_details';
    final url = '${APIURL}/${year}/${event}/${match_key}/match_details';
    var data = (await _fetchFromAPI(url, cacheKey));
    return MatchDetails2024.fromJson(data);
  }
}
