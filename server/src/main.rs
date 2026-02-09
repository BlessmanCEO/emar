mod auth;
mod config;
mod db;
mod handlers;
mod models;

use axum::{routing::{get, post}, Router};
use config::Config;
use db::init_pool;
use tower_http::{cors::{Any, CorsLayer}, trace::TraceLayer};
use tracing_subscriber::EnvFilter;

#[derive(Clone)]
pub struct AppState {
    pub db: sqlx::PgPool,
    pub config: Config,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let config = Config::from_env()?;
    let db = init_pool(&config.database_url).await?;
    let state = AppState { db, config };

    let bind_addr = state.config.bind_addr.clone();

    let app = Router::new()
        .route("/auth/login", post(handlers::auth::login))
        .route("/auth/refresh", post(handlers::auth::refresh))
        .route("/sync/push", post(handlers::sync::push))
        .route("/sync/pull", get(handlers::sync::pull))
        .route("/bootstrap", get(handlers::bootstrap::bootstrap))
        .with_state(state)
        .layer(TraceLayer::new_for_http())
        .layer(CorsLayer::new().allow_origin(Any).allow_methods(Any).allow_headers(Any));

    let listener = tokio::net::TcpListener::bind(&bind_addr).await?;
    axum::serve(listener, app).await?;
    Ok(())
}
