// The ticket picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/theme.dart';
import 'package:ashlar_ui_gallery/ui/ticket.dart';

class TicketDemo extends StatelessWidget {
  const TicketDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final muted = t.text.xs.copyWith(color: t.colors.mutedForeground);
    final strong = t.text.xxl;
    Widget fact(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          Text(value, style: t.text.sm.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
    return SizedBox(
      width: 340,
      child: Ticket(
        top: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('SFO', style: strong), Text('San Francisco', style: muted)],
            ),
            Expanded(
              child: Text('11h 05m', textAlign: TextAlign.center, style: muted),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Text('NRT', style: strong), Text('Tokyo', style: muted)],
            ),
          ],
        ),
        bottom: Row(
          children: [
            fact('Date', 'Thu, 12 Mar'),
            fact('Seat', '14A'),
            fact('Gate', 'B22'),
          ],
        ),
      ),
    );
  }
}
