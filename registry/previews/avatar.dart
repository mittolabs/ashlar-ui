// The avatar picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/avatar.dart';

class AvatarDemo extends StatelessWidget {
  const AvatarDemo({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Avatar(fallback: 'MT', semanticLabel: 'Maya Thompson'),
      SizedBox(width: 12),
      Avatar(fallback: 'KM', size: 40, semanticLabel: 'Kofi Mensah'),
      SizedBox(width: 12),
      Avatar(fallback: 'AN', size: 48, semanticLabel: 'Aiko Nakamura'),
    ],
  );
}
