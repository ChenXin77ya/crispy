import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/credit_models.dart';
import '../providers/credit_providers.dart';

class CreditPage extends ConsumerWidget {
  const CreditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVm = ref.watch(creditProfileProvider);
    return SafeArea(
      child: asyncVm.when(
        data: (vm) => _CreditBody(profile: vm),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('加载失败')),
      ),
    );
  }
}

class _CreditBody extends StatelessWidget {
  const _CreditBody({required this.profile});

  final CreditProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('信用概览', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('信用分', style: Theme.of(context).textTheme.labelLarge),
                    Text(profile.score.toString(), style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                Chip(label: Text('等级 ${profile.level}')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('构成', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ...profile.factors.map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(f.name),
                        Text(f.score.toString()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('最近变动', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...profile.recentEvents.map((e) => ListTile(leading: const Icon(Icons.history), title: Text(e.title))),
      ],
    );
  }
}
