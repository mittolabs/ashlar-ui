// The swipe-actions picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/item.dart';
import 'package:ashlar_ui_gallery/ui/separator.dart';
import 'package:ashlar_ui_gallery/ui/swipe_actions.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class SwipeActionsDemo extends StatefulWidget {
  const SwipeActionsDemo({super.key});

  @override
  State<SwipeActionsDemo> createState() => _SwipeActionsDemoState();
}

class _SwipeActionsDemoState extends State<SwipeActionsDemo> {
  var mail = ['Achieng Otieno', 'Kofi Mensah', 'Amina Diallo', 'Tendai Moyo'];
  final pinned = <String>{};

  @override
  Widget build(BuildContext context) => Container(
    width: 360,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      border: Border.all(color: AshlarTheme.of(context).colors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, from) in mail.indexed) ...[
          if (i > 0) const Separator(),
          SwipeActions(
            key: ValueKey(from),
            start: [
              SwipeAction(
                label: pinned.contains(from) ? 'Unpin' : 'Pin',
                icon: const AshlarIcon(AshlarIconsRoundedStroke.pin),
                onPressed: () => setState(
                  () => pinned.contains(from) ? pinned.remove(from) : pinned.add(from),
                ),
              ),
            ],
            end: [
              SwipeAction(
                label: 'Delete',
                icon: const AshlarIcon(AshlarIconsRoundedStroke.trash),
                destructive: true,
                onPressed: () => setState(() => mail = [...mail]..remove(from)),
              ),
            ],
            child: Item(
              title: Text(from),
              description: const Text('Swipe either way.'),
              trailing: pinned.contains(from) ? const AshlarIcon(AshlarIconsRoundedStroke.pin, size: 14) : null,
            ),
          ),
        ],
      ],
    ),
  );
}
