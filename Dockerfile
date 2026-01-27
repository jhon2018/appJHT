# Dockerfile para Flutter Web en Render
FROM debian:stable-slim AS build

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Instalar Flutter (versión específica 3.32.8 como la tuya)
ARG FLUTTER_VERSION=3.32.8
RUN git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION} /usr/local/flutter

# Configurar PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Verificar instalación
RUN flutter doctor

# Configurar entorno de build
WORKDIR /app

# Copiar archivos del proyecto
COPY pubspec.yaml ./
COPY lib ./lib
COPY assets ./assets
COPY web ./web

# Instalar dependencias y hacer build
RUN flutter pub get
RUN flutter config --enable-web
RUN flutter build web \
    --release \
    --web-renderer html \
    --dart-define=API_BASE_URL=https://jht-transport-api.onrender.com \
    --no-tree-shake-icons

# Etapa final: Servir con Nginx
FROM nginx:alpine

# Copiar build de Flutter
COPY --from=build /app/build/web /usr/share/nginx/html

# Configuración Nginx optimizada para SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto 10000 (mismo que tu backend)
EXPOSE 10000

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]