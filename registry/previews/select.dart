// The select picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/select.dart';

class SelectDemo extends StatefulWidget {
  const SelectDemo({super.key});

  @override
  State<SelectDemo> createState() => _SelectDemoState();
}

class _SelectDemoState extends State<SelectDemo> {
  String? county;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Select<String>(
      value: county,
      placeholder: 'Choose a county',
      semanticLabel: 'County',
      options: const [
        SelectOption('nbo', 'Nairobi'),
        SelectOption('msa', 'Mombasa'),
        SelectOption('ksm', 'Kisumu'),
        SelectOption('nku', 'Nakuru'),
        SelectOption('eld', 'Uasin Gishu'),
      ],
      onChanged: (v) => setState(() => county = v),
    ),
  );
}
