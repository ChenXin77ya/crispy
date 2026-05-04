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

