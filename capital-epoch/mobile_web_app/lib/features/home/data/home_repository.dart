import '../domain/home_models.dart';

abstract class HomeRepository {
  Future<HomeViewModel> getHome();
}

