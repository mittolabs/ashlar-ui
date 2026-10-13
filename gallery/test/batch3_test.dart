// The third batch, as an app gets it from lib/ui.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/button_group.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: child),
    );

BoxDecoration box(WidgetTester tester, Finder of) =>
    tester
            .widget<AnimatedContainer>(
              find
                  .descendant(of: of, matching: find.byType(AnimatedContainer))
                  .first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  group('Button Group', () {
    testWidgets(
      'only the outer corners are round, and neighbours share one border',
      (tester) async {
        await tester.pumpWidget(
          app(
            ButtonGroup(
              children: [
                for (final l in ['A', 'B', 'C'])
                  Button(
                    variant: ButtonVariant.outline,
                    onPressed: () {},
                    child: Text(l),
                  ),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final buttons = find.byType(Button);
        final first = box(tester, buttons.at(0)),
            middle = box(tester, buttons.at(1)),
            last = box(tester, buttons.at(2));
        final r = first.borderRadius!.resolve(TextDirection.ltr);
        expect(r.topLeft.x, greaterThan(0));
        expect(r.topRight, Radius.zero);
        expect(
          middle.borderRadius!.resolve(TextDirection.ltr),
          BorderRadius.zero,
        );
        expect(
          last.borderRadius!.resolve(TextDirection.ltr).topRight.x,
          greaterThan(0),
        );
        expect((middle.border! as Border).left, BorderSide.none);
        expect((first.border! as Border).left, isNot(BorderSide.none));
        // Touching: one piece.
        expect(
          tester.getTopLeft(buttons.at(1)).dx,
          tester.getTopRight(buttons.at(0)).dx,
        );
      },
    );

    testWidgets('a button on its own is round all over', (tester) async {
      await tester.pumpWidget(
        app(
          Button(
            variant: ButtonVariant.outline,
            onPressed: () {},
            child: const Text('A'),
          ),
        ),
      );
      final d = box(tester, find.byType(Button));
      expect(
        d.borderRadius,
        isA<BorderRadius>().having(
          (r) => r.topRight.x,
          'topRight',
          greaterThan(0),
        ),
      );
    });
  });
}
