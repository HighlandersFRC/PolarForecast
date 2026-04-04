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
  static String? lastError; // Store last error for UI display

  static Future<String?>? _runningFuture;

  // ---------------------------
  // LOGIN
  // ---------------------------
  @override
  Future<String?> login(String redirectPath) async {
    print('🔐 Starting mobile login process...');
    print('🔗 AUTHURL: $AUTHURL');
    print('🏰 REALM: $REALM');
    print('👤 CLIENT: $CLIENT');
    lastError = null; // Clear previous error

    try {
      print('📡 Calling authorizeAndExchangeCode...');
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

      print('📋 Auth result received');
      print('🔑 Access token present: ${result.accessToken != null}');
      print('🔄 Refresh token present: ${result.refreshToken != null}');
      print('⏰ Token expiry: ${result.accessTokenExpirationDateTime}');

      if (result.accessToken != null) {
        print('✅ Login successful, saving token...');
        await _saveToken(
          result.accessToken!,
          result.refreshToken,
          result.accessTokenExpirationDateTime,
        );
        print('💾 Token saved successfully');
        return result.accessToken;
      } else {
        lastError = 'No access token received from OAuth provider';
        print('❌ Login failed: no access token received');
        return null;
      }
    } catch (e) {
      print('🚨 Login exception: $e');
      print('🚨 Exception type: ${e.runtimeType}');
      lastError = 'Login failed: $e';
      // Note: AuthorizationException details would be here if needed
      return null;
    }
  }

  // ---------------------------
  // GET TOKEN (MAIN ENTRY)
  // ---------------------------
  @override
  Future<String?> getToken() async {
    print('🔍 getToken() called');
    if (_runningFuture != null) {
      print('⏳ Returning existing future');
      return _runningFuture!;
    }
    _runningFuture = _getToken();
    _runningFuture!.whenComplete(() => _runningFuture = null);
    final result = await _runningFuture!;
    print(
        '🔍 getToken() returning: ${result != null ? "token present" : "null"}');
    return result;
  }

  // ---------------------------
  // INTERNAL TOKEN LOGIC
  // ---------------------------
  Future<String?> _getToken() async {
    try {
      print('🔍 Checking for stored token...');
      final raw = await _storage.read(key: tokenKey);
      print('📄 Raw token data: $raw');

      if (raw != null) {
        final data = json.decode(raw);
        print('📋 Decoded token data: $data');
        final token = data[0];
        final expiry = DateTime.parse(data[1]);
        print('🕒 Token expiry: $expiry, Current time: ${DateTime.now()}');

        if (DateTime.now().isBefore(expiry)) {
          print('✅ Valid token found: ${token.substring(0, 20)}...');
          return token;
        } else {
          print('⏰ Token expired, deleting...');
          await _storage.delete(key: tokenKey);
        }
      } else {
        print('📭 No stored token found');
      }
    } catch (e) {
      print('🚨 Error reading token: $e');
      print('🚨 Error type: ${e.runtimeType}');
    }

    // Try refresh token
    final refreshToken = await _storage.read(key: refreshTokenKey);
    if (refreshToken != null) {
      print('🔄 Trying to refresh token...');
      try {
        final newToken = await _refreshToken(refreshToken);
        print('✅ Token refreshed successfully');
        return newToken;
      } catch (e) {
        print('🚨 Token refresh failed: $e');
        await _storage.delete(key: refreshTokenKey);
      }
    } else {
      print('📭 No refresh token found');
    }

    print('❌ No valid token available');
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

    print('💾 Saving token with expiry: $expiration');
    print('💾 Encoded token data: $encoded');
    print('💾 Token length: ${token.length}');
    await _storage.write(key: tokenKey, value: encoded);
    print('💾 Token saved to storage');

    if (refreshToken != null) {
      print('💾 Saving refresh token (length: ${refreshToken.length})');
      await _storage.write(
        key: refreshTokenKey,
        value: refreshToken,
      );
      print('💾 Refresh token saved');
    } else {
      print('💾 No refresh token to save');
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
