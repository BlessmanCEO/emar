#!/usr/bin/env python3
import difflib
import hashlib
import json
import re
import subprocess
import uuid
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ADMIN_DIR = ROOT / "client-admin"
CONTAINER = "emar_postgres"
DATABASE = "emar"
DB_USER = "postgres"

EXPECTED_KEYS = {
    "first_name",
    "last_name",
    "medication",
    "status",
    "scheduled_time",
    "administered_time",
    "route",
    "prn",
    "strength_value",
    "stength_unit",
    "iscountrolleddrug",
    "note",
    "staff",
    "dose_quantity",
    "stock_before",
    "stock_after",
}

STATUS_MAP_ADMIN = {
    "administered": "given",
    "refused": "refused",
    "skipped": "omitted",
}

STATUS_MAP_MAR = {
    "administered": "administered",
    "refused": "refused",
    "skipped": "omitted",
}


def run_psql_copy(command_sql: str):
    cmd = (
        "docker exec -i emar_postgres psql -U postgres -d emar -t -A -F '|' "
        f"-c \"{command_sql}\""
    )
    result = subprocess.run(cmd, shell=True, text=True, capture_output=True, check=False)
    if result.returncode != 0:
        raise SystemExit(result.stderr.strip() or "Database query failed")
    return result.stdout


def sql_literal(value):
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    text = str(value).replace("'", "''")
    return f"'{text}'"


def normalize_name(value):
    return re.sub(r"\s+", " ", str(value or "").strip()).lower()


def slug(value):
    out = re.sub(r"[^a-zA-Z0-9]+", "-", str(value or "").strip()).strip("-").lower()
    return out or "unknown"


def parse_time(value):
    if not value:
        return None
    dt = datetime.strptime(value, "%Y-%m-%d %H:%M:%S")
    dt = dt.replace(tzinfo=timezone.utc)
    return dt.isoformat()


def maybe_numeric(value):
    if value is None:
        return None
    text = str(value).strip()
    if not text:
        return None
    try:
        return float(text)
    except ValueError:
        return None


def positive_numeric_or_none(value):
    parsed = maybe_numeric(value)
    if parsed is None or parsed <= 0:
        return None
    return parsed


def deterministic_uuid(parts):
    raw = "|".join(str(p) for p in parts)
    digest = hashlib.sha1(raw.encode("utf-8")).hexdigest()
    return str(uuid.UUID(digest[:32]))


def load_residents():
    output = run_psql_copy(
        "SELECT resident_id, org_id, first_name, last_name FROM residents ORDER BY resident_id"
    )
    residents = []
    for line in output.splitlines():
        line = line.strip()
        if not line:
            continue
        resident_id, org_id, first_name, last_name = line.split("|", 3)
        residents.append(
            {
                "resident_id": resident_id,
                "org_id": org_id,
                "first_name": first_name,
                "last_name": last_name,
                "first_norm": normalize_name(first_name),
                "last_norm": normalize_name(last_name),
            }
        )
    return residents


def load_medication_orders():
    output = run_psql_copy(
        "SELECT org_id, resident_id, order_id, lower(medication_name) FROM medication_orders"
    )
    mapping = {}
    for line in output.splitlines():
        line = line.strip()
        if not line:
            continue
        org_id, resident_id, order_id, med_name = line.split("|", 3)
        mapping[(org_id, resident_id, med_name)] = order_id
    return mapping


def match_resident(first_name, last_name, residents):
    first_norm = normalize_name(first_name)
    last_norm = normalize_name(last_name)

    exact = [r for r in residents if r["first_norm"] == first_norm and r["last_norm"] == last_norm]
    if exact:
        return exact[0]

    same_last = [r for r in residents if r["last_norm"] == last_norm]
    if same_last:
        candidates = [r["first_norm"] for r in same_last]
        match = difflib.get_close_matches(first_norm, candidates, n=1, cutoff=0.7)
        if match:
            for resident in same_last:
                if resident["first_norm"] == match[0]:
                    return resident

    full_input = f"{first_norm} {last_norm}".strip()
    full_candidates = [f"{r['first_norm']} {r['last_norm']}".strip() for r in residents]
    match = difflib.get_close_matches(full_input, full_candidates, n=1, cutoff=0.8)
    if match:
        for resident in residents:
            candidate = f"{resident['first_norm']} {resident['last_norm']}".strip()
            if candidate == match[0]:
                return resident

    return None


def build_sql(order_rows, mar_rows, admin_rows):
    statements = ["BEGIN;"]

    for row in order_rows:
        statements.append(
            """
INSERT INTO medication_orders (
    order_id, org_id, resident_id, vendor_drug_id, medication_name, raw_strength,
    dose_text, dose_value, dose_unit, prn, route, instructions, is_controlled_drug,
    source_vendor, source_external_id, frequency, start_date, end_date, status, updated_at
) VALUES (
    {order_id}, {org_id}, {resident_id}, {vendor_drug_id}, {medication_name}, {raw_strength},
    {dose_text}, {dose_value}, {dose_unit}, {prn}, {route}, {instructions}, {is_controlled_drug},
    {source_vendor}, {source_external_id}, {frequency}, {start_date}, {end_date}, 'active', now()
)
ON CONFLICT (order_id) DO UPDATE SET
    route = EXCLUDED.route,
    prn = EXCLUDED.prn,
    raw_strength = EXCLUDED.raw_strength,
    dose_text = EXCLUDED.dose_text,
    dose_value = EXCLUDED.dose_value,
    dose_unit = EXCLUDED.dose_unit,
    instructions = EXCLUDED.instructions,
    is_controlled_drug = EXCLUDED.is_controlled_drug,
    updated_at = now();
""".format(
                order_id=sql_literal(row["order_id"]),
                org_id=sql_literal(row["org_id"]),
                resident_id=sql_literal(row["resident_id"]),
                vendor_drug_id=sql_literal(row["vendor_drug_id"]),
                medication_name=sql_literal(row["medication_name"]),
                raw_strength=sql_literal(row["raw_strength"]),
                dose_text=sql_literal(row["dose_text"]),
                dose_value=sql_literal(row["dose_value"]),
                dose_unit=sql_literal(row["dose_unit"]),
                prn=sql_literal(row["prn"]),
                route=sql_literal(row["route"]),
                instructions=sql_literal(row["instructions"]),
                is_controlled_drug=sql_literal(row["is_controlled_drug"]),
                source_vendor=sql_literal(row["source_vendor"]),
                source_external_id=sql_literal(row["source_external_id"]),
                frequency="NULL",
                start_date="NULL",
                end_date="NULL",
            )
        )

    for row in mar_rows:
        statements.append(
            """
INSERT INTO mar_entries (
    mar_entry_id, org_id, resident_id, order_id, scheduled_at, status, updated_at
) VALUES (
    {mar_entry_id}::uuid, {org_id}::uuid, {resident_id}, {order_id}, {scheduled_at}::timestamptz, {status}, now()
)
ON CONFLICT (mar_entry_id) DO UPDATE SET
    status = EXCLUDED.status,
    scheduled_at = EXCLUDED.scheduled_at,
    updated_at = now();
""".format(
                mar_entry_id=sql_literal(row["mar_entry_id"]),
                org_id=sql_literal(row["org_id"]),
                resident_id=sql_literal(row["resident_id"]),
                order_id=sql_literal(row["order_id"]),
                scheduled_at=sql_literal(row["scheduled_at"]),
                status=sql_literal(row["status"]),
            )
        )

    for row in admin_rows:
        statements.append(
            """
INSERT INTO administrations (
    administration_id, org_id, resident_id, order_id, mar_entry_id, administered_at,
    status, reason_code, notes, updated_at
) VALUES (
    {administration_id}::uuid, {org_id}::uuid, {resident_id}, {order_id}, {mar_entry_id}::uuid, {administered_at}::timestamptz,
    {status}, {reason_code}, {notes}, now()
)
ON CONFLICT (administration_id) DO UPDATE SET
    administered_at = EXCLUDED.administered_at,
    status = EXCLUDED.status,
    reason_code = EXCLUDED.reason_code,
    notes = EXCLUDED.notes,
    updated_at = now();
""".format(
                administration_id=sql_literal(row["administration_id"]),
                org_id=sql_literal(row["org_id"]),
                resident_id=sql_literal(row["resident_id"]),
                order_id=sql_literal(row["order_id"]),
                mar_entry_id=sql_literal(row["mar_entry_id"]),
                administered_at=sql_literal(row["administered_at"]),
                status=sql_literal(row["status"]),
                reason_code=sql_literal(row["reason_code"]),
                notes=sql_literal(row["notes"]),
            )
        )

    statements.append("COMMIT;")
    return "\n".join(statements)


def main():
    files = sorted(ADMIN_DIR.glob("*.json"))
    if not files:
        raise SystemExit(f"No admin JSON files found in: {ADMIN_DIR}")

    residents = load_residents()
    order_lookup = load_medication_orders()

    errors = []
    order_rows = {}
    mar_rows = {}
    admin_rows = {}

    for file_path in files:
        with file_path.open("r", encoding="utf-8") as f:
            payload = json.load(f)

        events = payload if isinstance(payload, list) else [payload]
        for idx, event in enumerate(events, start=1):
            if not isinstance(event, dict):
                errors.append(f"{file_path.name} #{idx}: event must be an object")
                continue

            unknown = set(event.keys()) - EXPECTED_KEYS
            if unknown:
                errors.append(f"{file_path.name} #{idx}: unknown keys {sorted(unknown)}")

            resident = match_resident(event.get("first_name"), event.get("last_name"), residents)
            if not resident:
                errors.append(
                    f"{file_path.name} #{idx}: resident not found for '{event.get('first_name')} {event.get('last_name')}'"
                )
                continue

            raw_status = str(event.get("status", "")).strip().lower()
            mar_status = STATUS_MAP_MAR.get(raw_status)
            admin_status = STATUS_MAP_ADMIN.get(raw_status)
            if not mar_status or not admin_status:
                errors.append(f"{file_path.name} #{idx}: unsupported status '{raw_status}'")
                continue

            medication_name = str(event.get("medication", "")).strip()
            if not medication_name:
                errors.append(f"{file_path.name} #{idx}: medication is required")
                continue

            administered_raw = event.get("administered_time")
            scheduled_raw = event.get("scheduled_time") or administered_raw
            try:
                scheduled_at = parse_time(scheduled_raw)
            except Exception:
                errors.append(f"{file_path.name} #{idx}: invalid scheduled_time '{scheduled_raw}'")
                continue
            if scheduled_at is None:
                errors.append(f"{file_path.name} #{idx}: scheduled_time is required")
                continue

            try:
                administered_at = parse_time(administered_raw)
            except Exception:
                errors.append(f"{file_path.name} #{idx}: invalid administered_time '{administered_raw}'")
                continue

            med_key = (resident["org_id"], resident["resident_id"], medication_name.lower())
            order_id = order_lookup.get(med_key)
            if not order_id:
                order_id = f"ADM-{resident['resident_id']}-{slug(medication_name)}"
                order_lookup[med_key] = order_id

            source_external_id = f"ADMIN-{resident['resident_id']}-{slug(medication_name)}"
            order_rows[order_id] = {
                "order_id": order_id,
                "org_id": resident["org_id"],
                "resident_id": resident["resident_id"],
                "vendor_drug_id": None,
                "medication_name": medication_name,
                "raw_strength": (
                    f"{event.get('strength_value', '')}{event.get('stength_unit', '')}".strip() or None
                ),
                "dose_text": (str(event.get("dose_quantity", "")).strip() + " dose").strip(),
                "dose_value": positive_numeric_or_none(event.get("dose_quantity")),
                "dose_unit": event.get("stength_unit"),
                "prn": bool(event.get("prn", False)),
                "route": event.get("route"),
                "instructions": None,
                "is_controlled_drug": bool(event.get("iscountrolleddrug", False)),
                "source_vendor": "client-admin",
                "source_external_id": source_external_id,
            }

            mar_entry_id = deterministic_uuid(
                [resident["org_id"], resident["resident_id"], order_id, scheduled_at]
            )
            mar_rows[mar_entry_id] = {
                "mar_entry_id": mar_entry_id,
                "org_id": resident["org_id"],
                "resident_id": resident["resident_id"],
                "order_id": order_id,
                "scheduled_at": scheduled_at,
                "status": mar_status,
            }

            note = str(event.get("note", "")).strip()
            staff = str(event.get("staff", "")).strip()
            stock_before = str(event.get("stock_before", "")).strip()
            stock_after = str(event.get("stock_after", "")).strip()
            notes = "; ".join(
                part
                for part in [
                    f"staff={staff}" if staff else "",
                    f"note={note}" if note else "",
                    f"stock_before={stock_before}" if stock_before else "",
                    f"stock_after={stock_after}" if stock_after else "",
                ]
                if part
            ) or None

            reason_code = "resident_refused" if admin_status == "refused" else (
                "skipped" if admin_status == "omitted" else None
            )

            administration_id = deterministic_uuid(
                [mar_entry_id, administered_at, admin_status, notes]
            )
            admin_rows[administration_id] = {
                "administration_id": administration_id,
                "org_id": resident["org_id"],
                "resident_id": resident["resident_id"],
                "order_id": order_id,
                "mar_entry_id": mar_entry_id,
                "administered_at": administered_at,
                "status": admin_status,
                "reason_code": reason_code,
                "notes": notes,
            }

    if errors:
        raise SystemExit("Validation failed:\n- " + "\n- ".join(errors))

    sql = build_sql(list(order_rows.values()), list(mar_rows.values()), list(admin_rows.values()))
    result = subprocess.run(
        ["docker", "exec", "-i", CONTAINER, "psql", "-v", "ON_ERROR_STOP=1", "-U", DB_USER, "-d", DATABASE],
        input=sql,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise SystemExit(result.stderr.strip() or "Failed to ingest admin events")

    print(result.stdout.strip())
    print(f"Validated {len(files)} admin file(s)")
    print(f"Upserted {len(order_rows)} medication order(s)")
    print(f"Upserted {len(mar_rows)} mar entry row(s)")
    print(f"Upserted {len(admin_rows)} administration row(s)")


if __name__ == "__main__":
    main()
