// Tests for Drawer. Copied into your app by `ashlar add drawer` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/drawer.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/pressable.dart';
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
  group('Drawer builder', () {
    testWidgets('says so when its builder returns no Drawer', (tester) async {
      await open(
        tester,
        (context) => showDrawer<void>(
          context: context,
          builder: (context) => const Text('Bare'),
        ),
      );
      expect(
        '${tester.takeException()}',
        contains("showDrawer's builder returned no Drawer"),
      );
    });

    testWidgets('says nothing when the Drawer is inside another widget', (
      tester,
    ) async {
      await open(
        tester,
        (context) => showDrawer<void>(
          context: context,
          builder: (context) => const Padding(
            padding: EdgeInsets.zero,
            child: Drawer(title: Text('Wrapped')),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
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

  group('DrawerSheet', () {
    // Where the sheet's top is: its handle's, under the sheet's one-pixel border.
    double top(WidgetTester tester) =>
        tester
            .getTopLeft(
              find
                  .descendant(
                    of: find.byType(DrawerSheet),
                    matching: find.byType(Pressable),
                  )
                  .first,
            )
            .dy -
        1;

    Future<void> sheet(
      WidgetTester tester, {
      DrawerSheetController? controller,
      ValueChanged<int>? onSnap,
    }) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        AshlarApp(
          home: Stack(
            children: [
              const Center(child: Text('Behind')),
              DrawerSheet(
                snaps: const [.4, .9],
                controller: controller,
                onSnap: onSnap,
                builder: (context, scroll) => ListView(
                  controller: scroll,
                  children: [
                    const Text('First'),
                    for (var i = 0; i < 40; i++) Text('Row $i'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('rests at its first snap, over what is behind it', (
      tester,
    ) async {
      await sheet(tester);
      expect(top(tester), moreOrLessEquals(800 * .6, epsilon: 1));
      expect(find.text('Behind'), findsOneWidget);
    });

    testWidgets('dragged up by its handle, it rests at the next snap', (
      tester,
    ) async {
      final snaps = <int>[];
      await sheet(tester, onSnap: snaps.add);
      await tester.drag(
        find.bySemanticsLabel('Raise Sheet'),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(top(tester), moreOrLessEquals(800 * .1, epsilon: 1));
      expect(snaps, [1]);
    });

    testWidgets('a short, slow drag springs back to the snap it was at', (
      tester,
    ) async {
      await sheet(tester);
      await tester.timedDrag(
        find.bySemanticsLabel('Raise Sheet'),
        const Offset(0, -60),
        const Duration(milliseconds: 600),
      );
      await tester.pumpAndSettle();
      expect(top(tester), moreOrLessEquals(800 * .6, epsilon: 1));
    });

    testWidgets(
      'its handle, pressed, goes up a snap, and from the top back down',
      (tester) async {
        await sheet(tester);
        await tester.tap(find.bySemanticsLabel('Raise Sheet'));
        await tester.pumpAndSettle();
        expect(top(tester), moreOrLessEquals(800 * .1, epsilon: 1));
        await tester.tap(find.bySemanticsLabel('Lower Sheet'));
        await tester.pumpAndSettle();
        expect(top(tester), moreOrLessEquals(800 * .6, epsilon: 1));
      },
    );

    testWidgets('a controller moves it and says where it rests', (
      tester,
    ) async {
      final controller = DrawerSheetController();
      await sheet(tester, controller: controller);
      expect(controller.snap, 0);
      // Its animation runs on frames, which only pumping advances: not awaited here.
      controller.snapTo(1);
      await tester.pumpAndSettle();
      expect(controller.snap, 1);
      expect(top(tester), moreOrLessEquals(800 * .1, epsilon: 1));
    });
  });

  testWidgets('opens over a nested navigator, a tab bar included', (
    tester,
  ) async {
    await tester.pumpWidget(
      AshlarApp(
        home: Column(
          children: [
            Expanded(
              child: Navigator(
                key: const Key('tab'),
                onGenerateRoute: (_) => PageRouteBuilder<void>(
                  pageBuilder: (context, _, _) => Center(
                    child: Button(
                      onPressed: () => showDrawer<void>(
                        context: context,
                        builder: (_) => const Drawer(title: Text('Sheet')),
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(key: Key('bar'), height: 56),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    // Not in the tab's navigator but the app's, so from the bottom of the screen.
    expect(find.text('Sheet'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('tab')),
        matching: find.text('Sheet'),
      ),
      findsNothing,
    );
    expect(
      tester.getBottomLeft(find.byType(Drawer)).dy,
      greaterThan(tester.getTopLeft(find.byKey(const Key('bar'))).dy),
    );
  });
}
