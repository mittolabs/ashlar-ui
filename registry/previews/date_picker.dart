// The date-picker picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/calendar.dart';
import 'package:ashlar_ui_gallery/ui/date_picker.dart';

class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});

  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DateTime? due;
  DateRange? stay;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 220,
        child: DatePicker(value: due, semanticLabel: 'Due date', onChanged: (d) => setState(() => due = d)),
      ),
      const SizedBox(width: 16),
      SizedBox(
        width: 300,
        child: DatePicker.range(range: stay, semanticLabel: 'Stay', onRangeChanged: (r) => setState(() => stay = r)),
      ),
    ],
  );
}
