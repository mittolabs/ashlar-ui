// The sidebar, as an app gets it from lib/ui.
import 'dart:ui' show Tristate;

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/sidebar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget layout(
  List<String> went, {
  double width = 900,
  SidebarCollapse collapse = SidebarCollapse.icons,
}) => AshlarApp(
  home: Align(
    alignment: Alignment.topLeft,
    child: SizedBox(
      width: width,
      height: 500,
      child: SidebarLayout(
        collapse: collapse,
        header: const Text('Acme'),
        groups: [
          SidebarGroup(label: 'App', [
            SidebarItem(
              'Home',
              icon: AshlarIconsRoundedStroke.house,
              active: true,
              onPressed: () => went.add('home'),
            ),
            SidebarItem(
              'Inbox',
              icon: AshlarIconsRoundedStroke.inbox,
              badge: '12',
              onPressed: () => went.add('inbox'),
            ),
          ]),
        ],
        child: const Column(
          children: [
            Row(children: [SidebarTrigger()]),
            Expanded(child: Center(child: Text('Page'))),
          ],
        ),
      ),
    ),
  ),
);

double sidebarWidth(WidgetTester tester) =>
    tester.getSize(find.byType(AnimatedContainer).first).width;

void main() {
  testWidgets(
    'beside the page: labels, the page shown, a badge, and a tap goes there',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final went = <String>[];
      await tester.pumpWidget(layout(went));
      expect(sidebarWidth(tester), 256);
      expect(find.text('Acme'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.text('Home'))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      await tester.tap(find.text('Inbox'));
      expect(went, ['inbox']);
      semantics.dispose();
    },
  );

  testWidgets(
    'the trigger collapses it to icons, named for screen readers; Ctrl+B brings it back',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(layout([]));
      await tester.tap(find.bySemanticsLabel('Toggle sidebar'));
      await tester.pumpAndSettle();
      expect(sidebarWidth(tester), 48);
      expect(find.text('Inbox'), findsNothing);
      expect(find.bySemanticsLabel('Inbox'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(sidebarWidth(tester), 256);
      semantics.dispose();
    },
  );

  testWidgets('offcanvas, it goes out of sight and out of what is read', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(layout([], collapse: SidebarCollapse.offcanvas));
    await tester.tap(find.bySemanticsLabel('Toggle sidebar'));
    await tester.pumpAndSettle();
    expect(sidebarWidth(tester), 0);
    expect(find.bySemanticsLabel('Inbox'), findsNothing);
    semantics.dispose();
  });

  testWidgets(
    'on a narrow screen it is hidden, and slides in over the page; a pick closes it',
    (tester) async {
      final went = <String>[];
      await tester.pumpWidget(layout(went, width: 500));
      expect(sidebarWidth(tester), 0);
      expect(find.text('Inbox'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Toggle sidebar'));
      await tester.pumpAndSettle();
      expect(find.text('Inbox'), findsOneWidget);
      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();
      expect(went, ['inbox']);
      expect(find.text('Inbox'), findsNothing);
    },
  );
}
