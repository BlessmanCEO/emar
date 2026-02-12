#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESIDENTS_DIR = ROOT / "client" / "residents"
CONTAINER = "emar_postgres"
DATABASE = "emar"
DB_USER = "postgres"


def sql_literal(value):
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    text = str(value).replace("'", "''")
    return f"'{text}'"


def sql_text_array(values):
    if not values:
        return "ARRAY[]::text[]"
    inner = ", ".join(sql_literal(v) for v in values)
    return f"ARRAY[{inner}]::text[]"


def to_row(payload):
    name = payload.get("name") if isinstance(payload.get("name"), dict) else {}
    address = payload.get("address") if isinstance(payload.get("address"), dict) else {}
    gp = payload.get("gpDetails") if isinstance(payload.get("gpDetails"), dict) else {}
    meta = payload.get("metadata") if isinstance(payload.get("metadata"), dict) else {}

    given_raw = name.get("given")
    given = given_raw if isinstance(given_raw, list) else []
    first_name = next((g for g in given if isinstance(g, str) and g.strip()), "Unknown")

    family_raw = name.get("family")
    last_name = family_raw if isinstance(family_raw, str) and family_raw.strip() else "Unknown"

    raw_preferences = payload.get("rawPreferences")
    if not isinstance(raw_preferences, list):
        raw_preferences = []

    return {
        "resident_id": payload.get("resident_id"),
        "nhs_number": payload.get("nhsNumber"),
        "name_prefix": name.get("prefix"),
        "first_name": first_name,
        "last_name": last_name,
        "date_of_birth": payload.get("dateOfBirth"),
        "gender": payload.get("gender"),
        "care_setting": payload.get("careSetting"),
        "address_line1": address.get("line1"),
        "address_line2": address.get("line2"),
        "address_city": address.get("city"),
        "address_postcode": address.get("postcode"),
        "weight_kg": payload.get("weight"),
        "allergies": payload.get("allergies"),
        "raw_preferences": raw_preferences,
        "gp_name": gp.get("name"),
        "gp_code": gp.get("code"),
        "source_vendor": meta.get("sourceVendor"),
        "source_external_id": meta.get("externalId"),
        "source_received_at": meta.get("receivedAt"),
    }


def build_sql(rows):
    statements = ["BEGIN;"]

    for row in rows:
        if not row["resident_id"]:
            continue

        statements.append(
            """
INSERT INTO residents (
    resident_id, nhs_number, name_prefix, first_name, last_name, date_of_birth,
    gender, care_setting, address_line1, address_line2, address_city, address_postcode,
    weight_kg, allergies, raw_preferences, gp_name, gp_code,
    source_vendor, source_external_id, source_received_at, status, updated_at
) VALUES (
    {resident_id}, {nhs_number}, {name_prefix}, {first_name}, {last_name}, {date_of_birth}::date,
    {gender}, {care_setting}, {address_line1}, {address_line2}, {address_city}, {address_postcode},
    {weight_kg}, {allergies}, {raw_preferences}, {gp_name}, {gp_code},
    {source_vendor}, {source_external_id}, {source_received_at}::timestamptz, 'active', now()
)
ON CONFLICT (resident_id) DO UPDATE SET
    nhs_number = EXCLUDED.nhs_number,
    name_prefix = EXCLUDED.name_prefix,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    date_of_birth = EXCLUDED.date_of_birth,
    gender = EXCLUDED.gender,
    care_setting = EXCLUDED.care_setting,
    address_line1 = EXCLUDED.address_line1,
    address_line2 = EXCLUDED.address_line2,
    address_city = EXCLUDED.address_city,
    address_postcode = EXCLUDED.address_postcode,
    weight_kg = EXCLUDED.weight_kg,
    allergies = EXCLUDED.allergies,
    raw_preferences = EXCLUDED.raw_preferences,
    gp_name = EXCLUDED.gp_name,
    gp_code = EXCLUDED.gp_code,
    source_vendor = EXCLUDED.source_vendor,
    source_external_id = EXCLUDED.source_external_id,
    source_received_at = EXCLUDED.source_received_at,
    status = EXCLUDED.status,
    updated_at = now();
""".format(
                resident_id=sql_literal(row["resident_id"]),
                nhs_number=sql_literal(row["nhs_number"]),
                name_prefix=sql_literal(row["name_prefix"]),
                first_name=sql_literal(row["first_name"]),
                last_name=sql_literal(row["last_name"]),
                date_of_birth=sql_literal(row["date_of_birth"]),
                gender=sql_literal(row["gender"]),
                care_setting=sql_literal(row["care_setting"]),
                address_line1=sql_literal(row["address_line1"]),
                address_line2=sql_literal(row["address_line2"]),
                address_city=sql_literal(row["address_city"]),
                address_postcode=sql_literal(row["address_postcode"]),
                weight_kg=sql_literal(row["weight_kg"]),
                allergies=sql_literal(row["allergies"]),
                raw_preferences=sql_text_array(row["raw_preferences"]),
                gp_name=sql_literal(row["gp_name"]),
                gp_code=sql_literal(row["gp_code"]),
                source_vendor=sql_literal(row["source_vendor"]),
                source_external_id=sql_literal(row["source_external_id"]),
                source_received_at=sql_literal(row["source_received_at"]),
            )
        )

    statements.append("COMMIT;")
    return "\n".join(statements)


def main() -> None:
    if not RESIDENTS_DIR.exists():
        raise SystemExit(f"Residents directory not found: {RESIDENTS_DIR}")

    rows = []
    for path in sorted(RESIDENTS_DIR.glob("*.json")):
        if path.name.endswith("_schema.sql"):
            continue
        with path.open("r", encoding="utf-8") as f:
            payload = json.load(f)
        rows.append(to_row(payload))

    sql = build_sql(rows)

    result = subprocess.run(
        ["docker", "exec", "-i", CONTAINER, "psql", "-v", "ON_ERROR_STOP=1", "-U", DB_USER, "-d", DATABASE],
        input=sql,
        text=True,
        capture_output=True,
        check=False,
    )

    if result.returncode != 0:
        raise SystemExit(result.stderr.strip() or "Failed to ingest residents")

    print(result.stdout.strip())
    print(f"Ingested {len(rows)} resident files from {RESIDENTS_DIR}")


if __name__ == "__main__":
    main()
