import 'dart:io';

import 'package:scouting_app/auth/mobile_auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_service.dart';

class DesktopAuthService implements AuthService {
  final String APIURL, AUTHURL, APPURL, REALM, CLIENT;
  const DesktopAuthService(
      this.APIURL, this.AUTHURL, this.APPURL, this.REALM, this.CLIENT)
      : super();
  @override
  Future<String?> login(String redirectPath) async {
    final authUrl = Uri.parse(
        'http://pfkeycloak:8080/realms/your-realm/protocol/openid-connect/auth'
        '?client_id=your-client-id&response_type=code&redirect_uri=http://localhost:8080');

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
      // Manually handle code exchange here
    }

    return null; // Replace with the actual access token after code exchange
  }

  @override
  Future<void> logout() async {
    // Implement logout for desktop
  }

  @override
  Future<String?> getToken() {
    throw UnimplementedError();
  }
}

AuthService getManager(String APIURL, String AUTHURL, String APPURL,
        String REALM, String CLIENT) =>
    Platform.isWindows || Platform.isLinux
        ? DesktopAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT)
        : MobileAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT);
