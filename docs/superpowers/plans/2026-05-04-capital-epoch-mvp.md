# 资本纪元 MVP（阶段 1-2）Implementation Plan
 
> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
 
**Goal:** 产出一个可本地运行的 MVP 基础闭环：数据库可启动并初始化；后端提供健康检查 + 注册/登录/me + 资产总览；Flutter 可登录并展示资产摘要。
 
**Architecture:** 单仓单体（Flutter 客户端 + Rust API 服务 + PostgreSQL）。先按“数据库 → 后端 → 前端”顺序打通闭环，再进入股票/IPO/新闻等后续阶段。
 
**Tech Stack:** Flutter（go_router/riverpod/dio/shared_preferences）、Rust（axum/tokio/sqlx/postgres/jwt/argon2/tracing）、PostgreSQL（docker compose）。
 
---
 
## Repository 现状与落地约定
 
- 当前仓库主要为开发包文档与数据库草案，尚无可运行工程代码：见 [README.md](file:///workspace/%E8%B5%84%E6%9C%AC%E7%BA%AA%E5%85%83_%E5%BC%80%E5%8F%91%E5%8C%85/README.md)。
- 技术栈与开发顺序已经在文档里固定：先建库 → Rust API 骨架 → Flutter 骨架：见 [06_项目脚手架与初始化命令.md](file:///workspace/%E8%B5%84%E6%9C%AC%E7%BA%AA%E5%85%83_%E5%BC%80%E5%8F%91%E5%8C%85/06_%E9%A1%B9%E7%9B%AE%E8%84%9A%E6%89%8B%E6%9E%B6%E4%B8%8E%E5%88%9D%E5%A7%8B%E5%8C%96%E5%91%BD%E4%BB%A4.md) 与 [05_开发顺序与里程碑.md](file:///workspace/%E8%B5%84%E6%9C%AC%E7%BA%AA%E5%85%83_%E5%BC%80%E5%8F%91%E5%8C%85/05_%E5%BC%80%E5%8F%91%E9%A1%BA%E5%BA%8F%E4%B8%8E%E9%87%8C%E7%A8%8B%E7%A2%91.md)。
 
本计划假设最终仓库采用文档建议结构（你也可以改名，但需保持三层边界不变）：
 
```text
/workspace/
  capital-epoch/
    mobile_web_app/     # Flutter
    backend_api/        # Rust
    infra/              # docker-compose + .env
    docs/               # 复制开发包文档
```
 
---
 
### Task 0: 建立工程目录骨架（一次性准备）
 
**Files:**
- Create: `capital-epoch/`
- Create: `capital-epoch/infra/`
- Create: `capital-epoch/docs/`
 
- [ ] **Step 1: 创建工程目录**
 
Run:
```bash
mkdir -p capital-epoch/{infra,docs}
```
 
- [ ] **Step 2: 复制开发包文档到工程 docs**
 
Run:
```bash
cp -r "资本纪元_开发包" "capital-epoch/docs/资本纪元_开发包"
```
 
- [ ] **Step 3: 复制 infra 文件（docker-compose 与 env 示例）**
 
Run:
```bash
cp "资本纪元_开发包/docker-compose.yml" "capital-epoch/infra/docker-compose.yml"
cp "资本纪元_开发包/.env.example" "capital-epoch/infra/.env.example"
```
 
---
 
### Task 1: 数据库（PostgreSQL）本地启动与初始化
 
**Files:**
- Use: `capital-epoch/infra/docker-compose.yml`
- Use: `capital-epoch/docs/资本纪元_开发包/02_数据库初始化草案.sql`
 
- [ ] **Step 1: 启动 PostgreSQL**
 
Run:
```bash
cd capital-epoch/infra && docker compose up -d
```
 
Expected: 容器 `capital_epoch_postgres` 正常启动（配置来自 [docker-compose.yml](file:///workspace/%E8%B5%84%E6%9C%AC%E7%BA%AA%E5%85%83_%E5%BC%80%E5%8F%91%E5%8C%85/docker-compose.yml)）。
 
- [ ] **Step 2: 执行首版建表 SQL**
 
Run:
```bash
psql postgresql://capital_epoch:capital_epoch@localhost:5432/capital_epoch -f "capital-epoch/docs/资本纪元_开发包/02_数据库初始化草案.sql"
```
 
- [ ] **Step 3: 验证关键表存在**
 
Run:
```bash
psql postgresql://capital_epoch:capital_epoch@localhost:5432/capital_epoch -c "\dt"
```
 
Expected: 至少包含 `users`、`wallets`、`wallet_ledger`（草案见 [02_数据库初始化草案.sql](file:///workspace/%E8%B5%84%E6%9C%AC%E7%BA%AA%E5%85%83_%E5%BC%80%E5%8F%91%E5%8C%85/02_%E6%95%B0%E6%8D%AE%E5%BA%93%E5%88%9D%E5%A7%8B%E5%8C%96%E8%8D%89%E6%A1%88.sql)）。
 
---
 
### Task 2: 后端（Rust）阶段 1 — Health + 配置 + DB 连接
 
**Files:**
- Create: `capital-epoch/backend_api/`（Rust crate）
- Create: `capital-epoch/backend_api/.env`（本地开发）
- Create: `capital-epoch/backend_api/src/main.rs`
- Create: `capital-epoch/backend_api/src/app/state.rs`
- Create: `capital-epoch/backend_api/src/app/error.rs`
- Create: `capital-epoch/backend_api/src/router/mod.rs`
- Create: `capital-epoch/backend_api/src/handlers/health.rs`
 
- [ ] **Step 1: 初始化 Rust 工程**
 
Run:
```bash
cd capital-epoch && cargo new backend_api
```
 
- [ ] **Step 2: 配置依赖（按文档建议）**
 
Edit `capital-epoch/backend_api/Cargo.toml`：
```toml
[package]
name = "backend_api"
version = "0.1.0"
edition = "2021"

[dependencies]
anyhow = "1"
argon2 = "0.5"
axum = "0.8"
chrono = { version = "0.4", features = ["serde"] }
dotenvy = "0.15"
jsonwebtoken = "9"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
sqlx = { version = "0.8", features = ["runtime-tokio-rustls", "postgres", "uuid", "chrono"] }
thiserror = "2"
tokio = { version = "1", features = ["full"] }
tower-http = { version = "0.6", features = ["cors", "trace"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
uuid = { version = "1", features = ["v4", "serde"] }
```
 
- [ ] **Step 3: 增加本地 .env（不要提交到仓库）**
 
Create `capital-epoch/backend_api/.env`（值参考 [`.env.example`](file:///workspace/%E8%B5%84%E6%9C%AC%E7%BA%AA%E5%85%83_%E5%BC%80%E5%8F%91%E5%8C%85/.env.example)）：
```dotenv
APP_ENV=local
APP_HOST=0.0.0.0
APP_PORT=8080
DATABASE_URL=postgres://capital_epoch:capital_epoch@localhost:5432/capital_epoch
JWT_SECRET=change_me_in_local_dev
```
 
- [ ] **Step 4: 实现最小可运行服务（/health）**
 
Create `capital-epoch/backend_api/src/app/state.rs`：
```rust
use sqlx::PgPool;

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub jwt_secret: String,
}
```
 
Create `capital-epoch/backend_api/src/app/error.rs`：
```rust
use axum::{http::StatusCode, response::IntoResponse, Json};
use serde::Serialize;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum AppError {
    #[error("bad request: {0}")]
    BadRequest(String),
    #[error("unauthorized")]
    Unauthorized,
    #[error("internal")]
    Internal,
}

#[derive(Serialize)]
pub struct ApiResponse<T>
where
    T: Serialize,
{
    pub code: i32,
    pub message: String,
    pub data: Option<T>,
}

impl<T> ApiResponse<T>
where
    T: Serialize,
{
    pub fn ok(data: T) -> Self {
        Self {
            code: 0,
            message: "ok".to_string(),
            data: Some(data),
        }
    }

    pub fn err(code: i32, message: impl Into<String>) -> ApiResponse<serde_json::Value> {
        ApiResponse {
            code,
            message: message.into(),
            data: None,
        }
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
        let (status, body) = match self {
            AppError::BadRequest(msg) => (StatusCode::BAD_REQUEST, ApiResponse::<serde_json::Value>::err(4001, msg)),
            AppError::Unauthorized => (StatusCode::UNAUTHORIZED, ApiResponse::<serde_json::Value>::err(4010, "unauthorized")),
            AppError::Internal => (StatusCode::INTERNAL_SERVER_ERROR, ApiResponse::<serde_json::Value>::err(5000, "internal")),
        };
        (status, Json(body)).into_response()
    }
}
```
 
Create `capital-epoch/backend_api/src/handlers/health.rs`：
```rust
use axum::Json;
use serde::Serialize;

#[derive(Serialize)]
pub struct HealthResponse {
    pub status: &'static str,
}

pub async fn health() -> Json<HealthResponse> {
    Json(HealthResponse { status: "ok" })
}
```
 
Create `capital-epoch/backend_api/src/router/mod.rs`：
```rust
use axum::{routing::get, Router};

use crate::{app::state::AppState, handlers::health::health};

pub fn build_router(state: AppState) -> Router {
    Router::new().route("/health", get(health)).with_state(state)
}
```
 
Create `capital-epoch/backend_api/src/main.rs`：
```rust
mod app {
    pub mod error;
    pub mod state;
}

mod handlers {
    pub mod health;
}

mod router;

use anyhow::Context;
use dotenvy::dotenv;
use sqlx::PgPool;
use std::{env, net::SocketAddr};
use tower_http::{cors::CorsLayer, trace::TraceLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use crate::app::state::AppState;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenv().ok();

    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| "info".into()))
        .with(tracing_subscriber::fmt::layer())
        .init();

    let host = env::var("APP_HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
    let port: u16 = env::var("APP_PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse()
        .context("APP_PORT must be u16")?;
    let database_url = env::var("DATABASE_URL").context("DATABASE_URL is required")?;
    let jwt_secret = env::var("JWT_SECRET").unwrap_or_else(|_| "change_me".to_string());

    let db = PgPool::connect(&database_url).await.context("connect db")?;
    let state = AppState { db, jwt_secret };

    let app = router::build_router(state)
        .layer(CorsLayer::permissive())
        .layer(TraceLayer::new_for_http());

    let addr: SocketAddr = format!("{host}:{port}").parse().context("invalid APP_HOST/APP_PORT")?;
    let listener = tokio::net::TcpListener::bind(addr).await.context("bind")?;
    axum::serve(listener, app).await.context("serve")?;
    Ok(())
}
```
 
- [ ] **Step 5: 本地运行并验证 /health**
 
Run:
```bash
cd capital-epoch/backend_api && cargo run
```
 
In another terminal:
```bash
curl -s http://localhost:8080/health
```
 
Expected:
```json
{"status":"ok"}
```
 
---
 
### Task 3: 后端（Rust）阶段 2 — 认证与资产闭环（auth + portfolio summary）
 
**Files:**
- Create: `capital-epoch/backend_api/src/handlers/auth.rs`
- Create: `capital-epoch/backend_api/src/handlers/portfolio.rs`
- Create: `capital-epoch/backend_api/src/services/auth_service.rs`
- Create: `capital-epoch/backend_api/src/services/portfolio_service.rs`
- Create: `capital-epoch/backend_api/src/repos/user_repo.rs`
- Create: `capital-epoch/backend_api/src/repos/wallet_repo.rs`
- Create: `capital-epoch/backend_api/src/router/auth.rs`
- Modify: `capital-epoch/backend_api/src/router/mod.rs`
 
**API 参考**：见 [03_后端API与服务设计.md](file:///workspace/%E8%B5%84%E6%9C%AC%E7%BA%AA%E5%85%83_%E5%BC%80%E5%8F%91%E5%8C%85/03_%E5%90%8E%E7%AB%AFAPI%E4%B8%8E%E6%9C%8D%E5%8A%A1%E8%AE%BE%E8%AE%A1.md)。
 
- [ ] **Step 1: 定义 auth handler（register/login/me）请求与响应结构**
 
Create `capital-epoch/backend_api/src/handlers/auth.rs`：
```rust
use axum::{extract::State, http::HeaderMap, Json};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{
    app::{error::AppError, state::AppState},
    services::auth_service::{AuthService, AuthTokens},
};

#[derive(Deserialize)]
pub struct RegisterRequest {
    pub username: String,
    pub display_name: String,
    pub password: String,
}

#[derive(Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Serialize)]
pub struct UserDto {
    pub id: Uuid,
    pub username: String,
    pub display_name: String,
}

#[derive(Serialize)]
pub struct AuthResponse {
    pub user: UserDto,
    pub access_token: String,
    pub refresh_token: String,
}

pub async fn register(State(state): State<AppState>, Json(req): Json<RegisterRequest>) -> Result<Json<crate::app::error::ApiResponse<AuthResponse>>, AppError> {
    let svc = AuthService::new(state.clone());
    let (user, tokens) = svc.register(req.username, req.display_name, req.password).await?;
    Ok(Json(crate::app::error::ApiResponse::ok(AuthResponse {
        user: UserDto {
            id: user.id,
            username: user.username,
            display_name: user.display_name,
        },
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
    })))
}

pub async fn login(State(state): State<AppState>, Json(req): Json<LoginRequest>) -> Result<Json<crate::app::error::ApiResponse<AuthResponse>>, AppError> {
    let svc = AuthService::new(state.clone());
    let (user, tokens) = svc.login(req.username, req.password).await?;
    Ok(Json(crate::app::error::ApiResponse::ok(AuthResponse {
        user: UserDto {
            id: user.id,
            username: user.username,
            display_name: user.display_name,
        },
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
    })))
}

pub async fn me(State(state): State<AppState>, headers: HeaderMap) -> Result<Json<crate::app::error::ApiResponse<UserDto>>, AppError> {
    let svc = AuthService::new(state);
    let user = svc.me(headers).await?;
    Ok(Json(crate::app::error::ApiResponse::ok(UserDto {
        id: user.id,
        username: user.username,
        display_name: user.display_name,
    })))
}
```
 
- [ ] **Step 2: 实现 AuthService（JWT + argon2）**
 
Create `capital-epoch/backend_api/src/services/auth_service.rs`：
```rust
use argon2::{password_hash::SaltString, Argon2, PasswordHash, PasswordHasher, PasswordVerifier};
use axum::http::HeaderMap;
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, Algorithm, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{
    app::{error::AppError, state::AppState},
    repos::user_repo::{NewUser, User, UserRepo},
};

pub struct AuthService {
    state: AppState,
}

#[derive(Clone)]
pub struct AuthTokens {
    pub access_token: String,
    pub refresh_token: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct AccessClaims {
    sub: String,
    exp: usize,
}

impl AuthService {
    pub fn new(state: AppState) -> Self {
        Self { state }
    }

    pub async fn register(&self, username: String, display_name: String, password: String) -> Result<(User, AuthTokens), AppError> {
        if username.trim().is_empty() || password.trim().is_empty() {
            return Err(AppError::BadRequest("username/password required".to_string()));
        }

        let salt = SaltString::generate(&mut rand::thread_rng());
        let password_hash = Argon2::default()
            .hash_password(password.as_bytes(), &salt)
            .map_err(|_| AppError::Internal)?
            .to_string();

        let repo = UserRepo::new(self.state.db.clone());
        let user = repo
            .create_user(NewUser {
                username,
                display_name,
                password_hash,
            })
            .await?;

        let tokens = self.issue_tokens(user.id)?;
        Ok((user, tokens))
    }

    pub async fn login(&self, username: String, password: String) -> Result<(User, AuthTokens), AppError> {
        let repo = UserRepo::new(self.state.db.clone());
        let user = repo.find_by_username(&username).await?.ok_or_else(|| AppError::Unauthorized)?;

        let parsed = PasswordHash::new(&user.password_hash).map_err(|_| AppError::Internal)?;
        Argon2::default()
            .verify_password(password.as_bytes(), &parsed)
            .map_err(|_| AppError::Unauthorized)?;

        let tokens = self.issue_tokens(user.id)?;
        Ok((user, tokens))
    }

    pub async fn me(&self, headers: HeaderMap) -> Result<User, AppError> {
        let user_id = self.parse_bearer(headers)?;
        let repo = UserRepo::new(self.state.db.clone());
        repo.find_by_id(user_id).await?.ok_or_else(|| AppError::Unauthorized)
    }

    fn issue_tokens(&self, user_id: Uuid) -> Result<AuthTokens, AppError> {
        let exp = (Utc::now() + Duration::hours(2)).timestamp() as usize;
        let claims = AccessClaims {
            sub: user_id.to_string(),
            exp,
        };

        let access_token = encode(
            &Header::new(Algorithm::HS256),
            &claims,
            &EncodingKey::from_secret(self.state.jwt_secret.as_bytes()),
        )
        .map_err(|_| AppError::Internal)?;

        let refresh_token = Uuid::new_v4().to_string();

        Ok(AuthTokens {
            access_token,
            refresh_token,
        })
    }

    fn parse_bearer(&self, headers: HeaderMap) -> Result<Uuid, AppError> {
        let auth = headers
            .get(axum::http::header::AUTHORIZATION)
            .and_then(|h| h.to_str().ok())
            .ok_or_else(|| AppError::Unauthorized)?;

        let token = auth.strip_prefix("Bearer ").ok_or_else(|| AppError::Unauthorized)?;

        let decoded = decode::<AccessClaims>(
            token,
            &DecodingKey::from_secret(self.state.jwt_secret.as_bytes()),
            &Validation::new(Algorithm::HS256),
        )
        .map_err(|_| AppError::Unauthorized)?;

        Uuid::parse_str(&decoded.claims.sub).map_err(|_| AppError::Unauthorized)
    }
}
```
 
依赖补充：AuthService 使用到 `rand`，在 `Cargo.toml` 追加：
```toml
rand = "0.8"
```
 
- [ ] **Step 3: 实现 UserRepo（users + wallets 初始化）**
 
Create `capital-epoch/backend_api/src/repos/user_repo.rs`：
```rust
use sqlx::PgPool;
use uuid::Uuid;

use crate::app::error::AppError;

#[derive(Clone)]
pub struct UserRepo {
    db: PgPool,
}

pub struct NewUser {
    pub username: String,
    pub display_name: String,
    pub password_hash: String,
}

pub struct User {
    pub id: Uuid,
    pub username: String,
    pub display_name: String,
    pub password_hash: String,
}

impl UserRepo {
    pub fn new(db: PgPool) -> Self {
        Self { db }
    }

    pub async fn create_user(&self, new_user: NewUser) -> Result<User, AppError> {
        let mut tx = self.db.begin().await.map_err(|_| AppError::Internal)?;

        let user = sqlx::query_as::<_, (Uuid, String, String, String)>(
            r#"
            insert into users (username, display_name, password_hash)
            values ($1, $2, $3)
            returning id, username, display_name, password_hash
            "#,
        )
        .bind(&new_user.username)
        .bind(&new_user.display_name)
        .bind(&new_user.password_hash)
        .fetch_one(&mut *tx)
        .await
        .map_err(|_| AppError::BadRequest("username already exists".to_string()))?;

        let user_id = user.0;

        sqlx::query(
            r#"
            insert into wallets (user_id, available_cash, frozen_cash, total_asset_snapshot)
            values ($1, 1000000, 0, 1000000)
            "#,
        )
        .bind(user_id)
        .execute(&mut *tx)
        .await
        .map_err(|_| AppError::Internal)?;

        tx.commit().await.map_err(|_| AppError::Internal)?;

        Ok(User {
            id: user.0,
            username: user.1,
            display_name: user.2,
            password_hash: user.3,
        })
    }

    pub async fn find_by_username(&self, username: &str) -> Result<Option<User>, AppError> {
        let row = sqlx::query_as::<_, (Uuid, String, String, String)>(
            r#"
            select id, username, display_name, password_hash
            from users
            where username = $1
            "#,
        )
        .bind(username)
        .fetch_optional(&self.db)
        .await
        .map_err(|_| AppError::Internal)?;

        Ok(row.map(|u| User {
            id: u.0,
            username: u.1,
            display_name: u.2,
            password_hash: u.3,
        }))
    }

    pub async fn find_by_id(&self, user_id: Uuid) -> Result<Option<User>, AppError> {
        let row = sqlx::query_as::<_, (Uuid, String, String, String)>(
            r#"
            select id, username, display_name, password_hash
            from users
            where id = $1
            "#,
        )
        .bind(user_id)
        .fetch_optional(&self.db)
        .await
        .map_err(|_| AppError::Internal)?;

        Ok(row.map(|u| User {
            id: u.0,
            username: u.1,
            display_name: u.2,
            password_hash: u.3,
        }))
    }
}
```
 
- [ ] **Step 4: 实现 PortfolioSummary（钱包资产摘要）**
 
Create `capital-epoch/backend_api/src/handlers/portfolio.rs`：
```rust
use axum::{extract::State, http::HeaderMap, Json};
use serde::Serialize;

use crate::{
    app::{error::AppError, state::AppState},
    services::{auth_service::AuthService, portfolio_service::PortfolioService},
};

#[derive(Serialize)]
pub struct PortfolioSummaryResponse {
    pub total_asset: String,
    pub available_cash: String,
    pub frozen_cash: String,
}

pub async fn summary(State(state): State<AppState>, headers: HeaderMap) -> Result<Json<crate::app::error::ApiResponse<PortfolioSummaryResponse>>, AppError> {
    let auth = AuthService::new(state.clone());
    let user = auth.me(headers).await?;

    let svc = PortfolioService::new(state);
    let s = svc.summary(user.id).await?;
    Ok(Json(crate::app::error::ApiResponse::ok(PortfolioSummaryResponse {
        total_asset: s.total_asset,
        available_cash: s.available_cash,
        frozen_cash: s.frozen_cash,
    })))
}
```
 
Create `capital-epoch/backend_api/src/services/portfolio_service.rs`：
```rust
use uuid::Uuid;

use crate::{
    app::{error::AppError, state::AppState},
    repos::wallet_repo::WalletRepo,
};

pub struct PortfolioService {
    state: AppState,
}

pub struct PortfolioSummary {
    pub total_asset: String,
    pub available_cash: String,
    pub frozen_cash: String,
}

impl PortfolioService {
    pub fn new(state: AppState) -> Self {
        Self { state }
    }

    pub async fn summary(&self, user_id: Uuid) -> Result<PortfolioSummary, AppError> {
        let repo = WalletRepo::new(self.state.db.clone());
        let w = repo.get_wallet(user_id).await?;
        Ok(PortfolioSummary {
            total_asset: w.total_asset_snapshot,
            available_cash: w.available_cash,
            frozen_cash: w.frozen_cash,
        })
    }
}
```
 
Create `capital-epoch/backend_api/src/repos/wallet_repo.rs`：
```rust
use sqlx::PgPool;
use uuid::Uuid;

use crate::app::error::AppError;

#[derive(Clone)]
pub struct WalletRepo {
    db: PgPool,
}

pub struct Wallet {
    pub available_cash: String,
    pub frozen_cash: String,
    pub total_asset_snapshot: String,
}

impl WalletRepo {
    pub fn new(db: PgPool) -> Self {
        Self { db }
    }

    pub async fn get_wallet(&self, user_id: Uuid) -> Result<Wallet, AppError> {
        let row = sqlx::query_as::<_, (String, String, String)>(
            r#"
            select available_cash::text, frozen_cash::text, total_asset_snapshot::text
            from wallets
            where user_id = $1
            "#,
        )
        .bind(user_id)
        .fetch_one(&self.db)
        .await
        .map_err(|_| AppError::Internal)?;

        Ok(Wallet {
            available_cash: row.0,
            frozen_cash: row.1,
            total_asset_snapshot: row.2,
        })
    }
}
```
 
- [ ] **Step 5: 组装路由**
 
Create `capital-epoch/backend_api/src/router/auth.rs`：
```rust
use axum::{routing::{get, post}, Router};

use crate::{app::state::AppState, handlers::auth::{login, me, register}};

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/api/v1/auth/register", post(register))
        .route("/api/v1/auth/login", post(login))
        .route("/api/v1/auth/me", get(me))
}
```
 
Modify `capital-epoch/backend_api/src/router/mod.rs`：
```rust
use axum::{routing::get, Router};

use crate::{
    app::state::AppState,
    handlers::{health::health, portfolio::summary},
};

mod auth;

pub fn build_router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(health))
        .route("/api/v1/portfolio/summary", get(summary))
        .merge(auth::routes())
        .with_state(state)
}
```
 
同时在 `main.rs` 增加模块声明（与实际文件保持一致）：
```rust
mod repos {
    pub mod user_repo;
    pub mod wallet_repo;
}

mod services {
    pub mod auth_service;
    pub mod portfolio_service;
}

mod handlers {
    pub mod auth;
    pub mod health;
    pub mod portfolio;
}
```
 
- [ ] **Step 6: 手工联调（register → login → summary）**
 
Run:
```bash
cd capital-epoch/backend_api && cargo run
```
 
Register:
```bash
curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H 'content-type: application/json' \
  -d '{"username":"player001","display_name":"玩家001","password":"pass1234"}'
```
 
Login:
```bash
curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H 'content-type: application/json' \
  -d '{"username":"player001","password":"pass1234"}'
```
 
把返回里的 `access_token` 放入 Bearer 请求资产摘要：
```bash
curl -s http://localhost:8080/api/v1/portfolio/summary \
  -H "authorization: Bearer <ACCESS_TOKEN>"
```
 
Expected: `code=0` 且 `available_cash` 非空。
 
---
 
### Task 4: 前端（Flutter）阶段 1-2 — 登录与资产页联调
 
**Files:**
- Create: `capital-epoch/mobile_web_app/`（Flutter app）
- Create: `capital-epoch/mobile_web_app/lib/main.dart`
- Create: `capital-epoch/mobile_web_app/lib/app/app.dart`
- Create: `capital-epoch/mobile_web_app/lib/app/router.dart`
- Create: `capital-epoch/mobile_web_app/lib/core/network/dio_client.dart`
- Create: `capital-epoch/mobile_web_app/lib/core/constants/api.dart`
- Create: `capital-epoch/mobile_web_app/lib/features/auth/presentation/login_page.dart`
- Create: `capital-epoch/mobile_web_app/lib/features/auth/presentation/register_page.dart`
- Create: `capital-epoch/mobile_web_app/lib/features/portfolio/presentation/portfolio_page.dart`
 
- [ ] **Step 1: 初始化 Flutter 工程**
 
Run:
```bash
cd capital-epoch && flutter create mobile_web_app
```
 
- [ ] **Step 2: 安装依赖（按文档建议）**
 
Run:
```bash
cd capital-epoch/mobile_web_app && flutter pub add go_router flutter_riverpod dio shared_preferences
```
 
- [ ] **Step 3: 定义 API_BASE_URL（用 dart-define，不引入额外 env 包）**
 
Create `capital-epoch/mobile_web_app/lib/core/constants/api.dart`：
```dart
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
```
 
- [ ] **Step 4: 创建 Dio Client（带 Authorization Header）**
 
Create `capital-epoch/mobile_web_app/lib/core/network/dio_client.dart`：
```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api.dart';

class DioClient {
  DioClient(this._prefs);

  final SharedPreferences _prefs;

  Dio create() {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    return dio;
  }
}
```
 
- [ ] **Step 5: 配置 Router（login/register/portfolio）**
 
Create `capital-epoch/mobile_web_app/lib/app/router.dart`：
```dart
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/portfolio/presentation/portfolio_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/portfolio', builder: (context, state) => const PortfolioPage()),
    ],
  );
}
```
 
Create `capital-epoch/mobile_web_app/lib/app/app.dart`：
```dart
import 'package:flutter/material.dart';

import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
    return MaterialApp.router(
      title: 'Capital Epoch',
      routerConfig: router,
    );
  }
}
```
 
Create `capital-epoch/mobile_web_app/lib/main.dart`：
```dart
import 'package:flutter/material.dart';

import 'app/app.dart';

void main() {
  runApp(const App());
}
```
 
- [ ] **Step 6: 实现登录/注册（直接调用后端 auth 接口并保存 token）**
 
Create `capital-epoch/mobile_web_app/lib/features/auth/presentation/login_page.dart`：
```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = DioClient(prefs).create();
      final resp = await dio.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {
          'username': _username.text.trim(),
          'password': _password.text,
        },
      );

      final data = resp.data?['data'] as Map<String, dynamic>?;
      final accessToken = data?['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw DioException(requestOptions: RequestOptions(path: '/api/v1/auth/login'));
      }
      await prefs.setString('access_token', accessToken);

      if (!mounted) return;
      context.go('/portfolio');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _username, decoration: const InputDecoration(labelText: '用户名')),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: '密码')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? '登录中...' : '登录'),
            ),
            TextButton(
              onPressed: _loading ? null : () => context.go('/register'),
              child: const Text('去注册'),
            ),
          ],
        ),
      ),
    );
  }
}
```
 
Create `capital-epoch/mobile_web_app/lib/features/auth/presentation/register_page.dart`：
```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _username = TextEditingController();
  final _displayName = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = DioClient(prefs).create();
      final resp = await dio.post<Map<String, dynamic>>(
        '/api/v1/auth/register',
        data: {
          'username': _username.text.trim(),
          'display_name': _displayName.text.trim(),
          'password': _password.text,
        },
      );

      final data = resp.data?['data'] as Map<String, dynamic>?;
      final accessToken = data?['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw DioException(requestOptions: RequestOptions(path: '/api/v1/auth/register'));
      }
      await prefs.setString('access_token', accessToken);

      if (!mounted) return;
      context.go('/portfolio');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _displayName.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _username, decoration: const InputDecoration(labelText: '用户名')),
            TextField(controller: _displayName, decoration: const InputDecoration(labelText: '昵称')),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: '密码')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? '注册中...' : '注册'),
            ),
          ],
        ),
      ),
    );
  }
}
```
 
- [ ] **Step 7: 实现资产页（调用 /portfolio/summary）**
 
Create `capital-epoch/mobile_web_app/lib/features/portfolio/presentation/portfolio_page.dart`：
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  String? _availableCash;
  String? _frozenCash;
  String? _totalAsset;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final dio = DioClient(prefs).create();
    final resp = await dio.get<Map<String, dynamic>>('/api/v1/portfolio/summary');
    final data = resp.data?['data'] as Map<String, dynamic>?;
    setState(() {
      _availableCash = data?['available_cash'] as String?;
      _frozenCash = data?['frozen_cash'] as String?;
      _totalAsset = data?['total_asset'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('资产总览')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('总资产: ${_totalAsset ?? '-'}'),
            Text('可用现金: ${_availableCash ?? '-'}'),
            Text('冻结现金: ${_frozenCash ?? '-'}'),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('刷新')),
          ],
        ),
      ),
    );
  }
}
```
 
- [ ] **Step 8: 运行 Flutter 并联调后端**
 
Run（Web）：
```bash
cd capital-epoch/mobile_web_app && flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```
 
Expected: 注册/登录成功后进入资产页，能看到 `available_cash` 等字段。
 
---
 
## 后续计划（阶段 3-5 的拆分建议）
 
本计划只覆盖里程碑中的阶段 1-2（骨架 + 账户资产闭环）。后续建议拆成 3 个独立计划分别推进，避免一次性计划过大：
 
1. 阶段 3：股票交易闭环（stock + order + matching + 持仓更新）— 对事务一致性要求最高。
2. 阶段 4：新闻与 IPO 闭环（news + ipo）— 需要冻结/退款流程与后台任务雏形。
3. 阶段 5：信用与银行基础版（credit + bank）— 业务细节多，适合单独拆解。
 
