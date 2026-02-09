use crate::{auth::{hash_token, issue_access_token}, models::{LoginRequest, LoginResponse, RefreshRequest}, AppState};
use argon2::{Argon2, PasswordHash, PasswordVerifier};
use axum::{extract::{Json, State}, http::StatusCode};
use chrono::{Duration, Utc};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(FromRow)]
struct UserRow {
    user_id: Uuid,
    org_id: Uuid,
    password_hash: String,
    system_privileges: Vec<String>,
}

#[derive(FromRow)]
struct RefreshRow {
    user_id: Uuid,
    org_id: Uuid,
    system_privileges: Vec<String>,
}

pub async fn login(
    State(state): State<AppState>,
    Json(payload): Json<LoginRequest>,
) -> Result<Json<LoginResponse>, (StatusCode, String)> {
    let user = sqlx::query_as::<_, UserRow>(
        "SELECT user_id, org_id, password_hash, system_privileges FROM users WHERE username = $1 AND is_active = true",
    )
    .bind(&payload.username)
    .fetch_optional(&state.db)
    .await
    .map_err(internal_error)?
    .ok_or_else(|| (StatusCode::UNAUTHORIZED, "invalid credentials".to_string()))?;

    let parsed_hash = PasswordHash::new(&user.password_hash)
        .map_err(|_| (StatusCode::UNAUTHORIZED, "invalid credentials".to_string()))?;
    Argon2::default()
        .verify_password(payload.password.as_bytes(), &parsed_hash)
        .map_err(|_| (StatusCode::UNAUTHORIZED, "invalid credentials".to_string()))?;

    let access_token = issue_access_token(
        &state,
        &user.user_id,
        &user.org_id,
        &user.system_privileges,
    )?;

    let refresh_token = Uuid::new_v4().to_string();
    let token_hash = hash_token(&refresh_token);
    let expires_at = Utc::now() + Duration::days(state.config.refresh_token_ttl_days);

    sqlx::query(
        "INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)",
    )
    .bind(user.user_id)
    .bind(token_hash)
    .bind(expires_at)
    .execute(&state.db)
    .await
    .map_err(internal_error)?;

    Ok(Json(LoginResponse {
        access_token,
        refresh_token,
        token_type: "Bearer".to_string(),
        expires_in: state.config.access_token_ttl_minutes * 60,
    }))
}

pub async fn refresh(
    State(state): State<AppState>,
    Json(payload): Json<RefreshRequest>,
) -> Result<Json<LoginResponse>, (StatusCode, String)> {
    let token_hash = hash_token(&payload.refresh_token);
    let record = sqlx::query_as::<_, RefreshRow>(
        "SELECT rt.user_id, u.org_id, u.system_privileges\n         FROM refresh_tokens rt\n         JOIN users u ON u.user_id = rt.user_id\n         WHERE rt.token_hash = $1 AND rt.revoked_at IS NULL AND rt.expires_at > now()",
    )
    .bind(&token_hash)
    .fetch_optional(&state.db)
    .await
    .map_err(internal_error)?
    .ok_or_else(|| (StatusCode::UNAUTHORIZED, "invalid refresh token".to_string()))?;

    sqlx::query("UPDATE refresh_tokens SET revoked_at = now() WHERE token_hash = $1")
        .bind(&token_hash)
        .execute(&state.db)
        .await
        .map_err(internal_error)?;

    let access_token = issue_access_token(
        &state,
        &record.user_id,
        &record.org_id,
        &record.system_privileges,
    )?;

    let new_refresh_token = Uuid::new_v4().to_string();
    let new_hash = hash_token(&new_refresh_token);
    let expires_at = Utc::now() + Duration::days(state.config.refresh_token_ttl_days);

    sqlx::query(
        "INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)",
    )
    .bind(record.user_id)
    .bind(new_hash)
    .bind(expires_at)
    .execute(&state.db)
    .await
    .map_err(internal_error)?;

    Ok(Json(LoginResponse {
        access_token,
        refresh_token: new_refresh_token,
        token_type: "Bearer".to_string(),
        expires_in: state.config.access_token_ttl_minutes * 60,
    }))
}

fn internal_error(err: impl std::fmt::Display) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, err.to_string())
}
