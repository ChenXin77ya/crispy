class PortfolioSummary {
  const PortfolioSummary({
    required this.totalAssets,
    required this.todayPnl,
    required this.totalReturnPercent,
    required this.cash,
    required this.debt,
  });

  final double totalAssets;
  final double todayPnl;
  final double totalReturnPercent;
  final double cash;
  final double debt;
}

