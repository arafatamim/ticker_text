import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticker_text/ticker_text.dart';

import '../main.dart';

void main() {
  testWidgets('example app renders and the ticker can be controlled', (
    tester,
  ) async {
    await tester.pumpWidget(const TickerTextExampleApp());

    expect(find.text('TickerText'), findsOneWidget);
    expect(find.byType(TickerText), findsOneWidget);
    expect(find.text(text), findsOneWidget);
    expect(tester.takeException(), isNull);

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, 0.0);

    // The example auto-starts after the default 10 second start pause.
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 1));
    expect(scrollable.position.pixels, greaterThan(0.0));

    await tester.tap(find.widgetWithText(OutlinedButton, 'Stop'));
    await tester.pump();
    expect(scrollable.position.pixels, 0.0);

    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 1));
    expect(scrollable.position.pixels, greaterThan(0.0));

    expect(tester.takeException(), isNull);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Stop'));
    await tester.pump();
  });
}
