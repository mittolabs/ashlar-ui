// Ashlar UI: Breadcrumb. Copied into your app by `ashlar add breadcrumb`; it is yours to
// change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'dropdown_menu.dart';
import 'pressable.dart';
import 'theme.dart';

/// One step on the way to where you are. The last is the page itself and is not a link.
@immutable
class BreadcrumbItem {
  const BreadcrumbItem(this.label, {this.onPressed});

  /// The page's name.
  final String label;

  /// Goes to the page. Null for the page you are on.
  final VoidCallback? onPressed;
}

/// Where a page sits: the pages above it, each a link, then the page itself. Past
/// [maxItems] the middle steps fold into an ellipsis that opens them as a menu.
///
/// ```dart
/// Breadcrumb(maxItems: 3, items: [
///   BreadcrumbItem('Home', onPressed: () => go('/')),
///   BreadcrumbItem('Docs', onPressed: () => go('/docs')),
///   BreadcrumbItem('Components', onPressed: () => go('/docs/components')),
///   BreadcrumbItem('Breadcrumb'),
/// ])
/// ```
class Breadcrumb extends StatelessWidget {
  const Breadcrumb({
    super.key,
    required this.items,
    this.separator,
    this.maxItems,
  });

  /// The pages, from the top down to this one.
  final List<BreadcrumbItem> items;

  /// Between steps; a chevron unless given: a slash, a dot.
  final Widget? separator;

  /// How many steps show before the middle ones fold away: the first, and the last ones.
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final style = t.text.sm;
    final fold = maxItems != null && items.length > maxItems! && maxItems! >= 2;
    final hidden = fold
        ? items.sublist(1, items.length - (maxItems! - 1))
        : const <BreadcrumbItem>[];
    final shown = fold
        ? [items.first, ...items.sublist(items.length - (maxItems! - 1))]
        : items;
    Widget step(BreadcrumbItem item, bool last) {
      if (last || item.onPressed == null) {
        return Semantics(
          // The page itself: aria-current="page".
          selected: last,
          child: Text(
            item.label,
            style: style.copyWith(
              color: last ? c.foreground : c.mutedForeground,
            ),
          ),
        );
      }
      return Pressable(
        onPressed: item.onPressed,
        link: true,
        builder: (context, state) => Text(
          item.label,
          style: style.copyWith(
            color: state.hovered || state.focused
                ? c.foreground
                : c.mutedForeground,
            decoration: state.focused ? TextDecoration.underline : null,
            decorationColor: c.foreground,
          ),
        ),
      );
    }

    final between = ExcludeSemantics(
      child: IconTheme.merge(
        data: IconThemeData(color: c.mutedForeground, size: 14),
        child: DefaultTextStyle.merge(
          style: style.copyWith(color: c.mutedForeground),
          child:
              separator ??
              AshlarIcon(
                isRtl(context)
                    ? AshlarIconsRoundedStroke.chevronLeft
                    : AshlarIconsRoundedStroke.chevronRight,
              ),
        ),
      ),
    );
    final parts = <Widget>[];
    for (final (i, item) in shown.indexed) {
      if (i > 0) parts.add(between);
      parts.add(step(item, i == shown.length - 1));
      if (fold && i == 0) {
        parts
          ..add(between)
          ..add(
            DropdownMenu(
              builder: (context, menu) => Pressable(
                onPressed: menu.open,
                semanticLabel: 'Show ${hidden.length} more',
                builder: (context, state) => Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: state.hovered ? c.accent : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(t.radiusSm),
                    boxShadow: [if (state.focused) ...t.focusRing],
                  ),
                  child: AshlarIcon(
                    AshlarIconsRoundedStroke.ellipsis,
                    size: 16,
                    color: c.mutedForeground,
                  ),
                ),
              ),
              items: [
                for (final h in hidden)
                  MenuItem(onPressed: h.onPressed, child: Text(h.label)),
              ],
            ),
          );
      }
    }
    return Semantics(
      container: true,
      label: 'Breadcrumb',
      explicitChildNodes: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: parts,
      ),
    );
  }
}
