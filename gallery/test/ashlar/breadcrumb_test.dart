// Tests for Breadcrumb. Copied into your app by `ashlar add breadcrumb` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/breadcrumb.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: child),
    );

Widget app2(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  group('Breadcrumb', () {
    testWidgets('the steps above are links; the page itself is not', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final went = <String>[];
      await tester.pumpWidget(
        app(
          Breadcrumb(
            items: [
              BreadcrumbItem('Home', onPressed: () => went.add('home')),
              BreadcrumbItem('Docs', onPressed: () => went.add('docs')),
              const BreadcrumbItem('Breadcrumb'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Docs'));
      expect(went, ['docs']);
      final docs = tester.getSemantics(find.text('Docs')).getSemanticsData();
      expect(docs.flagsCollection.isLink, isTrue);
      expect(docs.flagsCollection.isButton, isFalse);
      final here = tester
          .getSemantics(find.text('Breadcrumb'))
          .getSemanticsData();
      expect(here.flagsCollection.isLink, isFalse);
      semantics.dispose();
    });
  });

  testWidgets('a long breadcrumb folds its middle into a menu', (tester) async {
    final semantics = tester.ensureSemantics();
    final went = <String>[];
    await tester.pumpWidget(
      app2(
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
}
