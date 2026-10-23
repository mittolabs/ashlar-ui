// Tests for Combobox. Copied into your app by `ashlar add combobox` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/combobox.dart';
import 'package:ashlar_ui_gallery/ui/popover.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

/// Without the room a finger's press area takes on a phone: these measure looks.
Widget app2(Widget child) => AshlarApp(
  theme: AshlarThemeData.light().copyWith(tapTarget: 0),
  home: Center(child: SizedBox(width: 260, child: child)),
);

void main() {
  testWidgets('in a short space, its list shrinks rather than overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      AshlarApp(
        home: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 240,
            child: Combobox<int>(
              value: null,
              options: [
                for (var i = 0; i < 40; i++) ComboboxOption(i, 'Option $i'),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Combobox<int>));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Option 0'), findsOneWidget);
  });

  testWidgets('a combobox searches, picks and says what it holds', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    String? value;
    await tester.pumpWidget(
      app(
        SizedBox(
          width: 240,
          child: StatefulBuilder(
            builder: (context, set) => Combobox<String>(
              value: value,
              placeholder: 'Choose a city',
              semanticLabel: 'City',
              options: const [
                ComboboxOption('lis', 'Lisbon'),
                ComboboxOption('bom', 'Mumbai'),
                ComboboxOption('kyo', 'Kyoto'),
              ],
              onChanged: (v) => set(() => value = v),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Choose a city'));
    await tester.pumpAndSettle();
    // As wide as the trigger, not the screen.
    expect(
      tester
          .getSize(
            find
                .descendant(
                  of: find.byType(PopoverPanel),
                  matching: find.byType(TapRegion),
                )
                .first,
          )
          .width,
      240,
    );
    await tester.enterText(find.byType(EditableText), 'mum');
    await tester.pump();
    expect(find.text('Lisbon'), findsNothing);
    await tester.tap(find.text('Mumbai'));
    await tester.pumpAndSettle();
    expect(value, 'bom');
    expect(find.text('Kyoto'), findsNothing);
    final node = tester.getSemantics(find.text('Mumbai')).getSemanticsData();
    expect(node.label, 'City');
    expect(node.value, 'Mumbai');
    semantics.dispose();
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
          app2(
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
        app2(
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
