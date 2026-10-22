// Tests for Sources. Copied into your app by `ashlar add sources` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/sources.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(
  home: Padding(padding: const EdgeInsets.all(16), child: child),
);

const _sources = [
  Source(title: 'Returns policy', url: 'https://www.shop.co.ke/returns'),
  Source(title: 'Order 1042', detail: 'Orders, 12 October'),
];

void main() {
  group('Sources', () {
    testWidgets('counts its sources and opens to list them', (tester) async {
      await tester.pumpWidget(app(const Sources(sources: _sources)));
      expect(find.text('Used 2 sources'), findsOneWidget);
      expect(find.text('Returns policy').hitTestable(), findsNothing);
      await tester.tap(find.text('Used 2 sources'));
      await tester.pumpAndSettle();
      expect(find.text('Returns policy').hitTestable(), findsOneWidget);
      // Where it is from, taken from its address when not given.
      expect(find.text('shop.co.ke'), findsOneWidget);
      expect(find.text('Orders, 12 October'), findsOneWidget);
    });

    testWidgets('gives back the source tapped', (tester) async {
      Source? opened;
      await tester.pumpWidget(
        app(
          Sources(
            sources: _sources,
            initiallyOpen: true,
            onOpen: (s) => opened = s,
          ),
        ),
      );
      await tester.tap(find.text('Order 1042'));
      expect(opened?.title, 'Order 1042');
    });

    testWidgets('reads each source with its number', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        app(const Sources(sources: _sources, initiallyOpen: true)),
      );
      expect(
        find.bySemanticsLabel('1. Returns policy, shop.co.ke'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('a Citation opens its source, and says which', (tester) async {
      final handle = tester.ensureSemantics();
      var opened = 0;
      await tester.pumpWidget(
        app(Citation(2, title: 'Order 1042', onPressed: () => opened++)),
      );
      expect(find.text('2'), findsOneWidget);
      expect(find.bySemanticsLabel('Source 2, Order 1042'), findsOneWidget);
      await tester.tap(find.text('2'));
      expect(opened, 1);
      handle.dispose();
    });
  });
}
