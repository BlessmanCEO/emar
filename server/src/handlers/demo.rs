use crate::AppState;
use axum::{extract::{Path, State}, http::StatusCode, Json};
use serde::Serialize;
use sqlx::FromRow;

#[derive(Serialize, FromRow)]
pub struct DemoResident {
    pub resident_id: String,
    pub first_name: String,
    pub last_name: String,
    pub status: String,
    pub date_of_birth: Option<String>,
    pub address_line1: Option<String>,
    pub allergies: Option<String>,
    pub raw_preferences: Vec<String>,
    pub site_name: String,
}

#[derive(Serialize, FromRow)]
pub struct DemoMedication {
    pub order_id: String,
    pub resident_id: String,
    pub medication_name: String,
    pub raw_strength: Option<String>,
    pub dose_text: Option<String>,
    pub dose_value: Option<f64>,
    pub dose_unit: Option<String>,
    pub route: Option<String>,
    pub instructions: Option<String>,
    pub prn: bool,
    pub is_controlled_drug: bool,
    pub frequency: Option<String>,
    pub timing_slots: Vec<String>,
    pub timing_times: Vec<String>,
    pub status: String,
}

#[derive(FromRow)]
struct DemoMedicationRow {
    order_id: String,
    resident_id: String,
    medication_name: String,
    raw_strength: Option<String>,
    dose_text: Option<String>,
    dose_value: Option<f64>,
    dose_unit: Option<String>,
    route: Option<String>,
    instructions: Option<String>,
    prn: bool,
    is_controlled_drug: bool,
    frequency: Option<String>,
    status: String,
}

pub async fn residents(
    State(state): State<AppState>,
) -> Result<Json<Vec<DemoResident>>, (StatusCode, String)> {
    let rows = sqlx::query_as::<_, DemoResident>(
        "SELECT resident_id, first_name, last_name, status,
                to_char(date_of_birth, 'DD-Mon-YYYY') AS date_of_birth,
                address_line1,
                allergies,
                raw_preferences,
                CASE
                    WHEN address_line1 = '123 Willow Lane' THEN 'Mobay'
                    ELSE 'Goldthorn Home'
                END AS site_name
         FROM residents
         WHERE status = 'active'
         ORDER BY last_name, first_name",
    )
    .fetch_all(&state.db)
    .await
    .map_err(internal_error)?;

    Ok(Json(rows))
}

pub async fn resident_medications(
    Path(resident_id): Path<String>,
    State(state): State<AppState>,
) -> Result<Json<Vec<DemoMedication>>, (StatusCode, String)> {
    let rows = sqlx::query_as::<_, DemoMedicationRow>(
        "SELECT order_id, resident_id, medication_name,
                raw_strength, dose_text,
                dose_value::double precision AS dose_value,
                dose_unit, route, instructions, prn, is_controlled_drug, frequency, status
         FROM medication_orders
         WHERE resident_id = $1 AND status = 'active'
         ORDER BY medication_name",
    )
    .bind(resident_id)
    .fetch_all(&state.db)
    .await
    .map_err(internal_error)?;

    let mapped = rows
        .into_iter()
        .map(|row| {
            let timing_slots = infer_timing_slots(row.frequency.as_deref(), row.instructions.as_deref());
            let timing_times = extract_clock_times(row.instructions.as_deref());
            DemoMedication {
                order_id: row.order_id,
                resident_id: row.resident_id,
                medication_name: row.medication_name,
                raw_strength: row.raw_strength,
                dose_text: row.dose_text,
                dose_value: row.dose_value,
                dose_unit: row.dose_unit,
                route: row.route,
                instructions: row.instructions,
                prn: row.prn,
                is_controlled_drug: row.is_controlled_drug,
                frequency: row.frequency,
                timing_slots,
                timing_times,
                status: row.status,
            }
        })
        .collect();

    Ok(Json(mapped))
}

fn infer_timing_slots(frequency: Option<&str>, instructions: Option<&str>) -> Vec<String> {
    let source = format!(
        "{} {}",
        frequency.unwrap_or_default().to_lowercase(),
        instructions.unwrap_or_default().to_lowercase()
    );

    let mut slots: Vec<String> = Vec::new();

    if source.contains("morning") || source.contains("breakfast") || source.contains(" am") {
        push_unique(&mut slots, "Morning");
    }
    if source.contains("noon") || source.contains("midday") || source.contains("lunch") {
        push_unique(&mut slots, "Noon");
    }
    if source.contains("evening") || source.contains("dinner") || source.contains("supper") || source.contains(" pm") {
        push_unique(&mut slots, "Evening");
    }
    if source.contains("night") || source.contains("bedtime") || source.contains("at bedtime") {
        push_unique(&mut slots, "Night");
    }

    if source.contains("twice daily") {
        push_unique(&mut slots, "Morning");
        push_unique(&mut slots, "Evening");
    }
    if source.contains("three times daily") || source.contains("tds") {
        push_unique(&mut slots, "Morning");
        push_unique(&mut slots, "Noon");
        push_unique(&mut slots, "Evening");
    }
    if source.contains("four times daily") || source.contains("qid") {
        push_unique(&mut slots, "Morning");
        push_unique(&mut slots, "Noon");
        push_unique(&mut slots, "Evening");
        push_unique(&mut slots, "Night");
    }

    for time in extract_clock_times(instructions) {
        let hour = time
            .split(':')
            .next()
            .and_then(|h| h.parse::<u32>().ok())
            .unwrap_or(8);
        if (5..12).contains(&hour) {
            push_unique(&mut slots, "Morning");
        } else if (12..16).contains(&hour) {
            push_unique(&mut slots, "Noon");
        } else if (16..21).contains(&hour) {
            push_unique(&mut slots, "Evening");
        } else {
            push_unique(&mut slots, "Night");
        }
    }

    if slots.is_empty() {
        push_unique(&mut slots, "Morning");
    }

    slots
}

fn extract_clock_times(text: Option<&str>) -> Vec<String> {
    let Some(value) = text else {
        return Vec::new();
    };

    let chars: Vec<char> = value.chars().collect();
    let mut times = Vec::new();

    if chars.len() < 5 {
        return times;
    }

    for idx in 0..=(chars.len() - 5) {
        let c0 = chars[idx];
        let c1 = chars[idx + 1];
        let c2 = chars[idx + 2];
        let c3 = chars[idx + 3];
        let c4 = chars[idx + 4];
        if c0.is_ascii_digit()
            && c1.is_ascii_digit()
            && c2 == ':'
            && c3.is_ascii_digit()
            && c4.is_ascii_digit()
        {
            let candidate = format!("{}{}:{}{}", c0, c1, c3, c4);
            if !times.iter().any(|t| t == &candidate) {
                times.push(candidate);
            }
        }
    }

    times
}

fn push_unique(slots: &mut Vec<String>, slot: &str) {
    if !slots.iter().any(|s| s == slot) {
        slots.push(slot.to_string());
    }
}

fn internal_error(err: impl std::fmt::Display) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}
