import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_web_app/app/app.dart';

void main() {
  testWidgets('switch tabs using bottom navigation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.textContaining('首页'), findsWidgets);

    await tester.tap(find.text('新闻'));
    await tester.pumpAndSettle();
    expect(find.textContaining('新闻'), findsWidgets);

    await tester.tap(find.text('信用'));
    await tester.pumpAndSettle();
    expect(find.textContaining('信用'), findsWidgets);
  });
}

