import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/market_repository.dart';
import '../../data/mock/mock_market_repository.dart';
import '../../domain/market_models.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) => MockMarketRepository());

final marketViewModelProvider = FutureProvider<MarketViewModel>((ref) async {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.getMarket();
});

