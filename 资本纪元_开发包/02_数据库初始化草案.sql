-- 资本纪元：交易所大亨
-- PostgreSQL 初始化草案
-- 说明：
-- 1. 本文件为 MVP 首版建表起点
-- 2. 重点覆盖用户、钱包、股票、IPO、订单、银行、新闻、信用
-- 3. 上线前请结合实际业务再做 migration 拆分

create extension if not exists "pgcrypto";

-- =========================
-- 枚举类型
-- =========================

do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_status') then
    create type user_status as enum ('active', 'restricted', 'banned');
  end if;

  if not exists (select 1 from pg_type where typname = 'entity_type') then
    create type entity_type as enum ('bank', 'fund');
  end if;

  if not exists (select 1 from pg_type where typname = 'entity_status') then
    create type entity_status as enum ('active', 'ipo_pending', 'listed', 'delisting', 'delisted');
  end if;

  if not exists (select 1 from pg_type where typname = 'stock_status') then
    create type stock_status as enum ('pre_ipo', 'subscribing', 'listed', 'halted', 'delisting', 'delisted');
  end if;

  if not exists (select 1 from pg_type where typname = 'ipo_status') then
    create type ipo_status as enum ('draft', 'reviewing', 'approved', 'roadshow', 'subscribing', 'allocating', 'listed', 'rejected', 'cancelled');
  end if;

  if not exists (select 1 from pg_type where typname = 'subscription_fund_source') then
    create type subscription_fund_source as enum ('cash', 'ipo_loan', 'mixed');
  end if;

  if not exists (select 1 from pg_type where typname = 'subscription_status') then
    create type subscription_status as enum ('valid', 'invalid', 'allocated', 'refunded');
  end if;

  if not exists (select 1 from pg_type where typname = 'order_side') then
    create type order_side as enum ('buy', 'sell');
  end if;

  if not exists (select 1 from pg_type where typname = 'order_status') then
    create type order_status as enum ('open', 'partial_filled', 'filled', 'cancelled', 'rejected');
  end if;

  if not exists (select 1 from pg_type where typname = 'bank_license_level') then
    create type bank_license_level as enum ('retail', 'universal', 'investment');
  end if;

  if not exists (select 1 from pg_type where typname = 'bank_status') then
    create type bank_status as enum ('active', 'warning', 'run_risk', 'taken_over', 'closed');
  end if;

  if not exists (select 1 from pg_type where typname = 'deposit_product_type') then
    create type deposit_product_type as enum ('demand', 'time_7d', 'time_30d');
  end if;

  if not exists (select 1 from pg_type where typname = 'deposit_account_status') then
    create type deposit_account_status as enum ('active', 'matured', 'withdrawn', 'closed');
  end if;

  if not exists (select 1 from pg_type where typname = 'loan_type') then
    create type loan_type as enum ('starter_credit', 'consumer', 'investment', 'ipo_margin', 'business');
  end if;

  if not exists (select 1 from pg_type where typname = 'loan_status') then
    create type loan_status as enum ('active', 'overdue', 'repaid', 'defaulted');
  end if;

  if not exists (select 1 from pg_type where typname = 'news_type') then
    create type news_type as enum ('system', 'market', 'bank', 'ipo', 'risk');
  end if;

  if not exists (select 1 from pg_type where typname = 'announcement_type') then
    create type announcement_type as enum ('general', 'ipo', 'dividend', 'risk', 'rate_change');
  end if;

  if not exists (select 1 from pg_type where typname = 'credit_level') then
    create type credit_level as enum ('e', 'd', 'c', 'b', 'a', 'aa', 'aaa');
  end if;

  if not exists (select 1 from pg_type where typname = 'risk_status') then
    create type risk_status as enum ('normal', 'watch', 'restricted');
  end if;
end
$$;

-- =========================
-- 用户与鉴权
-- =========================

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  username varchar(64) not null unique,
  display_name varchar(64) not null,
  password_hash text not null,
  status user_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists user_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  refresh_token_hash text not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

-- =========================
-- 钱包与资产
-- =========================

create table if not exists wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references users(id) on delete cascade,
  available_cash numeric(20,4) not null default 0,
  frozen_cash numeric(20,4) not null default 0,
  total_asset_snapshot numeric(20,4) not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists wallet_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  wallet_id uuid not null references wallets(id) on delete cascade,
  change_type varchar(64) not null,
  amount numeric(20,4) not null,
  balance_after numeric(20,4) not null,
  reference_type varchar(64),
  reference_id uuid,
  created_at timestamptz not null default now()
);

create index if not exists idx_wallet_ledger_user_created_at
  on wallet_ledger(user_id, created_at desc);

-- =========================
-- 股票与IPO
-- =========================

create table if not exists stock_entities (
  id uuid primary key default gen_random_uuid(),
  entity_name varchar(128) not null,
  entity_type entity_type not null,
  founder_user_id uuid not null references users(id),
  entity_status entity_status not null default 'active',
  total_assets numeric(20,4) not null default 0,
  profit_7d numeric(20,4) not null default 0,
  profit_30d numeric(20,4) not null default 0,
  stable_income_source_count integer not null default 0,
  entity_credit_score integer not null default 60,
  listing_deposit_amount numeric(20,4) not null default 0,
  listing_deposit_paid boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists stocks (
  id uuid primary key default gen_random_uuid(),
  entity_id uuid not null unique references stock_entities(id) on delete cascade,
  stock_code varchar(16) not null unique,
  stock_name varchar(128) not null,
  stock_status stock_status not null default 'pre_ipo',
  issue_price numeric(20,4),
  last_price numeric(20,4),
  open_price numeric(20,4),
  close_price numeric(20,4),
  total_shares numeric(20,4) not null default 0,
  circulating_shares numeric(20,4) not null default 0,
  market_value numeric(20,4) not null default 0,
  listing_date timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists ipo_issues (
  id uuid primary key default gen_random_uuid(),
  entity_id uuid not null references stock_entities(id) on delete cascade,
  stock_id uuid references stocks(id) on delete set null,
  ipo_status ipo_status not null default 'draft',
  issue_price numeric(20,4) not null,
  issue_shares numeric(20,4) not null,
  fundraising_target numeric(20,4) not null,
  prospectus_summary text not null,
  fund_usage_plan text not null,
  dividend_policy text not null,
  risk_disclosure text not null,
  lockup_rule text not null,
  pricing_band_low numeric(20,4),
  pricing_band_high numeric(20,4),
  review_reason text,
  subscription_start_at timestamptz,
  subscription_end_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_ipo_issues_status_created_at
  on ipo_issues(ipo_status, created_at desc);

create table if not exists ipo_subscriptions (
  id uuid primary key default gen_random_uuid(),
  ipo_id uuid not null references ipo_issues(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  subscription_shares numeric(20,4) not null,
  subscription_amount numeric(20,4) not null,
  fund_source subscription_fund_source not null,
  loan_bank_id uuid,
  subscription_status subscription_status not null default 'valid',
  invalid_reason text,
  created_at timestamptz not null default now()
);

create unique index if not exists idx_ipo_subscriptions_ipo_user
  on ipo_subscriptions(ipo_id, user_id);

create table if not exists ipo_allocations (
  id uuid primary key default gen_random_uuid(),
  ipo_id uuid not null references ipo_issues(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  base_allocated_shares numeric(20,4) not null default 0,
  proportional_allocated_shares numeric(20,4) not null default 0,
  total_allocated_shares numeric(20,4) not null default 0,
  refund_amount numeric(20,4) not null default 0,
  allocation_ratio numeric(10,6),
  created_at timestamptz not null default now()
);

create unique index if not exists idx_ipo_allocations_ipo_user
  on ipo_allocations(ipo_id, user_id);

create table if not exists stock_dividends (
  id uuid primary key default gen_random_uuid(),
  stock_id uuid not null references stocks(id) on delete cascade,
  dividend_type varchar(32) not null,
  dividend_total_amount numeric(20,4) not null default 0,
  record_date timestamptz not null,
  pay_date timestamptz not null,
  dividend_status varchar(32) not null default 'planned',
  created_at timestamptz not null default now()
);

-- =========================
-- 订单与成交
-- =========================

create table if not exists stock_orders (
  id uuid primary key default gen_random_uuid(),
  stock_id uuid not null references stocks(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  side order_side not null,
  price numeric(20,4) not null,
  quantity numeric(20,4) not null,
  filled_quantity numeric(20,4) not null default 0,
  order_status order_status not null default 'open',
  rejected_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_stock_orders_book
  on stock_orders(stock_id, side, order_status, price, created_at);

create table if not exists stock_trades (
  id uuid primary key default gen_random_uuid(),
  stock_id uuid not null references stocks(id) on delete cascade,
  buy_order_id uuid not null references stock_orders(id),
  sell_order_id uuid not null references stock_orders(id),
  trade_price numeric(20,4) not null,
  trade_quantity numeric(20,4) not null,
  trade_amount numeric(20,4) not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_stock_trades_stock_created_at
  on stock_trades(stock_id, created_at desc);

create table if not exists portfolio_positions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  stock_id uuid not null references stocks(id) on delete cascade,
  quantity numeric(20,4) not null default 0,
  available_quantity numeric(20,4) not null default 0,
  avg_cost numeric(20,4) not null default 0,
  unrealized_pnl numeric(20,4) not null default 0,
  updated_at timestamptz not null default now(),
  unique(user_id, stock_id)
);

create table if not exists fund_positions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  fund_entity_id uuid not null references stock_entities(id) on delete cascade,
  quantity numeric(20,4) not null default 0,
  avg_cost numeric(20,4) not null default 0,
  updated_at timestamptz not null default now(),
  unique(user_id, fund_entity_id)
);

-- =========================
-- 银行与贷款
-- =========================

create table if not exists banks (
  id uuid primary key default gen_random_uuid(),
  bank_name varchar(128) not null unique,
  founder_user_id uuid not null references users(id),
  license_level bank_license_level not null default 'retail',
  bank_status bank_status not null default 'active',
  credit_rating varchar(8) not null default 'BBB',
  registered_capital numeric(20,4) not null,
  total_assets numeric(20,4) not null default 0,
  total_deposits numeric(20,4) not null default 0,
  total_loans numeric(20,4) not null default 0,
  npl_ratio numeric(10,6) not null default 0,
  liquidity_ratio numeric(10,6) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists bank_deposit_accounts (
  id uuid primary key default gen_random_uuid(),
  bank_id uuid not null references banks(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  product_type deposit_product_type not null,
  principal_amount numeric(20,4) not null,
  annual_rate numeric(10,6) not null,
  start_at timestamptz not null,
  maturity_at timestamptz,
  account_status deposit_account_status not null default 'active',
  created_at timestamptz not null default now()
);

create index if not exists idx_bank_deposit_accounts_bank_user
  on bank_deposit_accounts(bank_id, user_id);

create table if not exists loan_accounts (
  id uuid primary key default gen_random_uuid(),
  bank_id uuid not null references banks(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  loan_type loan_type not null,
  principal_amount numeric(20,4) not null,
  outstanding_amount numeric(20,4) not null,
  annual_rate numeric(10,6) not null,
  loan_status loan_status not null default 'active',
  issued_at timestamptz not null,
  due_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_loan_accounts_bank_status
  on loan_accounts(bank_id, loan_status);

create index if not exists idx_loan_accounts_user_status
  on loan_accounts(user_id, loan_status);

create table if not exists loan_repayments (
  id uuid primary key default gen_random_uuid(),
  loan_id uuid not null references loan_accounts(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  repayment_amount numeric(20,4) not null,
  principal_component numeric(20,4) not null default 0,
  interest_component numeric(20,4) not null default 0,
  repayment_at timestamptz not null default now()
);

-- =========================
-- 新闻与公告
-- =========================

create table if not exists news_items (
  id uuid primary key default gen_random_uuid(),
  news_type news_type not null,
  title varchar(256) not null,
  summary text not null,
  content text,
  related_object_type varchar(64),
  related_object_id uuid,
  importance_level integer not null default 1,
  published_at timestamptz not null default now()
);

create index if not exists idx_news_items_published_at
  on news_items(published_at desc);

create table if not exists announcements (
  id uuid primary key default gen_random_uuid(),
  issuer_type varchar(64) not null,
  issuer_id uuid not null,
  title varchar(256) not null,
  content text not null,
  announcement_type announcement_type not null default 'general',
  published_at timestamptz not null default now()
);

create index if not exists idx_announcements_issuer_published
  on announcements(issuer_type, issuer_id, published_at desc);

-- =========================
-- 信用与风控
-- =========================

create table if not exists credit_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references users(id) on delete cascade,
  credit_score integer not null default 60,
  credit_level credit_level not null default 'c',
  risk_status risk_status not null default 'normal',
  updated_at timestamptz not null default now()
);

create table if not exists credit_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  event_type varchar(64) not null,
  score_delta integer not null,
  reason text not null,
  reference_type varchar(64),
  reference_id uuid,
  created_at timestamptz not null default now()
);

create index if not exists idx_credit_events_user_created_at
  on credit_events(user_id, created_at desc);

create table if not exists risk_flags (
  id uuid primary key default gen_random_uuid(),
  object_type varchar(64) not null,
  object_id uuid not null,
  flag_type varchar(64) not null,
  flag_status varchar(32) not null default 'active',
  reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_risk_flags_object
  on risk_flags(object_type, object_id, flag_status);
