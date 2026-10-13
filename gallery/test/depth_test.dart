// Ranges, sizes and variants added for parity: slider, checkbox, avatar, button, switch,
// badge, tabs and toggle group.
import 'dart:ui' show CheckedState;

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/avatar.dart';
import 'package:ashlar_ui_gallery/ui/badge.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/slider.dart';
import 'package:ashlar_ui_gallery/ui/switch.dart';
import 'package:ashlar_ui_gallery/ui/tabs.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:ashlar_ui_gallery/ui/toggle.dart';
import 'package:ashlar_ui_gallery/ui/toggle_group.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests measure how controls look, so without the room a finger's press area
/// takes on a phone (tap_target_test.dart covers that).
Widget app(Widget child) => AshlarApp(
  theme: AshlarThemeData.light().copyWith(tapTarget: 0),
  home: Center(child: child),
);

void main() {
  group('Slider', () {
    testWidgets(
      'a range moves the thumb nearest the tap, and the thumbs never cross',
      (tester) async {
        final semantics = tester.ensureSemantics();
        var range = (.2, .6);
        await tester.pumpWidget(
          app(
            SizedBox(
              width: 216,
              child: StatefulBuilder(
                builder: (context, set) => Slider.range(
                  values: range,
                  step: .1,
                  semanticLabel: 'Price',
                  onRangeChanged: (r) => set(() => range = r),
                ),
              ),
            ),
          ),
        );
        final box = tester.getRect(find.byType(Slider));
        await tester.tapAt(Offset(box.left + 8 + 180, box.center.dy));
        await tester.pump();
        expect(range.$1, closeTo(.2, 1e-9));
        expect(range.$2, closeTo(.9, 1e-9));
        expect(find.bySemanticsLabel('Price, lowest'), findsOneWidget);
        expect(find.bySemanticsLabel('Price, highest'), findsOneWidget);
        // The low thumb, pushed past the high one, stops at it.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        for (var i = 0; i < 12; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
        }
        expect(range.$1, closeTo(.9, 1e-9));
        semantics.dispose();
      },
    );

    testWidgets('upright, the lowest value is at the bottom', (tester) async {
      var v = 0.0;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Slider(
              value: v,
              axis: Axis.vertical,
              length: 216,
              onChanged: (x) => set(() => v = x),
            ),
          ),
        ),
      );
      final box = tester.getRect(find.byType(Slider));
      expect(box.height, 216);
      await tester.tapAt(Offset(box.center.dx, box.top + 8 + 50));
      expect(v, closeTo(.75, .01));
    });
  });

  testWidgets('an indeterminate checkbox reads as mixed and ticks on a tap', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    bool? value;
    await tester.pumpWidget(
      app(
        Checkbox(
          value: false,
          indeterminate: true,
          semanticLabel: 'All',
          onChanged: (v) => value = v,
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('All'))
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.mixed,
    );
    await tester.tap(find.byType(Checkbox));
    expect(value, isTrue);
    semantics.dispose();
  });

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

  testWidgets(
    'button sizes, and an invalid button draws a destructive border',
    (tester) async {
      await tester.pumpWidget(
        app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in [
                ButtonSize.xs,
                ButtonSize.iconXs,
                ButtonSize.iconSm,
                ButtonSize.iconLg,
              ])
                Button(
                  size: s,
                  semanticLabel: '$s',
                  onPressed: () {},
                  child: const Text('A'),
                ),
              Button(
                variant: ButtonVariant.outline,
                error: true,
                onPressed: () {},
                child: const Text('Bad'),
              ),
            ],
          ),
        ),
      );
      final sizes = [
        for (final e in find.byType(Button).evaluate().take(4)) e.size!,
      ];
      expect(sizes.map((s) => s.height), [24, 24, 32, 40]);
      expect(sizes.skip(1).map((s) => s.width), [24, 32, 40]);
      final bad = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(Button).last,
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(
        ((bad.decoration! as BoxDecoration).border! as Border).top.color,
        AshlarColors.light.destructive,
      );
    },
  );

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

  group('Tabs', () {
    const tabs = [
      TabItem(label: Text('One'), content: Text('First')),
      TabItem(label: Text('Two'), content: Text('Second')),
    ];

    testWidgets('the line variant underlines the chosen tab', (tester) async {
      await tester.pumpWidget(
        app(const Tabs(variant: TabsVariant.line, tabs: tabs)),
      );
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
      expect((deco('One').border! as Border).bottom.width, 2);
      expect(
        (deco('Two').border! as Border).bottom.color,
        const Color(0x00000000),
      );
    });

    testWidgets(
      'vertical tabs sit beside the panel and move with the up and down arrows',
      (tester) async {
        await tester.pumpWidget(
          app(
            const SizedBox(
              width: 400,
              child: Tabs(axis: Axis.vertical, tabs: tabs),
            ),
          ),
        );
        expect(
          tester.getTopLeft(find.text('Two')).dy,
          greaterThan(tester.getTopLeft(find.text('One')).dy),
        );
        expect(
          tester.getTopLeft(find.text('First')).dx,
          greaterThan(tester.getTopRight(find.text('One')).dx),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(find.text('Second'), findsOneWidget);
      },
    );
  });

  testWidgets(
    'a spaced toggle group stands its toggles apart, and can stand upright',
    (tester) async {
      await tester.pumpWidget(
        app(
          ToggleGroup<int>(
            values: const {1},
            spacing: 8,
            axis: Axis.vertical,
            onChanged: (_) {},
            items: const [
              ToggleGroupItem(1, Text('A')),
              ToggleGroupItem(2, Text('B')),
            ],
          ),
        ),
      );
      final a = tester.getRect(find.byType(Toggle).first),
          b = tester.getRect(find.byType(Toggle).last);
      expect(b.top - a.bottom, 8);
      expect(a.left, b.left);
    },
  );
}
