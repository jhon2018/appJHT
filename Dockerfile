# Dockerfile para Flutter Web ONLY
FROM ubuntu:22.04 AS build

# Instalar mínimo
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Clonar Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter

# PATH
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# CONFIGURAR SOLO WEB (CRÍTICO)
WORKDIR /flutter
RUN ./bin/flutter config --enable-web
RUN ./bin/flutter config --no-enable-android
RUN ./bin/flutter config --no-enable-ios
RUN ./bin/flutter config --no-enable-linux
RUN ./bin/flutter config --no-enable-windows
RUN ./bin/flutter config --no-enable-macos

# Precache solo web
RUN ./bin/flutter precache --web

# Trabajar en app
WORKDIR /app

# Copiar pubspec primero (para cache de dependencias)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiar código (Dockerignore evita android/ios/)
COPY lib/ ./lib/
COPY web/ ./web/
COPY assets/ ./assets/ 2>/dev/null || true

# Build web
RUN flutter build web \
    --release \
    --web-renderer html \
    --dart-define=API_BASE_URL=https://jht-transport-api.onrender.com \
    --no-tree-shake-icons

# Etapa final
FROM nginx:alpine

# Copiar build
COPY --from=build /app/build/web /usr/share/nginx/html

# Config Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 10000

CMD ["nginx", "-g", "daemon off;"]