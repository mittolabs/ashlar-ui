// The calendar picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/calendar.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class CalendarDemo extends StatefulWidget {
  const CalendarDemo({super.key});

  @override
  State<CalendarDemo> createState() => _CalendarDemoState();
}

class _CalendarDemoState extends State<CalendarDemo> {
  DateTime? day = DateTime(2026, 10, 13);
  DateRange? stay = DateRange(DateTime(2026, 10, 20), DateTime(2026, 10, 24));

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    BoxDecoration frame() => BoxDecoration(
      color: t.colors.card,
      border: Border.all(color: t.colors.border),
      borderRadius: BorderRadius.circular(t.radiusLg),
      boxShadow: t.shadowSm,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: frame(),
          child: Calendar(selected: day, onSelected: (d) => setState(() => day = d)),
        ),
        const SizedBox(width: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: frame(),
          child: Calendar.range(
            range: stay,
            isDisabled: (d) => d.weekday == DateTime.sunday,
            onRangeChanged: (r) => setState(() => stay = r),
          ),
        ),
      ],
    );
  }
}
