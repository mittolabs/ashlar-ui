// The visitors picture ashlar update --preview draws.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:ashlar_ui_gallery/ui/radial_chart.dart';

typedef _Browser = ({String browser, double visitors});

const _browsers = <_Browser>[
  (browser: 'Chrome', visitors: 275),
  (browser: 'Safari', visitors: 200),
  (browser: 'Firefox', visitors: 187),
  (browser: 'Edge', visitors: 173),
  (browser: 'Other', visitors: 90),
];

class RadialChartDemo extends StatelessWidget {
  const RadialChartDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Card(
      children: [
        const CardHeader(title: Text('Visitors'), description: Text('By browser, this month')),
        CardContent(
          child: Center(
            child: RadialBarChart<_Browser>(
              data: _browsers,
              name: (r) => r.browser,
              size: 220,
              semanticLabel: 'Visitors by browser',
              children: [ChartTooltip(hideLabel: true), RadialBar(value: (r) => r.visitors)],
            ),
          ),
        ),
      ],
    ),
  );
}
