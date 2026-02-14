#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DAILY_LOG_ROOT = ROOT / "client" / "daily-log"
CONTAINER = "careplanner-postgres"
DATABASE = "careplanner"
DB_USER = "postgres"


def sql_literal(value):
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


def discover_files():
    files = []
    files.extend(sorted((DAILY_LOG_ROOT / "stanley-hudson").glob("*.json")))
    files.extend(sorted(DAILY_LOG_ROOT.glob("*.json")))
    return [p for p in files if p.exists()]


def load_rows(paths):
    rows = []
    for path in paths:
        with path.open("r", encoding="utf-8") as f:
            payload = json.load(f)
        notes = payload if isinstance(payload, list) else [payload]
        for note in notes:
            rows.append(note)
    return rows


def build_statement(note):
    payload_json = json.dumps(note, separators=(",", ":"))

    return """
WITH upsert_resident AS (
    INSERT INTO careplanner.residents (
        resident_external_id,
        resident_display_name,
        source_vendor,
        updated_at
    ) VALUES (
        {resident_external_id},
        {resident_name},
        {source_vendor},
        now()
    )
    ON CONFLICT (source_vendor, resident_external_id) DO UPDATE SET
        resident_display_name = EXCLUDED.resident_display_name,
        updated_at = now()
    RETURNING resident_pk
), resident_row AS (
    SELECT resident_pk FROM upsert_resident
    UNION ALL
    SELECT resident_pk
    FROM careplanner.residents
    WHERE source_vendor = {source_vendor}
      AND resident_external_id = {resident_external_id}
    LIMIT 1
), upsert_staff AS (
    INSERT INTO careplanner.staff_members (
        staff_external_id,
        staff_display_name,
        source_vendor,
        updated_at
    ) VALUES (
        {staff_external_id},
        {staff_name},
        {source_vendor},
        now()
    )
    ON CONFLICT (source_vendor, staff_external_id) DO UPDATE SET
        staff_display_name = EXCLUDED.staff_display_name,
        updated_at = now()
    RETURNING staff_pk
), staff_row AS (
    SELECT staff_pk FROM upsert_staff
    UNION ALL
    SELECT staff_pk
    FROM careplanner.staff_members
    WHERE source_vendor = {source_vendor}
      AND staff_external_id = {staff_external_id}
    LIMIT 1
), upsert_category AS (
    INSERT INTO careplanner.note_categories (
        source_vendor,
        category_name
    ) VALUES (
        {source_vendor},
        {category_name}
    )
    ON CONFLICT (source_vendor, category_name_normalized) DO UPDATE SET
        category_name = EXCLUDED.category_name
    RETURNING category_pk
), category_row AS (
    SELECT category_pk FROM upsert_category
    UNION ALL
    SELECT category_pk
    FROM careplanner.note_categories
    WHERE source_vendor = {source_vendor}
      AND category_name_normalized = LOWER(btrim({category_name}))
    LIMIT 1
)
INSERT INTO careplanner.daily_log_notes (
    note_id,
    note_version,
    resident_pk,
    staff_pk,
    category_pk,
    content,
    created_at_utc,
    event_timestamp,
    received_at,
    normalized_at,
    local_date,
    local_time,
    source_vendor,
    source_external_id,
    ingest_id,
    raw_payload_hash,
    raw_payload,
    updated_at
) VALUES (
    {note_id},
    {note_version},
    (SELECT resident_pk FROM resident_row),
    (SELECT staff_pk FROM staff_row),
    (SELECT category_pk FROM category_row),
    {content},
    {created_at_utc}::timestamptz,
    {event_timestamp}::timestamptz,
    {received_at}::timestamptz,
    {normalized_at}::timestamptz,
    {local_date}::date,
    {local_time}::time,
    {source_vendor},
    {source_external_id},
    {ingest_id},
    {raw_payload_hash},
    {raw_payload}::jsonb,
    now()
)
ON CONFLICT (source_vendor, source_external_id, note_version) DO UPDATE SET
    resident_pk = EXCLUDED.resident_pk,
    staff_pk = EXCLUDED.staff_pk,
    category_pk = EXCLUDED.category_pk,
    content = EXCLUDED.content,
    created_at_utc = EXCLUDED.created_at_utc,
    event_timestamp = EXCLUDED.event_timestamp,
    received_at = EXCLUDED.received_at,
    normalized_at = EXCLUDED.normalized_at,
    local_date = EXCLUDED.local_date,
    local_time = EXCLUDED.local_time,
    note_id = EXCLUDED.note_id,
    ingest_id = EXCLUDED.ingest_id,
    raw_payload_hash = EXCLUDED.raw_payload_hash,
    raw_payload = EXCLUDED.raw_payload,
    updated_at = now();
""".format(
        resident_external_id=sql_literal(note.get("resident_id")),
        resident_name=sql_literal(note.get("client")),
        source_vendor=sql_literal(note.get("source_vendor")),
        staff_external_id=sql_literal(note.get("staff_id")),
        staff_name=sql_literal(note.get("staff")),
        category_name=sql_literal(note.get("vendor_category")),
        note_id=sql_literal(note.get("note_id")),
        note_version=sql_literal(note.get("version", 1)),
        content=sql_literal(note.get("content")),
        created_at_utc=sql_literal(note.get("created_at_utc")),
        event_timestamp=sql_literal(note.get("event_timestamp")),
        received_at=sql_literal(note.get("received_at")),
        normalized_at=sql_literal(note.get("normalized_at")),
        local_date=sql_literal(note.get("local_date_text")),
        local_time=sql_literal(note.get("local_time_text")),
        source_external_id=sql_literal(note.get("source_external_id")),
        ingest_id=sql_literal(note.get("ingest_id")),
        raw_payload_hash=sql_literal(note.get("raw_payload_hash")),
        raw_payload=sql_literal(payload_json),
    )


def build_sql(rows):
    statements = ["BEGIN;"]
    for row in rows:
        statements.append(build_statement(row))
    statements.append("COMMIT;")
    return "\n".join(statements)


def main():
    files = discover_files()
    if not files:
        raise SystemExit(f"No daily-log files found under {DAILY_LOG_ROOT}")

    rows = load_rows(files)
    sql = build_sql(rows)

    result = subprocess.run(
        ["docker", "exec", "-i", CONTAINER, "psql", "-v", "ON_ERROR_STOP=1", "-U", DB_USER, "-d", DATABASE],
        input=sql,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise SystemExit(result.stderr.strip() or "Failed to ingest daily logs")

    print(result.stdout.strip())
    print(f"Ingested {len(rows)} daily log rows from {len(files)} files")


if __name__ == "__main__":
    main()
