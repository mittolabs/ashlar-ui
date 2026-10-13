// The marker picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/marker.dart';
import 'package:ashlar_ui_gallery/ui/spinner.dart';

class MarkerDemo extends StatelessWidget {
  const MarkerDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 400,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Marker(variant: MarkerVariant.separator, child: Text('Today')),
        SizedBox(height: 24),
        Marker(
          icon: AshlarIcon(AshlarIconsRoundedStroke.userPlus),
          child: Text('Kofi joined the conversation'),
        ),
        SizedBox(height: 24),
        Marker(icon: Spinner(size: 16), child: Text('Searching the docs…')),
        SizedBox(height: 24),
        Marker(variant: MarkerVariant.border, child: Text('Earlier messages')),
      ],
    ),
  );
}
