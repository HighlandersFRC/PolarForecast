import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scouting_app/models/group.dart';
import 'package:scouting_app/models/group_join_request.dart';
import 'package:scouting_app/models/match_details_2025.dart';
import 'package:scouting_app/models/picture_data.dart';
import 'package:scouting_app/models/team_stats_2025.dart';
import 'auth/auth_service.dart';
import 'models/alliance_request.dart';
import 'models/match_scouting_2025.dart';
import 'models/tournament.dart';
import 'package:image/image.dart' as img;

class ApiService {
  final String APIURL, AUTHURL, APPURL, REALM, CLIENT;
  final Duration cacheDuration;
  final AuthService authService;
  Future<String?> get token async => await authService.getToken();
  // set token(dynamic token) => _token = token;

  ApiService(
      {required this.APIURL,
      required this.AUTHURL,
      required this.APPURL,
      required this.REALM,
      required this.CLIENT,
      required this.authService,
      required this.cacheDuration});

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
      Map<String, String> headers = {};
      final _token = await token;
      if (_token != null) headers = {'token': _token};
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _setInCache(cacheKey, data);
        return data;
      } else {
        throw Exception('Failed to load data from ' + url);
      }
    };
    if (useCache ?? true) return _getFromCache(cacheKey, getFromAPI);
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

  Future<Map<String, dynamic>> fetchTeamStats(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_${team}_team_stats';
    final url = '$APIURL/$year/$event/$team/stats';
    return await _fetchFromAPI(url, cacheKey) as Map<String, dynamic>;
  }

  Future<List<TeamStats2025>> fetchEventRankings(int year, String event) async {
    final cacheKey = '${year}_${event}_rankings';
    final url = '${APIURL}/${year}/${event}/stats';
    var data = (await _fetchFromAPI(url, cacheKey))['data'];
    data = [...data];
    data.removeAt(0);
    data = data.where((x) => x != null);
    return [for (var x in data) TeamStats2025.fromJson(x)];
  }

  Future<List<dynamic>> fetchPitStatus(int year, String event) async {
    final cacheKey = '${year}_${event}_pit_status';
    final url = '${APIURL}/${year}/${event}/PitScoutingStatus';
    var data = (await _fetchFromAPI(url, cacheKey))['data'];
    data = [...data];
    return data;
  }

  Future<Map<String, dynamic>> fetchTeamPitScouting(
      String year, String event, String team) async {
    try {
      final storageName = '${year}${event}_${team}_PitScouting';
      final endpoint = '$APIURL/$year/$event/$team/PitScouting';
      final data = await _fetchFromAPI(endpoint, storageName, useCache: false);
      return data;
    } catch (e) {
      print('Error fetching pit scouting data: $e');
      return {'pit_scouting': []};
    }
  }

  Future<int> postPitScouting(
      dynamic data, String year, String event, String team) async {
    try {
      final endpoint = '$APIURL/$year/$event/$team/PitScouting';
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
      print('Error posting pit scouting data: $e');
      return 0;
    }
  }

  Future<List<Image>> fetchTeamImages(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_${team}_pictures';
    final url = '${APIURL}/${year}/${event}/${team}/getPictures';
    var data = (await _fetchFromAPI(url, cacheKey));
    List<Image> returnImages = [];
    for (Map<String, dynamic> imageMap in data) {
      PictureData imageData = PictureData.fromJson(imageMap);
      returnImages.add(Image.network(imageData.link));
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

  Future<List<MatchScouting2025>> fetchTeamMatchScouting(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_${team}_match_scout_entries';
    final url = '${APIURL}/${year}/${event}/${team}/ScoutEntries';
    var data = (await _fetchFromAPI(url, cacheKey));
    var returnValue = <MatchScouting2025>[];
    for (var matchData in data) {
      dynamic died = matchData['data']['miscellaneous']['died'];
      if (died == 1 || died == true) {
        died = true;
      } else {
        died = false;
      }
      matchData['data']['miscellaneous']['died'] = died;
      returnValue.add(MatchScouting2025.fromJson(matchData));
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

  Future<MatchDetails2025> fetchMatchDetails(
      int year, String event, String match_key) async {
    final cacheKey = '${year}_${event}_${match_key}_details';
    final url = '${APIURL}/${year}/${event}/${match_key}/match_details';
    var data = (await _fetchFromAPI(url, cacheKey));
    return MatchDetails2025.fromJson(data);
  }

  Future<void> login(String redirectPath) async {
    // try {
    final String? token = await authService.login(redirectPath);
    if (token != null) {
      // print('Login successful! Access token: $token');
    } else {
      print('Login failed or canceled');
    }
    // } catch (e) {
    //   print('Error during login: $e');
    // }
  }

  Future<void> logout() async {
    await authService.logout();
  }

  Future<List<dynamic>> get_user_groups() async {
    var token = await this.token;
    if (token == null) {
      throw Exception('no user token');
    }
    final response = await http.get(
      Uri.parse('$APIURL/User/Groups'),
      headers: {'token': token},
    );
    return json.decode(response.body);
  }

  Future<List<Group>> get_user_groups_detailed() async {
    var token = await this.token;
    if (token == null) {
      throw Exception('no user token');
    }
    String url = '$APIURL/User/Groups/Detailed';
    var data = await _fetchFromAPI(url, url, useCache: false);
    List<Group> retVal = [];
    for (var x in data) {
      retVal.add(Group.fromJson(x));
    }
    return retVal;
  }

  Future<Group> make_group(String name, String? event, int? year) async {
    var token = await this.token;
    if (token == null) {
      throw Exception('no user token');
    }
    String? eventCode;
    if (event != null && year != null) {
      eventCode = year.toString() + event;
    }

    final response = await http.post(
      eventCode != null
          ? Uri.parse('$APIURL/CreateGroup?group_name=$name&event=$eventCode')
          : Uri.parse('$APIURL/CreateGroup?group_name=$name'),
      headers: {
        'token': token,
        'group_name': name,
        if (eventCode != null) 'event': eventCode,
      },
    );
    if (response.statusCode == 200) {
      return Group.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to create group: ${response.statusCode} - ${response.body}');
    }
  }

  Future<(Group, String)> get_group(String name) async {
    final response = await http.get(
      Uri.parse('$APIURL/Group/$name'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final data = json.decode(response.body);
    return (Group.fromJson(data['group']), data['group_role'].toString());
  }

  Future<Map> get_group_members(String name) async {
    final response = await http.get(
      Uri.parse('$APIURL/Group/$name/Members'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    return json.decode(response.body);
  }

  Future<List<GroupJoinRequest>> join_group(
      String name, String join_code) async {
    final response = await http.post(
      Uri.parse('$APIURL/Group/$name/Join?join_code=$join_code'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final data = json.decode(response.body);
    List<GroupJoinRequest> retVal = [];
    for (var x in data) {
      retVal.add(GroupJoinRequest.fromJson(x));
    }
    return retVal;
  }

  Future<Map> demote_group_member(String group_name, String demote_id) async {
    final response = await http.put(
      Uri.parse(
          '$APIURL/Group/$group_name/Members/Demote?demote_id=$demote_id'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    return json.decode(response.body);
  }

  Future<Map> kick_group_member(String group_name, String kick_id) async {
    final response = await http.delete(
      Uri.parse('$APIURL/Group/$group_name/Members/Kick?kick_id=$kick_id'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    return json.decode(response.body);
  }

  Future<Map> promote_group_member(String group_name, String promote_id) async {
    final response = await http.put(
      Uri.parse(
          '$APIURL/Group/$group_name/Members/PromoteMember?promote_id=$promote_id'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    return json.decode(response.body);
  }

  Future<Map> promote_group_admin(String group_name, String promote_id) async {
    final response = await http.put(
      Uri.parse(
          '$APIURL/Group/$group_name/Members/PromoteAdmin?promote_id=$promote_id'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    return json.decode(response.body);
  }

  Future<void> leave_group(String group_name) async {
    final response = await http.delete(
      Uri.parse('$APIURL/Group/$group_name/Leave'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
  }

  Future<void> delete_group(String group_name) async {
    final response = await http.delete(
      Uri.parse('$APIURL/Group/$group_name/Delete'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
  }

  Future<(Group, String)> add_group_to_event(
      String group_name, String event) async {
    final response = await http.post(
      Uri.parse('$APIURL/Group/$group_name/Event/$event/Add'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final data = json.decode(response.body);
    return (Group.fromJson(data['group']), data['group_role'].toString());
  }

  Future<List> get_event_groups(String event, int year) async {
    final response =
        await http.get(Uri.parse('$APIURL/$year/$event/Groups'), headers: {
      'token': (await token) ?? '',
    });
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    return json.decode(response.body);
  }

  Future<List<AllianceRequest>> request_alliance(
      String group_name, String event_key, String other_group) async {
    final response = await http.post(
      Uri.parse(
          '$APIURL/Group/$group_name/Event/$event_key/Alliance/Request/?other_group=$other_group'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<AllianceRequest> retVal = [];
    for (final request in requests) {
      retVal.add(AllianceRequest.fromJson(request));
    }
    return retVal;
  }

  Future<List<AllianceRequest>> get_alliance_requests(String group_name) async {
    final response = await http
        .get(Uri.parse('$APIURL/Group/$group_name/AllianceRequests'), headers: {
      'token': (await token) ?? '',
    });
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<AllianceRequest> retVal = [];
    for (final request in requests) {
      retVal.add(AllianceRequest.fromJson(request));
    }
    return retVal;
  }

  Future<List<AllianceRequest>> accept_alliance(
      String group_name, String event, AllianceRequest request) async {
    final response = await http.post(
        Uri.parse('$APIURL/Group/$group_name/Event/$event/Alliance/Accept'),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()));
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<AllianceRequest> retVal = [];
    for (final request in requests) {
      retVal.add(AllianceRequest.fromJson(request));
    }
    return retVal;
  }

  Future<List<AllianceRequest>> decline_alliance(
      String group_name, String event, AllianceRequest request) async {
    final response = await http.delete(
        Uri.parse('$APIURL/Group/$group_name/Event/$event/Alliance/Decline'),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()));
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<AllianceRequest> retVal = [];
    for (final request in requests) {
      retVal.add(AllianceRequest.fromJson(request));
    }
    return retVal;
  }

  Future<List<AllianceRequest>> delete_alliance_request(
      String group_name, String event, AllianceRequest request) async {
    final response = await http.delete(
        Uri.parse(
            '$APIURL/Group/$group_name/Event/$event/Alliance/DeleteRequest'),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()));
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<AllianceRequest> retVal = [];
    for (final request in requests) {
      retVal.add(AllianceRequest.fromJson(request));
    }
    return retVal;
  }

  Future<(Group, String)> leave_alliance(
      String group_name, String event, String other_group) async {
    final response = await http.delete(
        Uri.parse(
            '$APIURL/Group/$group_name/Event/$event/Alliance/Leave?other_group=$other_group'),
        headers: {
          'token': (await token) ?? '',
        });
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final data = json.decode(response.body);
    return (Group.fromJson(data['group']), data['group_role'].toString());
  }

  Future<List<GroupJoinRequest>> get_user_join_requests() async {
    final response = await http.get(
      Uri.parse('$APIURL/User/GroupJoinRequests'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<GroupJoinRequest> retVal = [];
    for (final request in requests) {
      retVal.add(GroupJoinRequest.fromJson(request));
    }
    return retVal;
  }

  Future<List<GroupJoinRequest>> get_group_join_requests(
      String group_name) async {
    final response = await http.get(
      Uri.parse('$APIURL/Group/$group_name/JoinRequests'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<GroupJoinRequest> retVal = [];
    for (final request in requests) {
      retVal.add(GroupJoinRequest.fromJson(request));
    }
    return retVal;
  }

  Future<List<GroupJoinRequest>> accept_join_request(
      GroupJoinRequest request) async {
    final response = await http.post(
        Uri.parse('$APIURL/Group/${request.group_name}/JoinRequests/Accept'),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()));
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<GroupJoinRequest> retVal = [];
    for (final request in requests) {
      retVal.add(GroupJoinRequest.fromJson(request));
    }
    return retVal;
  }

  Future<List<GroupJoinRequest>> decline_join_request(
      GroupJoinRequest request) async {
    final response = await http.delete(
        Uri.parse('$APIURL/Group/${request.group_name}/JoinRequests/Decline'),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()));
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<GroupJoinRequest> retVal = [];
    for (final request in requests) {
      retVal.add(GroupJoinRequest.fromJson(request));
    }
    return retVal;
  }

  Future<List<GroupJoinRequest>> delete_join_request(
      GroupJoinRequest request) async {
    final response = await http.delete(
        Uri.parse('$APIURL/Group/${request.group_name}/DeleteJoinRequest'),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()));
    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['detail']);
    }
    final requests = json.decode(response.body);
    List<GroupJoinRequest> retVal = [];
    for (final request in requests) {
      retVal.add(GroupJoinRequest.fromJson(request));
    }
    return retVal;
  }

  Future<void> post_image(img.Image image, String event_code, int team) async {
    final putURLResponse = await http.get(
      Uri.parse('$APIURL/Pictures/PutURL'),
      headers: {
        'token': (await token) ?? '',
      },
    );
    if (putURLResponse.statusCode != 200) {
      throw Exception(json.decode(putURLResponse.body)['detail']);
    }
    String preSignedURL = json.decode(putURLResponse.body)['presigned_url'];
    String image_id = json.decode(putURLResponse.body)['image_id'];
    final response = await http.put(
      Uri.parse(preSignedURL),
      headers: {
        'x-ms-blob-type': 'BlockBlob',
        'Content-Type': 'application/jpeg',
      },
      body: img.encodeJpg(image),
    );
    if (response.statusCode ~/ 100 != 2) {
      throw Exception(json.decode(response.body)['detail']);
    }
    var data = PictureData(
        user_id: '',
        team_number: team,
        time: 0,
        event_code: event_code,
        image_id: image_id,
        link: '',
        permissions: []);
    final postItOnAPI = await http.post(
      Uri.parse('$APIURL/Pictures/ConfirmUpload'),
      headers: {
        'token': (await token) ?? '',
        'Content-Type': 'application/json',
      },
      body: json.encode(data.toJson()),
    );
    if (postItOnAPI.statusCode ~/ 100 != 2) {
      throw Exception(json.decode(postItOnAPI.body)['detail']);
    }
  }
}
