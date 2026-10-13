// Charts, as an app gets them from lib/ui.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: SizedBox(width: 480, child: child)),
    );

const labels = ['Jan', 'Feb', 'Mar', 'Apr'];
const series = [
  ChartSeries('Desktop', [186, 305, 237, 73]),
  ChartSeries('Mobile', [80, 200, 120, 190]),
];

void main() {
  testWidgets('every kind draws in light and dark', (tester) async {
    for (final mode in AshlarThemeMode.values) {
      for (final chart in <Widget>[
        const BarChart(labels: labels, series: series),
        const BarChart(labels: labels, series: series, stacked: true),
        const LineChart(labels: labels, series: series),
        const LineChart(
          labels: labels,
          series: series,
          curve: ChartCurve.linear,
        ),
        const AreaChart(labels: labels, series: series),
        const AreaChart(labels: labels, series: series, stacked: true),
        const PieChart(
          slices: [
            ChartSlice('M-Pesa', 275),
            ChartSlice('Card', 200),
            ChartSlice('Bank', 90),
          ],
          center: Text('565'),
        ),
        const PieChart(
          slices: [ChartSlice('A', 1), ChartSlice('B', 1)],
          donut: false,
        ),
      ]) {
        await tester.pumpWidget(app(chart, mode: mode));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$chart $mode');
      }
    }
  });

  testWidgets('a screen reader hears what it shows and every value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const BarChart(
          labels: labels,
          series: series,
          semanticLabel: 'Visitors by month',
        ),
      ),
    );
    await tester.pumpAndSettle();
    final node = tester
        .getSemantics(find.bySemanticsLabel('Visitors by month'))
        .getSemanticsData();
    expect(node.value, contains('Jan: Desktop 186, Mobile 80'));
    expect(node.value, contains('Apr: Desktop 73, Mobile 190'));
    semantics.dispose();
  });

  testWidgets('hovering a month shows its values; leaving hides them', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const BarChart(labels: labels, series: series)),
    );
    await tester.pumpAndSettle();
    final box = tester.getRect(find.byType(BarChart));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    // The second of four columns.
    await mouse.moveTo(Offset(box.left + box.width * .375, box.top + 100));
    await tester.pump();
    expect(find.text('Feb'), findsNWidgets(2));
    expect(find.text('305'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(find.text('305'), findsNothing);
  });

  testWidgets('the arrow keys step through the values', (tester) async {
    await tester.pumpWidget(
      app(const LineChart(labels: labels, series: series)),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('186'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('305'), findsOneWidget);
  });

  testWidgets('with less motion asked for, it draws at once', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: app(const BarChart(labels: labels, series: series)),
      ),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a slice under the pointer shows its share', (tester) async {
    await tester.pumpWidget(
      app(
        const PieChart(
          slices: [ChartSlice('M-Pesa', 300), ChartSlice('Card', 100)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pie = tester.getRect(find.byType(CustomPaint).first);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    // Three quarters is M-Pesa, clockwise from the top: the right side is in it.
    await mouse.moveTo(pie.center + Offset(pie.width * .4, 0));
    await tester.pump();
    expect(find.text('75%'), findsOneWidget);
  });
}
