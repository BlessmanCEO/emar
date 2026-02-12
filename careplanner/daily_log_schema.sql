BEGIN;

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE SCHEMA IF NOT EXISTS careplanner;

CREATE TABLE IF NOT EXISTS careplanner.residents (
    resident_pk BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    resident_external_id TEXT NOT NULL,
    resident_display_name TEXT NOT NULL,
    source_vendor TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT residents_external_id_not_blank_chk CHECK (btrim(resident_external_id) <> ''),
    CONSTRAINT residents_display_name_not_blank_chk CHECK (btrim(resident_display_name) <> ''),
    CONSTRAINT residents_source_vendor_not_blank_chk CHECK (btrim(source_vendor) <> ''),
    CONSTRAINT residents_source_external_uidx UNIQUE (source_vendor, resident_external_id)
);

CREATE INDEX IF NOT EXISTS residents_display_name_trgm_idx
    ON careplanner.residents USING GIN (resident_display_name gin_trgm_ops);

CREATE TABLE IF NOT EXISTS careplanner.staff_members (
    staff_pk BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    staff_external_id TEXT NOT NULL,
    staff_display_name TEXT NOT NULL,
    source_vendor TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT staff_external_id_not_blank_chk CHECK (btrim(staff_external_id) <> ''),
    CONSTRAINT staff_display_name_not_blank_chk CHECK (btrim(staff_display_name) <> ''),
    CONSTRAINT staff_source_vendor_not_blank_chk CHECK (btrim(source_vendor) <> ''),
    CONSTRAINT staff_source_external_uidx UNIQUE (source_vendor, staff_external_id)
);

CREATE INDEX IF NOT EXISTS staff_display_name_trgm_idx
    ON careplanner.staff_members USING GIN (staff_display_name gin_trgm_ops);

CREATE TABLE IF NOT EXISTS careplanner.note_categories (
    category_pk BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_vendor TEXT NOT NULL,
    category_name TEXT NOT NULL,
    category_name_normalized TEXT GENERATED ALWAYS AS (LOWER(btrim(category_name))) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT note_categories_name_not_blank_chk CHECK (btrim(category_name) <> ''),
    CONSTRAINT note_categories_source_vendor_not_blank_chk CHECK (btrim(source_vendor) <> ''),
    CONSTRAINT note_categories_source_name_uidx UNIQUE (source_vendor, category_name_normalized)
);

CREATE TABLE IF NOT EXISTS careplanner.daily_log_notes (
    daily_log_pk BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    note_id TEXT NOT NULL,
    note_version INTEGER NOT NULL DEFAULT 1,
    resident_pk BIGINT NOT NULL REFERENCES careplanner.residents(resident_pk) ON DELETE RESTRICT,
    staff_pk BIGINT REFERENCES careplanner.staff_members(staff_pk) ON DELETE SET NULL,
    category_pk BIGINT REFERENCES careplanner.note_categories(category_pk) ON DELETE SET NULL,
    content TEXT NOT NULL,
    search_tsv TSVECTOR GENERATED ALWAYS AS (to_tsvector('english', content)) STORED,
    created_at_utc TIMESTAMPTZ NOT NULL,
    event_timestamp TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ NOT NULL,
    normalized_at TIMESTAMPTZ,
    local_date DATE NOT NULL,
    local_time TIME NOT NULL,
    source_vendor TEXT NOT NULL,
    source_external_id TEXT NOT NULL,
    ingest_id TEXT NOT NULL,
    raw_payload_hash TEXT NOT NULL,
    raw_payload JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT daily_log_note_id_not_blank_chk CHECK (btrim(note_id) <> ''),
    CONSTRAINT daily_log_source_vendor_not_blank_chk CHECK (btrim(source_vendor) <> ''),
    CONSTRAINT daily_log_source_external_id_not_blank_chk CHECK (btrim(source_external_id) <> ''),
    CONSTRAINT daily_log_ingest_id_not_blank_chk CHECK (btrim(ingest_id) <> ''),
    CONSTRAINT daily_log_payload_hash_not_blank_chk CHECK (btrim(raw_payload_hash) <> ''),
    CONSTRAINT daily_log_content_not_blank_chk CHECK (btrim(content) <> ''),
    CONSTRAINT daily_log_note_version_chk CHECK (note_version > 0),
    CONSTRAINT daily_log_payload_object_chk CHECK (jsonb_typeof(raw_payload) = 'object'),
    CONSTRAINT daily_log_received_after_event_chk CHECK (received_at >= event_timestamp),
    CONSTRAINT daily_log_source_external_version_uidx UNIQUE (source_vendor, source_external_id, note_version),
    CONSTRAINT daily_log_note_version_uidx UNIQUE (source_vendor, note_id, note_version),
    CONSTRAINT daily_log_ingest_uidx UNIQUE (source_vendor, ingest_id)
);

CREATE INDEX IF NOT EXISTS daily_log_resident_created_idx
    ON careplanner.daily_log_notes (resident_pk, created_at_utc DESC)
    INCLUDE (category_pk, staff_pk, note_id, note_version);

CREATE INDEX IF NOT EXISTS daily_log_resident_local_date_idx
    ON careplanner.daily_log_notes (resident_pk, local_date, local_time);

CREATE INDEX IF NOT EXISTS daily_log_staff_created_idx
    ON careplanner.daily_log_notes (staff_pk, created_at_utc DESC);

CREATE INDEX IF NOT EXISTS daily_log_category_created_idx
    ON careplanner.daily_log_notes (category_pk, created_at_utc DESC);

CREATE INDEX IF NOT EXISTS daily_log_source_received_idx
    ON careplanner.daily_log_notes (source_vendor, received_at DESC);

CREATE INDEX IF NOT EXISTS daily_log_brin_created_idx
    ON careplanner.daily_log_notes USING BRIN (created_at_utc);

CREATE INDEX IF NOT EXISTS daily_log_tsv_gin_idx
    ON careplanner.daily_log_notes USING GIN (search_tsv);

CREATE INDEX IF NOT EXISTS daily_log_content_trgm_idx
    ON careplanner.daily_log_notes USING GIN (content gin_trgm_ops);

CREATE INDEX IF NOT EXISTS daily_log_raw_payload_gin_idx
    ON careplanner.daily_log_notes USING GIN (raw_payload jsonb_path_ops);

COMMIT;
