// Tests for Pull To Refresh. Copied into your app by `ashlar add pull-to-refresh` with the component: they
// check what it promises, so change them as you change it.
import 'dart:async';

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/pull_to_refresh.dart';
import 'package:ashlar_ui_gallery/ui/spinner.dart';
import 'package:flutter/foundation.dart';
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
}
