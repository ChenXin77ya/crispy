import '../domain/news_models.dart';

abstract class NewsRepository {
  Future<NewsViewModel> getNews();
}

