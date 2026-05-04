# 资本纪元（交易所大亨）前端阶段1设计：Flutter UI骨架 + Mock

## 1. 背景与目标

本阶段面向 MVP 的“阶段1：项目骨架”，只落地 Flutter 前端的可运行 UI 骨架，不依赖后端联调。

目标：
- App 可启动、可导航、核心页面结构可用
- 关键页面具备明确的信息层级与组件拆分边界
- 数据全部来自本地 Mock，但保持未来可平滑替换为 API 的结构
- 兼容 Android 与 Web：优先保证窄屏可玩，宽屏提供更高信息密度布局

非目标：
- 不实现真实鉴权、交易、撮合、下单校验逻辑
- 不实现 WebSocket、推送、实时行情
- 不引入复杂主题/组件库工程化（首版以可读性与迭代速度优先）

## 2. 技术栈与约束

按开发包约定：
- 路由：go_router
- 状态管理：flutter_riverpod
- 网络层：dio（阶段1可不接入，但保留接口位置）
- 模型：freezed + json_serializable（阶段1建议先建 domain model 与 mock mapper，避免过度生成）
- 本地存储：shared_preferences（阶段1仅为“新手模式开关”等少量设置预留）

## 3. 信息架构与路由

### 3.1 顶层导航（MVP首屏）

一级页面（BottomNavigation/NavigationRail）：
- 首页 Home：`/home`
- 市场 Market：`/market`
- 资产 Portfolio：`/portfolio`
- 新闻 News：`/news`
- 我的信用 Credit：`/credit`

### 3.2 认证页（阶段1先做页面壳）

- 登录：`/login`
- 注册：`/register`

阶段1不做真实登录态，仅提供进入主导航入口。

### 3.3 详情页

- 股票详情：`/stocks/:id`
- IPO 详情：`/ipos/:id`
- 银行详情：`/banks/:id`

阶段1仅做 UI + Mock 数据，入口来自首页/市场的列表卡片。

## 4. 项目结构（Flutter）

目录按开发包建议落地，并以“feature 内 data/domain/presentation”组织：

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

阶段1落地最小文件集合（建议）：
- `lib/main.dart`
- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/app/theme.dart`
- `lib/core/widgets/responsive_scaffold.dart`
- `lib/shared/components/*`（通用卡片/标签/列表项）
- 各 feature 的 `presentation/pages/*_page.dart` 与 `data/mock/*`

## 5. 状态管理（Riverpod）

阶段1目标是“页面可跑 + mock 可注入”，状态控制保持最小集合：

全局：
- `appSettingsProvider`：是否新手模式、平台布局阈值等

页面级（只读为主）：
- `homeViewModelProvider`
- `stockDetailProvider(stockId)`
- `portfolioSummaryProvider`
- `newsListProvider`
- `creditProfileProvider`

说明：
- 阶段1不引入复杂的写操作 controller；仅在股票详情页保留“下单面板”的 UI 状态（输入框）即可。

## 6. 响应式策略（Android/Web）

### 6.1 统一壳：ResponsiveScaffold

根据宽度切换：
- 窄屏：`Scaffold + BottomNavigationBar`
- 宽屏：`Row( NavigationRail + Expanded(content) )`

### 6.2 页面级布局规则（首批）

- 首页：宽屏时“主内容 + 侧栏辅助区”（快讯/榜单/IPO）两列；窄屏纵向堆叠
- 股票详情：宽屏时“左（价格/图表/说明）+ 右（盘口/交易面板）”；窄屏按区块堆叠

## 7. Mock 数据与未来对接 API 的边界

### 7.1 原则

- 页面不直接依赖 mock 常量
- 页面只依赖 repository/provider 输出的 domain model
- mock 数据通过 `*Repository` 的 mock 实现提供；未来替换为 `ApiRepository` 时不改 UI

### 7.2 Mock 覆盖范围（阶段1）

建议提供固定 mock：
- 首页：总资产摘要、市场指数、热点快讯、自选列表、IPO 申购中、热门榜单
- 股票详情：价格摘要、风险标签、盘口（简化）、公司说明、公告列表（占位）
- 资产页：现金/存款摘要、持仓摘要、负债摘要、信用摘要
- 新闻页：系统快讯、主体公告两栏（玩家观点可先隐藏或占位）
- 信用页：当前信用分、构成条、最近事件列表

## 8. 页面与组件拆分（阶段1范围）

### 8.1 首页 Home

页面结构对齐执行层文档：
- 顶部状态栏：总资产/可用现金/持仓盈亏/信用分（卡片化）
- 主内容区：指数卡、快讯轮播、自选列表、持仓摘要
- 辅助区：IPO 申购中、银行利率榜、基金收益榜、热门股票榜

建议组件（阶段1实现首版）：
- `AssetSummaryCard`
- `MarketIndexCard`
- `NewsTickerCard`
- `WatchlistCard`
- `IpoListCard`
- `RankListCard`

### 8.2 股票详情 Stock Detail

页面结构对齐执行层文档：
- 顶部摘要区（价格/涨跌/风险标签）
- 图表区（阶段1用占位图/简线，不做真实 K 线）
- 交易区（买入/卖出按钮 + 价格/数量输入）
- 盘口区（买卖五档 + 最新成交占位）
- 主体说明区（公司信息/收益来源/信用）
- 公告区（列表占位）

建议组件（阶段1实现首版）：
- `StockPriceHeader`
- `RiskTagList`
- `StockChartPlaceholder`
- `OrderPanel`
- `OrderBookPanel`
- `EntityInfoCard`
- `AnnouncementList`

### 8.3 资产页 Portfolio

- 总览区（总资产/今日盈亏/累计收益率/风险级别）
- 资产分布（现金/股票/基金）
- 负债区（占位/可空态）
- 信用区（摘要 + 跳转信用页）
- 曲线区（占位）

### 8.4 新闻页 News

阶段1先做：
- 系统快讯
- 主体公告

交互：
- 点击新闻进入详情页（阶段1可用通用详情页占位）
- 点击关联资产跳转股票/银行/IPO 详情（可选）

### 8.5 信用页 Credit

阶段1先做：
- 当前信用分 + 等级
- 构成条形图（可先用简单比例条）
- 最近变动事件列表

## 9. 验收标准（阶段1）

- App 可启动，支持 Android/Web
- 主导航可用：能在首页/市场/资产/新闻/信用之间切换
- 首页、股票详情、资产、新闻、信用页均可渲染，且从 provider 读取 mock 数据
- 从首页/市场可进入至少一个详情页（股票详情）
- 响应式壳可用：窄屏与宽屏布局切换正常（不要求完全美观，但信息不重叠、不溢出）

## 10. 风险与取舍

- 图表与盘口真实度：阶段1全部占位或简化；避免引入图表库与复杂计算
- 模型生成：freezed/json_serializable 可先在核心 model 上使用，避免在阶段1过度建模导致时间消耗
- 视觉设计：首版以信息层级与可读性优先，不追求美术质感

