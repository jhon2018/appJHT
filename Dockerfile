# Dockerfile para Flutter Web
FROM ubuntu:22.04 AS build

RUN apt-get update && apt-get install -y curl git unzip xz-utils ca-certificates && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

WORKDIR /flutter
RUN ./bin/flutter config --enable-web
RUN ./bin/flutter config --no-enable-android
RUN ./bin/flutter config --no-enable-ios
RUN ./bin/flutter config --no-enable-macos
RUN ./bin/flutter config --no-enable-windows
RUN ./bin/flutter config --no-enable-linux

RUN ./bin/flutter precache --web

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY lib/ ./lib/
COPY web/ ./web/
COPY assets/ ./assets/ 2>/dev/null || true

RUN flutter build web --release --web-renderer html --dart-define=API_BASE_URL=https://jht-transport-api.onrender.com --no-tree-shake-icons

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 10000
CMD ["nginx", "-g", "daemon off;"]