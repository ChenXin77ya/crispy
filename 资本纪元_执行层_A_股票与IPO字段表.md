# 资本纪元：交易所大亨

## 执行层 A：股票与IPO字段表

本文档将 `v1.3-A` 中的规则翻译为执行层结构，重点给出：

- 核心数据对象
- 页面字段
- 状态流转
- 校验规则
- 前后端关注点

---

## 一、数据对象总览

股票与IPO模块建议拆为以下核心对象：

1. `StockEntity`：可上市主体
2. `StockInstrument`：股票本体
3. `IPOIssue`：一次IPO发行单
4. `IPOSubscription`：单个玩家申购记录
5. `IPOAllocation`：中签与配售结果
6. `StockOrder`：股票委托单
7. `StockTrade`：股票成交记录
8. `StockDividend`：分红记录
9. `StockRefinancing`：再融资记录
10. `StockRiskFlag`：风险标签记录

---

## 二、可上市主体 `StockEntity`

## 2.1 基础字段

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `entity_id` | string | 是 | 主体唯一ID |
| `entity_name` | string | 是 | 主体名称 |
| `entity_type` | enum | 是 | `bank` / `fund` |
| `founder_user_id` | string | 是 | 创始人ID |
| `founder_name` | string | 是 | 创始人昵称快照 |
| `established_at` | datetime | 是 | 成立时间 |
| `entity_status` | enum | 是 | `active` / `ipo_pending` / `listed` / `delisting` / `delisted` |

## 2.2 经营与信用字段

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `total_assets` | number | 是 | 主体总资产 |
| `profit_7d` | number | 是 | 最近7日收益 |
| `profit_30d` | number | 是 | 最近30日收益 |
| `stable_income_source_count` | number | 是 | 稳定收益来源数量 |
| `entity_credit_score` | number | 是 | 主体信用分 |
| `founder_credit_score` | number | 是 | 创始人信用分 |
| `major_violation_7d` | boolean | 是 | 近7日重大违规 |
| `major_violation_14d` | boolean | 是 | 近14日重大违规 |

## 2.3 上市资格字段

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `ipo_eligible` | boolean | 是 | 是否达到申请条件 |
| `ipo_eligible_reason` | string | 否 | 不满足时的原因说明 |
| `listing_deposit_amount` | number | 是 | 上市保证金 |
| `listing_deposit_paid` | boolean | 是 | 是否已缴纳 |

---

## 三、股票本体 `StockInstrument`

## 3.1 基础字段

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `stock_id` | string | 是 | 股票ID |
| `stock_code` | string | 是 | 股票代码 |
| `stock_name` | string | 是 | 股票简称 |
| `entity_id` | string | 是 | 对应上市主体 |
| `market_board` | enum | 是 | `main_board` / `risk_board` |
| `listing_date` | datetime | 否 | 上市日期 |
| `stock_status` | enum | 是 | `pre_ipo` / `subscribing` / `listed` / `halted` / `delisting` / `delisted` |

## 3.2 股本字段

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `total_shares` | number | 是 | 总股本 |
| `circulating_shares` | number | 是 | 流通股 |
| `ipo_shares` | number | 是 | 首发股数 |
| `founder_locked_shares` | number | 是 | 创始人锁定股数 |
| `incentive_pool_shares` | number | 否 | 激励池股数 |

## 3.3 市场字段

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `issue_price` | number | 否 | 发行价 |
| `last_price` | number | 否 | 最新价 |
| `open_price` | number | 否 | 开盘价 |
| `close_price` | number | 否 | 收盘价 |
| `daily_limit_up` | number | 否 | 涨停价 |
| `daily_limit_down` | number | 否 | 跌停价 |
| `market_value` | number | 否 | 市值 |
| `turnover_1d` | number | 否 | 日成交额 |

---

## 四、IPO发行单 `IPOIssue`

## 4.1 基础字段

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `ipo_id` | string | 是 | IPO唯一ID |
| `entity_id` | string | 是 | 发行主体ID |
| `stock_id` | string | 否 | 若股票代码已预生成则写入 |
| `ipo_status` | enum | 是 | `draft` / `reviewing` / `approved` / `roadshow` / `subscribing` / `allocating` / `listed` / `rejected` |
| `issue_price` | number | 是 | 发行价 |
| `issue_shares` | number | 是 | 发行股数 |
| `fundraising_target` | number | 是 | 募资金额 |
| `subscription_start_at` | datetime | 否 | 申购开始时间 |
| `subscription_end_at` | datetime | 否 | 申购结束时间 |

## 4.2 说明书字段

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `prospectus_summary` | text | 是 | 招股说明摘要 |
| `fund_usage_plan` | text | 是 | 募资用途 |
| `dividend_policy` | text | 是 | 分红政策 |
| `risk_disclosure` | text | 是 | 风险提示 |
| `lockup_rule` | text | 是 | 锁定期说明 |
| `underwriter_bank_ids` | string[] | 否 | 代销/承销银行ID列表 |

## 4.3 审核字段

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `review_result` | enum | 否 | `approved` / `need_fix` / `rejected` |
| `review_reason` | text | 否 | 审核意见 |
| `pricing_band_low` | number | 否 | 系统建议定价下限 |
| `pricing_band_high` | number | 否 | 系统建议定价上限 |
| `risk_review_flag` | string[] | 否 | 风险审查标签 |

---

## 五、IPO申购记录 `IPOSubscription`

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `subscription_id` | string | 是 | 申购记录ID |
| `ipo_id` | string | 是 | 对应IPO |
| `user_id` | string | 是 | 玩家ID |
| `subscription_shares` | number | 是 | 申购股数 |
| `subscription_amount` | number | 是 | 冻结金额 |
| `fund_source` | enum | 是 | `cash` / `ipo_loan` / `mixed` |
| `loan_bank_id` | string | 否 | 若用了申购贷则记录 |
| `subscription_status` | enum | 是 | `valid` / `invalid` / `allocated` / `refunded` |
| `invalid_reason` | string | 否 | 无效原因 |

---

## 六、IPO配售结果 `IPOAllocation`

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `allocation_id` | string | 是 | 配售结果ID |
| `ipo_id` | string | 是 | IPO ID |
| `user_id` | string | 是 | 玩家ID |
| `base_allocated_shares` | number | 是 | 基础配售股数 |
| `proportional_allocated_shares` | number | 是 | 比例配售股数 |
| `total_allocated_shares` | number | 是 | 总中签股数 |
| `refund_amount` | number | 是 | 退回金额 |
| `allocation_ratio` | number | 否 | 缩配比例 |

---

## 七、交易委托 `StockOrder`

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `order_id` | string | 是 | 委托单ID |
| `stock_id` | string | 是 | 股票ID |
| `user_id` | string | 是 | 用户ID |
| `side` | enum | 是 | `buy` / `sell` |
| `price` | number | 是 | 委托价格 |
| `quantity` | number | 是 | 委托数量 |
| `filled_quantity` | number | 是 | 已成交数量 |
| `order_status` | enum | 是 | `open` / `partial_filled` / `filled` / `cancelled` / `rejected` |
| `rejected_reason` | string | 否 | 拒单原因 |
| `created_at` | datetime | 是 | 委托时间 |

---

## 八、成交记录 `StockTrade`

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `trade_id` | string | 是 | 成交ID |
| `stock_id` | string | 是 | 股票ID |
| `buy_order_id` | string | 是 | 买单ID |
| `sell_order_id` | string | 是 | 卖单ID |
| `trade_price` | number | 是 | 成交价 |
| `trade_quantity` | number | 是 | 成交量 |
| `trade_amount` | number | 是 | 成交额 |
| `traded_at` | datetime | 是 | 成交时间 |

---

## 九、分红记录 `StockDividend`

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `dividend_id` | string | 是 | 分红ID |
| `stock_id` | string | 是 | 股票ID |
| `dividend_type` | enum | 是 | `cash` / `bonus_share` |
| `dividend_total_amount` | number | 是 | 总分红金额 |
| `record_date` | datetime | 是 | 股权登记日 |
| `pay_date` | datetime | 是 | 发放日 |
| `dividend_status` | enum | 是 | `planned` / `approved` / `paid` |

---

## 十、再融资记录 `StockRefinancing`

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `refinancing_id` | string | 是 | 再融资ID |
| `stock_id` | string | 是 | 股票ID |
| `refinancing_type` | enum | 是 | `private_placement` |
| `new_shares` | number | 是 | 增发股数 |
| `placement_price` | number | 是 | 增发价 |
| `use_of_funds` | text | 是 | 用途说明 |
| `approval_status` | enum | 是 | `reviewing` / `approved` / `rejected` |

---

## 十一、风险标签 `StockRiskFlag`

| 字段名 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `flag_id` | string | 是 | 标签ID |
| `stock_id` | string | 是 | 股票ID |
| `flag_type` | enum | 是 | `stable_dividend` / `high_credit` / `low_liquidity` / `high_volatility` / `regulatory_watch` / `new_stock` |
| `flag_source` | enum | 是 | `system` / `regulator` / `manual_rule` |
| `flag_start_at` | datetime | 是 | 生效时间 |
| `flag_end_at` | datetime | 否 | 结束时间 |

---

## 十二、页面字段说明

## 12.1 股票详情页

必须展示字段：

| 页面区块 | 字段 |
|---|---|
| 顶部摘要 | 股票名、代码、最新价、涨跌幅、风险标签 |
| 图表区 | 分时、K线、成交额 |
| 交易区 | 买卖盘口、委托输入框、可买数量、可卖数量 |
| 主体区 | 主体类型、创始人、主体信用、收益来源 |
| 权益区 | 分红记录、投票权、优先申购权 |
| 公告区 | 最新公告、风险提示 |

## 12.2 IPO详情页

必须展示字段：

| 页面区块 | 字段 |
|---|---|
| 顶部摘要 | 主体名、发行价、发行股数、募资金额 |
| 信用区 | 创始人信用、主体信用、处罚摘要 |
| 经营区 | 存续时间、总资产、收益趋势 |
| 风险区 | 风险提示、锁定期、定价合理区间 |
| 申购区 | 可申购数量、冻结金额、申购资金来源 |
| 渠道区 | 代销银行、是否支持申购贷 |

---

## 十三、状态流转

## 13.1 IPO状态流转

`draft → reviewing → approved → roadshow → subscribing → allocating → listed`

异常分支：

- `reviewing → need_fix`
- `reviewing → rejected`
- `subscribing → cancelled`

## 13.2 股票状态流转

`pre_ipo → subscribing → listed → halted / delisting → delisted`

---

## 十四、关键校验规则

## 14.1 上市申请校验

提交IPO申请前必须校验：

1. 主体存续时间是否达到 `14日`
2. 总资产是否达到 `5000万`
3. 主体信用分是否达到 `75`
4. 创始人信用分是否达到 `80`
5. 是否存在近期重大违规
6. 保证金是否已缴纳

## 14.2 发行结构校验

1. 总股本是否为首版允许范围
2. 首发比例是否在 `20%-35%`
3. 创始人持股是否不低于 `45%`
4. 发行价是否在 `1.0-5.0`

## 14.3 申购校验

1. 用户是否被限制交易
2. 申购数量是否超过单账户上限
3. 资金是否足额
4. 若用申购贷，是否符合申购贷资格

## 14.4 委托下单校验

1. 是否在交易时间内
2. 价格是否落在涨跌幅限制内
3. 买单资金是否足够
4. 卖单持仓是否足够

---

## 十五、后端处理节点

## 15.1 定时任务或服务

需要单独处理的节点：

- IPO审核任务
- 申购截止后配售计算
- 上市首日价格保护检查
- 风险标签刷新
- 分红发放
- 退市观察扫描

## 15.2 高风险处理点

需重点防错：

- 超额申购冻结与退款
- 创始人锁定股约束
- 临停触发条件
- 退市后资产处理

---

## 十六、前端重点关注

前端在原型阶段应优先支持：

1. IPO详情页字段完整展示
2. 股票详情页的“价格 + 主体 + 风险 + 公告”一体化展示
3. 新手模式下的简化说明卡
4. 风险标签高亮展示

---

## 十七、结论

这份执行层文档的作用，是把股票与IPO从策划规则转换成结构化开发对象。  
后续如果继续深入，建议下一步再补：

- `股票与IPO接口草表`
- `配售算法说明`
- `交易撮合与临停规则说明`
