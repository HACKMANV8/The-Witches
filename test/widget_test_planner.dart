import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/pages/planner_page.dart';

void main() {
  testWidgets('PlannerPage builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PlannerPage())));
    await tester.pumpAndSettle();
    expect(find.byType(PlannerPage), findsOneWidget);
  });
}
