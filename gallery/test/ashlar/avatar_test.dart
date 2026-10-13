// Tests for Avatar. Copied into your app by `ashlar add avatar` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/avatar.dart';
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
  testWidgets('an avatar group overlaps, counts the rest, and is read as one', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const AvatarGroup(
          max: 2,
          children: [
            Avatar(fallback: 'WM', semanticLabel: 'Wanjiru'),
            Avatar(fallback: 'OK', semanticLabel: 'Otieno'),
            Avatar(fallback: 'AN', semanticLabel: 'Achieng'),
            Avatar(fallback: 'KM', semanticLabel: 'Kamau', badge: AvatarDot()),
          ],
        ),
      ),
    );
    expect(find.text('+2'), findsOneWidget);
    expect(find.text('AN'), findsNothing);
    expect(
      tester.getRect(find.text('OK')).left,
      lessThan(tester.getRect(find.text('WM')).right + 4),
    );
    expect(
      find.bySemanticsLabel('Wanjiru, Otieno, Achieng, Kamau'),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
