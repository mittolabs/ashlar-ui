// The chart picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';

class ChartDemo extends StatelessWidget {
  const ChartDemo({super.key});

  static const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 820,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            children: [
              const CardHeader(title: Text('Visitors'), description: Text('January to June')),
              const CardContent(
                child: BarChart(
                  height: 200,
                  labels: months,
                  semanticLabel: 'Visitors by month',
                  series: [
                    ChartSeries('Desktop', [186, 305, 237, 73, 209, 214]),
                    ChartSeries('Mobile', [80, 200, 120, 190, 130, 140]),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            children: [
              const CardHeader(title: Text('Sales'), description: Text('KES, thousands')),
              const CardContent(
                child: AreaChart(
                  height: 200,
                  stacked: true,
                  labels: months,
                  semanticLabel: 'Sales by month',
                  series: [
                    ChartSeries('M-Pesa', [120, 160, 150, 210, 240, 260]),
                    ChartSeries('Card', [60, 80, 70, 90, 110, 100]),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 220,
          child: Card(
            children: [
              const CardHeader(title: Text('Payments'), description: Text('This month')),
              const CardContent(
                child: Center(
                  child: PieChart(
                    size: 150,
                    semanticLabel: 'Payments by method',
                    center: Text('565'),
                    slices: [ChartSlice('M-Pesa', 275), ChartSlice('Card', 200), ChartSlice('Bank', 90)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
