// Ranges, sizes and variants added for parity: slider, checkbox, avatar, button, switch,
// badge, tabs and toggle group.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/badge.dart';
import 'package:ashlar_ui_gallery/ui/switch.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests measure how controls look, so without the room a finger's press area
/// takes on a phone (tap_target_test.dart covers that).
Widget app(Widget child) => AshlarApp(
  theme: AshlarThemeData.light().copyWith(tapTarget: 0),
  home: Center(child: child),
);

void main() {
  testWidgets('a small switch, and ghost and link badges', (tester) async {
    await tester.pumpWidget(
      app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: true, size: SwitchSize.sm, onChanged: (_) {}),
            const Badge(variant: BadgeVariant.ghost, child: Text('Ghost')),
            const Badge(variant: BadgeVariant.link, child: Text('Link')),
          ],
        ),
      ),
    );
    expect(tester.getSize(find.byType(Switch)), const Size(24, 14));
    expect(
      tester.widget<Text>(find.text('Link')).style?.decoration ??
          DefaultTextStyle.of(tester.element(find.text('Link')))
              .style
              .decoration,
      TextDecoration.underline,
    );
  });
}
