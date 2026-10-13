// The separator picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/separator.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class SeparatorDemo extends StatelessWidget {
  const SeparatorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final muted = TextStyle(color: t.colors.mutedForeground);
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ashlar UI', style: t.text.sm.copyWith(fontWeight: FontWeight.w500)),
          Text('Components for Flutter, copied into your app.', style: muted),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Separator()),
          // As tall as the words: the lines between them follow the text, at any size.
          IntrinsicHeight(
            child: Row(
              children: [
                const Text('Docs'),
                const SizedBox(width: 12),
                const Separator(axis: Axis.vertical),
                const SizedBox(width: 12),
                const Text('Components'),
                const SizedBox(width: 12),
                const Separator(axis: Axis.vertical),
                const SizedBox(width: 12),
                Text('Source', style: muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
