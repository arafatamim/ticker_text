# ticker_text for Flutter

Straightforward widget scroller with minimal dependencies.

## Features
- optional control with `TickerTextController`, 
- specifying scrolling speed and curves, 
- setting custom durations, \
and more.

## Example
```dart
TickerText(
  controller: tickerTextController, // this is optional
  scrollDirection: Axis.horizontal,
  speed: 20,
  startPauseDuration: const Duration(milliseconds: 500),
  endPauseDuration: const Duration(seconds: 2),
  child: Text("Very long paragraph of text...")
);
```

## Previews
<img src="./ticker_2.gif?raw=true">
<img src="./ticker_1.gif?raw=true">

## License
This project is MIT licensed.