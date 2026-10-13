// Tests for Menubar. Copied into your app by `ashlar add menubar` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';
import 'package:ashlar_ui_gallery/ui/menubar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  group('Menubar', () {
    Future<List<String>> bar(WidgetTester tester) async {
      final picked = <String>[];
      await tester.pumpWidget(
        app(
          Menubar(
            menus: [
              MenubarMenu(
                'File',
                items: [
                  MenuItem(
                    onPressed: () => picked.add('new'),
                    child: const Text('New tab'),
                  ),
                ],
              ),
              MenubarMenu(
                'Edit',
                items: [
                  MenuItem(
                    onPressed: () => picked.add('undo'),
                    child: const Text('Undo'),
                  ),
                ],
              ),
              MenubarMenu(
                'View',
                items: [
                  MenuItem(
                    onPressed: () => picked.add('zoom'),
                    child: const Text('Zoom in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      return picked;
    }

    testWidgets('a click opens a menu; pointing at the next switches to it', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final picked = await bar(tester);
      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      expect(find.text('New tab'), findsOneWidget);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('File')));
      await mouse.moveTo(tester.getCenter(find.text('Edit')));
      await tester.pumpAndSettle();
      expect(find.text('New tab'), findsNothing);
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(picked, ['undo']);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    testWidgets('the arrows move between menus', (tester) async {
      await bar(tester);
      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(find.text('Zoom in'), findsOneWidget);
    });
  });
}
