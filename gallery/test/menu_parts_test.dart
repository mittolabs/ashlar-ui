// Menu parts: checkbox and radio items, insets and submenus; and panels on all four sides.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/popover.dart';
import 'package:ashlar_ui_gallery/ui/tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

Finder panel() => find
    .descendant(of: find.byType(PopoverPanel), matching: find.byType(TapRegion))
    .first;

void main() {
  group('Four sides', () {
    testWidgets('a popover opens left or right of its trigger', (tester) async {
      for (final side in [PopoverSide.left, PopoverSide.right]) {
        await tester.pumpWidget(
          app(
            Popover(
              side: side,
              width: 160,
              builder: (context, m) =>
                  Button(onPressed: m.open, child: const Text('Open')),
              content: (context) => const Text('Panel'),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final trigger = tester.getRect(find.byType(Button)),
            p = tester.getRect(panel());
        if (side == PopoverSide.right) {
          expect(p.left, greaterThanOrEqualTo(trigger.right));
        } else {
          expect(p.right, lessThanOrEqualTo(trigger.left));
        }
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
      }
    });

    testWidgets(
      'a tooltip shows on each side, and flips where there is no room',
      (tester) async {
        for (final (side, check)
            in <(TooltipSide, bool Function(Rect tip, Rect target))>[
              (TooltipSide.top, (tip, target) => tip.bottom <= target.top),
              (TooltipSide.bottom, (tip, target) => tip.top >= target.bottom),
              (TooltipSide.left, (tip, target) => tip.right <= target.left),
              (TooltipSide.right, (tip, target) => tip.left >= target.right),
            ]) {
          await tester.pumpWidget(
            app(
              Tooltip(
                message: 'Tip',
                side: side,
                child: Button(onPressed: () {}, child: const Text('Go')),
              ),
            ),
          );
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(tester.getCenter(find.text('Go')));
          await tester.pumpAndSettle();
          expect(
            check(
              tester.getRect(find.text('Tip')),
              tester.getRect(find.byType(Button)),
            ),
            isTrue,
            reason: '$side',
          );
          await mouse.removePointer();
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        }
        // At the left edge there is no room on the left: it goes right.
        await tester.pumpWidget(
          AshlarApp(
            home: Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: 'Tip',
                side: TooltipSide.left,
                child: Button(onPressed: () {}, child: const Text('Go')),
              ),
            ),
          ),
        );
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.text('Go')));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.text('Tip')).left,
          greaterThanOrEqualTo(tester.getRect(find.byType(Button)).right),
        );
      },
    );
  });
}
