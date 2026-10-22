// Tests for Soundwave. Copied into your app by `ashlar add soundwave` with the component:
// they check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/soundwave.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(
  home: Center(child: SizedBox(width: 200, child: child)),
);

void main() {
  group('Soundwave', () {
    testWidgets('draws as tall as it is told', (tester) async {
      await tester.pumpWidget(
        app(const Soundwave(levels: [0, .5, 1], height: 40)),
      );
      expect(tester.getSize(find.byType(Soundwave)), const Size(200, 40));
    });

    testWidgets('draws silence and more levels than fit', (tester) async {
      await tester.pumpWidget(app(const Soundwave(levels: [])));
      await tester.pumpWidget(
        app(Soundwave(levels: [for (var i = 0; i < 500; i++) (i % 10) / 10])),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('is one picture to a screen reader, named', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        app(const Soundwave(levels: [.2, .8], semanticLabel: 'Listening')),
      );
      expect(
        tester.getSemantics(find.byType(Soundwave)),
        matchesSemantics(label: 'Listening', isImage: true),
      );
      handle.dispose();
    });
  });
}
