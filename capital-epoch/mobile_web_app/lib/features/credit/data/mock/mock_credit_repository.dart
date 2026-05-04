import '../../domain/credit_models.dart';
import '../credit_repository.dart';

class MockCreditRepository implements CreditRepository {
  @override
  Future<CreditProfile> getProfile() async {
    return const CreditProfile(
      score: 720,
      level: 'A',
      factors: [
        CreditFactor(name: '按时还款', score: 260),
        CreditFactor(name: '资产稳定性', score: 240),
        CreditFactor(name: '风险敞口', score: 220),
      ],
      recentEvents: [
        CreditEvent(title: '完成一次活期存款（+5）'),
        CreditEvent(title: '买入低波动股票（+2）'),
        CreditEvent(title: '阅读一条系统快讯（+1）'),
      ],
    );
  }
}

