// The heatmap picture ashlar update --preview draws.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/heatmap.dart';

typedef _Load = ({String day, String hour, double requests});

final _load = <_Load>[
  for (final (d, day) in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].indexed)
    for (var h = 8; h <= 18; h += 2)
      (day: day, hour: '${h}h', requests: ((h - 13).abs() * -9 + 60 + d * 4).toDouble()),
];

class HeatmapDemo extends StatelessWidget {
  const HeatmapDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 480,
    child: Card(
      children: [
        const CardHeader(title: Text('Requests'), description: Text('By hour, this week')),
        CardContent(
          child: Heatmap<_Load>(
            data: _load,
            x: (r) => r.hour,
            y: (r) => r.day,
            value: (r) => r.requests,
            semanticLabel: 'Requests by hour',
          ),
        ),
      ],
    ),
  );
}
