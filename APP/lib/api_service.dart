import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:scouting_app/models/deaths_form.dart';
import 'package:scouting_app/models/group.dart';
import 'package:scouting_app/models/group_join_request.dart';
import 'package:scouting_app/models/match_details_2026.dart';
import 'package:scouting_app/models/picture_data.dart';
import 'package:scouting_app/models/team_stats_2026.dart';
import 'package:scouting_app/utils.dart';
import 'auth/auth_service.dart';
import 'models/alliance_request.dart';
import 'models/global_rank.dart';
import 'models/match_scouting_2026.dart';
import 'models/pit_scouting_2026.dart';
import 'models/tournament.dart';
import 'models/scouting_report.dart';
import 'package:image/image.dart';

class ApiService {
  final String APIURL, AUTHURL, APPURL, REALM, TBA_KEY, CLIENT;
  final Duration cacheDuration;
  final AuthService authService;
  Future<String?> get token async => await authService.getToken();

  List<Tournament>? tournaments;
  // set token(dynamic token) => _token = token;

  ApiService(
      {required this.APIURL,
      required this.AUTHURL,
      required this.APPURL,
      required this.REALM,
      required this.TBA_KEY,
      required this.CLIENT,
      required this.authService,
      required this.cacheDuration});

  Map<String, dynamic> _cache = {};
  Map<String, Future> _pendingRequests = {};
  dynamic _setInCache(String key, dynamic value,
      {Duration cacheTime = const Duration(minutes: 5)}) {
    DateTime timestamp = DateTime.now().add(cacheTime);
    Map<String, dynamic> item = {
      'data': value,
      'timestamp': timestamp,
    };
    _cache[key] = item;
  }

  dynamic _getFromCache(String key, Function() ifExpired) {
    if (_cache.containsKey(key) &&
        DateTime.now().compareTo(_cache[key]['timestamp']) < 0) {
      return _cache[key]['data'];
    }
    return ifExpired();
  }

  Future<dynamic> _fetchFromAPI(String url, String cacheKey,
      {bool? useCache,
      Duration cacheTime = const Duration(minutes: 5),
      Map<String, String> extraHeaders = const {}}) async {
    Function() getFromAPI = () async {
      if (_pendingRequests.containsKey(cacheKey))
        return _pendingRequests[cacheKey];
      Map<String, String> headers = extraHeaders;
      Future<dynamic> Function() futureFunc = () async {
        final _token = await token;
        if (_token != null) headers = {'token': _token, ...extraHeaders};
        final response = await http.get(Uri.parse(url), headers: headers);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _setInCache(cacheKey, data, cacheTime: cacheTime);
          return data;
        } else {
          throw Exception('Failed to load data from ' + url);
        }
      };
      final future = futureFunc().whenComplete(() {
        _pendingRequests.remove(cacheKey);
      });
      _pendingRequests[cacheKey] = future;
      return future;
    };
    if (useCache ?? true) return _getFromCache(cacheKey, getFromAPI);
    return getFromAPI();
  }

  Future<String> fetchTeamNicknames(String team_number) async {
    Map<String, String> extraHeaders = {'X-TBA-Auth-Key': TBA_KEY};
    final url = 'https://www.thebluealliance.com/api/v3/team/$team_number';

    final data = await http.get(Uri.parse(url), headers: extraHeaders);
    return jsonDecode(data.body)['nickname'];
  }

  Future<List<Tournament>> fetchTournaments() async {
    final cacheKey = 'tournaments';
    final url = '$APIURL/search_keys';
    if (this.tournaments == null) {
      tournaments = [
        for (var x in ((await _fetchFromAPI(url, cacheKey)
            as Map<String, dynamic>)['data']))
          Tournament.fromJson(x)
      ];
    }
    return this.tournaments!;
  }

  Future<Map<String, dynamic>> fetchTeamStats(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_${team}_team_stats';
    final url = '$APIURL/$year/$event/$team/stats';
    return await _fetchFromAPI(url, cacheKey) as Map<String, dynamic>;
  }

  Future<List<TeamStats2026>> fetchEventRankings(int year, String event) async {
    final cacheKey = '${year}_${event}_rankings';
    final url = '${APIURL}/${year}/${event}/stats';
    var data = (await _fetchFromAPI(url, cacheKey))['data'];
    data = [...data];
    data.removeAt(0);
    data = data.where((x) => x != null);
    return [for (var x in data) TeamStats2026.fromJson(x)];
  }

  Future<List<dynamic>> fetchPitStatus(int year, String event) async {
    final cacheKey = '${year}_${event}_pit_status';
    final url = '${APIURL}/${year}/${event}/PitScoutingStatus';
    var data = (await _fetchFromAPI(url, cacheKey, useCache: false))['data'];
    data = [...data];
    return data;
  }

  Future<PitScouting2026> fetchTeamPitScouting(
      String year, String event, String team) async {
    final storageName = '${year}/${event}_${team}_PitScouting';
    final endpoint = '$APIURL/$year/$event/$team/PitScouting';

    try {
      final response =
          await _fetchFromAPI(endpoint, storageName, useCache: false);

      // Defensive null check
      if (response == null || response is! Map<String, dynamic>) {
        print('Warning: Pit scouting API returned null or invalid data');
        return _defaultPitScouting(year, event, team);
      }

      return PitScouting2026.fromJson(response);
    } catch (e) {
      print('Error fetching pit scouting data: $e');
      return _defaultPitScouting(year, event, team);
    }
  }

// Helper to create a default PitScouting2026 object
  PitScouting2026 _defaultPitScouting(String year, String event, String team) {
    return PitScouting2026(
      scout_info: get_scout_info(''), // pass token if needed
      team_number: int.tryParse(team.replaceAll(RegExp(r'\D'), '')) ?? 0,
      time: 0,
      event_code: '$year$event',
      data: PitData2026(
          auto: Auto2026(
            starting_position_meters_from_hub_center: 0,
            steps: [],
            field_side: [],
            preload: false,
            climb: false,
            contacts_robot: false,
          ),
          driver_experience_events: 0,
          drive_train: '',
          climbing: [],
          spare_parts: 0,
          favorite_color: '',
          autos: [],
          can_feed_human_player: false,
          can_pick_up_from_ground: false,
          distance_to_shoot: 0,
          go_over_bump: false,
          go_under_trench: false,
          can_climb: false,
          can_climb_in_autonomous: false,
          automatically_shooting: false,
          shooting_while_moving: false,
          main_strategy: '',
          hopper_capacity: 0,
          mag_unload_speed: 0,
          bps: 0,
          robot_height: 0,
          straddling_pole_climb_right: false,
          straddling_pole_climb_left: false,
          left_pole_climb: false,
          right_pole_climb: false,
          center_pole_climb: false),
      user_id: '',
      auto: Auto2026(
        starting_position_meters_from_hub_center: 0,
        steps: [],
        field_side: [],
        preload: false,
        climb: false,
        contacts_robot: false,
      ),
    );
  }

  Future<int> postPitScouting(
      PitScouting2026 data, String year, String event, String team) async {
    try {
      final endpoint = '$APIURL/PitScouting/';
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'token': (await token) ?? ''
        },
        body: json.encode(data.toJson()),
      );
      final status = response.statusCode;
      return status;
    } catch (e) {
      print('Error posting pit scouting data: $e');
      return 0;
    }
  }

  Future<List<PictureData>> fetchTeamImages(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_${team}_pictures';
    final url = '${APIURL}/${year}/${event}/${team}/getPictures';
    var data = (await _fetchFromAPI(url, cacheKey, useCache: false));
    List<PictureData> returnImages = [];
    for (Map<String, dynamic> imageMap in data) {
      PictureData imageData = PictureData.fromJson(imageMap);
      returnImages.add(imageData);
    }
    return returnImages;
  }

  Future<List<PictureData>> fetchEventImages(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_pictures';
    final url = '${APIURL}/${year}/${event}/getPictures';
    var data = (await _fetchFromAPI(url, cacheKey, useCache: false));
    List<PictureData> returnImages = [];
    for (Map<String, dynamic> imageMap in data) {
      PictureData imageData = PictureData.fromJson(imageMap);
      returnImages.add(imageData);
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

  Future<List<MatchScouting2026>> fetchEventScouting(
      int year, String event) async {
    final cacheKey = '${year}_${event}_scout_entries';
    final url = '${APIURL}/${year}/${event}/ScoutEntries';
    var data = (await _fetchFromAPI(url, cacheKey, useCache: true));
    data = [...data];
    List<MatchScouting2026> retVal = [];
    for (var x in data) {
      try {
        retVal.add(MatchScouting2026.fromJson(x));
      } catch (e) {}
    }
    return retVal;
  }

  Future<List<MatchScouting2026>> fetchTeamMatchScouting(
      int year, String event, String team) async {
    final cacheKey = '${year}_${event}_${team}_match_scout_entries';
    final url = '${APIURL}/${year}/${event}/${team}/ScoutEntries';
    var data = (await _fetchFromAPI(url, cacheKey, useCache: false));
    var returnValue = <MatchScouting2026>[];
    for (var matchData in data) {
      returnValue.add(MatchScouting2026.fromJson(matchData));
    }
    return returnValue;
  }

  Future<Deaths> fetchFollowUp(String year, String event, String team) async {
    await token;
    try {
      final storageName = '${year}${event}_${team}_deaths';
      final endpoint = '$APIURL/$year/$event/$team/FollowUp';
      final data = await _fetchFromAPI(endpoint, storageName, useCache: false);
      return Deaths.fromJson(data);
    } catch (e) {
      print('Error fetching follow-up data: $e');
      return Deaths(
          scout_info: get_scout_info((await token) ?? ''),
          event_code: year + event,
          team_key: team,
          deaths: [],
          total: 0,
          average: 0,
          time: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
    }
  }

  Future<int> postFollowUp(
      dynamic data, String year, String event, String team) async {
    try {
      final endpoint = '$APIURL/FollowUp';
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'token': await token ?? '',
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

  Future<MatchDetails2026> fetchMatchDetails(
      int year, String event, String match_key) async {
    final cacheKey = '${year}_${event}_${match_key}_details';
    final url = '${APIURL}/${year}/${event}/${match_key}/match_details';
    var data = (await _fetchFromAPI(url, cacheKey));
    return MatchDetails2026.fromJson(data);
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
    String endpoint = '$APIURL/User/Groups';
    final data = await _fetchFromAPI(
      endpoint,
      'user_groups',
      useCache: false,
    );
    return data;
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
      throw Exception('${response.body}');
    }
  }

  Future<(Group, String)> get_group(String name) async {
    final endpoint = '$APIURL/Group/$name';
    final data = await _fetchFromAPI(endpoint, '', useCache: false);
    var group = Group.fromJson(data['group']);
    var role = data['group_role'].toString();
    group = group.copyWith(
        events: group.events
            .where((e) => e.event_code.startsWith('2026'))
            .toList());
    return (group, role);
  }

  Future<Map> get_group_members(String name) async {
    final endpoint = '$APIURL/Group/$name/Members';
    return await _fetchFromAPI(endpoint, '', useCache: false);
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

  Future<(Group, String)> remove_event_from_group(
      String group_name, String event) async {
    final response = await http.delete(
      Uri.parse('$APIURL/Group/$group_name/Event/$event/Remove'),
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
    final endpoint = '$APIURL/$year/$event/Groups';
    return await _fetchFromAPI(endpoint, '', useCache: false);
  }

  Future<List<AllianceRequest>> request_alliance(
      String group_name, String event_key, String other_group) async {
    final response = await http.post(
      Uri.parse(
          '$APIURL/Group/$group_name/Event/$event_key/Alliance/Request?other_group=$other_group'),
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
    final endpoint = '$APIURL/Group/$group_name/AllianceRequests';
    final requests = await _fetchFromAPI(endpoint, '', useCache: false);
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
    final endpoint = '$APIURL/User/GroupJoinRequests';
    final requests = await _fetchFromAPI(endpoint, '', useCache: false);
    List<GroupJoinRequest> retVal = [];
    for (final request in requests) {
      retVal.add(GroupJoinRequest.fromJson(request));
    }
    return retVal;
  }

  Future<List<GroupJoinRequest>> get_group_join_requests(
      String group_name) async {
    final endpoint = '$APIURL/Group/$group_name/JoinRequests';
    final requests = await _fetchFromAPI(endpoint, '', useCache: false);
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

  Future<void> post_image(
      Uint8List image, String event_code, int team, String image_type) async {
    // Get the pre-signed URL for uploading the image
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
    // Resize image to 480p (854x480 maintaining aspect ratio)
    var decodedImage = decodeImage(image);
    if (decodedImage != null) {
      var resized = copyResize(
        decodedImage,
        height: 360,
      );
      image = Uint8List.fromList(encodeJpg(resized, quality: 85));
    }
    final response = await http.put(
      Uri.parse(preSignedURL),
      headers: {
        'x-ms-blob-type': 'BlockBlob',
        'Content-Type': 'image/jpeg',
      },
      body: image,
    );
    if (response.statusCode ~/ 100 != 2) {
      throw Exception(json.decode(response.body)['detail']);
    }
    var data = PictureData(
        scout_info: get_scout_info(await token ?? ''),
        team_number: team,
        time: 0,
        event_code: event_code,
        image_id: image_id,
        link: '',
        permissions: [],
        image_type: image_type);
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

  Future<void> delete_image(PictureData image) async {
    final url = '$APIURL/Pictures/Delete';
    final request = await http.delete(Uri.parse(url),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(image.toJson()));
    if (request.statusCode != 200) {
      throw Exception(json.decode(request.body)['detail']);
    }
  }

  Future<void> post_match_scouting(MatchScouting2026 data) async {
    final url = '$APIURL/MatchScouting/';
    final request = await http.post(Uri.parse(url),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(data.toJson()));
    if (request.statusCode == 307) {
      throw Exception('update');
    } else if (request.statusCode != 200) {
      throw Exception(json.decode(request.body)['detail']);
    }
  }

  Future<void> update_match_scouting(MatchScouting2026 data) async {
    final url = '$APIURL/MatchScouting/';
    final request = await http.put(Uri.parse(url),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(data.toJson()));
    if (request.statusCode != 200) {
      throw Exception(json.decode(request.body)['detail']);
    }
  }

  Future<void> delete_match_scouting(MatchScouting2026 data) async {
    final url = '$APIURL/MatchScouting/Delete';
    final request = await http.delete(Uri.parse(url),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(data.toJson()));
    if (request.statusCode != 200) {
      throw Exception(json.decode(request.body)['detail']);
    }
  }

  Future<(List<GlobalRank>, int)> fetch_global_rankings({
    int limit = 100,
    int offset = 0,
    String sortBy = 'data.OPR',
    String sortOrder = 'desc',
    List<String>? filterTeams,
  }) async {
    final cacheKey =
        'global_rankings_${limit}_${offset}_${sortBy}_${sortOrder}_${filterTeams?.join(",")}';
    final queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
      if (filterTeams != null) 'filter_teams': filterTeams.join(','),
    };
    final url = Uri.parse('$APIURL/${DateTime.now().year}/GlobalRankings')
        .replace(queryParameters: queryParams);
    var data = await _fetchFromAPI(url.toString(), cacheKey, useCache: true);
    return (
      [for (var rank in data['data']) GlobalRank.fromJson(rank)],
      data['max_data_query'] as int
    );
  }

  Future<void> post_offline_match_scouting(MatchScouting2026 data) async {
    final url = '$APIURL/MatchScouting/Offline/';
    final request = await http.post(Uri.parse(url),
        headers: {
          'token': (await token) ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(data.toJson()));
    if (request.statusCode != 200) {
      throw Exception(json.decode(request.body)['detail']);
    }
  }

  Future<ScoutingReport> fetchReport({
    required String group,
    required String event,
  }) async {
    final cacheKey = '${group}_${event}_scouting_report';
    final url = Uri.parse('$APIURL/Group/$group/Event/$event/ScoutingReport');

    final decoded =
        await _fetchFromAPI(url.toString(), cacheKey, useCache: false);

    return ScoutingReport.fromJson(decoded);
  }
}
