use argon2::{password_hash::{PasswordHasher, SaltString}, Argon2};
use dotenvy::dotenv;
use rand::rngs::OsRng;
use sqlx::PgPool;
use uuid::Uuid;

fn parse_arg(flag: &str) -> Option<String> {
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        if arg == flag {
            return args.next();
        }
    }
    None
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenv().ok();
    let database_url = std::env::var("DATABASE_URL")?;

    let username = parse_arg("--username").expect("--username required");
    let password = parse_arg("--password").expect("--password required");
    let org_id = parse_arg("--org-id").expect("--org-id required");
    let first_name = parse_arg("--first-name").unwrap_or_else(|| "".to_string());
    let last_name = parse_arg("--last-name").unwrap_or_else(|| "".to_string());
    let job_role = parse_arg("--job-role").unwrap_or_else(|| "nurse".to_string());
    let privileges_raw = parse_arg("--privileges").unwrap_or_else(|| "nurse".to_string());
    let privileges: Vec<String> = privileges_raw
        .split(',')
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();

    let org_id = Uuid::parse_str(&org_id)?;
    let salt = SaltString::generate(&mut OsRng);
    let password_hash = Argon2::default()
        .hash_password(password.as_bytes(), &salt)
        .map_err(|e| anyhow::anyhow!(e.to_string()))?
        .to_string();

    let pool = PgPool::connect(&database_url).await?;
    let user_id = Uuid::new_v4();

    sqlx::query(
        "INSERT INTO users (user_id, org_id, username, password_hash, first_name, last_name, job_role, system_privileges) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
    )
    .bind(user_id)
    .bind(org_id)
    .bind(username)
    .bind(password_hash)
    .bind(first_name)
    .bind(last_name)
    .bind(job_role)
    .bind(privileges)
    .execute(&pool)
    .await?;

    println!("Created user {user_id}");
    Ok(())
}
