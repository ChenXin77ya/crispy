class StockOrderBookLevel {
  const StockOrderBookLevel({required this.price, required this.quantity});

  final double price;
  final int quantity;
}

class StockOrderBook {
  const StockOrderBook({required this.bids, required this.asks});

  final List<StockOrderBookLevel> bids;
  final List<StockOrderBookLevel> asks;
}

class StockDetailViewModel {
  const StockDetailViewModel({
    required this.stockId,
    required this.name,
    required this.lastPrice,
    required this.changePercent,
    required this.riskTags,
    required this.orderBook,
    required this.about,
  });

  final String stockId;
  final String name;
  final double lastPrice;
  final double changePercent;
  final List<String> riskTags;
  final StockOrderBook orderBook;
  final String about;
}

