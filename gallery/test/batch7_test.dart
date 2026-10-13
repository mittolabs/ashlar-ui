// Command, combobox, menubar, navigation menu and carousel, as an app gets them from lib/ui.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/carousel.dart';
import 'package:ashlar_ui_gallery/ui/combobox.dart';
import 'package:ashlar_ui_gallery/ui/command.dart';
import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';
import 'package:ashlar_ui_gallery/ui/menubar.dart';
import 'package:ashlar_ui_gallery/ui/navigation_menu.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  group('Command', () {
    Future<List<String>> command(WidgetTester tester) async {
      final picked = <String>[];
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 400,
            child: Command(
              groups: [
                CommandGroup(heading: 'Suggestions', [
                  CommandItem(
                    'Calendar',
                    onSelected: () => picked.add('calendar'),
                  ),
                  CommandItem(
                    'Calculator',
                    enabled: false,
                    onSelected: () => picked.add('calculator'),
                  ),
                  CommandItem(
                    'Search emoji',
                    onSelected: () => picked.add('emoji'),
                  ),
                ]),
                CommandGroup(heading: 'Settings', [
                  CommandItem(
                    'Billing',
                    keywords: ['invoice', 'payment'],
                    onSelected: () => picked.add('billing'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      return picked;
    }

    testWidgets('typing narrows the list, by label or keyword', (tester) async {
      await command(tester);
      await tester.enterText(find.byType(EditableText), 'cal');
      await tester.pump();
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Search emoji'), findsNothing);
      expect(find.text('Settings'), findsNothing);
      await tester.enterText(find.byType(EditableText), 'invoice');
      await tester.pump();
      expect(find.text('Billing'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pump();
      expect(find.text('No results found.'), findsOneWidget);
    });

    testWidgets(
      'the arrows move the highlight past what is off, Enter picks, and the box keeps the typing',
      (tester) async {
        final semantics = tester.ensureSemantics();
        final picked = await command(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(find.bySemanticsLabel('Search emoji'), findsWidgets);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(picked, ['emoji']);
        expect(
          FocusManager.instance.primaryFocus!.context!
              .findAncestorWidgetOfExactType<EditableText>(),
          isNotNull,
        );
        semantics.dispose();
      },
    );

    testWidgets('as a dialog, picking closes it first', (tester) async {
      final picked = <String>[];
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Button(
              onPressed: () => showCommandDialog(
                context: context,
                groups: [
                  CommandGroup([
                    CommandItem(
                      'Profile',
                      onSelected: () => picked.add('profile'),
                    ),
                  ]),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, ['profile']);
      expect(find.text('Profile'), findsNothing);
    });
  });

  testWidgets(
    'in a short space, its list shrinks rather than overflow',
    (tester) async {
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
    },
  );

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
              placeholder: 'Choose a county',
              semanticLabel: 'County',
              options: const [
                ComboboxOption('nbo', 'Nairobi'),
                ComboboxOption('msa', 'Mombasa'),
                ComboboxOption('ksm', 'Kisumu'),
              ],
              onChanged: (v) => set(() => value = v),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Choose a county'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'mom');
    await tester.pump();
    expect(find.text('Nairobi'), findsNothing);
    await tester.tap(find.text('Mombasa'));
    await tester.pumpAndSettle();
    expect(value, 'msa');
    expect(find.text('Kisumu'), findsNothing);
    final node = tester.getSemantics(find.text('Mombasa')).getSemanticsData();
    expect(node.label, 'County');
    expect(node.value, 'Mombasa');
    semantics.dispose();
  });

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

  testWidgets(
    'a navigation menu opens on hover after a moment; its links close it',
    (tester) async {
      final went = <String>[];
      await tester.pumpWidget(
        app(
          NavigationMenu(
            items: [
              NavigationMenuItem(
                'Components',
                content: (context) => NavigationMenuLink(
                  title: 'Button',
                  description: 'Six variants.',
                  onPressed: () => went.add('button'),
                ),
              ),
              NavigationMenuItem.link(
                'Docs',
                onPressed: () => went.add('docs'),
              ),
            ],
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Components')));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Six variants.'), findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Six variants.'), findsOneWidget);
      await mouse.moveTo(tester.getCenter(find.text('Button')));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Button'));
      await tester.pumpAndSettle();
      expect(went, ['button']);
      expect(find.text('Six variants.'), findsNothing);
      await tester.tap(find.text('Docs'));
      expect(went, ['button', 'docs']);
    },
  );

  testWidgets(
    'a carousel moves by its buttons and arrow keys, and says which slide shows',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 500,
            height: 200,
            child: Carousel(
              children: [for (var i = 1; i <= 4; i++) Text('Card $i')],
            ),
          ),
        ),
      );
      await tester.tap(
        find.bySemanticsLabel('Previous slide'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('Card 1').hitTestable(), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Next slide'));
      await tester.pumpAndSettle();
      expect(find.text('Card 2').hitTestable(), findsOneWidget);
      expect(find.bySemanticsLabel('Carousel'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Carousel'))
            .getSemanticsData()
            .value,
        'Slide 2 of 4',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Card 3').hitTestable(), findsOneWidget);
      semantics.dispose();
    },
  );
}
