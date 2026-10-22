// Ashlar UI: Chart indicators. Copied into your app by `ashlar add chart-indicators`; it
// is yours to change.
//
// The technical indicators traders read off prices, worked out from your rows and drawn
// as ordinary series: put one in a chart's children beside a Candlestick. Those on a
// scale of their own (RSI, MACD and the rest) take a `yAxisId`; give the chart a YAxis
// with that id.
//
// ```dart
// ComposedChart<Day>(
//   data: days,
//   x: (r) => r.day,
//   children: [
//     YAxis(),
//     YAxis(id: 'rsi', right: true, domain: (0, 100)),
//     Candlestick(label: 'KES', open: (r) => r.open, high: (r) => r.high, low: (r) => r.low, close: (r) => r.close),
//     Sma(value: (r) => r.close, period: 20),
//     Rsi(value: (r) => r.close, yAxisId: 'rsi'),
//   ],
// )
// ```

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'chart.dart';

List<double?> _read<T>(List<T> data, ChartValue<T> f) => [
  for (final r in data) f(r)?.toDouble(),
];

/// The mean of the last [period] values at each row; null until there are enough.
List<double?> _sma(List<double?> v, int period) {
  final out = List<double?>.filled(v.length, null);
  var sum = 0.0, count = 0;
  for (var i = 0; i < v.length; i++) {
    if (v[i] != null) {
      sum += v[i]!;
      count++;
    }
    if (i >= period && v[i - period] != null) {
      sum -= v[i - period]!;
      count--;
    }
    if (i >= period - 1 && count == period) out[i] = sum / period;
  }
  return out;
}

/// The exponential moving average: each row weighs the newest value 2 / (period + 1).
List<double?> _ema(List<double?> v, int period) {
  final out = List<double?>.filled(v.length, null);
  final k = 2 / (period + 1);
  double? prev;
  final seed = _sma(v, period);
  for (var i = 0; i < v.length; i++) {
    if (prev == null) {
      if (seed[i] != null) prev = out[i] = seed[i];
      continue;
    }
    if (v[i] == null) continue;
    prev = out[i] = v[i]! * k + prev * (1 - k);
  }
  return out;
}

/// The standard deviation of the last [period] values.
List<double?> _sd(List<double?> v, int period, List<double?> mean) => [
  for (var i = 0; i < v.length; i++)
    if (mean[i] == null)
      null
    else
      math.sqrt(
        [for (var k = i - period + 1; k <= i; k++) math.pow((v[k] ?? mean[i]!) - mean[i]!, 2)]
                .fold<double>(0, (a, x) => a + x) /
            period,
      ),
];

/// A simple moving average: the mean of the last [period] values.
class Sma<T> extends DerivedSeries<T> {
  const Sma({required this.value, this.period = 20, this.label, this.color, this.yAxisId = ''});

  final ChartValue<T> value;
  final int period;
  final String? label;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) => [
    Line(
      label: label ?? 'SMA $period',
      values: _sma(_read(data, value), period),
      color: color,
      yAxisId: yAxisId,
      curve: ChartCurve.linear,
      width: 1.5,
    ),
  ];
}

/// An exponential moving average: newer values count for more.
class Ema<T> extends DerivedSeries<T> {
  const Ema({required this.value, this.period = 20, this.label, this.color, this.yAxisId = ''});

  final ChartValue<T> value;
  final int period;
  final String? label;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) => [
    Line(
      label: label ?? 'EMA $period',
      values: _ema(_read(data, value), period),
      color: color,
      yAxisId: yAxisId,
      curve: ChartCurve.linear,
      width: 1.5,
    ),
  ];
}

/// A weighted moving average: the newest value counts [period] times, the oldest once.
class Wma<T> extends DerivedSeries<T> {
  const Wma({required this.value, this.period = 20, this.label, this.color, this.yAxisId = ''});

  final ChartValue<T> value;
  final int period;
  final String? label;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final v = _read(data, value);
    final weights = period * (period + 1) / 2;
    return [
      Line(
        label: label ?? 'WMA $period',
        values: [
          for (var i = 0; i < v.length; i++)
            if (i < period - 1 || v.sublist(i - period + 1, i + 1).contains(null))
              null
            else
              [for (var k = 0; k < period; k++) v[i - period + 1 + k]! * (k + 1)]
                      .fold<double>(0, (a, x) => a + x) /
                  weights,
        ],
        color: color,
        yAxisId: yAxisId,
        curve: ChartCurve.linear,
        width: 1.5,
      ),
    ];
  }
}

/// A triangular moving average: the moving average of the moving average, smoother
/// still.
class Tma<T> extends DerivedSeries<T> {
  const Tma({required this.value, this.period = 20, this.label, this.color, this.yAxisId = ''});

  final ChartValue<T> value;
  final int period;
  final String? label;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final half = (period + 1) ~/ 2;
    return [
      Line(
        label: label ?? 'TMA $period',
        values: _sma(_sma(_read(data, value), half), half),
        color: color,
        yAxisId: yAxisId,
        curve: ChartCurve.linear,
        width: 1.5,
      ),
    ];
  }
}

/// Bollinger bands: the moving average, and lines [deviations] standard deviations
/// above and below it.
class Bollinger<T> extends DerivedSeries<T> {
  const Bollinger({
    required this.value,
    this.period = 20,
    this.deviations = 2,
    this.color,
    this.yAxisId = '',
  });

  final ChartValue<T> value;
  final int period;
  final double deviations;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final v = _read(data, value);
    final mid = _sma(v, period);
    final sd = _sd(v, period, mid);
    return [
      Line(
        label: 'Upper band',
        values: [for (var i = 0; i < v.length; i++) mid[i] == null ? null : mid[i]! + deviations * sd[i]!],
        color: color,
        yAxisId: yAxisId,
        curve: ChartCurve.linear,
        width: 1,
        dashed: true,
      ),
      Line(
        label: 'Middle band',
        values: mid,
        color: color,
        yAxisId: yAxisId,
        curve: ChartCurve.linear,
        width: 1.5,
      ),
      Line(
        label: 'Lower band',
        values: [for (var i = 0; i < v.length; i++) mid[i] == null ? null : mid[i]! - deviations * sd[i]!],
        color: color,
        yAxisId: yAxisId,
        curve: ChartCurve.linear,
        width: 1,
        dashed: true,
      ),
    ];
  }
}

/// MACD: the gap between a fast and a slow exponential average, its own average (the
/// signal), and the gap between those two as bars.
class Macd<T> extends DerivedSeries<T> {
  const Macd({
    required this.value,
    this.fast = 12,
    this.slow = 26,
    this.signal = 9,
    this.yAxisId = '',
  });

  final ChartValue<T> value;
  final int fast, slow, signal;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final v = _read(data, value);
    final f = _ema(v, fast), s = _ema(v, slow);
    final macd = [for (var i = 0; i < v.length; i++) f[i] == null || s[i] == null ? null : f[i]! - s[i]!];
    final sig = _ema(macd, signal);
    return [
      Bar(
        label: 'Histogram',
        values: [for (var i = 0; i < v.length; i++) macd[i] == null || sig[i] == null ? null : macd[i]! - sig[i]!],
        yAxisId: yAxisId,
        radius: 0,
      ),
      Line(label: 'MACD', values: macd, yAxisId: yAxisId, curve: ChartCurve.linear, width: 1.5),
      Line(label: 'Signal', values: sig, yAxisId: yAxisId, curve: ChartCurve.linear, width: 1.5, dashed: true),
    ];
  }
}

/// The relative strength index, 0 to 100: above 70 is read as bought too far, below 30
/// sold too far.
class Rsi<T> extends DerivedSeries<T> {
  const Rsi({required this.value, this.period = 14, this.color, this.yAxisId = ''});

  final ChartValue<T> value;
  final int period;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final v = _read(data, value);
    final out = List<double?>.filled(v.length, null);
    double? gain, loss;
    for (var i = 1; i < v.length; i++) {
      if (v[i] == null || v[i - 1] == null) continue;
      final d = v[i]! - v[i - 1]!;
      final up = math.max(0.0, d), down = math.max(0.0, -d);
      if (i <= period) {
        gain = (gain ?? 0) + up / period;
        loss = (loss ?? 0) + down / period;
        if (i < period) continue;
      } else {
        // Wilder's smoothing.
        gain = (gain! * (period - 1) + up) / period;
        loss = (loss! * (period - 1) + down) / period;
      }
      out[i] = loss == 0 ? 100 : 100 - 100 / (1 + gain / loss);
    }
    return [
      Line(label: 'RSI $period', values: out, color: color, yAxisId: yAxisId, curve: ChartCurve.linear, width: 1.5),
    ];
  }
}

/// The stochastic oscillator, 0 to 100: where the close sits between the period's low
/// and high (%K), and its average (%D).
class Stochastic<T> extends DerivedSeries<T> {
  const Stochastic({
    required this.high,
    required this.low,
    required this.close,
    this.period = 14,
    this.kPeriod = 3,
    this.dPeriod = 3,
    this.yAxisId = '',
  });

  final ChartValue<T> high, low, close;
  final int period, kPeriod, dPeriod;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final h = _read(data, high), l = _read(data, low), c = _read(data, close);
    final raw = [
      for (var i = 0; i < c.length; i++)
        if (i < period - 1 || c[i] == null)
          null
        else
          () {
            final hs = h.sublist(i - period + 1, i + 1).whereType<double>();
            final ls = l.sublist(i - period + 1, i + 1).whereType<double>();
            if (hs.isEmpty || ls.isEmpty) return null;
            final hh = hs.reduce(math.max), ll = ls.reduce(math.min);
            return hh == ll ? 50.0 : (c[i]! - ll) / (hh - ll) * 100;
          }(),
    ];
    final k = _sma(raw, kPeriod);
    return [
      Line(label: '%K', values: k, yAxisId: yAxisId, curve: ChartCurve.linear, width: 1.5),
      Line(label: '%D', values: _sma(k, dPeriod), yAxisId: yAxisId, curve: ChartCurve.linear, width: 1.5, dashed: true),
    ];
  }
}

/// The average true range: how far prices move in a row, gaps included.
class Atr<T> extends DerivedSeries<T> {
  const Atr({
    required this.high,
    required this.low,
    required this.close,
    this.period = 14,
    this.color,
    this.yAxisId = '',
  });

  final ChartValue<T> high, low, close;
  final int period;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final h = _read(data, high), l = _read(data, low), c = _read(data, close);
    final tr = [
      for (var i = 0; i < c.length; i++)
        if (h[i] == null || l[i] == null)
          null
        else if (i == 0 || c[i - 1] == null)
          h[i]! - l[i]!
        else
          [h[i]! - l[i]!, (h[i]! - c[i - 1]!).abs(), (l[i]! - c[i - 1]!).abs()].reduce(math.max),
    ];
    final out = List<double?>.filled(c.length, null);
    final seed = _sma(tr, period);
    double? prev;
    for (var i = 0; i < c.length; i++) {
      if (prev == null) {
        if (seed[i] != null) prev = out[i] = seed[i];
        continue;
      }
      if (tr[i] == null) continue;
      prev = out[i] = (prev * (period - 1) + tr[i]!) / period;
    }
    return [
      Line(label: 'ATR $period', values: out, color: color, yAxisId: yAxisId, curve: ChartCurve.linear, width: 1.5),
    ];
  }
}

/// Accumulation/distribution: volume added when the close is near the high, taken away
/// near the low, as a running total.
class AccumulationDistribution<T> extends DerivedSeries<T> {
  const AccumulationDistribution({
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.color,
    this.yAxisId = '',
  });

  final ChartValue<T> high, low, close, volume;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final h = _read(data, high), l = _read(data, low), c = _read(data, close);
    final vol = _read(data, volume);
    var run = 0.0;
    final out = <double?>[
      for (var i = 0; i < c.length; i++)
        if (h[i] == null || l[i] == null || c[i] == null || vol[i] == null)
          null
        else
          run += h[i] == l[i]
              ? 0
              : ((c[i]! - l[i]!) - (h[i]! - c[i]!)) / (h[i]! - l[i]!) * vol[i]!,
    ];
    return [
      Line(label: 'A/D', values: out, color: color, yAxisId: yAxisId, curve: ChartCurve.linear, width: 1.5),
    ];
  }
}

/// Momentum: the value against the one [period] rows before, as a percentage (100 is
/// level).
class Momentum<T> extends DerivedSeries<T> {
  const Momentum({required this.value, this.period = 10, this.color, this.yAxisId = ''});

  final ChartValue<T> value;
  final int period;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final v = _read(data, value);
    return [
      Line(
        label: 'Momentum $period',
        values: [
          for (var i = 0; i < v.length; i++)
            i < period || v[i] == null || v[i - period] == null || v[i - period] == 0
                ? null
                : v[i]! / v[i - period]! * 100,
        ],
        color: color,
        yAxisId: yAxisId,
        curve: ChartCurve.linear,
        width: 1.5,
      ),
    ];
  }
}

/// The rate of change: how much the value moved over [period] rows, in percent.
class RateOfChange<T> extends DerivedSeries<T> {
  const RateOfChange({required this.value, this.period = 10, this.color, this.yAxisId = ''});

  final ChartValue<T> value;
  final int period;
  final Color? color;
  final String yAxisId;

  @override
  List<CartesianSeries<T>> derive(List<T> data) {
    final v = _read(data, value);
    return [
      Line(
        label: 'ROC $period',
        values: [
          for (var i = 0; i < v.length; i++)
            i < period || v[i] == null || v[i - period] == null || v[i - period] == 0
                ? null
                : (v[i]! - v[i - period]!) / v[i - period]! * 100,
        ],
        color: color,
        yAxisId: yAxisId,
        curve: ChartCurve.linear,
        width: 1.5,
      ),
    ];
  }
}
