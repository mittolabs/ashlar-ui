// The spinner picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/badge.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/spinner.dart';

class SpinnerDemo extends StatelessWidget {
  const SpinnerDemo({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Spinner(),
      Button(onPressed: null, leading: Spinner(), child: Text('Saving')),
      Badge(variant: BadgeVariant.secondary, leading: Spinner(), child: Text('Syncing')),
    ],
  );
}
