class CreditFactor {
  const CreditFactor({required this.name, required this.score});

  final String name;
  final int score;
}

class CreditEvent {
  const CreditEvent({required this.title});

  final String title;
}

class CreditProfile {
  const CreditProfile({
    required this.score,
    required this.level,
    required this.factors,
    required this.recentEvents,
  });

  final int score;
  final String level;
  final List<CreditFactor> factors;
  final List<CreditEvent> recentEvents;
}

