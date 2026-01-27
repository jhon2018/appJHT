# Dockerfile para Flutter Web en Render - VERSIÓN CORREGIDA
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

# Configurar usuario sin privilegios para evitar problemas de permisos
RUN useradd -m -u 1000 flutteruser

# Instalar Flutter como usuario root primero, luego cambiar ownership
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter

# Configurar PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Configurar Flutter para no verificar gradle (no lo necesitamos para web)
RUN flutter config --no-analytics
RUN flutter config --enable-web

# Pre-descargar dependencias de Flutter sin verificar todo
RUN flutter precache --web

# Cambiar ownership para evitar problemas de permisos
RUN chown -R 1000:1000 /usr/local/flutter

# Cambiar a usuario no-root
USER flutteruser

# Configurar entorno de build
WORKDIR /app

# Copiar archivos del proyecto
COPY --chown=flutteruser:flutteruser pubspec.yaml ./
COPY --chown=flutteruser:flutteruser lib ./lib
COPY --chown=flutteruser:flutteruser assets ./assets
COPY --chown=flutteruser:flutteruser web ./web
COPY --chown=flutteruser:flutteruser .env ./

# Instalar dependencias
RUN flutter pub get

# Build para web (SOLO web, sin verificar Android/iOS)
RUN flutter build web \
    --release \
    --web-renderer html \
    --dart-define=API_BASE_URL=https://jht-transport-api.onrender.com \
    --no-tree-shake-icons \
    --verbose

# Etapa final: Servir con Nginx
FROM nginx:alpine

# Copiar build de Flutter
COPY --from=build /app/build/web /usr/share/nginx/html

# Configuración Nginx optimizada para SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto 10000
EXPOSE 10000

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]