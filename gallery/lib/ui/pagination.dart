// Ashlar UI: Pagination. Copied into your app by `ashlar add pagination`; it is yours to
// change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'button.dart';
import 'theme.dart';

/// Moves between the pages of a long list: Previous, the page numbers near this one with
/// the first and last, and Next. Pages count from 1.
///
/// ```dart
/// Pagination(page: page, pageCount: 12, onChanged: (p) => setState(() => page = p))
/// ```
class Pagination extends StatelessWidget {
  const Pagination({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onChanged,
    this.siblings = 1,
    this.simple = false,
  });

  final int page;
  final int pageCount;
  final ValueChanged<int> onChanged;

  /// How many pages either side of this one are shown by number.
  final int siblings;

  /// Previous, "Page 2 of 10" and Next, without the numbers.
  final bool simple;

  /// The pages to show by number, with null for a gap.
  List<int?> get _pages {
    final shown = <int>{
      1,
      pageCount,
      for (var p = page - siblings; p <= page + siblings; p++) p,
    }.where((p) => p >= 1 && p <= pageCount).toList()..sort();
    final out = <int?>[];
    for (final p in shown) {
      if (out.isNotEmpty && p - out.last! > 1) {
        // A gap of one page shows the page; a longer one shows an ellipsis.
        if (p - out.last! == 2) {
          out.add(p - 1);
        } else {
          out.add(null);
        }
      }
      out.add(p);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    if (simple) {
      return Semantics(
        container: true,
        label: 'Pagination',
        explicitChildNodes: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.iconSm,
              semanticLabel: 'Previous page',
              onPressed: page > 1 ? () => onChanged(page - 1) : null,
              child: const AshlarIcon(AshlarIconsRoundedStroke.chevronLeft),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Page $page of $pageCount',
                style: t.text.sm.copyWith(
                  color: c.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.iconSm,
              semanticLabel: 'Next page',
              onPressed: page < pageCount ? () => onChanged(page + 1) : null,
              child: const AshlarIcon(AshlarIconsRoundedStroke.chevronRight),
            ),
          ],
        ),
      );
    }
    return Semantics(
      container: true,
      label: 'Pagination',
      explicitChildNodes: true,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Button(
            variant: ButtonVariant.ghost,
            leading: const AshlarIcon(AshlarIconsRoundedStroke.chevronLeft),
            semanticLabel: 'Previous page',
            onPressed: page > 1 ? () => onChanged(page - 1) : null,
            child: const Text('Previous'),
          ),
          for (final p in _pages)
            if (p == null)
              Semantics(
                label: 'More pages',
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: 36,
                    child: Center(
                      child: AshlarIcon(
                        AshlarIconsRoundedStroke.ellipsis,
                        size: 16,
                        color: c.mutedForeground,
                      ),
                    ),
                  ),
                ),
              )
            else
              Button(
                variant: p == page
                    ? ButtonVariant.outline
                    : ButtonVariant.ghost,
                size: ButtonSize.icon,
                semanticLabel: p == page ? 'Page $p, current page' : 'Page $p',
                onPressed: p == page ? () {} : () => onChanged(p),
                child: Text('$p'),
              ),
          Button(
            variant: ButtonVariant.ghost,
            trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronRight),
            semanticLabel: 'Next page',
            onPressed: page < pageCount ? () => onChanged(page + 1) : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
