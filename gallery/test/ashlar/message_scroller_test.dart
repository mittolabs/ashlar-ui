// Tests for Message Scroller. Copied into your app by `ashlar add message-scroller` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/message_scroller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    AshlarApp(
      builder: (context, page) =>
          Directionality(textDirection: direction, child: page!),
      home: child,
    );

/// A row of a known height, named by its id.
MessageScrollerItem row(String id, double height, {bool anchor = false}) =>
    MessageScrollerItem(
      id: id,
      anchor: anchor,
      child: SizedBox(height: height, child: Text(id)),
    );

void main() {
  endButtonTests();
  followEndTests();
  group('Message Scroller', () {
    Future<MessageScrollerController> pump(
      WidgetTester tester,
      List<MessageScrollerItem> items, {
      MessageScrollStart start = MessageScrollStart.lastAnchor,
    }) async {
      final controller = MessageScrollerController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        app(
          Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: MessageScroller(
                controller: controller,
                start: start,
                gap: 0,
                padding: EdgeInsets.zero,
                items: items,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return controller;
    }

    double topOf(WidgetTester tester, String id) =>
        tester.getTopLeft(find.text(id)).dy -
        tester.getTopLeft(find.byType(MessageScroller)).dy;

    testWidgets('opens at the last turn when it is longer than the view', (
      tester,
    ) async {
      await pump(tester, [
        for (var i = 0; i < 10; i++) row('old $i', 100),
        row('question', 60, anchor: true),
        row('long answer', 600),
      ]);
      // The question near the top, its answer below: not the very end.
      expect(topOf(tester, 'question'), closeTo(64, 1));
    });

    testWidgets('opens at the end when the last turn fits', (tester) async {
      await pump(tester, [
        for (var i = 0; i < 10; i++) row('old $i', 100),
        row('question', 60, anchor: true),
        row('short answer', 100),
      ]);
      expect(
        tester.getBottomLeft(find.text('short answer')).dy,
        closeTo(tester.getBottomLeft(find.byType(MessageScroller)).dy, 1),
      );
    });

    testWidgets(
      'a new turn rises near the top, the row before it peeking above',
      (tester) async {
        final items = [for (var i = 0; i < 10; i++) row('old $i', 100)];
        await pump(tester, items);
        await pump(tester, [...items, row('new question', 60, anchor: true)]);
        // 64 of the row before stays in view; room is kept below to read from the top.
        expect(topOf(tester, 'new question'), closeTo(64, 1));
        expect(find.text('old 9'), findsOneWidget);
      },
    );

    testWidgets(
      'it follows a growing answer only while the reader is at the end',
      (tester) async {
        final items = [for (var i = 0; i < 10; i++) row('old $i', 100)];
        await pump(tester, [
          ...items,
          row('q', 40, anchor: true),
          row('a', 50),
        ]);
        // The answer streams in, longer than the view: the reader is carried along.
        await pump(tester, [
          ...items,
          row('q', 40, anchor: true),
          row('a', 900),
        ]);
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.text('a')).dy,
          closeTo(tester.getBottomLeft(find.byType(MessageScroller)).dy, 1),
        );
        // The reader scrolls up to read: more streams in, and they stay put.
        await tester.drag(find.byType(MessageScroller), const Offset(0, 200));
        await tester.pumpAndSettle();
        final before = tester.getTopLeft(find.text('a')).dy;
        await pump(tester, [
          ...items,
          row('q', 40, anchor: true),
          row('a', 1200),
        ]);
        expect(tester.getTopLeft(find.text('a')).dy, closeTo(before, 1));
      },
    );

    testWidgets('a turn sent from far up is brought into view', (tester) async {
      final items = [for (var i = 0; i < 30; i++) row('old $i', 100)];
      final controller = await pump(
        tester,
        items,
        start: MessageScrollStart.start,
      );
      expect(controller.canScrollEnd, isTrue);
      // Sent while reading the start: the new turn is far below anything laid out.
      await pump(tester, [...items, row('q', 40, anchor: true), row('a', 50)]);
      await tester.pumpAndSettle();
      expect(find.text('q'), findsOneWidget);
      expect(topOf(tester, 'q'), lessThan(120));
    });

    testWidgets('older messages load above without moving the view', (
      tester,
    ) async {
      final items = [for (var i = 10; i < 20; i++) row('m $i', 100)];
      await pump(tester, items, start: MessageScrollStart.start);
      final at = topOf(tester, 'm 11');
      await pump(tester, [
        for (var i = 0; i < 10; i++) row('m $i', 100),
        ...items,
      ], start: MessageScrollStart.start);
      expect(topOf(tester, 'm 11'), closeTo(at, 1));
      expect(find.text('m 9'), findsNothing);
    });

    testWidgets(
      'jumps to a message not yet built, and tells which turn shows',
      (tester) async {
        final controller = await pump(tester, [
          for (var i = 0; i < 200; i++) row('m $i', 100, anchor: i % 10 == 0),
        ], start: MessageScrollStart.end);
        expect(find.text('m 30'), findsNothing);
        expect(controller.scrollToMessage('m 30'), isTrue);
        await tester.pumpAndSettle();
        expect(topOf(tester, 'm 30'), closeTo(0, 1));
        expect(controller.currentAnchor, 'm 30');
        expect(controller.visible.first, 'm 30');
        expect(controller.scrollToMessage('nobody'), isFalse);
      },
    );

    testWidgets('the button shows only with more below, and takes you there', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, [
        for (var i = 0; i < 20; i++) row('m $i', 100),
      ], start: MessageScrollStart.end);
      expect(find.semantics.byLabel('Scroll to end'), findsNothing);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        mouse.hover(tester.getCenter(find.byType(MessageScroller))),
      );
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, -600)));
      await tester.pumpAndSettle();
      expect(find.semantics.byLabel('Scroll to end'), findsOne);
      await tester.tap(find.bySemanticsLabel('Scroll to end'));
      await tester.pumpAndSettle();
      expect(find.text('m 19'), findsOneWidget);
      expect(find.semantics.byLabel('Scroll to end'), findsNothing);
      semantics.dispose();
    });
  });
}

/// Found 2026-11-03 in an app: the scroll-to-end button sat over the rows, so a
/// wheel or trackpad scroll that started on it never reached the scroller, and
/// it shows exactly when the reader has scrolled up.
void endButtonTests() {
  testWidgets('a scroll that starts on the end button moves the rows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(
        MessageScroller(
          items: [
            for (var i = 0; i < 30; i++)
              MessageScrollerItem(
                id: i,
                child: SizedBox(height: 120, child: Text('row $i')),
              ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    final mouse = TestPointer(1, PointerDeviceKind.mouse);
    final stuck = <String>[];
    for (var y = 40.0; y < 700; y += 40) {
      for (final x in [100.0, 450.0]) {
        position.jumpTo(position.maxScrollExtent / 2);
        await tester.pumpAndSettle();
        final before = position.pixels;
        await tester.sendEventToBinding(mouse.hover(Offset(x, y)));
        await tester.sendEventToBinding(mouse.scroll(const Offset(0, -100)));
        await tester.pumpAndSettle();
        if (position.pixels == before) stuck.add('($x, $y)');
      }
    }
    expect(stuck, isEmpty);
  });
}

class _Growing extends StatefulWidget {
  const _Growing();
  @override
  State<_Growing> createState() => _GrowingState();
}

class _GrowingState extends State<_Growing> {
  double last = 300;
  void grow() => setState(() => last += 1);
  @override
  Widget build(BuildContext context) => MessageScroller(
    items: [
      for (var i = 0; i < 6; i++)
        MessageScrollerItem(
          id: i,
          child: SizedBox(height: 200, child: Text('row $i')),
        ),
      MessageScrollerItem(
        id: 'last',
        child: SizedBox(height: last),
      ),
    ],
  );
}

/// Found 2026-11-03 from an app's log of real trackpad events: scrolling up from
/// the end, the first pixel still counted as "at the end" (a trackpad bounce
/// overshoots it), a size change in that moment queued a jump to the end, and
/// the jump ran after the reader had moved away. The page flickered back.
void followEndTests() {
  testWidgets(
    'scrolling up from the end is not pulled back when the rows change',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(const _Growing()));
      await tester.pumpAndSettle();
      final pos = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      final rows = tester.state<_GrowingState>(find.byType(_Growing));
      expect(pos.pixels, pos.maxScrollExtent);
      final pad = TestPointer(1, PointerDeviceKind.trackpad);
      const at = Offset(450, 300);
      await tester.sendEventToBinding(pad.panZoomStart(at));
      await tester.sendEventToBinding(
        pad.panZoomUpdate(at, pan: const Offset(0, 1)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      rows.grow();
      for (var k = 1; k <= 8; k++) {
        await tester.sendEventToBinding(
          pad.panZoomUpdate(at, pan: Offset(0, 1 + 15.0 * k)),
        );
        await tester.pump(const Duration(milliseconds: 16));
        if (k == 2) rows.grow();
      }
      await tester.sendEventToBinding(pad.panZoomEnd());
      await tester.pumpAndSettle();
      expect(pos.pixels, lessThan(pos.maxScrollExtent - 60));
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
