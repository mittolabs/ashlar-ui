// The funnel chart picture ashlar update --preview draws.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:ashlar_ui_gallery/ui/funnel_chart.dart';

typedef _Stage = ({String stage, double people});

const _stages = <_Stage>[
  (stage: 'Visited', people: 5200),
  (stage: 'Signed up', people: 2300),
  (stage: 'Verified', people: 1500),
  (stage: 'Paid', people: 640),
];

class FunnelChartDemo extends StatelessWidget {
  const FunnelChartDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 460,
    child: Card(
      children: [
        const CardHeader(title: Text('Sign-ups'), description: Text('This month')),
        CardContent(
          child: FunnelChart<_Stage>(
            data: _stages,
            height: 220,
            children: [
              ChartTooltip(),
              Funnel(
                value: (r) => r.people,
                name: (r) => r.stage,
                labels: [
                  ChartLabels(position: ChartLabelPosition.inside),
                  ChartLabels(position: ChartLabelPosition.right, text: (r, _) => r.stage),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
