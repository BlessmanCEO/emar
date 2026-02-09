eMAR REST backend (Axum + Postgres).

Setup:

1) Copy env example:

```bash
cp .env.example .env
```

2) Run migrations (requires sqlx-cli):

```bash
cargo install sqlx-cli
sqlx database create
sqlx migrate run
```

3) Start server:

```bash
cargo run
```

Create a user:

```bash
cargo run --bin create_user -- --email nurse@example.com --password "ChangeMe123" --org-id "<org-uuid>" --roles nurse
```
