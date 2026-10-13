// The tooltip picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/tooltip.dart';

class TooltipDemo extends StatelessWidget {
  const TooltipDemo({super.key});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Add to library',
    child: Button(
      size: ButtonSize.icon,
      variant: ButtonVariant.outline,
      semanticLabel: 'Add',
      onPressed: () {},
      child: const AshlarIcon(AshlarIconsRoundedStroke.plus),
    ),
  );
}
