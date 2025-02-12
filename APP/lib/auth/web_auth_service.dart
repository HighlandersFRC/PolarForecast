import 'dart:convert';
import 'package:http/http.dart';
import 'auth_service.dart';
import 'dart:html';

class WebAuthService implements AuthService {
  final String APIURL, AUTHURL, APPURL, REALM, CLIENT;
  const WebAuthService(
      this.APIURL, this.AUTHURL, this.APPURL, this.REALM, this.CLIENT)
      : super();
  static const String tokenKey = 'pf_token';
  static const String refreshTokenKey = 'pf_refresh_token';

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
      var redirectUri = Uri.parse(APPURL)
          .replace(path: Uri.parse(window.location.href).path)
          .toString();

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
    window.sessionStorage.remove(tokenKey);
    window.sessionStorage.remove(refreshTokenKey);
    var redirectUri = Uri.parse(APPURL)
        .replace(path: Uri.parse(window.location.href).path)
        .toString();
    window.location.href =
        '$AUTHURL/realms/$REALM/protocol/openid-connect/logout?post_logout_redirect_uri=$redirectUri/&client_id=$CLIENT';
  }

  static Future<String?>? _runningFuture = null;
  @override
  Future<String?> getToken() async {
    if (_runningFuture != null) return _runningFuture;
    _runningFuture = _getToken();
    _runningFuture!.whenComplete(() => _runningFuture = null);
    return _runningFuture;
  }

  Future<String?> _getToken() async {
    try {
      final tokenData = window.sessionStorage[tokenKey];
      if (tokenData != null) {
        final data = json.decode(tokenData);
        final expirationTime = DateTime.parse(data[1]);
        final token = data[0];
        if (DateTime.now().isBefore(expirationTime)) {
          return token; // Token is still valid
        } else {
          window.sessionStorage.remove(tokenKey); // Token expired
        }
      }
    } catch (e) {
      print(e);
    }

    final refreshToken = window.sessionStorage[refreshTokenKey];
    print(refreshToken);
    if (refreshToken != null) {
      return await _refreshToken(refreshToken);
    }

    final uri = Uri.parse(window.location.href);
    final authorizationCode = uri.queryParameters['code'];
    if (authorizationCode == null) {
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
      saveToken(tokenData['access_token'], tokenData['refresh_token']);
      return tokenData['access_token'] as String?;
    } else {
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
      window.sessionStorage
          .remove(refreshTokenKey); // Refresh token expired or invalid
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }

  void saveToken(String token, String refreshToken) {
    final expirationTime =
        DateTime.now().add(Duration(minutes: 30)); // Current time + 30 minutes
    final tokenData = [token, expirationTime.toString()];
    window.sessionStorage[tokenKey] = json.encode(tokenData);
    window.sessionStorage[refreshTokenKey] = refreshToken;
  }
}

AuthService getManager(String APIURL, String AUTHURL, String APPURL,
        String REALM, String CLIENT) =>
    WebAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT);
