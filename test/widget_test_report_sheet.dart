import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metropulse/widgets/report_crowd_sheet.dart';

void main() {
  testWidgets('ReportCrowdSheet opens without error', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Builder(builder: (context) {
      return Scaffold(body: Center(child: ElevatedButton(onPressed: () => showReportCrowdSheet(context), child: const Text('Open'))));
    }))));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Report Crowd'), findsOneWidget);
  });
}
