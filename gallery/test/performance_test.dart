// Long lists build only what is on screen, so they stay fast at any length.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/combobox.dart';
import 'package:ashlar_ui_gallery/ui/command.dart';
import 'package:ashlar_ui_gallery/ui/scroll_area.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const many = 10000;

Widget app(Widget child) => AshlarApp(home: Center(child: child));

/// How many rows exist right now: built, whether or not they are painted.
int built(String prefix) => find.textContaining(prefix).evaluate().length;

void main() {
  testWidgets(
    'a scroll area builder with 10,000 rows builds a screenful, wherever it is scrolled',
    (tester) async {
      final watch = Stopwatch()..start();
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 300,
            height: 300,
            child: ScrollArea.builder(
              itemCount: many,
              itemExtent: 30,
              itemBuilder: (context, i) => Text('Row $i'),
            ),
          ),
        ),
      );
      watch.stop();
      expect(built('Row '), lessThan(30));
      expect(watch.elapsedMilliseconds, lessThan(1000));
      await tester.drag(find.byType(ScrollArea), const Offset(0, -30000));
      await tester.pumpAndSettle();
      expect(built('Row '), lessThan(30));
      expect(find.text('Row 0'), findsNothing);
    },
  );

  group('Command with 10,000 items', () {
    Future<List<int>> command(WidgetTester tester) async {
      final picked = <int>[];
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 400,
            child: Command(
              groups: [
                CommandGroup(heading: 'Items', [
                  for (var i = 0; i < many; i++)
                    CommandItem('Item $i', onSelected: () => picked.add(i)),
                ]),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      return picked;
    }

    testWidgets('builds a screenful', (tester) async {
      final watch = Stopwatch()..start();
      await command(tester);
      watch.stop();
      expect(built('Item '), lessThan(20));
      expect(watch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('the keys still reach row 1,000 and keep it in view', (
      tester,
    ) async {
      final picked = await command(tester);
      for (var i = 0; i < 1000; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      }
      await tester.pump();
      expect(find.text('Item 1000').hitTestable(), findsOneWidget);
      expect(built('Item '), lessThan(20));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(picked, [1000]);
    });

    testWidgets('searching finds one among them', (tester) async {
      final picked = await command(tester);
      await tester.enterText(find.byType(EditableText), '9876');
      await tester.pump();
      expect(find.text('Item 9876'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(picked, [9876]);
    });
  });

  testWidgets('a combobox with 10,000 options opens with a screenful built', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        SizedBox(
          width: 240,
          child: Combobox<int>(
            value: null,
            placeholder: 'Choose',
            options: [
              for (var i = 0; i < many; i++) ComboboxOption(i, 'Option $i'),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    final watch = Stopwatch()..start();
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();
    watch.stop();
    expect(built('Option '), lessThan(20));
    expect(watch.elapsedMilliseconds, lessThan(1500));
  });
}
