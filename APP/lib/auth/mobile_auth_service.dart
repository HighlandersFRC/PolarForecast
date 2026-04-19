import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'auth_service.dart';
import 'mobile_auth_config.dart';

class MobileAuthService implements AuthService {
  final String APIURL, AUTHURL, APPURL, REALM, CLIENT;

  MobileAuthService(
    this.APIURL,
    this.AUTHURL,
    this.APPURL,
    this.REALM,
    this.CLIENT,
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AppLinks _appLinks = AppLinks();
  final Random _random = Random.secure();

  StreamSubscription<Uri>? _linkSubscription;
  Completer<String?>? _loginCompleter;
  final Set<String> _handledLinkKeys = <String>{};
  bool _didCheckInitialLink = false;

  static const String tokenKey = 'pf_token';
  static const String refreshTokenKey = 'pf_refresh_token';
  static const String pendingStateKey = 'pf_pending_auth_state';
  static const String pendingVerifierKey = 'pf_pending_auth_verifier';
  static const String pendingRedirectUriKey = 'pf_pending_auth_redirect_uri';

  static Future<String?>? _runningFuture;

  Uri get _issuerUri => Uri.parse('$AUTHURL/realms/$REALM');
  Uri get _tokenEndpoint =>
      Uri.parse('$AUTHURL/realms/$REALM/protocol/openid-connect/token');
  Uri get _authorizationEndpoint =>
      Uri.parse('$AUTHURL/realms/$REALM/protocol/openid-connect/auth');

  @override
  Future<String?> login(String redirectPath) async {
    await _ensureLinkListener();

    final existingToken = await getToken();
    if (existingToken != null) {
      return existingToken;
    }

    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      return _loginCompleter!.future;
    }

    final state = _randomUrlSafeValue(24);
    final codeVerifier = _randomUrlSafeValue(64);
    final redirectUri = mobileWebCallbackUri(APPURL).toString();
    final loginUri = _authorizationEndpoint.replace(
      queryParameters: {
        'client_id': CLIENT,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': 'openid profile email offline_access',
        'state': state,
        'code_challenge': _codeChallengeFor(codeVerifier),
        'code_challenge_method': 'S256',
      },
    );

    await _storage.write(key: pendingStateKey, value: state);
    await _storage.write(key: pendingVerifierKey, value: codeVerifier);
    await _storage.write(key: pendingRedirectUriKey, value: redirectUri);

    _loginCompleter = Completer<String?>();

    try {
      final didLaunch = await launchUrl(
        loginUri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
      if (!didLaunch) {
        await _clearPendingAuthorization();
        _loginCompleter = null;
        return '❌ Unable to open the in-app login page';
      }

      return await _loginCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () async {
          await _clearPendingAuthorization();
          _loginCompleter = null;
          return '⚠️ Login timed out before the app received a callback';
        },
      );
    } catch (e) {
      await _clearPendingAuthorization();
      _loginCompleter = null;
      return _formatError(e);
    }
  }

  @override
  Future<String?> getToken() async {
    await _ensureLinkListener();

    if (_runningFuture != null) return _runningFuture!;

    _runningFuture = _getToken();
    _runningFuture!.whenComplete(() => _runningFuture = null);

    return await _runningFuture!;
  }

  Future<String?> _getToken() async {
    try {
      final raw = await _storage.read(key: tokenKey);

      if (raw != null) {
        final data = json.decode(raw);
        final token = data[0] as String;
        final expiry = DateTime.parse(data[1] as String);

        if (!hasJwtSubjectClaim(token)) {
          await _storage.delete(key: tokenKey);
          return null;
        }

        if (DateTime.now().isBefore(expiry)) {
          return token;
        }

        await _storage.delete(key: tokenKey);
      }
    } catch (_) {}

    final refreshToken = await _storage.read(key: refreshTokenKey);

    if (refreshToken != null) {
      try {
        return await _refreshToken(refreshToken);
      } catch (_) {
        await _storage.delete(key: refreshTokenKey);
      }
    }

    return null;
  }

  Future<String?> _refreshToken(String refreshToken) async {
    final response = await http.post(
      _tokenEndpoint,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': CLIENT,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Refresh token failed: ${response.body}');
    }

    final tokenData = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = tokenData['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Refresh token response did not contain an access token');
    }
    if (!hasJwtSubjectClaim(accessToken)) {
      throw Exception(
          'Refresh token response returned a malformed access token');
    }

    await _saveToken(
      accessToken,
      tokenData['refresh_token'] as String?,
      _expiryFromTokenResponse(tokenData),
    );

    return accessToken;
  }

  Future<void> _saveToken(
    String token,
    String? refreshToken,
    DateTime? expiry,
  ) async {
    final expiration =
        expiry ?? DateTime.now().add(const Duration(minutes: 30));

    final encoded = json.encode([
      token,
      expiration.toIso8601String(),
    ]);

    await _storage.write(key: tokenKey, value: encoded);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(
        key: refreshTokenKey,
        value: refreshToken,
      );
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: refreshTokenKey);
    await _clearPendingAuthorization();
  }

  Future<void> _ensureLinkListener() async {
    if (_linkSubscription == null) {
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          unawaited(_handleIncomingUri(uri));
        },
        onError: (Object error) {
          if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
            _loginCompleter!.complete(_formatError(error));
          }
        },
      );
    }

    if (_didCheckInitialLink) {
      return;
    }

    _didCheckInitialLink = true;

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _handleIncomingUri(initialUri);
    }
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    if (!isMobileAppCallbackUri(uri)) {
      return;
    }

    final linkKey = uri.toString();
    if (_handledLinkKeys.contains(linkKey)) {
      return;
    }
    _handledLinkKeys.add(linkKey);

    final completer = _loginCompleter;
    if (completer != null && completer.isCompleted) {
      return;
    }

    try {
      final error = uri.queryParameters['error'];
      if (error != null) {
        final description = uri.queryParameters['error_description'] ?? error;
        await _clearPendingAuthorization();
        if (completer != null && !completer.isCompleted) {
          completer.complete('❌ Authentication failed: $description');
        }
        return;
      }

      final code = uri.queryParameters['code'];
      if (code == null || code.isEmpty) {
        await _clearPendingAuthorization();
        if (completer != null && !completer.isCompleted) {
          completer.complete(
            '❌ Authentication did not return an authorization code',
          );
        }
        return;
      }

      final expectedState = await _storage.read(key: pendingStateKey);
      final returnedState = uri.queryParameters['state'];
      if (expectedState == null || expectedState != returnedState) {
        await _clearPendingAuthorization();
        if (completer != null && !completer.isCompleted) {
          completer.complete('❌ Authentication state mismatch');
        }
        return;
      }

      final codeVerifier = await _storage.read(key: pendingVerifierKey);
      final redirectUri = await _storage.read(key: pendingRedirectUriKey) ??
          mobileWebCallbackUri(APPURL).toString();

      if (codeVerifier == null || codeVerifier.isEmpty) {
        await _clearPendingAuthorization();
        if (completer != null && !completer.isCompleted) {
          completer.complete(
            '❌ The app lost the PKCE verifier before token exchange',
          );
        }
        return;
      }

      final response = await http.post(
        _tokenEndpoint,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'client_id': CLIENT,
          'redirect_uri': redirectUri,
          'code_verifier': codeVerifier,
        },
      );

      if (response.statusCode != 200) {
        await _clearPendingAuthorization();
        if (completer != null && !completer.isCompleted) {
          completer.complete(_formatTokenExchangeError(response.body));
        }
        return;
      }

      final tokenData = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = tokenData['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        await _clearPendingAuthorization();
        if (completer != null && !completer.isCompleted) {
          completer.complete(
            '❌ Token exchange succeeded without an access token',
          );
        }
        return;
      }
      if (!hasJwtSubjectClaim(accessToken)) {
        await _clearPendingAuthorization();
        if (completer != null && !completer.isCompleted) {
          completer.complete(
            '❌ Authentication failed: access token was malformed',
          );
        }
        return;
      }

      await _saveToken(
        accessToken,
        tokenData['refresh_token'] as String?,
        _expiryFromTokenResponse(tokenData),
      );
      await _clearPendingAuthorization();
      unawaited(_closeInAppBrowserIfOpen());
      if (completer != null && !completer.isCompleted) {
        completer.complete(accessToken);
      }
    } catch (e) {
      await _clearPendingAuthorization();
      if (completer != null && !completer.isCompleted) {
        completer.complete(_formatError(e));
      }
    } finally {
      if (identical(_loginCompleter, completer)) {
        _loginCompleter = null;
      }
    }
  }

  Future<void> _clearPendingAuthorization() async {
    await _storage.delete(key: pendingStateKey);
    await _storage.delete(key: pendingVerifierKey);
    await _storage.delete(key: pendingRedirectUriKey);
  }

  Future<void> _closeInAppBrowserIfOpen() async {
    try {
      await closeInAppWebView();
    } catch (_) {}
  }

  String _randomUrlSafeValue(int byteCount) {
    final values = List<int>.generate(byteCount, (_) => _random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  String _codeChallengeFor(String verifier) {
    final bytes = sha256.convert(utf8.encode(verifier)).bytes;
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  DateTime? _expiryFromTokenResponse(Map<String, dynamic> tokenData) {
    final expiresIn = tokenData['expires_in'];
    if (expiresIn is int) {
      return DateTime.now().add(Duration(seconds: expiresIn));
    }
    if (expiresIn is String) {
      final parsed = int.tryParse(expiresIn);
      if (parsed != null) {
        return DateTime.now().add(Duration(seconds: parsed));
      }
    }
    return null;
  }

  String _formatTokenExchangeError(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error']?.toString();
      final description = decoded['error_description']?.toString();
      if (description != null && description.isNotEmpty) {
        return '❌ Authentication failed: $description';
      }
      if (error != null && error.isNotEmpty) {
        return '❌ Authentication failed: $error';
      }
    } catch (_) {}

    return _formatError(body);
  }

  String _formatError(dynamic error) {
    final message = error.toString();

    if (message.contains('User cancelled') ||
        message.contains('CANCELED') ||
        message.contains('cancelled')) {
      return '⚠️ Login cancelled by user';
    }

    if (message.contains('invalid_client')) {
      return '❌ Invalid client ID for $CLIENT';
    }

    if (message.contains('redirect_uri') || message.contains('redirect_url')) {
      return '❌ Redirect mismatch while using ${mobileWebCallbackUri(APPURL)}';
    }

    if (message.contains('Network') ||
        message.contains('SocketException') ||
        message.contains('Failed host lookup')) {
      return '🌐 Network error while contacting $_issuerUri';
    }

    if (message.contains('SSL') || message.contains('certificate')) {
      return '🔒 SSL or certificate error while contacting $_issuerUri';
    }

    return '🚨 Authentication failed: $message';
  }
}
