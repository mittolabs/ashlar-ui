// The interactive part of the third batch, as an app gets it from lib/ui.
import 'dart:ui' show Tristate;

import 'package:ashlar_ui_gallery/ui/accordion.dart';
import 'package:ashlar_ui_gallery/ui/alert_dialog.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/collapsible.dart';
import 'package:ashlar_ui_gallery/ui/pagination.dart';
import 'package:ashlar_ui_gallery/ui/slider.dart';
import 'package:ashlar_ui_gallery/ui/toggle.dart';
import 'package:ashlar_ui_gallery/ui/toggle_group.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  testWidgets(
    'a collapsible hides its content from sight, focus and screen readers until opened',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 300,
            child: Collapsible(
              builder: (context, open, toggle) => Button(
                onPressed: toggle,
                child: Text(open ? 'Hide' : 'Show'),
              ),
              child: Button(onPressed: () {}, child: const Text('Inside')),
            ),
          ),
        ),
      );
      expect(find.text('Inside').hitTestable(), findsNothing);
      expect(find.bySemanticsLabel('Inside'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus!.context!
            .findAncestorWidgetOfExactType<Collapsible>(),
        isNotNull,
      );
      expect(find.text('Show'), findsOneWidget);
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Inside').hitTestable(), findsOneWidget);
      expect(find.text('Hide'), findsOneWidget);
      semantics.dispose();
    },
  );

  group('Accordion', () {
    const items = [
      AccordionItem(title: Text('One'), content: Text('First body')),
      AccordionItem(title: Text('Two'), content: Text('Second body')),
    ];

    testWidgets('one open at a time; the heading says expanded or collapsed', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(const SizedBox(width: 300, child: Accordion(items: items))),
      );
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      expect(find.text('First body').hitTestable(), findsOneWidget);
      expect(
        tester
            .getSemantics(find.text('One'))
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        Tristate.isTrue,
      );
      expect(
        tester
            .getSemantics(find.text('Two'))
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        Tristate.isFalse,
      );
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();
      expect(find.text('First body').hitTestable(), findsNothing);
      expect(find.text('Second body').hitTestable(), findsOneWidget);
      semantics.dispose();
    });

    testWidgets(
      'with multiple, several stay open; Enter opens from the keyboard',
      (tester) async {
        await tester.pumpWidget(
          app(
            const SizedBox(
              width: 300,
              child: Accordion(items: items, multiple: true),
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Two'));
        await tester.pumpAndSettle();
        expect(find.text('First body').hitTestable(), findsOneWidget);
        expect(find.text('Second body').hitTestable(), findsOneWidget);
      },
    );
  });

  group('Toggle', () {
    testWidgets('stays pressed and says so', (tester) async {
      final semantics = tester.ensureSemantics();
      var on = false;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Toggle(
              pressed: on,
              onChanged: (v) => set(() => on = v),
              semanticLabel: 'Bold',
              child: const Text('B'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Toggle));
      await tester.pump();
      expect(on, isTrue);
      final node = tester.getSemantics(find.byType(Toggle)).getSemanticsData();
      expect(node.label, 'Bold');
      expect(node.flagsCollection.isToggled, Tristate.isTrue);
      semantics.dispose();
    });

    testWidgets(
      'a group presses one at a time, or several; the arrows move between them',
      (tester) async {
        var values = <String>{};
        var multiple = false;
        await tester.pumpWidget(
          app(
            StatefulBuilder(
              builder: (context, set) => ToggleGroup<String>(
                values: values,
                multiple: multiple,
                onChanged: (v) => set(() => values = v),
                items: const [
                  ToggleGroupItem('a', Text('A')),
                  ToggleGroupItem('b', Text('B')),
                  ToggleGroupItem('c', Text('C')),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('A'));
        await tester.pump();
        await tester.tap(find.text('B'));
        await tester.pump();
        expect(values, {'b'});
        await tester.tap(find.text('B'));
        await tester.pump();
        expect(values, isEmpty);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(values, {'c'});
        multiple = true;
        tester.element(find.byType(StatefulBuilder)).markNeedsBuild();
        await tester.pump();
        await tester.tap(find.text('A'));
        await tester.pump();
        expect(values, {'a', 'c'});
      },
    );
  });

  group('Slider', () {
    Future<List<double>> slider(
      WidgetTester tester, {
      double value = .5,
      double? step,
    }) async {
      final seen = <double>[];
      var v = value;
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 216,
            child: StatefulBuilder(
              builder: (context, set) => Slider(
                value: v,
                step: step,
                semanticLabel: 'Volume',
                onChanged: (x) => set(() {
                  v = x;
                  seen.add(x);
                }),
              ),
            ),
          ),
        ),
      );
      return seen;
    }

    testWidgets('a tap sets the value where it lands', (tester) async {
      final seen = await slider(tester);
      final box = tester.getRect(find.byType(Slider));
      // The thumb's centre runs from 8 to 208 on a 216 wide track.
      await tester.tapAt(Offset(box.left + 8 + 50, box.center.dy));
      expect(seen.last, closeTo(.25, .01));
    });

    testWidgets('the keys step, page and jump to the ends', (tester) async {
      final seen = await slider(tester, step: .1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(seen.last, closeTo(.6, 1e-9));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(seen.last, closeTo(.4, 1e-9));
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      expect(seen.last, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      expect(seen.last, 0);
    });

    testWidgets(
      'a screen reader hears a slider with its value, and can move it',
      (tester) async {
        final semantics = tester.ensureSemantics();
        final seen = await slider(tester, step: .1);
        final node = tester.getSemantics(find.byType(Slider));
        final data = node.getSemanticsData();
        expect(data.flagsCollection.isSlider, isTrue);
        expect(data.label, 'Volume');
        expect(data.value, '50%');
        expect(data.increasedValue, '60%');
        node.owner!.performAction(node.id, SemanticsAction.increase);
        expect(seen.last, closeTo(.6, 1e-9));
        semantics.dispose();
      },
    );
  });

  group('Pagination', () {
    testWidgets('shows the first, the last and the pages near this one', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var page = 5;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Pagination(
              page: page,
              pageCount: 12,
              onChanged: (p) => set(() => page = p),
            ),
          ),
        ),
      );
      for (final p in ['1', '4', '5', '6', '12']) {
        expect(find.text(p), findsOneWidget, reason: p);
      }
      expect(find.text('2'), findsNothing);
      expect(find.bySemanticsLabel('More pages'), findsNWidgets(2));
      expect(find.bySemanticsLabel('Page 5, current page'), findsOneWidget);
      await tester.tap(find.text('6'));
      await tester.pump();
      expect(page, 6);
      await tester.tap(find.text('Previous'));
      await tester.pump();
      expect(page, 5);
      semantics.dispose();
    });

    testWidgets('Previous is off on the first page, Next on the last', (
      tester,
    ) async {
      var page = 1;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Pagination(
              page: page,
              pageCount: 3,
              onChanged: (p) => set(() => page = p),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Previous'), warnIfMissed: false);
      await tester.pump();
      expect(page, 1);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('Alert Dialog', () {
    Future<List<bool>> open(WidgetTester tester) async {
      final answers = <bool>[];
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Button(
              onPressed: () async => answers.add(
                await showAlertDialog(
                  context,
                  title: 'Delete?',
                  action: 'Delete',
                  destructive: true,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      return answers;
    }

    testWidgets('a tap outside does nothing; Escape cancels', (tester) async {
      final answers = await open(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsOneWidget);
      expect(find.bySemanticsLabel('Close'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsNothing);
      expect(answers, [false]);
    });

    testWidgets('the action answers true', (tester) async {
      final answers = await open(tester);
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(answers, [true]);
    });
  });
}
