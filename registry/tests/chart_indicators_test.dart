// Tests for Chart indicators. Copied into your app by `ashlar add chart-indicators` with
// the component: they check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:ashlar_ui_gallery/ui/chart_indicators.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

typedef P = ({int i, double high, double low, double close, double volume});

final rows = <P>[
  for (var i = 0; i < 40; i++)
    (i: i, high: 12.0 + i % 5, low: 8.0 + i % 3, close: 10.0 + i % 4, volume: 100.0),
];

List<num?> values(DerivedSeries<P> d, [int k = 0]) => d.derive(rows)[k].values!;

void main() {
  test('moving averages', () {
    final c = [for (final r in rows) r.close];
    final sma = values(Sma(value: (r) => r.close, period: 4));
    expect(sma[2], isNull);
    expect(sma[3], (c[0] + c[1] + c[2] + c[3]) / 4);
    final wma = values(Wma(value: (r) => r.close, period: 3));
    expect(wma[2], (c[0] * 1 + c[1] * 2 + c[2] * 3) / 6);
    final ema = values(Ema(value: (r) => r.close, period: 3));
    expect(ema[2], (c[0] + c[1] + c[2]) / 3);
    expect(ema[3], closeTo(c[3] * .5 + ema[2]! * .5, 1e-9));
    expect(values(Tma(value: (r) => r.close, period: 4)).whereType<num>(), isNotEmpty);
  });

  test('bands sit either side of the average', () {
    final b = Bollinger<P>(value: (r) => r.close, period: 5).derive(rows);
    expect(b.map((s) => s.label), ['Upper band', 'Middle band', 'Lower band']);
    for (var i = 4; i < rows.length; i++) {
      expect(b[0].values![i]! >= b[1].values![i]!, isTrue);
      expect(b[2].values![i]! <= b[1].values![i]!, isTrue);
    }
  });

  test('oscillators stay in their ranges', () {
    for (final v in values(Rsi(value: (r) => r.close)).whereType<num>()) {
      expect(v, inInclusiveRange(0, 100));
    }
    final s = Stochastic<P>(high: (r) => r.high, low: (r) => r.low, close: (r) => r.close).derive(rows);
    for (final v in s[0].values!.whereType<num>()) {
      expect(v, inInclusiveRange(0, 100));
    }
    for (final v in values(Atr(high: (r) => r.high, low: (r) => r.low, close: (r) => r.close)).whereType<num>()) {
      expect(v, greaterThan(0));
    }
  });

  test('MACD, momentum, rate of change and accumulation', () {
    final m = Macd<P>(value: (r) => r.close).derive(rows);
    expect(m.map((s) => s.label), ['Histogram', 'MACD', 'Signal']);
    final mom = values(Momentum(value: (r) => r.close, period: 4));
    expect(mom[4], rows[4].close / rows[0].close * 100);
    final roc = values(RateOfChange(value: (r) => r.close, period: 4));
    expect(roc[4], (rows[4].close - rows[0].close) / rows[0].close * 100);
    final ad = values(
      AccumulationDistribution(high: (r) => r.high, low: (r) => r.low, close: (r) => r.close, volume: (r) => r.volume),
    );
    expect(ad.length, rows.length);
  });

  testWidgets('indicators draw in a chart', (tester) async {
    await tester.pumpWidget(
      AshlarApp(
        home: Center(
          child: SizedBox(
            width: 480,
            child: ComposedChart<P>(
              data: rows,
              x: (r) => r.i,
              children: [
                YAxis(),
                YAxis(id: 'o', right: true),
                Candlestick(label: 'P', open: (r) => r.close, high: (r) => r.high, low: (r) => r.low, close: (r) => r.close),
                Sma(value: (r) => r.close, period: 5),
                Bollinger(value: (r) => r.close),
                Macd(value: (r) => r.close, yAxisId: 'o'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
