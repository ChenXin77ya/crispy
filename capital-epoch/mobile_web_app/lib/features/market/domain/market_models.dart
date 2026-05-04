class MarketStockItem {
  const MarketStockItem({
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

class MarketViewModel {
  const MarketViewModel({required this.stocks});

  final List<MarketStockItem> stocks;
}

