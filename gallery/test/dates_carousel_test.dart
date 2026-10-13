// Calendar's several days, week numbers, two months and dropdowns; date presets; and the
// carousel's direction, controller and autoplay.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/calendar.dart';
import 'package:ashlar_ui_gallery/ui/carousel.dart';
import 'package:ashlar_ui_gallery/ui/date_picker.dart';
import 'package:ashlar_ui_gallery/ui/popover.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));
final october = DateTime(2026, 10);

void main() {
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

  testWidgets('a carousel moved by its controller, and by itself', (
    tester,
  ) async {
    final controller = CarouselController();
    await tester.pumpWidget(
      app(
        SizedBox(
          width: 300,
          height: 300,
          child: Carousel(
            axis: Axis.vertical,
            controller: controller,
            autoplay: const Duration(seconds: 2),
            children: [for (var i = 1; i <= 3; i++) Text('Slide $i')],
          ),
        ),
      ),
    );
    controller.next();
    await tester.pumpAndSettle();
    expect(controller.index, 1);
    expect(find.text('Slide 2').hitTestable(), findsOneWidget);
    // Upright: the next slide comes from below.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(controller.index, 2);
    // And from the last, back to the first.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(controller.index, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a popover header', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const PopoverHeader(
          title: Text('Dimensions'),
          description: Text('Set the size.'),
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.text('Dimensions'))
          .getSemanticsData()
          .flagsCollection
          .isHeader,
      isTrue,
    );
    semantics.dispose();
  });
}
