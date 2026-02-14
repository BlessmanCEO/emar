# Build stage
FROM ghcr.io/cirruslabs/flutter:3.38.9 as builder

WORKDIR /app

# Copy pubspec and fetch dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy source code
COPY . .

# Generate Drift code
RUN dart run build_runner build -d

# Generate FRB bindings
RUN flutter_rust_bridge_codegen generate \
  --rust-root ../rust_core \
  -r crate::api \
  -d lib \
  -c ios/Runner/bridge_generated.h || true

# Build the web app (disable PWA caching for faster UI iteration)
RUN flutter build web --pwa-strategy=none

# Final stage - serve with nginx
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
