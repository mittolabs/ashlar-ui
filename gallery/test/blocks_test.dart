// Blocks: every whole screen lays out at a desktop and a phone size, light and dark,
// and the forms in them check what is sent.
import 'package:ashlar_ui_gallery/blocks/dashboard_01.dart';
import 'package:ashlar_ui_gallery/blocks/login_01.dart';
import 'package:ashlar_ui_gallery/blocks/login_02.dart';
import 'package:ashlar_ui_gallery/blocks/login_03.dart';
import 'package:ashlar_ui_gallery/blocks/login_04.dart';
import 'package:ashlar_ui_gallery/blocks/login_05.dart';
import 'package:ashlar_ui_gallery/blocks/signup_01.dart';
import 'package:ashlar_ui_gallery/blocks/signup_02.dart';
import 'package:ashlar_ui_gallery/blocks/signup_03.dart';
import 'package:ashlar_ui_gallery/blocks/signup_04.dart';
import 'package:ashlar_ui_gallery/blocks/signup_05.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final blocks = <String, Widget Function()>{
  'dashboard-01': () => const Dashboard01(),
  'login-01': () => const Login01(),
  'login-02': () => const Login02(),
  'login-03': () => const Login03(),
  'login-04': () => const Login04(),
  'login-05': () => const Login05(),
  'signup-01': () => const Signup01(),
  'signup-02': () => const Signup02(),
  'signup-03': () => const Signup03(),
  'signup-04': () => const Signup04(),
  'signup-05': () => const Signup05(),
};

Future<void> pumpAt(
  WidgetTester tester,
  Size size,
  Widget page, {
  AshlarThemeMode mode = AshlarThemeMode.light,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(AshlarApp(themeMode: mode, home: page));
  await tester.pump(const Duration(seconds: 1));
}

Finder input(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(EditableText),
);

void main() {
  for (final MapEntry(key: name, value: build) in blocks.entries) {
    for (final (label, size) in [
      ('desktop', const Size(1280, 800)),
      ('phone', const Size(390, 844)),
    ]) {
      for (final mode in [AshlarThemeMode.light, AshlarThemeMode.dark]) {
        testWidgets('$name lays out on a $label, ${mode.name}', (tester) async {
          await pumpAt(tester, size, build(), mode: mode);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('a login says what is wrong, then gives what is right', (
    tester,
  ) async {
    (String, String)? got;
    await pumpAt(
      tester,
      const Size(1280, 800),
      Login01(onLogin: (e, p) => got = (e, p)),
    );
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(got, isNull);
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'ama@solutech.co.ke');
    await tester.enterText(fields.at(1), 'brick-by-brick');
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(got, ('ama@solutech.co.ke', 'brick-by-brick'));
  });

  testWidgets('a sign-up wants the two passwords to match', (tester) async {
    (String, String, String)? got;
    await pumpAt(
      tester,
      const Size(1280, 1000),
      Signup01(onSignUp: (n, e, p) => got = (n, e, p)),
    );
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'Ama Owusu');
    await tester.enterText(fields.at(1), 'ama@solutech.co.ke');
    await tester.enterText(fields.at(2), 'brick-by-brick');
    await tester.enterText(fields.at(3), 'brick-by-stone');
    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));
    await tester.pump();
    expect(find.text('The passwords do not match.'), findsOneWidget);
    expect(got, isNull);
    await tester.enterText(fields.at(3), 'brick-by-brick');
    await tester.pump();
    expect(find.text('The passwords do not match.'), findsNothing);
    await tester.tap(find.text('Create Account'));
    await tester.pump();
    expect(got, ('Ama Owusu', 'ama@solutech.co.ke', 'brick-by-brick'));
  });

  testWidgets('a picture shows beside the form only where there is room', (
    tester,
  ) async {
    const picture = ColoredBox(color: Color(0xFF123456));
    await pumpAt(
      tester,
      const Size(1280, 800),
      const Login02(picture: picture),
    );
    expect(find.byWidget(picture), findsOneWidget);
    await pumpAt(tester, const Size(390, 844), const Login02(picture: picture));
    expect(find.byWidget(picture), findsNothing);
  });
}
