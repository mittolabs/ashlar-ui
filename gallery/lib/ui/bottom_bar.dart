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
  }) : assert(items.length >= 2 && items.length <= 5);

  final List<BottomBarItem> items;

  /// The place you are in.
  final int index;

  /// Told the place chosen.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final rtl = isRtl(context);
    void step(int by) => onChanged((index + (rtl ? -by : by)) % items.length);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowRight): () => step(1),
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () => step(-1),
          },
          child: Semantics(
            role: SemanticsRole.tabBar,
            container: true,
            explicitChildNodes: true,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  for (final (i, item) in items.indexed)
                    Expanded(
                      child: Pressable(
                        role: SemanticsRole.tab,
                        selected: i == index,
                        semanticLabel: item.badge == null
                            ? item.label
                            : '${item.label}, ${item.badge}',
                        onPressed: () => onChanged(i),
                        builder: (context, state) {
                          final on = i == index;
                          final ink = on ? c.foreground : c.mutedForeground;
                          return AnimatedContainer(
                            duration: t.duration,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: state.hovered
                                  ? c.muted
                                  : const Color(0x00000000),
                              borderRadius: BorderRadius.circular(t.radiusMd),
                              border: state.focused
                                  ? Border.all(color: c.ring, width: 2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    IconTheme.merge(
                                      data: IconThemeData(color: ink, size: 22),
                                      child: on
                                          ? item.activeIcon ?? item.icon
                                          : item.icon,
                                    ),
                                    if (item.badge != null)
                                      PositionedDirectional(
                                        top: -4,
                                        end: -10,
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          height: 16,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: c.destructive,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: c.background,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Text(
                                            item.badge!,
                                            style: t.text.xs.copyWith(
                                              fontSize: 10,
                                              height: 1,
                                              color: c.destructiveForeground,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
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
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
