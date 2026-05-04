import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_scaffold.dart';
import '../../domain/stock_models.dart';
import '../providers/stock_providers.dart';

class StockDetailPage extends ConsumerWidget {
  const StockDetailPage({super.key, required this.stockId});

  final String stockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVm = ref.watch(stockDetailProvider(stockId));
    return asyncVm.when(
      data: (vm) => _StockDetailScaffold(vm: vm),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => const Scaffold(body: Center(child: Text('加载失败'))),
    );
  }
}

class _StockDetailScaffold extends StatelessWidget {
  const _StockDetailScaffold({required this.vm});

  final StockDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vm.name)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= kWideLayoutBreakpoint;
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _PriceHeader(vm: vm),
                        const SizedBox(height: 12),
                        _RiskTags(tags: vm.riskTags),
                        const SizedBox(height: 16),
                        _ChartPlaceholder(),
                        const SizedBox(height: 16),
                        _AboutCard(text: vm.about),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _OrderPanel(),
                        const SizedBox(height: 16),
                        _OrderBookPanel(orderBook: vm.orderBook),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PriceHeader(vm: vm),
                const SizedBox(height: 12),
                _RiskTags(tags: vm.riskTags),
                const SizedBox(height: 16),
                _ChartPlaceholder(),
                const SizedBox(height: 16),
                _OrderPanel(),
                const SizedBox(height: 16),
                _OrderBookPanel(orderBook: vm.orderBook),
                const SizedBox(height: 16),
                _AboutCard(text: vm.about),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PriceHeader extends StatelessWidget {
  const _PriceHeader({required this.vm});

  final StockDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    final changeColor = vm.changePercent >= 0 ? Colors.red : Colors.green;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(vm.name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '¥${vm.lastPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 12),
            Text(
              '${vm.changePercent.toStringAsFixed(2)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: changeColor),
            ),
          ],
        ),
      ],
    );
  }
}

class _RiskTags extends StatelessWidget {
  const _RiskTags({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((t) => Chip(label: Text(t))).toList(growable: false),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('图表占位（阶段1）')),
      ),
    );
  }
}

class _OrderPanel extends StatefulWidget {
  @override
  State<_OrderPanel> createState() => _OrderPanelState();
}

class _OrderPanelState extends State<_OrderPanel> {
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('下单面板（Mock）', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '价格'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '数量'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: FilledButton(onPressed: () {}, child: const Text('买入'))),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {},
                    child: const Text('卖出'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderBookPanel extends StatelessWidget {
  const _OrderBookPanel({required this.orderBook});

  final StockOrderBook orderBook;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('盘口（简化）', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('买盘', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      ...orderBook.bids.map((l) => _OrderBookRow(price: l.price, qty: l.quantity)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('卖盘', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      ...orderBook.asks.map((l) => _OrderBookRow(price: l.price, qty: l.quantity)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderBookRow extends StatelessWidget {
  const _OrderBookRow({required this.price, required this.qty});

  final double price;
  final int qty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(price.toStringAsFixed(2)),
          Text(qty.toString()),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('主体说明', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}
