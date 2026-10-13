// The second batch: forms, overlays and feedback, as an app gets them from lib/ui.
import 'package:ashlar_ui_gallery/ui/alert.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/avatar.dart';
import 'package:ashlar_ui_gallery/ui/kbd.dart';
import 'package:ashlar_ui_gallery/ui/skeleton.dart';
import 'package:ashlar_ui_gallery/ui/spinner.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: child),
    );

void main() {
  testWidgets(
    'the display pieces lay out in light and dark, and leave the timers clean',
    (tester) async {
      for (final mode in AshlarThemeMode.values) {
        await tester.pumpWidget(
          app(
            const SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Alert(
                    title: Text('Heads up'),
                    description: Text('Something to know.'),
                  ),
                  Alert(
                    variant: AlertVariant.destructive,
                    title: Text('Declined'),
                  ),
                  Avatar(fallback: 'WM', semanticLabel: 'Wanjiru Mwangi'),
                  Skeleton(width: 120),
                  Spinner(),
                  Kbd(child: Text('Esc')),
                ],
              ),
            ),
            mode: mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'a spinner and an avatar are named for screen readers; a skeleton is not read',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Spinner(),
              Avatar(fallback: 'WM', semanticLabel: 'Wanjiru Mwangi'),
              Skeleton(width: 40),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      expect(find.bySemanticsLabel('Wanjiru Mwangi'), findsOneWidget);
      expect(find.bySemanticsLabel('WM'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );
}
