# ticker_text for Flutter

[![Pub](https://img.shields.io/pub/v/ticker_text.svg)](https://pub.dartlang.org/packages/ticker_text)

Straightforward widget scroller with minimal dependencies.

<img src="https://raw.githubusercontent.com/arafatamim/ticker_text/main/ticker_2.gif?raw=true">
<img src="https://raw.githubusercontent.com/arafatamim/ticker_text/main/ticker_1.gif?raw=true">

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

