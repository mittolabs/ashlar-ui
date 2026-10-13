// Select's groups, type-to-find and long lists; Combobox's many picks, clearing and groups.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:ashlar_ui_gallery/ui/combobox.dart';
import 'package:ashlar_ui_gallery/ui/select.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Without the room a finger's press area takes on a phone: these measure looks.
Widget app(Widget child) => AshlarApp(
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

void main() {
  group('Select', () {
    testWidgets(
      'lists options under their groups, with the disabled one skipped by the keys',
      (tester) async {
        String? value = 'banana';
        await tester.pumpWidget(
          app(
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
        app(
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
          app(
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
        app(
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

  group('Combobox', () {
    const options = [
      ComboboxOption('ke', 'Kenya', group: 'East Africa'),
      ComboboxOption('tz', 'Tanzania', group: 'East Africa'),
      ComboboxOption('ug', 'Uganda', group: 'East Africa', enabled: false),
      ComboboxOption('gh', 'Ghana', group: 'West Africa'),
    ];

    testWidgets(
      'picks several as chips; a chip removes itself; the list stays open while picking',
      (tester) async {
        final semantics = tester.ensureSemantics();
        var values = <String>{};
        await tester.pumpWidget(
          app(
            StatefulBuilder(
              builder: (context, set) => Combobox<String>.multiple(
                values: values,
                placeholder: 'Countries',
                options: options,
                onValuesChanged: (v) => set(() => values = v),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Countries'));
        await tester.pumpAndSettle();
        expect(find.text('East Africa'), findsOneWidget);
        await tester.tap(find.text('Kenya'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ghana').last);
        await tester.pumpAndSettle();
        expect(values, {'ke', 'gh'});
        // A disabled option cannot be picked.
        await tester.tap(find.text('Uganda'), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(values, {'ke', 'gh'});
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Remove Kenya'));
        await tester.pumpAndSettle();
        expect(values, {'gh'});
        semantics.dispose();
      },
    );

    testWidgets('the clear button clears a single pick', (tester) async {
      final semantics = tester.ensureSemantics();
      String? value = 'tz';
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Combobox<String>(
              value: value,
              options: options,
              placeholder: 'Country',
              onChanged: (v) => set(() => value = v),
              onCleared: () => set(() => value = null),
            ),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Clear'));
      await tester.pumpAndSettle();
      expect(value, isNull);
      expect(find.text('Country'), findsOneWidget);
      expect(find.bySemanticsLabel('Clear'), findsNothing);
      semantics.dispose();
    });
  });
}
