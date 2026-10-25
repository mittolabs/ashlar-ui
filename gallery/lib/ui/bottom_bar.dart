// Ashlar UI: Bottom Bar. Copied into your app by `ashlar add bottom-bar`; it is yours to
// change.

import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'pressable.dart';
import 'theme.dart';

/// One place in a [BottomBar].
@immutable
class BottomBarItem {
  const BottomBarItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badge,
  });

  /// Its name, under the icon.
  final String label;
  final Widget icon;

  /// Shown instead of [icon] while it is the place you are: a filled icon, say.
  final Widget? activeIcon;

  /// A count to show on the icon: unread messages. Null shows none.
  final String? badge;
}

/// An app's main places along the bottom of a phone screen, an icon and a name each,
/// above the home indicator. Two to five places; the one you are in stands out.
///
/// To a screen reader it is a tab bar; from a keyboard, the arrow keys move along it.
///
/// [floating] lays it in a rounded bar of its own over the page, icons alone.
///
/// ```dart
/// BottomBar(
///   index: page,
///   onChanged: (i) => setState(() => page = i),
///   items: [
///     BottomBarItem(label: 'Home', icon: AshlarIcon(AshlarIconsRoundedStroke.house)),
///     BottomBarItem(label: 'Inbox', icon: AshlarIcon(AshlarIconsRoundedStroke.inbox), badge: '3'),
///   ],
/// )
/// ```
class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.floating = false,
  }) : assert(items.length >= 2 && items.length <= 5);

  final List<BottomBarItem> items;

  /// The place you are in.
  final int index;

  /// Told the place chosen.
  final ValueChanged<int> onChanged;

  /// Floats over the page in a rounded bar of its own: icons alone, the place you are in a
  /// filled circle, the names still read out. Lay it over the bottom of the page (in a
  /// Stack, clear of the home indicator) and leave room under the page's last line.
  final bool floating;

  /// Its count over the top end corner of an icon.
  Widget _badge(BuildContext context, AshlarThemeData t, String count) {
    final c = t.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      // As tall as it is drawn, or taller when larger text needs it.
      height: grownHeight(context, 16, line: 10),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.destructive,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.background, width: 1.5),
      ),
      child: Text(
        count,
        style: t.text.xs.copyWith(
          fontSize: 10,
          height: 1,
          color: c.destructiveForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _place(
    BuildContext context,
    int i,
    Widget Function(PressableState state, bool on) look,
  ) {
    final item = items[i];
    return Pressable(
      role: SemanticsRole.tab,
      selected: i == index,
      semanticLabel: item.badge == null
          ? item.label
          : '${item.label}, ${item.badge}',
      onPressed: () => onChanged(i),
      builder: (context, state) => look(state, i == index),
    );
  }

  Widget _icon(
    BuildContext context,
    AshlarThemeData t,
    int i,
    Color ink,
    double size,
  ) {
    final item = items[i];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconTheme.merge(
          data: IconThemeData(color: ink, size: size),
          child: i == index ? item.activeIcon ?? item.icon : item.icon,
        ),
        if (item.badge != null)
          PositionedDirectional(
            top: -4,
            end: -10,
            child: _badge(context, t, item.badge!),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final rtl = isRtl(context);
    void step(int by) => onChanged((index + (rtl ? -by : by)) % items.length);
    Widget bar(Widget child) => CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => step(1),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => step(-1),
      },
      child: Semantics(
        role: SemanticsRole.tabBar,
        container: true,
        explicitChildNodes: true,
        child: child,
      ),
    );
    if (floating) {
      return bar(
        Container(
          height: 72,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: c.border),
            boxShadow: t.shadowLg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                _place(
                  context,
                  i,
                  (state, on) => AnimatedContainer(
                    duration: t.duration,
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on
                          ? c.primary
                          : (state.hovered
                                ? c.muted
                                : c.muted.withValues(alpha: 0)),
                      border: state.focused
                          ? Border.all(color: c.ring, width: 2)
                          : null,
                    ),
                    child: _icon(
                      context,
                      t,
                      i,
                      on ? c.primaryForeground : c.cardForeground,
                      24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: bar(
          SizedBox(
            height: 56,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _place(context, i, (state, on) {
                      final ink = on ? c.foreground : c.mutedForeground;
                      return AnimatedContainer(
                        duration: t.duration,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: state.hovered
                              ? c.muted
                              : c.muted.withValues(alpha: 0),
                          borderRadius: BorderRadius.circular(t.radiusMd),
                          border: state.focused
                              ? Border.all(color: c.ring, width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _icon(context, t, i, ink, 22),
                            const SizedBox(height: 4),
                            Text(
                              items[i].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.text.xs.copyWith(
                                color: ink,
                                fontWeight: on
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
