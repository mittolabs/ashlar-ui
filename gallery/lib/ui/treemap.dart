// Ashlar UI: Treemap. Copied into your app by `ashlar add treemap`; it is yours to change.
// ashlar: ignore-file. Laid out the same in any language.
//
// Parts of a whole as rectangles, each as big as its share, grouped if you like: for
// when a pie has too many slices to read.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'chart.dart';
import 'theme.dart';

/// Parts of a whole as rectangles, as near square as they will go, each as big as its
/// value; with [group], rows of a group sit together in its colour.
///
/// ```dart
/// Treemap<Spend>(
///   data: spend,
///   value: (r) => r.amount,
///   name: (r) => r.item,
///   group: (r) => r.category,
/// )
/// ```
class Treemap<T> extends StatefulWidget {
  const Treemap({
    super.key,
    required this.data,
    required this.value,
    required this.name,
    this.group,
    this.colorOf,
    this.height = 300,
    this.gap = 2,
    this.radius = 4,
    this.labels = true,
    this.format,
    this.onSelect,
    this.semanticLabel,
  });

  final List<T> data;
  final ChartValue<T> value;
  final String Function(T row) name;

  /// A row's group: rows of a group are laid out together, in its colour.
  final String Function(T row)? group;

  /// A colour per row; null: its group's, or the theme's chart colours in turn.
  final Color? Function(T row)? colorOf;
  final double height;
  final double gap;
  final double radius;

  /// Each rectangle's name and value, where they fit.
  final bool labels;
  final String Function(num value)? format;
  final ValueChanged<ChartSelection<T>?>? onSelect;
  final String? semanticLabel;

  @override
  State<Treemap<T>> createState() => _TreemapState<T>();
}

class _TreemapState<T> extends State<Treemap<T>> {
  int? _at;

  String _write(num v) => widget.format?.call(v) ?? chartThousands(v);

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final data = widget.data;
    final values = [for (final r in data) math.max(0.0, widget.value(r)?.toDouble() ?? 0)];
    final groups = <String, List<int>>{};
    for (var i = 0; i < data.length; i++) {
      groups.putIfAbsent(widget.group?.call(data[i]) ?? '', () => []).add(i);
    }
    final groupNames = groups.keys.toList();
    Color colorOf(int i) {
      if (widget.colorOf?.call(data[i]) case final col?) return col;
      if (widget.group != null) {
        return c.charts[groupNames.indexOf(widget.group!(data[i])) % c.charts.length];
      }
      return c.charts[i % c.charts.length];
    }

    final total = values.fold<double>(0, (a, v) => a + v);
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Treemap',
      value: [
        for (var i = 0; i < data.length; i++)
          '${widget.name(data[i])} ${_write(values[i])}',
      ].join(', '),
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, box) {
            final whole = Offset.zero & Size(box.maxWidth, widget.height);
            final rects = List<Rect>.filled(data.length, Rect.zero);
            final groupRects = <String, Rect>{};
            // Groups first, then each group's rows inside it.
            final gTotals = [
              for (final g in groupNames) groups[g]!.fold<double>(0, (a, i) => a + values[i]),
            ];
            final gOrder = [for (var k = 0; k < groupNames.length; k++) k]
              ..sort((a, b) => gTotals[b].compareTo(gTotals[a]));
            final gBoxes = _squarify([for (final k in gOrder) gTotals[k]], whole);
            for (final (j, k) in gOrder.indexed) {
              final g = groupNames[k];
              final inner = widget.group == null ? gBoxes[j] : gBoxes[j].deflate(widget.gap);
              groupRects[g] = gBoxes[j];
              final rows = [...groups[g]!]..sort((a, b) => values[b].compareTo(values[a]));
              final boxes = _squarify([for (final i in rows) values[i]], inner);
              for (final (m, i) in rows.indexed) {
                rects[i] = boxes[m].deflate(widget.gap / 2);
              }
            }
            int? hit(Offset p) {
              for (var i = 0; i < rects.length; i++) {
                if (rects[i].contains(p)) return i;
              }
              return null;
            }

            return MouseRegion(
              onHover: (e) => setState(() => _at = hit(e.localPosition)),
              onExit: (_) => setState(() => _at = null),
              child: GestureDetector(
                onTapDown: (d) => setState(() => _at = hit(d.localPosition)),
                onTapUp: (d) {
                  final i = hit(d.localPosition);
                  if (i != null) widget.onSelect?.call(ChartSelection<T>(index: i, row: data[i]));
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TreemapPainter(
                          rects: rects,
                          colors: [for (var i = 0; i < data.length; i++) colorOf(i)],
                          names: widget.labels ? [for (final r in data) widget.name(r)] : null,
                          values: [for (final v in values) _write(v)],
                          radius: widget.radius,
                          at: _at,
                          name: t.text.xs.copyWith(color: c.background, fontWeight: FontWeight.w600),
                          value: t.text.xs.copyWith(color: c.background.withValues(alpha: .85)),
                        ),
                      ),
                    ),
                    if (_at != null)
                      Positioned(
                        left: math.min(rects[_at!].left + 8, box.maxWidth - 150),
                        top: math.min(rects[_at!].top + 8, widget.height - 64),
                        child: IgnorePointer(
                          child: ChartTooltipCard(
                            title: [
                              if (widget.group != null) widget.group!(data[_at!]),
                              widget.name(data[_at!]),
                            ].join(' · '),
                            items: [
                              ChartTooltipItem(
                                label: total == 0 ? '' : '${(values[_at!] / total * 100).toStringAsFixed(1)}%',
                                value: values[_at!],
                                text: _write(values[_at!]),
                                color: colorOf(_at!),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Splits [box] into rectangles with the areas of [values] (largest first), keeping each
/// as near square as it can: the squarified treemap.
List<Rect> _squarify(List<double> values, Rect box) {
  final total = values.fold<double>(0, (a, v) => a + v);
  if (values.isEmpty || total <= 0 || box.isEmpty) {
    return [for (final _ in values) Rect.fromLTWH(box.left, box.top, 0, 0)];
  }
  final scale = box.width * box.height / total;
  final areas = [for (final v in values) v * scale];
  final out = <Rect>[];
  var rest = box;
  var i = 0;
  double worst(List<double> row, double side) {
    final s = row.fold<double>(0, (a, v) => a + v);
    if (s == 0) return double.infinity;
    final mx = row.reduce(math.max), mn = row.reduce(math.min);
    return math.max(side * side * mx / (s * s), (s * s) / (side * side * math.max(mn, 1e-9)));
  }

  while (i < areas.length) {
    final side = math.min(rest.width, rest.height);
    final row = <double>[areas[i]];
    var j = i + 1;
    while (j < areas.length && worst([...row, areas[j]], side) <= worst(row, side)) {
      row.add(areas[j]);
      j++;
    }
    final s = row.fold<double>(0, (a, v) => a + v);
    if (rest.width >= rest.height) {
      // A column down the left.
      final w = rest.height == 0 ? 0.0 : s / rest.height;
      var y = rest.top;
      for (final a in row) {
        final h = w == 0 ? 0.0 : a / w;
        out.add(Rect.fromLTWH(rest.left, y, w, h));
        y += h;
      }
      rest = Rect.fromLTRB(rest.left + w, rest.top, rest.right, rest.bottom);
    } else {
      // A row along the top.
      final h = rest.width == 0 ? 0.0 : s / rest.width;
      var x = rest.left;
      for (final a in row) {
        final w = h == 0 ? 0.0 : a / h;
        out.add(Rect.fromLTWH(x, rest.top, w, h));
        x += w;
      }
      rest = Rect.fromLTRB(rest.left, rest.top + h, rest.right, rest.bottom);
    }
    i = j;
  }
  return out;
}

class _TreemapPainter extends CustomPainter {
  _TreemapPainter({
    required this.rects,
    required this.colors,
    required this.names,
    required this.values,
    required this.radius,
    required this.at,
    required this.name,
    required this.value,
  });

  final List<Rect> rects;
  final List<Color> colors;
  final List<String>? names;
  final List<String> values;
  final double radius;
  final int? at;
  final TextStyle name, value;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (i, r) in rects.indexed) {
      if (r.width <= 0 || r.height <= 0) continue;
      final c = colors[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(radius)),
        Paint()..color = at == null || at == i ? c : c.withValues(alpha: c.a * .7),
      );
      if (names == null || r.width < 48 || r.height < 34) continue;
      canvas.save();
      canvas.clipRect(r.deflate(4));
      final n = TextPainter(
        text: TextSpan(text: names![i], style: name),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: r.width - 12);
      n.paint(canvas, r.topLeft + const Offset(6, 5));
      final v = TextPainter(
        text: TextSpan(text: values[i], style: value),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: r.width - 12);
      v.paint(canvas, r.topLeft + Offset(6, 6 + n.height));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_TreemapPainter old) => true;
}
