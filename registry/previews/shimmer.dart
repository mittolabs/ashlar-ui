// The shimmer picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/shimmer.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class ShimmerDemo extends StatelessWidget {
  const ShimmerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer(child: Text('Thinking…', style: t.text.base)),
        const SizedBox(height: 12),
        Shimmer(child: Text('Searching this week\'s orders…', style: t.text.sm)),
      ],
    );
  }
}
