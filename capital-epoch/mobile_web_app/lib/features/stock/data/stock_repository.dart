import '../domain/stock_models.dart';

abstract class StockRepository {
  Future<StockDetailViewModel> getStockDetail(String stockId);
}

