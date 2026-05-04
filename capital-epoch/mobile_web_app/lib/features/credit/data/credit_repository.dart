import '../domain/credit_models.dart';

abstract class CreditRepository {
  Future<CreditProfile> getProfile();
}

