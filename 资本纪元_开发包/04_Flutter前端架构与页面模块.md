# 资本纪元：交易所大亨

## 04. Flutter 前端架构与页面模块

本文档目标：

- 明确 Flutter 客户端项目结构
- 给出 Android / Web 共用策略
- 让页面和组件可以直接开始拆分开发

---

## 一、前端目标

Flutter 客户端需要完成三件事：

1. 让新手能看懂和玩通核心链路
2. 让老玩家能高频查看行情和交易
3. 在 Android 和 Web 之间复用一套业务逻辑

---

## 二、推荐技术栈

建议：

- 路由：`go_router`
- 状态管理：`flutter_riverpod`
- 网络：`dio`
- 数据模型：`freezed`、`json_serializable`
- 图表：可先用基础图表组件，后续再换更强图表库
- 本地缓存：`shared_preferences`

---

## 三、项目结构建议

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme.dart
  core/
    constants/
    network/
    storage/
    widgets/
    utils/
  features/
    auth/
    home/
    market/
    stock/
    ipo/
    bank/
    portfolio/
    news/
    credit/
  shared/
    models/
    enums/
    components/
```

---

## 四、功能模块拆分

## 4.1 `auth`

负责：

- 登录页
- 注册页
- token 持久化
- 启动自动登录

## 4.2 `home`

负责：

- 首页总览
- 热点快讯
- 自选摘要
- 热门榜单

## 4.3 `market`

负责：

- 股票列表
- IPO列表
- 银行列表
- 搜索和筛选

## 4.4 `stock`

负责：

- 股票详情页
- 下单区
- 盘口区
- 公告区

## 4.5 `ipo`

负责：

- IPO详情页
- 申购页
- 我的申购记录
- 配售结果页

## 4.6 `bank`

负责：

- 银行详情页
- 存款页
- 贷款申请页

## 4.7 `portfolio`

负责：

- 资产总览
- 股票持仓
- 基金持仓
- 负债列表

## 4.8 `news`

负责：

- 新闻列表
- 公告列表
- 新闻详情

## 4.9 `credit`

负责：

- 信用概览
- 信用事件列表
- 信用说明页

---

## 五、状态管理建议

建议按“页面粒度 + 领域粒度”管理状态。

## 5.1 全局 Provider

建议全局持有：

- `authProvider`
- `currentUserProvider`
- `appThemeProvider`
- `appConfigProvider`

## 5.2 页面级 Provider

例如：

- `homeSummaryProvider`
- `stockDetailProvider(stockId)`
- `ipoDetailProvider(ipoId)`
- `bankDetailProvider(bankId)`
- `portfolioSummaryProvider`

## 5.3 操作型 Controller

建议用 `Notifier` 或 `AsyncNotifier` 处理：

- 下单
- 撤单
- IPO申购
- 创建存款
- 申请贷款

---

## 六、路由设计

建议使用嵌套路由。

### 主路由

- `/login`
- `/register`
- `/home`
- `/market`
- `/portfolio`
- `/news`
- `/credit`

### 子路由

- `/stocks/:id`
- `/ipos/:id`
- `/banks/:id`
- `/orders`
- `/loans`

---

## 七、页面优先级

## 7.1 第一批页面

必须先做：

- 登录页
- 首页
- 股票详情页
- 个人资产页
- 新闻页

## 7.2 第二批页面

- IPO详情页
- 银行详情页
- 信用页
- 我的委托页

## 7.3 第三批页面

- 贷款页
- 存款页
- 更复杂筛选页

---

## 八、核心页面组件拆分

## 8.1 首页

建议组件：

- `AssetSummaryCard`
- `MarketIndexCard`
- `NewsTickerCard`
- `WatchlistCard`
- `HotStockList`
- `IpoListCard`

## 8.2 股票详情页

建议组件：

- `StockPriceHeader`
- `StockChartPanel`
- `StockOrderBook`
- `StockOrderPanel`
- `StockEntityInfoCard`
- `StockAnnouncementList`
- `RiskTagList`

## 8.3 IPO详情页

建议组件：

- `IpoHeaderCard`
- `IpoCreditInfoCard`
- `IpoRiskInfoCard`
- `IpoSubscriptionPanel`
- `IpoUnderwriterList`

## 8.4 银行详情页

建议组件：

- `BankHeaderCard`
- `BankRateCard`
- `BankProductList`
- `BankRiskBanner`
- `BankAnnouncementList`

## 8.5 资产页

建议组件：

- `PortfolioSummaryHeader`
- `CashCard`
- `StockPositionList`
- `FundPositionList`
- `LiabilityCard`
- `CreditSummaryCard`

---

## 九、Android / Web 适配策略

## 9.1 共用原则

以下内容尽量完全共用：

- 业务逻辑
- Provider
- 请求层
- 模型层

## 9.2 差异化内容

以下内容允许分平台布局：

- 首页多栏布局
- 股票详情页的宽屏分区
- Web 侧更密集表格视图

## 9.3 实现建议

可以通过：

- `LayoutBuilder`
- `MediaQuery`
- 自定义 `ResponsiveScaffold`

在不同宽度下切布局。

---

## 十、接口与 DTO 设计建议

建议每个模块拆成：

- `api`
- `dto`
- `mapper`
- `entity`

示例：

```text
features/stock/
  data/
    stock_api.dart
    dto/
    mapper/
  domain/
    stock_entity.dart
  presentation/
    pages/
    widgets/
    providers/
```

---

## 十一、错误处理与提示

金融类产品必须重视错误提示。

## 11.1 用户可理解错误

错误文案优先返回用户能看懂的内容，例如：

- 余额不足
- 不在交易时间
- 超出涨跌幅范围
- 可卖数量不足
- 当前不可申购

## 11.2 表单校验

下单、申购、贷款申请必须前端先校验：

- 数量不能为空
- 数值必须大于0
- 不得超过可用余额

---

## 十二、首版 UI 风格建议

首版不建议追求复杂视觉，而应优先：

- 信息清晰
- 风险突出
- 价格、收益、亏损层级明确

关键视觉原则：

- 涨跌颜色统一
- 风险标签高辨识
- 可操作按钮位置固定

---

## 十三、前端开发顺序

建议按这个顺序写：

1. `app/router/theme`
2. 登录与会话管理
3. 首页
4. 资产页
5. 股票详情页
6. 下单交互
7. 新闻页
8. IPO页
9. 银行页
10. 信用页

---

## 十四、联调建议

先联调这几个接口：

1. `GET /portfolio/summary`
2. `GET /market/home`
3. `GET /stocks/:id`
4. `POST /stocks/:id/orders/buy`
5. `GET /news`

打通后，你就能做出首版“可登录、可看行情、可下单”的客户端。

---

## 十五、结论

这份文档的重点是把 Flutter 客户端从“页面想法”推进到“可以搭工程和拆组件”的阶段。  
你接下来可以直接开始建 Flutter 项目，并按这份结构逐页推进。
