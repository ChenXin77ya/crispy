class HomeAssetSummary {
  const HomeAssetSummary({
    required this.totalAssets,
    required this.availableCash,
    required this.positionPnl,
    required this.creditScore,
  });

  final double totalAssets;
  final double availableCash;
  final double positionPnl;
  final int creditScore;
}

class NewsTickerItem {
  const NewsTickerItem({required this.title});

  final String title;
}

class WatchlistItem {
  const WatchlistItem({
    required this.stockId,
    required this.name,
    required this.lastPrice,
    required this.changePercent,
  });

  final String stockId;
  final String name;
  final double lastPrice;
  final double changePercent;
}

class HomeViewModel {
  const HomeViewModel({
    required this.assetSummary,
    required this.newsTicker,
    required this.watchlist,
  });

  final HomeAssetSummary assetSummary;
  final List<NewsTickerItem> newsTicker;
  final List<WatchlistItem> watchlist;
}

