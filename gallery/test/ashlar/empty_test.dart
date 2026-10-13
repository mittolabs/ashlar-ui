// Tests for Empty. Copied into your app by `ashlar add empty` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/empty.dart';
import 'package:ashlar_ui_gallery/ui/item.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: child),
    );

Widget app2(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  testWidgets('empty and item lay out in light and dark', (tester) async {
    for (final mode in AshlarThemeMode.values) {
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Empty(
                  title: const Text('No projects'),
                  description: const Text('Create one.'),
                  actions: [
                    Button(onPressed: () {}, child: const Text('Create')),
                  ],
                ),
                for (final v in ItemVariant.values)
                  Item(
                    variant: v,
                    title: const Text('Title'),
                    description: const Text('Description'),
                  ),
              ],
            ),
          ),
          mode: mode,
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('empty states on a muted ground and in a border', (tester) async {
    await tester.pumpWidget(
      app2(
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
}
