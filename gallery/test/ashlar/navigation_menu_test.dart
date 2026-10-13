// Tests for Navigation Menu. Copied into your app by `ashlar add navigation-menu` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/navigation_menu.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

Widget menu() => AshlarApp(
  home: Align(
    alignment: Alignment.topCenter,
    child: NavigationMenu(
      items: [
        NavigationMenuItem(
          'Products',
          width: 300,
          content: (context) =>
              NavigationMenuLink(title: 'Components', onPressed: () {}),
        ),
        NavigationMenuItem.link('Pricing', onPressed: () {}),
        NavigationMenuItem(
          'Company',
          width: 220,
          content: (context) =>
              NavigationMenuLink(title: 'About us', onPressed: () {}),
        ),
      ],
    ),
  ),
);

/// The panel: the box around a link's content.
Rect panelOf(WidgetTester tester, String link) => tester.getRect(
  find
      .ancestor(of: find.text(link), matching: find.byType(AnimatedContainer))
      .last,
);

void main() {
  testWidgets(
    'a navigation menu opens on hover after a moment; its links close it',
    (tester) async {
      final went = <String>[];
      await tester.pumpWidget(
        app(
          NavigationMenu(
            items: [
              NavigationMenuItem(
                'Components',
                content: (context) => NavigationMenuLink(
                  title: 'Button',
                  description: 'Six variants.',
                  onPressed: () => went.add('button'),
                ),
              ),
              NavigationMenuItem.link(
                'Docs',
                onPressed: () => went.add('docs'),
              ),
            ],
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Components')));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Six variants.'), findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Six variants.'), findsOneWidget);
      await mouse.moveTo(tester.getCenter(find.text('Button')));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Button'));
      await tester.pumpAndSettle();
      expect(went, ['button']);
      expect(find.text('Six variants.'), findsNothing);
      await tester.tap(find.text('Docs'));
      expect(went, ['button', 'docs']);
    },
  );

  testWidgets('moving to another heading moves the one panel across to it', (
    tester,
  ) async {
    await tester.pumpWidget(menu());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Products')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    final first = panelOf(tester, 'Components');
    expect(first.width, closeTo(300, 1));

    await mouse.moveTo(tester.getCenter(find.text('Company')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    // Midway: the panel is on its way, and both contents are there as one slides in.
    final going = panelOf(tester, 'About us');
    expect(going.left, greaterThan(first.left + 1));
    expect(going.left, lessThan(tester.getRect(find.text('Company')).left));
    await tester.pumpAndSettle();
    final last = panelOf(tester, 'About us');
    expect(last.width, closeTo(220, 1));
    expect(
      last.left,
      closeTo(
        tester
            .getRect(
              find
                  .ancestor(
                    of: find.text('Company'),
                    matching: find.byType(KeyedSubtree),
                  )
                  .first,
            )
            .left,
        2,
      ),
    );
    // The content it left has gone.
    expect(find.text('Components'), findsNothing);
  });

  testWidgets('Escape closes it, and a heading is said to be open or not', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(menu());
    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();
    expect(find.text('Components'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.text('Products'))
          .getSemanticsData()
          .flagsCollection
          .isExpanded,
      isNot(equals(null)),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Components'), findsNothing);
    semantics.dispose();
  });
}
