// Chart variants: every kind and option lays out, the legend hides and shows, and the
// tooltip, keys and screen reader say what is drawn.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Visit = ({String month, double desktop, double mobile});
typedef Browser = ({String browser, double visitors});

const visits = <Visit>[
  (month: 'Jan', desktop: 186, mobile: 80),
  (month: 'Feb', desktop: 305, mobile: 200),
  (month: 'Mar', desktop: 237, mobile: 120),
  (month: 'Apr', desktop: 73, mobile: 190),
  (month: 'May', desktop: 209, mobile: 130),
  (month: 'Jun', desktop: 214, mobile: 140),
];
const browsers = <Browser>[
  (browser: 'Chrome', visitors: 275),
  (browser: 'Safari', visitors: 200),
  (browser: 'Firefox', visitors: 187),
  (browser: 'Edge', visitors: 173),
];

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: SizedBox(width: 520, child: child)),
    );

String summary(WidgetTester tester, String label) => tester
    .getSemantics(find.bySemanticsLabel(label))
    .getSemanticsData()
    .value;

void main() {
  final variants = <String, Widget>{
    'bar horizontal, labels inside and past the end': BarChart<Visit>(
      data: visits,
      x: (r) => r.month,
      layout: ChartLayout.vertical,
      children: [
        XAxis(hide: true),
        YAxis(),
        Bar(
          label: 'Desktop',
          value: (r) => r.desktop,
          labels: [
            ChartLabels(position: ChartLabelPosition.insideStart, text: (r, _) => r.month),
            ChartLabels(position: ChartLabelPosition.right),
          ],
        ),
      ],
    ),
    'bar negative, own colours, active': BarChart<Visit>(
      data: visits,
      x: (r) => r.month,
      active: 2,
      children: [
        XAxis(),
        YAxis(),
        Bar(
          label: 'Change',
          value: (r) => r.desktop - r.mobile * 1.5,
          colorOf: (r) => r.desktop > r.mobile * 1.5 ? null : const Color(0xFFDC2626),
          labels: [ChartLabels()],
        ),
      ],
    ),
    'bar stacked to 100%, with a track': BarChart<Visit>(
      data: visits,
      x: (r) => r.month,
      stackOffset: StackOffset.expand,
      children: [
        YAxis(),
        Bar(label: 'Desktop', value: (r) => r.desktop, stackId: 'a', track: true),
        Bar(label: 'Mobile', value: (r) => r.mobile, stackId: 'a'),
      ],
    ),
    'line steps, dots of their own, values': LineChart<Visit>(
      data: visits,
      x: (r) => r.month,
      children: [
        Line(
          label: 'Desktop',
          value: (r) => r.desktop,
          curve: ChartCurve.stepAfter,
          dot: ChartDot(shape: ChartShape.diamond, radius: 4, colorOf: (r) => r.desktop > 200 ? const Color(0xFF16A34A) : null),
          labels: [ChartLabels()],
        ),
        Line(label: 'Mobile', value: (r) => r.mobile, dashed: true, dot: const ChartDot(hollow: true)),
      ],
    ),
    'area expanded, flat': AreaChart<Visit>(
      data: visits,
      x: (r) => r.month,
      stackOffset: StackOffset.expand,
      children: [
        Area(label: 'Desktop', value: (r) => r.desktop, stackId: 'a', gradient: false),
        Area(label: 'Mobile', value: (r) => r.mobile, stackId: 'a', curve: ChartCurve.linear),
      ],
    ),
    'pie, names outside, one drawn out': PieChart<Browser>(
      data: browsers,
      children: [
        Pie(value: (r) => r.visitors, name: (r) => r.browser, activeIndex: 1, labels: [ChartLabels(text: (r, _) => r.browser)]),
      ],
    ),
    'donut, values inside, no separators, an inner ring': PieChart<Browser>(
      data: browsers,
      children: [
        Pie(value: (r) => r.visitors, name: (r) => r.browser, separators: false, labels: [ChartLabels(position: ChartLabelPosition.inside)]),
        Pie(value: (r) => r.visitors / 2, name: (r) => r.browser),
      ],
    ),
    'radar polygon, filled grid, dots, scale': RadarChart<Visit>(
      data: visits,
      axis: (r) => r.month,
      children: [PolarGrid(fill: true), PolarAngleAxis(), PolarRadiusAxis(), Radar(label: 'Desktop', value: (r) => r.desktop, dots: true)],
    ),
    'radar circle, lines only, no spokes, outer ring': RadarChart<Visit>(
      data: visits,
      axis: (r) => r.month,
      children: [
        PolarGrid(type: PolarGridType.circle, radialLines: false, radii: const [1]),
        Radar(label: 'Desktop', value: (r) => r.desktop, fill: false),
        Radar(label: 'Mobile', value: (r) => r.mobile, fill: false),
      ],
    ),
    'radial rings with labels': RadialBarChart<Browser>(
      data: browsers,
      name: (r) => r.browser,
      children: [
        RadialBar(value: (r) => r.visitors, labels: [ChartLabels(position: ChartLabelPosition.insideStart, text: (r, _) => r.browser)]),
      ],
    ),
    'radial stacked half, a grid': RadialBarChart<Visit>(
      data: visits.take(1).toList(),
      startAngle: -90,
      endAngle: 90,
      center: const Text('266'),
      children: [
        PolarGrid(type: PolarGridType.circle),
        RadialBar(label: 'Desktop', value: (r) => r.desktop, stackId: 'a'),
        RadialBar(label: 'Mobile', value: (r) => r.mobile, stackId: 'a'),
      ],
    ),
  };

  for (final MapEntry(key: name, value: chart) in variants.entries) {
    for (final mode in AshlarThemeMode.values) {
      testWidgets('$name lays out, ${mode.name}', (tester) async {
        await tester.pumpWidget(app(chart, mode: mode));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the legend hides and shows a series by keyboard', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        BarChart<Visit>(
          data: visits,
          x: (r) => r.month,
          semanticLabel: 'Visits',
          children: [
            ChartLegend(),
            Bar(label: 'Desktop', value: (r) => r.desktop),
            Bar(label: 'Mobile', value: (r) => r.mobile),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(summary(tester, 'Visits'), contains('Mobile 80'));
    // The chart, then the legend's two names.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(summary(tester, 'Visits'), isNot(contains('Mobile')));
    semantics.dispose();
  });

  testWidgets('a title can be left out of the tooltip', (tester) async {
    await tester.pumpWidget(
      app(
        BarChart<Visit>(
          data: visits,
          x: (r) => r.month,
          children: [
            ChartTooltip(hideLabel: true, indicator: ChartIndicator.line),
            Bar(label: 'Desktop', value: (r) => r.desktop),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final box = tester.getRect(find.byType(BarChart<Visit>));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(Offset(box.left + box.width / 12, box.top + 100));
    await tester.pump();
    expect(find.text('Desktop'), findsOneWidget);
    expect(find.text('Jan'), findsNothing);
  });

  testWidgets('lying bars step with the up and down keys', (tester) async {
    await tester.pumpWidget(
      app(
        BarChart<Visit>(
          data: visits,
          x: (r) => r.month,
          layout: ChartLayout.vertical,
          children: [XAxis(), ChartTooltip(), Bar(label: 'Desktop', value: (r) => r.desktop)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.text('186'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.text('305'), findsOneWidget);
  });

  testWidgets('a radar reads each axis', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        RadarChart<Visit>(
          data: visits,
          axis: (r) => r.month,
          semanticLabel: 'Visits',
          children: [Radar(label: 'Desktop', value: (r) => r.desktop)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(summary(tester, 'Visits'), startsWith('Jan: Desktop 186; Feb: Desktop 305'));
    semantics.dispose();
  });

  testWidgets('a radial chart reads each value against its whole', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        RadialBarChart<Browser>(
          data: browsers.take(1).toList(),
          name: (r) => r.browser,
          max: 2000,
          semanticLabel: 'Visitors',
          children: [RadialBar(value: (r) => r.visitors)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(summary(tester, 'Visitors'), 'Chrome 275 of 2,000');
    semantics.dispose();
  });

  testWidgets('a pie reads every slice', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        PieChart<Browser>(
          data: browsers,
          semanticLabel: 'Browsers',
          children: [Pie(value: (r) => r.visitors, name: (r) => r.browser)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(summary(tester, 'Browsers'), 'Chrome 275, Safari 200, Firefox 187, Edge 173');
    semantics.dispose();
  });
}
