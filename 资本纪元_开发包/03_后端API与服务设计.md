# 资本纪元：交易所大亨

## 03. 后端 API 与服务设计

本文档目标：

- 明确 Rust 服务端模块边界
- 给出 MVP 阶段 REST API 草案
- 说明关键事务与后台任务

技术前提：

- Web 框架：`axum`
- DB：`sqlx + PostgreSQL`
- 认证：`JWT`

---

## 一、后端模块拆分

建议按业务拆分为以下模块：

1. `auth`
2. `user`
3. `wallet`
4. `market`
5. `stock`
6. `ipo`
7. `bank`
8. `news`
9. `credit`
10. `admin`

---

## 二、项目目录建议

```text
src/
  main.rs
  app/
    state.rs
    error.rs
  config/
  router/
    mod.rs
    auth.rs
    user.rs
    market.rs
    stock.rs
    ipo.rs
    bank.rs
    news.rs
    credit.rs
  handlers/
  services/
  repos/
  models/
  domains/
  jobs/
  middleware/
  utils/
```

---

## 三、统一接口约定

## 3.1 成功响应

建议统一结构：

```json
{
  "code": 0,
  "message": "ok",
  "data": {}
}
```

## 3.2 失败响应

```json
{
  "code": 4001,
  "message": "余额不足",
  "data": null
}
```

## 3.3 分页约定

```json
{
  "items": [],
  "page": 1,
  "page_size": 20,
  "total": 200
}
```

---

## 四、认证模块 API

## 4.1 注册

`POST /api/v1/auth/register`

请求：

```json
{
  "username": "player001",
  "display_name": "玩家001",
  "password": "******"
}
```

响应：

- 用户基础信息
- access token
- refresh token

## 4.2 登录

`POST /api/v1/auth/login`

## 4.3 刷新 token

`POST /api/v1/auth/refresh`

## 4.4 当前用户

`GET /api/v1/auth/me`

---

## 五、用户与资产模块 API

## 5.1 资产总览

`GET /api/v1/portfolio/summary`

返回：

- 总资产
- 可用现金
- 冻结现金
- 持仓盈亏
- 信用分

## 5.2 钱包流水

`GET /api/v1/wallet/ledger`

支持参数：

- `page`
- `page_size`
- `change_type`

## 5.3 股票持仓

`GET /api/v1/portfolio/stocks`

## 5.4 基金持仓

`GET /api/v1/portfolio/funds`

## 5.5 负债列表

`GET /api/v1/portfolio/liabilities`

---

## 六、市场模块 API

## 6.1 首页摘要

`GET /api/v1/market/home`

返回：

- 综合指数
- 热点快讯
- 自选摘要
- IPO进行中
- 热门股票

## 6.2 股票列表

`GET /api/v1/market/stocks`

支持参数：

- `keyword`
- `tag`
- `sort_by`
- `page`

## 6.3 IPO列表

`GET /api/v1/market/ipos`

## 6.4 银行列表

`GET /api/v1/market/banks`

---

## 七、股票模块 API

## 7.1 股票详情

`GET /api/v1/stocks/:stock_id`

返回：

- 股票头部信息
- 当前价和涨跌幅
- 主体信息
- 风险标签
- 公告摘要

## 7.2 股票盘口

`GET /api/v1/stocks/:stock_id/orderbook`

## 7.3 股票成交明细

`GET /api/v1/stocks/:stock_id/trades`

## 7.4 下买单

`POST /api/v1/stocks/:stock_id/orders/buy`

请求：

```json
{
  "price": "3.25",
  "quantity": "1000"
}
```

## 7.5 下卖单

`POST /api/v1/stocks/:stock_id/orders/sell`

## 7.6 撤单

`POST /api/v1/orders/:order_id/cancel`

## 7.7 我的委托

`GET /api/v1/orders/my`

---

## 八、IPO 模块 API

## 8.1 IPO详情

`GET /api/v1/ipos/:ipo_id`

## 8.2 IPO申购

`POST /api/v1/ipos/:ipo_id/subscribe`

请求：

```json
{
  "subscription_shares": "2000",
  "fund_source": "cash"
}
```

## 8.3 我的IPO申购记录

`GET /api/v1/ipos/my/subscriptions`

## 8.4 我的IPO配售结果

`GET /api/v1/ipos/my/allocations`

---

## 九、银行模块 API

MVP 阶段先做玩家视角，不先做复杂银行家后台。

## 9.1 银行详情

`GET /api/v1/banks/:bank_id`

## 9.2 银行产品列表

`GET /api/v1/banks/:bank_id/products`

## 9.3 创建存款

`POST /api/v1/banks/:bank_id/deposits`

请求：

```json
{
  "product_type": "time_7d",
  "amount": "100000"
}
```

## 9.4 贷款试算

`POST /api/v1/banks/:bank_id/loans/quote`

## 9.5 申请贷款

`POST /api/v1/banks/:bank_id/loans/apply`

## 9.6 我的贷款列表

`GET /api/v1/loans/my`

## 9.7 还款

`POST /api/v1/loans/:loan_id/repay`

---

## 十、新闻与公告 API

## 10.1 新闻列表

`GET /api/v1/news`

支持：

- `news_type`
- `page`

## 10.2 新闻详情

`GET /api/v1/news/:news_id`

## 10.3 公告列表

`GET /api/v1/announcements`

支持：

- `issuer_type`
- `issuer_id`

---

## 十一、信用模块 API

## 11.1 我的信用概览

`GET /api/v1/credit/me`

返回：

- 当前信用分
- 信用等级
- 风险状态
- 评分构成说明

## 11.2 信用事件列表

`GET /api/v1/credit/events`

---

## 十二、后台管理 API

管理员或后续运营端使用，MVP 可先做极少量接口。

## 12.1 审核 IPO

`POST /api/v1/admin/ipos/:ipo_id/review`

## 12.2 发布新闻

`POST /api/v1/admin/news`

## 12.3 发布公告

`POST /api/v1/admin/announcements`

---

## 十三、关键服务职责

## 13.1 `AuthService`

负责：

- 注册
- 登录
- token 刷新
- 会话校验

## 13.2 `WalletService`

负责：

- 资金冻结
- 资金解冻
- 记账
- 钱包流水

## 13.3 `StockService`

负责：

- 股票详情查询
- 下单校验
- 撤单逻辑
- 行情基础数据聚合

## 13.4 `MatchingService`

负责：

- 订单撮合
- 成交生成
- 持仓更新
- 钱包结算

MVP 可以先用“简化撮合引擎”，放在单服务内。

## 13.5 `IPOService`

负责：

- IPO详情
- 申购校验
- 申购冻结
- 配售计算
- 退款处理

## 13.6 `BankService`

负责：

- 银行详情
- 存款产品创建
- 贷款试算
- 贷款申请
- 还款处理

## 13.7 `CreditService`

负责：

- 信用分更新
- 信用事件记录
- 风险状态变更

---

## 十四、关键事务说明

## 14.1 下单事务

步骤：

1. 校验交易时间和价格范围
2. 校验资金或持仓
3. 冻结资金或可卖股数
4. 创建委托单

## 14.2 撮合事务

步骤：

1. 选择可撮合订单
2. 生成成交记录
3. 更新买卖双方订单状态
4. 更新持仓
5. 更新钱包

## 14.3 IPO申购事务

步骤：

1. 校验申购资格
2. 冻结申购资金
3. 创建申购记录

## 14.4 还款事务

步骤：

1. 校验应还金额
2. 扣减钱包现金
3. 更新贷款余额
4. 写入还款记录
5. 更新信用事件

---

## 十五、后台任务

## 15.1 必要任务

- `ipo_review_job`
- `ipo_allocate_job`
- `market_close_job`
- `credit_refresh_job`
- `bank_rating_job`
- `dividend_pay_job`

## 15.2 幂等要求

所有任务必须具备：

- 重试安全
- 重复执行不导致重复记账
- 清晰的状态判断

---

## 十六、MVP 优先接口顺序

建议先实现：

1. `auth`
2. `portfolio summary`
3. `market home`
4. `stock detail`
5. `buy/sell/cancel order`
6. `orders my`
7. `news`

第二批再实现：

1. `ipo detail`
2. `ipo subscribe`
3. `credit me`
4. `bank detail`
5. `loan apply`

---

## 十七、结论

这套 API 设计足以支持你进入真正开发阶段。  
建议下一步直接开始做：

1. Rust 项目骨架
2. 数据库 migration
3. 第一批接口 handler + service + repo
4. Flutter 首页、股票页、资产页联调
