// Sheet, drawer, input group, input OTP and resizable, as an app gets them from lib/ui.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/drawer.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/input_group.dart';
import 'package:ashlar_ui_gallery/ui/input_otp.dart';
import 'package:ashlar_ui_gallery/ui/resizable.dart';
import 'package:ashlar_ui_gallery/ui/sheet.dart';
import 'package:ashlar_ui_gallery/ui/textarea.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  group('Sheet', () {
    Future<void> open(WidgetTester tester, SheetSide side) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Button(
              onPressed: () => showSheet(
                context: context,
                side: side,
                builder: (context) => const Sheet(
                  title: Text('Edit profile'),
                  content: Text('Form'),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('slides in at the right edge, no wider than 384', (
      tester,
    ) async {
      await open(tester, SheetSide.right);
      final panel = tester.getRect(
        find
            .ancestor(
              of: find.text('Edit profile'),
              matching: find.byType(SafeArea),
            )
            .first,
      );
      expect(panel.right, 800);
      expect(panel.width, lessThanOrEqualTo(384));
      expect(panel.height, 600);
    });

    testWidgets('at the left edge, and from the bottom at its own height', (
      tester,
    ) async {
      await open(tester, SheetSide.left);
      expect(
        tester
            .getRect(
              find
                  .ancestor(
                    of: find.text('Edit profile'),
                    matching: find.byType(SafeArea),
                  )
                  .first,
            )
            .left,
        0,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await open(tester, SheetSide.bottom);
      final panel = tester.getRect(
        find
            .ancestor(
              of: find.text('Edit profile'),
              matching: find.byType(SafeArea),
            )
            .first,
      );
      expect(panel.bottom, 600);
      expect(panel.height, lessThan(300));
    });

    testWidgets('the close button, Escape and a tap outside close it', (
      tester,
    ) async {
      await open(tester, SheetSide.right);
      await tester.tap(find.bySemanticsLabel('Close').last);
      await tester.pumpAndSettle();
      expect(find.text('Edit profile'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Edit profile'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 300));
      await tester.pumpAndSettle();
      expect(find.text('Edit profile'), findsNothing);
    });
  });

  group('Drawer', () {
    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Button(
              onPressed: () => showDrawer(
                context: context,
                builder: (context) => const Drawer(
                  title: Text('Move goal'),
                  content: SizedBox(height: 200, child: Text('Steps')),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'comes up at the bottom; a small drag springs back, a long one closes it',
      (tester) async {
        await open(tester);
        expect(tester.getBottomLeft(find.byType(Drawer)).dy, 600);
        await tester.drag(find.text('Move goal'), const Offset(0, 40));
        await tester.pumpAndSettle();
        expect(find.text('Move goal'), findsOneWidget);
        expect(tester.getBottomLeft(find.byType(Drawer)).dy, 600);
        await tester.drag(find.text('Move goal'), const Offset(0, 250));
        await tester.pumpAndSettle();
        expect(find.text('Move goal'), findsNothing);
      },
    );

    testWidgets('a tap outside closes it', (tester) async {
      await open(tester);
      await tester.tapAt(const Offset(400, 20));
      await tester.pumpAndSettle();
      expect(find.text('Move goal'), findsNothing);
    });
  });

  testWidgets(
    'an input group puts its pieces in one border and rings it when the field has focus',
    (tester) async {
      await tester.pumpWidget(
        app(
          const SizedBox(
            width: 320,
            child: InputGroup(
              start: Text('https://'),
              end: Text('.co.ke'),
              child: Input(decorated: false, placeholder: 'example'),
            ),
          ),
        ),
      );
      BoxDecoration group() =>
          tester
                  .widget<AnimatedContainer>(
                    find
                        .descendant(
                          of: find.byType(InputGroup),
                          matching: find.byType(AnimatedContainer),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(group().boxShadow!.any((s) => s.spreadRadius == 3), isFalse);
      // The field inside draws no box of its own.
      final inner = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(Input),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(inner.decoration, isNull);
      await tester.tap(find.byType(Input));
      await tester.pumpAndSettle();
      expect(group().boxShadow!.any((s) => s.spreadRadius == 3), isTrue);
      expect(
        tester.getRect(find.text('https://')).right,
        lessThan(tester.getRect(find.byType(Input)).left + 1),
      );
    },
  );

  group('Input OTP', () {
    testWidgets(
      'fills a box per digit, ignores letters and reports the whole code',
      (tester) async {
        final semantics = tester.ensureSemantics();
        String? done;
        await tester.pumpWidget(
          app(InputOtp(groups: const [3, 3], onCompleted: (c) => done = c)),
        );
        await tester.tap(find.byType(InputOtp));
        await tester.enterText(find.byType(EditableText), '12a3');
        await tester.pump();
        for (final d in ['1', '2', '3']) {
          expect(find.text(d), findsOneWidget);
        }
        expect(find.text('a'), findsNothing);
        expect(done, isNull);
        // Pasted whole, or filled in from a text message.
        await tester.enterText(find.byType(EditableText), '482913');
        await tester.pump();
        expect(done, '482913');
        final node = tester
            .getSemantics(find.byType(EditableText))
            .getSemanticsData();
        expect(node.label, contains('One-time code'));
        expect(node.flagsCollection.isTextField, isTrue);
        semantics.dispose();
      },
    );

    testWidgets('stops at its length', (tester) async {
      await tester.pumpWidget(app(const InputOtp(length: 4)));
      await tester.tap(find.byType(InputOtp));
      await tester.enterText(find.byType(EditableText), '123456');
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '1234',
      );
    });
  });

  group('Resizable', () {
    Widget panes() => const SizedBox(
      width: 401,
      height: 200,
      child: Resizable(
        panels: [
          ResizablePanel(size: 1, minSize: .2, child: Text('Left')),
          ResizablePanel(size: 3, child: Text('Right')),
        ],
      ),
    );

    double left(WidgetTester tester) => tester
        .getSize(
          find
              .ancestor(of: find.text('Left'), matching: find.byType(SizedBox))
              .first,
        )
        .width;

    testWidgets(
      'starts at its shares and drags to new ones, not past the least',
      (tester) async {
        await tester.pumpWidget(app(panes()));
        expect(left(tester), closeTo(100, .5));
        final handle = tester.getCenter(find.bySemanticsLabel('Resize'));
        await tester.dragFrom(handle, const Offset(100, 0));
        await tester.pump();
        expect(left(tester), closeTo(200, 1));
        await tester.dragFrom(
          tester.getCenter(find.bySemanticsLabel('Resize')),
          const Offset(-300, 0),
        );
        await tester.pump();
        expect(left(tester), closeTo(80, .5));
      },
    );

    testWidgets('the handle takes focus and the arrows move it', (
      tester,
    ) async {
      await tester.pumpWidget(app(panes()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(left(tester), closeTo(116, .5));
    });
  });

  group('Textarea', () {
    Finder grip() => find
        .descendant(
          of: find.byType(Textarea),
          matching: find.byType(CustomPaint),
        )
        .last;

    testWidgets(
      'the grip drags it taller a line at a time, and no shorter than two lines',
      (tester) async {
        await tester.pumpWidget(
          app(const SizedBox(width: 320, child: Textarea(placeholder: 'Note'))),
        );
        final start = tester.getSize(find.byType(Textarea)).height;
        await tester.drag(grip(), const Offset(0, 60));
        await tester.pump();
        expect(
          tester.getSize(find.byType(Textarea)).height,
          closeTo(start + 60, 1),
        );
        await tester.drag(grip(), const Offset(0, -400));
        await tester.pump();
        expect(tester.getSize(find.byType(Textarea)).height, 64);
        await tester.enterText(
          find.byType(EditableText),
          List.filled(10, 'line').join('\n'),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(Textarea)).height, 64);
      },
    );

    testWidgets('without resizable there is no grip', (tester) async {
      await tester.pumpWidget(
        app(const SizedBox(width: 320, child: Textarea(resizable: false))),
      );
      expect(
        find
            .descendant(
              of: find.byType(Textarea),
              matching: find.byType(MouseRegion),
            )
            .evaluate()
            .where(
              (e) =>
                  (e.widget as MouseRegion).cursor ==
                  SystemMouseCursors.resizeUpDown,
            ),
        isEmpty,
      );
    });
  });
}
