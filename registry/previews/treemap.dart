// The treemap picture ashlar update --preview draws.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/treemap.dart';

typedef _Spend = ({String item, String category, double amount});

const _spend = <_Spend>[
  (item: 'Rent', category: 'Home', amount: 45000),
  (item: 'Power', category: 'Home', amount: 4200),
  (item: 'Fuel', category: 'Transport', amount: 12000),
  (item: 'Fares', category: 'Transport', amount: 3500),
  (item: 'Groceries', category: 'Food', amount: 18000),
  (item: 'Eating out', category: 'Food', amount: 7600),
];

class TreemapDemo extends StatelessWidget {
  const TreemapDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 480,
    child: Card(
      children: [
        const CardHeader(title: Text('Spending'), description: Text('KES, October')),
        CardContent(
          child: Treemap<_Spend>(
            data: _spend,
            height: 220,
            value: (r) => r.amount,
            name: (r) => r.item,
            group: (r) => r.category,
          ),
        ),
      ],
    ),
  );
}
