// The command picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/command.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class CommandDemo extends StatelessWidget {
  const CommandDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Container(
      width: 420,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: t.colors.popover,
        borderRadius: BorderRadius.circular(t.radiusLg),
        border: Border.all(color: t.colors.border),
        boxShadow: t.shadowSm,
      ),
      child: Command(
        autofocus: false,
        groups: [
          CommandGroup(heading: 'Suggestions', [
            CommandItem('Calendar', leading: const AshlarIcon(AshlarIconsRoundedStroke.calendar), onSelected: () {}),
            CommandItem(
              'Search emoji',
              leading: const AshlarIcon(AshlarIconsRoundedStroke.faceSlightlySmiling),
              onSelected: () {},
            ),
            CommandItem(
              'Calculator',
              leading: const AshlarIcon(AshlarIconsRoundedStroke.calculator),
              enabled: false,
              onSelected: () {},
            ),
          ]),
          CommandGroup(heading: 'Settings', [
            CommandItem(
              'Profile',
              leading: const AshlarIcon(AshlarIconsRoundedStroke.user),
              shortcut: '⌘P',
              onSelected: () {},
            ),
            CommandItem(
              'Billing',
              keywords: const ['invoice', 'payment'],
              leading: const AshlarIcon(AshlarIconsRoundedStroke.creditCard),
              shortcut: '⌘B',
              onSelected: () {},
            ),
            CommandItem(
              'Settings',
              leading: const AshlarIcon(AshlarIconsRoundedStroke.settings),
              shortcut: '⌘S',
              onSelected: () {},
            ),
          ]),
        ],
      ),
    );
  }
}
