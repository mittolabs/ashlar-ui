// The skills picture ashlar update --preview draws.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:ashlar_ui_gallery/ui/radar_chart.dart';

typedef _Skill = ({String skill, double now, double then});

const _skills = <_Skill>[
  (skill: 'Speed', now: 80, then: 60),
  (skill: 'Range', now: 62, then: 75),
  (skill: 'Price', now: 70, then: 55),
  (skill: 'Comfort', now: 90, then: 70),
  (skill: 'Safety', now: 75, then: 85),
  (skill: 'Space', now: 58, then: 66),
];

class RadarChartDemo extends StatelessWidget {
  const RadarChartDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 320,
    child: Card(
      children: [
        const CardHeader(title: Text('Skills'), description: Text('This year and last')),
        CardContent(
          child: Center(
            child: RadarChart<_Skill>(
              data: _skills,
              axis: (r) => r.skill,
              semanticLabel: 'Skills',
              children: [
                PolarGrid(),
                PolarAngleAxis(),
                ChartTooltip(),
                ChartLegend(),
                Radar(label: 'This year', value: (r) => r.now),
                Radar(label: 'Last year', value: (r) => r.then, fill: false),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
