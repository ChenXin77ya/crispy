# 资本纪元：阶段A（后端骨架跑通）设计

## 1. 背景与目标

本阶段目标是把后端工程与本地基础设施跑通，形成一个稳定的开发起点：

- 本地用 Docker Compose 启动 PostgreSQL
- Rust 后端可启动，并提供 `GET /health`
- `/health` 返回应用存活状态，并包含数据库连通性结果（用于快速定位环境问题）

本阶段不包含 Flutter 工程、不包含注册登录等业务接口。

## 2. 范围（In / Out）

### 2.1 In Scope

- 工程目录落地到 `/workspace/capital-epoch`
- `infra/` 具备可直接启动的 PostgreSQL Compose 配置
- `backend_api/` 具备可运行的 Axum 服务骨架
- 最小配置管理（环境变量）
- 最小观测性（tracing 日志）

### 2.2 Out of Scope

- 任何鉴权逻辑（JWT/refresh token/权限）
- 业务表、业务接口（auth/portfolio/market 等）
- Flutter 前端工程与联调

## 3. 工程结构

采用“先只搭后端”的结构，但保留后续扩展空间：

```text
capital-epoch/
  backend_api/
  infra/
  docs/
    superpowers/
      specs/
        2026-05-04-backend-skeleton-design.md
```

## 4. 基础设施（infra）

### 4.1 文件

- `infra/docker-compose.yml`：PostgreSQL 服务定义
- `infra/.env.example`：本地默认环境变量示例

### 4.2 约定的数据库连接信息

通过 `DATABASE_URL` 统一注入，例如：

```text
postgresql://capital_epoch:capital_epoch@localhost:5432/capital_epoch
```

说明：

- 实际用户名/密码/库名以 `infra/.env`（从 `.env.example` 复制）为准
- 后端只依赖 `DATABASE_URL`，避免散落多个 DB 配置项

## 5. 后端服务（backend_api）

### 5.1 技术选型

- Web：Axum + Tokio
- DB：sqlx（PostgreSQL）
- 日志：tracing + tracing-subscriber
- HTTP 中间件：tower-http（trace、cors 按需）

### 5.2 模块边界（骨架级别）

```text
src/
  main.rs
  app/
    state.rs        # AppState / 依赖注入（如 PgPool）
    config.rs       # 读取环境变量并构造配置
  router/
    mod.rs          # 组装 Router
  handlers/
    health.rs       # /health
```

约束：

- handler 只负责 HTTP 入参/出参，不直接写 SQL
- state 负责组装依赖（如 PgPool）

### 5.3 配置（环境变量）

最小集合：

- `APP_HOST`（默认 `0.0.0.0`）
- `APP_PORT`（默认 `3000`）
- `DATABASE_URL`（无默认值；必须由 `.env` 或运行环境提供）

### 5.4 健康检查

`GET /health` 响应：

- `status: "ok"`（服务存活）
- `db: "ok" | "error"`（DB 连通性）

DB 检查策略：

- 启动时创建 `PgPool`
- 每次 `/health` 执行一次轻量查询（例如 `SELECT 1`）或用 `acquire` 验证连接

## 6. 验收标准（Definition of Done）

满足以下条件即认为阶段 A 完成：

- `docker compose up -d` 可启动 PostgreSQL
- `cargo run` 可启动后端服务
- `GET /health` 返回 `status=ok`
- 在数据库可连接时，`/health` 的 `db=ok`；断库时 `db=error` 且服务仍可返回（便于诊断）

## 7. 下一阶段衔接（阶段B 入口）

阶段B（账户与资产闭环）开始前的最小准备：

- 引入 migrations（如采用 sqlx migrate）
- 明确错误模型与统一响应结构（错误码、message）
- 决定鉴权方案（JWT access + refresh）的细节与表结构

