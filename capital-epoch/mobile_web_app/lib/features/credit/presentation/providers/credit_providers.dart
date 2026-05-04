import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/credit_repository.dart';
import '../../data/mock/mock_credit_repository.dart';
import '../../domain/credit_models.dart';

final creditRepositoryProvider = Provider<CreditRepository>((ref) => MockCreditRepository());

final creditProfileProvider = FutureProvider<CreditProfile>((ref) async {
  final repo = ref.watch(creditRepositoryProvider);
  return repo.getProfile();
});

