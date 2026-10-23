// The chart picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';

typedef _Month = ({String month, double desktop, double mobile, double wallet, double card});
typedef _Method = ({String method, double amount});

const _months = <_Month>[
  (month: 'Jan', desktop: 186, mobile: 80, wallet: 120, card: 60),
  (month: 'Feb', desktop: 305, mobile: 200, wallet: 160, card: 80),
  (month: 'Mar', desktop: 237, mobile: 120, wallet: 150, card: 70),
  (month: 'Apr', desktop: 73, mobile: 190, wallet: 210, card: 90),
  (month: 'May', desktop: 209, mobile: 130, wallet: 240, card: 110),
  (month: 'Jun', desktop: 214, mobile: 140, wallet: 260, card: 100),
];

const _methods = <_Method>[
  (method: 'Wallet', amount: 275),
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
              const CardHeader(title: Text('Sales'), description: Text('USD, thousands')),
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
                    Area(label: 'Wallet', value: (r) => r.wallet, stackId: 'a'),
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
                child: BarChart<_Method>(
                  height: 150,
                  data: _methods,
                  x: (r) => r.method,
                  layout: ChartLayout.vertical,
                  semanticLabel: 'Payments by method',
                  children: [
                    XAxis(),
                    ChartTooltip(hideLabel: true),
                    Bar(label: 'USD', value: (r) => r.amount, labels: [ChartLabels(position: ChartLabelPosition.right)]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
