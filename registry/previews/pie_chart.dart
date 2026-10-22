// The visitors picture ashlar update --preview draws.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:ashlar_ui_gallery/ui/pie_chart.dart';

typedef _Browser = ({String browser, double visitors});

const _browsers = <_Browser>[
  (browser: 'Chrome', visitors: 275),
  (browser: 'Safari', visitors: 200),
  (browser: 'Firefox', visitors: 187),
  (browser: 'Edge', visitors: 173),
  (browser: 'Other', visitors: 90),
];

class PieChartDemo extends StatelessWidget {
  const PieChartDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Card(
      children: [
        const CardHeader(title: Text('Visitors'), description: Text('By browser, this month')),
        CardContent(
          child: Center(
            child: PieChart<_Browser>(
              data: _browsers,
              size: 200,
              semanticLabel: 'Visitors by browser',
              center: const Text('925'),
              children: [
                ChartTooltip(hideLabel: true),
                ChartLegend(),
                Pie(value: (r) => r.visitors, name: (r) => r.browser, innerRadius: .6),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
