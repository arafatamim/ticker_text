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

Widget renderWidget(
  TickerTextController? controller, {
  Axis scrollDirection = Axis.vertical,
  Widget child = const Text(text),
  int speed = 20,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 100,
        height: 50,
        child: TickerText(
          controller: controller,
          startPauseDuration: duration,
          scrollDirection: scrollDirection,
          speed: speed,
          child: child,
        ),
      ),
    ),
  );
}

ScrollController scrollControllerOf(WidgetTester tester) {
  return tester
      .state<ScrollableState>(find.byType(Scrollable))
      .widget
      .controller!;
}

void main() {
  test('TickerTextController notifies only when the state changes', () {
    final controller = TickerTextController();
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.startScroll();
    controller.startScroll();
    expect(controller.started, isTrue);
    expect(notifications, 1);

    controller.stopScroll();
    controller.stopScroll();
    expect(controller.started, isFalse);
    expect(notifications, 2);

    controller.dispose();
  });

  testWidgets('automatically scrolls when loaded', (tester) async {
    final controller = TickerTextController(autoStart: true);
    addTearDown(controller.dispose);
    await tester.pumpWidget(renderWidget(controller));

    final scrollController = scrollControllerOf(tester);
    final maxScrollExtent = scrollController.position.maxScrollExtent;

    expect(maxScrollExtent, greaterThan(0));
    expect(scrollController.offset, 0.0);

    await tester.pump(duration);
    await tester.pumpAndSettle();

    expect(scrollController.offset, maxScrollExtent);

    controller.stopScroll();
    await tester.pump();

    expect(scrollController.offset, 0.0);
  });

  testWidgets('does not start scrolling when auto start is disabled', (
    tester,
  ) async {
    final controller = TickerTextController(autoStart: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(renderWidget(controller));

    final scrollController = scrollControllerOf(tester);
    expect(scrollController.offset, 0.0);

    await tester.pump(duration);
    await tester.pumpAndSettle();

    expect(scrollController.offset, 0.0);
  });

  testWidgets('scrolls when started and returns to start when stopped', (
    tester,
  ) async {
    final controller = TickerTextController(autoStart: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(renderWidget(controller));

    final scrollController = scrollControllerOf(tester);
    expect(scrollController.offset, 0.0);

    controller.startScroll();
    await tester.pump(duration);
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0.0));

    controller.stopScroll();
    await tester.pump();

    expect(scrollController.offset, 0.0);

    await tester.pumpAndSettle();
  });

  testWidgets('scrolls back to the start after reaching the end', (
    tester,
  ) async {
    final controller = TickerTextController(autoStart: true);
    addTearDown(controller.dispose);

    await tester.pumpWidget(renderWidget(controller, speed: 2000));

    final scrollController = scrollControllerOf(tester);
    final maxScrollExtent = scrollController.position.maxScrollExtent;

    await tester.pump(duration);
    await tester.pumpAndSettle();

    expect(scrollController.offset, maxScrollExtent);

    await tester.pump(duration); // Wait for the end pause.
    await tester.pumpAndSettle();

    expect(scrollController.offset, 0.0);

    controller.stopScroll();
    await tester.pump();
  });

  testWidgets('stopping mid-animation returns to the start', (tester) async {
    final controller = TickerTextController(autoStart: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(renderWidget(controller, speed: 100));

    final scrollController = scrollControllerOf(tester);
    final maxScrollExtent = scrollController.position.maxScrollExtent;

    controller.startScroll();
    await tester.pump(duration);
    await tester.pump(const Duration(seconds: 1));

    expect(scrollController.offset, greaterThan(0.0));
    expect(scrollController.offset, lessThan(maxScrollExtent));

    controller.stopScroll();
    await tester.pump();

    expect(scrollController.offset, 0.0);
  });

  testWidgets('stopping during the initial pause cancels the pending scroll', (
    tester,
  ) async {
    final controller = TickerTextController(autoStart: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(renderWidget(controller));

    final scrollController = scrollControllerOf(tester);

    controller.startScroll();
    await tester.pump(const Duration(milliseconds: 100));
    controller.stopScroll();
    await tester.pump();

    expect(scrollController.offset, 0.0);

    // The cancelled start pause must not scroll the widget later.
    await tester.pump(const Duration(seconds: 20));
    expect(scrollController.offset, 0.0);
  });

  testWidgets('can be restarted after stopping', (tester) async {
    final controller = TickerTextController(autoStart: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(renderWidget(controller));

    final scrollController = scrollControllerOf(tester);

    controller.startScroll();
    await tester.pump(duration);
    await tester.pumpAndSettle();
    expect(scrollController.offset, greaterThan(0.0));

    controller.stopScroll();
    await tester.pump();
    expect(scrollController.offset, 0.0);

    controller.startScroll();
    await tester.pump(duration);
    await tester.pumpAndSettle();
    expect(scrollController.offset, greaterThan(0.0));

    controller.stopScroll();
    await tester.pump();
  });

  testWidgets('does not dispose a controller owned by the caller', (
    tester,
  ) async {
    final controller = TickerTextController(autoStart: false);

    await tester.pumpWidget(renderWidget(controller));
    await tester.pumpWidget(const SizedBox.shrink());

    // A disposed ChangeNotifier would throw when notified.
    expect(controller.startScroll, returnsNormally);
    controller.dispose();
  });

  testWidgets('switches to a new controller when the widget is updated', (
    tester,
  ) async {
    final first = TickerTextController(autoStart: false);
    final second = TickerTextController(autoStart: false);
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await tester.pumpWidget(renderWidget(first));
    await tester.pumpWidget(renderWidget(second));

    final scrollController = scrollControllerOf(tester);

    second.startScroll();
    await tester.pump(duration);
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0.0));

    // The old controller is detached but still usable.
    expect(first.startScroll, returnsNormally);
    expect(first.started, isTrue);
    first.stopScroll();

    second.stopScroll();
    await tester.pump();
  });

  testWidgets('scrolls horizontally', (tester) async {
    final controller = TickerTextController(autoStart: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      renderWidget(controller, scrollDirection: Axis.horizontal),
    );

    final scrollController = scrollControllerOf(tester);

    controller.startScroll();
    await tester.pump(duration);
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0.0));
    expect(scrollController.position.axisDirection, AxisDirection.right);

    controller.stopScroll();
    await tester.pump();
  });

  testWidgets('does not scroll when the child does not overflow', (
    tester,
  ) async {
    final controller = TickerTextController(autoStart: true);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      renderWidget(controller, child: const Text('Short')),
    );

    final scrollController = scrollControllerOf(tester);
    expect(scrollController.position.maxScrollExtent, 0.0);

    await tester.pump(duration);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(scrollController.offset, 0.0);

    controller.stopScroll();
    await tester.pump();
  });
}
