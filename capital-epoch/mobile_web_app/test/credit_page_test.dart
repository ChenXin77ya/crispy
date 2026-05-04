import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_web_app/app/app.dart';

void main() {
  testWidgets('credit shows mock profile', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('信用'));
    await tester.pumpAndSettle();

    expect(find.text('信用概览'), findsOneWidget);
    expect(find.textContaining('信用分'), findsOneWidget);
  });
}

