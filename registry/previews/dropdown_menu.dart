// The dropdown-menu picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';

class DropdownMenuDemo extends StatelessWidget {
  const DropdownMenuDemo({super.key});

  @override
  Widget build(BuildContext context) => DropdownMenu(
    width: 224,
    builder: (context, menu) => Button(
      variant: ButtonVariant.outline,
      trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronDown),
      onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      child: const Text('My account'),
    ),
    items: [
      const MenuLabel(child: Text('My account')),
      MenuItem(
        leading: const AshlarIcon(AshlarIconsRoundedStroke.user),
        shortcut: const Text('⇧⌘P'),
        onPressed: () {},
        child: const Text('Profile'),
      ),
      MenuItem(
        leading: const AshlarIcon(AshlarIconsRoundedStroke.creditCard),
        onPressed: () {},
        child: const Text('Billing'),
      ),
      MenuItem(
        leading: const AshlarIcon(AshlarIconsRoundedStroke.settings),
        shortcut: const Text('⌘,'),
        onPressed: () {},
        child: const Text('Settings'),
      ),
      const MenuSeparator(),
      MenuItem(
        leading: const AshlarIcon(AshlarIconsRoundedStroke.logOut),
        destructive: true,
        onPressed: () {},
        child: const Text('Sign out'),
      ),
    ],
  );
}
