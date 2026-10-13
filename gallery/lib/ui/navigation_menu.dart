// Ashlar UI: Navigation Menu. Copied into your app by `ashlar add navigation-menu`; it is
// yours to change.

import 'dart:async';

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'popover.dart';
import 'pressable.dart';
import 'theme.dart';

/// One entry of a [NavigationMenu]: a link, or a heading that opens a panel of [content].
@immutable
class NavigationMenuItem {
  const NavigationMenuItem.link(
    this.label, {
    required VoidCallback this.onPressed,
  }) : content = null,
       width = 0;
  const NavigationMenuItem(
    this.label, {
    required WidgetBuilder this.content,
    this.width = 400,
  }) : onPressed = null;

  /// Its name in the bar.
  final String label;

  /// Called when it is chosen, for an item without a panel.
  final VoidCallback? onPressed;

  /// What its panel shows, usually links; null makes it a link itself.
  final WidgetBuilder? content;

  /// The panel's width.
  final double width;
}

/// A site's main navigation: links, and headings whose panels open on hover, on a click
/// or from the keyboard, with links and a line about each inside. Moving to another
/// heading while one is open switches straight to it.
///
/// ```dart
/// NavigationMenu(items: [
///   NavigationMenuItem('Components', content: (context) => Column(children: [
///     NavigationMenuLink(title: 'Button', description: 'Six variants and four sizes.', onPressed: () => go('/button')),
///   ])),
///   NavigationMenuItem.link('Docs', onPressed: () => go('/docs')),
/// ])
/// ```
class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key, required this.items});

  /// The items along the bar.
  final List<NavigationMenuItem> items;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late final _menus = [for (final _ in widget.items) MenuController()];
  int? _open;
  Timer? _timer;

  void _show(int i) {
    _timer?.cancel();
    for (final (j, m) in _menus.indexed) {
      if (j != i && m.isOpen) m.close();
    }
    if (!_menus[i].isOpen) _menus[i].open();
  }

  /// Opens after a moment on hover, straight away if one is already open.
  void _hoverIn(int i) {
    _timer?.cancel();
    if (_open != null) return _show(i);
    _timer = Timer(
      const Duration(milliseconds: 200),
      () => mounted ? _show(i) : null,
    );
  }

  void _hoverOut() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _open != null) _menus[_open!].close();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget trigger(int i, NavigationMenuItem item, {required bool open}) =>
        Pressable(
          link: item.onPressed != null,
          expanded: item.content == null ? null : open,
          onPressed:
              item.onPressed ?? () => open ? _menus[i].close() : _show(i),
          builder: (context, state) => AnimatedContainer(
            duration: t.duration,
            height: t.control(36),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: open || state.hovered ? c.accent : const Color(0x00000000),
              borderRadius: BorderRadius.circular(t.radiusMd),
              boxShadow: [if (state.focused) ...t.focusRing],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label,
                  style: t.text.sm.copyWith(
                    fontWeight: FontWeight.w500,
                    color: open || state.hovered
                        ? c.accentForeground
                        : c.foreground,
                  ),
                ),
                if (item.content != null) ...[
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: open ? .5 : 0,
                    duration: t.duration,
                    child: AshlarIcon(
                      AshlarIconsRoundedStroke.chevronDown,
                      size: 12,
                      color: c.foreground,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
    return Semantics(
      container: true,
      label: 'Main',
      explicitChildNodes: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, item) in widget.items.indexed)
            if (item.content == null)
              trigger(i, item, open: false)
            else
              RawMenuAnchor(
                controller: _menus[i],
                onOpen: () => setState(() => _open = i),
                onClose: () =>
                    setState(() => _open = _open == i ? null : _open),
                overlayBuilder: (context, info) => PopoverPanel(
                  info: info,
                  width: item.width,
                  child: MouseRegion(
                    onEnter: (_) => _timer?.cancel(),
                    onExit: (_) => _hoverOut(),
                    child: FocusTraversalGroup(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Builder(builder: item.content!),
                      ),
                    ),
                  ),
                ),
                child: MouseRegion(
                  onEnter: (_) => _hoverIn(i),
                  onExit: (_) => _hoverOut(),
                  child: trigger(i, item, open: _open == i),
                ),
              ),
        ],
      ),
    );
  }
}

/// A link in a navigation panel, with a line about where it goes. Picking it closes the
/// panel.
class NavigationMenuLink extends StatelessWidget {
  const NavigationMenuLink({
    super.key,
    required this.title,
    this.description,
    required this.onPressed,
  });

  /// The link's name.
  final String title;

  /// A line under the name: where it goes.
  final String? description;

  /// Called when it is chosen.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Pressable(
      link: true,
      onPressed: () {
        MenuController.maybeOf(context)?.close();
        onPressed();
      },
      builder: (context, state) => AnimatedContainer(
        duration: t.duration,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: state.hovered || state.focused
              ? c.accent
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(t.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: t.text.sm.copyWith(
                fontWeight: FontWeight.w500,
                color: c.popoverForeground,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 2),
              Text(
                description!,
                style: t.text.sm.copyWith(color: c.mutedForeground),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
