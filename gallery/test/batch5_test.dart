// Hover card, context menu, scroll area and data table, as an app gets them from lib/ui.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/context_menu.dart';
import 'package:ashlar_ui_gallery/ui/data_table.dart';
import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';
import 'package:ashlar_ui_gallery/ui/hover_card.dart';
import 'package:ashlar_ui_gallery/ui/popover.dart';
import 'package:ashlar_ui_gallery/ui/scroll_area.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

Future<TestGesture> mouseAt(WidgetTester tester, Offset at) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(at);
  return mouse;
}

void main() {
  testWidgets(
    'a hover card waits, appears, stays while the pointer is on it, then goes',
    (tester) async {
      await tester.pumpWidget(
        app(
          HoverCard(
            content: (context) => const Text('Profile card'),
            child: Button(
              variant: ButtonVariant.link,
              onPressed: () {},
              child: const Text('@wanjiru'),
            ),
          ),
        ),
      );
      final mouse = await mouseAt(
        tester,
        tester.getCenter(find.text('@wanjiru')),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Profile card'), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('Profile card'), findsOneWidget);
      // Across the gap and onto the card: it stays.
      await mouse.moveTo(tester.getCenter(find.text('Profile card')));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Profile card'), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Profile card'), findsNothing);
    },
  );

  group('Context Menu', () {
    Future<List<String>> menu(WidgetTester tester) async {
      final picked = <String>[];
      await tester.pumpWidget(
        app(
          ContextMenu(
            items: [
              MenuItem(
                onPressed: () => picked.add('back'),
                child: const Text('Back'),
              ),
              MenuItem(
                onPressed: () => picked.add('reload'),
                child: const Text('Reload'),
              ),
            ],
            child: SizedBox(
              width: 300,
              height: 150,
              child: Center(
                child: Button(onPressed: () {}, child: const Text('Area')),
              ),
            ),
          ),
        ),
      );
      return picked;
    }

    testWidgets('a right-click opens it at the pointer; picking closes it', (
      tester,
    ) async {
      final picked = await menu(tester);
      final area = tester.getRect(find.byType(ContextMenu));
      final at = area.topLeft + const Offset(40, 30);
      await tester.tapAt(at, buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      final panel = tester.getRect(
        find
            .descendant(
              of: find.byType(PopoverPanel),
              matching: find.byType(TapRegion),
            )
            .first,
      );
      expect(panel.left, closeTo(at.dx, 1));
      expect(panel.top, closeTo(at.dy + 4, 1));
      await tester.tap(find.text('Reload'));
      await tester.pumpAndSettle();
      expect(picked, ['reload']);
      expect(find.text('Back'), findsNothing);
    });

    testWidgets(
      'a long press opens it, and so does Shift+F10 from the keyboard',
      (tester) async {
        await menu(tester);
        await tester.longPress(find.byType(ContextMenu));
        await tester.pumpAndSettle();
        expect(find.text('Back'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Back'), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.f10);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
        expect(find.text('Back'), findsOneWidget);
      },
    );
  });

  testWidgets('a scroll area scrolls and shows its bar under the pointer', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        SizedBox(
          height: 200,
          width: 200,
          child: ScrollArea(
            child: Column(
              children: [for (var i = 0; i < 40; i++) Text('Tag $i')],
            ),
          ),
        ),
      ),
    );
    expect(
      tester.widget<RawScrollbar>(find.byType(RawScrollbar)).thumbVisibility,
      isFalse,
    );
    await mouseAt(tester, tester.getCenter(find.byType(ScrollArea)));
    await tester.pump();
    expect(
      tester.widget<RawScrollbar>(find.byType(RawScrollbar)).thumbVisibility,
      isTrue,
    );
    await tester.drag(find.byType(ScrollArea), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Tag 0').hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('Data Table', () {
    Widget table({ValueChanged<int>? onRowPressed}) => SizedBox(
      width: 480,
      child: DataTable(
        columns: const [
          DataColumn(Text('Invoice')),
          DataColumn(Text('Status')),
          DataColumn(Text('Amount'), numeric: true),
        ],
        rows: const [
          [Text('INV001'), Text('Paid'), Text('KES 2,500')],
          [Text('INV002'), Text('Pending'), Text('KES 1,500')],
        ],
        footer: const [Text('Total'), SizedBox(), Text('KES 4,000')],
        caption: const Text('Recent invoices.'),
        onRowPressed: onRowPressed,
      ),
    );

    testWidgets('headings are headings; numbers sit at the end', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(app(table()));
      expect(tester.takeException(), isNull);
      expect(
        tester
            .getSemantics(find.text('Invoice'))
            .getSemanticsData()
            .flagsCollection
            .isHeader,
        isTrue,
      );
      final amount = tester.getRect(find.text('KES 2,500')),
          cell = tester.getRect(find.byType(DataTable));
      expect(amount.right, closeTo(cell.right - 8, 1));
      semantics.dispose();
    });

    testWidgets('with onRowPressed, each row is a button', (tester) async {
      final semantics = tester.ensureSemantics();
      final pressed = <int>[];
      await tester.pumpWidget(app(table(onRowPressed: pressed.add)));
      await tester.tap(find.text('Pending'));
      expect(pressed, [1]);
      final row = tester.getSemantics(find.text('Pending')).getSemanticsData();
      expect(row.flagsCollection.isButton, isTrue);
      expect(row.label, contains('INV002'));
      semantics.dispose();
    });
  });
}
