import 'dart:async';

import 'package:ticker_text/ticker_text.dart';
import "package:flutter/material.dart";

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

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TickerTextController _tickerTextController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 50,
            width: 100,
            child: TickerText(
              controller: _tickerTextController,
              scrollDirection: Axis.vertical,
              child: const Text(text),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _tickerTextController = TickerTextController(autoStart: false);

    // start scrolling after 10 seconds
    Timer(
      const Duration(seconds: 10),
      () {
        _tickerTextController.startScroll();
        // print(_tickerTextController.started);
      },
    );

    super.initState();
  }
}
