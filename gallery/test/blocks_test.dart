// Blocks: every whole screen lays out at a desktop and a phone size, light and dark,
// and the forms in them check what is sent.
import 'dart:async';

import 'package:ashlar_ui_gallery/blocks/account_picker.dart';
import 'package:ashlar_ui_gallery/blocks/api_docs.dart';
import 'package:ashlar_ui_gallery/blocks/assistant_chat.dart';
import 'package:ashlar_ui_gallery/blocks/business_sign_up.dart';
import 'package:ashlar_ui_gallery/blocks/clinic.dart';
import 'package:ashlar_ui_gallery/blocks/code_review.dart';
import 'package:ashlar_ui_gallery/blocks/field_notes.dart';
import 'package:ashlar_ui_gallery/blocks/magic_link_sign_in.dart';
import 'package:ashlar_ui_gallery/blocks/member_sign_up.dart';
import 'package:ashlar_ui_gallery/blocks/newsroom.dart';
import 'package:ashlar_ui_gallery/blocks/phone_sign_in.dart';
import 'package:ashlar_ui_gallery/blocks/phone_sign_up.dart';
import 'package:ashlar_ui_gallery/blocks/rent_tracker.dart';
import 'package:ashlar_ui_gallery/blocks/salon_bookings.dart';
import 'package:ashlar_ui_gallery/blocks/school_office.dart';
import 'package:ashlar_ui_gallery/blocks/shop_dashboard.dart';
import 'package:ashlar_ui_gallery/blocks/shop_settings.dart';
import 'package:ashlar_ui_gallery/blocks/split_sign_in.dart';
import 'package:ashlar_ui_gallery/blocks/staff_handbook.dart';
import 'package:ashlar_ui_gallery/blocks/support_inbox.dart';
import 'package:ashlar_ui_gallery/blocks/team_invite.dart';
import 'package:ashlar_ui_gallery/blocks/till_pin.dart';
import 'package:ashlar_ui_gallery/blocks/wallet.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final blocks = <String, Widget Function()>{
  'account-picker': () => const AccountPicker(),
  'api-docs': () => const ApiDocs(),
  'assistant-chat': () => const AssistantChat(),
  'business-sign-up': () => const BusinessSignUp(),
  'clinic': () => const Clinic(),
  'code-review': () => const CodeReview(),
  'field-notes': () => const FieldNotes(),
  'magic-link-sign-in': () => const MagicLinkSignIn(),
  'member-sign-up': () => const MemberSignUp(),
  'newsroom': () => const Newsroom(),
  'phone-sign-in': () => const PhoneSignIn(),
  'phone-sign-up': () => const PhoneSignUp(),
  'rent-tracker': () => const RentTracker(),
  'salon-bookings': () => const SalonBookings(),
  'school-office': () => const SchoolOffice(),
  'shop-dashboard': () => const ShopDashboard(),
  'shop-settings': () => const ShopSettings(),
  'split-sign-in': () => const SplitSignIn(),
  'staff-handbook': () => const StaffHandbook(),
  'support-inbox': () => const SupportInbox(),
  'team-invite': () => const TeamInvite(),
  'till-pin': () => const TillPin(),
  'wallet': () => const Wallet(),
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

  testWidgets('a phone number is checked, then the code is asked for', (
    tester,
  ) async {
    String? sent;
    (String, String)? verified;
    await pumpAt(
      tester,
      const Size(1280, 800),
      PhoneSignIn(
        onSendCode: (p) => sent = p,
        onVerify: (p, c) => verified = (p, c),
      ),
    );
    await tester.enterText(find.byType(EditableText), '555 01');
    await tester.tap(find.text('Text me a code'));
    await tester.pump();
    expect(
      find.text('That does not look like a phone number.'),
      findsOneWidget,
    );
    expect(sent, isNull);
    await tester.enterText(find.byType(EditableText), '415 555 0123');
    await tester.tap(find.text('Text me a code'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(sent, '+14155550123');
    expect(find.text('Enter the code'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).first, '481516');
    await tester.pump();
    expect(verified, ('+14155550123', '481516'));
  });

  testWidgets('a sign-up waits for the terms, then gives the full number', (
    tester,
  ) async {
    (String, String)? got;
    await pumpAt(
      tester,
      const Size(1280, 900),
      PhoneSignUp(onSignUp: (n, p) => got = (n, p)),
    );
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'Maya Thompson');
    await tester.enterText(fields.at(1), '(415) 555-0123');
    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(find.text('Agree to the terms to carry on.'), findsOneWidget);
    expect(got, isNull);
    await tester.tap(find.bySemanticsLabel('I agree to the terms'));
    await tester.pump();
    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(got, ('Maya Thompson', '+14155550123'));
  });

  testWidgets('a picture shows beside the form only where there is room', (
    tester,
  ) async {
    const picture = ColoredBox(color: Color(0xFF123456));
    await pumpAt(
      tester,
      const Size(1280, 800),
      const SplitSignIn(picture: picture),
    );
    expect(find.byWidget(picture), findsOneWidget);
    await pumpAt(
      tester,
      const Size(390, 844),
      const SplitSignIn(picture: picture),
    );
    expect(find.byWidget(picture), findsNothing);
  });

  // The sidebar on screen, by its panel.
  double sidebar(WidgetTester tester) =>
      tester.getRect(find.bySemanticsLabel('Sidebar').first).width;

  testWidgets('a header above the sidebar still folds it', (tester) async {
    await pumpAt(tester, const Size(1280, 800), const RentTracker());
    final semantics = tester.ensureSemantics();
    expect(sidebar(tester), 256);
    await tester.tap(find.bySemanticsLabel('Show or hide the sidebar'));
    await tester.pumpAndSettle();
    expect(sidebar(tester), 48);
    semantics.dispose();
  });

  testWidgets('the settings open in a dialog and switch section', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1280, 800), const ShopSettings());
    await tester.tap(find.text('Shop settings'));
    await tester.pumpAndSettle();
    expect(find.text('Payout account'), findsOneWidget);
    await tester.tap(find.text('Staff'));
    await tester.pump();
    expect(find.text('Largest discount'), findsOneWidget);
    expect(find.text('Payout account'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a folder opens onto its files, and a file is picked', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1280, 800), const CodeReview());
    // Listed once under Changed; the test folder starts closed.
    expect(find.text('checkout_test.dart'), findsOneWidget);
    await tester.tap(find.text('test'));
    await tester.pump();
    expect(find.text('checkout_test.dart'), findsNWidgets(2));
    await tester.tap(find.text('checkout_test.dart').last);
    await tester.pump();
    expect(find.textContaining('test/checkout_test.dart'), findsWidgets);
  });

  testWidgets('unanswered only hides the tickets already answered', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1280, 800), const SupportInbox());
    expect(find.text('Refund not received'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Unanswered only'));
    await tester.pump();
    expect(find.text('Refund not received'), findsNothing);
    expect(find.text('Driver asked me to pay again'), findsOneWidget);
  });

  testWidgets('a question is asked, its answer streams in, and stop ends it', (
    tester,
  ) async {
    final pieces = StreamController<String>();
    String? asked;
    await pumpAt(
      tester,
      const Size(1280, 800),
      AssistantChat(
        answer: (q) {
          asked = q;
          return pieces.stream;
        },
      ),
    );
    // The conversation it opens with, folded where it should be.
    expect(find.text('Thought for 4 seconds'), findsOneWidget);
    expect(find.text('Used 2 sources'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'Message the customers');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Send'));
    // The new turn is brought near the top over a few frames.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(asked, 'Message the customers');
    expect(find.text('Thinking…'), findsOneWidget);
    pieces.add('Sent to ');
    await tester.pump(const Duration(milliseconds: 100));
    pieces.add('all three.');
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.textContaining('Sent to all three.', findRichText: true),
      findsOneWidget,
    );
    // Stopped mid-answer: what came is kept, and the box sends again.
    await tester.tap(find.bySemanticsLabel('Stop'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.bySemanticsLabel('Send'), findsOneWidget);
    // Stop cancelled the answer, so nothing listens for the close.
    unawaited(pieces.close());
  });

  testWidgets('the balance hides at a tap, to the eye and the ear', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpAt(tester, const Size(390, 844), const Wallet());
    expect(find.bySemanticsLabel('USD 2,435.00'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Hide the balance'));
    await tester.pump();
    expect(find.bySemanticsLabel('Balance hidden'), findsOneWidget);
    expect(find.textContaining('2,435', findRichText: true), findsNothing);
    handle.dispose();
  });
}
