// Every theme Ashlar offers keeps text readable and the focus ring visible: WCAG AA, 4.5:1
// for text and 3:1 for the ring. Field borders are left out: like shadcn's, ours are
// 1.2 to 1.5:1, a choice of look that ashlar check reports.
import 'dart:math' as math;

import 'package:ashlar_ui_gallery/ui/palette.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

double lum(Color c) {
  double ch(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

Color over(Color top, Color bottom) =>
    Color.alphaBlend(top, bottom.withValues(alpha: 1));
double ratio(Color fg, Color bg) {
  final a = lum(over(fg, bg)), b = lum(bg.withValues(alpha: 1));
  return (math.max(a, b) + .05) / (math.min(a, b) + .05);
}

void main() {
  for (final base in AshlarBase.values) {
    test('every ${base.name} theme reads at AA', () {
      final failing = <String>[];
      for (final accent in <AshlarAccent?>[null, ...AshlarAccent.values]) {
        for (final b in Brightness.values) {
          final c = AshlarThemeData.from(
            brightness: b,
            base: base,
            accent: accent,
          ).colors;
          final pairs = {
            'foreground on background': (c.foreground, c.background, 4.5),
            'muted text on background': (c.mutedForeground, c.background, 4.5),
            'muted text on muted': (c.mutedForeground, c.muted, 4.5),
            'card text': (c.cardForeground, c.card, 4.5),
            'popover text': (c.popoverForeground, c.popover, 4.5),
            'primary button text': (c.primaryForeground, c.primary, 4.5),
            'secondary button text': (c.secondaryForeground, c.secondary, 4.5),
            'accent text': (c.accentForeground, c.accent, 4.5),
            'destructive button text': (
              c.destructiveForeground,
              c.destructive,
              4.5,
            ),
            'error text on background': (c.destructive, c.background, 4.5),
            'sidebar text': (c.sidebarForeground, c.sidebar, 4.5),
            'sidebar primary text': (
              c.sidebarPrimaryForeground,
              c.sidebarPrimary,
              4.5,
            ),
            'focus ring on background': (c.ring, c.background, 3.0),
          };
          for (final MapEntry(key: what, value: (fg, bg, need))
              in pairs.entries) {
            final r = ratio(fg, bg);
            if (r < need) {
              failing.add(
                '${accent?.name ?? 'no accent'}, ${b.name}: $what ${r.toStringAsFixed(2)}',
              );
            }
          }
        }
      }
      expect(failing, isEmpty);
    });
  }
}
