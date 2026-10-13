// Calendar and date picker, as an app gets them from lib/ui.
import 'dart:ui' show Tristate;

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/calendar.dart';
import 'package:ashlar_ui_gallery/ui/date_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));
final october = DateTime(2026, 10);

/// The day cell showing [n] in the month shown (not a day from the month either side).
Finder dayOf(int n) => find.text('$n').last;

void main() {
  group('Calendar', () {
    testWidgets('lays out the month from Monday, with the days either side', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          Calendar(selected: null, initialMonth: october, onSelected: (_) {}),
        ),
      );
      expect(find.text('October 2026'), findsOneWidget);
      final heads = tester
          .widgetList<Text>(
            find.textContaining(RegExp(r'^(Mo|Tu|We|Th|Fr|Sa|Su)$')),
          )
          .map((t) => t.data)
          .toList();
      expect(heads, ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']);
      // 1 October 2026 is a Thursday: the grid opens on Monday 28 September.
      expect(
        tester.getTopLeft(find.text('28').first).dx,
        lessThan(tester.getTopLeft(find.text('1').first).dx),
      );
      expect(find.text('31'), findsOneWidget);
    });

    testWidgets('a tap picks a day, read out in full', (tester) async {
      final semantics = tester.ensureSemantics();
      DateTime? picked;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) => Calendar(
              selected: picked,
              initialMonth: october,
              onSelected: (d) => set(() => picked = d),
            ),
          ),
        ),
      );
      await tester.tap(dayOf(13));
      await tester.pump();
      expect(picked, DateTime(2026, 10, 13));
      final node = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Tuesday, 13 October 2026')),
      );
      expect(
        node.getSemanticsData().flagsCollection.isSelected,
        Tristate.isTrue,
      );
      semantics.dispose();
    });

    testWidgets('the arrows either side change the month', (tester) async {
      await tester.pumpWidget(
        app(
          Calendar(selected: null, initialMonth: october, onSelected: (_) {}),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump();
      expect(find.text('November 2026'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.pump();
      expect(find.text('September 2026'), findsOneWidget);
    });

    testWidgets(
      'from the keyboard: arrows, a week down, the next month, Enter',
      (tester) async {
        DateTime? picked;
        await tester.pumpWidget(
          app(
            Calendar(
              selected: DateTime(2026, 10, 13),
              onSelected: (d) => picked = d,
              autofocus: true,
            ),
          ),
        );
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(picked, DateTime(2026, 10, 21));
        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pump();
        expect(find.text('November 2026'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        // 21 November 2026 is a Saturday; its week starts on Monday the 16th.
        expect(picked, DateTime(2026, 11, 16));
      },
    );

    testWidgets(
      'a range: two taps in either order, the days between chosen too',
      (tester) async {
        final semantics = tester.ensureSemantics();
        DateRange? range;
        await tester.pumpWidget(
          app(
            StatefulBuilder(
              builder: (context, set) => Calendar.range(
                range: range,
                initialMonth: october,
                onRangeChanged: (r) => set(() => range = r),
              ),
            ),
          ),
        );
        await tester.tap(dayOf(10));
        await tester.pump();
        expect(range, DateRange(DateTime(2026, 10, 10)));
        await tester.tap(dayOf(5));
        await tester.pump();
        expect(range, DateRange(DateTime(2026, 10, 5), DateTime(2026, 10, 10)));
        final middle = tester
            .getSemantics(find.bySemanticsLabel('Wednesday, 7 October 2026'))
            .getSemanticsData();
        expect(middle.flagsCollection.isSelected, Tristate.isTrue);
        // A third tap starts again.
        await tester.tap(dayOf(20));
        await tester.pump();
        expect(range, DateRange(DateTime(2026, 10, 20)));
        semantics.dispose();
      },
    );

    testWidgets(
      'days that cannot be picked: before the first date, and weekends',
      (tester) async {
        DateTime? picked;
        await tester.pumpWidget(
          app(
            Calendar(
              selected: null,
              initialMonth: october,
              firstDate: DateTime(2026, 10, 10),
              isDisabled: (d) => d.weekday >= DateTime.saturday,
              onSelected: (d) => picked = d,
            ),
          ),
        );
        await tester.tap(dayOf(5));
        await tester.tap(dayOf(17)); // a Saturday
        expect(picked, isNull);
        await tester.tap(dayOf(15));
        expect(picked, DateTime(2026, 10, 15));
        // No month before the first date.
        await tester.tap(
          find.bySemanticsLabel('Previous month'),
          warnIfMissed: false,
        );
        await tester.pump();
        expect(find.text('October 2026'), findsOneWidget);
      },
    );

    testWidgets('other names and a Sunday start come from DateNamesScope', (
      tester,
    ) async {
      const swahili = DateNames(
        months: [
          'Januari',
          'Februari',
          'Machi',
          'Aprili',
          'Mei',
          'Juni',
          'Julai',
          'Agosti',
          'Septemba',
          'Oktoba',
          'Novemba',
          'Desemba',
        ],
        weekdays: [
          'Jumatatu',
          'Jumanne',
          'Jumatano',
          'Alhamisi',
          'Ijumaa',
          'Jumamosi',
          'Jumapili',
        ],
        weekdaysShort: ['J3', 'J4', 'J5', 'Al', 'Ij', 'J1', 'J2'],
        firstWeekday: DateTime.sunday,
      );
      await tester.pumpWidget(
        app(
          DateNamesScope(
            names: swahili,
            child: Calendar(
              selected: null,
              initialMonth: october,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Oktoba 2026'), findsOneWidget);
      // Sunday first: J2, then J3.
      expect(
        tester.getTopLeft(find.text('J2')).dx,
        lessThan(tester.getTopLeft(find.text('J3')).dx),
      );
    });
  });

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
}
