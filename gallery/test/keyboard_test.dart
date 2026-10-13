// With the on-screen keyboard up, dialogs, sheets and drawers sit above it.

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/dialog.dart';
import 'package:ashlar_ui_gallery/ui/drawer.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> open(WidgetTester tester, void Function(BuildContext) show) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  // A keyboard 300 tall.
  tester.view.viewInsets = const FakeViewPadding(bottom: 300);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AshlarApp(
      home: Builder(
        builder: (context) => Center(
          child: Button(
            onPressed: () => show(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a dialog with a field sits above the keyboard', (tester) async {
    await open(
      tester,
      (context) => showAshlarDialog<void>(
        context: context,
        builder: (_) => const Dialog(
          title: Text('Rename'),
          content: Input(placeholder: 'Name'),
        ),
      ),
    );
    expect(tester.getRect(find.byType(Dialog)).bottom, lessThanOrEqualTo(500));
    expect(tester.getRect(find.byType(Input)).bottom, lessThanOrEqualTo(500));
  });

  testWidgets('a drawer from the bottom rises above the keyboard', (
    tester,
  ) async {
    await open(
      tester,
      (context) => showDrawer<void>(
        context: context,
        builder: (_) => const Drawer(
          title: Text('Note'),
          content: Input(placeholder: 'Note'),
        ),
      ),
    );
    expect(tester.getRect(find.byType(Input)).bottom, lessThanOrEqualTo(500));
  });

  testWidgets('a sheet from the bottom rises above the keyboard', (
    tester,
  ) async {
    await open(
      tester,
      (context) => showSheet<void>(
        context: context,
        side: SheetSide.bottom,
        builder: (_) => const Sheet(
          title: Text('Search'),
          content: Input(placeholder: 'Search'),
        ),
      ),
    );
    expect(tester.getRect(find.byType(Input)).bottom, lessThanOrEqualTo(500));
  });
}
