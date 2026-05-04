import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_portfolio_repository.dart';
import '../../data/portfolio_repository.dart';
import '../../domain/portfolio_models.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) => MockPortfolioRepository());

final portfolioSummaryProvider = FutureProvider<PortfolioSummary>((ref) async {
  final repo = ref.watch(portfolioRepositoryProvider);
  return repo.getSummary();
});

