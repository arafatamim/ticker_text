# ticker_text for Flutter

[![Pub](https://img.shields.io/pub/v/ticker_text.svg)](https://pub.dartlang.org/packages/ticker_text)

Straightforward widget scroller with minimal dependencies.

![ticker_anim_1](https://github.com/user-attachments/assets/c81e2728-53eb-4c77-8595-89091819b7cf)

![ticker_anim_2](https://github.com/user-attachments/assets/bc10acf8-f3fd-498c-a221-ac39012ca7fe)

## Features

- optional control with [`TickerTextController`](https://pub.dev/documentation/ticker_text/latest/ticker_text/TickerTextController-class.html),
- specifying scrolling speed and curves,
- setting custom durations, \
  and more.

## Example

```dart
SizedBox(
  width: 50,  // constrain the parent width so the child overflows and scrolling takes effect
  child: TickerText(
    // default values
    controller: tickerTextController, // this is optional
    scrollDirection: Axis.horizontal,
    speed: 20,
    startPauseDuration: const Duration(seconds: 10),
    endPauseDuration: const Duration(seconds: 10),
    returnDuration: const Duration(milliseconds: 800),
    primaryCurve: Curves.linear,
    returnCurve: Curves.easeOut,
    child: Text("Very long sentence..."),
  ),
);
```

## API Reference

Detailed API documentation can be found on [pub.dev](https://pub.dev/documentation/ticker_text/latest/ticker_text/ticker_text-library.html).

## License

This project is [MIT licensed](https://github.com/arafatamim/ticker_text/blob/main/LICENSE).

