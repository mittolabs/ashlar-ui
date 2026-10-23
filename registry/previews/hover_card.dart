// The hover-card picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/avatar.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/hover_card.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class HoverCardDemo extends StatelessWidget {
  const HoverCardDemo({super.key});

  @override
  Widget build(BuildContext context) => HoverCard(
    width: 300,
    content: (context) {
      final t = AshlarTheme.of(context);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Avatar(fallback: 'MT', size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@maya', style: t.text.sm.copyWith(fontWeight: FontWeight.w600)),
                const Text('Designs payment apps. Based in Lisbon.'),
                const SizedBox(height: 6),
                Text('Joined March 2024', style: t.text.xs.copyWith(color: t.colors.mutedForeground)),
              ],
            ),
          ),
        ],
      );
    },
    child: Button(variant: ButtonVariant.link, onPressed: () {}, child: const Text('@maya')),
  );
}
