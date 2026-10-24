// Tests for Ticket. Copied into your app by `ashlar add ticket` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/ticket.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: SizedBox(width: 320, child: child)),
    );

void main() {
  testWidgets('a ticket lays out in light and dark', (tester) async {
    for (final mode in AshlarThemeMode.values) {
      await tester.pumpWidget(
        app(
          const Ticket(top: Text('SFO to NRT'), bottom: Text('Seat 14A')),
          mode: mode,
        ),
      );
      expect(find.text('SFO to NRT'), findsOneWidget);
      expect(find.text('Seat 14A'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the bites sit where the two halves meet, whatever they hold', (
    tester,
  ) async {
    for (final lines in [1, 4]) {
      await tester.pumpWidget(
        app(
          Ticket(
            top: Text(List.filled(lines, 'Line').join('\n')),
            bottom: const Text('Seat 14A'),
          ),
        ),
      );
      final halves = find.descendant(
        of: find.byType(Ticket),
        matching: find.byType(DecoratedBox),
      );
      final upper = tester.widget<DecoratedBox>(halves.first).decoration;
      final lower = tester.widget<DecoratedBox>(halves.last).decoration;
      expect(((upper as ShapeDecoration).shape as TicketHalf).upper, isTrue);
      expect(((lower as ShapeDecoration).shape as TicketHalf).upper, isFalse);
      // The join is the upper half's bottom and the lower half's top: no gap between.
      expect(
        tester.getBottomLeft(halves.first).dy,
        tester.getTopLeft(halves.last).dy,
      );
    }
  });

  testWidgets('a bite is cut from each side at the join', (tester) async {
    const half = TicketHalf(upper: true, bite: 10);
    const rect = Rect.fromLTWH(0, 0, 200, 100);
    final path = half.getOuterPath(rect);
    // Just inside the side at the join is bitten away; higher up the side is card.
    expect(path.contains(const Offset(2, 98)), isFalse);
    expect(path.contains(const Offset(198, 98)), isFalse);
    expect(path.contains(const Offset(2, 50)), isTrue);
    expect(path.contains(const Offset(100, 98)), isTrue);
  });
}
