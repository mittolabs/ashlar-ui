// Tests for Input Otp. Copied into your app by `ashlar add input-otp` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/input_otp.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  group('Input OTP', () {
    testWidgets(
      'fills a box per digit, ignores letters and reports the whole code',
      (tester) async {
        final semantics = tester.ensureSemantics();
        String? done;
        await tester.pumpWidget(
          app(InputOtp(groups: const [3, 3], onCompleted: (c) => done = c)),
        );
        await tester.tap(find.byType(InputOtp));
        await tester.enterText(find.byType(EditableText), '12a3');
        await tester.pump();
        for (final d in ['1', '2', '3']) {
          expect(find.text(d), findsOneWidget);
        }
        expect(find.text('a'), findsNothing);
        expect(done, isNull);
        // Pasted whole, or filled in from a text message.
        await tester.enterText(find.byType(EditableText), '482913');
        await tester.pump();
        expect(done, '482913');
        final node = tester
            .getSemantics(find.byType(EditableText))
            .getSemanticsData();
        expect(node.label, contains('One-time code'));
        expect(node.flagsCollection.isTextField, isTrue);
        semantics.dispose();
      },
    );

    testWidgets('stops at its length', (tester) async {
      await tester.pumpWidget(app(const InputOtp(length: 4)));
      await tester.tap(find.byType(InputOtp));
      await tester.enterText(find.byType(EditableText), '123456');
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '1234',
      );
    });
  });
}
