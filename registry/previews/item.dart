// The item picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/avatar.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/item.dart';

class ItemDemo extends StatelessWidget {
  const ItemDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 440,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Item(
          variant: ItemVariant.outline,
          leading: const AshlarIcon(AshlarIconsRoundedStroke.shieldCheck),
          title: const Text('Two-step sign in is on'),
          description: const Text('A code from your phone is asked for at each sign in.'),
          trailing: Button(
            size: ButtonSize.sm,
            variant: ButtonVariant.outline,
            onPressed: () {},
            child: const Text('Manage'),
          ),
        ),
        const SizedBox(height: 12),
        Item(
          variant: ItemVariant.muted,
          leading: const Avatar(fallback: 'WM'),
          title: const Text('Wanjiru Mwangi'),
          description: const Text('Invited you to the Design team.'),
          trailing: Button(size: ButtonSize.sm, onPressed: () {}, child: const Text('Accept')),
        ),
      ],
    ),
  );
}
