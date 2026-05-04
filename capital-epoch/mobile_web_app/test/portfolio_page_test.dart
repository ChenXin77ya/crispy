import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_web_app/app/app.dart';

void main() {
  testWidgets('portfolio shows mock summary', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('资产'));
    await tester.pumpAndSettle();

    expect(find.text('总览'), findsOneWidget);
    expect(find.textContaining('总资产'), findsOneWidget);
  });
}

