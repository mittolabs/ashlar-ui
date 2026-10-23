// Tests for Typography. Copied into your app by `ashlar add typography` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: child),
    );

Widget app2(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  testWidgets('headings are announced as headings', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            H1('Title'),
            H2('Section'),
            H3('Part'),
            H4('Small'),
            P('Text'),
            Lead('Lead'),
            Large('Large'),
            Small('Small note'),
            Muted('Muted'),
            Blockquote('Quote'),
            InlineCode('code'),
            BulletList(['One', 'Two']),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    for (final h in ['Title', 'Section', 'Part', 'Small']) {
      expect(
        tester.getSemantics(find.text(h)).flagsCollection.isHeader,
        isTrue,
        reason: h,
      );
    }
    expect(
      tester.getSemantics(find.text('Text')).flagsCollection.isHeader,
      isFalse,
    );
    semantics.dispose();
  });

  testWidgets('a typography table', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app2(
        const SizedBox(
          width: 400,
          child: TypographyTable(
            headings: ['County', 'People'],
            rows: [
              ['Tokyo', '37.4m'],
              ['Lagos', '15.9m'],
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
    expect(find.text('Lagos'), findsOneWidget);
    semantics.dispose();
  });
}
