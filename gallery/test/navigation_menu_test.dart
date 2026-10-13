// Navigation Menu: one panel for the bar, moving to the heading shown.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/navigation_menu.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
