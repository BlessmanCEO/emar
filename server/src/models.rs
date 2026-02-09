use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Serialize)]
pub struct LoginResponse {
    pub access_token: String,
    pub refresh_token: String,
    pub token_type: String,
    pub expires_in: i64,
}

#[derive(Deserialize)]
pub struct RefreshRequest {
    pub refresh_token: String,
}

#[derive(Deserialize)]
pub struct SyncPushRequest {
    pub events: Vec<AuditEventInput>,
}

#[derive(Serialize)]
pub struct SyncPushResponse {
    pub accepted: Vec<Uuid>,
    pub rejected: Vec<RejectedEvent>,
}

#[derive(Serialize)]
pub struct RejectedEvent {
    pub event_id: Uuid,
    pub code: String,
    pub message: String,
    pub field_path: Option<String>,
}

#[derive(Deserialize)]
pub struct SyncPullParams {
    pub cursor: Option<i64>,
    pub limit: Option<i64>,
}

#[derive(Serialize)]
pub struct SyncPullResponse {
    pub events: Vec<AuditEvent>,
    pub next_cursor: i64,
}

#[derive(Deserialize)]
pub struct AuditEventInput {
    pub event_id: Uuid,
    pub org_id: Uuid,
    pub site_id: Option<Uuid>,
    pub actor_user_id: Uuid,
    pub device_id: Uuid,
    pub event_type: String,
    pub entity_type: String,
    pub entity_id: Uuid,
    pub occurred_at: DateTime<Utc>,
    pub schema_version: i32,
    pub payload: serde_json::Value,
}

#[derive(Serialize, sqlx::FromRow)]
pub struct AuditEvent {
    pub seq: i64,
    pub event_id: Uuid,
    pub org_id: Uuid,
    pub site_id: Option<Uuid>,
    pub actor_user_id: Uuid,
    pub device_id: Uuid,
    pub event_type: String,
    pub entity_type: String,
    pub entity_id: Uuid,
    pub occurred_at: DateTime<Utc>,
    pub received_at: DateTime<Utc>,
    pub schema_version: i32,
    pub payload: serde_json::Value,
}

#[derive(Serialize)]
pub struct BootstrapResponse {
    pub residents: Vec<serde_json::Value>,
    pub medication_orders: Vec<serde_json::Value>,
    pub mar_entries: Vec<serde_json::Value>,
    pub administrations: Vec<serde_json::Value>,
    pub cursor: i64,
}
