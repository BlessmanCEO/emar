#!/usr/bin/env python3
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESIDENTS_DIR = ROOT / "client" / "residents"


def build_initials(name_obj: dict) -> str:
    given = name_obj.get("given") or []
    family = name_obj.get("family", "")

    initials = "".join(part.strip()[:1].upper() for part in given if isinstance(part, str) and part.strip())
    if isinstance(family, str) and family.strip():
        initials += family.strip()[:1].upper()

    return initials or "XX"


def normalized_dob(value: str) -> str:
    if not isinstance(value, str):
        return "00000000"

    compact = value.replace("-", "")
    if len(compact) == 8 and compact.isdigit():
        return compact

    return "00000000"


def with_resident_id(record: dict, resident_id: str) -> dict:
    new_record = {}
    inserted = False

    for key, value in record.items():
        new_record[key] = value
        if key == "nhsNumber":
            new_record["resident_id"] = resident_id
            inserted = True

    if not inserted:
        final_record = {"resident_id": resident_id}
        final_record.update(new_record)
        return final_record

    return new_record


def main() -> None:
    if not RESIDENTS_DIR.exists():
        raise SystemExit(f"Residents directory not found: {RESIDENTS_DIR}")

    used_ids = set()
    updated = 0

    for path in sorted(RESIDENTS_DIR.glob("*.json")):
        with path.open("r", encoding="utf-8") as f:
            payload = json.load(f)

        name_obj = payload.get("name") if isinstance(payload.get("name"), dict) else {}
        dob = payload.get("dateOfBirth")

        base_id = f"{build_initials(name_obj)}-{normalized_dob(dob)}"
        resident_id = base_id

        sequence = 1
        while resident_id in used_ids:
            sequence += 1
            resident_id = f"{base_id}-{sequence}"

        used_ids.add(resident_id)

        payload = with_resident_id(payload, resident_id)

        with path.open("w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2)
            f.write("\n")

        updated += 1

    print(f"Updated {updated} resident files in {RESIDENTS_DIR}")


if __name__ == "__main__":
    main()
