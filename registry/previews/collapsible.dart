// The collapsible picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/collapsible.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class CollapsibleDemo extends StatelessWidget {
  const CollapsibleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    Widget row(String text) => Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: t.colors.border),
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Text(text),
    );
    return SizedBox(
      width: 340,
      child: Collapsible(
        initiallyOpen: true,
        builder: (context, open, toggle) => Row(
          children: [
            Expanded(
              child: Text('3 orders this week', style: t.text.sm.copyWith(fontWeight: FontWeight.w600)),
            ),
            Button(
              variant: ButtonVariant.ghost,
              size: ButtonSize.icon,
              semanticLabel: open ? 'Hide orders' : 'Show orders',
              onPressed: toggle,
              child: const AshlarIcon(AshlarIconsRoundedStroke.chevronsUpDown),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [row('#4021 · KES 2,400'), row('#4022 · KES 860'), row('#4023 · KES 1,150')],
        ),
      ),
    );
  }
}
