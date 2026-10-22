// The chart picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';

typedef _Month = ({String month, double desktop, double mobile, double mpesa, double card});
typedef _Method = ({String method, double amount});

const _months = <_Month>[
  (month: 'Jan', desktop: 186, mobile: 80, mpesa: 120, card: 60),
  (month: 'Feb', desktop: 305, mobile: 200, mpesa: 160, card: 80),
  (month: 'Mar', desktop: 237, mobile: 120, mpesa: 150, card: 70),
  (month: 'Apr', desktop: 73, mobile: 190, mpesa: 210, card: 90),
  (month: 'May', desktop: 209, mobile: 130, mpesa: 240, card: 110),
  (month: 'Jun', desktop: 214, mobile: 140, mpesa: 260, card: 100),
];

const _methods = <_Method>[
  (method: 'M-Pesa', amount: 275),
  (method: 'Card', amount: 200),
  (method: 'Bank', amount: 90),
];

class ChartDemo extends StatelessWidget {
  const ChartDemo({super.key});

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
              CardContent(
                child: BarChart<_Month>(
                  height: 200,
                  data: _months,
                  x: (r) => r.month,
                  semanticLabel: 'Visitors by month',
                  children: [
                    CartesianGrid(),
                    XAxis(),
                    ChartTooltip(),
                    Bar(label: 'Desktop', value: (r) => r.desktop),
                    Bar(label: 'Mobile', value: (r) => r.mobile),
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
              CardContent(
                child: AreaChart<_Month>(
                  height: 200,
                  data: _months,
                  x: (r) => r.month,
                  semanticLabel: 'Sales by month',
                  children: [
                    CartesianGrid(),
                    XAxis(),
                    ChartTooltip(),
                    Area(label: 'Card', value: (r) => r.card, stackId: 'a'),
                    Area(label: 'M-Pesa', value: (r) => r.mpesa, stackId: 'a'),
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
              CardContent(
                child: Center(
                  child: PieChart<_Method>(
                    size: 150,
                    data: _methods,
                    semanticLabel: 'Payments by method',
                    center: const Text('565'),
                    children: [
                      ChartTooltip(hideLabel: true),
                      Pie(value: (r) => r.amount, name: (r) => r.method, innerRadius: .6),
                    ],
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
