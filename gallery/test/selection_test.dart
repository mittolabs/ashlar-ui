// Text selection in AshlarApp, as an app gets it from lib/ui.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/context_menu.dart';
import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';
import 'package:ashlar_ui_gallery/ui/selection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String? copied;

  setUp(() => copied = null);

  Future<void> page(WidgetTester tester, {bool? selectable}) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await tester.pumpWidget(
      AshlarApp(
        selectable: selectable,
        home: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Paid KES 2,400 to Wanjiru'),
              const SizedBox(height: 40),
              Button(onPressed: () {}, child: const Text('Save changes')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> dragAcross(WidgetTester tester, Finder text) async {
    final r = tester.getRect(text);
    final mouse = await tester.startGesture(
      r.centerLeft + const Offset(1, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await mouse.moveTo(r.centerRight - const Offset(1, 0));
    await tester.pump();
    await mouse.up();
    await tester.pump();
  }

  Future<void> copy(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
  }

  testWidgets('dragging across text selects it, and it copies', (tester) async {
    await page(tester, selectable: true);
    await dragAcross(tester, find.text('Paid KES 2,400 to Wanjiru'));
    await copy(tester);
    expect(copied, 'Paid KES 2,400 to Wanjiru');
  });

  testWidgets('a drag over a button selects nothing', (tester) async {
    await page(tester, selectable: true);
    await dragAcross(tester, find.text('Save changes'));
    await copy(tester);
    expect(copied, anyOf(isNull, isEmpty));
  });

  testWidgets(
    'on by default on the desktop, off on phones, and either when asked',
    (tester) async {
      for (final (platform, on) in [
        (TargetPlatform.macOS, true),
        (TargetPlatform.windows, true),
        (TargetPlatform.android, false),
        (TargetPlatform.iOS, false),
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        await page(tester);
        expect(
          find.byType(SelectableRegion),
          on ? findsOneWidget : findsNothing,
          reason: '$platform',
        );
      }
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await page(tester, selectable: true);
      expect(find.byType(SelectableRegion), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'a right-click in a context menu opens the menu and selects nothing',
    (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      await tester.pumpWidget(
        AshlarApp(
          selectable: true,
          home: Center(
            child: ContextMenu(
              items: [MenuItem(onPressed: () {}, child: const Text('Reload'))],
              child: const SizedBox(
                width: 300,
                height: 150,
                child: Center(child: Text('Right-click here')),
              ),
            ),
          ),
        ),
      );
      await tester.tapAt(
        tester.getCenter(find.text('Right-click here')),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      expect(find.text('Reload'), findsOneWidget);
      await copy(tester);
      expect(copied, anyOf(isNull, isEmpty));
    },
  );

  testWidgets('touch handles show on phones, never on the desktop', (
    tester,
  ) async {
    final controls = AshlarSelectionControls(const Color(0xFF000000));
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (c) => SizedBox(
          key: GlobalKey(),
          child: Builder(
            builder: (cc) {
              context = cc;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    for (final (platform, shown) in [
      (TargetPlatform.macOS, false),
      (TargetPlatform.windows, false),
      (TargetPlatform.iOS, true),
      (TargetPlatform.android, true),
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      expect(
        controls.getHandleSize(20) != Size.zero,
        shown,
        reason: '$platform',
      );
      expect(
        (controls.buildHandle(
              context,
              TextSelectionHandleType.left,
              20,
            ) as SizedBox).child !=
            null,
        shown,
        reason: '$platform',
      );
    }
    debugDefaultTargetPlatformOverride = null;
  });
}
