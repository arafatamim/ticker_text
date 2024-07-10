import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticker_text/ticker_text.dart';

const text = """Bavarian bergkase cheddar cheese triangles.
Fromage frais bocconcini pecorino caerphilly chalk and cheese
cheddar fondue cheesy feet. Cheesy feet goat cheesy grin
smelly cheese everyone loves cauliflower cheese cut the
cheese everyone loves.
Monterey jack rubber cheese edam goat pepper jack fromage
frais say cheese bocconcini. Cottage cheese cheese slices.

Cheese triangles danish fontina cream cheese. When the
cheese comes out everybody's happy st. agur blue cheese
chalk and cheese cheddar cream cheese mozzarella cheesecake
cream cheese. The big cheese blue castello camembert de
normandie airedale stinking bishop cheddar hard cheese
squirty cheese. Red leicester squirty cheese cream cheese.
""";

const duration = Duration(milliseconds: 500);

Widget renderWidget(TickerTextController controller) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 100,
        height: 50,
        child: TickerText(
          controller: controller,
          startPauseDuration: duration,
          scrollDirection: Axis.vertical,
          child: const Text(text),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Automatically scrolls when loaded',
      (tester) async {
    final controller = TickerTextController(autoStart: true);
    await tester.pumpWidget(renderWidget(controller));

    final scrollController = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .widget
        .controller!;

    expect(scrollController.offset, 0.0);

    await tester.pumpAndSettle(duration);

    expect(scrollController.offset, 2130.0);

    controller.stopScroll();

    expect(scrollController.offset, 2130.0);

    await tester.pumpAndSettle(duration);
  });

  testWidgets('Does not start scrolling when auto start is disabled',
      (WidgetTester tester) async {
    final controller = TickerTextController(autoStart: false);

    await tester.pumpWidget(renderWidget(controller));

    final scrollController = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .widget
        .controller!;

    expect(scrollController.offset, 0.0);

    await tester.pumpAndSettle(duration);

    expect(scrollController.offset, 0.0);
  });

  testWidgets('Scrolls when called by controller', (WidgetTester tester) async {
    final controller = TickerTextController(autoStart: false);

    await tester.pumpWidget(renderWidget(controller));

    final scrollController = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .widget
        .controller!;

    expect(scrollController.offset, 0.0);

    controller.startScroll();

    await tester.pumpAndSettle(duration);

    expect(scrollController.offset, greaterThan(0.0));

    controller.stopScroll();

    await tester.pumpAndSettle(duration);
  });
}
