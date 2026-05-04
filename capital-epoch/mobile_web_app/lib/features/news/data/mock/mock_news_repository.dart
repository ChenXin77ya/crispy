import '../../domain/news_models.dart';
import '../news_repository.dart';

class MockNewsRepository implements NewsRepository {
  @override
  Future<NewsViewModel> getNews() async {
    return const NewsViewModel(
      flash: [
        NewsItem(title: '央行下调基准利率 25bp，资金面改善', source: '系统快讯'),
        NewsItem(title: '监管提示：高波动资产交易需注意风险', source: '系统快讯'),
      ],
      announcements: [
        NewsItem(title: '恒星银行：调整活期利率与部分授信政策', source: '主体公告'),
        NewsItem(title: '新远科技：发布季度经营快报（简化）', source: '主体公告'),
      ],
    );
  }
}

