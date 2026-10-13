// The context-menu picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/context_menu.dart';
import 'package:ashlar_ui_gallery/ui/dropdown_menu.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class ContextMenuDemo extends StatelessWidget {
  const ContextMenuDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return ContextMenu(
      items: [
        MenuItem(shortcut: const Text('⌘['), onPressed: () {}, child: const Text('Back')),
        MenuItem(shortcut: const Text('⌘]'), onPressed: null, child: const Text('Forward')),
        MenuItem(shortcut: const Text('⌘R'), onPressed: () {}, child: const Text('Reload')),
        const MenuSeparator(),
        MenuItem(onPressed: () {}, child: const Text('Save page as…')),
      ],
      child: Container(
        width: 300,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: t.colors.border),
          borderRadius: BorderRadius.circular(t.radiusMd),
        ),
        child: Text('Right-click here', style: TextStyle(color: t.colors.mutedForeground)),
      ),
    );
  }
}
