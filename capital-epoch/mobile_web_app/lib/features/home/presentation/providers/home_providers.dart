import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/home_repository.dart';
import '../../data/mock/mock_home_repository.dart';
import '../../domain/home_models.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => MockHomeRepository());

final homeViewModelProvider = FutureProvider<HomeViewModel>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getHome();
});

