## 2.2.0

* Update minimum SDK to Dart 3.0 / Flutter 3.10, as required by
  `fading_edge_scrollview`.
* Allow `flutter_lints` 3 through 6 so newer SDKs use current lint rules.
* Add repository, issue tracker, and topics metadata.
* Add a runnable example app with its own `pubspec.yaml`.
* Add a smoke test that renders the example and exercises start/stop.
* Fix `stopScroll()` not being observed by the internal auto-start controller.
* Recalculate fading edges after an orientation or window-size change (#4).
* Fix a caller-provided `TickerTextController` being disposed with the widget.
* Handle controller replacement through `didUpdateWidget`.
* Cancel pending delays when scrolling is stopped or the widget is disposed.
* Avoid starting more than one scroll loop at a time.
* Improve API documentation and test coverage.

## 2.1.0

* Support Dart 3. Lower minimum SDK version to 2.12.0.

## 2.0.0

* Flutter 3.0 migration.

## 1.0.0

* First iteration.
