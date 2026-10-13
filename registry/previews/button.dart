// The button picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';

class ButtonDemo extends StatelessWidget {
  const ButtonDemo({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Button(onPressed: () {}, child: const Text('Button')),
      Button(variant: ButtonVariant.secondary, onPressed: () {}, child: const Text('Secondary')),
      Button(variant: ButtonVariant.outline, onPressed: () {}, child: const Text('Outline')),
      Button(variant: ButtonVariant.ghost, onPressed: () {}, child: const Text('Ghost')),
      Button(variant: ButtonVariant.destructive, onPressed: () {}, child: const Text('Delete')),
      Button(variant: ButtonVariant.link, onPressed: () {}, child: const Text('Link')),
      Button(
        variant: ButtonVariant.outline,
        leading: const AshlarIcon(AshlarIconsRoundedStroke.plus),
        onPressed: () {},
        child: const Text('New project'),
      ),
      Button(
        size: ButtonSize.icon,
        variant: ButtonVariant.outline,
        semanticLabel: 'Settings',
        onPressed: () {},
        child: const AshlarIcon(AshlarIconsRoundedStroke.settings),
      ),
    ],
  );
}
