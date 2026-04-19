import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scouting_app/api_service.dart';
import 'package:scouting_app/auth/auth_service.dart';
import 'package:scouting_app/auth/mobile_auth_config.dart';

class FakeAuthService implements AuthService {
  String? currentToken;
  int logoutCount = 0;

  FakeAuthService(this.currentToken);

  @override
  Future<String?> getToken() async => currentToken;

  @override
  Future<String?> login(String redirectPath) async => currentToken;

  @override
  Future<void> logout() async {
    logoutCount++;
    currentToken = null;
  }
}

ApiService buildService({
  required AuthService authService,
  required http.Client client,
}) {
  return ApiService(
    APIURL: 'https://api.example.com',
    AUTHURL: 'https://auth.example.com',
    APPURL: 'https://app.example.com',
    REALM: 'polarforecast',
    TBA_KEY: 'tba-key',
    CLIENT: 'polarforecast-gui',
    authService: authService,
    cacheDuration: const Duration(minutes: 2),
    httpClient: client,
  );
}

String buildJwt(Map<String, dynamic> payload) {
  String encode(Map<String, dynamic> data) {
    return base64Url.encode(utf8.encode(jsonEncode(data))).replaceAll('=', '');
  }

  final header = encode({'alg': 'none', 'typ': 'JWT'});
  final body = encode(payload);
  return '$header.$body.signature';
}

void main() {
  group('ApiService auth recovery', () {
    test('clears token and retries once without token on auth-failure payload',
        () async {
      final authService = FakeAuthService('header.payload.signature');
      final requestHeaders = <Map<String, String>>[];
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        requestHeaders.add(Map<String, String>.from(request.headers));
        if (requestCount == 1) {
          return http.Response(
            jsonEncode({'detail': 'token introspect failed'}),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'data': [
              {
                'key': '2026casj',
                'display': '2026 Test Event',
                'page': '/event/2026casj',
                'start': '2026-03-01',
                'end': '2026-03-03',
              }
            ]
          }),
          200,
        );
      });
      final service = buildService(authService: authService, client: client);

      final tournaments = await service.fetchTournaments();

      expect(tournaments, isNotEmpty);
      expect(authService.logoutCount, 1);
      expect(requestCount, 2);
      expect(requestHeaders.first['token'], 'header.payload.signature');
      expect(requestHeaders.last.containsKey('token'), isFalse);
    });

    test('throws AuthRecoveryException when retry also fails', () async {
      final authService = FakeAuthService('header.payload.signature');
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        if (requestCount.isOdd) {
          return http.Response(
            jsonEncode({'detail': 'token invalid'}),
            200,
          );
        }
        return http.Response('server failed', 500);
      });
      final service = buildService(authService: authService, client: client);

      await expectLater(
        service.fetchTournaments(),
        throwsA(isA<AuthRecoveryException>()),
      );
      expect(authService.logoutCount, 1);
      expect(requestCount, 2);

      await expectLater(
        service.fetchTournaments(),
        throwsA(isA<AuthRecoveryException>()),
      );
      expect(requestCount, 3);
    });

    test('returns and caches valid 200 payload normally', () async {
      final authService = FakeAuthService('header.payload.signature');
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return http.Response(jsonEncode({'ok': true}), 200);
      });
      final service = buildService(authService: authService, client: client);

      final first = await service.fetchTeamStats(2026, 'casj', 'frc1');
      final second = await service.fetchTeamStats(2026, 'casj', 'frc1');

      expect(first['ok'], true);
      expect(second['ok'], true);
      expect(requestCount, 1);
      expect(authService.logoutCount, 0);
    });

    test('recovers from 401 by retrying once without token', () async {
      final authService = FakeAuthService('header.payload.signature');
      final requestHeaders = <Map<String, String>>[];
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        requestHeaders.add(Map<String, String>.from(request.headers));
        if (requestCount == 1) {
          return http.Response('unauthorized', 401);
        }
        return http.Response(
          jsonEncode({
            'data': [
              {
                'key': '2026casj',
                'display': '2026 Test Event',
                'page': '/event/2026casj',
                'start': '2026-03-01',
                'end': '2026-03-03',
              }
            ]
          }),
          200,
        );
      });
      final service = buildService(authService: authService, client: client);

      final tournaments = await service.fetchTournaments();

      expect(tournaments, isNotEmpty);
      expect(authService.logoutCount, 1);
      expect(requestCount, 2);
      expect(requestHeaders.first['token'], 'header.payload.signature');
      expect(requestHeaders.last.containsKey('token'), isFalse);
    });

    test('keeps existing non-200 failure behavior', () async {
      final authService = FakeAuthService('header.payload.signature');
      final client = MockClient((request) async {
        return http.Response('bad request', 400);
      });
      final service = buildService(authService: authService, client: client);

      await expectLater(
        service.fetchTeamStats(2026, 'casj', 'frc1'),
        throwsA(isA<Exception>()),
      );
      expect(authService.logoutCount, 0);
    });
  });

  group('JWT payload sanity helpers', () {
    test('accepts token with sub claim', () {
      final token = buildJwt({'sub': 'user-123', 'name': 'Scout'});
      expect(hasJwtSubjectClaim(token), isTrue);
    });

    test('rejects token without sub claim', () {
      final token = buildJwt({'name': 'Scout'});
      expect(hasJwtSubjectClaim(token), isFalse);
    });

    test('rejects malformed token', () {
      expect(hasJwtSubjectClaim('not-a-jwt'), isFalse);
      expect(decodeJwtPayload('still-not-a-jwt'), isNull);
    });
  });
}
