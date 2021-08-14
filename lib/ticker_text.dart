library ticker_text;

import 'package:flutter/material.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

class TickerTextController extends ChangeNotifier {
  bool _started;

  /// Check if scrolling has started
  bool get started => _started;

  TickerTextController({bool autoStart = false}) : _started = autoStart;

  void startScroll() {
    _started = true;
    notifyListeners();
  }

  void stopScroll() {
    _started = false;
    notifyListeners();
  }
}

class TickerText extends StatefulWidget {
  final Widget child;
  final Axis scrollDirection;

  /// Speed at which the widget scrolls in pixels per second.
  /// Has to be greater than zero.
  final int speed;

  /// How long it takes for the widget to scroll back up from the end.
  final Duration returnDuration;

  /// How long it takes for widget to begin scrolling.
  final Duration startPauseDuration;

  /// How long the scrolling pauses at the end before scrolling back up.
  /// If null, it is the same as [startPauseDuration].
  final Duration? endPauseDuration;

  /// Controls the state of scrolling. If not provided, uses its default internal controller
  /// with `autoStart` enabled.
  final TickerTextController? controller;

  final Curve primaryCurve;

  final Curve returnCurve;

  /// Creates a widget that scrolls to reveal child contents if it overflows,
  /// and scrolls back up when it reaches the end.
  /// Optionally accepts a [TickerTextController] to control scroll behavior.
  ///
  /// Example:
  /// ```
  /// TickerText(
  ///   scrollDirection: Axis.horizontal,
  ///   speed: 20,
  ///   startPauseDuration: const Duration(milliseconds: 500),
  ///   endPauseDuration: const Duration(seconds: 2),
  ///   child: Text("Very long paragraph of text...")
  /// );
  /// ```
  const TickerText({
    Key? key,
    required this.child,
    this.scrollDirection = Axis.horizontal,
    this.returnDuration = const Duration(milliseconds: 800),
    this.startPauseDuration = const Duration(seconds: 10),
    this.endPauseDuration,
    this.speed = 20,
    this.controller,
    this.primaryCurve = Curves.linear,
    this.returnCurve = Curves.easeOut,
  })  : assert(speed > 0, "Speed has to be greater than zero"),
        super(key: key);

  @override
  _TickerTextState createState() => _TickerTextState();
}

class _TickerTextState extends State<TickerText> {
  late final ScrollController _scrollController;
  late final TickerTextController _autoScrollController;

  double get maxScrollExtent => _scrollController.position.maxScrollExtent;
  Duration get scrollDuration => Duration(
        milliseconds: ((maxScrollExtent / widget.speed) * 1000).toInt(),
      );

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _autoScrollController =
        widget.controller ?? TickerTextController(autoStart: true);

    if (_autoScrollController.started) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => _scroll());
    } else {
      _autoScrollController.addListener(_scroll);
    }

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: widget.child,
        scrollDirection: widget.scrollDirection,
        controller: _scrollController,
      ),
    );
  }

  void _scroll() async {
    if (_scrollController.hasClients &&
        _scrollController.offset > 0 &&
        !_autoScrollController.started) {
      _scrollController.jumpTo(0);
      return;
    }
    while (_scrollController.hasClients && _autoScrollController.started) {
      // Run futures in succession
      await Future.delayed(widget.startPauseDuration).then((_) {
        if (_scrollController.hasClients &&
            _autoScrollController.started &&
            _scrollController.offset == 0) {
          return _scrollController.animateTo(
            maxScrollExtent,
            duration: scrollDuration,
            curve: widget.primaryCurve,
          );
        }
      }).then((_) {
        if (_scrollController.hasClients &&
            _autoScrollController.started &&
            _scrollController.offset == maxScrollExtent) {
          return Future.delayed(
            widget.endPauseDuration ?? widget.startPauseDuration,
          );
        }
      }).then((_) {
        if (_scrollController.hasClients &&
            _scrollController.offset == maxScrollExtent) {
          return _scrollController.animateTo(
            0.0,
            duration: widget.returnDuration,
            curve: widget.returnCurve,
          );
        }
      });
    }
  }
}
