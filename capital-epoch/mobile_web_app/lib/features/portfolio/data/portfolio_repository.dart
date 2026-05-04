import '../domain/portfolio_models.dart';

abstract class PortfolioRepository {
  Future<PortfolioSummary> getSummary();
}

