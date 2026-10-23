// The chart indicators picture ashlar update --preview draws.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:ashlar_ui_gallery/ui/chart_indicators.dart';

typedef _Day = ({DateTime day, double open, double high, double low, double close});

final _days = () {
  final out = <_Day>[];
  var p = 100.0;
  for (var i = 0; i < 60; i++) {
    // A steady walk with a wave in it, the same every time.
    final c = p + ((i * 37) % 11 - 5) * .6 + (i % 20 < 10 ? .4 : -.4);
    out.add((
      day: DateTime(2026, 1, 1).add(Duration(days: i)),
      open: p,
      high: (p > c ? p : c) + 1.2,
      low: (p < c ? p : c) - 1.2,
      close: c,
    ));
    p = c;
  }
  return out;
}();

class ChartIndicatorsDemo extends StatelessWidget {
  const ChartIndicatorsDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 640,
    child: Card(
      children: [
        const CardHeader(title: Text('\$104.20'), description: Text('With Bollinger bands and RSI')),
        CardContent(
          child: ComposedChart<_Day>(
            data: _days,
            x: (r) => r.day,
            height: 240,
            children: [
              XAxis(type: AxisType.category, tickFormatter: (d) => chartDate(d as DateTime)),
              YAxis(),
              YAxis(id: 'rsi', right: true, domain: (0, 100)),
              ChartTooltip(),
              Candlestick(label: 'Price', open: (r) => r.open, high: (r) => r.high, low: (r) => r.low, close: (r) => r.close),
              Bollinger(value: (r) => r.close),
              Rsi(value: (r) => r.close, yAxisId: 'rsi'),
            ],
          ),
        ),
      ],
    ),
  );
}
