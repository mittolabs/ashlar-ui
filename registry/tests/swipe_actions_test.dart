// Tests for Swipe Actions. Copied into your app by `ashlar add swipe-actions` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/swipe_actions.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    AshlarApp(
      builder: (context, page) =>
          Directionality(textDirection: direction, child: page!),
      home: child,
    );

void main() {
  group('Swipe Actions', () {
    late List<String> done;
    late int rowPresses;
    Widget row({TextDirection direction = TextDirection.ltr}) => app(
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 360,
          child: SwipeActions(
            start: [
              SwipeAction(
                label: 'Pin',
                icon: const Text('P'),
                onPressed: () => done.add('pin'),
              ),
            ],
            end: [
              SwipeAction(
                label: 'Delete',
                icon: const Text('D'),
                destructive: true,
                onPressed: () => done.add('delete'),
              ),
              SwipeAction(
                label: 'Archive',
                icon: const Text('A'),
                onPressed: () => done.add('archive'),
              ),
            ],
            child: GestureDetector(
              onTap: () => rowPresses++,
              child: const SizedBox(
                height: 60,
                child: Center(child: Text('Invoice 2041')),
              ),
            ),
          ),
        ),
      ),
      direction: direction,
    );

    setUp(() {
      done = [];
      rowPresses = 0;
    });

    testWidgets(
      'a swipe shows the actions; one pressed is done and closes it',
      (tester) async {
        await tester.pumpWidget(row());
        expect(find.text('Delete'), findsNothing);
        await tester.drag(find.text('Invoice 2041'), const Offset(-120, 0));
        await tester.pumpAndSettle();
        expect(find.text('Delete'), findsOneWidget);
        await tester.tap(find.text('Archive'));
        await tester.pumpAndSettle();
        expect(done, ['archive']);
        expect(find.text('Delete'), findsNothing);
      },
    );

    testWidgets(
      'a short swipe springs back; a full one does the first action',
      (tester) async {
        await tester.pumpWidget(row());
        await tester.drag(find.text('Invoice 2041'), const Offset(-30, 0));
        await tester.pumpAndSettle();
        expect(find.text('Delete'), findsNothing);
        await tester.drag(find.text('Invoice 2041'), const Offset(-300, 0));
        await tester.pumpAndSettle();
        expect(done, ['delete']);
        await tester.drag(find.text('Invoice 2041'), const Offset(300, 0));
        await tester.pumpAndSettle();
        expect(done, ['delete', 'pin']);
      },
    );

    testWidgets('an open row closes on a tap, which does not reach the row', (
      tester,
    ) async {
      await tester.pumpWidget(row());
      await tester.drag(find.text('Invoice 2041'), const Offset(-120, 0));
      await tester.pumpAndSettle();
      // The row lets the tap through to the swipe, which closes.
      await tester.tap(find.text('Invoice 2041'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(rowPresses, 0);
      expect(find.text('Delete'), findsNothing);
      await tester.tap(find.text('Invoice 2041'));
      expect(rowPresses, 1);
    });

    testWidgets('right to left, the end is on the left', (tester) async {
      await tester.pumpWidget(row(direction: TextDirection.rtl));
      await tester.drag(find.text('Invoice 2041'), const Offset(120, 0));
      await tester.pumpAndSettle();
      expect(find.text('Delete'), findsOneWidget);
      expect(
        tester.getCenter(find.text('Delete')).dx,
        lessThan(tester.getCenter(find.text('Invoice 2041')).dx),
      );
    });

    testWidgets('a screen reader has the actions without swiping', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(row());
      final node = tester.getSemantics(find.byType(SwipeActions));
      final data = node.getSemanticsData();
      expect(data.customSemanticsActionIds, hasLength(3));
      final delete = data.customSemanticsActionIds!.firstWhere(
        (id) => CustomSemanticsAction.getAction(id)!.label == 'Delete',
      );
      node.owner!.performAction(node.id, SemanticsAction.customAction, delete);
      expect(done, ['delete']);
      semantics.dispose();
    });
  });
}
