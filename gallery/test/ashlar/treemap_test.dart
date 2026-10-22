// Tests for Treemap. Copied into your app by `ashlar add treemap` with the component:
// they check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:ashlar_ui_gallery/ui/treemap.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) => AshlarApp(
  themeMode: mode,
  home: Center(child: SizedBox(width: 400, child: child)),
);

typedef Spend = ({String item, String cat, double amount});

const spend = <Spend>[
  (item: 'Rent', cat: 'Home', amount: 600),
  (item: 'Power', cat: 'Home', amount: 100),
  (item: 'Fuel', cat: 'Transport', amount: 300),
];

void main() {
  testWidgets('it draws, grouped or not, in light and dark', (tester) async {
    for (final mode in AshlarThemeMode.values) {
      for (final grouped in [false, true]) {
        await tester.pumpWidget(
          app(
            Treemap<Spend>(
              data: spend,
              value: (r) => r.amount,
              name: (r) => r.item,
              group: grouped ? (r) => r.cat : null,
            ),
            mode: mode,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('the largest part takes its share of the room', (tester) async {
    ChartSelection<Spend>? chosen;
    await tester.pumpWidget(
      app(Treemap<Spend>(data: spend, value: (r) => r.amount, name: (r) => r.item, height: 200, onSelect: (s) => chosen = s)),
    );
    final box = tester.getRect(find.byType(Treemap<Spend>));
    // Rent is 60% of the whole: the left 60% of a wide box is all Rent.
    await tester.tapAt(box.centerLeft + Offset(box.width * .3, 0));
    expect(chosen?.row.item, 'Rent');
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(box.centerLeft + Offset(box.width * .3, 0));
    await tester.pump();
    expect(find.text('60.0%'), findsOneWidget);
  });
}
