# ticker_text for Flutter

[![Pub](https://img.shields.io/pub/v/ticker_text.svg)](https://pub.dev/packages/ticker_text)
[![CI](https://github.com/arafatamim/ticker_text/actions/workflows/ci.yml/badge.svg)](https://github.com/arafatamim/ticker_text/actions/workflows/ci.yml)

Straightforward widget scroller with minimal dependencies. It scrolls its child
when the child overflows, pauses at the end, and returns to the start.

![ticker_anim_1](https://github.com/user-attachments/assets/c81e2728-53eb-4c77-8595-89091819b7cf)

![ticker_anim_2](https://github.com/user-attachments/assets/bc10acf8-f3fd-498c-a221-ac39012ca7fe)

## Features

- automatic scrolling when the child overflows,
- optional control with [`TickerTextController`](https://pub.dev/documentation/ticker_text/latest/ticker_text/TickerTextController-class.html),
- configurable speed, pause durations, and curves,
- horizontal or vertical scrolling,
- no platform-specific dependencies.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ticker_text: ^2.2.0
```

Or run:

```sh
flutter pub add ticker_text
```

## Usage

The parent must constrain the size of the child so that it overflows for
scrolling to take effect:

```dart
SizedBox(
  width: 50, // constrain the width so the child overflows
  child: TickerText(
    // these are the default values
    scrollDirection: Axis.horizontal,
    speed: 20,
    startPauseDuration: const Duration(seconds: 10),
    endPauseDuration: const Duration(seconds: 10),
    returnDuration: const Duration(milliseconds: 800),
    primaryCurve: Curves.linear,
    returnCurve: Curves.easeOut,
    child: const Text('Very long sentence...'),
  ),
)
```

### Controlling the scroll

If no controller is provided, an internal controller starts scrolling
automatically. Pass a `TickerTextController` to start and stop scrolling
yourself:

```dart
final controller = TickerTextController(autoStart: false);

@override
void initState() {
  super.initState();
  controller.startScroll();
}

@override
void dispose() {
  controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return SizedBox(
    width: 200,
    child: TickerText(
      controller: controller,
      child: const Text('Very long sentence...'),
    ),
  );
}
```

Calling `stopScroll()` stops the animation and returns the content to its
starting position.

See the [example](example/main.dart) for a complete runnable app.

## API reference

Detailed API documentation can be found on
[pub.dev](https://pub.dev/documentation/ticker_text/latest/ticker_text/ticker_text-library.html).

## License

This project is [MIT licensed](https://github.com/arafatamim/ticker_text/blob/main/LICENSE).
