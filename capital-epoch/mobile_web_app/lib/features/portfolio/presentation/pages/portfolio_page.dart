import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/portfolio_models.dart';
import '../providers/portfolio_providers.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVm = ref.watch(portfolioSummaryProvider);
    return SafeArea(
      child: asyncVm.when(
        data: (vm) => _PortfolioBody(summary: vm),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('加载失败')),
      ),
    );
  }
}

class _PortfolioBody extends StatelessWidget {
  const _PortfolioBody({required this.summary});

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('总览', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('总资产：¥${summary.totalAssets.toStringAsFixed(0)}'),
                Text('今日盈亏：¥${summary.todayPnl.toStringAsFixed(0)}'),
                Text('累计收益率：${summary.totalReturnPercent.toStringAsFixed(2)}%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('现金与负债', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('可用现金：¥${summary.cash.toStringAsFixed(0)}'),
                Text('负债：¥${summary.debt.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('持仓（阶段1占位）', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text('股票/基金持仓列表将在联调阶段接入'),
          ),
        ),
      ],
    );
  }
}
