// The third batch, as an app gets it from lib/ui.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/breadcrumb.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/button_group.dart';
import 'package:ashlar_ui_gallery/ui/empty.dart';
import 'package:ashlar_ui_gallery/ui/item.dart';
import 'package:ashlar_ui_gallery/ui/progress.dart';
import 'package:ashlar_ui_gallery/ui/typography.dart';
import 'package:flutter/services.dart';
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
        final r = (first.borderRadius! as BorderRadius);
        expect(r.topLeft.x, greaterThan(0));
        expect(r.topRight, Radius.zero);
        expect((middle.borderRadius! as BorderRadius), BorderRadius.zero);
        expect((last.borderRadius! as BorderRadius).topRight.x, greaterThan(0));
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

  testWidgets('headings are announced as headings', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            H1('Title'),
            H2('Section'),
            H3('Part'),
            H4('Small'),
            P('Text'),
            Lead('Lead'),
            Large('Large'),
            Small('Small note'),
            Muted('Muted'),
            Blockquote('Quote'),
            InlineCode('code'),
            BulletList(['One', 'Two']),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    for (final h in ['Title', 'Section', 'Part', 'Small']) {
      expect(
        tester.getSemantics(find.text(h)).flagsCollection.isHeader,
        isTrue,
        reason: h,
      );
    }
    expect(
      tester.getSemantics(find.text('Text')).flagsCollection.isHeader,
      isFalse,
    );
    semantics.dispose();
  });

  testWidgets('empty and item lay out in light and dark', (tester) async {
    for (final mode in AshlarThemeMode.values) {
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Empty(
                  title: const Text('No projects'),
                  description: const Text('Create one.'),
                  actions: [
                    Button(onPressed: () {}, child: const Text('Create')),
                  ],
                ),
                for (final v in ItemVariant.values)
                  Item(
                    variant: v,
                    title: const Text('Title'),
                    description: const Text('Description'),
                  ),
              ],
            ),
          ),
          mode: mode,
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('an item with onPressed is a button, by tap and by keyboard', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var n = 0;
    await tester.pumpWidget(
      app(
        SizedBox(
          width: 300,
          child: Item(title: const Text('Open'), onPressed: () => n++),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(n, 2);
    expect(
      tester
          .getSemantics(find.text('Open'))
          .getSemanticsData()
          .flagsCollection
          .isButton,
      isTrue,
    );
    semantics.dispose();
  });

  group('Progress', () {
    testWidgets('fills to its value and reads it as a percentage', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          const SizedBox(
            width: 200,
            child: Progress(value: .4, semanticLabel: 'Upload'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final fill = tester.getSize(
        find
            .descendant(
              of: find.byType(Progress),
              matching: find.byType(DecoratedBox),
            )
            .last,
      );
      expect(fill.width, closeTo(80, .5));
      final node = tester
          .getSemantics(find.byType(Progress))
          .getSemanticsData();
      expect(node.label, 'Upload');
      expect(node.value, '40%');
      semantics.dispose();
    });

    testWidgets('unknown, it sweeps; with less motion asked for, it is still', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(const SizedBox(width: 200, child: Progress())),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: app(const SizedBox(width: 200, child: Progress())),
        ),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('Breadcrumb', () {
    testWidgets('the steps above are links; the page itself is not', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final went = <String>[];
      await tester.pumpWidget(
        app(
          Breadcrumb(
            items: [
              BreadcrumbItem('Home', onPressed: () => went.add('home')),
              BreadcrumbItem('Docs', onPressed: () => went.add('docs')),
              const BreadcrumbItem('Breadcrumb'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Docs'));
      expect(went, ['docs']);
      final docs = tester.getSemantics(find.text('Docs')).getSemanticsData();
      expect(docs.flagsCollection.isLink, isTrue);
      expect(docs.flagsCollection.isButton, isFalse);
      final here = tester
          .getSemantics(find.text('Breadcrumb'))
          .getSemanticsData();
      expect(here.flagsCollection.isLink, isFalse);
      semantics.dispose();
    });
  });
}
