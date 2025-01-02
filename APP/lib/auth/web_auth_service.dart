import 'auth_service.dart';
import 'package:openid_client/openid_client_browser.dart';
import 'dart:html';

class WebAuthService implements AuthService {
  final String APIURL, AUTHURL, APPURL, REALM, CLIENT;
  const WebAuthService(
      this.APIURL, this.AUTHURL, this.APPURL, this.REALM, this.CLIENT)
      : super();
  @override
  Future<String?> login(String redirectPath) async {
    final uri = Uri.parse('$AUTHURL/realms/$REALM');
    final client = Client(
      await Issuer.discover(uri),
      CLIENT,
    );
    var f = new Flow.authorizationCode(client,
        redirectUri: Uri.parse('$APPURL/$redirectPath'));
    try {
      var url = Uri.parse(window.location.href);
      var c = await f.callback(url.queryParameters);
      return (await c.getTokenResponse()).accessToken;
    } catch (e) {
      print(e);
      window.location.href = f.authenticationUri.toString();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    // Implement logout for web
  }

  @override
  Future<String?> getToken() async {
    final uri = Uri.parse('$AUTHURL/realms/$REALM');
    final client = Client(
      await Issuer.discover(uri),
      CLIENT,
    );
    var f = new Flow.authorizationCode(client);
    try {
      var url = Uri.parse(window.location.href);
      var c = await f.callback(url.queryParameters);
      return (await c.getTokenResponse()).accessToken;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

AuthService getManager(String APIURL, String AUTHURL, String APPURL,
        String REALM, String CLIENT) =>
    WebAuthService(APIURL, AUTHURL, APPURL, REALM, CLIENT);
