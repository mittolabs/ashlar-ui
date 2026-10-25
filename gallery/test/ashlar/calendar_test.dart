// Tests for Calendar. Copied into your app by `ashlar add calendar` with the component: they
// check what it promises, so change them as you change it.
import 'dart:ui' show Tristate;

import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

final october = DateTime(2026, 10);

/// The day cell showing [n] in the month shown (not a day from the month either side).
Finder dayOf(int n) => find.text('$n').last;

void main() {
  group('Choosing a month and year', () {
    Future<List<DateTime>> pump(
      WidgetTester tester, {
      DateTime? firstDate,
      DateTime? lastDate,
    }) async {
      final picked = <DateTime>[];
      await tester.pumpWidget(
        app(
          Calendar(
            selected: null,
            initialMonth: october,
            firstDate: firstDate,
            lastDate: lastDate,
            onSelected: picked.add,
          ),
        ),
      );
      return picked;
    }

    testWidgets('the month opens its year, the year a choice of years', (
      tester,
    ) async {
      final picked = await pump(tester);
      final size = tester.getSize(find.byType(Calendar));
      await tester.tap(find.text('October 2026'));
      await tester.pumpAndSettle();
      expect(find.text('Mar'), findsOneWidget);
      // The same room as the days, so what holds it does not jump.
      expect(tester.getSize(find.byType(Calendar)), size);
      await tester.tap(find.text('2026'));
      await tester.pumpAndSettle();
      expect(find.text('2016 to 2027'), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.bySemanticsLabel('Earlier years'));
        await tester.pumpAndSettle();
      }
      expect(find.text('1980 to 1991'), findsOneWidget);
      await tester.tap(find.text('1990'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mar'));
      await tester.pumpAndSettle();
      expect(find.text('March 1990'), findsOneWidget);
      await tester.tap(dayOf(14));
      expect(picked, [DateTime(1990, 3, 14)]);
    });

    testWidgets(
      'years and months outside the first and last dates cannot be chosen',
      (tester) async {
        await pump(
          tester,
          firstDate: DateTime(2025, 6, 15),
          lastDate: DateTime(2027, 2, 1),
        );
        await tester.tap(find.text('October 2026'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2026'));
        await tester.pumpAndSettle();
        bool enabled(String label) =>
            tester
                .getSemantics(find.bySemanticsLabel(label))
                .getSemanticsData()
                .flagsCollection
                .isEnabled ==
            Tristate.isTrue;
        expect(enabled('2024'), isFalse);
        expect(enabled('2025'), isTrue);
        expect(enabled('2027'), isTrue);
        expect(enabled('Later years'), isFalse);
        await tester.tap(find.text('2025'));
        await tester.pumpAndSettle();
        expect(enabled('May 2025'), isFalse);
        expect(enabled('June 2025'), isTrue);
      },
    );

    testWidgets('Escape steps back towards the days', (tester) async {
      await pump(tester);
      await tester.tap(find.text('October 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2026'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Mar'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
    });
  });

  group('Calendar', () {
    testWidgets('expand fills the width given, its days widening and growing', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 350,
            child: Calendar(
              expand: true,
              selected: DateTime(2026, 10, 14),
              onSelected: (_) {},
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(Calendar)).width, closeTo(350, 1));
      final day = tester.getSize(
        find.ancestor(of: dayOf(14), matching: find.byType(SizedBox)).first,
      );
      expect(day.width, closeTo(50, 1));
      expect(day.height, 40);
    });

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

  test('ISO week numbers', () {
    expect(isoWeek(DateTime(2026, 1, 1)), 1);
    expect(isoWeek(DateTime(2026, 10, 13)), 42);
    expect(isoWeek(DateTime(2027, 1, 1)), 53);
  });

  testWidgets('several days picked and unpicked', (tester) async {
    var days = <DateTime>{};
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, set) => Calendar.multiple(
            days: days,
            initialMonth: october,
            onDaysChanged: (d) => set(() => days = d),
          ),
        ),
      ),
    );
    await tester.tap(find.text('5').last);
    await tester.pump();
    await tester.tap(find.text('9').last);
    await tester.pump();
    await tester.tap(find.text('5').last);
    await tester.pump();
    expect(days, {DateTime(2026, 10, 9)});
  });

  testWidgets('two months side by side, with week numbers', (tester) async {
    await tester.pumpWidget(
      app(
        Calendar(
          selected: null,
          initialMonth: october,
          months: 2,
          showWeekNumbers: true,
          onSelected: (_) {},
        ),
      ),
    );
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('month and year from lists', (tester) async {
    await tester.pumpWidget(
      app(
        Calendar(
          selected: null,
          initialMonth: october,
          dropdowns: true,
          onSelected: (_) {},
        ),
      ),
    );
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    // The year list builds a screenful; typing jumps to the year.
    for (final k in [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit9,
      LogicalKeyboardKey.digit9,
      LogicalKeyboardKey.digit0,
    ]) {
      await tester.sendKeyEvent(k);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oct'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mar'));
    await tester.pumpAndSettle();
    // 1 March 1990 was a Thursday.
    expect(find.text('1990'), findsOneWidget);
    expect(find.text('Mar'), findsOneWidget);
  });
}
