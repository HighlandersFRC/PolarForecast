// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:html';

import 'package:http/http.dart';

import 'auth_service.dart';

class WebAuthService implements AuthService {
  final String APIURL, AUTHURL, APPURL, REALM, CLIENT;
  const WebAuthService(
      this.APIURL, this.AUTHURL, this.APPURL, this.REALM, this.CLIENT)
      : super();
  static const String tokenKey = 'pf_token';
  static const String refreshTokenKey = 'pf_refresh_token';

  String get _currentRedirectUri {
    final current = Uri.parse(window.location.href);
    return Uri(
      scheme: current.scheme,
      host: current.host,
      port: current.hasPort ? current.port : null,
      path: current.path.isEmpty ? '/' : current.path,
    ).toString();
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
      var redirectUri = _currentRedirectUri;

      final responseType = 'code'; // Use authorization code flow
      final scope =
          'openid profile email offline_access'; // Adjust scopes as needed

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
    // Remove token and refresh token from localStorage
    window.localStorage.remove(tokenKey);
    window.localStorage.remove(refreshTokenKey);
    window.localStorage.remove(_codeExchangedKey);
    var redirectUri = _currentRedirectUri;
    window.location.href =
        '$AUTHURL/realms/$REALM/protocol/openid-connect/logout?post_logout_redirect_uri=$redirectUri&client_id=$CLIENT';
  }

  static Future<String?>? _runningFuture = null;
  static const String _codeExchangedKey = 'pf_code_exchanged';

  @override
  Future<String?> getToken() async {
    if (_runningFuture != null) return _runningFuture;
    _runningFuture = _getToken();
    _runningFuture!.whenComplete(() => _runningFuture = null);
    return _runningFuture;
  }

  Future<String?> _getToken() async {
    try {
      final tokenData = window.localStorage[tokenKey];
      if (tokenData != null) {
        final data = json.decode(tokenData);
        final expirationTime = DateTime.parse(data[1]);
        final token = data[0];
        print(
            'DEBUG: Token found in storage. Expires: $expirationTime, Now: ${DateTime.now()}');
        if (DateTime.now().isBefore(expirationTime)) {
          print('DEBUG: Token is valid, returning it');
          return token; // Token is still valid
        } else {
          print('DEBUG: Token expired, removing from storage');
          window.localStorage.remove(tokenKey); // Token expired
        }
      } else {
        print('DEBUG: No token found in localStorage');
      }
    } catch (e) {
      print('DEBUG: Error retrieving token from storage: $e');
    }

    final refreshToken = window.localStorage[refreshTokenKey];
    print('DEBUG: Refresh token present: ${refreshToken != null}');
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        return await _refreshToken(refreshToken);
      } catch (e) {
        print('DEBUG: Error refreshing token: $e');
      }
    }

    final uri = Uri.parse(window.location.href);
    final authorizationCode = uri.queryParameters['code'];
    // Prevent reusing the same authorization code
    if (authorizationCode == null ||
        window.localStorage[_codeExchangedKey] == 'true') {
      return null;
    }

    // Keycloak token endpoint and client details
    var tokenEndpoint = '$AUTHURL/realms/$REALM/protocol/openid-connect/token';
    var clientId = CLIENT;
    var redirectUri = _currentRedirectUri;

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
      print('DEBUG: Token exchange successful. Keys: ${tokenData.keys}');
      print(
          'DEBUG: Has access_token: ${tokenData.containsKey('access_token')}');
      print(
          'DEBUG: Has refresh_token: ${tokenData.containsKey('refresh_token')}');
      saveToken(
          tokenData['access_token'], tokenData['refresh_token'] as String?);
      // Mark code as exchanged to prevent reuse
      window.localStorage[_codeExchangedKey] = 'true';
      // Clean the URL to remove the authorization code
      final cleanedUri = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: uri.path,
      ).toString();
      window.history.replaceState(null, '', cleanedUri);
      return tokenData['access_token'] as String?;
    } else {
      print(
          'DEBUG: Token exchange failed. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to get token: ${response.body}');
    }
  }

  Future<String?> _refreshToken(String refreshToken) async {
    var tokenEndpoint = '$AUTHURL/realms/$REALM/protocol/openid-connect/token';
    var clientId = CLIENT;

    final response = await post(
      Uri.parse(tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': clientId,
      },
    );

    if (response.statusCode == 200) {
      final tokenData = jsonDecode(response.body);
      saveToken(tokenData['access_token'], tokenData['refresh_token']);
      return tokenData['access_token'] as String?;
    } else {
      window.localStorage
          .remove(refreshTokenKey); // Refresh token expired or invalid
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }

  void saveToken(String token, String? refreshToken) {
    final expirationTime = DateTime.now()
        .add(const Duration(minutes: 30)); // Current time + 30 minutes
    final tokenData = [token, expirationTime.toIso8601String()];
    window.localStorage[tokenKey] = json.encode(tokenData);
    print('DEBUG: Token saved. Expires: $expirationTime');

    if (refreshToken != null && refreshToken.isNotEmpty) {
      window.localStorage[refreshTokenKey] = refreshToken;
      print('DEBUG: Refresh token saved');
    } else {
      print('WARNING: No refresh token returned from Keycloak');
      window.localStorage.remove(refreshTokenKey);
    }
  }
}

AuthService getManager(String APIURL, String AUTHURL, String APPURL,
        String REALM, String CLIENT) =>
    WebAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT);
