FROM rust:alpine AS builder

WORKDIR /app

# Install necessary build dependencies
RUN apk add --no-cache musl-dev openssl-dev pkgconfig libpq-dev curl

# Copy Cargo files
COPY Cargo.toml ./

# Create dummy src for cargo check
RUN mkdir -p src && echo "fn main() {}" > src/main.rs

# Build dependencies (lock file will be regenerated)
RUN cargo fetch

# Copy source and build
COPY src ./src
COPY migrations ./migrations

RUN cargo build --release

# Final image
FROM alpine:3.19

RUN apk add --no-cache libpq openssl curl

WORKDIR /app

COPY --from=builder /app/target/release/server /usr/local/bin/

# Ensure migrations are available
COPY migrations ./migrations

EXPOSE 8080

CMD ["/usr/local/bin/server"]
