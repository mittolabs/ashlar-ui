// Tests for Drawer. Copied into your app by `ashlar add drawer` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/drawer.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

Future<void> open(WidgetTester tester, void Function(BuildContext) show) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  // A keyboard 300 tall.
  tester.view.viewInsets = const FakeViewPadding(bottom: 300);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AshlarApp(
      home: Builder(
        builder: (context) => Center(
          child: Button(
            onPressed: () => show(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
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

  testWidgets('a drawer from the bottom rises above the keyboard', (
    tester,
  ) async {
    await open(
      tester,
      (context) => showDrawer<void>(
        context: context,
        builder: (_) => const Drawer(
          title: Text('Note'),
          content: Input(placeholder: 'Note'),
        ),
      ),
    );
    expect(tester.getRect(find.byType(Input)).bottom, lessThanOrEqualTo(500));
  });

  testWidgets('a drawer from the left goes back left with a drag', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Button(
            onPressed: () => showDrawer(
              context: context,
              side: DrawerSide.left,
              builder: (_) => const Drawer(title: Text('Filters')),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(Drawer)).left, 0);
    await tester.drag(find.text('Filters'), const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsNothing);
  });
}
