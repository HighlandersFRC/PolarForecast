import 'package:flutter_appauth/flutter_appauth.dart';

import 'auth_service.dart';

class MobileAuthService implements AuthService {
  final String APIURL, AUTHURL, APPURL, REALM, CLIENT;
  const MobileAuthService(
      this.APIURL, this.AUTHURL, this.APPURL, this.REALM, this.CLIENT)
      : super();
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  @override
  Future<String?> login(String redirectPath) async {
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        CLIENT,
        'com.polar.forecast:/$redirectPath',
        issuer: '$AUTHURL/realms/$REALM',
        scopes: ['openid', 'profile', 'email'],
      ),
    );

    return result.accessToken;
  }

  @override
  Future<void> logout() async {
    // Implement logout for mobile
  }

  @override
  Future<String?> getToken() {
    // TODO: implement getToken
    throw UnimplementedError();
  }
}

AuthService getManager(String APIURL, String AUTHURL, String APPURL,
        String REALM, String CLIENT) =>
    MobileAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT);
