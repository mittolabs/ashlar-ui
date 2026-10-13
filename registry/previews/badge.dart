// The badge picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/badge.dart';

class BadgeDemo extends StatelessWidget {
  const BadgeDemo({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 8,
    runSpacing: 8,
    alignment: WrapAlignment.center,
    children: [
      Badge(child: Text('New')),
      Badge(variant: BadgeVariant.secondary, child: Text('Draft')),
      Badge(variant: BadgeVariant.destructive, child: Text('Overdue')),
      Badge(
        variant: BadgeVariant.outline,
        leading: AshlarIcon(AshlarIconsRoundedStroke.check),
        child: Text('Paid'),
      ),
    ],
  );
}
