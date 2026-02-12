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
