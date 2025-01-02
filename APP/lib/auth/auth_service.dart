import 'unsupported_stub.dart'
    if (dart.library.io) 'desktop_auth_service.dart'
    if (dart.library.html) 'web_auth_service.dart';

abstract class AuthService {
  Future<String?> login(String redirectPath);
  Future<String?> getToken();
  Future<void> logout();
}

AuthService createAuthService(
    String APIURL, String AUTHURL, String APPURL, String REALM, String CLIENT) {
  return getManager(APIURL, AUTHURL, APPURL, REALM, CLIENT);
}
