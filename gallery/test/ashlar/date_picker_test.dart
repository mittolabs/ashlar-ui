// Tests for Date Picker. Copied into your app by `ashlar add date-picker` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/calendar.dart';
import 'package:ashlar_ui_gallery/ui/date_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  group('Date Picker', () {
    testWidgets(
      'shows the placeholder, opens a calendar, and closes on a pick',
      (tester) async {
        DateTime? value;
        await tester.pumpWidget(
          app(
            StatefulBuilder(
              builder: (context, set) => DatePicker(
                value: value,
                onChanged: (d) => set(() => value = d),
              ),
            ),
          ),
        );
        expect(find.text('Pick a date'), findsOneWidget);
        await tester.tap(find.text('Pick a date'));
        await tester.pumpAndSettle();
        final month = DateTime.now();
        expect(find.text(DateNames.english.monthYear(month)), findsOneWidget);
        await tester.tap(find.text('15').last);
        await tester.pumpAndSettle();
        expect(value, DateTime(month.year, month.month, 15));
        expect(
          find.text(
            '15 ${DateNames.english.months[month.month - 1]} ${month.year}',
          ),
          findsOneWidget,
        );
        expect(find.text('Mo'), findsNothing);
      },
    );

    testWidgets('the calendar opens in a panel as wide as it, not the screen', (
      tester,
    ) async {
      await tester.pumpWidget(app(DatePicker(value: null, onChanged: (_) {})));
      await tester.tap(find.text('Pick a date'));
      await tester.pumpAndSettle();
      final calendar = tester.getRect(find.byType(Calendar));
      final panel = tester.getRect(
        find.ancestor(
          of: find.byType(Calendar),
          matching: find.byType(IntrinsicWidth),
        ),
      );
      // The calendar and the panel's padding, on an 800 wide screen.
      expect(panel.width, lessThan(calendar.width + 40));
      expect(panel.width, lessThan(400));
    });

    testWidgets('the keys move through the days as soon as it opens', (
      tester,
    ) async {
      final got = <DateTime>[];
      await tester.pumpWidget(
        app(DatePicker(value: DateTime(2026, 10, 13), onChanged: got.add)),
      );
      await tester.tap(find.text('13 October 2026'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(got, [DateTime(2026, 10, 14)]);
    });

    testWidgets('a range stays open until both ends are picked', (
      tester,
    ) async {
      DateRange? range;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => DatePicker.range(
              range: range,
              onRangeChanged: (r) => set(() => range = r),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Pick dates'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5').last);
      await tester.pumpAndSettle();
      expect(find.text('Mo'), findsOneWidget);
      await tester.tap(find.text('10').last);
      await tester.pumpAndSettle();
      expect(find.text('Mo'), findsNothing);
      final m = DateNames.english.months[DateTime.now().month - 1],
          y = DateTime.now().year;
      expect(find.text('5 $m $y to 10 $m $y'), findsOneWidget);
    });
  });

  testWidgets('a preset picks its date and closes', (tester) async {
    DateTime? value;
    final tomorrow = DateTime(2026, 10, 14);
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, set) => DatePicker(
            value: value,
            presets: [('Tomorrow', tomorrow)],
            onChanged: (d) => set(() => value = d),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pick a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pick a preset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();
    expect(value, tomorrow);
    expect(find.text('14 October 2026'), findsOneWidget);
  });
}
