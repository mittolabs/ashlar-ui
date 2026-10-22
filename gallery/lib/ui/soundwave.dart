// Ashlar UI: Soundwave. Copied into your app by `ashlar add soundwave`; it is yours to change.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// How loud something is, as a row of rounded bars: a person speaking to an assistant, or
/// a voice note. Give it [levels] from 0 (silence) to 1, newest last, as your audio gives
/// them; it draws as many of the newest as fit, and a row of dots when there are none.
/// Listening to the microphone needs a plugin, so that part is your app's.
///
/// ```dart
/// Soundwave(levels: recorder.levels, semanticLabel: 'Listening')
/// ```
class Soundwave extends StatelessWidget {
  const Soundwave({
    super.key,
    required this.levels,
    this.height = 32,
    this.barWidth = 3,
    this.gap = 2,
    this.color,
    this.semanticLabel,
  });

  /// From 0 to 1, oldest first.
  final List<double> levels;
  final double height, barWidth, gap;

  /// The bars' colour; the foreground when not given.
  final Color? color;

  /// What a screen reader hears: "Listening", "Voice note, 12 seconds".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = AshlarTheme.of(context).colors;
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _Bars(
            levels: levels,
            barWidth: barWidth,
            gap: gap,
            color: color ?? c.foreground,
            quiet: c.mutedForeground.withValues(alpha: .5),
            rtl: Directionality.of(context) == TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}

class _Bars extends CustomPainter {
  _Bars({
    required this.levels,
    required this.barWidth,
    required this.gap,
    required this.color,
    required this.quiet,
    required this.rtl,
  });

  final List<double> levels;
  final double barWidth, gap;
  final Color color, quiet;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final step = barWidth + gap;
    final fit = math.max(1, ((size.width + gap) / step).floor());
    final shown = levels.length > fit
        ? levels.sublist(levels.length - fit)
        : levels;
    final mid = size.height / 2;
    final paint = Paint();
    // The newest bar at the end the text reads to; the bars before it towards the start.
    for (var i = 0; i < fit; i++) {
      final k = i - (fit - shown.length);
      final level = k < 0 ? 0.0 : shown[k].clamp(0.0, 1.0);
      final h = math.max(barWidth, level * size.height);
      final x = rtl ? size.width - (i + 1) * step + gap : i * step;
      paint.color = k < 0 || level == 0 ? quiet : color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, mid - h / 2, barWidth, h),
          Radius.circular(barWidth / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_Bars old) =>
      old.levels != levels ||
      old.color != color ||
      old.quiet != quiet ||
      old.barWidth != barWidth ||
      old.gap != gap ||
      old.rtl != rtl;
}
