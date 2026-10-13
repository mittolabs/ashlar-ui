// Tests for Pagination. Copied into your app by `ashlar add pagination` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/pagination.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  group('Pagination', () {
    testWidgets('shows the first, the last and the pages near this one', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var page = 5;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Pagination(
              page: page,
              pageCount: 12,
              onChanged: (p) => set(() => page = p),
            ),
          ),
        ),
      );
      for (final p in ['1', '4', '5', '6', '12']) {
        expect(find.text(p), findsOneWidget, reason: p);
      }
      expect(find.text('2'), findsNothing);
      expect(find.bySemanticsLabel('More pages'), findsNWidgets(2));
      expect(find.bySemanticsLabel('Page 5, current page'), findsOneWidget);
      await tester.tap(find.text('6'));
      await tester.pump();
      expect(page, 6);
      await tester.tap(find.text('Previous'));
      await tester.pump();
      expect(page, 5);
      semantics.dispose();
    });

    testWidgets('Previous is off on the first page, Next on the last', (
      tester,
    ) async {
      var page = 1;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Pagination(
              page: page,
              pageCount: 3,
              onChanged: (p) => set(() => page = p),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Previous'), warnIfMissed: false);
      await tester.pump();
      expect(page, 1);
      expect(find.text('2'), findsOneWidget);
    });
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
}
