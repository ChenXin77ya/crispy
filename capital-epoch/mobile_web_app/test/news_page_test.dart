import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_web_app/app/app.dart';

void main() {
  testWidgets('news shows mock lists', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('新闻'));
    await tester.pumpAndSettle();

    expect(find.textContaining('快讯'), findsWidgets);
  });
}

