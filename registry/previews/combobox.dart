// The combobox picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/combobox.dart';

class ComboboxDemo extends StatefulWidget {
  const ComboboxDemo({super.key});

  @override
  State<ComboboxDemo> createState() => _ComboboxDemoState();
}

class _ComboboxDemoState extends State<ComboboxDemo> {
  String? country;

  static const countries = [
    'Argentina', 'Australia', 'Brazil', 'Canada', 'Egypt', 'France', 'Germany', 'Ghana', 'India', 'Indonesia', //
    'Japan', 'Kenya', 'Mexico', 'Morocco', 'Nigeria', 'Peru', 'Philippines', 'Portugal', 'South Africa', 'Spain', 'Vietnam',
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: Combobox<String>(
      value: country,
      placeholder: 'Choose a country',
      searchPlaceholder: 'Search countries',
      semanticLabel: 'Country',
      options: [for (final c in countries) ComboboxOption(c, c)],
      onChanged: (v) => setState(() => country = v),
    ),
  );
}
