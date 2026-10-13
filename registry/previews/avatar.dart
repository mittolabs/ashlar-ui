// The avatar picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/avatar.dart';

class AvatarDemo extends StatelessWidget {
  const AvatarDemo({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Avatar(fallback: 'WM', semanticLabel: 'Wanjiru Mwangi'),
      SizedBox(width: 12),
      Avatar(fallback: 'OK', size: 40, semanticLabel: 'Otieno Kamau'),
      SizedBox(width: 12),
      Avatar(fallback: 'AN', size: 48, semanticLabel: 'Achieng Njeri'),
    ],
  );
}
