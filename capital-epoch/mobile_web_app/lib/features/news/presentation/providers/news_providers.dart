import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_news_repository.dart';
import '../../data/news_repository.dart';
import '../../domain/news_models.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) => MockNewsRepository());

final newsViewModelProvider = FutureProvider<NewsViewModel>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getNews();
});

