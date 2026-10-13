// Tests for Accordion. Copied into your app by `ashlar add accordion` with the component: they
// check what it promises, so change them as you change it.
import 'dart:ui' show Tristate;

import 'package:ashlar_ui_gallery/ui/accordion.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
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

  testWidgets('a bordered accordion with a disabled section that stays shut', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 360,
          child: Accordion(
            bordered: true,
            items: [
              AccordionItem(title: Text('Open me'), content: Text('Opened')),
              AccordionItem(
                title: Text('Not me'),
                content: Text('Never'),
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Not me'));
    await tester.pumpAndSettle();
    expect(find.text('Never').hitTestable(), findsNothing);
    await tester.tap(find.text('Open me'));
    await tester.pumpAndSettle();
    expect(find.text('Opened').hitTestable(), findsOneWidget);
  });
}
