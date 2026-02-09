use crate::{auth::AuthUser, models::BootstrapResponse, AppState};
use axum::{extract::State, http::StatusCode, Json};

pub async fn bootstrap(
    auth: AuthUser,
    State(state): State<AppState>,
) -> Result<Json<BootstrapResponse>, (StatusCode, String)> {
    let max_seq: i64 = sqlx::query_scalar(
        "SELECT COALESCE(MAX(seq), 0) FROM audit_events WHERE org_id = $1",
    )
    .bind(auth.org_id)
    .fetch_one(&state.db)
    .await
    .map_err(internal_error)?;

    Ok(Json(BootstrapResponse {
        residents: Vec::new(),
        medication_orders: Vec::new(),
        mar_entries: Vec::new(),
        administrations: Vec::new(),
        cursor: max_seq,
    }))
}

fn internal_error(err: impl std::fmt::Display) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}
