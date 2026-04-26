FROM debian:bookworm-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git --depth 1 -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

RUN flutter precache --web

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

RUN dart run build_runner build --delete-conflicting-outputs

RUN flutter build web --release \
    --dart-define=PF_API_ENDPOINT=http://127.0.0.1:8000 \
    --dart-define=PF_KEYCLOAK_LOGIN_IP=http://localhost:8080 \
    --dart-define=KEYCLOAK_REALM=polarforecast \
    --dart-define=KEYCLOAK_APP_CLIENT_ID=polarforecast-gui \
    --dart-define=APP_DOMAIN=http://localhost:3000 \
    --dart-define=APP_TBA_KEY=NtlbulTTKEs3Gy7deIFd5j4WpF9qmdNT4CL7ee3tWgjTPwvQhTWxmwIeY9xYlan5

FROM nginx:stable
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 3000