CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    job_role TEXT,
    system_privileges TEXT[] NOT NULL DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE refresh_tokens (
    token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at TIMESTAMPTZ
);

CREATE TABLE devices (
    device_id UUID PRIMARY KEY,
    org_id UUID NOT NULL,
    user_id UUID,
    label TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at TIMESTAMPTZ
);

CREATE TABLE audit_events (
    seq BIGSERIAL PRIMARY KEY,
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
    schema_version INT NOT NULL,
    payload JSONB NOT NULL
);

CREATE INDEX audit_events_org_seq_idx ON audit_events (org_id, seq);
CREATE INDEX audit_events_entity_idx ON audit_events (entity_type, entity_id);
CREATE INDEX audit_events_occurred_idx ON audit_events (occurred_at);

CREATE TABLE residents (
    resident_id UUID PRIMARY KEY,
    org_id UUID NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    date_of_birth DATE,
    status TEXT NOT NULL DEFAULT 'active',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE medication_orders (
    order_id UUID PRIMARY KEY,
    org_id UUID NOT NULL,
    resident_id UUID NOT NULL,
    medication_name TEXT NOT NULL,
    dose_value NUMERIC,
    dose_unit TEXT,
    route TEXT,
    frequency TEXT,
    start_date DATE,
    end_date DATE,
    status TEXT NOT NULL DEFAULT 'active',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE mar_entries (
    mar_entry_id UUID PRIMARY KEY,
    org_id UUID NOT NULL,
    resident_id UUID NOT NULL,
    order_id UUID NOT NULL,
    scheduled_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE administrations (
    administration_id UUID PRIMARY KEY,
    org_id UUID NOT NULL,
    resident_id UUID NOT NULL,
    order_id UUID NOT NULL,
    mar_entry_id UUID NOT NULL,
    administered_at TIMESTAMPTZ,
    status TEXT NOT NULL,
    reason_code TEXT,
    notes TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
