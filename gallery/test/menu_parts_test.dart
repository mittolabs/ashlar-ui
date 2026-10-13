// Menu parts: checkbox and radio items, insets and submenus; and panels on all four sides.
import 'dart:ui' show CheckedState, SemanticsRole;

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';
import 'package:ashlar_ui_gallery/ui/popover.dart';
import 'package:ashlar_ui_gallery/ui/tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

Finder panel() => find
    .descendant(of: find.byType(PopoverPanel), matching: find.byType(TapRegion))
    .first;

void main() {
  group('Menu items', () {
    Future<Map<String, Object?>> menu(WidgetTester tester) async {
      final state = <String, Object?>{
        'bar': true,
        'pos': 'top',
        'picked': null,
      };
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => DropdownMenu(
              builder: (context, m) =>
                  Button(onPressed: m.open, child: const Text('Open')),
              items: [
                const MenuLabel(inset: true, child: Text('View')),
                MenuCheckboxItem(
                  checked: state['bar']! as bool,
                  onChanged: (v) => set(() => state['bar'] = v),
                  child: const Text('Status bar'),
                ),
                const MenuSeparator(),
                MenuRadioGroup<String>(
                  value: state['pos'] as String?,
                  onChanged: (v) => set(() => state['pos'] = v),
                  children: const [
                    MenuRadioItem(value: 'top', child: Text('Top')),
                    MenuRadioItem(value: 'bottom', child: Text('Bottom')),
                  ],
                ),
                MenuItem(
                  inset: true,
                  onPressed: () => set(() => state['picked'] = 'plain'),
                  child: const Text('Plain'),
                ),
                MenuSub(
                  items: [
                    MenuItem(
                      onPressed: () => set(() => state['picked'] = 'email'),
                      child: const Text('Email'),
                    ),
                    MenuItem(
                      onPressed: () => set(() => state['picked'] = 'link'),
                      child: const Text('Copy link'),
                    ),
                  ],
                  child: const Text('Share'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      return state;
    }

    testWidgets(
      'a checkbox item flips, says whether it is checked, and closes the menu',
      (tester) async {
        final semantics = tester.ensureSemantics();
        final state = await menu(tester);
        final node = tester
            .getSemantics(find.text('Status bar'))
            .getSemanticsData();
        expect(node.flagsCollection.isChecked, CheckedState.isTrue);
        expect(node.role, SemanticsRole.menuItemCheckbox);
        await tester.tap(find.text('Status bar'));
        await tester.pumpAndSettle();
        expect(state['bar'], isFalse);
        expect(find.text('Status bar'), findsNothing);
        semantics.dispose();
      },
    );

    testWidgets(
      'a radio item picks one, and the inset lines labels up with them',
      (tester) async {
        final state = await menu(tester);
        expect(
          tester.getTopLeft(find.text('View')).dx,
          tester.getTopLeft(find.text('Top')).dx,
        );
        expect(
          tester.getTopLeft(find.text('Plain')).dx,
          tester.getTopLeft(find.text('Top')).dx,
        );
        await tester.tap(find.text('Bottom'));
        await tester.pumpAndSettle();
        expect(state['pos'], 'bottom');
      },
    );

    testWidgets(
      'a submenu opens on hover beside its row; picking in it closes everything',
      (tester) async {
        final state = await menu(tester);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.text('Share')));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        expect(find.text('Email'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Email')).dx,
          greaterThan(tester.getTopRight(find.text('Share')).dx),
        );
        // Moving to another row of the first menu closes it.
        await mouse.moveTo(tester.getCenter(find.text('Plain')));
        await tester.pumpAndSettle();
        expect(find.text('Email'), findsNothing);
        await mouse.moveTo(tester.getCenter(find.text('Share')));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Copy link'));
        await tester.pumpAndSettle();
        expect(state['picked'], 'link');
        expect(find.text('Share'), findsNothing);
      },
    );

    testWidgets(
      'from the keyboard: right opens the submenu on its first item, left comes back',
      (tester) async {
        final state = await menu(tester);
        // Down to Share: the checkbox, two radios, Plain, Share.
        for (var i = 0; i < 5; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(find.text('Email'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        expect(find.text('Email'), findsNothing);
        expect(find.text('Share'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(state['picked'], 'email');
      },
    );
  });

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
