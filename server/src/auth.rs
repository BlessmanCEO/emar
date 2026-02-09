use crate::{config::Config, AppState};
use axum::{async_trait, extract::FromRequestParts, http::{header, request::Parts, StatusCode}};
use chrono::Utc;
use jsonwebtoken::{decode, encode, Algorithm, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize)]
pub struct AccessClaims {
    pub sub: String,
    pub org_id: String,
    pub roles: Vec<String>,
    pub iat: usize,
    pub exp: usize,
}

#[derive(Clone, Debug)]
#[allow(dead_code)]
pub struct AuthUser {
    pub user_id: Uuid,
    pub org_id: Uuid,
    pub roles: Vec<String>,
}

#[async_trait]
impl FromRequestParts<AppState> for AuthUser {
    type Rejection = (StatusCode, String);

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        let auth_header = parts
            .headers
            .get(header::AUTHORIZATION)
            .and_then(|v| v.to_str().ok())
            .ok_or_else(|| (StatusCode::UNAUTHORIZED, "missing authorization".to_string()))?;

        let token = auth_header
            .strip_prefix("Bearer ")
            .ok_or_else(|| (StatusCode::UNAUTHORIZED, "invalid authorization".to_string()))?;

        let claims = decode_access_token(token, &state.config)
            .map_err(|_| (StatusCode::UNAUTHORIZED, "invalid token".to_string()))?;

        let user_id = Uuid::parse_str(&claims.sub)
            .map_err(|_| (StatusCode::UNAUTHORIZED, "invalid token".to_string()))?;
        let org_id = Uuid::parse_str(&claims.org_id)
            .map_err(|_| (StatusCode::UNAUTHORIZED, "invalid token".to_string()))?;

        Ok(AuthUser {
            user_id,
            org_id,
            roles: claims.roles,
        })
    }
}

pub fn issue_access_token(
    state: &AppState,
    user_id: &Uuid,
    org_id: &Uuid,
    roles: &[String],
) -> Result<String, (StatusCode, String)> {
    let now = Utc::now().timestamp() as usize;
    let exp = now + (state.config.access_token_ttl_minutes as usize * 60);
    let claims = AccessClaims {
        sub: user_id.to_string(),
        org_id: org_id.to_string(),
        roles: roles.to_vec(),
        iat: now,
        exp,
    };
    encode(
        &Header::new(Algorithm::HS256),
        &claims,
        &EncodingKey::from_secret(state.config.jwt_secret.as_bytes()),
    )
    .map_err(|err| (StatusCode::INTERNAL_SERVER_ERROR, err.to_string()))
}

pub fn decode_access_token(token: &str, config: &Config) -> Result<AccessClaims, jsonwebtoken::errors::Error> {
    let mut validation = Validation::new(Algorithm::HS256);
    validation.validate_exp = true;
    let token_data = decode::<AccessClaims>(
        token,
        &DecodingKey::from_secret(config.jwt_secret.as_bytes()),
        &validation,
    )?;
    Ok(token_data.claims)
}

pub fn hash_token(token: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(token.as_bytes());
    hex::encode(hasher.finalize())
}
