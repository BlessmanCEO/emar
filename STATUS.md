# eMAR REST-only Plan Status

## What is done

- **Server (Axum + Postgres)**
  - REST endpoints: `/auth/login`, `/auth/refresh`, `/sync/push`, `/sync/pull`, `/bootstrap`.
  - JWT auth + refresh tokens.
  - Event store schema + projections tables migration (`audit_events`, `users`, `devices`, `refresh_tokens`, `residents`, `medication_orders`, `mar_entries`, `administrations`).
  - CLI to create users with Argon2 password hashing.
  - Dockerized with PostgreSQL and backend containers.

- **Rust core (shared logic)**
  - Core functions: normalize medication name, parse dose, expand schedule, normalize reason codes, generate event ID.
  - FRB API module and codegen wired.

- **Mobile (Flutter + Drift)**
  - Drift schema with `outbox_events`, `outbox_errors`, `sync_state` and read models.
  - Sync engine: push outbox, pull events, apply projections.
  - Bootstrap client + snapshot apply.
  - Demo UI to enqueue events, sync, bootstrap, and test Rust core.
  - eMAR screen with resident list + MAR panel + responsive layout.

## Current warnings/notes

- FRB on web needs cross-origin headers if you want shared buffers. Current warning is expected on Chrome.
- `rust_core` uses `#![allow(unexpected_cfgs)]` to silence macro cfg warnings.
- `AuthUser` fields `user_id` and `roles` are unused for now; warning suppressed.

## Docker Compose Services

The project now includes Docker Compose for easy development:

```yaml
services:
  postgres:    # PostgreSQL database (port 5432)
  backend:     # Rust Axum API (port 8080)
```

### Start services:
```bash
docker compose up -d
```

### Run migrations:
```bash
export DATABASE_URL="postgres://postgres:postgres@localhost:5432/emar"
cd server
sqlx migrate run
```

### Create a user:
```bash
cd server
cargo run --bin create_user -- --email nurse@example.com --password "ChangeMe123" --org-id "550e8400-e29b-41d4-a716-446655440000" --roles nurse
```

### Test login:
```bash
curl -s http://localhost:8080/auth/login -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"nurse@example.com","password":"ChangeMe123"}'
```

## What still needs doing

### Functional gaps to implement

- **Server-side projections**
  - Apply events to projections (`residents`, `medication_orders`, `mar_entries`, `administrations`) on write or via a worker.

- **Validation rules**
  - Enforce domain validations: discontinued orders, time bounds, reason codes, authorization by role/site.

- **Bootstrap content**
  - `/bootstrap` currently returns empty lists; needs real snapshot data from projections.

### Mobile integration

- Wire Rust core into actual event creation (normalize medication names before writing to outbox).
- Hook eMAR UI to real Drift data (read from projections instead of mock data).
- Real login screen with token storage.
- MAR detail + administration capture flow.

### Cleanup

- Remove leftover `flutter_emar/` directory once it is no longer locked by any process.

## Commands reference

### Server (local)

```
cd server
cp .env.example .env
sqlx database create
sqlx migrate run
cargo run
```

### Mobile

```
cd mobile
flutter pub get
dart run build_runner build -d
flutter_rust_bridge_codegen generate --rust-root ../rust_core -r crate::api -d lib -c ios/Runner/bridge_generated.h
flutter run
```

### Docker Compose

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```
