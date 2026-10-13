// The field picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/field.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';

class FieldDemo extends StatefulWidget {
  const FieldDemo({super.key});

  @override
  State<FieldDemo> createState() => _FieldDemoState();
}

class _FieldDemoState extends State<FieldDemo> {
  bool news = true;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 340,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Field(
          label: Text('Email'),
          description: Text('We send receipts here.'),
          child: Input(placeholder: 'you@solutech.co.ke'),
        ),
        const SizedBox(height: 20),
        const Field(
          label: Text('Phone'),
          error: Text('Enter a number like 0712 345 678.'),
          child: Input(placeholder: '0712 345 678', error: true),
        ),
        const SizedBox(height: 20),
        Field(
          axis: Axis.horizontal,
          label: const Text('Send me news'),
          description: const Text('One email a month. Leave at any time.'),
          child: Checkbox(value: news, onChanged: (v) => setState(() => news = v)),
        ),
      ],
    ),
  );
}
