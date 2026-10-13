// The time-picker picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/time_picker.dart';

class TimePickerDemo extends StatefulWidget {
  const TimePickerDemo({super.key});

  @override
  State<TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<TimePickerDemo> {
  ClockTime? opens = const ClockTime(9, 0), closes;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // A 12-hour clock, with AM and PM.
      SizedBox(
        width: 180,
        child: TimePicker(
          value: opens,
          use24Hour: false,
          semanticLabel: 'Opens',
          onChanged: (t) => setState(() => opens = t),
        ),
      ),
      const SizedBox(width: 16),
      // A 24-hour clock, every 15 minutes.
      SizedBox(
        width: 180,
        child: TimePicker(
          value: closes,
          use24Hour: true,
          minuteStep: 15,
          placeholder: 'Closes at',
          semanticLabel: 'Closes',
          onChanged: (t) => setState(() => closes = t),
        ),
      ),
    ],
  );
}
