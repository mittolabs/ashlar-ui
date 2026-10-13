// The radio picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/radio.dart';

class RadioDemo extends StatefulWidget {
  const RadioDemo({super.key});

  @override
  State<RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<RadioDemo> {
  String? plan = 'monthly';

  @override
  Widget build(BuildContext context) => RadioGroup<String>(
    groupValue: plan,
    onChanged: (v) => setState(() => plan = v),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Radio(value: 'monthly', label: Text('Monthly'), description: Text('KES 500 a month.')),
        SizedBox(height: 12),
        Radio(value: 'yearly', label: Text('Yearly'), description: Text('Two months free.')),
        SizedBox(height: 12),
        Radio(value: 'team', label: Text('Team'), enabled: false),
      ],
    ),
  );
}
