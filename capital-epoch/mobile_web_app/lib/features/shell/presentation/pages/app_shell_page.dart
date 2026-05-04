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
      const NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: '资产',
      ),
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

