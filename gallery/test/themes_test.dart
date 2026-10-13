// Themes: seven bases, seventeen accents and six styles, each readable and each felt by the
// components.
import 'dart:math' as math;

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/palette.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast between two opaque colours.
double contrast(Color a, Color b) {
  double lum(Color c) {
    double ch(double v) =>
        v <= .04045 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
    return .2126 * ch(c.r) + .7152 * ch(c.g) + .0722 * ch(c.b);
  }

  final (x, y) = (lum(a), lum(b));
  return (math.max(x, y) + .05) / (math.min(x, y) + .05);
}

void main() {
  test('neutral is the theme as it was', () {
    expect(
      ashlarColors(AshlarBase.neutral, Brightness.light),
      AshlarColors.light,
    );
    expect(
      ashlarColors(AshlarBase.neutral, Brightness.dark),
      AshlarColors.dark,
    );
  });

  for (final brightness in Brightness.values) {
    for (final base in AshlarBase.values) {
      test('${base.name}, ${brightness.name}: text reads on every surface', () {
        final c = ashlarColors(base, brightness);
        expect(contrast(c.foreground, c.background), greaterThan(7));
        // Muted text on the page and on muted surfaces: 4.5 to 1, as small text needs.
        expect(
          contrast(c.mutedForeground, c.background),
          greaterThanOrEqualTo(4.5),
        );
        expect(contrast(c.mutedForeground, c.muted), greaterThanOrEqualTo(4.5));
        expect(contrast(c.primaryForeground, c.primary), greaterThan(4.5));
        expect(contrast(c.cardForeground, c.card), greaterThan(7));
      });
    }
    for (final accent in AshlarAccent.values) {
      test('${accent.name}, ${brightness.name}: a primary button reads', () {
        final c = ashlarColors(AshlarBase.zinc, brightness, accent);
        expect(
          c.primary,
          isNot(ashlarColors(AshlarBase.zinc, brightness).primary),
        );
        // A button's 14px label is small text: 4.5 to 1. The sidebar's mark too.
        expect(
          contrast(c.primaryForeground, c.primary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(c.sidebarPrimaryForeground, c.sidebarPrimary),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  }

  testWidgets('styles change the size of controls and the room in panels', (
    tester,
  ) async {
    Future<(double, double)> measure(AshlarStyle style) async {
      await tester.pumpWidget(
        AshlarApp(
          theme: AshlarThemeData.from(style: style),
          home: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(onPressed: () {}, child: const Text('Save')),
                const SizedBox(
                  width: 300,
                  child: Card(children: [CardContent(child: Text('Body'))]),
                ),
              ],
            ),
          ),
        ),
      );
      final card = tester.getRect(find.byType(Card));
      final body = tester.getRect(find.text('Body'));
      return (tester.getSize(find.byType(Button)).height, body.top - card.top);
    }

    final standard = await measure(AshlarStyle.standard);
    final compact = await measure(AshlarStyle.compact);
    final rounded = await measure(AshlarStyle.rounded);
    expect(standard.$1, 36);
    expect(compact.$1, 32);
    expect(rounded.$1, 40);
    expect(compact.$2, lessThan(standard.$2));
    expect(rounded.$2, greaterThan(standard.$2));
  });

  test('a sharp style casts no shadows and has square corners', () {
    final t = AshlarThemeData.from(style: AshlarStyle.sharp);
    expect(t.shadowSm, isEmpty);
    expect(t.shadowLg, isEmpty);
    expect(t.radiusMd, 0);
    expect(AshlarThemeData.from().shadowSm, isNotEmpty);
  });
}
