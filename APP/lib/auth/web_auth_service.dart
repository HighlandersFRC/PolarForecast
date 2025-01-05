import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';

import 'auth_service.dart';
import 'package:openid_client/openid_client_browser.dart';
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
      return await getToken();
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
  }

  @override
  Future<void> logout() async {
    // Remove token from localStorage
    window.localStorage.remove(tokenKey);

    // Optionally redirect to a logout page or refresh the application
    window.location.href =
        '$AUTHURL/realms/$REALM/protocol/openid-connect/logout?redirect_uri=$APPURL';
  }

  @override
  Future<String?> getToken() async {
    // Extract the authorization code from the URL
    if (window.sessionStorage['pf_token'] != null) {
      return window.sessionStorage['pf_token'];
    }
    final uri = Uri.parse(window.location.href);
    final authorizationCode = uri.queryParameters['code'];
    print('Authorization code: $authorizationCode');
    if (authorizationCode == null) {
      throw ('Authorization code: $authorizationCode');
    }

    // Keycloak token endpoint and client details
    var tokenEndpoint = '$AUTHURL/realms/$REALM/protocol/openid-connect/token';
    var clientId = CLIENT;
    var redirectUri = '$APPURL/event/2024code';

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
      print(tokenData);
      window.sessionStorage['pf_token'] = tokenData['access_token'];
      return tokenData['access_token'] as String?;
    } else {
      throw Exception('Failed to get token: ${response.body}');
    }
  }
}

AuthService getManager(String APIURL, String AUTHURL, String APPURL,
        String REALM, String CLIENT) =>
    WebAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT);
