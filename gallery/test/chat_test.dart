// Chat: messages on their sides, bubbles, markers, attachments, and a scroller that never
// moves the reader against their intent.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/attachment.dart';
import 'package:ashlar_ui_gallery/ui/bubble.dart';
import 'package:ashlar_ui_gallery/ui/marker.dart';
import 'package:ashlar_ui_gallery/ui/message.dart';
import 'package:ashlar_ui_gallery/ui/message_scroller.dart';
import 'package:ashlar_ui_gallery/ui/spinner.dart';
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
  group('Message and Bubble', () {
    for (final direction in TextDirection.values) {
      testWidgets(
        'what you sent sits at the end of the line, ${direction.name}',
        (tester) async {
          await tester.pumpWidget(
            app(
              const SizedBox(
                width: 400,
                child: Column(
                  children: [
                    Message(child: Bubble(child: Text('Theirs'))),
                    Message(
                      align: MessageAlign.end,
                      avatar: SizedBox.square(dimension: 32, child: Text('ME')),
                      child: Bubble(child: Text('Mine')),
                    ),
                  ],
                ),
              ),
              direction: direction,
            ),
          );
          final theirs = tester.getCenter(find.text('Theirs')).dx;
          final mine = tester.getCenter(find.text('Mine')).dx;
          final me = tester.getCenter(find.text('ME')).dx;
          if (direction == TextDirection.ltr) {
            expect(mine, greaterThan(theirs));
            expect(me, greaterThan(mine));
          } else {
            expect(mine, lessThan(theirs));
            expect(me, lessThan(mine));
          }
        },
      );
    }

    testWidgets('a bubble is no wider than four fifths of the room', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          Center(
            child: SizedBox(
              width: 500,
              child: Message(child: Bubble(child: Text('word ' * 80))),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(Bubble)).width, lessThanOrEqualTo(400));
    });

    testWidgets('reactions sit over the edge without covering what follows', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Bubble(reactions: Text('+2'), child: Text('Shipped')),
              Text('Next'),
            ],
          ),
        ),
      );
      final reaction = tester.getRect(find.text('+2'));
      final next = tester.getRect(find.text('Next'));
      expect(reaction.bottom, lessThanOrEqualTo(next.top));
      expect(
        reaction.top,
        lessThan(tester.getRect(find.text('Shipped')).bottom + 12),
      );
    });

    testWidgets('a bubble with onPressed is a button', (tester) async {
      var taps = 0;
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          Center(
            child: Bubble(
              variant: BubbleVariant.outline,
              onPressed: () => taps++,
              child: const Text('Yes, book it'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Yes, book it'));
      expect(taps, 1);
      expect(
        tester
            .getSemantics(find.text('Yes, book it'))
            .getSemanticsData()
            .flagsCollection
            .isButton,
        isTrue,
      );
      semantics.dispose();
    });
  });

  testWidgets('a separator marker has a line either side of its words', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 400,
          child: Marker(variant: MarkerVariant.separator, child: Text('Today')),
        ),
      ),
    );
    final lines = find.descendant(
      of: find.byType(Marker),
      matching: find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxHeight == 1,
      ),
    );
    expect(lines, findsNWidgets(2));
    final text = tester.getRect(find.text('Today'));
    expect(tester.getRect(lines.first).right, lessThan(text.left));
    expect(tester.getRect(lines.last).left, greaterThan(text.right));
  });

  group('Attachment', () {
    testWidgets('says how it is getting on, to the eye and the ear', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Attachment(
                  title: 'report.pdf',
                  description: '2.4 MB',
                  state: AttachmentState.uploading,
                ),
                Attachment(
                  title: 'photo.jpg',
                  description: 'Too large to send.',
                  state: AttachmentState.error,
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(Spinner), findsOneWidget);
      expect(
        find.bySemanticsLabel('report.pdf, 2.4 MB, uploading'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('photo.jpg, Too large to send., failed'),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('opens when pressed; its actions work on their own', (
      tester,
    ) async {
      var opened = 0, removed = 0;
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          Center(
            child: Attachment(
              title: 'notes.txt',
              onPressed: () => opened++,
              actions: [
                AttachmentAction(
                  icon: AshlarIconsRoundedStroke.x,
                  label: 'Remove',
                  onPressed: () => removed++,
                ),
              ],
            ),
          ),
        ),
      );
      // The name lets the press through to the card under it.
      await tester.tap(find.text('notes.txt'), warnIfMissed: false);
      await tester.tap(find.bySemanticsLabel('Remove'));
      expect((opened, removed), (1, 1));
      semantics.dispose();
    });

    testWidgets('a group scrolls sideways rather than overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 300,
            child: AttachmentGroup(
              children: [
                for (var i = 0; i < 6; i++) Attachment(title: 'file-$i.pdf'),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Scrollable), findsOneWidget);
    });
  });

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
