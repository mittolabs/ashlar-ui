// The button-group picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/button_group.dart';

class ButtonGroupDemo extends StatelessWidget {
  const ButtonGroupDemo({super.key});

  @override
  Widget build(BuildContext context) => ButtonGroup(
    children: [
      Button(variant: ButtonVariant.outline, onPressed: () {}, child: const Text('Archive')),
      Button(variant: ButtonVariant.outline, onPressed: () {}, child: const Text('Report')),
      Button(variant: ButtonVariant.outline, onPressed: () {}, child: const Text('Snooze')),
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.icon,
        semanticLabel: 'More',
        onPressed: () {},
        child: const AshlarIcon(AshlarIconsRoundedStroke.ellipsis),
      ),
    ],
  );
}
