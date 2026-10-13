// Ashlar UI: Chart. Copied into your app by `ashlar add chart`; it is yours to change.
//
// Drawn on the canvas here, with no charting package: bars, lines, areas and pies, with
// a tooltip on hover, the arrow keys stepping through the values, and a summary a screen
// reader can read.

import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

/// One run of values, one per label: "Desktop", "Mobile".
@immutable
class ChartSeries {
  const ChartSeries(this.label, this.values, {this.color});

  final String label;
  final List<double> values;

  /// Null takes the theme's chart colours in turn.
  final Color? color;
}

/// One part of a pie.
@immutable
class ChartSlice {
  const ChartSlice(this.label, this.value, {this.color});

  final String label;
  final double value;
  final Color? color;
}

String _plain(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// A round number at or above [max] for the top of the scale: 1, 2, 2.5 or 5 times a
/// power of ten.
double _niceTop(double max) {
  if (max <= 0) return 1;
  final p = math.pow(10, (math.log(max) / math.ln10).floor()).toDouble();
  for (final m in [1.0, 2.0, 2.5, 5.0, 10.0]) {
    if (m * p >= max) return m * p;
  }
  return 10 * p;
}

enum _Kind { bar, line, area }

/// Bars by label, a series side by side or stacked.
///
/// ```dart
/// BarChart(
///   labels: ['Jan', 'Feb', 'Mar'],
///   series: [ChartSeries('Desktop', [186, 305, 237]), ChartSeries('Mobile', [80, 200, 120])],
/// )
/// ```
class BarChart extends _Cartesian {
  const BarChart({
    super.key,
    required super.labels,
    required super.series,
    super.height,
    super.stacked,
    super.format,
    super.semanticLabel,
    super.legend,
  }) : super(kind: _Kind.bar);
}

/// Lines through each series' values.
class LineChart extends _Cartesian {
  const LineChart({
    super.key,
    required super.labels,
    required super.series,
    super.height,
    super.format,
    super.semanticLabel,
    super.legend,
    super.curved,
  }) : super(kind: _Kind.line);
}

/// Lines with the area under them filled; [stacked] puts each series on the one below.
class AreaChart extends _Cartesian {
  const AreaChart({
    super.key,
    required super.labels,
    required super.series,
    super.height,
    super.stacked,
    super.format,
    super.semanticLabel,
    super.legend,
    super.curved,
  }) : super(kind: _Kind.area);
}

abstract class _Cartesian extends StatefulWidget {
  const _Cartesian({
    super.key,
    required this.labels,
    required this.series,
    required this.kind,
    this.height = 250,
    this.stacked = false,
    this.curved = true,
    this.legend = true,
    this.format = _plain,
    this.semanticLabel,
  });

  final List<String> labels;
  final List<ChartSeries> series;
  final _Kind kind;
  final double height;
  final bool stacked, curved, legend;

  /// How a value is written in the tooltip and read out: "KES 2,400".
  final String Function(double value) format;

  /// What the chart shows, read before its values: 'Visitors by month'.
  final String? semanticLabel;

  @override
  State<_Cartesian> createState() => _CartesianState();
}

class _CartesianState extends State<_Cartesian>
    with SingleTickerProviderStateMixin {
  late final _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  int? _at;
  bool _focused = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _grow.value = 1;
    } else if (_grow.isDismissed) {
      _grow.forward();
    }
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  List<Color> _colors(AshlarColors c) => [
    for (final (i, s) in widget.series.indexed)
      s.color ?? c.charts[i % c.charts.length],
  ];

  String get _summary => [
    for (final (i, label) in widget.labels.indexed)
      '$label: ${[for (final s in widget.series) '${s.label} ${widget.format(s.values[i])}'].join(', ')}',
  ].join('; ');

  void _step(int by) {
    final n = widget.labels.length;
    setState(() => _at = ((_at ?? (by > 0 ? -1 : n)) + by).clamp(0, n - 1));
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final colors = _colors(c);
    final n = widget.labels.length;
    final top = _niceTop(
      [
        for (var i = 0; i < n; i++)
          widget.stacked
              ? widget.series.fold<double>(0, (s, x) => s + x.values[i])
              : widget.series.map((s) => s.values[i]).fold<double>(0, math.max),
      ].fold<double>(0, math.max),
    );
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Chart',
      value: _summary,
      child: Focus(
        onFocusChange: (f) => setState(() {
          _focused =
              f &&
              FocusManager.instance.highlightMode ==
                  FocusHighlightMode.traditional;
          if (!f) _at = null;
        }),
        onKeyEvent: (node, e) {
          if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
            return KeyEventResult.ignored;
          }
          if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
            _step(1);
            return KeyEventResult.handled;
          }
          if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _step(-1);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: widget.height,
              child: LayoutBuilder(
                builder: (context, box) {
                  final plot = Size(box.maxWidth, widget.height - 24);
                  int? indexAt(Offset p) => n == 0
                      ? null
                      : (p.dx / plot.width * n).floor().clamp(0, n - 1);
                  return MouseRegion(
                    onHover: (e) =>
                        setState(() => _at = indexAt(e.localPosition)),
                    onExit: (_) => setState(() => _at = null),
                    child: GestureDetector(
                      onTapDown: (d) =>
                          setState(() => _at = indexAt(d.localPosition)),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _grow,
                              builder: (context, _) => CustomPaint(
                                painter: _CartesianPainter(
                                  kind: widget.kind,
                                  series: widget.series,
                                  colors: colors,
                                  top: top,
                                  stacked: widget.stacked,
                                  curved: widget.curved,
                                  grow: Curves.easeOutCubic.transform(
                                    _grow.value,
                                  ),
                                  at: _at,
                                  grid: c.border,
                                  cursor: c.muted,
                                  ring: _focused ? c.ring : null,
                                  plotHeight: plot.height,
                                ),
                              ),
                            ),
                          ),
                          // Labels along the bottom.
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 20,
                            child: ExcludeSemantics(
                              child: Row(
                                children: [
                                  for (final l in widget.labels)
                                    Expanded(
                                      child: Text(
                                        l,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                        style: t.text.xs.copyWith(
                                          color: c.mutedForeground,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_at != null)
                            _Tooltip(
                              x: (_at! + .5) / n * plot.width,
                              width: plot.width,
                              title: widget.labels[_at!],
                              rows: [
                                for (final (i, s) in widget.series.indexed)
                                  (
                                    colors[i],
                                    s.label,
                                    widget.format(s.values[_at!]),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.legend && widget.series.length > 1) ...[
              const SizedBox(height: 12),
              _Legend(
                items: [
                  for (final (i, s) in widget.series.indexed)
                    (colors[i], s.label),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartesianPainter extends CustomPainter {
  _CartesianPainter({
    required this.kind,
    required this.series,
    required this.colors,
    required this.top,
    required this.stacked,
    required this.curved,
    required this.grow,
    required this.at,
    required this.grid,
    required this.cursor,
    required this.ring,
    required this.plotHeight,
  });

  final _Kind kind;
  final List<ChartSeries> series;
  final List<Color> colors;
  final double top, grow, plotHeight;
  final bool stacked, curved;
  final int? at;
  final Color grid, cursor;
  final Color? ring;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = plotHeight;
    if (series.isEmpty || series.first.values.isEmpty) return;
    final n = series.first.values.length;
    final band = w / n;
    double y(double v) => h - (v / top) * h * grow;

    // Gridlines: four steps, the bottom one solid.
    final line = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final gy = (h * i / 4).roundToDouble() + .5;
      canvas.drawLine(Offset(0, gy), Offset(w, gy), line);
    }
    // The column under the pointer, behind the bars.
    if (at != null && kind == _Kind.bar) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(at! * band + 2, 0, band - 4, h),
          const Radius.circular(6),
        ),
        Paint()..color = cursor,
      );
    }
    if (ring != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h).inflate(4),
          const Radius.circular(8),
        ),
        Paint()
          ..color = ring!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (kind == _Kind.bar) {
      final groups = stacked ? 1 : series.length;
      final inner = band * .7, each = inner / groups;
      for (var i = 0; i < n; i++) {
        var base = 0.0;
        for (final (s, ser) in series.indexed) {
          final v = ser.values[i];
          final left = i * band + (band - inner) / 2 + (stacked ? 0 : s * each);
          final width = (stacked ? inner : each) - (stacked ? 0 : 2);
          final from = stacked ? base : 0.0, to = from + v;
          base = to;
          final rect = Rect.fromLTRB(left, y(to), left + width, y(from));
          // Only a bar's top rounds; in a stack, only the top segment's.
          final round = !stacked || s == series.length - 1;
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              rect,
              topLeft: Radius.circular(round ? 4 : 0),
              topRight: Radius.circular(round ? 4 : 0),
            ),
            Paint()..color = colors[s],
          );
        }
      }
      return;
    }

    // Lines and areas: points at the middle of each band.
    final base = List<double>.filled(n, 0);
    for (final (s, ser) in series.indexed) {
      final lows = List<double>.of(base);
      final points = [
        for (var i = 0; i < n; i++)
          Offset((i + .5) * band, y((stacked ? base[i] : 0) + ser.values[i])),
      ];
      if (stacked) {
        for (var i = 0; i < n; i++) {
          base[i] += ser.values[i];
        }
      }
      final path = _through(points);
      if (kind == _Kind.area) {
        final fill = Path.from(path);
        if (stacked && s > 0) {
          final under = [
            for (var i = n - 1; i >= 0; i--)
              Offset((i + .5) * band, y(lows[i])),
          ];
          fill.lineTo(under.first.dx, under.first.dy);
          fill.addPath(_through(under), Offset.zero);
        } else {
          fill
            ..lineTo(points.last.dx, h)
            ..lineTo(points.first.dx, h);
        }
        fill.close();
        canvas.drawPath(
          fill,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors[s].withValues(alpha: .4),
                colors[s].withValues(alpha: .05),
              ],
            ).createShader(Rect.fromLTWH(0, 0, w, h)),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors[s]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
      if (at != null) {
        canvas.drawCircle(points[at!], 4, Paint()..color = colors[s]);
      }
    }
    if (at != null) {
      final x = (at! + .5) * band;
      canvas.drawLine(Offset(x, 0), Offset(x, h), Paint()..color = grid);
    }
  }

  /// A path through [p]: straight, or a smooth curve that never overshoots a point.
  Path _through(List<Offset> p) {
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    if (!curved || p.length < 3) {
      for (final q in p.skip(1)) {
        path.lineTo(q.dx, q.dy);
      }
      return path;
    }
    // Monotone cubic: tangents from neighbouring slopes, flattened at peaks and troughs.
    final m = <double>[];
    for (var i = 0; i < p.length; i++) {
      double slope(int a, int b) => (p[b].dy - p[a].dy) / (p[b].dx - p[a].dx);
      if (i == 0) {
        m.add(slope(0, 1));
      } else if (i == p.length - 1) {
        m.add(slope(i - 1, i));
      } else {
        final a = slope(i - 1, i), b = slope(i, i + 1);
        m.add(a * b <= 0 ? 0 : (a + b) / 2);
      }
    }
    for (var i = 0; i < p.length - 1; i++) {
      final dx = (p[i + 1].dx - p[i].dx) / 3;
      path.cubicTo(
        p[i].dx + dx,
        p[i].dy + m[i] * dx,
        p[i + 1].dx - dx,
        p[i + 1].dy - m[i + 1] * dx,
        p[i + 1].dx,
        p[i + 1].dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(_CartesianPainter old) =>
      old.grow != grow ||
      old.at != at ||
      old.series != series ||
      old.colors != colors ||
      old.ring != ring ||
      old.top != top;
}

/// Slices of a whole, as a pie or, with a hole, a donut with [center] in the middle.
///
/// ```dart
/// PieChart(slices: [ChartSlice('M-Pesa', 275), ChartSlice('Card', 200), ChartSlice('Bank', 90)], center: Text('565'))
/// ```
class PieChart extends StatefulWidget {
  const PieChart({
    super.key,
    required this.slices,
    this.size = 250,
    this.donut = true,
    this.center,
    this.legend = true,
    this.format = _plain,
    this.semanticLabel,
  });

  final List<ChartSlice> slices;
  final double size;
  final bool donut, legend;
  final Widget? center;
  final String Function(double value) format;
  final String? semanticLabel;

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart>
    with SingleTickerProviderStateMixin {
  late final _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  int? _at;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _grow.value = 1;
    } else if (_grow.isDismissed) {
      _grow.forward();
    }
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final colors = [
      for (final (i, s) in widget.slices.indexed)
        s.color ?? c.charts[i % c.charts.length],
    ];
    final total = widget.slices.fold<double>(0, (a, s) => a + s.value);
    int? sliceAt(Offset p) {
      final centre = Offset(widget.size / 2, widget.size / 2), d = p - centre;
      final r = widget.size / 2;
      if (d.distance > r || (widget.donut && d.distance < r * .6)) return null;
      // Angles run clockwise from the top.
      var a = math.atan2(d.dy, d.dx) + math.pi / 2;
      if (a < 0) a += 2 * math.pi;
      var run = 0.0;
      for (final (i, s) in widget.slices.indexed) {
        run += s.value / total * 2 * math.pi;
        if (a <= run) return i;
      }
      return null;
    }

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Chart',
      value: [
        for (final s in widget.slices) '${s.label} ${widget.format(s.value)}',
      ].join(', '),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            onHover: (e) => setState(() => _at = sliceAt(e.localPosition)),
            onExit: (_) => setState(() => _at = null),
            child: GestureDetector(
              onTapDown: (d) => setState(() => _at = sliceAt(d.localPosition)),
              child: SizedBox.square(
                dimension: widget.size,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _grow,
                        builder: (context, _) => CustomPaint(
                          painter: _PiePainter(
                            values: [for (final s in widget.slices) s.value],
                            colors: colors,
                            donut: widget.donut,
                            at: _at,
                            gap: c.background,
                            sweep: Curves.easeOutCubic.transform(_grow.value),
                          ),
                        ),
                      ),
                    ),
                    if (widget.center != null && widget.donut)
                      DefaultTextStyle.merge(
                        style: t.text.xl.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.foreground,
                        ),
                        textAlign: TextAlign.center,
                        child: widget.center!,
                      ),
                    if (_at != null)
                      Positioned(
                        top: 0,
                        left: widget.size * .5,
                        child: _TooltipCard(
                          title: widget.slices[_at!].label,
                          rows: [
                            (
                              colors[_at!],
                              '${(widget.slices[_at!].value / total * 100).round()}%',
                              widget.format(widget.slices[_at!].value),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.legend) ...[
            const SizedBox(height: 12),
            _Legend(
              items: [
                for (final (i, s) in widget.slices.indexed)
                  (colors[i], s.label),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({
    required this.values,
    required this.colors,
    required this.donut,
    required this.at,
    required this.gap,
    required this.sweep,
  });

  final List<double> values;
  final List<Color> colors;
  final bool donut;
  final int? at;
  final Color gap;
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, v) => a + v);
    if (total <= 0) return;
    final r = size.shortestSide / 2;
    final centre = size.center(Offset.zero);
    var start = -math.pi / 2;
    for (final (i, v) in values.indexed) {
      final a = v / total * 2 * math.pi * sweep;
      // The slice under the pointer stands out a little.
      final grow = i == at ? 4.0 : 0.0;
      final rect = Rect.fromCircle(center: centre, radius: r - 4 + grow);
      final paint = Paint()..color = colors[i];
      if (donut) {
        final thick = r * .4;
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = thick + grow;
        canvas.drawArc(
          Rect.fromCircle(center: centre, radius: r - 4 - thick / 2 + grow / 2),
          start,
          a,
          false,
          paint,
        );
      } else {
        canvas.drawArc(rect, start, a, true, paint);
      }
      // A thin line of the page between slices.
      final edge = centre + Offset(math.cos(start), math.sin(start)) * r;
      canvas.drawLine(
        centre,
        edge,
        Paint()
          ..color = gap
          ..strokeWidth = 2,
      );
      start += a;
    }
    if (donut) {
      canvas.drawCircle(centre, r * .6 - 4, Paint()..color = gap);
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.sweep != sweep ||
      old.at != at ||
      old.values != values ||
      old.colors != colors;
}

/// The tooltip over a chart, kept inside its width.
class _Tooltip extends StatelessWidget {
  const _Tooltip({
    required this.x,
    required this.width,
    required this.title,
    required this.rows,
  });

  final double x, width;
  final String title;
  final List<(Color, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    // Right of the pointer, or left of it near the right edge.
    final right = x > width * .6;
    return Positioned(
      top: 8,
      left: right ? null : x + 12,
      right: right ? width - x + 12 : null,
      child: IgnorePointer(
        child: _TooltipCard(title: title, rows: rows),
      ),
    );
  }
}

class _TooltipCard extends StatelessWidget {
  const _TooltipCard({required this.title, required this.rows});

  final String title;
  final List<(Color, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minWidth: 128),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(t.radiusMd),
          border: Border.all(
            color: c.border.withValues(alpha: c.border.a * .5),
          ),
          boxShadow: t.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: t.text.xs.copyWith(
                fontWeight: FontWeight.w500,
                color: c.foreground,
              ),
            ),
            const SizedBox(height: 4),
            for (final (color, label, value) in rows)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: t.text.xs.copyWith(color: c.mutedForeground),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      value,
                      style: t.text.xs.copyWith(
                        color: c.foreground,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.items});

  final List<(Color, String)> items;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return ExcludeSemantics(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 4,
        children: [
          for (final (color, label) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: t.text.xs.copyWith(color: t.colors.foreground),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
