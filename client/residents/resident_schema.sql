CREATE TABLE IF NOT EXISTS residents (
    resident_id TEXT PRIMARY KEY,
    org_id UUID NOT NULL,
    nhs_number TEXT,
    name_prefix TEXT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    date_of_birth DATE,
    gender TEXT,
    care_setting TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    address_city TEXT,
    address_postcode TEXT,
    weight_kg NUMERIC,
    allergies TEXT,
    raw_preferences TEXT[] NOT NULL DEFAULT '{}',
    gp_name TEXT,
    gp_code TEXT,
    source_vendor TEXT,
    source_external_id TEXT,
    source_received_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT residents_org_resident_uq UNIQUE (org_id, resident_id),
    CONSTRAINT residents_name_not_blank_chk CHECK (btrim(first_name) <> '' AND btrim(last_name) <> ''),
    CONSTRAINT residents_nhs_number_format_chk CHECK (nhs_number IS NULL OR nhs_number ~ '^[0-9]{10}$'),
    CONSTRAINT residents_weight_kg_chk CHECK (weight_kg IS NULL OR weight_kg > 0),
    CONSTRAINT residents_status_chk CHECK (status IN ('active', 'inactive', 'discharged', 'deceased'))
);

CREATE UNIQUE INDEX IF NOT EXISTS residents_org_nhs_number_uidx ON residents (org_id, nhs_number) WHERE nhs_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS residents_org_name_idx ON residents (org_id, last_name, first_name);
CREATE INDEX IF NOT EXISTS residents_source_external_idx ON residents (org_id, source_vendor, source_external_id);
CREATE INDEX IF NOT EXISTS residents_raw_preferences_gin_idx ON residents USING GIN (raw_preferences);
