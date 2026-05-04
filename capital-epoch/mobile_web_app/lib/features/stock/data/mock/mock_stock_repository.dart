import '../../domain/stock_models.dart';
import '../stock_repository.dart';

class MockStockRepository implements StockRepository {
  @override
  Future<StockDetailViewModel> getStockDetail(String stockId) async {
    if (stockId == 'S2') {
      return StockDetailViewModel(
        stockId: stockId,
        name: '恒星银行',
        lastPrice: 8.90,
        changePercent: -0.6,
        riskTags: const ['监管观察'],
        orderBook: const StockOrderBook(
          bids: [
            StockOrderBookLevel(price: 8.89, quantity: 1200),
            StockOrderBookLevel(price: 8.88, quantity: 800),
            StockOrderBookLevel(price: 8.87, quantity: 600),
            StockOrderBookLevel(price: 8.86, quantity: 400),
            StockOrderBookLevel(price: 8.85, quantity: 200),
          ],
          asks: [
            StockOrderBookLevel(price: 8.91, quantity: 1100),
            StockOrderBookLevel(price: 8.92, quantity: 700),
            StockOrderBookLevel(price: 8.93, quantity: 500),
            StockOrderBookLevel(price: 8.94, quantity: 300),
            StockOrderBookLevel(price: 8.95, quantity: 150),
          ],
        ),
        about: '区域性商业银行，主营存贷款业务与投行业务（简化说明）。',
      );
    }

    return StockDetailViewModel(
      stockId: stockId,
      name: '新远科技',
      lastPrice: 12.34,
      changePercent: 1.2,
      riskTags: const ['低波动'],
      orderBook: const StockOrderBook(
        bids: [
          StockOrderBookLevel(price: 12.33, quantity: 900),
          StockOrderBookLevel(price: 12.32, quantity: 650),
          StockOrderBookLevel(price: 12.31, quantity: 500),
          StockOrderBookLevel(price: 12.30, quantity: 350),
          StockOrderBookLevel(price: 12.29, quantity: 200),
        ],
        asks: [
          StockOrderBookLevel(price: 12.35, quantity: 880),
          StockOrderBookLevel(price: 12.36, quantity: 600),
          StockOrderBookLevel(price: 12.37, quantity: 420),
          StockOrderBookLevel(price: 12.38, quantity: 260),
          StockOrderBookLevel(price: 12.39, quantity: 180),
        ],
      ),
      about: '科技制造企业，主营业务为智能设备与工业软件（简化说明）。',
    );
  }
}

