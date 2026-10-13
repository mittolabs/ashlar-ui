// Tests for Bottom Bar. Copied into your app by `ashlar add bottom-bar` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/bottom_bar.dart';
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
