// Phone patterns: actions behind a row, pull to refresh, places along the bottom. Each
// reachable without its gesture too.
import 'dart:async';

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/bottom_bar.dart';
import 'package:ashlar_ui_gallery/ui/pull_to_refresh.dart';
import 'package:ashlar_ui_gallery/ui/spinner.dart';
import 'package:ashlar_ui_gallery/ui/swipe_actions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
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

  group('Pull to Refresh', () {
    Future<Completer<void>> pumpList(
      WidgetTester tester,
      List<int> calls,
    ) async {
      final done = Completer<void>();
      await tester.pumpWidget(
        app(
          PullToRefresh(
            onRefresh: () {
              calls.add(1);
              return done.future;
            },
            child: ListView(
              children: [
                for (var i = 0; i < 30; i++)
                  SizedBox(height: 50, child: Text('Order $i')),
              ],
            ),
          ),
        ),
      );
      return done;
    }

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('pulled far enough, it refreshes, on ${platform.name}', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          final calls = <int>[];
          final done = await pumpList(tester, calls);
          await tester.fling(find.text('Order 2'), const Offset(0, 400), 400);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(calls, [1]);
          expect(find.bySemanticsLabel('Refreshing'), findsOneWidget);
          done.complete();
          await tester.pumpAndSettle();
          expect(find.bySemanticsLabel('Refreshing'), findsNothing);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }

    testWidgets('a bouncing list is held under the spinner while it turns', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final calls = <int>[];
        final done = await pumpList(tester, calls);
        await tester.fling(find.text('Order 2'), const Offset(0, 400), 400);
        // The bounce back has finished; the refresh has not.
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(calls, [1]);
        final spinner = tester.getRect(find.byType(Spinner));
        expect(
          tester.getRect(find.text('Order 0')).top,
          greaterThanOrEqualTo(spinner.bottom),
        );
        done.complete();
        await tester.pumpAndSettle();
        expect(tester.getRect(find.text('Order 0')).top, 0);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('a short pull does not', (tester) async {
      final calls = <int>[];
      await pumpList(tester, calls);
      await tester.drag(find.text('Order 2'), const Offset(0, 40));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });

    testWidgets('a screen reader refreshes without pulling', (tester) async {
      final semantics = tester.ensureSemantics();
      final calls = <int>[];
      final done = await pumpList(tester, calls);
      final node = tester.getSemantics(find.byType(PullToRefresh));
      final id = node.getSemanticsData().customSemanticsActionIds!.single;
      expect(CustomSemanticsAction.getAction(id)!.label, 'Refresh');
      node.owner!.performAction(node.id, SemanticsAction.customAction, id);
      await tester.pump();
      expect(calls, [1]);
      done.complete();
      await tester.pumpAndSettle();
      semantics.dispose();
    });
  });

  group('Bottom Bar', () {
    testWidgets('a tap, or the arrow keys, choose a place; it is a tab bar', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var page = 0;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Align(
              alignment: Alignment.bottomCenter,
              child: BottomBar(
                index: page,
                onChanged: (i) => set(() => page = i),
                items: const [
                  BottomBarItem(label: 'Home', icon: Text('H')),
                  BottomBarItem(label: 'Inbox', icon: Text('I'), badge: '3'),
                  BottomBarItem(label: 'Profile', icon: Text('P')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Inbox'));
      await tester.pump();
      expect(page, 1);
      final inbox = tester
          .getSemantics(find.bySemanticsLabel('Inbox, 3'))
          .getSemanticsData();
      expect(inbox.role, SemanticsRole.tab);
      expect(inbox.flagsCollection.isSelected, isNotNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(page, 2);
      semantics.dispose();
    });

    testWidgets('it rises above the home indicator by its height', (
      tester,
    ) async {
      Future<double> homeBottom() async {
        await tester.pumpWidget(
          app(
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomBar(
                index: 0,
                onChanged: (_) {},
                items: const [
                  BottomBarItem(label: 'Home', icon: Text('H')),
                  BottomBarItem(label: 'Inbox', icon: Text('I')),
                ],
              ),
            ),
          ),
        );
        return tester.getRect(find.text('Home')).bottom;
      }

      final without = await homeBottom();
      // 34 physical pixels of home indicator.
      tester.view.padding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.reset);
      final within = await homeBottom();
      expect(without - within, closeTo(34 / tester.view.devicePixelRatio, .01));
    });
  });
}
