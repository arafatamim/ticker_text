import 'package:flutter/material.dart';
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

void main() => runApp(const TickerTextExampleApp());

class TickerTextExampleApp extends StatelessWidget {
  const TickerTextExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TickerText example',
      home: const TickerTextExample(),
    );
  }
}

class TickerTextExample extends StatefulWidget {
  const TickerTextExample({super.key});

  @override
  State<TickerTextExample> createState() => _TickerTextExampleState();
}

class _TickerTextExampleState extends State<TickerTextExample> {
  late final TickerTextController _tickerTextController;

  @override
  void initState() {
    super.initState();
    _tickerTextController = TickerTextController(autoStart: true);
  }

  @override
  void dispose() {
    _tickerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TickerText')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 50,
              child: TickerText(
                controller: _tickerTextController,
                child: const Text(text),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  onPressed: _tickerTextController.startScroll,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _tickerTextController.stopScroll,
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
