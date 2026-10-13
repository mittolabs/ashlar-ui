// Tests every component as an app gets it: the files `ashlar add --all` copied into lib/ui.
import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/badge.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/dialog.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/separator.dart';
import 'package:ashlar_ui_gallery/ui/switch.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: child),
    );

/// The decoration of the first box a control draws.
BoxDecoration box(WidgetTester tester, Finder of) =>
    tester
            .widget<AnimatedContainer>(
              find
                  .descendant(of: of, matching: find.byType(AnimatedContainer))
                  .first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  test('nothing uses Material or Cupertino', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final f in files) {
      expect(
        f.readAsStringSync(),
        isNot(matches(RegExp(r"package:flutter/(material|cupertino)\.dart"))),
        reason: f.path,
      );
    }
    expect(
      File('pubspec.yaml').readAsStringSync(),
      isNot(contains('uses-material-design')),
    );
  });

  group('Button', () {
    testWidgets('a tap, Enter and Space all press it', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        app(Button(onPressed: () => presses++, child: const Text('Save'))),
      );
      await tester.tap(find.text('Save'));
      expect(presses, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(presses, 3);
    });

    testWidgets('disabled, it ignores taps and is announced as disabled', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(const Button(onPressed: null, child: Text('Save'))),
      );
      await tester.tap(find.text('Save'), warnIfMissed: false);
      expect(
        tester.getSemantics(find.text('Save')),
        matchesSemantics(
          label: 'Save',
          isButton: true,
          hasEnabledState: true,
          isFocusable: false,
        ),
      );
      semantics.dispose();
    });

    testWidgets('a screen reader hears its text as a button', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(Button(onPressed: () {}, child: const Text('Save'))),
      );
      expect(
        tester.getSemantics(find.text('Save')),
        matchesSemantics(
          label: 'Save',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('the focus ring shows for keyboard focus, not for a tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(Button(onPressed: () {}, child: const Text('Save'))),
      );
      final button = find.byType(Button);
      bool ring() =>
          box(tester, button).boxShadow!.any((s) => s.spreadRadius == 3);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(ring(), isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(ring(), isTrue);
    });

    testWidgets('hovering changes its fill', (tester) async {
      await tester.pumpWidget(
        app(
          Button(
            variant: ButtonVariant.outline,
            onPressed: () {},
            child: const Text('Save'),
          ),
        ),
      );
      final before = box(tester, find.byType(Button)).color;
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Save')));
      await tester.pumpAndSettle();
      expect(box(tester, find.byType(Button)).color, isNot(before));
      expect(box(tester, find.byType(Button)).color, AshlarColors.light.accent);
    });

    testWidgets('every variant and size lays out without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          Wrap(
            children: [
              for (final v in ButtonVariant.values)
                for (final s in ButtonSize.values)
                  Button(
                    variant: v,
                    size: s,
                    onPressed: () {},
                    semanticLabel: 'x',
                    child: const Text('Go'),
                  ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final heights = [
        for (final e in find.byType(Button).evaluate()) e.size!.height,
      ];
      expect(heights.take(4), [32, 36, 40, 36]);
    });
  });

  group('Checkbox and Switch', () {
    testWidgets(
      'a checkbox toggles by tap and by Space, and says whether it is checked',
      (tester) async {
        final semantics = tester.ensureSemantics();
        var value = false;
        await tester.pumpWidget(
          app(
            StatefulBuilder(
              builder: (context, set) => Checkbox(
                value: value,
                onChanged: (v) => set(() => value = v),
                semanticLabel: 'Terms',
              ),
            ),
          ),
        );
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        expect(value, isTrue);
        expect(
          tester.getSemantics(
            find
                .descendant(
                  of: find.byType(Checkbox),
                  matching: find.byType(MergeSemantics),
                )
                .first,
          ),
          matchesSemantics(
            label: 'Terms',
            hasCheckedState: true,
            isChecked: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            isFocusable: true,
            hasFocusAction: true,
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(value, isFalse);
        semantics.dispose();
      },
    );

    testWidgets('a switch toggles and says whether it is on', (tester) async {
      final semantics = tester.ensureSemantics();
      var value = false;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Switch(
              value: value,
              onChanged: (v) => set(() => value = v),
              semanticLabel: 'Wi-Fi',
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(
        tester.getSemantics(
          find
              .descendant(
                of: find.byType(Switch),
                matching: find.byType(MergeSemantics),
              )
              .first,
        ),
        matchesSemantics(
          label: 'Wi-Fi',
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('disabled, neither changes', (tester) async {
      await tester.pumpWidget(
        app(
          const Column(
            children: [
              Checkbox(value: false, onChanged: null),
              Switch(value: false, onChanged: null),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.tap(find.byType(Switch), warnIfMissed: false);
      expect(tester.takeException(), isNull);
    });
  });

  group('Input', () {
    testWidgets(
      'typing fills it, hides the placeholder and reports each change',
      (tester) async {
        final seen = <String>[];
        await tester.pumpWidget(
          app(
            SizedBox(
              width: 300,
              child: Input(placeholder: 'Email', onChanged: seen.add),
            ),
          ),
        );
        expect(find.text('Email'), findsOneWidget);
        await tester.tap(find.byType(Input));
        await tester.enterText(find.byType(EditableText), 'a@solutech.co.ke');
        await tester.pump();
        expect(find.text('Email'), findsNothing);
        expect(seen.last, 'a@solutech.co.ke');
      },
    );

    testWidgets('focus draws the ring; an error draws it red', (tester) async {
      await tester.pumpWidget(
        app(
          const SizedBox(
            width: 300,
            child: Column(
              children: [
                Input(placeholder: 'A'),
                Input(placeholder: 'B', error: true),
              ],
            ),
          ),
        ),
      );
      final first = find.byType(Input).first, second = find.byType(Input).last;
      expect(
        box(tester, first).boxShadow!.any((s) => s.spreadRadius == 3),
        isFalse,
      );
      await tester.tap(first);
      await tester.pumpAndSettle();
      expect(
        box(tester, first).boxShadow!.any((s) => s.spreadRadius == 3),
        isTrue,
      );
      expect(
        (box(tester, second).border! as Border).top.color,
        AshlarColors.light.destructive,
      );
    });

    testWidgets('a screen reader hears a text field named by its placeholder', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(const SizedBox(width: 300, child: Input(placeholder: 'Email'))),
      );
      final node = tester.getSemantics(find.byType(EditableText));
      expect(node.label, 'Email');
      expect(node.flagsCollection.isTextField, isTrue);
      expect(node.flagsCollection.isFocused != Tristate.none, isTrue);
      semantics.dispose();
    });

    testWidgets('disabled, it does not take focus', (tester) async {
      final focus = FocusNode();
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 300,
            child: Input(
              placeholder: 'Email',
              enabled: false,
              focusNode: focus,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Input));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'x');
      expect(find.text('x'), findsNothing);
      focus.dispose();
    });
  });

  group('Dialog', () {
    Future<List<Object?>> open(WidgetTester tester) async {
      final results = <Object?>[];
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Button(
              onPressed: () async => results.add(
                await showAshlarDialog<String>(
                  context: context,
                  builder: (context) => Dialog(
                    title: const Text('Delete?'),
                    description: const Text('This cannot be undone.'),
                    actions: [
                      Button(
                        onPressed: () => Navigator.pop(context, 'delete'),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsOneWidget);
      return results;
    }

    testWidgets('an action closes it with its value', (tester) async {
      final results = await open(tester);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsNothing);
      expect(results, ['delete']);
    });

    testWidgets('Escape closes it', (tester) async {
      final results = await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsNothing);
      expect(results, [null]);
    });

    testWidgets('the close button and a tap outside close it', (tester) async {
      await open(tester);
      await tester.tap(find.bySemanticsLabel('Close').last);
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsNothing);
    });

    testWidgets('it carries the dark theme', (tester) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Button(
              onPressed: () => showAshlarDialog(
                context: context,
                builder: (_) => const Dialog(title: Text('Hi')),
              ),
              child: const Text('Open'),
            ),
          ),
          mode: AshlarThemeMode.dark,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final panel = tester.widget<Container>(
        find
            .ancestor(of: find.text('Hi'), matching: find.byType(Container))
            .first,
      );
      expect(
        (panel.decoration! as BoxDecoration).color,
        AshlarColors.dark.background,
      );
    });
  });

  group('Card, Badge and Separator', () {
    testWidgets('lay out in light and dark without overflow', (tester) async {
      for (final mode in [AshlarThemeMode.light, AshlarThemeMode.dark]) {
        await tester.pumpWidget(
          app(
            SizedBox(
              width: 360,
              child: Card(
                children: [
                  const CardHeader(
                    title: Text('Title'),
                    description: Text('Description'),
                    action: Badge(child: Text('New')),
                  ),
                  const CardContent(child: Separator()),
                  CardFooter(
                    children: [
                      Button(onPressed: () {}, child: const Text('OK')),
                    ],
                  ),
                ],
              ),
            ),
            mode: mode,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('New'), findsOneWidget);
      }
    });
  });
}
