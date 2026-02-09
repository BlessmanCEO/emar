use regex::Regex;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Dose {
    pub value: f64,
    pub unit: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MedicationOrder {
    pub order_id: String,
    pub resident_id: String,
    pub interval_minutes: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MarEntry {
    pub order_id: String,
    pub resident_id: String,
    pub scheduled_at: i64,
}

pub fn normalize_medication_name(raw: String) -> String {
    let lowered = raw.trim().to_lowercase();
    let re = Regex::new(r"[^a-z0-9]+").unwrap();
    let slug = re.replace_all(&lowered, "-");
    slug.trim_matches('-').to_string()
}

pub fn parse_dose(raw: String) -> Option<Dose> {
    let re = Regex::new(r"(?i)^\s*(\d+(?:\.\d+)?)\s*([a-zA-Z/]+)\s*$").ok()?;
    let caps = re.captures(raw.trim())?;
    let value: f64 = caps.get(1)?.as_str().parse().ok()?;
    let unit = caps.get(2)?.as_str().to_lowercase();
    Some(Dose { value, unit })
}

pub fn expand_schedule(order: MedicationOrder, from_ts: i64, to_ts: i64) -> Vec<MarEntry> {
    if order.interval_minutes <= 0 || to_ts < from_ts {
        return Vec::new();
    }

    let mut entries = Vec::new();
    let mut current = from_ts;
    while current <= to_ts {
        entries.push(MarEntry {
            order_id: order.order_id.clone(),
            resident_id: order.resident_id.clone(),
            scheduled_at: current,
        });
        current += order.interval_minutes * 60;
    }
    entries
}

pub fn normalize_reason_codes(list: Vec<String>) -> Vec<String> {
    let mut out: Vec<String> = list
        .into_iter()
        .map(|s| s.trim().to_lowercase())
        .filter(|s| !s.is_empty())
        .collect();
    out.sort();
    out.dedup();
    out
}

pub fn make_event_id() -> String {
    Uuid::new_v4().to_string()
}
