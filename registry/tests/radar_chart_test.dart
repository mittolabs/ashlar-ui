// Tests for Radar chart. Copied into your app by `ashlar add radar-chart` with the component:
// they check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:ashlar_ui_gallery/ui/radar_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {AshlarThemeMode mode = AshlarThemeMode.light}) =>
    AshlarApp(
      themeMode: mode,
      home: Center(child: SizedBox(width: 480, child: child)),
    );

typedef Visit = ({String month, double desktop, double mobile});

const visits = <Visit>[
  (month: 'Jan', desktop: 186, mobile: 80),
  (month: 'Feb', desktop: 305, mobile: 200),
  (month: 'Mar', desktop: 237, mobile: 120),
  (month: 'Apr', desktop: 73, mobile: 190),
];

Future<void> mouseAt(WidgetTester tester, Offset at) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(at);
  await tester.pump();
}

String summary(WidgetTester tester, String label) =>
    tester.getSemantics(find.bySemanticsLabel(label)).getSemanticsData().value;

void main() {
  testWidgets('it draws in light and dark', (tester) async {
    for (final mode in AshlarThemeMode.values) {
      await tester.pumpWidget(
        app(
          RadarChart<Visit>(
            data: visits,
            axis: (r) => r.month,
            children: [
              PolarGrid(type: PolarGridType.circle, fill: true),
              PolarAngleAxis(tickFormatter: (name, r) => '$name\n${r.desktop.round()}'),
              PolarRadiusAxis(),
              ChartLegend(),
              Radar(label: 'Desktop', value: (r) => r.desktop, dots: true),
              Radar(label: 'Mobile', value: (r) => r.mobile, fill: false, dashed: true),
            ],
          ),
          mode: mode,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('a radar shows every series at the axis under the pointer', (tester) async {
    await tester.pumpWidget(
      app(
        RadarChart<Visit>(
          data: visits,
          axis: (r) => r.month,
          children: [
            ChartTooltip(),
            Radar(label: 'Desktop', value: (r) => r.desktop),
            Radar(label: 'Mobile', value: (r) => r.mobile),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final r = tester.getRect(find.byType(RadarChart<Visit>));
    // Straight up is the first axis.
    await mouseAt(tester, r.center - Offset(0, r.height * .3));
    expect(find.text('186'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
  });

  testWidgets('a screen reader hears each axis', (tester) async {
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
}
