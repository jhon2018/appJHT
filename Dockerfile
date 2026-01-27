FROM ubuntu:22.04 AS build 
 
RUN apt-get update && apt-get install -y curl git unzip xz-utils && rm -rf /var/lib/apt/lists/* 
 
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter 
ENV PATH="/flutter/bin:${PATH}" 
 
RUN flutter config --enable-web 
RUN flutter config --no-enable-android 
 
WORKDIR /app 
COPY pubspec.yaml pubspec.lock ./ 
RUN flutter pub get 
 
COPY lib/ ./lib/ 
COPY web/ ./web/ 
 
RUN flutter build web --release --web-renderer html --dart-define=API_BASE_URL=https://jht-transport-api.onrender.com 
 
FROM nginx:alpine 
COPY --from=build /app/build/web /usr/share/nginx/html 
COPY nginx.conf /etc/nginx/conf.d/default.conf 
EXPOSE 10000 
CMD ["nginx", "-g", "daemon off;"] 
