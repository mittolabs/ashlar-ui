// The second batch: forms, overlays and feedback, as an app gets them from lib/ui.
import 'dart:ui' show CheckedState, SemanticsRole, Tristate;

import 'package:ashlar_ui_gallery/ui/alert.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/avatar.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';
import 'package:ashlar_ui_gallery/ui/field.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/kbd.dart';
import 'package:ashlar_ui_gallery/ui/popover.dart';
import 'package:ashlar_ui_gallery/ui/radio.dart';
import 'package:ashlar_ui_gallery/ui/select.dart';
import 'package:ashlar_ui_gallery/ui/skeleton.dart';
import 'package:ashlar_ui_gallery/ui/spinner.dart';
import 'package:ashlar_ui_gallery/ui/tabs.dart';
import 'package:ashlar_ui_gallery/ui/textarea.dart';
import 'package:ashlar_ui_gallery/ui/toast.dart';
import 'package:ashlar_ui_gallery/ui/tooltip.dart';
import 'package:flutter/gestures.dart';
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

void main() {
  group('Field', () {
    testWidgets('a screen reader hears the label with the checkbox', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 300,
            child: Field(
              axis: Axis.horizontal,
              label: const Text('Accept the terms'),
              description: const Text('You can leave at any time.'),
              child: Checkbox(value: false, onChanged: (_) {}),
            ),
          ),
        ),
      );
      final node = tester
          .getSemantics(find.byType(Checkbox))
          .getSemanticsData();
      expect(node.label, contains('Accept the terms'));
      expect(node.label, contains('You can leave at any time.'));
      semantics.dispose();
    });

    testWidgets('an input in a field is named by its label', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          const SizedBox(
            width: 300,
            child: Field(
              label: Text('Email'),
              error: Text('Enter an email'),
              child: Input(placeholder: 'you@solutech.co.ke'),
            ),
          ),
        ),
      );
      // What a screen reader gets: the field with everything merged into it.
      final node = tester
          .getSemantics(find.byType(EditableText))
          .getSemanticsData();
      expect(node.label, contains('Email'));
      expect(node.label, contains('Enter an email'));
      expect(node.flagsCollection.isTextField, isTrue);
      semantics.dispose();
    });
  });

  testWidgets('a textarea starts three lines tall and grows with its text', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const SizedBox(width: 300, child: Textarea(placeholder: 'Note'))),
    );
    final start = tester.getSize(find.byType(Textarea)).height;
    await tester.enterText(
      find.byType(EditableText),
      List.filled(6, 'line').join('\n'),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(Textarea)).height, greaterThan(start));
    await tester.enterText(
      find.byType(EditableText),
      List.filled(20, 'line').join('\n'),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

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

  group('Tabs', () {
    final tabs = [
      const TabItem(label: Text('Account'), content: Text('Account form')),
      const TabItem(label: Text('Password'), content: Text('Password form')),
      const TabItem(
        label: Text('Billing'),
        content: Text('Billing form'),
        enabled: false,
      ),
      const TabItem(label: Text('Team'), content: Text('Team form')),
    ];

    testWidgets('a tap shows its panel', (tester) async {
      await tester.pumpWidget(app(Tabs(tabs: tabs)));
      expect(find.text('Account form'), findsOneWidget);
      await tester.tap(find.text('Password'));
      await tester.pump();
      expect(find.text('Password form'), findsOneWidget);
      expect(find.text('Account form'), findsNothing);
    });

    testWidgets(
      'the arrow keys move along, skipping a disabled tab and wrapping',
      (tester) async {
        final seen = <int>[];
        await tester.pumpWidget(app(Tabs(tabs: tabs, onChanged: seen.add)));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        for (var i = 0; i < 3; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
        }
        expect(seen, [1, 3, 0]);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        expect(find.text('Team form'), findsOneWidget);
      },
    );

    testWidgets('Tab reaches only the chosen tab, then leaves the row', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tabs(tabs: tabs, initialIndex: 1),
              Button(onPressed: () {}, child: const Text('After')),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(
        find
                .ancestor(
                  of: find.byElementPredicate((e) => e == focused),
                  matching: find.byType(Button),
                )
                .evaluate()
                .isNotEmpty ||
            focused.findAncestorWidgetOfExactType<Button>() != null,
        isTrue,
      );
    });

    testWidgets('a screen reader hears tabs, and which is selected', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(app(Tabs(tabs: tabs)));
      final node = tester.getSemantics(find.text('Account'));
      expect(node.role, SemanticsRole.tab);
      expect(node.flagsCollection.isSelected, Tristate.isTrue);
      expect(
        tester.getSemantics(find.text('Password')).flagsCollection.isSelected,
        Tristate.isFalse,
      );
      semantics.dispose();
    });
  });

  group('Dropdown Menu', () {
    Future<List<String>> open(WidgetTester tester) async {
      final picked = <String>[];
      await tester.pumpWidget(
        app(
          DropdownMenu(
            builder: (context, menu) =>
                Button(onPressed: menu.open, child: const Text('Open')),
            items: [
              const MenuLabel(child: Text('My account')),
              MenuItem(
                onPressed: () => picked.add('profile'),
                child: const Text('Profile'),
              ),
              MenuItem(onPressed: null, child: const Text('Billing')),
              const MenuSeparator(),
              MenuItem(
                destructive: true,
                onPressed: () => picked.add('out'),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
      return picked;
    }

    testWidgets('a tap on an item calls it and closes the menu', (
      tester,
    ) async {
      final picked = await open(tester);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(picked, ['out']);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('the arrow keys skip a disabled item; Enter picks', (
      tester,
    ) async {
      final picked = await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, ['out']);
    });

    testWidgets('Escape and a tap outside close it', (tester) async {
      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('it opens under the trigger and stays on screen', (
      tester,
    ) async {
      await open(tester);
      final trigger = tester.getRect(find.byType(Button));
      final menu = tester.getRect(find.byType(MenuList));
      expect(menu.top, greaterThanOrEqualTo(trigger.bottom));
      expect(menu.left, closeTo(trigger.left, 1));
    });
  });

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

  group('Popover', () {
    testWidgets('opens, takes focus, and Escape closes it', (tester) async {
      await tester.pumpWidget(
        app(
          Popover(
            builder: (context, menu) =>
                Button(onPressed: menu.open, child: const Text('Dimensions')),
            content: (context) =>
                const SizedBox(width: 200, child: Input(placeholder: 'Width')),
          ),
        ),
      );
      await tester.tap(find.text('Dimensions'));
      await tester.pumpAndSettle();
      expect(find.text('Width'), findsOneWidget);
      await tester.tap(find.byType(Input));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Width'), findsNothing);
    });

    testWidgets('scrolls when its content is taller than the room', (
      tester,
    ) async {
      await tester.pumpWidget(
        AshlarApp(
          home: Center(
            child: Popover(
              builder: (context, menu) =>
                  Button(onPressed: menu.open, child: const Text('Open')),
              content: (context) =>
                  const SizedBox(height: 2000, child: Text('Tall')),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getRect(panel()).bottom, lessThanOrEqualTo(600));
    });

    testWidgets('flips above when there is no room below', (tester) async {
      await tester.pumpWidget(
        AshlarApp(
          home: Align(
            alignment: Alignment.bottomCenter,
            child: Popover(
              builder: (context, menu) =>
                  Button(onPressed: menu.open, child: const Text('Open')),
              content: (context) =>
                  const SizedBox(height: 200, child: Text('Panel')),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(panel()).bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(Button)).top),
      );
    });
  });

  group('Tooltip', () {
    Widget tip() => Tooltip(
      message: 'Add to library',
      child: Button(
        semanticLabel: 'Add',
        onPressed: () {},
        child: const Text('+'),
      ),
    );

    testWidgets('shows on hover', (tester) async {
      await tester.pumpWidget(app(tip()));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('+')));
      await tester.pumpAndSettle();
      expect(find.text('Add to library'), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Add to library'), findsNothing);
    });

    testWidgets('shows on keyboard focus', (tester) async {
      await tester.pumpWidget(app(tip()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(find.text('Add to library'), findsOneWidget);
    });

    testWidgets('a screen reader hears the message', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(app(tip()));
      final node = tester.getSemantics(find.text('+')).getSemanticsData();
      expect(node.label, 'Add');
      expect(node.tooltip, 'Add to library');
      expect(node.flagsCollection.isButton, isTrue);
      semantics.dispose();
    });
  });

  group('Toast', () {
    testWidgets('shows, then goes by itself', (tester) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Button(
              onPressed: () => showToast(
                context,
                title: 'Payment sent',
                description: 'KES 2,400',
              ),
              child: const Text('Pay'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();
      expect(find.text('Payment sent'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Payment sent'), findsNothing);
    });

    testWidgets('keeps the newest three', (tester) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) {
              var n = 0;
              return Button(
                onPressed: () => showToast(context, title: 'Toast ${++n}'),
                child: const Text('Go'),
              );
            },
          ),
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Go'));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
      expect(find.text('Toast 1'), findsNothing);
      expect(find.text('Toast 4'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('a swipe sends it away', (tester) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Button(
              onPressed: () => showToast(
                context,
                title: 'Swipe me',
                duration: const Duration(minutes: 1),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.fling(find.text('Swipe me'), const Offset(400, 0), 2000);
      await tester.pumpAndSettle();
      expect(find.text('Swipe me'), findsNothing);
    });
  });

  testWidgets(
    'the display pieces lay out in light and dark, and leave the timers clean',
    (tester) async {
      for (final mode in AshlarThemeMode.values) {
        await tester.pumpWidget(
          app(
            const SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Alert(
                    title: Text('Heads up'),
                    description: Text('Something to know.'),
                  ),
                  Alert(
                    variant: AlertVariant.destructive,
                    title: Text('Declined'),
                  ),
                  Avatar(fallback: 'WM', semanticLabel: 'Wanjiru Mwangi'),
                  Skeleton(width: 120),
                  Spinner(),
                  Kbd(child: Text('Esc')),
                ],
              ),
            ),
            mode: mode,
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'a spinner and an avatar are named for screen readers; a skeleton is not read',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Spinner(),
              Avatar(fallback: 'WM', semanticLabel: 'Wanjiru Mwangi'),
              Skeleton(width: 40),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      expect(find.bySemanticsLabel('Wanjiru Mwangi'), findsOneWidget);
      expect(find.bySemanticsLabel('WM'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );
}
