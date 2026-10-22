// The color picker picture ashlar update --preview draws.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/color_picker.dart';

class ColorPickerDemo extends StatefulWidget {
  const ColorPickerDemo({super.key});

  @override
  State<ColorPickerDemo> createState() => _ColorPickerDemoState();
}

class _ColorPickerDemoState extends State<ColorPickerDemo> {
  var _brand = const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Card(
      children: [
        const CardHeader(title: Text('Brand colour'), description: Text('Used for buttons and links.')),
        CardContent(
          child: ColorPicker(
            value: _brand,
            onChanged: (c) => setState(() => _brand = c),
            semanticLabel: 'Brand colour',
            swatches: const [
              Color(0xFF2563EB),
              Color(0xFF16A34A),
              Color(0xFFDC2626),
              Color(0xFFF59E0B),
              Color(0xFF7C3AED),
              Color(0xFF0F172A),
            ],
          ),
        ),
      ],
    ),
  );
}
