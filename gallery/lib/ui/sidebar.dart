// Ashlar UI: Sidebar. Copied into your app by `ashlar add sidebar`; it is yours to change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'button.dart';
import 'pressable.dart';
import 'sheet.dart';
import 'theme.dart';
import 'tooltip.dart';

/// A place in the app, on the sidebar.
@immutable
class SidebarItem {
  const SidebarItem(
    this.label, {
    required this.icon,
    required this.onPressed,
    this.active = false,
    this.badge,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  /// The page being shown.
  final bool active;

  /// A count or a word at the end of the row: '12'.
  final String? badge;
}

/// A titled run of [SidebarItem]s.
@immutable
class SidebarGroup {
  const SidebarGroup(this.items, {this.label});

  final String? label;
  final List<SidebarItem> items;
}

/// How a sidebar gets out of the way.
enum SidebarCollapse {
  /// Down to a strip of icons, each with its label in a tooltip.
  icons,

  /// Off the side of the screen entirely.
  offcanvas,
}

/// An app's main navigation down the left side, beside [child]. It collapses with a
/// [SidebarTrigger] or ⌘B (Ctrl+B), to icons or out of sight; on a narrow screen it is
/// hidden, and the trigger slides it in over the page.
///
/// ```dart
/// SidebarLayout(
///   header: Text('Acme'),
///   groups: [SidebarGroup(label: 'App', [
///     SidebarItem('Home', icon: AshlarIconsRoundedStroke.house, active: true, onPressed: () => go('/')),
///     SidebarItem('Inbox', icon: AshlarIconsRoundedStroke.inbox, badge: '12', onPressed: () => go('/inbox')),
///   ])],
///   child: Column(children: [Row(children: [SidebarTrigger()]), Expanded(child: page)]),
/// )
/// ```
class SidebarLayout extends StatefulWidget {
  const SidebarLayout({
    super.key,
    required this.groups,
    required this.child,
    this.header,
    this.footer,
    this.collapse = SidebarCollapse.icons,
    this.initiallyOpen = true,
    this.width = 256,
    this.narrow = 768,
  });

  final List<SidebarGroup> groups;
  final Widget child;
  final Widget? header, footer;
  final SidebarCollapse collapse;
  final bool initiallyOpen;
  final double width;

  /// Below this width the sidebar is hidden, and slides in over the page.
  final double narrow;

  /// The layout above [context]: whether it is open, and the way to toggle it.
  static SidebarLayoutState of(BuildContext context) =>
      context.findAncestorStateOfType<SidebarLayoutState>()!;

  @override
  State<SidebarLayout> createState() => SidebarLayoutState();
}

class SidebarLayoutState extends State<SidebarLayout> {
  late bool _open = widget.initiallyOpen;
  bool _narrow = false;

  bool get open => _open;

  /// Opens or closes it; on a narrow screen, slides it in over the page.
  void toggle() {
    if (_narrow) {
      final theme = AshlarTheme.of(context);
      showSheet<void>(
        context: context,
        side: SheetSide.left,
        builder: (context) => Align(
          alignment: Alignment.centerLeft,
          child: AshlarTheme(
            data: theme,
            child: SizedBox(
              width: 288,
              child: _Panel(
                layout: widget,
                collapsed: false,
                onPicked: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      );
      return;
    }
    setState(() => _open = !_open);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      _narrow = box.maxWidth < widget.narrow;
      final collapsed = !_open && widget.collapse == SidebarCollapse.icons;
      final width = _narrow
          ? 0.0
          : (_open ? widget.width : (collapsed ? 48.0 : 0.0));
      final t = AshlarTheme.of(context);
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyB, meta: true): toggle,
          const SingleActivator(LogicalKeyboardKey.keyB, control: true): toggle,
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: t.duration * 1.5,
              curve: Curves.easeOutCubic,
              width: width,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: collapsed ? 48 : widget.width,
                  maxWidth: collapsed ? 48 : widget.width,
                  // Out of sight is out of the Tab order and of what screen readers read.
                  child: width == 0
                      ? const SizedBox()
                      : _Panel(layout: widget, collapsed: collapsed),
                ),
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    },
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.layout, required this.collapsed, this.onPicked});

  final SidebarLayout layout;
  final bool collapsed;

  /// On a narrow screen the panel closes once something is picked.
  final VoidCallback? onPicked;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Semantics(
      container: true,
      label: 'Sidebar',
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          color: c.sidebar,
          border: Border(right: BorderSide(color: c.sidebarBorder)),
        ),
        child: SafeArea(
          right: false,
          child: DefaultTextStyle.merge(
            style: t.text.sm.copyWith(color: c.sidebarForeground),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (layout.header != null && !collapsed)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: layout.header,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (gi, g) in layout.groups.indexed) ...[
                          if (gi > 0) const SizedBox(height: 16),
                          if (g.label != null && !collapsed)
                            SizedBox(
                              height: 32,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Semantics(
                                    header: true,
                                    child: Text(
                                      g.label!,
                                      style: t.text.xs.copyWith(
                                        color: c.sidebarForeground.withValues(
                                          alpha: .7,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          for (final item in g.items)
                            _Item(
                              item: item,
                              collapsed: collapsed,
                              onPicked: onPicked,
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (layout.footer != null && !collapsed)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: layout.footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.collapsed, this.onPicked});

  final SidebarItem item;
  final bool collapsed;
  final VoidCallback? onPicked;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final row = Pressable(
      selected: item.active,
      semanticLabel: collapsed ? item.label : null,
      onPressed: () {
        onPicked?.call();
        item.onPressed();
      },
      builder: (context, state) {
        final lit = item.active || state.hovered;
        final fg = lit ? c.sidebarAccentForeground : c.sidebarForeground;
        return AnimatedContainer(
          duration: t.duration,
          height: 32,
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 8),
          alignment: collapsed ? Alignment.center : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: lit ? c.sidebarAccent : const Color(0x00000000),
            borderRadius: BorderRadius.circular(t.radiusMd),
            boxShadow: [
              if (state.focused)
                BoxShadow(color: c.sidebarRing, spreadRadius: 2),
            ],
          ),
          child: collapsed
              ? AshlarIcon(item.icon, size: 16, color: fg)
              : Row(
                  children: [
                    AshlarIcon(item.icon, size: 16, color: fg),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.text.sm.copyWith(
                          color: fg,
                          fontWeight: item.active ? FontWeight.w500 : null,
                        ),
                      ),
                    ),
                    if (item.badge != null)
                      Text(
                        item.badge!,
                        style: t.text.xs.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
        );
      },
    );
    return collapsed ? Tooltip(message: item.label, child: row) : row;
  }
}

/// The button that opens and closes the [SidebarLayout] above it.
class SidebarTrigger extends StatelessWidget {
  const SidebarTrigger({super.key});

  @override
  Widget build(BuildContext context) => Button(
    variant: ButtonVariant.ghost,
    size: ButtonSize.icon,
    semanticLabel: 'Toggle sidebar',
    onPressed: () => SidebarLayout.of(context).toggle(),
    child: const AshlarIcon(AshlarIconsRoundedStroke.panelLeft),
  );
}
