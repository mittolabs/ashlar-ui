// The chart export picture ashlar update --preview draws: a chart with its buttons.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/chart.dart';
import 'package:ashlar_ui_gallery/ui/chart_export.dart';

typedef _Month = ({String month, double visitors});

const _months = <_Month>[
  (month: 'Jan', visitors: 186),
  (month: 'Feb', visitors: 305),
  (month: 'Mar', visitors: 237),
  (month: 'Apr', visitors: 73),
];

class ChartExportDemo extends StatefulWidget {
  const ChartExportDemo({super.key});

  @override
  State<ChartExportDemo> createState() => _ChartExportDemoState();
}

class _ChartExportDemoState extends State<ChartExportDemo> {
  final _export = ChartExportController();
  String _made = '';

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 460,
    child: Card(
      children: [
        const CardHeader(title: Text('Visitors'), description: Text('January to April')),
        CardContent(
          child: ChartExport(
            controller: _export,
            child: BarChart<_Month>(
              data: _months,
              x: (r) => r.month,
              height: 180,
              children: [XAxis(), Bar(label: 'Visitors', value: (r) => r.visitors)],
            ),
          ),
        ),
        CardFooter(
          children: [
            Button(
              variant: ButtonVariant.outline,
              onPressed: () async {
                final bytes = await _export.png();
                setState(() => _made = 'PNG, ${bytes.length ~/ 1024} KB');
              },
              child: const Text('PNG'),
            ),
            const SizedBox(width: 8),
            Button(
              variant: ButtonVariant.outline,
              onPressed: () async {
                final bytes = await _export.pdf(title: 'Visitors');
                setState(() => _made = 'PDF, ${bytes.length ~/ 1024} KB');
              },
              child: const Text('PDF'),
            ),
            const SizedBox(width: 12),
            Text(_made),
          ],
        ),
      ],
    ),
  );
}
