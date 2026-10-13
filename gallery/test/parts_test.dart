// Parts and options added for parity: card, field, item, breadcrumb, accordion, dialogs,
// empty, drawer, sheet, pagination, radio, resizable and typography.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:ashlar_ui_gallery/ui/accordion.dart';
import 'package:ashlar_ui_gallery/ui/alert_dialog.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/breadcrumb.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/drawer.dart';
import 'package:ashlar_ui_gallery/ui/empty.dart';
import 'package:ashlar_ui_gallery/ui/field.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/item.dart';
import 'package:ashlar_ui_gallery/ui/pagination.dart';
import 'package:ashlar_ui_gallery/ui/radio.dart';
import 'package:ashlar_ui_gallery/ui/resizable.dart';
import 'package:ashlar_ui_gallery/ui/sheet.dart';
import 'package:ashlar_ui_gallery/ui/typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  testWidgets(
    'a small card pads by 16; an image runs to its edges; a header can be lined',
    (tester) async {
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 300,
            child: Card(
              size: CardSize.sm,
              children: [
                const CardImage(
                  height: 100,
                  child: ColoredBox(color: Color(0xFF888888)),
                ),
                const CardHeader(title: Text('Title'), border: true),
                CardFooter(
                  children: [Button(onPressed: () {}, child: const Text('Go'))],
                ),
              ],
            ),
          ),
        ),
      );
      final card = tester.getRect(find.byType(Card)),
          image = tester.getRect(find.byType(CardImage));
      expect(image.top, card.top + 1);
      expect(image.width, card.width - 2);
      expect(tester.getRect(find.text('Title')).left, card.left + 1 + 16);
      expect(tester.takeException(), isNull);
    },
  );

  group('Field', () {
    testWidgets(
      'a field set reads its legend; a choice card picks on a tap anywhere',
      (tester) async {
        final semantics = tester.ensureSemantics();
        var picked = false;
        await tester.pumpWidget(
          app(
            SizedBox(
              width: 360,
              child: StatefulBuilder(
                builder: (context, set) => FieldSet(
                  legend: const Text('Plan'),
                  children: [
                    Field(
                      card: true,
                      selected: picked,
                      axis: Axis.horizontal,
                      onPressed: () => set(() => picked = !picked),
                      label: const Text('Pro'),
                      description: const Text('For teams.'),
                      child: Checkbox(
                        value: picked,
                        onChanged: (v) => set(() => picked = v),
                      ),
                    ),
                    const FieldSeparator(child: Text('or')),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(
          tester
              .getSemantics(find.text('Plan'))
              .getSemanticsData()
              .flagsCollection
              .isHeader,
          isTrue,
        );
        await tester.tap(find.text('For teams.'));
        await tester.pump();
        expect(picked, isTrue);
        expect(find.text('or'), findsOneWidget);
        semantics.dispose();
      },
    );

    testWidgets(
      'responsive: the label beside the field when wide, above it when narrow',
      (tester) async {
        for (final (width, beside) in [(600.0, true), (320.0, false)]) {
          await tester.pumpWidget(
            app(
              SizedBox(
                width: width,
                child: const Field(
                  responsive: true,
                  label: Text('Name'),
                  child: Input(placeholder: 'Wanjiru'),
                ),
              ),
            ),
          );
          final label = tester.getRect(find.text('Name')),
              input = tester.getRect(find.byType(Input));
          expect(input.left > label.right, beside, reason: '$width');
        }
      },
    );
  });

  testWidgets('item sizes, media and a group with a line between items', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 360,
          child: ItemGroup(
            children: [
              Item(
                size: ItemSize.sm,
                leading: ItemMedia.icon(
                  AshlarIcon(AshlarIconsRoundedStroke.inbox),
                ),
                title: Text('Inbox'),
              ),
              Item(
                size: ItemSize.xs,
                title: Text('Sent'),
                header: Text('Today'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(ItemSeparator), findsOneWidget);
    expect(
      tester.getSize(find.byType(Item).last).height,
      lessThan(tester.getSize(find.byType(Item).first).height + 24),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long breadcrumb folds its middle into a menu', (tester) async {
    final semantics = tester.ensureSemantics();
    final went = <String>[];
    await tester.pumpWidget(
      app(
        Breadcrumb(
          maxItems: 3,
          separator: const Text('/'),
          items: [
            for (final n in ['Home', 'Docs', 'Components', 'Forms'])
              BreadcrumbItem(n, onPressed: () => went.add(n)),
            const BreadcrumbItem('Field'),
          ],
        ),
      ),
    );
    expect(find.text('Docs'), findsNothing);
    expect(find.text('Forms'), findsOneWidget);
    expect(find.text('/'), findsNWidgets(3));
    await tester.tap(find.bySemanticsLabel('Show 2 more'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Components'));
    await tester.pumpAndSettle();
    expect(went, ['Components']);
    semantics.dispose();
  });

  testWidgets('a bordered accordion with a disabled section that stays shut', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 360,
          child: Accordion(
            bordered: true,
            items: [
              AccordionItem(title: Text('Open me'), content: Text('Opened')),
              AccordionItem(
                title: Text('Not me'),
                content: Text('Never'),
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Not me'));
    await tester.pumpAndSettle();
    expect(find.text('Never').hitTestable(), findsNothing);
    await tester.tap(find.text('Open me'));
    await tester.pumpAndSettle();
    expect(find.text('Opened').hitTestable(), findsOneWidget);
  });

  testWidgets(
    'a small alert dialog is centred, its buttons sharing the width',
    (tester) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Button(
              onPressed: () => showAlertDialog(
                context,
                title: 'Leave?',
                small: true,
                media: const AshlarIcon(AshlarIconsRoundedStroke.info),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final cancel = tester.getRect(find.text('Cancel').first),
          go = tester.getRect(find.text('Continue'));
      expect(tester.getCenter(find.text('Leave?')).dx, closeTo(400, 1));
      expect(cancel.center.dy, go.center.dy);
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('Cancel'),
                    matching: find.byType(Button),
                  )
                  .first,
            )
            .width,
        greaterThan(100),
      );
    },
  );

  testWidgets('empty states on a muted ground and in a border', (tester) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Empty(background: true, title: Text('A')),
              Empty(border: true, title: Text('B')),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Empty).first).width, 500);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a drawer from the left goes back left with a drag', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Button(
            onPressed: () => showDrawer(
              context: context,
              side: DrawerSide.left,
              builder: (_) => const Drawer(title: Text('Filters')),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(Drawer)).left, 0);
    await tester.drag(find.text('Filters'), const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsNothing);
  });

  testWidgets('a sheet without its close button', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Button(
            onPressed: () => showSheet(
              context: context,
              builder: (_) =>
                  const Sheet(title: Text('Edit'), showClose: false),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.descendant(of: find.byType(Sheet), matching: find.byType(Button)), findsNothing);
    semantics.dispose();
  });

  testWidgets('simple pagination says the page and moves', (tester) async {
    final semantics = tester.ensureSemantics();
    var page = 2;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, set) => Pagination(
            simple: true,
            page: page,
            pageCount: 10,
            onChanged: (p) => set(() => page = p),
          ),
        ),
      ),
    );
    expect(find.text('Page 2 of 10'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Next page'));
    await tester.pump();
    expect(find.text('Page 3 of 10'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('radio cards mark the chosen one', (tester) async {
    String? plan = 'pro';
    await tester.pumpWidget(
      app(
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

  testWidgets('resizable reports the shares after a move', (tester) async {
    List<double>? sizes;
    await tester.pumpWidget(
      app(
        SizedBox(
          width: 401,
          height: 100,
          child: Resizable(
            onResize: (s) => sizes = s,
            panels: const [
              ResizablePanel(child: Text('A')),
              ResizablePanel(child: Text('B')),
            ],
          ),
        ),
      ),
    );
    await tester.dragFrom(
      tester.getCenter(find.byType(Resizable)),
      const Offset(100, 0),
    );
    expect(sizes![0], closeTo(.75, .01));
  });

  testWidgets('a typography table', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 400,
          child: TypographyTable(
            headings: ['County', 'People'],
            rows: [
              ['Nairobi', '4.4m'],
              ['Mombasa', '1.2m'],
            ],
          ),
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.text('County'))
          .getSemanticsData()
          .flagsCollection
          .isHeader,
      isTrue,
    );
    expect(find.text('Mombasa'), findsOneWidget);
    semantics.dispose();
  });
}
