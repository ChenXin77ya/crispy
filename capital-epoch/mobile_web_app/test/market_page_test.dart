import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_web_app/app/app.dart';

void main() {
  testWidgets('market shows mock stock list', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('市场'));
    await tester.pumpAndSettle();

    expect(find.text('股票'), findsOneWidget);
    expect(find.textContaining('新远科技'), findsWidgets);
  });
}

