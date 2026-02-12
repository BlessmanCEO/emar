BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL,
    username TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    job_role TEXT,
    system_privileges TEXT[] NOT NULL DEFAULT '{}',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT users_username_not_blank_chk CHECK (btrim(username) <> '')
);

CREATE UNIQUE INDEX IF NOT EXISTS users_username_lower_uidx ON users (LOWER(username));
CREATE INDEX IF NOT EXISTS users_org_active_idx ON users (org_id) WHERE is_active = true;

CREATE TABLE IF NOT EXISTS refresh_tokens (
    token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS refresh_tokens_user_id_idx ON refresh_tokens (user_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_expires_active_idx ON refresh_tokens (expires_at) WHERE revoked_at IS NULL;

CREATE TABLE IF NOT EXISTS devices (
    device_id UUID PRIMARY KEY,
    org_id UUID NOT NULL,
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    label TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS devices_org_id_idx ON devices (org_id);
CREATE INDEX IF NOT EXISTS devices_user_id_idx ON devices (user_id);

CREATE TABLE IF NOT EXISTS audit_events (
    seq BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_id UUID NOT NULL UNIQUE,
    org_id UUID NOT NULL,
    site_id UUID,
    actor_user_id UUID NOT NULL,
    device_id UUID NOT NULL,
    event_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    schema_version INTEGER NOT NULL CHECK (schema_version > 0),
    payload JSONB NOT NULL,
    CONSTRAINT audit_events_payload_object_chk CHECK (jsonb_typeof(payload) = 'object')
);

CREATE INDEX IF NOT EXISTS audit_events_org_seq_idx ON audit_events (org_id, seq);
CREATE INDEX IF NOT EXISTS audit_events_org_occurred_idx ON audit_events (org_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS audit_events_entity_idx ON audit_events (entity_type, entity_id);
CREATE INDEX IF NOT EXISTS audit_events_occurred_idx ON audit_events (occurred_at);
CREATE INDEX IF NOT EXISTS audit_events_actor_idx ON audit_events (actor_user_id);
CREATE INDEX IF NOT EXISTS audit_events_device_idx ON audit_events (device_id);

ALTER TABLE residents
    ADD COLUMN IF NOT EXISTS org_id UUID,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now();

UPDATE residents
SET org_id = '00000000-0000-0000-0000-000000000001'::uuid
WHERE org_id IS NULL;

UPDATE residents
SET created_at = COALESCE(updated_at, now())
WHERE created_at IS NULL;

ALTER TABLE residents
    ALTER COLUMN org_id SET NOT NULL,
    ALTER COLUMN updated_at SET DEFAULT now(),
    ALTER COLUMN created_at SET DEFAULT now();

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'residents_org_resident_uq') THEN
        ALTER TABLE residents
            ADD CONSTRAINT residents_org_resident_uq UNIQUE (org_id, resident_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'residents_name_not_blank_chk') THEN
        ALTER TABLE residents
            ADD CONSTRAINT residents_name_not_blank_chk CHECK (btrim(first_name) <> '' AND btrim(last_name) <> '');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'residents_nhs_number_format_chk') THEN
        ALTER TABLE residents
            ADD CONSTRAINT residents_nhs_number_format_chk CHECK (nhs_number IS NULL OR nhs_number ~ '^[0-9]{10}$');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'residents_weight_kg_chk') THEN
        ALTER TABLE residents
            ADD CONSTRAINT residents_weight_kg_chk CHECK (weight_kg IS NULL OR weight_kg > 0);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'residents_status_chk') THEN
        ALTER TABLE residents
            ADD CONSTRAINT residents_status_chk CHECK (status IN ('active', 'inactive', 'discharged', 'deceased'));
    END IF;
END$$;

CREATE UNIQUE INDEX IF NOT EXISTS residents_org_nhs_number_uidx ON residents (org_id, nhs_number) WHERE nhs_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS residents_org_name_idx ON residents (org_id, last_name, first_name);
CREATE INDEX IF NOT EXISTS residents_source_external_idx ON residents (org_id, source_vendor, source_external_id);
CREATE INDEX IF NOT EXISTS residents_raw_preferences_gin_idx ON residents USING GIN (raw_preferences);

CREATE TABLE IF NOT EXISTS medication_orders (
    order_id TEXT PRIMARY KEY,
    org_id UUID NOT NULL,
    resident_id TEXT NOT NULL,
    vendor_drug_id TEXT,
    medication_name TEXT NOT NULL,
    raw_strength TEXT,
    dose_text TEXT,
    dose_value NUMERIC,
    dose_unit TEXT,
    prn BOOLEAN NOT NULL DEFAULT false,
    route TEXT,
    instructions TEXT,
    is_controlled_drug BOOLEAN NOT NULL DEFAULT false,
    source_vendor TEXT,
    source_external_id TEXT,
    frequency TEXT,
    start_date DATE,
    end_date DATE,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT medication_orders_org_order_uq UNIQUE (org_id, order_id),
    CONSTRAINT medication_orders_resident_fk FOREIGN KEY (org_id, resident_id)
        REFERENCES residents(org_id, resident_id)
        ON DELETE RESTRICT,
    CONSTRAINT medication_orders_medication_name_not_blank_chk CHECK (btrim(medication_name) <> ''),
    CONSTRAINT medication_orders_dose_value_chk CHECK (dose_value IS NULL OR dose_value > 0),
    CONSTRAINT medication_orders_date_window_chk CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
    CONSTRAINT medication_orders_status_chk CHECK (status IN ('active', 'on_hold', 'discontinued', 'completed'))
);

CREATE UNIQUE INDEX IF NOT EXISTS medication_orders_source_external_uidx
    ON medication_orders (org_id, source_vendor, source_external_id)
    WHERE source_vendor IS NOT NULL AND source_external_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS medication_orders_org_resident_status_idx ON medication_orders (org_id, resident_id, status);
CREATE INDEX IF NOT EXISTS medication_orders_org_vendor_drug_idx ON medication_orders (org_id, vendor_drug_id);

CREATE TABLE IF NOT EXISTS mar_entries (
    mar_entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL,
    resident_id TEXT NOT NULL,
    order_id TEXT NOT NULL,
    scheduled_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT mar_entries_org_mar_entry_uq UNIQUE (org_id, mar_entry_id),
    CONSTRAINT mar_entries_resident_fk FOREIGN KEY (org_id, resident_id)
        REFERENCES residents(org_id, resident_id)
        ON DELETE RESTRICT,
    CONSTRAINT mar_entries_order_fk FOREIGN KEY (org_id, order_id)
        REFERENCES medication_orders(org_id, order_id)
        ON DELETE RESTRICT,
    CONSTRAINT mar_entries_status_chk CHECK (status IN ('scheduled', 'administered', 'missed', 'omitted', 'refused'))
);

CREATE INDEX IF NOT EXISTS mar_entries_org_scheduled_status_idx ON mar_entries (org_id, scheduled_at, status);
CREATE INDEX IF NOT EXISTS mar_entries_org_order_idx ON mar_entries (org_id, order_id);
CREATE INDEX IF NOT EXISTS mar_entries_org_resident_idx ON mar_entries (org_id, resident_id);

CREATE TABLE IF NOT EXISTS administrations (
    administration_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL,
    resident_id TEXT NOT NULL,
    order_id TEXT NOT NULL,
    mar_entry_id UUID NOT NULL,
    administered_at TIMESTAMPTZ,
    status TEXT NOT NULL,
    reason_code TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT administrations_resident_fk FOREIGN KEY (org_id, resident_id)
        REFERENCES residents(org_id, resident_id)
        ON DELETE RESTRICT,
    CONSTRAINT administrations_order_fk FOREIGN KEY (org_id, order_id)
        REFERENCES medication_orders(org_id, order_id)
        ON DELETE RESTRICT,
    CONSTRAINT administrations_mar_entry_fk FOREIGN KEY (org_id, mar_entry_id)
        REFERENCES mar_entries(org_id, mar_entry_id)
        ON DELETE RESTRICT,
    CONSTRAINT administrations_status_chk CHECK (status IN ('given', 'omitted', 'refused', 'delayed', 'error'))
);

CREATE INDEX IF NOT EXISTS administrations_org_administered_idx ON administrations (org_id, administered_at DESC);
CREATE INDEX IF NOT EXISTS administrations_org_resident_administered_idx ON administrations (org_id, resident_id, administered_at DESC);
CREATE INDEX IF NOT EXISTS administrations_org_order_idx ON administrations (org_id, order_id);
CREATE INDEX IF NOT EXISTS administrations_org_mar_entry_idx ON administrations (org_id, mar_entry_id);

COMMIT;
