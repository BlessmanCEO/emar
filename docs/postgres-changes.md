# PostgreSQL Changes Log

## Overview

This project now runs two PostgreSQL instances with different responsibilities:

- `emar_postgres` (database: `emar`) for eMAR clinical/admin medication workflows.
- `careplanner-postgres` (database: `careplanner`) for Careplanner daily log notes.

---

## 1) eMAR Database (`emar_postgres`)

### Container and Access

- Container: `emar_postgres`
- Database: `emar`
- User: `postgres`
- Local port: `5432`

### Schema hardening performed

Primary files updated:

- `server/migrations/0001_init.sql`
- `server/migrations/0002_live_schema_upgrade.sql`

Key design changes:

- Expanded `residents` schema to cover resident payload fields (`nhs_number`, address columns, preferences, gp/source metadata).
- Updated resident identifiers to `TEXT` (`resident_id`) to support IDs like `SH-19541102`.
- Aligned medication schema with payload: `vendor_drug_id`, `raw_strength`, `dose_text`, `prn`, `instructions`, `is_controlled_drug`, source metadata.
- Added multi-table relational integrity with composite tenant keys:
  - `medication_orders -> residents`
  - `mar_entries -> residents` and `medication_orders`
  - `administrations -> residents`, `medication_orders`, `mar_entries`
- Added constraints for data quality:
  - status domain checks
  - date window checks
  - positive numeric checks
  - non-empty text checks
  - payload object shape checks on JSONB event payloads
- Added access-path indexes for fast reads/writes (org/date/status/source/fk join paths).
- Added extensions: `pgcrypto`, `pg_trgm`.

### Data ingested into `emar`

- Residents: `19`
- Medication orders: `51`
- MAR entries: `361`
- Administrations: `419`

Supporting ingestion scripts:

- `scripts/designate_resident_ids.py`
- `scripts/ingest_residents.py`
- `scripts/ingest_medications.py`
- `scripts/ingest_admin_events.py`

---

## 2) Careplanner Database (`careplanner-postgres`)

### Container and Access

- Container: `careplanner-postgres`
- Database: `careplanner`
- User: `postgres`
- Local port: `5433`

### Daily log schema created

Schema file:

- `careplanner/daily_log_schema.sql`

Objects created under schema `careplanner`:

- `careplanner.residents`
- `careplanner.staff_members`
- `careplanner.note_categories`
- `careplanner.daily_log_notes`

Design and performance features:

- Normalized dimensions (resident/staff/category) with surrogate identity PKs.
- High-fidelity note table including source IDs, ingest IDs, payload hash, and full `raw_payload JSONB`.
- Generated full-text search vector on `content` (`search_tsv`).
- Strong idempotency/duplicate protection using unique constraints:
  - `(source_vendor, source_external_id, note_version)`
  - `(source_vendor, note_id, note_version)`
  - `(source_vendor, ingest_id)`
- Index strategy for speed at scale:
  - resident timeline (`resident_pk, created_at_utc DESC`)
  - resident day views (`resident_pk, local_date, local_time`)
  - staff/category/source-time indexes
  - BRIN on `created_at_utc` for append-heavy growth
  - GIN FTS index (`search_tsv`)
  - GIN trigram index on note `content`
  - GIN JSONB index on `raw_payload`
- Added extension: `pg_trgm`.

### Daily log data ingested

All discovered daily-log files were loaded:

- `client/daily-log/ethel-beavers.json`
- `client/daily-log/stanley-hudson/*.json` (7 files)

Current counts in `careplanner`:

- Daily log notes: `155`
- Residents: `4`
- Staff members: `11`
- Note categories: `20`

Supporting ingestion script:

- `scripts/ingest_careplanner_daily_logs.py`

One-shot Stanley-specific SQL ingest script:

- `careplanner/ingest_stanley_hudson_all.sql`

---

## Useful Commands

### Access eMAR DB

```bash
docker exec -it emar_postgres psql -U postgres -d emar
```

### Access Careplanner DB

```bash
docker exec -it careplanner-postgres psql -U postgres -d careplanner
```

### Re-run careplanner schema

```bash
docker exec -i careplanner-postgres psql -U postgres -d careplanner -v ON_ERROR_STOP=1 < careplanner/daily_log_schema.sql
```

### Re-run all daily-log ingestion

```bash
python scripts/ingest_careplanner_daily_logs.py
```

### Re-run Stanley-only one-shot SQL

```bash
docker exec -i careplanner-postgres psql -U postgres -d careplanner -v ON_ERROR_STOP=1 < careplanner/ingest_stanley_hudson_all.sql
```
