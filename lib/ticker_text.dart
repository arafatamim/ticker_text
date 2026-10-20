/// A configurable ticker widget for Flutter.
library;

import 'dart:async';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

/// Controls the scrolling behavior of a [TickerText] widget.
///
/// If no controller is passed to [TickerText], an internal controller with
/// `autoStart: true` is created. Pass your own controller to start and stop
/// scrolling manually.
///
/// ```dart
/// final controller = TickerTextController();
///
/// TickerText(controller: controller, child: const Text('Hello'));
///
/// controller.startScroll();
/// controller.stopScroll();
/// ```
class TickerTextController extends ChangeNotifier {
  bool _started;

  /// Whether the [TickerText] controlled by this object is currently scrolling.
  bool get started => _started;

  /// Creates a controller.
  ///
  /// When [autoStart] is `true`, scrolling begins as soon as the widget is
  /// laid out.
  TickerTextController({bool autoStart = false}) : _started = autoStart;

  /// Starts scrolling.
  ///
  /// Calling this while scrolling is already in progress has no effect.
  void startScroll() {
    if (_started) return;
    _started = true;
    notifyListeners();
  }

  /// Stops scrolling and returns the content to its starting position.
  ///
  /// Calling this while scrolling is already stopped has no effect.
  void stopScroll() {
    if (!_started) return;
    _started = false;
    notifyListeners();
  }
}

/// A widget that scrolls its child to reveal overflowing content and then
/// scrolls back to the start.
///
/// Constrain the size of the parent so that [child] overflows for the scrolling
/// to take effect:
///
/// ```dart
/// SizedBox(
///   width: 100,
///   child: TickerText(
///     child: Text('A sentence that is wider than 100 pixels.'),
///   ),
/// )
/// ```
///
/// Scrolling is driven by a [TickerTextController]. If [controller] is omitted,
/// an internal controller with `autoStart: true` is used.
class TickerText extends StatefulWidget {
  /// The widget to scroll.
  final Widget child;

  /// The axis along which [child] is scrolled.
  final Axis scrollDirection;

  /// The speed at which the widget scrolls in pixels per second.
  ///
  /// Must be greater than zero.
  final int speed;

  /// How long it takes for the widget to scroll back to the start after
  /// reaching the end.
  final Duration returnDuration;

  /// How long the widget waits before it begins scrolling.
  final Duration startPauseDuration;

  /// How long the widget waits at the end before scrolling back to the start.
  ///
  /// If `null`, [startPauseDuration] is used.
  final Duration? endPauseDuration;

  /// Controls the state of scrolling.
  ///
  /// If not provided, an internal controller with `autoStart: true` is used.
  final TickerTextController? controller;

  /// The curve used while scrolling towards the end of [child].
  final Curve primaryCurve;

  /// The curve used while scrolling back to the start.
  final Curve returnCurve;

  /// Creates a widget that scrolls to reveal child contents if it overflows,
  /// and scrolls back to the start when it reaches the end.
  ///
  /// Optionally accepts a [TickerTextController] to control scroll behavior.
  ///
  /// Example:
  /// ```dart
  /// TickerText(
  ///   scrollDirection: Axis.horizontal,
  ///   speed: 20,
  ///   startPauseDuration: const Duration(milliseconds: 500),
  ///   endPauseDuration: const Duration(seconds: 2),
  ///   child: Text('Very long paragraph of text...'),
  /// );
  /// ```
  const TickerText({
    super.key,
    required this.child,
    this.scrollDirection = Axis.horizontal,
    this.returnDuration = const Duration(milliseconds: 800),
    this.startPauseDuration = const Duration(seconds: 10),
    this.endPauseDuration,
    this.speed = 20,
    this.controller,
    this.primaryCurve = Curves.linear,
    this.returnCurve = Curves.easeOut,
  }) : assert(speed > 0, 'Speed has to be greater than zero');

  @override
  State<TickerText> createState() => _TickerTextState();
}

class _TickerTextState extends State<TickerText> {
  late final ScrollController _scrollController;
  late TickerTextController _tickerController;
  bool _ownsController = false;

  /// Identifies the current scroll run. Incremented whenever scrolling is
  /// restarted or stopped, which invalidates any run still awaiting an
  /// animation or a delay.
  int _runId = 0;

  Timer? _delayTimer;
  Completer<void>? _delayCompleter;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _attachController(
      widget.controller ?? TickerTextController(autoStart: true),
      ownsController: widget.controller == null,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _restartScrolling());
  }

  @override
  void didUpdateWidget(covariant TickerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachController();
      _attachController(
        widget.controller ?? TickerTextController(autoStart: true),
        ownsController: widget.controller == null,
      );
      _restartScrolling();
    }
  }

  @override
  void dispose() {
    _runId++;
    _cancelDelay();
    _detachController();
    _scrollController.dispose();
    super.dispose();
  }

  void _attachController(
    TickerTextController controller, {
    required bool ownsController,
  }) {
    _tickerController = controller;
    _ownsController = ownsController;
    _tickerController.addListener(_handleControllerChange);
  }

  void _detachController() {
    _tickerController.removeListener(_handleControllerChange);
    if (_ownsController) {
      _tickerController.dispose();
    }
  }

  void _handleControllerChange() => _restartScrolling();

  void _restartScrolling() {
    _runId++;
    _cancelDelay();

    if (!mounted) return;

    if (!_tickerController.started) {
      _jumpToStart();
      return;
    }

    unawaited(_run(_runId));
  }

  bool _isActive(int runId) =>
      mounted && runId == _runId && _tickerController.started;

  void _jumpToStart() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset != 0) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _run(int runId) async {
    while (_isActive(runId)) {
      await _delay(widget.startPauseDuration);
      if (!_isActive(runId) || !_scrollController.hasClients) return;

      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      if (maxScrollExtent <= 0) {
        // Nothing to scroll right now. Check again after the start pause in
        // case the child starts overflowing later.
        continue;
      }

      await _scrollController.animateTo(
        maxScrollExtent,
        duration: _scrollDuration(maxScrollExtent),
        curve: widget.primaryCurve,
      );
      if (!_isActive(runId)) return;

      await _delay(widget.endPauseDuration ?? widget.startPauseDuration);
      if (!_isActive(runId) || !_scrollController.hasClients) return;

      await _scrollController.animateTo(
        0,
        duration: widget.returnDuration,
        curve: widget.returnCurve,
      );
    }
  }

  Duration _scrollDuration(double maxScrollExtent) {
    final milliseconds = (maxScrollExtent / widget.speed * 1000).round();
    return Duration(milliseconds: milliseconds);
  }

  /// Waits for [duration], but lets [_cancelDelay] complete the wait early so
  /// that a stopped or disposed widget does not leave a timer behind.
  Future<void> _delay(Duration duration) {
    _cancelDelay();

    final completer = Completer<void>();
    _delayCompleter = completer;
    _delayTimer = Timer(duration, () {
      _delayTimer = null;
      _delayCompleter = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    return completer.future;
  }

  void _cancelDelay() {
    _delayTimer?.cancel();
    _delayTimer = null;

    final completer = _delayCompleter;
    _delayCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: widget.scrollDirection,
        controller: _scrollController,
        child: widget.child,
      ),
    );
  }
}
