// The combobox picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/combobox.dart';

class ComboboxDemo extends StatefulWidget {
  const ComboboxDemo({super.key});

  @override
  State<ComboboxDemo> createState() => _ComboboxDemoState();
}

class _ComboboxDemoState extends State<ComboboxDemo> {
  String? county;

  static const counties = [
    'Baringo', 'Bomet', 'Bungoma', 'Busia', 'Embu', 'Garissa', 'Kajiado', 'Kakamega', 'Kericho', 'Kiambu', //
    'Kilifi', 'Kisii', 'Kisumu', 'Kitui', 'Lamu', 'Machakos', 'Meru', 'Mombasa', 'Nairobi', 'Nakuru', 'Nyeri',
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: Combobox<String>(
      value: county,
      placeholder: 'Choose a county',
      searchPlaceholder: 'Search counties',
      semanticLabel: 'County',
      options: [for (final c in counties) ComboboxOption(c, c)],
      onChanged: (v) => setState(() => county = v),
    ),
  );
}
