class NewsItem {
  const NewsItem({required this.title, required this.source});

  final String title;
  final String source;
}

class NewsViewModel {
  const NewsViewModel({required this.flash, required this.announcements});

  final List<NewsItem> flash;
  final List<NewsItem> announcements;
}

