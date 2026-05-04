import '../../domain/home_models.dart';
import '../home_repository.dart';

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeViewModel> getHome() async {
    return const HomeViewModel(
      assetSummary: HomeAssetSummary(
        totalAssets: 1280000,
        availableCash: 520000,
        positionPnl: 12000,
        creditScore: 720,
      ),
      newsTicker: [
        NewsTickerItem(title: '央行下调基准利率 25bp，市场风险偏好回升'),
        NewsTickerItem(title: '监管提示：高波动资产交易需注意风险'),
      ],
      watchlist: [
        WatchlistItem(stockId: 'S1', name: '新远科技', lastPrice: 12.34, changePercent: 1.2),
        WatchlistItem(stockId: 'S2', name: '恒星银行', lastPrice: 8.90, changePercent: -0.6),
      ],
    );
  }
}

