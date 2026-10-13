// The checkbox picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/checkbox.dart';

class CheckboxDemo extends StatefulWidget {
  const CheckboxDemo({super.key});

  @override
  State<CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<CheckboxDemo> {
  bool terms = true, news = false;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: terms, onChanged: (v) => setState(() => terms = v), semanticLabel: 'Accept the terms'),
          const SizedBox(width: 8),
          const Text('Accept the terms'),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: news, onChanged: (v) => setState(() => news = v), semanticLabel: 'Send me news'),
          const SizedBox(width: 8),
          const Text('Send me news'),
        ],
      ),
      const SizedBox(height: 12),
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: true, onChanged: null),
          SizedBox(width: 8),
          Text('Disabled'),
        ],
      ),
    ],
  );
}
