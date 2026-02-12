#!/usr/bin/env python3
import json
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MEDICATION_DIR = ROOT / "client" / "client-med"
CONTAINER = "emar_postgres"
DATABASE = "emar"
DB_USER = "postgres"

EXPECTED_RESIDENT_KEYS = {"nhsNumber", "name", "medications"}
EXPECTED_MED_KEYS = {
    "name",
    "vendorDrugId",
    "rawStrength",
    "dose",
    "prn",
    "route",
    "instructions",
    "is_controlled_drug",
    "metadata",
}
EXPECTED_METADATA_KEYS = {"sourceVendor", "externalId"}


def sql_literal(value):
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    text = str(value).replace("'", "''")
    return f"'{text}'"


def slug(text: str) -> str:
    normalized = re.sub(r"[^A-Za-z0-9]+", "-", text.strip()).strip("-").lower()
    return normalized or "med"


def load_resident_map():
    cmd = (
        "docker exec -i emar_postgres psql -U postgres -d emar -t -A -F '|' "
        "-c \"SELECT nhs_number, resident_id, org_id FROM residents WHERE nhs_number IS NOT NULL;\""
    )
    result = subprocess.run(cmd, shell=True, text=True, capture_output=True, check=False)
    if result.returncode != 0:
        raise SystemExit(result.stderr.strip() or "Failed to load residents from database")

    mapping = {}
    for line in result.stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        nhs_number, resident_id, org_id = line.split("|", 2)
        mapping[nhs_number] = (resident_id, org_id)
    return mapping


def validate_payload(payload, file_path):
    errors = []
    resident_rows = payload if isinstance(payload, list) else [payload]

    for idx, resident in enumerate(resident_rows, start=1):
        if not isinstance(resident, dict):
            errors.append(f"{file_path} resident #{idx}: object expected")
            continue

        unknown_resident = set(resident.keys()) - EXPECTED_RESIDENT_KEYS
        if unknown_resident:
            errors.append(f"{file_path} resident #{idx}: unknown keys {sorted(unknown_resident)}")

        if "nhsNumber" not in resident:
            errors.append(f"{file_path} resident #{idx}: missing nhsNumber")

        medications = resident.get("medications")
        if not isinstance(medications, list):
            errors.append(f"{file_path} resident #{idx}: medications must be an array")
            continue

        for med_idx, med in enumerate(medications, start=1):
            if not isinstance(med, dict):
                errors.append(f"{file_path} resident #{idx} medication #{med_idx}: object expected")
                continue

            unknown_med = set(med.keys()) - EXPECTED_MED_KEYS
            if unknown_med:
                errors.append(
                    f"{file_path} resident #{idx} medication #{med_idx}: unknown keys {sorted(unknown_med)}"
                )

            if "name" not in med:
                errors.append(f"{file_path} resident #{idx} medication #{med_idx}: missing name")

            metadata = med.get("metadata")
            if metadata is not None:
                if not isinstance(metadata, dict):
                    errors.append(
                        f"{file_path} resident #{idx} medication #{med_idx}: metadata must be an object"
                    )
                else:
                    unknown_metadata = set(metadata.keys()) - EXPECTED_METADATA_KEYS
                    if unknown_metadata:
                        errors.append(
                            f"{file_path} resident #{idx} medication #{med_idx}: unknown metadata keys {sorted(unknown_metadata)}"
                        )

    return errors


def build_order_id(resident_id, med, med_index):
    metadata = med.get("metadata") if isinstance(med.get("metadata"), dict) else {}
    external_id = metadata.get("externalId")
    if isinstance(external_id, str) and external_id.strip():
        return external_id.strip()

    vendor_drug_id = med.get("vendorDrugId")
    if isinstance(vendor_drug_id, str) and vendor_drug_id.strip():
        return f"{resident_id}-{vendor_drug_id.strip()}"

    med_name = med.get("name") if isinstance(med.get("name"), str) else "medication"
    return f"{resident_id}-{slug(med_name)}-{med_index}"


def build_sql(rows):
    statements = ["BEGIN;"]
    for row in rows:
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
    org_id = EXCLUDED.org_id,
    resident_id = EXCLUDED.resident_id,
    vendor_drug_id = EXCLUDED.vendor_drug_id,
    medication_name = EXCLUDED.medication_name,
    raw_strength = EXCLUDED.raw_strength,
    dose_text = EXCLUDED.dose_text,
    dose_value = EXCLUDED.dose_value,
    dose_unit = EXCLUDED.dose_unit,
    prn = EXCLUDED.prn,
    route = EXCLUDED.route,
    instructions = EXCLUDED.instructions,
    is_controlled_drug = EXCLUDED.is_controlled_drug,
    source_vendor = EXCLUDED.source_vendor,
    source_external_id = EXCLUDED.source_external_id,
    frequency = EXCLUDED.frequency,
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date,
    status = EXCLUDED.status,
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
                frequency=sql_literal(row["frequency"]),
                start_date=sql_literal(row["start_date"]),
                end_date=sql_literal(row["end_date"]),
            )
        )
    statements.append("COMMIT;")
    return "\n".join(statements)


def main():
    if not MEDICATION_DIR.exists():
        raise SystemExit(f"Medication directory not found: {MEDICATION_DIR}")

    files = sorted(MEDICATION_DIR.glob("*.json"))
    if not files:
        raise SystemExit(f"No medication JSON files found in: {MEDICATION_DIR}")

    validation_errors = []
    payloads = []
    for file_path in files:
        with file_path.open("r", encoding="utf-8") as f:
            payload = json.load(f)
        payloads.append((file_path, payload))
        validation_errors.extend(validate_payload(payload, str(file_path.relative_to(ROOT))))

    if validation_errors:
        raise SystemExit("Validation failed:\n- " + "\n- ".join(validation_errors))

    resident_map = load_resident_map()

    rows = []
    missing_residents = set()
    seen_order_ids = set()

    for file_path, payload in payloads:
        resident_rows = payload if isinstance(payload, list) else [payload]
        for resident in resident_rows:
            nhs_number = resident.get("nhsNumber")
            if not isinstance(nhs_number, str) or nhs_number not in resident_map:
                missing_residents.add(str(nhs_number))
                continue

            resident_id, org_id = resident_map[nhs_number]
            medications = resident.get("medications") or []

            for med_index, med in enumerate(medications, start=1):
                metadata = med.get("metadata") if isinstance(med.get("metadata"), dict) else {}
                order_id = build_order_id(resident_id, med, med_index)

                if order_id in seen_order_ids:
                    order_id = f"{order_id}-{med_index}"
                seen_order_ids.add(order_id)

                rows.append(
                    {
                        "order_id": order_id,
                        "org_id": org_id,
                        "resident_id": resident_id,
                        "vendor_drug_id": med.get("vendorDrugId"),
                        "medication_name": med.get("name"),
                        "raw_strength": med.get("rawStrength"),
                        "dose_text": med.get("dose"),
                        "dose_value": None,
                        "dose_unit": None,
                        "prn": bool(med.get("prn", False)),
                        "route": med.get("route"),
                        "instructions": med.get("instructions"),
                        "is_controlled_drug": bool(med.get("is_controlled_drug", False)),
                        "source_vendor": metadata.get("sourceVendor"),
                        "source_external_id": metadata.get("externalId"),
                        "frequency": None,
                        "start_date": None,
                        "end_date": None,
                    }
                )

    if missing_residents:
        raise SystemExit(
            "Cannot ingest medications: NHS number(s) not found in residents table: "
            + ", ".join(sorted(missing_residents))
        )

    sql = build_sql(rows)
    result = subprocess.run(
        ["docker", "exec", "-i", CONTAINER, "psql", "-v", "ON_ERROR_STOP=1", "-U", DB_USER, "-d", DATABASE],
        input=sql,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise SystemExit(result.stderr.strip() or "Failed to ingest medications")

    print(result.stdout.strip())
    print(f"Validated {len(files)} file(s) from {MEDICATION_DIR}")
    print(f"Ingested {len(rows)} medication order row(s)")


if __name__ == "__main__":
    main()
