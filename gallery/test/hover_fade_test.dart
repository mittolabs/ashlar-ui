// A hover's tint fades out to its own colour made clear, never to clear black: halfway
// from a light grey to clear black is a darker grey, a flash on every pointer that leaves.
import 'dart:io';

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:ashlar_ui_gallery/ui/toggle.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

double luminance(Color c) => c.computeLuminance();

void main() {
  testWidgets('a toggle left by the pointer never goes darker than its hover', (
    tester,
  ) async {
    await tester.pumpWidget(
      AshlarApp(
        theme: AshlarThemeData.light().copyWith(tapTarget: 0),
        home: Center(
          child: Toggle(
            pressed: false,
            onChanged: (_) {},
            child: const Text('Starred'),
          ),
        ),
      ),
    );
    final page = AshlarThemeData.light().colors.background;
    final hover = AshlarThemeData.light().colors.muted;
    Color shown() {
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(Toggle),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return Color.alphaBlend((box.decoration as BoxDecoration).color!, page);
    }

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(Toggle)));
    await tester.pumpAndSettle();
    await mouse.moveTo(Offset.zero);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 15));
      expect(luminance(shown()), greaterThanOrEqualTo(luminance(hover) - .001));
    }
  });

  test('no component fades a colour to clear black', () {
    final fades = RegExp(r'\?\s*[\w.()*, :]+?\s*:\s*const Color\(0x00000000\)');
    final found = [
      for (final f in Directory('lib/ui').listSync().whereType<File>())
        for (final m in fades.allMatches(f.readAsStringSync()))
          '${f.path}: ${m[0]!.replaceAll(RegExp(r'\s+'), ' ')}',
    ];
    expect(found, isEmpty);
  });
}
