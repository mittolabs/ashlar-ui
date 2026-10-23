// The select picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/select.dart';

class SelectDemo extends StatefulWidget {
  const SelectDemo({super.key});

  @override
  State<SelectDemo> createState() => _SelectDemoState();
}

class _SelectDemoState extends State<SelectDemo> {
  String? city;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Select<String>(
      value: city,
      placeholder: 'Choose a city',
      semanticLabel: 'City',
      options: const [
        SelectOption('lis', 'Lisbon'),
        SelectOption('bom', 'Mumbai'),
        SelectOption('kyo', 'Kyoto'),
        SelectOption('lag', 'Lagos'),
        SelectOption('mex', 'Mexico City'),
      ],
      onChanged: (v) => setState(() => city = v),
    ),
  );
}
