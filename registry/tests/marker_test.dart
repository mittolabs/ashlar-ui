// Tests for Marker. Copied into your app by `ashlar add marker` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/marker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    AshlarApp(
      builder: (context, page) =>
          Directionality(textDirection: direction, child: page!),
      home: child,
    );

void main() {
  testWidgets('a separator marker has a line either side of its words', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const SizedBox(
          width: 400,
          child: Marker(variant: MarkerVariant.separator, child: Text('Today')),
        ),
      ),
    );
    final lines = find.descendant(
      of: find.byType(Marker),
      matching: find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxHeight == 1,
      ),
    );
    expect(lines, findsNWidgets(2));
    final text = tester.getRect(find.text('Today'));
    expect(tester.getRect(lines.first).right, lessThan(text.left));
    expect(tester.getRect(lines.last).left, greaterThan(text.right));
  });
}
