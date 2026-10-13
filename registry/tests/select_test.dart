// Tests for Select. Copied into your app by `ashlar add select` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/popover.dart';
import 'package:ashlar_ui_gallery/ui/select.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: child),
    );

/// The drawn panel of an open popover, menu or select (PopoverPanel itself fills the screen to place it).
Finder panel() => find
    .descendant(of: find.byType(PopoverPanel), matching: find.byType(TapRegion))
    .first;

/// Without the room a finger's press area takes on a phone: these measure looks.
Widget app2(Widget child) => AshlarApp(
  theme: AshlarThemeData.light().copyWith(tapTarget: 0),
  home: Center(child: SizedBox(width: 260, child: child)),
);

const fruit = [
  SelectOption('apple', 'Apple', group: 'Fruit'),
  SelectOption('banana', 'Banana', group: 'Fruit'),
  SelectOption('blueberry', 'Blueberry', group: 'Fruit', enabled: false),
  SelectOption('carrot', 'Carrot', group: 'Vegetables'),
  SelectOption('cabbage', 'Cabbage', group: 'Vegetables'),
];

/// Without the room a finger's press area takes on a phone: these measure looks.
Widget app3(Widget child) => AshlarApp(
  theme: AshlarThemeData.light().copyWith(tapTarget: 0),
  home: Center(child: SizedBox(width: 260, child: child)),
);

void main() {
  group('Select', () {
    Widget select(String? value, ValueChanged<String> onChanged) => SizedBox(
      width: 200,
      child: Select<String>(
        value: value,
        placeholder: 'Choose a county',
        semanticLabel: 'County',
        options: const [
          SelectOption('nbo', 'Nairobi'),
          SelectOption('msa', 'Mombasa'),
          SelectOption('ksm', 'Kisumu'),
        ],
        onChanged: onChanged,
      ),
    );

    testWidgets('shows the placeholder, then the chosen option', (
      tester,
    ) async {
      String? value;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) =>
                select(value, (v) => set(() => value = v)),
          ),
        ),
      );
      expect(find.text('Choose a county'), findsOneWidget);
      await tester.tap(find.text('Choose a county'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mombasa'));
      await tester.pumpAndSettle();
      expect(value, 'msa');
      expect(find.text('Mombasa'), findsOneWidget);
      expect(find.text('Kisumu'), findsNothing);
    });

    testWidgets('the list is at least as wide as the trigger', (tester) async {
      await tester.pumpWidget(app(select(null, (_) {})));
      await tester.tap(find.byType(Select<String>));
      await tester.pumpAndSettle();
      expect(tester.getSize(panel()).width, greaterThanOrEqualTo(200));
    });

    testWidgets(
      'by keyboard: down arrow opens on the chosen option, and focus comes back',
      (tester) async {
        String? value = 'nbo';
        await tester.pumpWidget(
          app(
            StatefulBuilder(
              builder: (context, set) =>
                  select(value, (v) => set(() => value = v)),
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(find.text('Kisumu'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(value, 'msa');
        final focused = FocusManager.instance.primaryFocus!.context!;
        expect(
          focused.findAncestorWidgetOfExactType<Select<String>>(),
          isNotNull,
        );
      },
    );

    testWidgets('a screen reader hears what it chooses and the choice', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(app(select('ksm', (_) {})));
      final node = tester.getSemantics(find.text('Kisumu')).getSemanticsData();
      expect(node.label, 'County');
      expect(node.value, 'Kisumu');
      semantics.dispose();
    });
  });

  group('Select', () {
    testWidgets(
      'lists options under their groups, with the disabled one skipped by the keys',
      (tester) async {
        String? value = 'banana';
        await tester.pumpWidget(
          app2(
            StatefulBuilder(
              builder: (context, set) => Select<String>(
                value: value,
                options: fruit,
                onChanged: (v) => set(() => value = v),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Banana'));
        await tester.pumpAndSettle();
        expect(find.text('Fruit'), findsOneWidget);
        expect(find.text('Vegetables'), findsOneWidget);
        // Down from Banana passes over Blueberry.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(value, 'carrot');
      },
    );

    testWidgets('typing jumps to an option by its first letters', (
      tester,
    ) async {
      String? value;
      await tester.pumpWidget(
        app2(
          StatefulBuilder(
            builder: (context, set) => Select<String>(
              value: value,
              placeholder: 'Pick',
              options: fruit,
              onChanged: (v) => set(() => value = v),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(value, 'cabbage');
    });

    testWidgets(
      'a list of 10,000 opens on the chosen one with a screenful built',
      (tester) async {
        String? value = 'v7000';
        await tester.pumpWidget(
          app2(
            Select<String>(
              value: value,
              options: [
                for (var i = 0; i < 10000; i++)
                  SelectOption('v$i', 'Option $i'),
              ],
              onChanged: (v) => value = v,
            ),
          ),
        );
        await tester.tap(find.text('Option 7000'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Option ').evaluate().length, lessThan(25));
        expect(find.text('Option 7000').hitTestable(), findsWidgets);
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(value, 'v9999');
      },
    );

    testWidgets('the small size is 32 tall', (tester) async {
      await tester.pumpWidget(
        app2(
          Select<String>(
            value: null,
            placeholder: 'Pick',
            size: SelectSize.sm,
            options: fruit,
            onChanged: (_) {},
          ),
        ),
      );
      expect(tester.getSize(find.byType(Select<String>)).height, 32);
    });
  });

  testWidgets('a select\'s list is as wide as its field', (tester) async {
    String? picked;
    await tester.pumpWidget(
      app3(
        StatefulBuilder(
          builder: (context, set) => Select<String>(
            value: picked,
            placeholder: 'Choose',
            options: fruit,
            onChanged: (v) => set(() => picked = v),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();
    final list = tester.getRect(
      find
          .ancestor(of: find.text('Banana'), matching: find.byType(Container))
          .last,
    );
    expect(list.width, closeTo(260, 1));
  });
}
