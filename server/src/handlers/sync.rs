use crate::{auth::AuthUser, models::{AuditEvent, AuditEventInput, RejectedEvent, SyncPullParams, SyncPullResponse, SyncPushRequest, SyncPushResponse}, AppState};
use axum::{extract::{Json, Query, State}, http::StatusCode};
use chrono::Utc;

pub async fn push(
    auth: AuthUser,
    State(state): State<AppState>,
    Json(payload): Json<SyncPushRequest>,
) -> Result<Json<SyncPushResponse>, (StatusCode, String)> {
    let mut accepted = Vec::new();
    let mut rejected = Vec::new();

    let mut tx = state.db.begin().await.map_err(internal_error)?;

    for event in payload.events {
        if let Some(rejection) = basic_validate(&auth, &event) {
            rejected.push(rejection);
            continue;
        }

        let result = sqlx::query(
            "INSERT INTO audit_events (event_id, org_id, site_id, actor_user_id, device_id, event_type, entity_type, entity_id, occurred_at, schema_version, payload, received_at)\n             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)\n             ON CONFLICT (event_id) DO NOTHING",
        )
        .bind(event.event_id)
        .bind(event.org_id)
        .bind(event.site_id)
        .bind(event.actor_user_id)
        .bind(event.device_id)
        .bind(&event.event_type)
        .bind(&event.entity_type)
        .bind(event.entity_id)
        .bind(event.occurred_at)
        .bind(event.schema_version)
        .bind(event.payload)
        .bind(Utc::now())
        .execute(&mut *tx)
        .await
        .map_err(internal_error)?;

        if result.rows_affected() == 1 {
            accepted.push(event.event_id);
        } else {
            rejected.push(RejectedEvent {
                event_id: event.event_id,
                code: "duplicate_event_id".to_string(),
                message: "event_id already exists".to_string(),
                field_path: Some("event_id".to_string()),
            });
        }
    }

    tx.commit().await.map_err(internal_error)?;

    Ok(Json(SyncPushResponse { accepted, rejected }))
}

pub async fn pull(
    auth: AuthUser,
    State(state): State<AppState>,
    Query(params): Query<SyncPullParams>,
) -> Result<Json<SyncPullResponse>, (StatusCode, String)> {
    let cursor = params.cursor.unwrap_or(0);
    let limit = params.limit.unwrap_or(200).clamp(1, 500);

    let events = sqlx::query_as::<_, AuditEvent>(
        "SELECT seq, event_id, org_id, site_id, actor_user_id, device_id, event_type, entity_type, entity_id, occurred_at, received_at, schema_version, payload\n         FROM audit_events\n         WHERE org_id = $1 AND seq > $2\n         ORDER BY seq ASC\n         LIMIT $3",
    )
    .bind(auth.org_id)
    .bind(cursor)
    .bind(limit)
    .fetch_all(&state.db)
    .await
    .map_err(internal_error)?;

    let next_cursor = events.last().map(|e| e.seq).unwrap_or(cursor);
    Ok(Json(SyncPullResponse { events, next_cursor }))
}

fn basic_validate(user: &AuthUser, event: &AuditEventInput) -> Option<RejectedEvent> {
    if event.org_id != user.org_id {
        return Some(RejectedEvent {
            event_id: event.event_id,
            code: "org_mismatch".to_string(),
            message: "event org_id does not match token".to_string(),
            field_path: Some("org_id".to_string()),
        });
    }

    if event.event_type.trim().is_empty() {
        return Some(RejectedEvent {
            event_id: event.event_id,
            code: "invalid_event_type".to_string(),
            message: "event_type is required".to_string(),
            field_path: Some("event_type".to_string()),
        });
    }

    if event.entity_type.trim().is_empty() {
        return Some(RejectedEvent {
            event_id: event.event_id,
            code: "invalid_entity_type".to_string(),
            message: "entity_type is required".to_string(),
            field_path: Some("entity_type".to_string()),
        });
    }

    None
}

fn internal_error(err: impl std::fmt::Display) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}
