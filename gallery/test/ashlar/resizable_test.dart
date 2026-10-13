// Tests for Resizable. Copied into your app by `ashlar add resizable` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/resizable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
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

  testWidgets('resizable reports the shares after a move', (tester) async {
    List<double>? sizes;
    await tester.pumpWidget(
      app(
        SizedBox(
          width: 401,
          height: 100,
          child: Resizable(
            onResize: (s) => sizes = s,
            panels: const [
              ResizablePanel(child: Text('A')),
              ResizablePanel(child: Text('B')),
            ],
          ),
        ),
      ),
    );
    await tester.dragFrom(
      tester.getCenter(find.byType(Resizable)),
      const Offset(100, 0),
    );
    expect(sizes![0], closeTo(.75, .01));
  });
}
