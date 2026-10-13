// The skeleton picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/skeleton.dart';

class SkeletonDemo extends StatelessWidget {
  const SkeletonDemo({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Skeleton(width: 48, height: 48, circle: true),
      SizedBox(width: 16),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Skeleton(width: 220), SizedBox(height: 8), Skeleton(width: 160)],
      ),
    ],
  );
}
