// Right-to-left: every check runs in both reading directions. What starts a line sits
// on the left in one and the right in the other, and arrow keys follow what they see.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/button_group.dart';
import 'package:ashlar_ui_gallery/ui/dialog.dart';
import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';
import 'package:ashlar_ui_gallery/ui/popover.dart';
import 'package:ashlar_ui_gallery/ui/resizable.dart';
import 'package:ashlar_ui_gallery/ui/slider.dart';
import 'package:ashlar_ui_gallery/ui/switch.dart';
import 'package:ashlar_ui_gallery/ui/tabs.dart';
import 'package:ashlar_ui_gallery/ui/toggle_group.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, TextDirection direction) => AshlarApp(
  builder: (context, page) =>
      Directionality(textDirection: direction, child: page!),
  home: Center(child: child),
);

void main() {
  for (final direction in TextDirection.values) {
    final rtl = direction == TextDirection.rtl;
    // The arrow that points along the line, towards its end.
    final forward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final back = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;

    group(direction.name, () {
      testWidgets(
        'Slider fills from the start, and the forward arrow raises it',
        (tester) async {
          var value = .5;
          await tester.pumpWidget(
            app(
              SizedBox(
                width: 216,
                child: StatefulBuilder(
                  builder: (context, set) => Slider(
                    value: value,
                    step: .1,
                    semanticLabel: 'Volume',
                    onChanged: (v) => set(() => value = v),
                  ),
                ),
              ),
              direction,
            ),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.sendKeyEvent(forward);
          await tester.pump();
          expect(value, closeTo(.6, .001));
          await tester.sendKeyEvent(back);
          await tester.pump();
          await tester.sendKeyEvent(back);
          await tester.pump();
          expect(value, closeTo(.4, .001));
          final box = tester.getRect(find.byType(Slider));
          // A tap near the right-hand end.
          await tester.tapAt(Offset(box.right - 10, box.center.dy));
          await tester.pump();
          expect(value, rtl ? closeTo(0, .01) : closeTo(1, .01));
        },
      );

      testWidgets('Tabs run from the start, and the forward arrow moves on', (
        tester,
      ) async {
        await tester.pumpWidget(
          app(
            const Tabs(
              tabs: [
                TabItem(label: Text('One'), content: Text('First')),
                TabItem(label: Text('Two'), content: Text('Second')),
              ],
            ),
            direction,
          ),
        );
        final one = tester.getCenter(find.text('One')).dx,
            two = tester.getCenter(find.text('Two')).dx;
        expect(rtl ? one > two : one < two, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(forward);
        await tester.pumpAndSettle();
        expect(find.text('Second'), findsOneWidget);
        await tester.sendKeyEvent(back);
        await tester.pumpAndSettle();
        expect(find.text('First'), findsOneWidget);
      });

      testWidgets('Toggle Group moves focus with the forward arrow', (
        tester,
      ) async {
        await tester.pumpWidget(
          app(
            ToggleGroup<int>(
              values: const {},
              onChanged: (_) {},
              items: const [
                ToggleGroupItem(1, Text('A')),
                ToggleGroupItem(2, Text('B')),
              ],
            ),
            direction,
          ),
        );
        final a = tester.getCenter(find.text('A')).dx,
            b = tester.getCenter(find.text('B')).dx;
        expect(rtl ? a > b : a < b, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(forward);
        await tester.pump();
        final focused = FocusManager.instance.primaryFocus!.context!;
        expect(
          find
              .descendant(
                of: find.byWidget(focused.widget),
                matching: find.text('B'),
              )
              .evaluate()
              .isNotEmpty,
          isTrue,
        );
      });

      testWidgets('Button Group rounds the outer corners on its own sides', (
        tester,
      ) async {
        await tester.pumpWidget(
          app(
            ButtonGroup(
              children: [
                for (final l in ['A', 'B'])
                  Button(
                    variant: ButtonVariant.outline,
                    onPressed: () {},
                    child: Text(l),
                  ),
              ],
            ),
            direction,
          ),
        );
        expect(tester.takeException(), isNull);
        BoxDecoration deco(String label) =>
            tester
                    .widget<AnimatedContainer>(
                      find
                          .ancestor(
                            of: find.text(label),
                            matching: find.byType(AnimatedContainer),
                          )
                          .first,
                    )
                    .decoration!
                as BoxDecoration;
        final first = deco('A').borderRadius!.resolve(direction);
        // The first button is at the start: its outer corners are round.
        expect((rtl ? first.topRight : first.topLeft).x, greaterThan(0));
        expect(rtl ? first.topLeft : first.topRight, Radius.zero);
        // The second has no edge where it meets the first.
        final second = deco('B').border! as Border;
        expect(rtl ? second.right : second.left, BorderSide.none);
        expect(rtl ? second.left : second.right, isNot(BorderSide.none));
      });

      testWidgets('a submenu opens towards the end of the line', (
        tester,
      ) async {
        await tester.pumpWidget(
          app(
            DropdownMenu(
              builder: (context, m) =>
                  Button(onPressed: m.open, child: const Text('Open')),
              items: [
                MenuSub(
                  items: [
                    MenuItem(onPressed: () {}, child: const Text('Email')),
                  ],
                  child: const Text('Share'),
                ),
              ],
            ),
            direction,
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(forward);
        await tester.pumpAndSettle();
        expect(find.text('Email'), findsOneWidget);
        final email = tester.getRect(find.text('Email')),
            share = tester.getRect(find.text('Share'));
        expect(
          rtl ? email.right < share.left : email.left > share.right,
          isTrue,
        );
        await tester.sendKeyEvent(back);
        await tester.pumpAndSettle();
        expect(find.text('Email'), findsNothing);
      });

      testWidgets('a submenu also opens on hover, on the same side', (
        tester,
      ) async {
        await tester.pumpWidget(
          app(
            DropdownMenu(
              builder: (context, m) =>
                  Button(onPressed: m.open, child: const Text('Open')),
              items: [
                MenuSub(
                  items: [
                    MenuItem(onPressed: () {}, child: const Text('Email')),
                  ],
                  child: const Text('Share'),
                ),
              ],
            ),
            direction,
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.text('Share')));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        final email = tester.getCenter(find.text('Email')).dx,
            share = tester.getCenter(find.text('Share')).dx;
        expect(rtl ? email < share : email > share, isTrue);
      });

      testWidgets(
        'a popover aligned to the start lines up with its start edge',
        (tester) async {
          await tester.pumpWidget(
            app(
              Popover(
                align: PopoverAlign.start,
                builder: (context, menu) => Button(
                  onPressed: menu.open,
                  child: const SizedBox(width: 160, child: Text('Dimensions')),
                ),
                content: (context) =>
                    const SizedBox(width: 60, child: Text('Width')),
              ),
              direction,
            ),
          );
          await tester.tap(find.text('Dimensions'));
          await tester.pumpAndSettle();
          final anchor = tester.getRect(find.byType(Button));
          final panel = tester.getRect(
            find
                .ancestor(
                  of: find.text('Width'),
                  matching: find.byType(Container),
                )
                .last,
          );
          if (rtl) {
            expect(panel.right, closeTo(anchor.right, 1));
          } else {
            expect(panel.left, closeTo(anchor.left, 1));
          }
        },
      );

      testWidgets(
        'Resizable: the forward arrow and a drag to the end grow the first panel',
        (tester) async {
          var shares = <double>[];
          await tester.pumpWidget(
            app(
              SizedBox(
                width: 401,
                height: 200,
                child: Resizable(
                  onResize: (s) => shares = s,
                  panels: const [
                    ResizablePanel(child: Text('First')),
                    ResizablePanel(child: Text('Second')),
                  ],
                ),
              ),
              direction,
            ),
          );
          final first = tester.getCenter(find.text('First')).dx,
              second = tester.getCenter(find.text('Second')).dx;
          expect(rtl ? first > second : first < second, isTrue);
          await tester.dragFrom(
            tester.getCenter(find.bySemanticsLabel('Resize')),
            Offset(rtl ? -100 : 100, 0),
          );
          await tester.pump();
          expect(shares.first, greaterThan(.6));
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          final before = shares.first;
          await tester.sendKeyEvent(back);
          await tester.pump();
          expect(shares.first, lessThan(before));
        },
      );

      testWidgets('Switch puts its thumb at the end when on', (tester) async {
        await tester.pumpWidget(
          app(Switch(value: true, onChanged: (_) {}), direction),
        );
        await tester.pumpAndSettle();
        final track = tester.getRect(find.byType(Switch));
        final knob = tester.getRect(
          find
              .descendant(
                of: find.byType(AnimatedAlign),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(
          rtl
              ? knob.center.dx < track.center.dx
              : knob.center.dx > track.center.dx,
          isTrue,
        );
      });

      testWidgets('Dialog puts its close button at the end', (tester) async {
        await tester.pumpWidget(
          app(
            Builder(
              builder: (context) => Button(
                onPressed: () => showAshlarDialog(
                  context: context,
                  builder: (_) => const Dialog(title: Text('Hi')),
                ),
                child: const Text('Open'),
              ),
            ),
            direction,
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final close = tester.getCenter(find.bySemanticsLabel('Close').last).dx,
            title = tester.getCenter(find.text('Hi')).dx;
        expect(rtl ? close < title : close > title, isTrue);
      });
    });
  }
}
