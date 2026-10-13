// On a phone, a control's press area is big enough for a finger; it looks the same.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/button_group.dart';
import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (platform, size) in [
    (TargetPlatform.android, 48.0),
    (TargetPlatform.iOS, 44.0),
    (TargetPlatform.macOS, 16.0),
  ]) {
    testWidgets('a checkbox answers a finger on ${platform.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      var ticked = false;
      await tester.pumpWidget(
        AshlarApp(
          home: Center(
            child: StatefulBuilder(
              builder: (context, set) => Checkbox(
                value: ticked,
                onChanged: (v) => set(() => ticked = v),
              ),
            ),
          ),
        ),
      );
      final area = tester.getSize(find.byType(Checkbox));
      expect(area.width, size);
      expect(area.height, size);
      // The box itself is still 16.
      final drawn = find
          .descendant(
            of: find.byType(Checkbox),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      expect(tester.getSize(drawn), const Size(16, 16));
      // A press near its edge, outside the drawn box, still ticks it on a phone.
      if (size > 16) {
        await tester.tapAt(
          tester.getCenter(find.byType(Checkbox)) + Offset(size / 2 - 3, 0),
        );
        await tester.pump();
        expect(ticked, isTrue);
      }
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('in a joined group only the height grows, so it stays joined', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(
      AshlarApp(
        home: Center(
          child: ButtonGroup(
            children: [
              for (final l in ['A', 'B'])
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.icon,
                  semanticLabel: l,
                  onPressed: () {},
                  child: Text(l),
                ),
            ],
          ),
        ),
      ),
    );
    final a = tester.getRect(find.byType(Button).first),
        b = tester.getRect(find.byType(Button).last);
    expect(a.height, 48);
    expect(b.left, a.right);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('a theme can set the size itself', (tester) async {
    await tester.pumpWidget(
      AshlarApp(
        theme: AshlarThemeData.light().copyWith(tapTarget: 0),
        home: Center(
          child: Button(onPressed: () {}, child: const Text('Save')),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Button)).height, 36);
  });
}
