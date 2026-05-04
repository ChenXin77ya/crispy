import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_stock_repository.dart';
import '../../data/stock_repository.dart';
import '../../domain/stock_models.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) => MockStockRepository());

final stockDetailProvider = FutureProvider.family<StockDetailViewModel, String>((ref, stockId) async {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getStockDetail(stockId);
});

