// Ashlar UI: Context Menu. Copied into your app by `ashlar add context-menu`; it is yours to
// change.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'dropdown_menu.dart';
import 'popover.dart';

/// A menu that opens where [child] is right-clicked or long-pressed, or from the keyboard
/// with the menu key or Shift+F10 while something inside it has focus. Takes the same
/// items as a DropdownMenu. On the web it turns the browser's own menu off while shown.
///
/// ```dart
/// ContextMenu(
///   items: [
///     MenuItem(onPressed: back, shortcut: Text('⌘['), child: Text('Back')),
///     MenuItem(onPressed: reload, shortcut: Text('⌘R'), child: Text('Reload')),
///   ],
///   child: Container(height: 150, child: Center(child: Text('Right-click here'))),
/// )
/// ```
class ContextMenu extends StatefulWidget {
  const ContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.width = 224,
  });

  final Widget child;

  /// [MenuItem], [MenuLabel] and [MenuSeparator], in order.
  final List<Widget> items;
  final double width;

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

/// How many context menus are on screen, so the browser's menu comes back with the last.
int _shown = 0;

class _ContextMenuState extends State<ContextMenu> {
  final _menu = MenuController();

  @override
  void initState() {
    super.initState();
    if (kIsWeb && _shown++ == 0) BrowserContextMenu.disableContextMenu();
  }

  @override
  void dispose() {
    if (kIsWeb && --_shown == 0) BrowserContextMenu.enableContextMenu();
    super.dispose();
  }

  void _openAt(Offset at) => _menu.open(position: at);

  @override
  Widget build(BuildContext context) => RawMenuAnchor(
    controller: _menu,
    overlayBuilder: (context, info) => PopoverPanel(
      info: info,
      width: widget.width,
      child: MenuList(children: widget.items),
    ),
    child: Builder(
      builder: (context) => Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.contextMenu): _OpenIntent(),
          SingleActivator(LogicalKeyboardKey.f10, shift: true): _OpenIntent(),
        },
        child: Actions(
          actions: {
            _OpenIntent: CallbackAction<_OpenIntent>(
              onInvoke: (_) {
                final box = context.findRenderObject()! as RenderBox;
                _openAt(box.size.center(Offset.zero));
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onSecondaryTapDown: (d) => _openAt(d.localPosition),
            onLongPressStart: (d) => _openAt(d.localPosition),
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}

class _OpenIntent extends Intent {
  const _OpenIntent();
}
