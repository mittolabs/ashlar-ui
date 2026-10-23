// The alert picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/alert.dart';

class AlertDemo extends StatelessWidget {
  const AlertDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 440,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Alert(
          icon: AshlarIcon(AshlarIconsRoundedStroke.circleCheck),
          title: Text('Payment received'),
          description: Text('\$240 from Maya Thompson.'),
        ),
        SizedBox(height: 12),
        Alert(
          variant: AlertVariant.destructive,
          icon: AshlarIcon(AshlarIconsRoundedStroke.circleAlert),
          title: Text('The card was declined'),
          description: Text('Try another card or pay by mobile money.'),
        ),
      ],
    ),
  );
}
