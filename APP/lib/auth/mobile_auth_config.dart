import 'dart:convert';

Uri normalizeHostedAppUri(String appUrl) {
  final trimmed = appUrl.trim();
  if (trimmed.isEmpty) {
    return Uri.parse('https://polarforecast-frc.com/');
  }

  final parsed = Uri.parse(trimmed);

  if (parsed.host == 'highlanderscoutingkc.azurewebsites.net') {
    return Uri.parse('https://polarforecast-frc.com/');
  }

  return parsed;
}

Uri mobileWebCallbackUri(String appUrl) {
  final hostedAppUri = normalizeHostedAppUri(appUrl);
  return hostedAppUri.replace(
    path: '/auth/mobile-callback',
    query: null,
    fragment: null,
  );
}

Uri mobileAppCallbackUri({Map<String, String>? queryParameters}) {
  return Uri(
    scheme: 'com.polarforecastfrc.app',
    host: 'callback',
    queryParameters: queryParameters == null || queryParameters.isEmpty
        ? null
        : queryParameters,
  );
}

bool isMobileAppCallbackUri(Uri uri) {
  if (uri.scheme != 'com.polarforecastfrc.app') {
    return false;
  }

  // Accept both URI styles for robustness:
  // com.polarforecastfrc.app://callback?...
  // com.polarforecastfrc.app:/callback?...
  return uri.host == 'callback' || uri.path == '/callback';
}

Map<String, dynamic>? decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    return null;
  }

  try {
    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payload = jsonDecode(decoded);
    if (payload is Map<String, dynamic>) {
      return payload;
    }
  } catch (_) {}

  return null;
}

bool hasJwtSubjectClaim(String token) {
  final payload = decodeJwtPayload(token);
  if (payload == null) {
    return false;
  }
  final sub = payload['sub'];
  return sub is String && sub.isNotEmpty;
}
