// Tests for Radio. Copied into your app by `ashlar add radio` with the component: they
// check what it promises, so change them as you change it.
import 'dart:ui' show CheckedState;

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/radio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: child),
    );

Widget app2(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  group('Radio', () {
    Widget group(String? value, ValueChanged<String?> onChanged) =>
        RadioGroup<String>(
          groupValue: value,
          onChanged: onChanged,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio(value: 'monthly', label: Text('Monthly')),
              Radio(value: 'yearly', label: Text('Yearly')),
              Radio(value: 'never', label: Text('Never'), enabled: false),
            ],
          ),
        );

    testWidgets(
      'a tap on the label chooses it, and it is announced as checked',
      (tester) async {
        final semantics = tester.ensureSemantics();
        String? value;
        await tester.pumpWidget(
          app(
            StatefulBuilder(
              builder: (context, set) =>
                  group(value, (v) => set(() => value = v)),
            ),
          ),
        );
        await tester.tap(find.text('Yearly'));
        await tester.pump();
        expect(value, 'yearly');
        final node = tester.getSemantics(find.text('Yearly'));
        expect(node.label, 'Yearly');
        expect(node.flagsCollection.isChecked, CheckedState.isTrue);
        expect(node.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
        semantics.dispose();
      },
    );

    testWidgets('the arrow keys move the choice', (tester) async {
      String? value = 'monthly';
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) =>
                group(value, (v) => set(() => value = v)),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 'yearly');
    });

    testWidgets('a disabled one cannot be chosen', (tester) async {
      String? value;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) =>
                group(value, (v) => set(() => value = v)),
          ),
        ),
      );
      await tester.tap(find.text('Never'), warnIfMissed: false);
      await tester.pump();
      expect(value, isNull);
    });
  });

  testWidgets('radio cards mark the chosen one', (tester) async {
    String? plan = 'pro';
    await tester.pumpWidget(
      app2(
        SizedBox(
          width: 300,
          child: StatefulBuilder(
            builder: (context, set) => RadioGroup<String>(
              groupValue: plan,
              onChanged: (v) => set(() => plan = v),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(value: 'free', card: true, label: Text('Free')),
                  Radio(value: 'pro', card: true, label: Text('Pro')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Free'));
    await tester.pumpAndSettle();
    expect(plan, 'free');
  });
}
