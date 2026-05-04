import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/responsive_scaffold.dart';
import '../../domain/news_models.dart';
import '../providers/news_providers.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVm = ref.watch(newsViewModelProvider);
    return SafeArea(
      child: asyncVm.when(
        data: (vm) => _NewsBody(vm: vm),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('加载失败')),
      ),
    );
  }
}

class _NewsBody extends StatelessWidget {
  const _NewsBody({required this.vm});

  final NewsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kWideLayoutBreakpoint;
        if (isWide) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _NewsList(title: '系统快讯', items: vm.flash)),
                const SizedBox(width: 16),
                Expanded(child: _NewsList(title: '主体公告', items: vm.announcements)),
              ],
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: '快讯'),
                  Tab(text: '公告'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _NewsList(title: '系统快讯', items: vm.flash),
                    _NewsList(title: '主体公告', items: vm.announcements),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NewsList extends StatelessWidget {
  const _NewsList({required this.title, required this.items});

  final String title;
  final List<NewsItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...items.map(
          (n) => ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(n.title),
            subtitle: Text(n.source),
          ),
        ),
      ],
    );
  }
}
