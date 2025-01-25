import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';

import 'auth_service.dart';
import 'dart:html';

class WebAuthService implements AuthService {
  final String APIURL, AUTHURL, APPURL, REALM, CLIENT;
  const WebAuthService(
      this.APIURL, this.AUTHURL, this.APPURL, this.REALM, this.CLIENT)
      : super();
  static const String tokenKey = 'pf_token';
  static String _randomString(int length) {
    var r = Random.secure();
    var chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return Iterable.generate(length, (_) => chars[r.nextInt(chars.length)])
        .join();
  }

  @override
  Future<String?> login(redirect_path) async {
    // Keycloak authorization endpoint and client details
    try {
      final token = await getToken();
      if (token != null)
        return token;
      else
        throw 'need new token';
    } catch (e) {
      print(e);
      var authorizationEndpoint =
          '$AUTHURL/realms/$REALM/protocol/openid-connect/auth';
      var clientId = CLIENT;
      var redirectUri = '$APPURL/$redirect_path';

      final responseType = 'code'; // Use authorization code flow
      final scope = 'openid profile email'; // Adjust scopes as needed

      // Build the redirect URI with an optional redirect path
      final loginUrl =
          Uri.parse(authorizationEndpoint).replace(queryParameters: {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'response_type': responseType,
        'scope': scope,
      });

      // Redirect the user to the login URL
      window.location.href = loginUrl.toString();
    }
    return null;
  }

  @override
  Future<void> logout() async {
    // Remove token from localStorage
    window.sessionStorage.remove(tokenKey);

    // Optionally redirect to a logout page or refresh the application
    var redirectUri = Uri.parse(APPURL)
        .replace(path: Uri.parse(window.location.href).path)
        .toString();
    window.location.href =
        '$AUTHURL/realms/$REALM/protocol/openid-connect/logout?post_logout_redirect_uri=$redirectUri/&client_id=$CLIENT';
  }

  static Future<String?>? _runningFuture = null;
  @override
  Future<String?> getToken() async {
    // Extract the authorization code from the URL
    if (_runningFuture != null) return _runningFuture;
    _runningFuture = _getToken();
    _runningFuture!.whenComplete(() => _runningFuture = null);
    return _runningFuture;
  }

  Future<String?> _getToken() async {
    try {
      final tokenData = window.sessionStorage['pf_token'];
      if (tokenData != null) {
        final data = json.decode(tokenData);
        final expirationTime = DateTime.parse(data[1]);
        final token = data[0];
        if (DateTime.now().isBefore(expirationTime)) {
          return token; // Token is still valid
        } else {
          window.sessionStorage.remove('pf_token'); // Token expired
        }
      }
    } catch (e) {
      print(e);
    }
    final uri = Uri.parse(window.location.href);
    final authorizationCode = uri.queryParameters['code'];
    // print('Authorization code: $authorizationCode');
    if (authorizationCode == null) {
      // throw ('Authorization code: $authorizationCode');
      return null;
    }

    // Keycloak token endpoint and client details
    var tokenEndpoint = '$AUTHURL/realms/$REALM/protocol/openid-connect/token';
    var clientId = CLIENT;
    var redirectUri = Uri.parse(APPURL)
        .replace(path: Uri.parse(window.location.href).path)
        .toString();

    // Exchange the authorization code for an access token
    final response = await post(
      Uri.parse(tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': authorizationCode,
        'client_id': clientId,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      final tokenData = jsonDecode(response.body);
      saveToken(tokenData['access_token']);
      return tokenData['access_token'] as String?;
    } else {
      //Make sure another request has not already been made
      try {
        final tokenData = window.sessionStorage['pf_token'];
        if (tokenData != null) {
          final data = json.decode(tokenData);
          final expirationTime = DateTime.parse(data[1]);
          final token = data[0];
          if (DateTime.now().isBefore(expirationTime)) {
            return token; // Token is still valid
          } else {
            window.sessionStorage.remove('pf_token'); // Token expired
          }
        }
      } catch (e) {}
      throw Exception('Failed to get token: ${response.body}');
    }
  }

  void saveToken(token) {
    final expirationTime =
        DateTime.now().add(Duration(minutes: 30)); // Current time + 30 minutes
    final tokenData = [token, expirationTime.toString()];
    window.sessionStorage['pf_token'] = json.encode(tokenData);
  }
}

AuthService getManager(String APIURL, String AUTHURL, String APPURL,
        String REALM, String CLIENT) =>
    WebAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT);
