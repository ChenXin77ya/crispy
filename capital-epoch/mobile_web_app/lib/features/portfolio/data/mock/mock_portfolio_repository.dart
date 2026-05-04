import '../../domain/portfolio_models.dart';
import '../portfolio_repository.dart';

class MockPortfolioRepository implements PortfolioRepository {
  @override
  Future<PortfolioSummary> getSummary() async {
    return const PortfolioSummary(
      totalAssets: 1280000,
      todayPnl: 3200,
      totalReturnPercent: 8.5,
      cash: 520000,
      debt: 0,
    );
  }
}

