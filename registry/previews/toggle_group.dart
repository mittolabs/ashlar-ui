// The toggle-group picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/toggle_group.dart';

class ToggleGroupDemo extends StatefulWidget {
  const ToggleGroupDemo({super.key});

  @override
  State<ToggleGroupDemo> createState() => _ToggleGroupDemoState();
}

class _ToggleGroupDemoState extends State<ToggleGroupDemo> {
  Set<String> styles = {'bold'};
  Set<String> align = {'left'};

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ToggleGroup<String>(
        multiple: true,
        semanticLabel: 'Text style',
        values: styles,
        onChanged: (v) => setState(() => styles = v),
        items: const [
          ToggleGroupItem('bold', AshlarIcon(AshlarIconsRoundedStroke.bold), semanticLabel: 'Bold'),
          ToggleGroupItem('italic', AshlarIcon(AshlarIconsRoundedStroke.italic), semanticLabel: 'Italic'),
          ToggleGroupItem('underline', AshlarIcon(AshlarIconsRoundedStroke.underline), semanticLabel: 'Underline'),
        ],
      ),
      const SizedBox(height: 16),
      ToggleGroup<String>(
        semanticLabel: 'Alignment',
        values: align,
        onChanged: (v) => setState(() => align = v),
        items: const [
          ToggleGroupItem('left', AshlarIcon(AshlarIconsRoundedStroke.textAlignStart), semanticLabel: 'Align left'),
          ToggleGroupItem('center', AshlarIcon(AshlarIconsRoundedStroke.textAlignCenter), semanticLabel: 'Centre'),
          ToggleGroupItem('right', AshlarIcon(AshlarIconsRoundedStroke.textAlignEnd), semanticLabel: 'Align right'),
        ],
      ),
    ],
  );
}
