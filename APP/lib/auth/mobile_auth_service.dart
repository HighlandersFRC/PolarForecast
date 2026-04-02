import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

class MobileAuthService implements AuthService {
  final String APIURL, AUTHURL, APPURL, REALM, CLIENT;

  const MobileAuthService(
    this.APIURL,
    this.AUTHURL,
    this.APPURL,
    this.REALM,
    this.CLIENT,
  );

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String tokenKey = 'pf_token';
  static const String refreshTokenKey = 'pf_refresh_token';

  static Future<String?>? _runningFuture;

  // ---------------------------
  // LOGIN
  // ---------------------------
  @override
  Future<String?> login(String redirectPath) async {
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        CLIENT,
        'com.polarforecastfrc.app://callback',
        issuer: '$AUTHURL/realms/$REALM',
        scopes: [
          'openid',
          'profile',
          'email',
          'offline_access',
        ],
      ),
    );

    if (result.accessToken != null) {
      await _saveToken(
        result.accessToken!,
        result.refreshToken,
        result.accessTokenExpirationDateTime,
      );
    }

    return result.accessToken;
  }

  // ---------------------------
  // GET TOKEN (MAIN ENTRY)
  // ---------------------------
  @override
  Future<String?> getToken() async {
    if (_runningFuture != null) return _runningFuture!;
    _runningFuture = _getToken();
    _runningFuture!.whenComplete(() => _runningFuture = null);
    return _runningFuture!;
  }

  // ---------------------------
  // INTERNAL TOKEN LOGIC
  // ---------------------------
  Future<String?> _getToken() async {
    try {
      final raw = await _storage.read(key: tokenKey);

      if (raw != null) {
        final data = json.decode(raw);
        final token = data[0];
        final expiry = DateTime.parse(data[1]);

        // ✅ still valid
        if (DateTime.now().isBefore(expiry)) {
          return token;
        }

        // ❌ expired
        await _storage.delete(key: tokenKey);
      }
    } catch (_) {}

    // 🔄 try refresh token
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

  // ---------------------------
  // REFRESH TOKEN
  // ---------------------------
  Future<String?> _refreshToken(String refreshToken) async {
    final result = await _appAuth.token(
      TokenRequest(
        CLIENT,
        'com.polarforecastfrc.app://callback',
        issuer: '$AUTHURL/realms/$REALM',
        refreshToken: refreshToken,
      ),
    );

    if (result.accessToken != null) {
      await _saveToken(
        result.accessToken!,
        result.refreshToken,
        result.accessTokenExpirationDateTime,
      );
      return result.accessToken;
    }

    throw Exception('Refresh token failed');
  }

  // ---------------------------
  // SAVE TOKEN (LIKE YOUR WEB VERSION)
  // ---------------------------
  Future<void> _saveToken(
    String token,
    String? refreshToken,
    DateTime? expiry,
  ) async {
    final expiration = expiry ??
        DateTime.now().add(
          const Duration(minutes: 30),
        );

    final encoded = json.encode([
      token,
      expiration.toIso8601String(),
    ]);

    await _storage.write(key: tokenKey, value: encoded);

    if (refreshToken != null) {
      await _storage.write(
        key: refreshTokenKey,
        value: refreshToken,
      );
    }
  }

  // ---------------------------
  // LOGOUT
  // ---------------------------
  @override
  Future<void> logout() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: refreshTokenKey);
  }
}
