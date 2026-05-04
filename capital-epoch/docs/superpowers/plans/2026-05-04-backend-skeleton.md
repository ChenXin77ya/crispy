# Backend Skeleton Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在本地完成后端工程骨架：Docker Compose 启动 PostgreSQL，Rust Axum 服务提供 `GET /health`，并返回 DB 连通性结果。

**Architecture:** `infra/` 提供本地数据库；`backend_api/` 提供单体后端服务，读取环境变量构造 `AppConfig` 与 `AppState(PgPool)`，由 `router` 组装路由，`handlers` 提供 HTTP 入口。

**Tech Stack:** Rust（axum/tokio/sqlx/tracing/tower-http/dotenvy），PostgreSQL（docker compose）

---

## File Map

**Create:**
- `capital-epoch/.gitignore`
- `capital-epoch/infra/docker-compose.yml`
- `capital-epoch/infra/.env.example`
- `capital-epoch/backend_api/Cargo.toml`
- `capital-epoch/backend_api/src/main.rs`
- `capital-epoch/backend_api/src/app/mod.rs`
- `capital-epoch/backend_api/src/app/config.rs`
- `capital-epoch/backend_api/src/app/state.rs`
- `capital-epoch/backend_api/src/router/mod.rs`
- `capital-epoch/backend_api/src/handlers/mod.rs`
- `capital-epoch/backend_api/src/handlers/health.rs`

**Docs (already created in spec step):**
- `capital-epoch/docs/superpowers/specs/2026-05-04-backend-skeleton-design.md`

---

### Task 1: 创建工程目录与基础忽略规则

**Files:**
- Create: `capital-epoch/.gitignore`

- [ ] **Step 1: 创建目录结构**

Run:

```bash
mkdir -p capital-epoch/{backend_api,infra,docs}
```

Expected: `capital-epoch/` 下出现 `backend_api/ infra/ docs/`

- [ ] **Step 2: 添加 `.gitignore`（忽略 `.env` 与 brainstorming 产物）**

Create `capital-epoch/.gitignore`:

```gitignore
.DS_Store

# Local env
.env

# Rust
/capital-epoch/backend_api/target/

# Brainstorming visual companion artifacts
.superpowers/
```

- [ ] **Step 3: 验证目录与忽略文件存在**

Run:

```bash
ls -la capital-epoch
```

Expected: 包含 `.gitignore backend_api infra docs`

- [ ] **Step 4: Commit**

```bash
git add capital-epoch/.gitignore
git commit -m "chore: init monorepo ignore rules"
```

---

### Task 2: 落地 PostgreSQL Docker Compose

**Files:**
- Create: `capital-epoch/infra/docker-compose.yml`
- Create: `capital-epoch/infra/.env.example`

- [ ] **Step 1: 写入 `infra/.env.example`**

Create `capital-epoch/infra/.env.example`:

```dotenv
POSTGRES_DB=capital_epoch
POSTGRES_USER=capital_epoch
POSTGRES_PASSWORD=capital_epoch

# Optional (for host port mapping)
POSTGRES_PORT=5432
```

- [ ] **Step 2: 写入 `infra/docker-compose.yml`**

Create `capital-epoch/infra/docker-compose.yml`:

```yaml
services:
  db:
    image: postgres:16-alpine
    container_name: capital_epoch_db
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    volumes:
      - capital_epoch_pg_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-capital_epoch} -d ${POSTGRES_DB:-capital_epoch}"]
      interval: 2s
      timeout: 5s
      retries: 10

volumes:
  capital_epoch_pg_data:
```

- [ ] **Step 3: 复制 env 并启动数据库**

Run:

```bash
cp capital-epoch/infra/.env.example capital-epoch/infra/.env
docker compose -f capital-epoch/infra/docker-compose.yml --env-file capital-epoch/infra/.env up -d
```

Expected: `db` 容器启动成功

- [ ] **Step 4: 验证数据库健康状态**

Run:

```bash
docker ps --filter "name=capital_epoch_db" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Expected: 状态包含 `healthy`（或至少为 `Up` 并在数秒内变为 `healthy`）

- [ ] **Step 5: Commit**

```bash
git add capital-epoch/infra/docker-compose.yml capital-epoch/infra/.env.example
git commit -m "chore(infra): add postgres compose for local dev"
```

---

### Task 3: 初始化 Rust 后端工程与依赖

**Files:**
- Create: `capital-epoch/backend_api/Cargo.toml`
- Create: `capital-epoch/backend_api/src/main.rs`

- [ ] **Step 1: 创建 Rust crate**

Run:

```bash
cargo new capital-epoch/backend_api
```

Expected: 生成 `Cargo.toml` 与 `src/main.rs`

- [ ] **Step 2: 配置依赖**

Edit `capital-epoch/backend_api/Cargo.toml` to:

```toml
[package]
name = "backend_api"
version = "0.1.0"
edition = "2024"

[dependencies]
anyhow = "1"
axum = "0.8"
dotenvy = "0.15"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
sqlx = { version = "0.8", features = ["runtime-tokio-rustls", "postgres"] }
thiserror = "2"
tokio = { version = "1", features = ["full"] }
tower-http = { version = "0.6", features = ["cors", "trace"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
```

- [ ] **Step 3: 编译通过验证（不启动服务）**

Run:

```bash
cargo check --manifest-path capital-epoch/backend_api/Cargo.toml
```

Expected: Exit code 0

- [ ] **Step 4: Commit**

```bash
git add capital-epoch/backend_api/Cargo.toml
git commit -m "chore(backend): init axum/sqlx project dependencies"
```

---

### Task 4: 添加配置与状态（AppConfig / AppState）

**Files:**
- Create: `capital-epoch/backend_api/src/app/mod.rs`
- Create: `capital-epoch/backend_api/src/app/config.rs`
- Create: `capital-epoch/backend_api/src/app/state.rs`
- Modify: `capital-epoch/backend_api/src/main.rs`

- [ ] **Step 1: 创建 `app/mod.rs`**

Create `capital-epoch/backend_api/src/app/mod.rs`:

```rust
pub mod config;
pub mod state;
```

- [ ] **Step 2: 创建 `AppConfig`**

Create `capital-epoch/backend_api/src/app/config.rs`:

```rust
use anyhow::Context;

#[derive(Clone)]
pub struct AppConfig {
    pub host: String,
    pub port: u16,
    pub database_url: String,
}

impl AppConfig {
    pub fn from_env() -> anyhow::Result<Self> {
        let host = std::env::var("APP_HOST").unwrap_or_else(|_| "0.0.0.0".to_string());
        let port = std::env::var("APP_PORT")
            .ok()
            .and_then(|v| v.parse::<u16>().ok())
            .unwrap_or(3000);
        let database_url = std::env::var("DATABASE_URL").context("DATABASE_URL is required")?;

        Ok(Self {
            host,
            port,
            database_url,
        })
    }
}
```

- [ ] **Step 3: 创建 `AppState`**

Create `capital-epoch/backend_api/src/app/state.rs`:

```rust
use sqlx::PgPool;

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
}
```

- [ ] **Step 4: 在 `main.rs` 里加载 `.env` 并构造 config（暂不启路由）**

Edit `capital-epoch/backend_api/src/main.rs` to:

```rust
mod app;

use app::config::AppConfig;

fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();
    let _config = AppConfig::from_env()?;
    Ok(())
}
```

- [ ] **Step 5: 编译通过验证**

Run:

```bash
cargo check --manifest-path capital-epoch/backend_api/Cargo.toml
```

Expected: Exit code 0

- [ ] **Step 6: Commit**

```bash
git add capital-epoch/backend_api/src/app capital-epoch/backend_api/src/main.rs
git commit -m "chore(backend): add app config and state skeleton"
```

---

### Task 5: 添加路由与 /health

**Files:**
- Create: `capital-epoch/backend_api/src/router/mod.rs`
- Create: `capital-epoch/backend_api/src/handlers/mod.rs`
- Create: `capital-epoch/backend_api/src/handlers/health.rs`
- Modify: `capital-epoch/backend_api/src/main.rs`

- [ ] **Step 1: 创建 health handler**

Create `capital-epoch/backend_api/src/handlers/health.rs`:

```rust
use axum::{extract::State, Json};
use serde::Serialize;

use crate::app::state::AppState;

#[derive(Serialize)]
struct HealthResponse {
    status: &'static str,
    db: &'static str,
}

pub async fn health(State(state): State<AppState>) -> Json<HealthResponse> {
    let db_ok = sqlx::query_scalar::<_, i32>("SELECT 1")
        .fetch_one(&state.db)
        .await
        .is_ok();

    Json(HealthResponse {
        status: "ok",
        db: if db_ok { "ok" } else { "error" },
    })
}
```

- [ ] **Step 2: handlers mod**

Create `capital-epoch/backend_api/src/handlers/mod.rs`:

```rust
pub mod health;
```

- [ ] **Step 3: router 组装**

Create `capital-epoch/backend_api/src/router/mod.rs`:

```rust
use axum::Router;

use crate::{app::state::AppState, handlers};

pub fn build_router(state: AppState) -> Router {
    Router::new()
        .route("/health", axum::routing::get(handlers::health::health))
        .with_state(state)
}
```

- [ ] **Step 4: 启动服务并注入 PgPool**

Edit `capital-epoch/backend_api/src/main.rs` to:

```rust
mod app;
mod handlers;
mod router;

use app::{config::AppConfig, state::AppState};
use sqlx::PgPool;
use tracing_subscriber::EnvFilter;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();

    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let config = AppConfig::from_env()?;
    let db = PgPool::connect(&config.database_url).await?;
    let state = AppState { db };

    let app = router::build_router(state);
    let listener = tokio::net::TcpListener::bind(format!("{}:{}", config.host, config.port)).await?;

    tracing::info!("listening on http://{}:{}", config.host, config.port);
    axum::serve(listener, app).await?;

    Ok(())
}
```

- [ ] **Step 5: 配置 `DATABASE_URL` 并运行服务**

Create `capital-epoch/backend_api/.env`:

```dotenv
APP_HOST=0.0.0.0
APP_PORT=3000
DATABASE_URL=postgresql://capital_epoch:capital_epoch@localhost:5432/capital_epoch
```

Run:

```bash
cargo run --manifest-path capital-epoch/backend_api/Cargo.toml
```

Expected: 日志包含 `listening on http://0.0.0.0:3000`

- [ ] **Step 6: 验证 /health**

In another terminal:

```bash
curl -sS http://localhost:3000/health
```

Expected:

```json
{"status":"ok","db":"ok"}
```

- [ ] **Step 7: Commit**

```bash
git add capital-epoch/backend_api/src/router capital-epoch/backend_api/src/handlers capital-epoch/backend_api/src/main.rs
git commit -m "feat(backend): add health endpoint and app bootstrap"
```

---

### Task 6: 断库验证（db=error）与收尾清理

**Files:**
- (optional) Create: `capital-epoch/infra/README.md`

- [ ] **Step 1: 临时停库**

Run:

```bash
docker stop capital_epoch_db
```

- [ ] **Step 2: 再次请求 /health**

Run:

```bash
curl -sS http://localhost:3000/health
```

Expected:

```json
{"status":"ok","db":"error"}
```

- [ ] **Step 3: 恢复数据库**

Run:

```bash
docker start capital_epoch_db
```

- [ ] **Step 4:（可选）写一段 infra 使用说明**

Create `capital-epoch/infra/README.md`:

```markdown
# infra

## Start Postgres

```bash
cp .env.example .env
docker compose --env-file .env up -d
```
```

- [ ] **Step 5: Commit**

```bash
git add capital-epoch/infra/README.md
git commit -m "docs(infra): add local postgres start instructions"
```

---

## Plan Self-Review

### Spec coverage

- 工程结构：Task 1
- Docker Compose Postgres：Task 2
- Rust Axum + /health：Task 3-5
- /health 返回 DB 连通性：Task 5-6
- 验收标准：Task 5-6 的命令与预期输出对应 DoD

### Placeholder scan

- 无 TBD/TODO
- 每一步包含明确文件内容或可运行命令与预期

### Type consistency

- `AppConfig/AppState/build_router/health` 的命名在各任务中一致

