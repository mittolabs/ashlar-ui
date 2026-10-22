// Ashlar UI: Radar chart. Copied into your app by `ashlar add radar-chart`; it is yours to change.
// ashlar: ignore-file. Laid out the same in any language, as charts are read.
//
// Several values for each series round a circle, joined into a shape: your rows (one an
// axis) and a Radar each, over a PolarGrid.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'chart.dart';
import 'theme.dart';

/// A radar's labels round the edge.
class PolarAngleAxis<T> extends ChartPart<T> {
  const PolarAngleAxis({this.hide = false, this.tickFormatter});

  final bool hide;

  /// Writes an axis's label from its name and row: `'$name\n${row.score}'` puts the
  /// value under it.
  final String Function(String name, T row)? tickFormatter;
}

/// A radar's scale along one spoke.
class PolarRadiusAxis<T> extends ChartPart<T> {
  const PolarRadiusAxis({
    this.angle = 90,
    this.tickCount = 4,
    this.tickFormatter,
    this.max,
  });

  /// The spoke it is written along, in degrees clockwise from the top.
  final double angle;
  final int tickCount;
  final String Function(num value)? tickFormatter;

  /// The value at the edge; null is a round number above the largest.
  final num? max;
}

/// A radar's shape: one value per row, round the circle.
class Radar<T> extends ChartPart<T> implements ChartColumn<T> {
  const Radar({
    required this.label,
    required this.value,
    this.color,
    this.icon,
    this.fill = true,
    this.opacity = .6,
    this.dots = false,
    this.dot,
    this.width = 2,
    this.dashed = false,
  });

  final String label;
  final ChartValue<T> value;
  final Color? color;
  final IconData? icon;

  /// The shape filled; false draws its outline alone.
  final bool fill;
  final double opacity;
  final bool dots;
  final ChartDot<T>? dot;
  final double width;
  final bool dashed;

  @override
  String get columnName => label;

  @override
  num? columnValue(T row) => value(row);
}

/// Several values for each series round a circle, joined into a shape: how a series
/// spreads across the axes, and how series compare. Each row is an axis.
///
/// ```dart
/// RadarChart<Score>(
///   data: scores,
///   axis: (r) => r.skill,
///   children: [
///     PolarGrid(),
///     PolarAngleAxis(),
///     ChartTooltip(),
///     Radar(label: 'This year', value: (r) => r.now),
///   ],
/// )
/// ```
class RadarChart<T> extends StatefulWidget {
  const RadarChart({
    super.key,
    required this.data,
    required this.axis,
    required this.children,
    this.size = 280,
    this.onSelect,
    this.format,
    this.semanticLabel,
  });

  final List<T> data;

  /// Each row's axis name: 'Speed', 'Range'.
  final String Function(T row) axis;
  final List<ChartPart<T>> children;
  final double size;
  final ValueChanged<ChartSelection<T>?>? onSelect;
  final String Function(num value)? format;
  final String? semanticLabel;

  @override
  State<RadarChart<T>> createState() => _RadarState<T>();
}

class _RadarState<T> extends State<RadarChart<T>>
    with TickerProviderStateMixin, ChartGrowth<RadarChart<T>> {
  int? _at;
  final _hidden = <String>{};

  String Function(num) get _format => widget.format ?? chartPlain;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final data = widget.data;
    final n = data.length;
    final radars = widget.children.whereType<Radar<T>>().toList();
    final grid = widget.children.whereType<PolarGrid<T>>().firstOrNull;
    final angleAxis = widget.children.whereType<PolarAngleAxis<T>>().firstOrNull;
    final radius = widget.children.whereType<PolarRadiusAxis<T>>().firstOrNull;
    final tooltip = widget.children.whereType<ChartTooltip<T>>().firstOrNull;
    final legend = widget.children.whereType<ChartLegend<T>>().firstOrNull;
    final colors = [
      for (final (k, p) in radars.indexed) p.color ?? c.charts[k % c.charts.length],
    ];
    final shown = [
      for (final (k, p) in radars.indexed)
        if (!_hidden.contains(p.label)) k,
    ];
    final values = [
      for (final p in radars) [for (final r in data) p.value(r)?.toDouble()],
    ];
    final biggest = [
      for (final k in shown) ...values[k].whereType<double>(),
    ].fold<double>(0, math.max);
    final ticks = chartTicks(0, biggest, count: radius?.tickCount ?? 4);
    final top = radius?.max?.toDouble() ?? ticks.last;
    const margin = 44.0;
    final r = widget.size / 2 - margin;
    final centre = Offset(widget.size / 2, widget.size / 2);
    double angle(int i) => -math.pi / 2 + i * 2 * math.pi / math.max(1, n);
    int? axisAt(Offset p) {
      final d = p - centre;
      if (d.distance > r + margin || n == 0) return null;
      var a = math.atan2(d.dy, d.dx) + math.pi / 2;
      if (a < 0) a += 2 * math.pi;
      return (a / (2 * math.pi) * n).round() % n;
    }

    final legendView = legend == null
        ? null
        : (legend.builder ?? (context, e) => ChartLegendView(entries: e))(
            context,
            [
              for (final (k, p) in radars.indexed)
                ChartLegendEntry(
                  label: p.label,
                  color: colors[k],
                  icon: p.icon,
                  shown: !_hidden.contains(p.label),
                  onToggle: legend.toggle && radars.length > 1
                      ? () => setState(() {
                          if (!_hidden.remove(p.label) &&
                              _hidden.length < radars.length - 1) {
                            _hidden.add(p.label);
                          }
                        })
                      : null,
                ),
            ],
          );
    String axisText(int i) =>
        angleAxis?.tickFormatter?.call(widget.axis(data[i]), data[i]) ??
        widget.axis(data[i]);

    Widget? tip;
    if (_at != null && tooltip != null && _at! < n) {
      final row = data[_at!];
      final name = widget.axis(row);
      final items = [
        for (final k in shown)
          if (values[k][_at!] case final v?)
            ChartTooltipItem(
              label: radars[k].label,
              value: v,
              text: tooltip.formatter?.call(v, radars[k].label, row) ?? _format(v),
              color: colors[k],
              icon: radars[k].icon,
            ),
      ];
      final d = ChartTooltipData<T>(
        title: tooltip.labelFormatter?.call(name, row) ?? name,
        items: items,
        row: row,
        index: _at,
      );
      tip = tooltip.builder?.call(context, d) ??
          ChartTooltipCard(
            title: tooltip.hideLabel ? null : d.title,
            items: items,
            indicator: tooltip.hideIndicator ? ChartIndicator.none : tooltip.indicator,
            total: tooltip.total
                ? (() {
                    final sum = items.fold<num>(0, (a, it) => a + it.value);
                    return tooltip.formatter?.call(sum, 'Total', row) ?? _format(sum);
                  })()
                : null,
          );
    }

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Chart',
      value: [
        for (var i = 0; i < n; i++)
          '${widget.axis(data[i])}: ${[
            for (final k in shown)
              if (values[k][i] != null) '${radars[k].label} ${_format(values[k][i]!)}',
          ].join(', ')}',
      ].join('; '),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (legendView != null && legend!.position == ChartLegendPosition.top) ...[
            legendView,
            const SizedBox(height: 12),
          ],
          MouseRegion(
            onHover: (e) => setState(() => _at = axisAt(e.localPosition)),
            onExit: (_) => setState(() => _at = null),
            child: GestureDetector(
              onTapDown: (d) => setState(() => _at = axisAt(d.localPosition)),
              onTapUp: (d) {
                final i = axisAt(d.localPosition);
                if (i != null) {
                  widget.onSelect?.call(ChartSelection<T>(index: i, row: data[i]));
                }
              },
              child: SizedBox.square(
                dimension: widget.size,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: grow,
                        builder: (context, _) => CustomPaint(
                          painter: _RadarPainter(
                            n: n,
                            radars: [for (final k in shown) radars[k]],
                            values: [for (final k in shown) values[k]],
                            dotColors: [
                              for (final k in shown)
                                [for (final row in data) radars[k].dot?.colorOf?.call(row)],
                            ],
                            colors: [for (final k in shown) colors[k]],
                            top: top,
                            r: r,
                            centre: centre,
                            grid: grid,
                            radius: radius,
                            ticks: [for (final v in ticks) if (v <= top) v],
                            at: _at,
                            line: c.border,
                            band: c.muted,
                            page: c.background,
                            text: t.text.xs.copyWith(color: c.mutedForeground),
                            grow: grown,
                          ),
                        ),
                      ),
                    ),
                    if (angleAxis == null || !angleAxis.hide)
                      for (var i = 0; i < n; i++)
                        _CentredLabel(
                          at: centre +
                              Offset(math.cos(angle(i)), math.sin(angle(i))) *
                                  (r + 22),
                          text: axisText(i),
                          style: t.text.xs.copyWith(
                            color: i == _at ? c.foreground : c.mutedForeground,
                            fontWeight: i == _at ? FontWeight.w500 : null,
                          ),
                        ),
                    if (tip != null)
                      Positioned(
                        top: 0,
                        left: widget.size * .6,
                        child: IgnorePointer(child: tip),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (legendView != null &&
              legend!.position == ChartLegendPosition.bottom) ...[
            const SizedBox(height: 12),
            legendView,
          ],
        ],
      ),
    );
  }
}

/// Text centred on a point, without catching the pointer; it may run to two lines.
class _CentredLabel extends StatelessWidget {
  const _CentredLabel({required this.at, required this.text, required this.style});

  final Offset at;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final lines = '\n'.allMatches(text).length + 1;
    final line = math.max(18.0, MediaQuery.textScalerOf(context).scale(16) + 2);
    return Positioned(
      left: at.dx - 60,
      top: at.dy - line * lines / 2,
      width: 120,
      height: line * lines,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Center(
            child: Text(text, style: style, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.n,
    required this.radars,
    required this.values,
    required this.dotColors,
    required this.colors,
    required this.top,
    required this.r,
    required this.centre,
    required this.grid,
    required this.radius,
    required this.ticks,
    required this.at,
    required this.line,
    required this.band,
    required this.page,
    required this.text,
    required this.grow,
  });

  final int n;
  final List<Radar<dynamic>> radars;
  final List<List<double?>> values;
  final List<List<Color?>> dotColors;
  final List<Color> colors;
  final double top, r, grow;
  final Offset centre;
  final PolarGrid<dynamic>? grid;
  final PolarRadiusAxis<dynamic>? radius;
  final List<double> ticks;
  final int? at;
  final Color line, band, page;
  final TextStyle text;

  Offset _point(int i, double d) {
    final a = -math.pi / 2 + i * 2 * math.pi / n;
    return centre + Offset(math.cos(a), math.sin(a)) * d;
  }

  Path _ring(double d, PolarGridType type) {
    if (type == PolarGridType.circle) {
      return Path()..addOval(Rect.fromCircle(center: centre, radius: d));
    }
    final p = Path()..moveTo(_point(0, d).dx, _point(0, d).dy);
    for (var i = 1; i < n; i++) {
      p.lineTo(_point(i, d).dx, _point(i, d).dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (n < 3) return;
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke;
    if (grid case final g?) {
      final radii = g.radii ?? [for (var k = 1; k <= g.rings; k++) k / g.rings];
      final sorted = [...radii]..sort((a, b) => b.compareTo(a));
      for (final (k, f) in sorted.indexed) {
        final ring = _ring(r * f, g.type);
        if (g.fill && k.isEven) {
          canvas.drawPath(ring, Paint()..color = band.withValues(alpha: .6));
          if (k + 1 < sorted.length) {
            canvas.drawPath(_ring(r * sorted[k + 1], g.type), Paint()..color = page);
          }
        }
        canvas.drawPath(g.dashed ? chartDashed(ring) : ring, stroke);
      }
      if (g.radialLines) {
        for (var i = 0; i < n; i++) {
          canvas.drawLine(
            centre,
            _point(i, r),
            i == at ? (Paint()..color = line..strokeWidth = 2) : stroke,
          );
        }
      }
    }
    for (final (s, v) in values.indexed) {
      final p = radars[s];
      final shape = Path();
      final pts = [
        for (var i = 0; i < n; i++)
          _point(i, r * ((v[i] ?? 0) / top).clamp(0, 1) * grow),
      ];
      for (final (i, q) in pts.indexed) {
        i == 0 ? shape.moveTo(q.dx, q.dy) : shape.lineTo(q.dx, q.dy);
      }
      shape.close();
      if (p.fill) {
        canvas.drawPath(shape, Paint()..color = colors[s].withValues(alpha: p.opacity));
      }
      final outline = Paint()
        ..color = colors[s]
        ..style = PaintingStyle.stroke
        ..strokeWidth = p.width
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(p.dashed ? chartDashed(shape) : shape, outline);
      if (p.dots || p.dot != null || at != null) {
        final d = p.dot ?? const ChartDot<dynamic>();
        for (final (i, q) in pts.indexed) {
          if (!(p.dots || p.dot != null) && i != at) continue;
          final color = dotColors[s][i] ?? colors[s];
          if (d.icon != null) {
            chartGlyph(canvas, d.icon!, q, d.radius * 3, color);
          } else {
            chartMark(canvas, d.shape, q, i == at ? d.radius + 1 : d.radius, Paint()..color = color);
          }
        }
      }
    }
    // The scale along one spoke.
    if (radius case final ra?) {
      final a = (ra.angle - 90) * math.pi / 180;
      final dir = Offset(math.cos(a), math.sin(a));
      for (final v in ticks) {
        if (v == 0) continue;
        chartText(
          canvas,
          ra.tickFormatter?.call(v) ?? chartNumber(v),
          centre + dir * (r * v / top) + const Offset(4, 0),
          text,
          Alignment.centerLeft,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => true;
}
