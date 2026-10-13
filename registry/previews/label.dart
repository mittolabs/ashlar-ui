// The label picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/label.dart';

class LabelDemo extends StatefulWidget {
  const LabelDemo({super.key});

  @override
  State<LabelDemo> createState() => _LabelDemoState();
}

class _LabelDemoState extends State<LabelDemo> {
  bool agreed = false;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Checkbox(value: agreed, onChanged: (v) => setState(() => agreed = v), semanticLabel: 'Accept the terms'),
      const SizedBox(width: 8),
      const Label(child: Text('Accept the terms')),
    ],
  );
}
