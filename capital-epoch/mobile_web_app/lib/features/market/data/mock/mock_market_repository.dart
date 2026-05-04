import '../../domain/market_models.dart';
import '../market_repository.dart';

class MockMarketRepository implements MarketRepository {
  @override
  Future<MarketViewModel> getMarket() async {
    return const MarketViewModel(
      stocks: [
        MarketStockItem(stockId: 'S1', name: '新远科技', lastPrice: 12.34, changePercent: 1.2),
        MarketStockItem(stockId: 'S2', name: '恒星银行', lastPrice: 8.90, changePercent: -0.6),
        MarketStockItem(stockId: 'S3', name: '北陆能源', lastPrice: 6.21, changePercent: 0.1),
        MarketStockItem(stockId: 'S4', name: '海湾航运', lastPrice: 4.56, changePercent: -1.8),
      ],
    );
  }
}

