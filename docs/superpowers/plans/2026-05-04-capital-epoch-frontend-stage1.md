# Capital Epoch Frontend Stage 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 落地 Flutter 前端阶段1（UI骨架 + Mock 数据）：可启动、可导航、核心页面结构齐全、支持 Android/Web 响应式壳。

**Architecture:** UI 层只依赖 Riverpod provider 输出的 domain model；数据来源先用 Mock Repository 实现，后续联调仅替换 repository 为 dio API 实现。全局用 go_router 管理路由，并用 ResponsiveScaffold 适配窄屏/宽屏导航形态。

**Tech Stack:** Flutter, go_router, flutter_riverpod, dio（预留）, freezed/json_serializable（阶段1可后置到需要时再引入）, shared_preferences（预留）

---

## 0. 当前仓库状态与落地位置

当前 `/workspace` 只有文档包，没有工程代码。按开发包推荐结构在仓库根目录创建：

```text
/workspace/capital-epoch/
  mobile_web_app/        # Flutter 工程
  backend_api/           # 阶段1不做（可空）
  infra/                 # 阶段1不做（可空）
  docs/                  # 可后续复制文档
```

后续所有文件路径都以 `/workspace/capital-epoch/mobile_web_app` 为根。

---

## Task 1: 创建 Flutter 工程与依赖（仅一次性骨架）

**Files:**
- Create: `/workspace/capital-epoch/mobile_web_app/**`（由 flutter create 生成）
- Modify: `/workspace/capital-epoch/mobile_web_app/pubspec.yaml`

- [ ] **Step 1: 创建工程目录**

Run:
```bash
mkdir -p /workspace/capital-epoch
cd /workspace/capital-epoch
flutter create mobile_web_app
```

Expected:
- 命令成功结束
- 生成 `/workspace/capital-epoch/mobile_web_app/lib/main.dart`

- [ ] **Step 2: 开启 Web 支持（如果需要）**

Run:
```bash
flutter config --enable-web
```

Expected:
- 输出包含启用 web 的提示（不同 Flutter 版本文案可能不同）

- [ ] **Step 3: 添加依赖**

Run:
```bash
cd /workspace/capital-epoch/mobile_web_app
flutter pub add go_router flutter_riverpod dio shared_preferences
flutter pub add --dev build_runner
```

Expected:
- pub get 成功
- `pubspec.yaml` 中出现上述依赖

- [ ] **Step 4: 验证工程可启动**

Run:
```bash
cd /workspace/capital-epoch/mobile_web_app
flutter test
```

Expected:
- PASS（初始模板测试通过）

---

## Task 2: 建立代码目录结构与入口文件

**Files:**
- Modify: `/workspace/capital-epoch/mobile_web_app/lib/main.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/app/app.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/app/router.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/app/theme.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/core/widgets/responsive_scaffold.dart`

- [ ] **Step 1: 创建目录结构**

Run:
```bash
cd /workspace/capital-epoch/mobile_web_app
mkdir -p lib/app lib/core/widgets lib/core/constants lib/core/utils lib/shared/components lib/features
```

Expected:
- 目录创建成功

- [ ] **Step 2: 写入 lib/main.dart（最小入口）**

Replace `/workspace/capital-epoch/mobile_web_app/lib/main.dart` with:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}
```

- [ ] **Step 3: 写入 App / Theme / Router 文件**

Create `/workspace/capital-epoch/mobile_web_app/lib/app/theme.dart`:
```dart
import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5EFF)),
    useMaterial3: true,
  );
}
```

Create `/workspace/capital-epoch/mobile_web_app/lib/app/router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/shell/presentation/pages/app_shell_page.dart';
import '../features/stock/presentation/pages/stock_detail_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const AppShellPage(initialIndex: 0),
      ),
      GoRoute(
        path: '/market',
        builder: (context, state) => const AppShellPage(initialIndex: 1),
      ),
      GoRoute(
        path: '/portfolio',
        builder: (context, state) => const AppShellPage(initialIndex: 2),
      ),
      GoRoute(
        path: '/news',
        builder: (context, state) => const AppShellPage(initialIndex: 3),
      ),
      GoRoute(
        path: '/credit',
        builder: (context, state) => const AppShellPage(initialIndex: 4),
      ),
      GoRoute(
        path: '/stocks/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StockDetailPage(stockId: id);
        },
      ),
    ],
  );
}
```

Create `/workspace/capital-epoch/mobile_web_app/lib/app/app.dart`:
```dart
import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
```

- [ ] **Step 4: 写入 ResponsiveScaffold（窄屏底部导航 / 宽屏侧边导航）**

Create `/workspace/capital-epoch/mobile_web_app/lib/core/widgets/responsive_scaffold.dart`:
```dart
import 'package:flutter/material.dart';

const kWideLayoutBreakpoint = 900.0;

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.body,
  });

  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kWideLayoutBreakpoint;
        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: Text(d.label),
                        ),
                      )
                      .toList(growable: false),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 5: 创建最小 smoke widget test（验证入口可跑）**

Create `/workspace/capital-epoch/mobile_web_app/test/app_smoke_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_web_app/app/app.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

- [ ] **Step 6: 运行测试**

Run:
```bash
cd /workspace/capital-epoch/mobile_web_app
flutter test
```

Expected:
- PASS

---

## Task 3: 建立 Shell（主导航容器）与五个一级页面占位

**Files:**
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/shell/presentation/pages/app_shell_page.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/home/presentation/pages/home_page.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/market/presentation/pages/market_page.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/portfolio/presentation/pages/portfolio_page.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/news/presentation/pages/news_page.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/credit/presentation/pages/credit_page.dart`

- [ ] **Step 1: 创建 feature 目录**

Run:
```bash
cd /workspace/capital-epoch/mobile_web_app
mkdir -p lib/features/{shell,home,market,portfolio,news,credit}/presentation/pages
```

- [ ] **Step 2: 写 AppShellPage（统一导航 + 路由跳转）**

Create `/workspace/capital-epoch/mobile_web_app/lib/features/shell/presentation/pages/app_shell_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/responsive_scaffold.dart';
import '../../../credit/presentation/pages/credit_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../market/presentation/pages/market_page.dart';
import '../../../news/presentation/pages/news_page.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key, required this.initialIndex});

  final int initialIndex;

  static const _paths = <String>['/home', '/market', '/portfolio', '/news', '/credit'];

  @override
  Widget build(BuildContext context) {
    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
      const NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: '市场'),
      const NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: '资产'),
      const NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: '新闻'),
      const NavigationDestination(icon: Icon(Icons.verified_outlined), selectedIcon: Icon(Icons.verified), label: '信用'),
    ];

    final pages = <Widget>[
      const HomePage(),
      const MarketPage(),
      const PortfolioPage(),
      const NewsPage(),
      const CreditPage(),
    ];

    return ResponsiveScaffold(
      selectedIndex: initialIndex,
      destinations: destinations,
      onDestinationSelected: (index) => context.go(_paths[index]),
      body: pages[initialIndex],
    );
  }
}
```

- [ ] **Step 3: 为五个页面写最小占位（后续再替换为真实 UI）**

Create `/workspace/capital-epoch/mobile_web_app/lib/features/home/presentation/pages/home_page.dart`:
```dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: Text('首页（阶段1占位）')),
      ),
    );
  }
}
```

Create `/workspace/capital-epoch/mobile_web_app/lib/features/market/presentation/pages/market_page.dart`:
```dart
import 'package:flutter/material.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: Text('市场（阶段1占位）')),
      ),
    );
  }
}
```

Create `/workspace/capital-epoch/mobile_web_app/lib/features/portfolio/presentation/pages/portfolio_page.dart`:
```dart
import 'package:flutter/material.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: Text('资产（阶段1占位）')),
      ),
    );
  }
}
```

Create `/workspace/capital-epoch/mobile_web_app/lib/features/news/presentation/pages/news_page.dart`:
```dart
import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: Text('新闻（阶段1占位）')),
      ),
    );
  }
}
```

Create `/workspace/capital-epoch/mobile_web_app/lib/features/credit/presentation/pages/credit_page.dart`:
```dart
import 'package:flutter/material.dart';

class CreditPage extends StatelessWidget {
  const CreditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: Text('信用（阶段1占位）')),
      ),
    );
  }
}
```

- [ ] **Step 4: 写路由切换 widget test（验证主导航可用）**

Create `/workspace/capital-epoch/mobile_web_app/test/shell_navigation_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_web_app/app/app.dart';

void main() {
  testWidgets('switch tabs using bottom navigation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.textContaining('首页'), findsWidgets);

    await tester.tap(find.text('新闻'));
    await tester.pumpAndSettle();
    expect(find.textContaining('新闻'), findsWidgets);

    await tester.tap(find.text('信用'));
    await tester.pumpAndSettle();
    expect(find.textContaining('信用'), findsWidgets);
  });
}
```

- [ ] **Step 5: 运行测试**

Run:
```bash
cd /workspace/capital-epoch/mobile_web_app
flutter test
```

Expected:
- PASS

---

## Task 4: 增量替换占位页为“阶段1 UI + Mock”（从首页开始）

此任务分 5 个子任务（Home / Stock Detail / Portfolio / News / Credit）。每个子任务都遵循同一模式：
- 定义 domain model（必要最小字段）
- 定义 repository 接口
- 定义 mock repository 实现（固定数据）
- 定义 riverpod provider 暴露给 UI
- 写 page + widgets（组合 shared/components）
- 写 widget test（只验证渲染关键文案/数值即可）

### Task 4.1: Home（首页）

**Files:**
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/home/domain/home_models.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/home/data/home_repository.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/home/data/mock/mock_home_repository.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/home/presentation/providers/home_providers.dart`
- Modify: `/workspace/capital-epoch/mobile_web_app/lib/features/home/presentation/pages/home_page.dart`

- [ ] **Step 1: 定义 domain model（最小字段）**

Create `/workspace/capital-epoch/mobile_web_app/lib/features/home/domain/home_models.dart`:
```dart
class HomeAssetSummary {
  const HomeAssetSummary({
    required this.totalAssets,
    required this.availableCash,
    required this.positionPnl,
    required this.creditScore,
  });

  final double totalAssets;
  final double availableCash;
  final double positionPnl;
  final int creditScore;
}

class NewsTickerItem {
  const NewsTickerItem({required this.title});

  final String title;
}

class WatchlistItem {
  const WatchlistItem({
    required this.stockId,
    required this.name,
    required this.lastPrice,
    required this.changePercent,
  });

  final String stockId;
  final String name;
  final double lastPrice;
  final double changePercent;
}

class HomeViewModel {
  const HomeViewModel({
    required this.assetSummary,
    required this.newsTicker,
    required this.watchlist,
  });

  final HomeAssetSummary assetSummary;
  final List<NewsTickerItem> newsTicker;
  final List<WatchlistItem> watchlist;
}
```

- [ ] **Step 2: 定义 repository 接口 + mock 实现**

Create `/workspace/capital-epoch/mobile_web_app/lib/features/home/data/home_repository.dart`:
```dart
import '../domain/home_models.dart';

abstract class HomeRepository {
  Future<HomeViewModel> getHome();
}
```

Create `/workspace/capital-epoch/mobile_web_app/lib/features/home/data/mock/mock_home_repository.dart`:
```dart
import '../../domain/home_models.dart';
import '../home_repository.dart';

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeViewModel> getHome() async {
    return const HomeViewModel(
      assetSummary: HomeAssetSummary(
        totalAssets: 1280000,
        availableCash: 520000,
        positionPnl: 12000,
        creditScore: 720,
      ),
      newsTicker: [
        NewsTickerItem(title: '央行下调基准利率 25bp，市场风险偏好回升'),
        NewsTickerItem(title: '监管提示：高波动资产交易需注意风险'),
      ],
      watchlist: [
        WatchlistItem(stockId: 'S1', name: '新远科技', lastPrice: 12.34, changePercent: 1.2),
        WatchlistItem(stockId: 'S2', name: '恒星银行', lastPrice: 8.90, changePercent: -0.6),
      ],
    );
  }
}
```

- [ ] **Step 3: 定义 provider**

Create `/workspace/capital-epoch/mobile_web_app/lib/features/home/presentation/providers/home_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/home_repository.dart';
import '../../data/mock/mock_home_repository.dart';
import '../../domain/home_models.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => MockHomeRepository());

final homeViewModelProvider = FutureProvider<HomeViewModel>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getHome();
});
```

- [ ] **Step 4: 替换 HomePage 为实际 UI（先用最小信息层级）**

Replace `/workspace/capital-epoch/mobile_web_app/lib/features/home/presentation/pages/home_page.dart` with:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/home_models.dart';
import '../providers/home_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVm = ref.watch(homeViewModelProvider);
    return Scaffold(
      body: SafeArea(
        child: asyncVm.when(
          data: (vm) => _HomeBody(vm: vm),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => const Center(child: Text('加载失败')),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.vm});

  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('资产总览', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _AssetRow(vm: vm),
        const SizedBox(height: 16),
        Text('热点快讯', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...vm.newsTicker.map((n) => ListTile(leading: const Icon(Icons.bolt), title: Text(n.title))),
        const SizedBox(height: 16),
        Text('自选', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...vm.watchlist.map(
          (w) => ListTile(
            title: Text(w.name),
            subtitle: Text('¥${w.lastPrice.toStringAsFixed(2)}   ${w.changePercent.toStringAsFixed(2)}%'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/stocks/${w.stockId}'),
          ),
        ),
      ],
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.vm});

  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final s = vm.assetSummary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('总资产：¥${s.totalAssets.toStringAsFixed(0)}'),
        Text('可用现金：¥${s.availableCash.toStringAsFixed(0)}'),
        Text('持仓盈亏：¥${s.positionPnl.toStringAsFixed(0)}'),
        Text('信用分：${s.creditScore}'),
      ],
    );
  }
}
```

- [ ] **Step 5: 写渲染测试（验证 mock 内容出现）**

Create `/workspace/capital-epoch/mobile_web_app/test/home_page_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_web_app/app/app.dart';

void main() {
  testWidgets('home shows mock content', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('资产总览'), findsOneWidget);
    expect(find.textContaining('信用分'), findsOneWidget);
    expect(find.textContaining('热点快讯'), findsOneWidget);
    expect(find.textContaining('自选'), findsOneWidget);
    expect(find.textContaining('新远科技'), findsOneWidget);
  });
}
```

- [ ] **Step 6: 运行测试**

Run:
```bash
cd /workspace/capital-epoch/mobile_web_app
flutter test
```

Expected:
- PASS

### Task 4.2: Stock Detail（股票详情）

按与 Home 相同模式实现：
- domain：`StockDetailViewModel`（价格、涨跌、风险标签、盘口占位、说明占位）
- provider：`stockDetailProvider(stockId)`
- UI：左侧/右侧分区（宽屏）+ 纵向堆叠（窄屏）
- 测试：进入 `/stocks/S1` 能看到股票名称与价格字段

**Files（建议）:**
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/stock/domain/stock_models.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/stock/data/stock_repository.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/stock/data/mock/mock_stock_repository.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/stock/presentation/providers/stock_providers.dart`
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/stock/presentation/pages/stock_detail_page.dart`
- Test: `/workspace/capital-epoch/mobile_web_app/test/stock_detail_test.dart`

### Task 4.3: Portfolio（资产页）

同模式实现：
- summary、现金/存款、持仓摘要、负债/曲线占位

**Files（建议）:**
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/portfolio/...`
- Test: `/workspace/capital-epoch/mobile_web_app/test/portfolio_test.dart`

### Task 4.4: News（新闻页）

同模式实现：
- 系统快讯、主体公告两栏（窄屏可用 TabBar，宽屏可两列）

**Files（建议）:**
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/news/...`
- Test: `/workspace/capital-epoch/mobile_web_app/test/news_test.dart`

### Task 4.5: Credit（信用页）

同模式实现：
- 信用分、构成条、最近事件列表

**Files（建议）:**
- Create: `/workspace/capital-epoch/mobile_web_app/lib/features/credit/...`
- Test: `/workspace/capital-epoch/mobile_web_app/test/credit_test.dart`

---

## Task 5: 人工验收（运行方式）

- [ ] **Step 1: 本地运行（Android 或 Web）**

Android（示例）：
```bash
cd /workspace/capital-epoch/mobile_web_app
flutter run
```

Web（示例）：
```bash
cd /workspace/capital-epoch/mobile_web_app
flutter run -d chrome
```

- [ ] **Step 2: 验收清单**

手动检查：
- 主导航切换正常（首页/市场/资产/新闻/信用）
- 首页能点进股票详情页
- 窄屏与宽屏布局切换正常（窗口拉伸到 900px 左右观察）
- 各页 mock 数据展示稳定（不闪烁、不溢出）

---

## Plan Self-Review

- 覆盖性：计划覆盖 spec 的路由信息架构、目录结构、ResponsiveScaffold、Mock Repository + Provider、首页与至少一个详情页的落地。
- 占位扫描：无 TBD/TODO；核心入口与 Home 的实现给出完整代码；其余页面按同模式重复实现，不引入额外抽象。
- 一致性：路径与路由统一使用 `/home`、`/market`、`/portfolio`、`/news`、`/credit`、`/stocks/:id`。

