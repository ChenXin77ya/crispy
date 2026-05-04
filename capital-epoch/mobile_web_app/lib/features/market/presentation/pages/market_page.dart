import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/market_models.dart';
import '../providers/market_providers.dart';

class MarketPage extends ConsumerWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVm = ref.watch(marketViewModelProvider);
    return SafeArea(
      child: asyncVm.when(
        data: (vm) => _MarketBody(vm: vm),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('加载失败')),
      ),
    );
  }
}

class _MarketBody extends StatelessWidget {
  const _MarketBody({required this.vm});

  final MarketViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('股票', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...vm.stocks.map(
          (s) => ListTile(
            title: Text(s.name),
            subtitle: Text('¥${s.lastPrice.toStringAsFixed(2)}   ${s.changePercent.toStringAsFixed(2)}%'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/stocks/${s.stockId}'),
          ),
        ),
      ],
    );
  }
}
