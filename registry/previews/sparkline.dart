// The sparkline picture ashlar update --preview draws.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/sparkline.dart';

class SparklineDemo extends StatelessWidget {
  const SparklineDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 640,
    child: Row(
      children: [
        Expanded(
          child: Card(
            children: [
              CardHeader(title: Text('\$48,200'), description: Text('Revenue, last 12 days')),
              CardContent(
                child: Sparkline(
                  values: [31, 34, 30, 38, 42, 40, 45, 43, 47, 46, 52, 48],
                  kind: SparkKind.area,
                  markers: SparkMarkers(last: true),
                  semanticLabel: 'Revenue',
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Card(
            children: [
              CardHeader(title: Text('8 of 12'), description: Text('Matches won')),
              CardContent(
                child: Sparkline(
                  values: [1, 1, -1, 1, 1, -1, 1, 1, -1, 1, -1, 1],
                  kind: SparkKind.winLoss,
                  semanticLabel: 'Results',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
