// The menubar picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';
import 'package:ashlar_ui_gallery/ui/menubar.dart';

class MenubarDemo extends StatelessWidget {
  const MenubarDemo({super.key});

  @override
  Widget build(BuildContext context) => Menubar(
    menus: [
      MenubarMenu(
        'File',
        items: [
          MenuItem(shortcut: const Text('⌘T'), onPressed: () {}, child: const Text('New tab')),
          MenuItem(shortcut: const Text('⌘N'), onPressed: () {}, child: const Text('New window')),
          const MenuSeparator(),
          MenuItem(shortcut: const Text('⌘P'), onPressed: () {}, child: const Text('Print…')),
        ],
      ),
      MenubarMenu(
        'Edit',
        items: [
          MenuItem(shortcut: const Text('⌘Z'), onPressed: () {}, child: const Text('Undo')),
          MenuItem(shortcut: const Text('⇧⌘Z'), onPressed: () {}, child: const Text('Redo')),
          const MenuSeparator(),
          MenuItem(onPressed: () {}, child: const Text('Find…')),
        ],
      ),
      MenubarMenu(
        'View',
        items: [
          MenuItem(onPressed: () {}, child: const Text('Reload')),
          MenuItem(onPressed: () {}, child: const Text('Full screen')),
        ],
      ),
    ],
  );
}
