import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticker_text/ticker_text.dart';

void main() {
  testWidgets('recalculates the fading edge after an orientation change', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const captureKey = ValueKey('capture');

    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: 100,
                child: TickerText(
                  startPauseDuration: const Duration(milliseconds: 100),
                  child: Container(width: 700, height: 100, color: Colors.red),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;

    // In portrait the 700px child does not fit in the 400px viewport.
    expect(position.maxScrollExtent, greaterThan(0));

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(position.pixels, greaterThan(0));

    // Rotate to landscape. The child now fits, so it should not be faded.
    tester.view.physicalSize = const Size(800, 400);
    await tester.pump();
    await tester.pump();

    expect(position.maxScrollExtent, 0);
    expect(position.pixels, 0);

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );

    final image = await tester.runAsync(() => boundary.toImage());
    final bytes = await tester.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    final pixels = bytes!.buffer.asUint8List();

    int colorAt(int x, int y) {
      final index = (y * image!.width + x) * 4;
      return (pixels[index + 3] << 24) |
          (pixels[index] << 16) |
          (pixels[index + 1] << 8) |
          pixels[index + 2];
    }

    // The child is centered at x = 50..750. The end fade would cover its last
    // few pixels (x >= 715) if the fading edge was not recalculated.
    expect(colorAt(745, 200), Colors.red.toARGB32());

    image!.dispose();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
