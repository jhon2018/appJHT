FROM ubuntu:22.04 AS build

ENV TAR_OPTIONS=--no-same-owner

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

RUN flutter config --enable-web

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY lib/ lib/
COPY web/ web/
COPY assets/ assets/

RUN VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}') && \
    APP_VER=$(echo $VERSION | cut -d'+' -f1) && \
    BUILD_NUM=$(echo $VERSION | cut -d'+' -f2) && \
    flutter build web --release \
    --dart-define=APP_VERSION=$APP_VER \
    --dart-define=API_BASE_URL=https://jht-transport-api.onrender.com && \
    echo "{\"version\": \"$APP_VER\", \"buildNumber\": \"$BUILD_NUM\"}" > build/web/version.json

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 10000
CMD ["nginx", "-g", "daemon off;"]
