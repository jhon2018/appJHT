FROM ubuntu:22.04 AS build

RUN apt-get update && apt-get install -y curl git unzip xz-utils && rm -rf /var/lib/apt/lists/*

RUN groupadd -r flutter && useradd -r -g flutter flutteruser
USER flutteruser
WORKDIR /home/flutteruser

RUN git clone https://github.com/flutter/flutter.git -b stable ./flutter

ENV PATH="/home/flutteruser/flutter/bin:${PATH}"
ENV FLUTTER_ROOT="/home/flutteruser/flutter"

RUN ./flutter/bin/flutter config --enable-web
RUN ./flutter/bin/flutter config --no-enable-android
RUN ./flutter/bin/flutter config --no-enable-ios

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./

RUN ./flutter/bin/flutter precache --web --no-android --no-ios --no-universal
RUN ./flutter/bin/flutter pub get

COPY lib/ ./lib/
COPY web/ ./web/
RUN mkdir -p assets || true

RUN ./flutter/bin/flutter build web --release --web-renderer html --dart-define=API_BASE_URL=https://jht-transport-api.onrender.com

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 10000
CMD ["nginx", "-g", "daemon off;"]