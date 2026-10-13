// Ashlar UI: Dropdown Menu. Copied into your app by `ashlar add dropdown-menu`; it is
// yours to change.

import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'popover.dart';
import 'pressable.dart';
import 'theme.dart';

/// A list of actions that opens from a trigger. [builder] draws the trigger and gets the
/// controller that opens it. The arrow keys move through the items, Enter picks one and
/// Escape closes the menu.
///
/// ```dart
/// DropdownMenu(
///   builder: (context, menu) => Button(variant: ButtonVariant.outline, onPressed: menu.open, child: Text('Open')),
///   items: [
///     MenuLabel(child: Text('My account')),
///     MenuItem(leading: AshlarIcon(AshlarIconsRoundedStroke.user), onPressed: profile, child: Text('Profile')),
///     MenuSeparator(),
///     MenuItem(destructive: true, onPressed: signOut, child: Text('Sign out')),
///   ],
/// )
/// ```
class DropdownMenu extends StatefulWidget {
  const DropdownMenu({
    super.key,
    required this.builder,
    required this.items,
    this.controller,
    this.side = PopoverSide.bottom,
    this.align = PopoverAlign.start,
    this.width,
  });

  final Widget Function(BuildContext context, MenuController controller)
  builder;

  /// [MenuItem], [MenuLabel] and [MenuSeparator], in order.
  final List<Widget> items;
  final MenuController? controller;
  final PopoverSide side;
  final PopoverAlign align;

  /// Null sizes the menu to its widest item.
  final double? width;

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  final _own = MenuController();

  @override
  Widget build(BuildContext context) => RawMenuAnchor(
    controller: widget.controller ?? _own,
    builder: (context, controller, _) => widget.builder(context, controller),
    overlayBuilder: (context, info) => PopoverPanel(
      info: info,
      side: widget.side,
      align: widget.align,
      width: widget.width,
      child: MenuList(children: widget.items),
    ),
  );
}

/// The items of an open menu, in a scrolling column: focus starts on the list, and the
/// arrow keys, Home and End move through the items. A Select uses it too.
class MenuList extends StatelessWidget {
  const MenuList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Semantics(
    role: SemanticsRole.menu,
    container: true,
    explicitChildNodes: true,
    child: Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
        SingleActivator(LogicalKeyboardKey.home): _EdgeIntent(first: true),
        SingleActivator(LogicalKeyboardKey.end): _EdgeIntent(first: false),
      },
      child: FocusScope(
        autofocus: true,
        child: Builder(
          builder: (context) => Actions(
            actions: {
              _EdgeIntent: CallbackAction<_EdgeIntent>(
                onInvoke: (i) {
                  final scope = FocusScope.of(context);
                  final items = scope.traversalDescendants.toList();
                  if (items.isEmpty) return null;
                  (i.first ? items.first : items.last).requestFocus();
                  return null;
                },
              ),
            },
            child: IntrinsicWidth(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _EdgeIntent extends Intent {
  const _EdgeIntent({required this.first});

  final bool first;
}

/// An action in a menu. Picking it closes the menu, then calls [onPressed].
class MenuItem extends StatefulWidget {
  const MenuItem({
    super.key,
    required this.child,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.shortcut,
    this.destructive = false,
    this.selected,
    this.autofocus = false,
  });

  final Widget child;

  /// Null disables the item.
  final VoidCallback? onPressed;

  /// A 16px icon before the label.
  final Widget? leading;

  /// An icon after the label, at the end of the row.
  final Widget? trailing;

  /// A key combination, shown faint at the end of the row: Text('⌘S').
  final Widget? shortcut;

  /// Drawn in the destructive colour: delete, sign out.
  final bool destructive;

  /// For a menu of choices: announced as chosen.
  final bool? selected;
  final bool autofocus;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return MouseRegion(
      // The pointer and the keyboard share one highlight, as in a native menu.
      onEnter: (_) => widget.onPressed == null ? null : _focus.requestFocus(),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (_) => setState(() {}),
        child: Pressable(
          focusNode: _focus,
          autofocus: widget.autofocus,
          role: SemanticsRole.menuItem,
          selected: widget.selected,
          onPressed: widget.onPressed == null
              ? null
              : () {
                  MenuController.maybeOf(context)?.close();
                  widget.onPressed!();
                },
          builder: (context, state) {
            final lit = state.enabled && (state.hovered || _focus.hasFocus);
            final fg = widget.destructive
                ? c.destructive
                : (lit ? c.accentForeground : c.popoverForeground);
            final bg = lit
                ? (widget.destructive
                      ? c.destructive.withValues(alpha: .1)
                      : c.accent)
                : const Color(0x00000000);
            return Opacity(
              opacity: state.enabled ? 1 : .5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(t.radiusSm),
                ),
                child: DefaultTextStyle.merge(
                  style: t.text.sm.copyWith(color: fg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: widget.destructive
                          ? c.destructive
                          : c.mutedForeground,
                      size: 16,
                    ),
                    child: Row(
                      children: [
                        if (widget.leading != null) ...[
                          widget.leading!,
                          const SizedBox(width: 8),
                        ],
                        Expanded(child: widget.child),
                        if (widget.shortcut != null) ...[
                          const SizedBox(width: 16),
                          DefaultTextStyle.merge(
                            style: t.text.xs.copyWith(
                              color: c.mutedForeground,
                              letterSpacing: 1.2,
                            ),
                            child: widget.shortcut!,
                          ),
                        ],
                        if (widget.trailing != null) ...[
                          const SizedBox(width: 8),
                          widget.trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A heading over a group of items.
class MenuLabel extends StatelessWidget {
  const MenuLabel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: DefaultTextStyle.merge(
        style: t.text.sm.copyWith(
          color: t.colors.popoverForeground,
          fontWeight: FontWeight.w500,
        ),
        child: Semantics(header: true, child: child),
      ),
    );
  }
}

/// A line between groups of items.
class MenuSeparator extends StatelessWidget {
  const MenuSeparator({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 4),
    transform: Matrix4.translationValues(0, 0, 0),
    color: AshlarTheme.of(context).colors.border,
  );
}
