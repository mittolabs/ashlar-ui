// The toggle picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/toggle.dart';

class ToggleDemo extends StatefulWidget {
  const ToggleDemo({super.key});

  @override
  State<ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<ToggleDemo> {
  bool bold = true, starred = false;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Toggle(
        pressed: bold,
        onChanged: (v) => setState(() => bold = v),
        semanticLabel: 'Bold',
        child: const AshlarIcon(AshlarIconsRoundedStroke.bold),
      ),
      const SizedBox(width: 8),
      Toggle(
        pressed: starred,
        onChanged: (v) => setState(() => starred = v),
        variant: ToggleVariant.outline,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AshlarIcon(AshlarIconsRoundedStroke.star),
            SizedBox(width: 6),
            Text('Starred'),
          ],
        ),
      ),
    ],
  );
}
