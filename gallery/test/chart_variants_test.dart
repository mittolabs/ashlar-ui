// Chart variants: every kind and option lays out, the legend hides and shows, and the
// tooltip, keys and screen reader say what is drawn.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const series = [
  ChartSeries('Desktop', [186, 305, 237, 73, 209, 214]),
  ChartSeries('Mobile', [80, 200, 120, 190, 130, 140]),
];
const slices = [
  ChartSlice('Chrome', 275),
  ChartSlice('Safari', 200),
  ChartSlice('Firefox', 187),
  ChartSlice('Edge', 173),
];

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: SizedBox(width: 520, child: child)),
    );

String summary(WidgetTester tester, Type type) =>
    tester.getSemantics(find.byType(type)).getSemanticsData().value;

void main() {
  final variants = <String, Widget>{
    'bar horizontal': const BarChart(
      labels: labels,
      series: series,
      horizontal: true,
      axis: true,
    ),
    'bar negative': const BarChart(
      labels: labels,
      series: [
        ChartSeries('Change', [186, -205, 237, -73, 209, -214]),
      ],
      valueLabels: true,
      axis: true,
    ),
    'bar active, own colours': BarChart(
      labels: labels,
      active: 2,
      series: [
        ChartSeries(
          'Visitors',
          const [186, 305, 237, 73, 209, 214],
          colors: [
            for (var i = 0; i < 6; i++) Color(0xFF000000 + i * 0x202020),
          ],
        ),
      ],
    ),
    'bar stacked to 100%': const BarChart(
      labels: labels,
      series: series,
      expand: true,
    ),
    'line step with dots and values': const LineChart(
      labels: labels,
      series: series,
      curve: ChartCurve.step,
      dots: true,
      valueLabels: true,
    ),
    'area expanded, linear, flat': const AreaChart(
      labels: labels,
      series: series,
      expand: true,
      curve: ChartCurve.linear,
      gradient: false,
      axis: true,
      legend: ChartLegend.top,
    ),
    'pie with names, one drawn out': const PieChart(
      slices: slices,
      donut: false,
      labels: PieLabels.titles,
      active: 1,
    ),
    'donut with values, no separators, inner ring': const PieChart(
      slices: slices,
      labels: PieLabels.amounts,
      separators: false,
      inner: [ChartSlice('Desktop', 60), ChartSlice('Mobile', 40)],
    ),
    'radar polygon, filled grid, dots': const RadarChart(
      labels: labels,
      series: series,
      gridFill: true,
      dots: true,
    ),
    'radar circle, lines only, no spokes': const RadarChart(
      labels: labels,
      series: series,
      grid: RadarGrid.circle,
      spokes: false,
      fill: false,
    ),
    'radial rings': const RadialChart(
      slices: slices,
      center: Text('835'),
      legend: ChartLegend.bottom,
    ),
    'radial stacked half': const RadialChart(
      slices: [ChartSlice('Desktop', 1260), ChartSlice('Mobile', 570)],
      stacked: true,
      half: true,
      track: false,
      center: Text('1,830'),
    ),
  };
  for (final MapEntry(key: name, value: chart) in variants.entries) {
    for (final mode in [AshlarThemeMode.light, AshlarThemeMode.dark]) {
      testWidgets('$name lays out, ${mode.name}', (tester) async {
        await tester.pumpWidget(app(chart, mode: mode));
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the legend hides and shows a series, by tap or by keyboard', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(const BarChart(labels: labels, series: series)),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(summary(tester, BarChart), contains('Mobile 80'));
    await tester.tap(find.text('Mobile'));
    await tester.pump();
    expect(summary(tester, BarChart), isNot(contains('Mobile')));
    // The last one shown stays.
    await tester.tap(find.text('Desktop'));
    await tester.pump();
    expect(summary(tester, BarChart), contains('Desktop 186'));
    // From the keyboard: Tab to the legend, Enter brings Mobile back.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(summary(tester, BarChart), contains('Mobile 80'));
    semantics.dispose();
  });

  testWidgets('expanded, each label is read as shares of its whole', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const AreaChart(
          labels: ['Q1'],
          series: [
            ChartSeries('A', [30]),
            ChartSeries('B', [70]),
          ],
          expand: true,
        ),
      ),
    );
    expect(summary(tester, AreaChart), 'Q1: A 30%, B 70%');
    semantics.dispose();
  });

  testWidgets('the tooltip writes its title your way, and can add up', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        BarChart(
          labels: labels,
          series: series,
          tooltip: ChartTooltip(
            indicator: ChartIndicator.line,
            title: (l) => '$l 2026',
            total: true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    final box = tester.getRect(find.byType(BarChart));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(Offset(box.left + box.width / 12, box.top + 100));
    await tester.pump();
    expect(find.text('Jan 2026'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('266'), findsOneWidget);
  });

  testWidgets('a title can be left out of the tooltip', (tester) async {
    await tester.pumpWidget(
      app(
        const LineChart(
          labels: labels,
          series: series,
          tooltip: ChartTooltip(
            showTitle: false,
            indicator: ChartIndicator.none,
          ),
        ),
      ),
    );
    final box = tester.getRect(find.byType(LineChart));
    await tester.tapAt(Offset(box.left + box.width / 12, box.top + 100));
    await tester.pump();
    expect(find.text('Desktop'), findsNWidgets(2));
    expect(find.text('Jan'), findsOneWidget);
  });

  testWidgets('lying bars step with the up and down keys', (tester) async {
    await tester.pumpWidget(
      app(const BarChart(labels: labels, series: series, horizontal: true)),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.text('Jan'), findsNWidgets(2));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.text('Feb'), findsNWidgets(2));
  });

  testWidgets('a radar reads each axis, and shows the one under the pointer', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(const RadarChart(labels: labels, series: series, size: 300)),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(
      summary(tester, RadarChart),
      startsWith('Jan: Desktop 186, Mobile 80'),
    );
    final chart = tester.getRect(
      find
          .descendant(
            of: find.byType(RadarChart),
            matching: find.byType(CustomPaint),
          )
          .first,
    );
    // Straight up from the centre: the first axis.
    await tester.tapAt(chart.center - const Offset(0, 80));
    await tester.pump();
    expect(find.text('186'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a radial chart reads each value against its whole', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const RadialChart(
          slices: [ChartSlice('Visitors', 1260)],
          max: 2000,
          center: Text('1,260'),
        ),
      ),
    );
    expect(summary(tester, RadialChart), 'Visitors 1260 of 2000');
    expect(find.text('1,260'), findsOneWidget);
    semantics.dispose();
  });
}
