// Tests for Time Picker. Copied into your app by `ashlar add time-picker` with the component:
// they check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/time_picker.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

/// A picker that keeps what is picked, starting at [start].
Future<List<ClockTime>> pump(
  WidgetTester tester, {
  ClockTime? start,
  bool use24Hour = true,
  int minuteStep = 5,
}) async {
  final picked = <ClockTime>[];
  var value = start;
  await tester.pumpWidget(
    app(
      StatefulBuilder(
        builder: (context, set) => TimePicker(
          value: value,
          use24Hour: use24Hour,
          minuteStep: minuteStep,
          semanticLabel: 'Start time',
          onChanged: (t) => set(() {
            value = t;
            picked.add(t);
          }),
        ),
      ),
    ),
  );
  return picked;
}

void main() {
  group('Time Picker', () {
    testWidgets('a pick in each column changes the time at once', (
      tester,
    ) async {
      final picked = await pump(tester, start: const ClockTime(9, 30));
      expect(find.text('09:30'), findsOneWidget);
      await tester.tap(find.text('09:30'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('11'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('45'));
      await tester.pumpAndSettle();
      expect(picked, const [ClockTime(11, 30), ClockTime(11, 45)]);
      expect(find.text('11:45'), findsOneWidget);
      // Enter closes it.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('45'), findsNothing);
    });

    testWidgets('on a 12-hour clock the hours read 12 to 11, with AM and PM', (
      tester,
    ) async {
      final picked = await pump(
        tester,
        start: const ClockTime(0, 15),
        use24Hour: false,
      );
      expect(find.text('12:15 AM'), findsOneWidget);
      await tester.tap(find.text('12:15 AM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PM'));
      await tester.pumpAndSettle();
      expect(picked.last, const ClockTime(12, 15));
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      expect(picked.last, const ClockTime(15, 15));
      expect(find.text('3:15 PM'), findsOneWidget);
    });

    testWidgets(
      'the arrow keys step the column in focus, and move between them',
      (tester) async {
        final picked = await pump(tester, start: const ClockTime(23, 55));
        await tester.tap(find.text('23:55'));
        await tester.pumpAndSettle();
        // The hours have focus first; down from 23 comes round to 0.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(picked.last, const ClockTime(0, 55));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expect(picked.last, const ClockTime(0, 50));
      },
    );

    testWidgets('minutes come in steps; 1 gives every minute', (tester) async {
      await pump(
        tester,
        start: const ClockTime(8, 0),
        minuteStep: 15,
        use24Hour: false,
      );
      await tester.tap(find.text('8:00 AM'));
      await tester.pumpAndSettle();
      for (final m in ['00', '15', '30', '45']) {
        expect(find.text(m), findsWidgets);
      }
      expect(find.text('05'), findsNothing);
    });

    testWidgets('a screen reader hears the field, and steps each column', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final picked = await pump(tester, start: const ClockTime(9, 30));
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Start time'))
            .getSemanticsData()
            .value,
        '09:30',
      );
      await tester.tap(find.text('09:30'));
      await tester.pumpAndSettle();
      final hour = tester.getSemantics(find.bySemanticsLabel('Hour'));
      expect(hour.getSemanticsData().value, '09');
      expect(hour.getSemanticsData().increasedValue, '10');
      hour.owner!.performAction(hour.id, SemanticsAction.increase);
      await tester.pump();
      expect(picked.last, const ClockTime(10, 30));
      semantics.dispose();
    });

    testWidgets('a time between the steps shows at the step before it', (
      tester,
    ) async {
      await pump(tester, start: const ClockTime(9, 32));
      expect(find.text('09:32'), findsOneWidget);
      await tester.tap(find.text('09:32'));
      await tester.pumpAndSettle();
      final semantics = tester.ensureSemantics();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Minute'))
            .getSemanticsData()
            .value,
        '30',
      );
      semantics.dispose();
    });
  });

  test('a time reads on either clock', () {
    expect(const ClockTime(0, 5).as12Hour, '12:05 AM');
    expect(const ClockTime(12, 0).as12Hour, '12:00 PM');
    expect(const ClockTime(23, 59).as24Hour, '23:59');
    expect(const ClockTime(7, 3).as24Hour, '07:03');
  });
}
