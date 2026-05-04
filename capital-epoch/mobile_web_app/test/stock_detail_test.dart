import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_web_app/features/stock/presentation/pages/stock_detail_page.dart';

void main() {
  testWidgets('stock detail shows mock content', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: StockDetailPage(stockId: 'S1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('新远科技'), findsWidgets);
    expect(find.textContaining('图表占位', skipOffstage: false), findsOneWidget);
    expect(find.textContaining('盘口', skipOffstage: false), findsOneWidget);
  });
}
