// The kbd picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/kbd.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class KbdDemo extends StatelessWidget {
  const KbdDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Kbd.group(const [Kbd(child: Text('⌘')), Kbd(child: Text('⇧')), Kbd(child: Text('K'))]),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Press ', style: TextStyle(color: t.colors.mutedForeground)),
            const Kbd(child: Text('Esc')),
            Text(' to close.', style: TextStyle(color: t.colors.mutedForeground)),
          ],
        ),
      ],
    );
  }
}
