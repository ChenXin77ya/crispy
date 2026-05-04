import '../domain/market_models.dart';

abstract class MarketRepository {
  Future<MarketViewModel> getMarket();
}

