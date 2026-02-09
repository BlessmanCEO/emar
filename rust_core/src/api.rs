use flutter_rust_bridge::frb;

use crate::core;
use crate::core::{Dose, MarEntry, MedicationOrder};

#[frb]
pub fn normalize_medication_name(raw: String) -> String {
    core::normalize_medication_name(raw)
}

#[frb]
pub fn parse_dose(raw: String) -> Option<Dose> {
    core::parse_dose(raw)
}

#[frb]
pub fn expand_schedule(order: MedicationOrder, from_ts: i64, to_ts: i64) -> Vec<MarEntry> {
    core::expand_schedule(order, from_ts, to_ts)
}

#[frb]
pub fn normalize_reason_codes(list: Vec<String>) -> Vec<String> {
    core::normalize_reason_codes(list)
}

#[frb]
pub fn make_event_id() -> String {
    core::make_event_id()
}
