import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_web_app/app/app.dart';

void main() {
  testWidgets('home shows mock content', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('资产总览'), findsOneWidget);
    expect(find.textContaining('信用分'), findsOneWidget);
    expect(find.textContaining('热点快讯'), findsOneWidget);
    expect(find.textContaining('自选'), findsOneWidget);
    expect(find.textContaining('新远科技'), findsOneWidget);
  });
}

