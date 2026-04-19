#!/bin/bash
# iOS IPA build script - Run on macOS only with Xcode installed

flutter build ipa \
  --dart-define=PF_API_ENDPOINT=https://highlanderscouting.azurewebsites.net/ \
  --dart-define=PF_KEYCLOAK_LOGIN_IP=https://highlanderscoutingkc.azurewebsites.net \
  --dart-define=KEYCLOAK_REALM=polarforecast \
  --dart-define=KEYCLOAK_APP_CLIENT_ID=polarforecast-gui \
  --dart-define=APP_DOMAIN=https://polarforecast-frc.com/ \
  --dart-define=APP_TBA_KEY=NtlbulTTKEs3Gy7deIFd5j4WpF9qmdNT4CL7ee3tWgjTPwvQhTWxmwIeY9xYlan5
