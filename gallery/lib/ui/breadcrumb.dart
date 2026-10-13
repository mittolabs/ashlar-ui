// Ashlar UI: Breadcrumb. Copied into your app by `ashlar add breadcrumb`; it is yours to
// change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'pressable.dart';
import 'theme.dart';

/// One step on the way to where you are. The last is the page itself and is not a link.
@immutable
class BreadcrumbItem {
  const BreadcrumbItem(this.label, {this.onPressed});

  final String label;
  final VoidCallback? onPressed;
}

/// Where a page sits: the pages above it, each a link, then the page itself.
///
/// ```dart
/// Breadcrumb(items: [
///   BreadcrumbItem('Home', onPressed: () => go('/')),
///   BreadcrumbItem('Components', onPressed: () => go('/components')),
///   BreadcrumbItem('Breadcrumb'),
/// ])
/// ```
class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.items});

  final List<BreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final style = t.text.sm;
    return Semantics(
      container: true,
      label: 'Breadcrumb',
      explicitChildNodes: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0)
              ExcludeSemantics(
                child: AshlarIcon(
                  AshlarIconsRoundedStroke.chevronRight,
                  size: 14,
                  color: c.mutedForeground,
                ),
              ),
            if (i == items.length - 1 || item.onPressed == null)
              Semantics(
                // The page itself: aria-current="page".
                selected: i == items.length - 1,
                child: Text(
                  item.label,
                  style: style.copyWith(
                    color: i == items.length - 1
                        ? c.foreground
                        : c.mutedForeground,
                  ),
                ),
              )
            else
              Pressable(
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
              ),
          ],
        ],
      ),
    );
  }
}
