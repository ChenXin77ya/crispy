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
    return SafeArea(
      child: asyncVm.when(
        data: (vm) => _HomeBody(vm: vm),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('加载失败')),
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
